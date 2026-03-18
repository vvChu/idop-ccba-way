param(
  [string]$ListsPath = "datamodel/sharepoint/lists",
  [switch]$DryRun,
  [string]$OnlyLists,
  [switch]$Fast,
  [switch]$Full
)

$ErrorActionPreference = 'Stop'

# Re-exec under PowerShell 7+ if currently running in Windows PowerShell 5.1
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "[apply-sp-lists] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
  $pwshCmd = $null
  try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
  if (-not $pwshCmd) {
    Write-Host "[apply-sp-lists] pwsh (PowerShell 7) not found. Please install PowerShell 7.4.6 or newer from https://github.com/PowerShell/PowerShell and re-run." -ForegroundColor Red
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

# Ensure required module exists (PnP.PowerShell)
$moduleName = 'PnP.PowerShell'
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
  Write-Host "[apply-sp-lists] Missing required module '$moduleName'." -ForegroundColor Red
  Write-Host "Install it for the current user, then re-run this task:" -ForegroundColor Yellow
  Write-Host "  Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -MinimumVersion 2.8.5.201" -ForegroundColor Yellow
  Write-Host "  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted" -ForegroundColor Yellow
  Write-Host "  Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force -AllowClobber" -ForegroundColor Yellow
  exit 4
}

# Import required modules
Import-Module PnP.PowerShell -ErrorAction Stop

# Load session helper to cache/reuse PnP connections (if present)
$__pnpHelper = Join-Path $PSScriptRoot 'pnp-session.ps1'
if (Test-Path $__pnpHelper) { . $__pnpHelper }

# Security: Validate inputs
if (-not (Test-Path $ListsPath)) {
  Write-Host "[ERROR] ListsPath does not exist: $ListsPath" -ForegroundColor Red
  exit 1
}

# Security: Use secure authentication (prefer certificate or managed identity over interactive)
$authMethod = $env:PNP_AUTH_METHOD  # Set to 'Certificate', 'ManagedIdentity', or 'Interactive'
if (-not $authMethod) { $authMethod = 'Interactive' }

# Default Entra App Registration Client ID for PnP interactive/device login (align with sp-diff)
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
if ($env:PNP_CLIENT_ID -and $env:PNP_CLIENT_ID.Trim()) { $clientId = $env:PNP_CLIENT_ID }

Write-Host "[apply-sp-lists] Applying SharePoint Lists from '$ListsPath' (DryRun=$DryRun, Fast=$Fast, OnlyLists=$OnlyLists)" -ForegroundColor Yellow
# TODO: Implement schema validation, diff, and apply logic using Microsoft Graph/PNP or SharePoint REST.
# - Validate JSON against schemas in datamodel/sharepoint/schemas
# - If -DryRun, show planned changes only
# - Otherwise, apply changes and create a backup/snapshot

# Environment config (update as needed)
$envs = @{
  Dev = @{
    SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-dev"
    TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    EnvironmentId = "8d5b1f25-82e2-eafe-8bab-76568795ee80"
    InstanceUrl = "https://org602e4787.crm5.dynamics.com/"
  }
  Test = @{
    SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-Test"
    TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    EnvironmentId = "30cf6c66-569a-e1c9-8a1b-8b1cd237629c"
    InstanceUrl = "https://org8b1a0d09.crm5.dynamics.com/"
  }
  Prod = @{
    SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-Prod"
    TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    EnvironmentId = "8524a85e-71ac-ef33-8829-c81b3267f78d"
    InstanceUrl = "https://org720c8362.crm5.dynamics.com/"
  }
}

# Select environment (default: Dev)
$SelectedEnv = $env:IDOP_ENVIRONMENT
if (-not $SelectedEnv) { $SelectedEnv = "Dev" }
if (-not $envs.ContainsKey($SelectedEnv)) {
  Write-Host "[ERROR] Unknown environment: $SelectedEnv. Valid: Dev, Test, Prod" -ForegroundColor Red
  exit 1
}
$envConfig = $envs[$SelectedEnv]
Write-Host "[env] Using environment: $SelectedEnv" -ForegroundColor Cyan
Write-Host "[env] SharePoint URL: $($envConfig.SharePointUrl)" -ForegroundColor Cyan
Write-Host "[env] Tenant ID: $($envConfig.TenantId)" -ForegroundColor Cyan
Write-Host "[env] Environment ID: $($envConfig.EnvironmentId)" -ForegroundColor Cyan
Write-Host "[env] Instance URL: $($envConfig.InstanceUrl)" -ForegroundColor Cyan

# Infer tenant domain from SharePoint URL if possible (e.g., ibstbim.onmicrosoft.com)
$tenantDomain = $null
try {
  $uri = [uri]$envConfig.SharePointUrl
  $siteHost = $uri.Host  # e.g., ibstbim.sharepoint.com
  $tenantBase = ($siteHost -split '\.')[0]
  if ($tenantBase) { $tenantDomain = "$tenantBase.onmicrosoft.com" }
} catch {}


# Validate all JSON files against schema (call ajv for each file individually)
# Resolve schema path relative to repo root so it works from any CWD
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$SchemaPath = Join-Path $repoRoot 'datamodel/sharepoint/schemas/sp-list.schema.json'
$skipFilesByName = @(
  # Deprecated list definition retained temporarily for Git clean-up
  'client_projects.json'
)
if (-not $Fast) {
  Write-Host "[validate] Checking all JSON lists against schema: $SchemaPath" -ForegroundColor Cyan
  $allValid = $true
  $onlySet = $null
  if ($OnlyLists -and $OnlyLists.Trim()) {
    $onlySet = @{}
    foreach ($n in ($OnlyLists -split ',' | ForEach-Object { $_.Trim() })) { if ($n) { $onlySet[$n] = $true } }
  }
  $jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
  foreach ($jsonFile in $jsonFiles) {
    if ($skipFilesByName -contains $jsonFile.Name) {
      Write-Host "Skipping (deprecated): $($jsonFile.FullName)"
      continue
    }
    if ($onlySet) {
      try {
        $jsonObj = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json
      } catch { continue }
      $ln = $jsonObj.ListName
      if (-not $ln -or -not $onlySet.ContainsKey($ln)) { continue }
    }
    $ajvCmd = "ajv validate -s `"$SchemaPath`" -d `"$($jsonFile.FullName)`""
    Write-Host "Validating: $($jsonFile.FullName)"
    Invoke-Expression $ajvCmd
    if ($LASTEXITCODE -ne 0) {
      Write-Host "[ERROR] Schema validation failed for $($jsonFile.FullName)" -ForegroundColor Red
      $allValid = $false
    }
  }
  if (-not $allValid) {
    exit 2
  }
  Write-Host "[validate] All JSON lists are valid." -ForegroundColor Green
} else {
  Write-Host "[validate] Fast mode enabled: skipping AJV schema validation (use without caution on trusted changes only)." -ForegroundColor Yellow
}

# In DryRun mode, if not Full, stop after validation. If Full+DryRun, perform plan-only preview (no changes).
if ($DryRun -and -not $Full) {
  Write-Host "[DryRun] Validation complete. Use 'SP: diff lists' to preview drifts. Skipping apply." -ForegroundColor Yellow
  exit 0
}

# Apply targeted changes (CDEDocuments creation; Opportunities fields; remove legacy ClientProject)
if ($Full) { Write-Host "[apply] Full provisioning mode: ensuring all lists/fields from JSON..." -ForegroundColor Green }
else { Write-Host "[apply] Applying targeted schema changes to SharePoint..." -ForegroundColor Green }

# Connect to SharePoint (prefer session helper if available) unless planning only (Full+DryRun)
$__planOnly = ($Full -and $DryRun)
if (-not $__planOnly) {
  try {
    if (Get-Command -Name Get-IdopPnPConnection -ErrorAction SilentlyContinue) {
      if ($authMethod -eq 'Certificate') {
        $certPath = $env:PNP_CERT_PATH
        $certPassword = $env:PNP_CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
        Connect-PnPOnline -Url $envConfig.SharePointUrl -CertificatePath $certPath -CertificatePassword $certPassword -Tenant $envConfig.TenantId
      } elseif ($authMethod -eq 'ManagedIdentity') {
        Connect-PnPOnline -Url $envConfig.SharePointUrl -ManagedIdentity
      } else {
        $mode = if ($env:IDOP_SP_AUTH_MODE) { $env:IDOP_SP_AUTH_MODE } else { 'Delegated' }
        $null = Get-IdopPnPConnection -Url $envConfig.SharePointUrl -Auth $mode -SetDefault
      }
    } else {
      switch ($authMethod) {
        'Certificate' {
          $certPath = $env:PNP_CERT_PATH
          $certPassword = $env:PNP_CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
          Connect-PnPOnline -Url $envConfig.SharePointUrl -CertificatePath $certPath -CertificatePassword $certPassword -Tenant $envConfig.TenantId
        }
        'ManagedIdentity' { Connect-PnPOnline -Url $envConfig.SharePointUrl -ManagedIdentity }
        default {
          if ($tenantDomain) { Connect-PnPOnline -Url $envConfig.SharePointUrl -Interactive -ClientId $clientId -Tenant $tenantDomain }
          else { Connect-PnPOnline -Url $envConfig.SharePointUrl -Interactive -ClientId $clientId }
        }
      }
    }
    Write-Host "[apply] Connected to SharePoint using $authMethod" -ForegroundColor Green
  } catch {
    Write-Host "[ERROR] Connect failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 3
  }
} else { Write-Host "[plan] Skipping SharePoint connection (Full+DryRun plan-only)" -ForegroundColor Yellow }

function Ensure-List {
  param([string]$Title)
  $existingList = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
  if (-not $list) {
    Write-Host "[apply] Creating list: $Title" -ForegroundColor Yellow
    New-PnPList -Title $Title -Template GenericList | Out-Null
    $list = Get-PnPList -Identity $Title
    if ($list) { Write-Host "[apply] Created list '$($list.Title)' at '$($list.RootFolder.ServerRelativeUrl)'" -ForegroundColor DarkGray }
  }
  return $list
}

function Test-FieldExists {
  param([string]$ListName,[string]$FieldName)
  $f = Get-PnPField -List $ListName -Identity $FieldName -ErrorAction SilentlyContinue
  return [bool]$f
}

function Add-FieldXml {
  param([string]$ListName,[string]$FieldXml)
  Write-Host "[apply] + Field on ${ListName}: ${FieldXml}" -ForegroundColor Yellow
  try {
    Add-PnPFieldFromXml -List $ListName -FieldXml $FieldXml -ErrorAction Stop | Out-Null
  } catch {
    Write-Host "[apply] (error) Add-PnPFieldFromXml failed on ${ListName}: $($_.Exception.Message)" -ForegroundColor Red
    throw
  }
  # Verify field exists; try to parse Name from XML
  try {
    if ($FieldXml -match "Name='([^']+)'") { $intName = $Matches[1] } else { $intName = $null }
    $field = $null
    if ($intName) { $field = Get-PnPField -List $ListName -Identity $intName -ErrorAction SilentlyContinue }
    if (-not $field) {
      # Fallback: try match by DisplayName/Title
      $displayName = $null
      if ($FieldXml -match "DisplayName='([^']+)'") { $displayName = $Matches[1] }
      if ($displayName) {
        $field = Get-PnPField -List $ListName -ErrorAction SilentlyContinue | Where-Object { $_.Title -eq $displayName } | Select-Object -First 1
      }
    }
    if ($field) {
      if ($intName -and $field.InternalName -ne $intName) {
        Write-Host "[apply] (note) Field created with internal name '${field.InternalName}' (requested '${intName}') on list '${ListName}'. Consider updating JSON schema to match." -ForegroundColor DarkYellow
      }
    } else {
      Write-Host "[apply] (warn) Unable to verify field existence on ${ListName}." -ForegroundColor DarkYellow
    }
  } catch {
    Write-Host "[apply] (warn) Post-add verification failed on ${ListName}: $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
}

function Ensure-TextField {
  param([string]$ListName,[string]$Name,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Text | Out-Null
  }
}
function Ensure-NoteField {
  param([string]$ListName,[string]$Name,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Note | Out-Null
  }
}
function Ensure-NumberField {
  param([string]$ListName,[string]$Name,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Number | Out-Null
  }
}
function Ensure-YesNoField {
  param([string]$ListName,[string]$Name,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
  if (-not $existing) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Boolean | Out-Null
  } elseif ($existing.TypeAsString -ne 'Boolean') {
    Write-Host "[apply] Recreating ${ListName}/${Name} as Yes/No (existing type: $($existing.TypeAsString))" -ForegroundColor Yellow
    try { Remove-PnPField -List $ListName -Identity $InternalName -Force } catch {}
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Boolean | Out-Null
  }
}
function Ensure-DateTimeField {
  param([string]$ListName,[string]$Name,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type DateTime | Out-Null
  }
}
function Ensure-UrlField {
  param([string]$ListName,[string]$Name,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type URL | Out-Null
  }
}
function Ensure-UserField {
  param([string]$ListName,[string]$Name,[switch]$Multi,[string]$SelectionMode='PeopleAndGroups',[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    # Use explicit FieldXml. SharePoint uses Type='UserMulti' for multi-value person fields.
    if (-not $SelectionMode -or [string]::IsNullOrWhiteSpace($SelectionMode)) { $SelectionMode = 'PeopleAndGroups' }
    $t = if ($Multi) { 'UserMulti' } else { 'User' }
    $xml = "<Field Type='${t}' DisplayName='${Name}' Name='${InternalName}' StaticName='${InternalName}' UserSelectionMode='${SelectionMode}' />"
    Add-FieldXml -ListName $ListName -FieldXml $xml
  }
}
function Ensure-ChoiceField {
  param([string]$ListName,[string]$Name,[string[]]$Choices,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
  if (-not $existing) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Choice | Out-Null
  } elseif ($existing.TypeAsString -ne 'Choice') {
    Write-Host "[apply] Recreating ${ListName}/${Name} as Choice (existing type: $($existing.TypeAsString))" -ForegroundColor Yellow
    try { Remove-PnPField -List $ListName -Identity $InternalName -Force } catch {}
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Choice | Out-Null
  }
  if ($Choices) {
    try { Set-PnPField -List $ListName -Identity $InternalName -Values @{ Choices = $Choices } } catch {
      Write-Host "[apply] (warn) Failed to update choices on ${ListName}/${Name}: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
  }
}
function Ensure-MultiChoiceField {
  param([string]$ListName,[string]$Name,[string[]]$Choices,[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
  if (-not $existing) {
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type MultiChoice | Out-Null
  } elseif ($existing.TypeAsString -ne 'MultiChoice') {
    Write-Host "[apply] Recreating ${ListName}/${Name} as MultiChoice (existing type: $($existing.TypeAsString))" -ForegroundColor Yellow
    try { Remove-PnPField -List $ListName -Identity $InternalName -Force } catch {}
    Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type MultiChoice | Out-Null
  }
  if ($Choices) {
    try { Set-PnPField -List $ListName -Identity $InternalName -Values @{ Choices = $Choices } } catch {
      Write-Host "[apply] (warn) Failed to update multichoices on ${ListName}/${Name}: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
  }
}
function Ensure-LookupField {
  param([string]$ListName,[string]$Name,[string]$TargetList,[string]$ShowField='ID',[string]$InternalName)
  if (-not $InternalName) { $InternalName = $Name }
  if (-not (Test-FieldExists $ListName $InternalName)) {
    $tList = Get-PnPList -Identity $TargetList
    if (-not $tList) { throw "Target lookup list not found: $TargetList" }
    try {
      # Preferred approach (newer PnP): direct parameters
      Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Lookup -LookupList $TargetList -LookupField $ShowField -ErrorAction Stop | Out-Null
    } catch {
      # Fallback for older PnP: use XML with GUID (no enforced relationship to avoid index requirement)
      try {
        $targetId = $tList.Id
        $xml = "<Field Type='Lookup' DisplayName='${Name}' Name='${InternalName}' StaticName='${InternalName}' List='{$targetId}' ShowField='${ShowField}' />"
        Add-FieldXml -ListName $ListName -FieldXml $xml
      } catch {
        Write-Host "[apply] (error) Failed to add lookup field ${ListName}/${Name}: $($_.Exception.Message)" -ForegroundColor Red
        throw
      }
    }
  }
}

function Ensure-TaxonomyField {
  param([string]$ListName,[string]$Name,[string]$TermGroup,[string]$TermSet,[switch]$Multi)
  if (-not (Test-FieldExists $ListName $Name)) {
    $path = "$TermGroup|$TermSet"
    try {
      # Prefer TermSetPath for clarity
      Add-PnPTaxonomyField -List $ListName -DisplayName $Name -InternalName $Name -TermSetPath $path -MultiValue:$($Multi.IsPresent) | Out-Null
    } catch {
      # Fallback to separate params in case of older module
      try { Add-PnPTaxonomyField -List $ListName -DisplayName $Name -InternalName $Name -Group $TermGroup -TermSet $TermSet -MultiValue:$($Multi.IsPresent) | Out-Null } catch {
        Write-Host "[apply] (warn) Failed to add taxonomy field ${ListName}/${Name}: $($_.Exception.Message)" -ForegroundColor DarkYellow
      }
    }
  }
}

if (-not $Full -and (-not $OnlyLists -or $OnlyLists -match '(?i)\bCDEDocuments\b')) {
try {
  Ensure-List -Title 'CDEDocuments' | Out-Null
  Ensure-LookupField -ListName 'CDEDocuments' -Name 'Project' -TargetList 'Projects' -ShowField 'ID'
  Ensure-TextField -ListName 'CDEDocuments' -Name 'ProjectCode'
  Ensure-TextField -ListName 'CDEDocuments' -Name 'DocumentCode'
  # Avoid reserved internal name 'Version' by using internal 'DocVersion' with display 'Version'
  Ensure-TextField -ListName 'CDEDocuments' -Name 'Version' -InternalName 'DocVersion'
  Ensure-UrlField  -ListName 'CDEDocuments' -Name 'FileUrl'
  Ensure-LookupField -ListName 'CDEDocuments' -Name 'Submission' -TargetList 'Submissions' -ShowField 'ID'
  Ensure-DateTimeField -ListName 'CDEDocuments' -Name 'RetentionUntil'
  Ensure-UserField -ListName 'CDEDocuments' -Name 'Owner'
  Write-Host "[apply] Ensured CDEDocuments list and fields." -ForegroundColor Green
} catch {
  Write-Host "[apply] (warn) Failed ensuring CDEDocuments: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

  # Ensure CDEDocuments taxonomy fields
  try {
    Ensure-TaxonomyField -ListName 'CDEDocuments' -Name 'DocumentType' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_LoaiTaiLieu'
    Ensure-TaxonomyField -ListName 'CDEDocuments' -Name 'Discipline' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_ChucDanhXayDung'
    Ensure-TaxonomyField -ListName 'CDEDocuments' -Name 'ServiceType' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_LoaiHinhDichVu'
    Ensure-TaxonomyField -ListName 'CDEDocuments' -Name 'Status' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_TrangThaiChung'
  } catch {
    Write-Host "[apply] (warn) Failed ensuring CDEDocuments taxonomy: $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
}

if (-not $Full -and (-not $OnlyLists -or $OnlyLists -match '(?i)\bPotentialProjects\b')) {
try {
  Ensure-List -Title 'PotentialProjects' | Out-Null
  Ensure-LookupField -ListName 'PotentialProjects' -Name 'Customer' -TargetList 'Customers' -ShowField 'ID'
  Ensure-LookupField -ListName 'PotentialProjects' -Name 'Contact' -TargetList 'Contacts' -ShowField 'ID'
  Ensure-NumberField -ListName 'PotentialProjects' -Name 'ExpectedContractValue'
  Ensure-ChoiceField -ListName 'PotentialProjects' -Name 'Stage' -Choices @('Identified','Qualified','On Hold','Converted','Dropped')
  # Additional fields per schema (taxonomy placeholders will be handled later via term store script)
  # ServiceType, Industry, ProjectType, Priority (taxonomy) are skipped here on purpose
  Ensure-DateTimeField -ListName 'PotentialProjects' -Name 'EstimatedStart'
  Ensure-DateTimeField -ListName 'PotentialProjects' -Name 'EstimatedEnd'
  Ensure-UserField -ListName 'PotentialProjects' -Name 'PMOOwner'
  Write-Host "[apply] Ensured PotentialProjects list and core fields." -ForegroundColor Green
} catch {
  Write-Host "[apply] (warn) Failed ensuring PotentialProjects: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

  # Ensure PotentialProjects taxonomy fields
  try {
    Ensure-TaxonomyField -ListName 'PotentialProjects' -Name 'ServiceType' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_LoaiHinhDichVu'
    Ensure-TaxonomyField -ListName 'PotentialProjects' -Name 'Industry' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_NganhLinhVuc'
    Ensure-TaxonomyField -ListName 'PotentialProjects' -Name 'ProjectType' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_LoaiCongTrinh'
    Ensure-TaxonomyField -ListName 'PotentialProjects' -Name 'Priority' -TermGroup 'CCBA Taxonomy' -TermSet 'CCBA_MucDoUuTien'
  } catch {
    Write-Host "[apply] (warn) Failed ensuring PotentialProjects taxonomy: $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
}

if (-not $Full -and (-not $OnlyLists -or $OnlyLists -match '(?i)\bOpportunities\b')) {
try {
  $null = Get-PnPList -Identity 'Opportunities' -ErrorAction Stop
  Ensure-LookupField -ListName 'Opportunities' -Name 'PotentialProject' -TargetList 'PotentialProjects' -ShowField 'ID'
  Ensure-TextField -ListName 'Opportunities' -Name 'BiddingFolderDriveItemId'
  Ensure-UrlField  -ListName 'Opportunities' -Name 'BiddingFolderUrl'
  Ensure-TextField -ListName 'Opportunities' -Name 'BiddingFolderPath'
  Ensure-ChoiceField -ListName 'Opportunities' -Name 'BiddingFolderState' -Choices @('Not Created','Creating','Created','Failed')
  Ensure-ChoiceField -ListName 'Opportunities' -Name 'BiddingFolderPhase' -Choices @('Draft','Confirmed','Archived')
  Ensure-TextField -ListName 'Opportunities' -Name 'BiddingCode'
  Ensure-ChoiceField -ListName 'Opportunities' -Name 'ParticipationDecision' -Choices @('Unknown','Yes','No')
  Ensure-DateTimeField -ListName 'Opportunities' -Name 'DecisionDate'
  Ensure-NoteField -ListName 'Opportunities' -Name 'DecisionNote'
  Ensure-UrlField  -ListName 'Opportunities' -Name 'DecisionEmailLink'
  # Schema expects multi User for BidTeam
  $existingBidTeam = Get-PnPField -List 'Opportunities' -Identity 'BidTeam' -ErrorAction SilentlyContinue
  if (-not $existingBidTeam) {
    Ensure-UserField -ListName 'Opportunities' -Name 'BidTeam' -Multi -SelectionMode 'PeopleAndGroups'
  } else {
    if ($existingBidTeam.TypeAsString -ne 'UserMulti') {
      Write-Host "[apply] Recreating BidTeam as multi-selection User (existing type: $($existingBidTeam.TypeAsString))" -ForegroundColor Yellow
      try { Remove-PnPField -List 'Opportunities' -Identity 'BidTeam' -Force } catch {}
      Ensure-UserField -ListName 'Opportunities' -Name 'BidTeam' -Multi -SelectionMode 'PeopleAndGroups'
    }
  }
  Ensure-ChoiceField -ListName 'Opportunities' -Name 'Stage' -Choices @('New','Qualification Review','Proposal/HSDX','Closed - Won','Closed - Lost','Closed - Not Pursued')
  Write-Host "[apply] Ensured Opportunities fields and Stage choices." -ForegroundColor Green
} catch {
  Write-Host "[apply] (warn) Failed ensuring Opportunities: $($_.Exception.Message)" -ForegroundColor DarkYellow
}
}

# Remove legacy ClientProject fields if present
foreach ($ln in @('Opportunities','PotentialProjects','Projects')) {
  if ($DryRun) {
    Write-Host "[plan] Would remove legacy field $ln/ClientProject if present" -ForegroundColor DarkCyan
  } else {
    try {
      $cp = Get-PnPField -List $ln -Identity 'ClientProject' -ErrorAction SilentlyContinue
      if ($cp) {
        Write-Host "[apply] Removing legacy field $ln/ClientProject" -ForegroundColor Yellow
        Remove-PnPField -List $ln -Identity 'ClientProject' -Force
      }
    } catch {
      Write-Host "[apply] (info) Legacy field check on ${ln}: $($_.Exception.Message)" -ForegroundColor DarkGray
    }
  }
}

if (-not $Full) { Write-Host "[apply] Targeted schema changes applied successfully." -ForegroundColor Green }

# Full mode: iterate JSON and provision
if ($Full) {
  $plan = @()
  function Add-Plan { param([string]$Message) $script:plan += $Message; Write-Host $Message -ForegroundColor DarkCyan }
  # Build filter set if OnlyLists specified
  $onlySet = $null
  if ($OnlyLists -and $OnlyLists.Trim()) {
    $onlySet = @{}
    foreach ($n in ($OnlyLists -split ',' | ForEach-Object { $_.Trim() })) { if ($n) { $onlySet[$n] = $true } }
  }
  $jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
  foreach ($jf in $jsonFiles) {
    if ($skipFilesByName -contains $jf.Name) { continue }
    $def = $null
    try { $def = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json -ErrorAction Stop } catch { continue }
    $ln = $null
    if ($def -is [System.Collections.IDictionary]) { if ($def.Contains('ListName')) { $ln = $def['ListName'] } }
    else { if ($def.PSObject.Properties['ListName']) { $ln = $def.ListName } }
    if (-not $ln) { continue }
    if ($onlySet -and -not $onlySet.ContainsKey($ln)) { continue }
    if ($DryRun) {
      Add-Plan "[plan] Would ensure list: ${ln}"
    } else {
      try {
        $existingList = Get-PnPList -Identity $ln -ErrorAction SilentlyContinue
        if (-not $existingList) { Ensure-List -Title $ln | Out-Null }
      } catch { Write-Host "[apply] (warn) Ensure list failed for ${ln}: $($_.Exception.Message)" -ForegroundColor DarkYellow }
    }

    # Columns
    $cols = @()
    if ($null -ne $def.Columns) {
      if ($def.Columns -is [System.Collections.IEnumerable] -and -not ($def.Columns -is [string])) { $cols = @($def.Columns) }
    }
    foreach ($col in $cols) {
      # Extract fields safely
      $name=$null;$type=$null;$choices=$null;$lookup=$null;$termset=$null;$allowMultiple=$false;$userMode='PeopleAndGroups';$internal=$null
      if ($col -is [System.Collections.IDictionary]) {
        if ($col.Contains('Name')) { $name = $col['Name'] }
        if ($col.Contains('Type')) { $type = $col['Type'] }
        if ($col.Contains('Choices')) { $choices = $col['Choices'] }
        if ($col.Contains('Lookup')) { $lookup = $col['Lookup'] }
        if ($col.Contains('TermSet')) { $termset = $col['TermSet'] }
        if ($col.Contains('AllowMultiple')) { $allowMultiple = [bool]$col['AllowMultiple'] }
        if ($col.Contains('UserSelectionMode')) { $userMode = $col['UserSelectionMode'] }
        if ($col.Contains('InternalName')) { $internal = $col['InternalName'] }
      } else {
        $p = $col.PSObject
        if ($p.Properties['Name']) { $name = $col.Name }
        if ($p.Properties['Type']) { $type = $col.Type }
        if ($p.Properties['Choices']) { $choices = $col.Choices }
        if ($p.Properties['Lookup']) { $lookup = $col.Lookup }
        if ($p.Properties['TermSet']) { $termset = $col.TermSet }
        if ($p.Properties['AllowMultiple']) { $allowMultiple = [bool]$col.AllowMultiple }
        if ($p.Properties['UserSelectionMode']) { $userMode = $col.UserSelectionMode }
        if ($p.Properties['InternalName']) { $internal = $col.InternalName }
      }
      if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($type)) { continue }
      $it = $type.ToString()
      switch -Regex ($it) {
        '^(Text|SingleLine)$' { if ($DryRun) { Add-Plan "[plan] Would ensure Text ${ln}/${name}" } else { Ensure-TextField -ListName $ln -Name $name -InternalName $internal } }
        '^Note$' { if ($DryRun) { Add-Plan "[plan] Would ensure Note ${ln}/${name}" } else { Ensure-NoteField -ListName $ln -Name $name -InternalName $internal } }
        '^Number$' { if ($DryRun) { Add-Plan "[plan] Would ensure Number ${ln}/${name}" } else { Ensure-NumberField -ListName $ln -Name $name -InternalName $internal } }
        '^(Date|DateTime)$' { if ($DryRun) { Add-Plan "[plan] Would ensure DateTime ${ln}/${name}" } else { Ensure-DateTimeField -ListName $ln -Name $name -InternalName $internal } }
        '^(URL|Hyperlink)$' { if ($DryRun) { Add-Plan "[plan] Would ensure Url ${ln}/${name}" } else { Ensure-UrlField -ListName $ln -Name $name -InternalName $internal } }
        '^(YesNo|Boolean)$' { if ($DryRun) { Add-Plan "[plan] Would ensure YesNo ${ln}/${name}" } else { Ensure-YesNoField -ListName $ln -Name $name -InternalName $internal } }
        '^User$' {
          if ($DryRun) {
            $mm = if ($allowMultiple) { ' (Multi)' } else { '' }
            Add-Plan "[plan] Would ensure User${mm} ${ln}/${name} (SelectionMode=${userMode})"
          } else {
            if ($allowMultiple) { Ensure-UserField -ListName $ln -Name $name -Multi -SelectionMode $userMode -InternalName $internal }
            else { Ensure-UserField -ListName $ln -Name $name -SelectionMode $userMode -InternalName $internal }
          }
        }
        '^Choice$' { if ($DryRun) { Add-Plan "[plan] Would ensure Choice ${ln}/${name} (Choices=$($choices -join ', '))" } else { Ensure-ChoiceField -ListName $ln -Name $name -Choices $choices -InternalName $internal } }
        '^MultiChoice$' { if ($DryRun) { Add-Plan "[plan] Would ensure MultiChoice ${ln}/${name} (Choices=$($choices -join ', '))" } else { Ensure-MultiChoiceField -ListName $ln -Name $name -Choices $choices -InternalName $internal } }
        '^Lookup$' {
          $tlist=$null;$sfield='ID'
          if ($lookup) {
            if ($lookup -is [System.Collections.IDictionary]) {
              if ($lookup.Contains('List')) { $tlist = $lookup['List'] }
              if ($lookup.Contains('Field')) { $sfield = $lookup['Field'] }
            } else {
              $lp = $lookup.PSObject; if ($lp.Properties['List']) { $tlist = $lookup.List }; if ($lp.Properties['Field']) { $sfield = $lookup.Field }
            }
          }
          if ($tlist) {
            if ($DryRun) { Add-Plan "[plan] Would ensure Lookup ${ln}/${name} -> ${tlist}.${sfield}" }
            else { try { Ensure-LookupField -ListName $ln -Name $name -TargetList $tlist -ShowField $sfield -InternalName $internal } catch { Write-Host "[apply] (warn) Lookup ensure failed ${ln}/${name}: $($_.Exception.Message)" -ForegroundColor DarkYellow } }
          }
        }
        '^(ManagedMetadata|Taxonomy)$' {
          $grp=$null;$ts=$null
          if ($termset) {
            if ($termset -is [System.Collections.IDictionary]) {
              if ($termset.Contains('Group')) { $grp = $termset['Group'] }
              if ($termset.Contains('Name')) { $ts = $termset['Name'] }
            } else { $tp = $termset.PSObject; if ($tp.Properties['Group']) { $grp = $termset.Group }; if ($tp.Properties['Name']) { $ts = $termset.Name } }
          }
          if ($grp -and $ts) {
            if ($DryRun) { Add-Plan "[plan] Would ensure Taxonomy ${ln}/${name} -> ${grp}|${ts} (Multi=$allowMultiple)" }
            else { Ensure-TaxonomyField -ListName $ln -Name $name -TermGroup $grp -TermSet $ts -Multi:($allowMultiple) }
          }
        }
        default { Write-Host "[apply] (info) Unsupported column type '${it}' for ${ln}/${name}; skipping." -ForegroundColor DarkGray }
      }
    }
  }
  # Retry missing lookup fields after all lists exist
  foreach ($jf in $jsonFiles) {
    if ($skipFilesByName -contains $jf.Name) { continue }
    $def = $null
    try { $def = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json -ErrorAction Stop } catch { continue }
    $ln = $null
    if ($def -is [System.Collections.IDictionary]) { if ($def.Contains('ListName')) { $ln = $def['ListName'] } }
    else { if ($def.PSObject.Properties['ListName']) { $ln = $def.ListName } }
    if (-not $ln) { continue }
    if ($onlySet -and -not $onlySet.ContainsKey($ln)) { continue }
    $cols = @()
    if ($null -ne $def.Columns) {
      if ($def.Columns -is [System.Collections.IEnumerable] -and -not ($def.Columns -is [string])) { $cols = @($def.Columns) }
    }
    foreach ($col in $cols) {
      $name=$null;$type=$null;$lookup=$null;$internal=$null
      if ($col -is [System.Collections.IDictionary]) {
        if ($col.Contains('Name')) { $name = $col['Name'] }
        if ($col.Contains('Type')) { $type = $col['Type'] }
        if ($col.Contains('Lookup')) { $lookup = $col['Lookup'] }
        if ($col.Contains('InternalName')) { $internal = $col['InternalName'] }
      } else { $p=$col.PSObject; if ($p.Properties['Name']) { $name=$col.Name }; if ($p.Properties['Type']) { $type=$col.Type }; if ($p.Properties['Lookup']) { $lookup=$col.Lookup }; if ($p.Properties['InternalName']) { $internal=$col.InternalName } }
      if ($type -ne 'Lookup' -or -not $lookup) { continue }
      $tlist=$null;$sfield='ID'
      if ($lookup -is [System.Collections.IDictionary]) { if ($lookup.Contains('List')) { $tlist=$lookup['List'] }; if ($lookup.Contains('Field')) { $sfield=$lookup['Field'] } }
      else { $lp=$lookup.PSObject; if ($lp.Properties['List']) { $tlist=$lookup.List }; if ($lp.Properties['Field']) { $sfield=$lookup.Field } }
      if ($tlist) {
        if ($DryRun) {
          Add-Plan "[plan] Would retry Lookup ${ln}/${name} -> ${tlist}.${sfield}"
        } else {
          $resolvedInternal = if ($internal) { $internal } else { $name }
          if (-not (Test-FieldExists $ln $resolvedInternal)) {
            Write-Host "[apply] Retry lookup ensure ${ln}/${name} -> ${tlist}.${sfield}" -ForegroundColor DarkCyan
            try { Ensure-LookupField -ListName $ln -Name $name -TargetList $tlist -ShowField $sfield -InternalName $internal } catch {}
          }
        }
      }
    }
  }
  if ($DryRun) {
    Write-Host "[plan] Full provisioning preview completed. Items planned: $($plan.Count)" -ForegroundColor Yellow
  } else {
    Write-Host "[apply] Full provisioning completed." -ForegroundColor Green
  }
}

# Optionally update field DisplayName (Vietnamese titles) from JSON if present (requires active PnP connection)
function Update-DisplayNamesFromJson {
  param([string]$ListsPath,[hashtable]$OnlySet)
  try {
    $jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
    foreach ($jf in $jsonFiles) {
      try { $obj = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json } catch { continue }
      $ln = $null
      # Safely read ListName from PSCustomObject or Hashtable
      if ($obj -is [System.Collections.IDictionary]) {
        if ($obj.Contains('ListName')) { $ln = $obj['ListName'] }
      } else {
        $pso = $obj.PSObject
        if ($pso -and $pso.Properties['ListName']) { $ln = $obj.ListName }
      }
      if (-not $ln) { continue }
      if ($OnlySet -and -not $OnlySet.ContainsKey($ln)) { continue }
      $list = Get-PnPList -Identity $ln -ErrorAction SilentlyContinue
      if (-not $list) { continue }
      $cols = @()
      if ($null -ne $obj.Columns) {
        if ($obj.Columns -is [System.Collections.IEnumerable] -and -not ($obj.Columns -is [string])) { $cols = @($obj.Columns) } else { $cols = @() }
      }
      foreach ($col in $cols) {
        # Safely extract properties regardless of PSCustomObject vs Hashtable
        $dn = $null; $internal = $null
        if ($col -is [System.Collections.IDictionary]) {
          if ($col.Contains('DisplayName')) { $dn = $col['DisplayName'] }
          if ($col.Contains('Name')) { $internal = $col['Name'] }
        } else {
          $pso = $col.PSObject
          if ($pso -and $pso.Properties['DisplayName']) { $dn = $col.DisplayName }
          if ($pso -and $pso.Properties['Name']) { $internal = $col.Name }
        }
        if ([string]::IsNullOrWhiteSpace($dn) -or [string]::IsNullOrWhiteSpace($internal)) { continue }
        try {
          Set-PnPField -List $ln -Identity $internal -Values @{ Title = $dn } | Out-Null
          Write-Host "[apply] Set display name ${ln}/${internal} -> '${dn}'" -ForegroundColor DarkGreen
        } catch {
          Write-Host "[apply] (warn) Failed to set display for ${ln}/${internal}: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
      }
    }
  } catch {
    Write-Host "[apply] (warn) Display name update loop failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
  }
}

# Build OnlySet from parameter for display name updates
$__onlySet = $null
if ($OnlyLists -and $OnlyLists.Trim()) {
  $__onlySet = @{}
  foreach ($n in ($OnlyLists -split ',' | ForEach-Object { $_.Trim() })) { if ($n) { $__onlySet[$n] = $true } }
}

if (-not $DryRun) { Update-DisplayNamesFromJson -ListsPath $ListsPath -OnlySet $__onlySet } else { Write-Host "[plan] Skipping display name updates (DryRun)" -ForegroundColor Yellow }

# Note: Keep connection open to reuse within this PowerShell session (no Disconnect-PnPOnline)
