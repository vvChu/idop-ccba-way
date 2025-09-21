param()

$ErrorActionPreference = 'Stop'

$minPwsh = [version]'7.4.6'
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion -lt $minPwsh) {
  Write-Host ("[bootstrap-pnp] PowerShell 7.4.6+ required. Current: {0} {1}." -f $PSVersionTable.PSEdition,$PSVersionTable.PSVersion) -ForegroundColor Red
  Write-Host "Install PowerShell 7 from https://github.com/PowerShell/PowerShell and rerun this script in pwsh." -ForegroundColor Yellow
  exit 1
}

Write-Host "[bootstrap-pnp] Ensuring NuGet provider..." -ForegroundColor Cyan
if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
  Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -MinimumVersion 2.8.5.201 | Out-Null
}

Write-Host "[bootstrap-pnp] Trusting PSGallery..." -ForegroundColor Cyan
try { Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction Stop } catch {}

$moduleName = 'PnP.PowerShell'
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
  Write-Host "[bootstrap-pnp] Installing $moduleName for current user..." -ForegroundColor Yellow
  Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -Repository PSGallery
}

Import-Module $moduleName -ErrorAction Stop
$m = Get-Module -ListAvailable -Name $moduleName | Sort-Object Version -Descending | Select-Object -First 1
Write-Host ("[bootstrap-pnp] Installed {0} v{1}" -f $m.Name,$m.Version) -ForegroundColor Green
exit 0
