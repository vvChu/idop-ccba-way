param(
  [switch]$Verbose
)

$ErrorActionPreference = 'Stop'

function Write-Info($m){ Write-Host $m -ForegroundColor Cyan }
function Write-Warn($m){ Write-Host $m -ForegroundColor DarkYellow }
function Write-Ok($m){ Write-Host $m -ForegroundColor Green }
function Write-Err($m){ Write-Host $m -ForegroundColor Red }

$module = Get-Module -ListAvailable -Name PnP.PowerShell
if (-not $module) {
  Write-Err "PnP.PowerShell NOT installed. Install first:" 
  Write-Host "  Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -MinimumVersion 2.8.5.201"
  Write-Host "  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
  Write-Host "  Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force -AllowClobber"
  exit 1
}

Import-Module PnP.PowerShell -ErrorAction Stop
Write-Info ("PnP.PowerShell version: {0}" -f $module.Version)

$cmd = Get-Command -Name Connect-PnPOnline -ErrorAction Stop
$hasPnPMS = $cmd.Parameters.ContainsKey('PnPManagementShell')
Write-Info ("Connect-PnPOnline supports -PnPManagementShell: {0}" -f $hasPnPMS)

if ($hasPnPMS) {
  Write-Ok "You can enable cached auth with: Register-PnPManagementShellAccess"
} else {
  Write-Warn "Your PnP.PowerShell version does not expose -PnPManagementShell."
  Write-Warn "Consider updating the module to benefit from cached token flow."
}

Write-Info "One-time setup (run in pwsh):"
Write-Host "  Register-PnPManagementShellAccess"

Write-Ok "Auth capability check completed."
