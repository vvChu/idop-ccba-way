#requires -Version 7.0
[CmdletBinding(PositionalBinding=$false)]
param(
  [Parameter(HelpMessage='Your tenant primary domain or GUID, e.g. ibstbim.onmicrosoft.com')]
  [string]$Tenant = 'ibstbim.onmicrosoft.com',

  [Parameter(HelpMessage='Display name for the app registration')]
  [string]$ApplicationName = 'IDOP-CCBA Prod Automation',

  [Parameter(HelpMessage='Folder to write generated certificate files (PFX/CER)')]
  [string]$OutPath = $(Join-Path $env:USERPROFILE 'idop-ccba-prod-cert'),

  [Parameter(HelpMessage='SharePoint application permissions to request')]
  [string[]]$SharePointApplicationPermissions = @('Sites.FullControl.All'),

  [Parameter(HelpMessage='Additional Graph application permissions to request (optional)')]
  [string[]]$GraphApplicationPermissions,

  [Parameter(HelpMessage='Convenience: add Microsoft Graph TermStore.ReadWrite.All permission')]
  [switch]$IncludeGraphTermStore,

  [Parameter(HelpMessage='Prompt for a password to protect the generated PFX')]
  [switch]$PromptForCertPassword,

  [Parameter(HelpMessage='Import the generated PFX into CurrentUser\\My store and output the thumbprint')]
  [switch]$ImportToCertStore,

  [Parameter(HelpMessage='Use device code login for registration (recommended for non-UI contexts)')]
  [switch]$DeviceLogin,

  [Parameter(HelpMessage='Explicitly use interactive login for registration (opens a browser)')]
  [switch]$Interactive
)

$ErrorActionPreference = 'Stop'

function Write-Info([string]$m)  { Write-Host $m -ForegroundColor Cyan }
function Write-Ok([string]$m)    { Write-Host $m -ForegroundColor Green }
function Write-Warn([string]$m)  { Write-Host $m -ForegroundColor DarkYellow }
function Write-Err([string]$m)   { Write-Host $m -ForegroundColor Red }

try {
  if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Err "PnP.PowerShell is not installed. Install-Module PnP.PowerShell -Scope CurrentUser"
    exit 1
  }
  Import-Module PnP.PowerShell -ErrorAction Stop

  if (-not (Test-Path -LiteralPath $OutPath)) {
    New-Item -ItemType Directory -Path $OutPath | Out-Null
  }

  $spPerms = $SharePointApplicationPermissions
  $graphPerms = @()
  if ($GraphApplicationPermissions) { $graphPerms += $GraphApplicationPermissions }
  if ($IncludeGraphTermStore) { $graphPerms += 'TermStore.ReadWrite.All' }
  $graphPerms = $graphPerms | Where-Object { $_ -and $_.Trim() } | Select-Object -Unique

  $certPwd = $null
  if ($PromptForCertPassword) {
    $certPwd = Read-Host -AsSecureString 'Enter a password to protect the generated PFX'
  }

  Write-Info "[AppReg] Registering Entra ID App for App-Only access"
  Write-Info "          Tenant       : $Tenant"
  Write-Info "          App Name     : $ApplicationName"
  Write-Info "          OutPath      : $OutPath"
  Write-Info ("          SPO App Perms : {0}" -f ($spPerms -join ', '))
  if ($graphPerms.Count -gt 0) { Write-Info ("          Graph App Perms: {0}" -f ($graphPerms -join ', ')) }

  $commonParams = @{
    ApplicationName = $ApplicationName
    Tenant          = $Tenant
    OutPath         = $OutPath
    SharePointApplicationPermissions = $spPerms
  }
  if ($graphPerms.Count -gt 0) { $commonParams['GraphApplicationPermissions'] = $graphPerms }
  if ($certPwd) { $commonParams['CertificatePassword'] = $certPwd }

  if ($DeviceLogin -and $Interactive) { Write-Warn "Both -DeviceLogin and -Interactive provided; using DeviceLogin." }
  if ($DeviceLogin) { $commonParams['DeviceLogin'] = $true }
  elseif ($Interactive) { $commonParams['Interactive'] = $true }
  else { $commonParams['DeviceLogin'] = $true } # default

  $result = Register-PnPEntraIDApp @commonParams

  # Summarize results
  $appId = $null
  $pfxPath = $null
  $cerPath = $null
  $consentUrl = $null
  if ($result) {
    if ($result.PSObject.Properties.Name -contains 'AppId') { $appId = $result.AppId }
    if ($result.PSObject.Properties.Name -contains 'CertificatePfxPath') { $pfxPath = $result.CertificatePfxPath }
    if ($result.PSObject.Properties.Name -contains 'CertificateCerPath') { $cerPath = $result.CertificateCerPath }
    if ($result.PSObject.Properties.Name -contains 'ConsentUrl') { $consentUrl = $result.ConsentUrl }
  }

  Write-Ok   "[AppReg] App registered successfully."
  if ($appId)  { Write-Info "          App (Client) ID : $appId" }
  if ($pfxPath){ Write-Info "          PFX file        : $pfxPath" }
  if ($cerPath){ Write-Info "          CER file        : $cerPath" }
  if ($consentUrl) {
    Write-Warn "[Consent] Grant admin consent by opening this URL in a browser (Global Admin required):"
    Write-Host $consentUrl -ForegroundColor Yellow
  } else {
    Write-Warn "[Consent] Go to Entra ID > App registrations > $ApplicationName > API permissions and grant admin consent."
  }

  if ($ImportToCertStore -and $pfxPath) {
    try {
      if (-not $certPwd) {
        $certPwd = Read-Host -AsSecureString 'Enter the PFX password to import into CurrentUser\\My'
      }
      $imported = Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\CurrentUser\My -Password $certPwd
      if ($imported) {
        $thumb = $imported.Thumbprint
        Write-Ok "[Cert] Imported to CurrentUser\\My. Thumbprint: $thumb"
        Write-Info "      You can set env var IDOP_PNP_CERT_THUMBPRINT='$thumb' to use thumbprint-based auth."
      }
    } catch {
      Write-Err "[Cert] Failed to import PFX: $($_.Exception.Message)"
    }
  }

  # Print connection env var guidance (do not print passwords)
  if ($appId) {
    $pfxHint = if ($pfxPath) { $pfxPath } else { '<path-to-your.pfx>' }
    Write-Host ""; Write-Host "Next steps (AppOnly connection in this repo):" -ForegroundColor White
    Write-Host "Set-Item Env:IDOP_PNP_TENANT_ID '$Tenant'" -ForegroundColor DarkCyan
    Write-Host "Set-Item Env:IDOP_PNP_CLIENT_ID '$appId'" -ForegroundColor DarkCyan
    if ($ImportToCertStore) {
      Write-Host "Set-Item Env:IDOP_PNP_CERT_THUMBPRINT '<thumbprint-from-import>'" -ForegroundColor DarkCyan
    } else {
      Write-Host "Set-Item Env:IDOP_PNP_CERT_PATH '$pfxHint'" -ForegroundColor DarkCyan
      Write-Host "# Set-Item Env:IDOP_PNP_CERT_PASSWORD '<your-pfx-password>'  # avoid plain-text; prefer thumbprint import" -ForegroundColor DarkYellow
    }
    Write-Host "Then run: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File 'tools\\scripts\\run-prod-migration.ps1' -Environment Prod -Auth AppOnly" -ForegroundColor DarkCyan
  }
}
catch {
  Write-Err "[AppReg-FAIL] $($_.Exception.Message)"
  exit 1
}
