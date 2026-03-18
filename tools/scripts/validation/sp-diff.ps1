param(
  [string]$ListsPath = "datamodel/sharepoint/lists",
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [string]$ReportPath = ".\tools\output\logs\sp-diff-$((Get-Date -Format 'yyyyMMdd-HHmmss')).txt",
  [ValidateSet("Cached","Interactive","DeviceLogin")]
  [string]$Auth = "Cached",
  [string]$Tenant,
  [ValidateSet('all','issues','changed')]
  [string]$Focus = 'all',
  [string]$OnlyLists,
  [string]$SinceGit
)

$ErrorActionPreference = 'Stop'
$script:ReportPath = $ReportPath
${stateDir} = ".\tools\output\state"
${stateFile} = Join-Path $stateDir "sp-diff-last.json"

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
  param($ef)
  $e = if ($ef -is [hashtable]) { $ef['Type'] } else { $ef.Type }
  if ($e -eq 'Text') { return 'Text' }
  elseif ($e -eq 'Note') { return 'Note' }
  elseif ($e -eq 'Number') { return 'Number' }
  elseif ($e -eq 'Currency') { return 'Currency' }
  elseif ($e -eq 'Boolean' -or $e -eq 'YesNo') { return 'Boolean' }
  elseif ($e -eq 'DateTime') { return 'DateTime' }
  elseif ($e -eq 'Choice') { return 'Choice' }
  elseif ($e -eq 'Hyperlink' -or $e -eq 'URL') { return 'URL' }
  elseif ($e -eq 'User') {
    $allowMulti = $false
    try {
      if ($ef -and $ef.PSObject -and $ef.PSObject.Properties['AllowMultiple']) { $allowMulti = [bool]$ef.AllowMultiple }
      elseif ($ef -is [hashtable] -and $ef.ContainsKey('AllowMultiple')) { $allowMulti = [bool]$ef['AllowMultiple'] }
    } catch { $allowMulti = $false }
    if ($allowMulti) { return 'UserMulti' } else { return 'User' }
  }
  elseif ($e -eq 'Lookup') { return 'Lookup' }
  elseif ($e -eq 'ManagedMetadata') { return 'TaxonomyFieldType' }
  else { return $e }
}

function Get-JsonHash {
  param([string]$path)
  try {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $sha = [System.Security.Cryptography.SHA1]::Create()
    $hash = $sha.ComputeHash($bytes)
    return ([System.BitConverter]::ToString($hash) -replace '-', '')
  } catch { return $null }
}

$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$authModule = Join-Path $PSScriptRoot '../modules/PnPHelpers.psm1'
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

Write-Host "[sp-diff] Inspect $Environment ($siteUrl) from '$ListsPath' (Focus=$Focus)" -ForegroundColor Yellow

# Ensure report directory exists and header
$reportDir = Split-Path -Path $ReportPath -Parent
if (-not (Test-Path -LiteralPath $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
"# sp-diff $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`nEnv: $Environment ($siteUrl)`nListsPath: $ListsPath`nFocus: $Focus" | Set-Content -Path $ReportPath

# Load previous state if exists
$lastState = @{}
if (Test-Path -LiteralPath $stateFile) {
  try { $lastState = Get-Content -Raw -Path $stateFile | ConvertFrom-Json } catch { $lastState = @{} }
}

# Ensure state is a hashtable for easy ContainsKey/indexing
function ConvertTo-Hashtable {
  param([psobject]$obj)
  if ($null -eq $obj) { return @{} }
  if ($obj -is [hashtable]) { return $obj }
  $ht = @{}
  foreach ($p in $obj.PSObject.Properties) { $ht[$p.Name] = $p.Value }
  return $ht
}
$lastState = ConvertTo-Hashtable $lastState

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
  $__pnpHelper = Join-Path $PSScriptRoot 'pnp-session.ps1'
  if (Test-Path $__pnpHelper) { . $__pnpHelper }
  $connected = $false
  try { $null = Get-PnPWeb -ErrorAction Stop; $connected = $true } catch {}
  if (-not $connected) {
    if (Get-Command -Name Get-IdopPnPConnection -ErrorAction SilentlyContinue) {
      $fallbackAuth = 'Delegated'
      if ($env:IDOP_SP_AUTH_MODE -and $env:IDOP_SP_AUTH_MODE.Trim()) { $fallbackAuth = $env:IDOP_SP_AUTH_MODE }
      $mode = 'Delegated'
      if ($Auth -and ($Auth -ne 'DeviceLogin') -and ($Auth -ne 'Interactive')) { $mode = $fallbackAuth }
      $null = Get-IdopPnPConnection -Url $siteUrl -Auth $mode -SetDefault
    } else {
      Write-Host "[sp-diff] Session helper missing, using interactive auth..." -ForegroundColor Yellow
      Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
    }
  } else {
    Write-Log "[sp-diff] Using existing PnP context" Green
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

$skipFilesByName = @(
  # Deprecated or to-be-removed files
  'client_projects.json'
)

$jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json

# Build OnlyLists filter set if provided (CSV of List names)
$onlySet = $null
if ($OnlyLists -and $OnlyLists.Trim()) {
  $onlySet = @{}
  foreach ($n in ($OnlyLists -split ',' | ForEach-Object { $_.Trim() })) { if ($n) { $onlySet[$n] = $true } }
}

# If SinceGit provided, attempt to narrow files to changes since ref
if ($SinceGit -and $SinceGit.Trim()) {
  try {
    $gitChanged = & git --no-pager diff --name-only $SinceGit -- "$ListsPath" 2>$null
    if ($LASTEXITCODE -eq 0 -and $gitChanged) {
      $gitSet = @{}
      foreach ($p in ($gitChanged -split "`n")) {
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        if ($p -notlike "*.json") { continue }
        try { $abs = (Resolve-Path $p).Path } catch { $abs = $null }
        if ($abs) { $gitSet[$abs] = $true }
      }
      if ($gitSet.Count -gt 0) {
        $jsonFiles = $jsonFiles | Where-Object { $gitSet.ContainsKey($_.FullName) }
      }
    }
  } catch {}
}
foreach ($jsonFile in $jsonFiles) {
  if ($skipFilesByName -contains $jsonFile.Name) {
    Write-Log "Skipping (deprecated): $($jsonFile.FullName)" DarkYellow
    continue
  }
  # Parse JSON early for filters and hash
  $jsonRaw = Get-Content -Raw -Path $jsonFile.FullName
  $json = $jsonRaw | ConvertFrom-Json
  $listName = $json.ListName
  if (-not $listName -or [string]::IsNullOrWhiteSpace($listName)) { Write-Log "Skipping (no ListName): $($jsonFile.FullName)" DarkYellow; continue }
  if ($onlySet -and -not $onlySet.ContainsKey($listName)) { continue }
  $jsonHash = Get-JsonHash -path $jsonFile.FullName
  if ($Focus -ne 'all') {
    $prev = $null
    if ($lastState.ContainsKey($listName)) { $prev = $lastState[$listName] }
    if ($Focus -eq 'issues') {
      if (-not $prev -or $prev.result -eq 'ok') { continue }
    } elseif ($Focus -eq 'changed') {
      if ($prev -and $prev.hash -eq $jsonHash) { continue }
    }
  }
  $total++
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

  $spFields = Get-PnPField -List $list | ForEach-Object { [pscustomobject]@{ InternalName = $_.InternalName; Title=$_.Title; Type = (NormalizeType $_.TypeAsString) } }
  $spMap = @{}
  foreach ($f in $spFields) { $spMap[$f.InternalName] = $f }

  $listOk = $true
  foreach ($ef in $json.Columns) {
    # Try by internal name first; if not found, fallback to Title match
    $spf = $null
    if ($spMap.ContainsKey($ef.Name)) { $spf = $spMap[$ef.Name] }
    else {
      $spf = $spFields | Where-Object { $_.Title -eq $ef.Name } | Select-Object -First 1
    }
    # Special-case aliasing: 'Version' may be created with internal name 'DocVersion' to avoid reserved names
    if (-not $spf -and $ef.Name -eq 'Version') {
      $spf = $spFields | Where-Object { $_.InternalName -eq 'DocVersion' -or ($_.Title -like 'Version*') } | Select-Object -First 1
    }
    if (-not $spf) {
      Write-Log "  Missing field: $($ef.Name) (expected type: $($ef.Type))" Red
      $listOk = $false
      $fieldIssues++
      continue
    }

    $expectedSpType = ExpectedToSpType $ef
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
    $curr = @{ result = 'ok'; hash = $jsonHash; path = $jsonFile.FullName; ts = (Get-Date).ToString('s') }
  }
  else {
    Write-Log "  List has discrepancies." Yellow
    $curr = @{ result = 'issues'; hash = $jsonHash; path = $jsonFile.FullName; ts = (Get-Date).ToString('s') }
  }
  $lastState[$listName] = $curr
}

Write-Log "`n=== SUMMARY ===" Cyan
Write-Log "Total JSON lists: $total" White
Write-Log "Lists OK: $ok" Green
Write-Log "Missing lists: $missing" Red
Write-Log "Fields with issues: $fieldIssues" Yellow
Write-Log "Report saved: $ReportPath" Cyan

# Persist state for next focused run
try {
  if (-not (Test-Path -LiteralPath $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
  ($lastState | ConvertTo-Json -Depth 5) | Set-Content -Path $stateFile -Encoding UTF8
} catch {}
