param(
  [string]$ListsPath = "datamodel/sharepoint/lists",
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [string]$ReportPath = ".\.serena\logs\sp-diff-$((Get-Date -Format 'yyyyMMdd-HHmmss')).txt",
  [ValidateSet("Cached","Interactive","DeviceLogin")]
  [string]$Auth = "Cached",
  [string]$Tenant
)

$ErrorActionPreference = 'Stop'
$script:ReportPath = $ReportPath

# Re-exec under PowerShell 7+ if currently running in Windows PowerShell 5.1
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "[sp-diff] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
  $pwshCmd = $null
  try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
  if (-not $pwshCmd) {
    Write-Host "[sp-diff] pwsh (PowerShell 7) not found. Please install PowerShell 7.4.6 or newer from https://github.com/PowerShell/PowerShell and re-run." -ForegroundColor Red
    exit 5
  }
  $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSCommandPath")
  foreach ($k in $PSBoundParameters.Keys) {
    $v = $PSBoundParameters[$k]
    $argList += "-$k"
    if ($null -ne $v -and $v -ne $true) { $argList += "$v" }
  }
  & $pwshCmd @argList
  exit $LASTEXITCODE
}

function Write-Log {
  param(
    [string]$Message,
    [ConsoleColor]$Color = [ConsoleColor]::White
  )
  Write-Host $Message -ForegroundColor $Color
  if ($script:ReportPath) {
    Add-Content -Path $script:ReportPath -Value $Message
  }
}

function NormalizeType {
  param([string]$t)
  if ([string]::IsNullOrWhiteSpace($t)) { return '(unknown)' }
  return $t.Trim()
}

function ExpectedToSpType {
  param([string]$e)
  if ($e -eq 'Text') { return 'Text' }
  elseif ($e -eq 'Note') { return 'Note' }
  elseif ($e -eq 'Number') { return 'Number' }
  elseif ($e -eq 'Currency') { return 'Currency' }
  elseif ($e -eq 'Boolean' -or $e -eq 'YesNo') { return 'Boolean' }
  elseif ($e -eq 'DateTime') { return 'DateTime' }
  elseif ($e -eq 'Choice') { return 'Choice' }
  elseif ($e -eq 'User') { return 'User' }
  elseif ($e -eq 'Lookup') { return 'Lookup' }
  elseif ($e -eq 'URL') { return 'URL' }
  elseif ($e -eq 'ManagedMetadata') { return 'TaxonomyFieldType' }
  else { return $e }
}

$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$authModule = Join-Path $PSScriptRoot 'modules/SpAuth.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }
$moduleName = 'PnP.PowerShell'
# Ensure PnP.PowerShell is available; if not, guide the user to install it manually
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
  Write-Host "[sp-diff] Missing required module '$moduleName'." -ForegroundColor Red
  Write-Host "Install it for the current user, then re-run this task:" -ForegroundColor Yellow
  Write-Host "  Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -MinimumVersion 2.8.5.201" -ForegroundColor Yellow
  Write-Host "  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted" -ForegroundColor Yellow
  Write-Host "  Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force -AllowClobber" -ForegroundColor Yellow
  exit 4
}
Import-Module $moduleName -ErrorAction Stop
$env = @{ Dev="https://ibstbim.sharepoint.com/sites/idop-dev"; Test="https://ibstbim.sharepoint.com/sites/idop-test"; Prod="https://ibstbim.sharepoint.com/sites/idop-prod" }
if (-not $env.ContainsKey($Environment)) { Write-Host "Unknown environment $Environment" -ForegroundColor Red; exit 1 }
$siteUrl = $env[$Environment]

Write-Host "[sp-diff] Inspect $Environment ($siteUrl) from '$ListsPath'" -ForegroundColor Yellow

# Ensure report directory exists and header
$reportDir = Split-Path -Path $ReportPath -Parent
if (-not (Test-Path -LiteralPath $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
"# sp-diff $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`nEnv: $Environment ($siteUrl)`nListsPath: $ListsPath" | Set-Content -Path $ReportPath

try {
  # Infer tenant hostname from site URL if not provided, e.g. ibstbim.onmicrosoft.com
  if (-not $Tenant -or [string]::IsNullOrWhiteSpace($Tenant)) {
    try {
      $uri = [uri]$siteUrl
      $siteHost = $uri.Host  # e.g., ibstbim.sharepoint.com
      $tenantBase = ($siteHost -split '\.')[0]
      if ($tenantBase) { $Tenant = "$tenantBase.onmicrosoft.com" }
    } catch {}
  }
  if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
    Write-Host "[sp-diff] Using '$Auth' auth via helper..." -ForegroundColor Yellow
    Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -Tenant $Tenant -ClientId $clientId
  } else {
    Write-Host "[sp-diff] Helper missing, using baseline auth '$Auth'..." -ForegroundColor Yellow
    if ($Auth -eq 'DeviceLogin') {
      if ($Tenant) { Connect-PnPOnline -Url $siteUrl -DeviceLogin -ClientId $clientId -Tenant $Tenant }
      else { Connect-PnPOnline -Url $siteUrl -DeviceLogin -ClientId $clientId }
    } elseif ($Auth -eq 'Interactive') {
      if ($Tenant) { Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId -Tenant $Tenant }
      else { Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId }
    } else {
      # Cached attempt
      Connect-PnPOnline -Url $siteUrl -PnPManagementShell
    }
  }
  Write-Log "[sp-diff] Connected" Green
}
catch {
  Write-Log "[sp-diff] Connect failed: $($_.Exception.Message)" Red
  exit 2
}

try {
  $serverRelativeUrl = (Get-PnPWeb).ServerRelativeUrl
}
catch {
  $serverRelativeUrl = $null
}

$total = 0
$ok = 0
$missing = 0
$fieldIssues = 0

$jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
foreach ($jsonFile in $jsonFiles) {
  $total++
  $json = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json
  $listName = $json.ListName
  Write-Log "`n=== List: $listName (from $($jsonFile.FullName)) ===" Cyan

  $list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
  if (-not $list) { $list = Get-PnPList -Identity "Lists/$listName" -ErrorAction SilentlyContinue }
  if (-not $list -and $serverRelativeUrl) {
    $sr = $serverRelativeUrl.TrimEnd('/')
    $list = Get-PnPList -Identity "$sr/Lists/$listName" -ErrorAction SilentlyContinue
  }
  if (-not $list) {
    Write-Log "  Missing list on site: $listName" Red
    $missing++
    continue
  }

  $spFields = Get-PnPField -List $list | ForEach-Object { [pscustomobject]@{ InternalName = $_.InternalName; Type = (NormalizeType $_.TypeAsString) } }
  $spMap = @{}
  foreach ($f in $spFields) { $spMap[$f.InternalName] = $f }

  $listOk = $true
  foreach ($ef in $json.Columns) {
    if (-not $spMap.ContainsKey($ef.Name)) {
      Write-Log "  Missing field: $($ef.Name) (expected type: $($ef.Type))" Red
      $listOk = $false
      $fieldIssues++
      continue
    }

    $spf = $spMap[$ef.Name]
    $expectedSpType = ExpectedToSpType $ef.Type
    if ($ef.Type -eq 'ManagedMetadata') {
      if ($spf.Type -notmatch 'Taxonomy') {
        Write-Log "  Type mismatch: $($ef.Name) expected Taxonomy, got '$($spf.Type)'" Yellow
        $listOk = $false
        $fieldIssues++
      }
      else {
        Write-Log "  OK $($ef.Name): Taxonomy" Green
      }
    }
    else {
      if ($spf.Type -ne $expectedSpType) {
        Write-Log "  Type mismatch: $($ef.Name) expected '$expectedSpType', got '$($spf.Type)'" Yellow
        $listOk = $false
        $fieldIssues++
      }
      else {
        Write-Log "  OK $($ef.Name): $($spf.Type)" Green
      }
    }
  }

  if ($listOk) {
    Write-Log "  List matches expected schema." Green
    $ok++
  }
  else {
    Write-Log "  List has discrepancies." Yellow
  }
}

Write-Log "`n=== SUMMARY ===" Cyan
Write-Log "Total JSON lists: $total" White
Write-Log "Lists OK: $ok" Green
Write-Log "Missing lists: $missing" Red
Write-Log "Fields with issues: $fieldIssues" Yellow
Write-Log "Report saved: $ReportPath" Cyan
