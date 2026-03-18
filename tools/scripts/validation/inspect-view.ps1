param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [Parameter(Mandatory=$true)]
  [string]$ListTitle,
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'

$moduleName = 'PnP.PowerShell'
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
  Write-Host "[inspect-view] Missing required module '$moduleName'." -ForegroundColor Red
  exit 4
}
Import-Module $moduleName -ErrorAction Stop

# Import shared modules
$authModule = Join-Path $PSScriptRoot '../modules/PnPHelpers.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }

# Get environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Host "[inspect-view] 🔗 Connecting to $siteUrl" -ForegroundColor Yellow
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $config.ClientId
} else {
  Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $config.ClientId
}
Write-Host "[inspect-view] ✅ Connected" -ForegroundColor Green

try {
  $default = Get-PnPView -List $ListTitle | Where-Object { $_.DefaultView -eq $true }
  if (-not $default) {
    Write-Host "[inspect-view] ❌ No default view found for list '$ListTitle'" -ForegroundColor Red
    exit 2
  }
  $vd = Get-PnPView -List $ListTitle -Identity $default.Id -Includes ViewFields,Title,DefaultView
  Write-Host ("[inspect-view] 📝 Default view: " + $vd.Title) -ForegroundColor Cyan
  Write-Host "[inspect-view] 📄 Fields in default view:" -ForegroundColor Cyan
  $vd.ViewFields | ForEach-Object { Write-Host ("  - " + $_) }

  # Quick checks for common expectations
  $hasLegacyStatus = $vd.ViewFields -contains 'Status_x0020__x0028_Term_x0029_'
  $hasStatusMM = $vd.ViewFields -contains 'Status_MM'
  if ($hasLegacyStatus) { Write-Host "[inspect-view] ⚠️ Legacy 'Status (Term)' appears in default view." -ForegroundColor Yellow }
  if ($hasStatusMM) { Write-Host "[inspect-view] ✅ 'Status_MM' appears in default view." -ForegroundColor Green }
}
catch {
  Write-Host "[inspect-view] Error: $($_.Exception.Message)" -ForegroundColor Red
  exit 3
}
