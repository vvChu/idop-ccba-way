param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [Parameter(Mandatory=$true)]
  [string]$ListTitle,
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'

$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$moduleName = 'PnP.PowerShell'
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
  Write-Host "[inspect-view] Missing required module '$moduleName'." -ForegroundColor Red
  exit 4
}
Import-Module $moduleName -ErrorAction Stop

$envMap = @{ Dev="https://ibstbim.sharepoint.com/sites/idop-dev"; Test="https://ibstbim.sharepoint.com/sites/idop-test"; Prod="https://ibstbim.sharepoint.com/sites/idop-prod" }
if (-not $envMap.ContainsKey($Environment)) { Write-Host "Unknown environment $Environment" -ForegroundColor Red; exit 1 }
$siteUrl = $envMap[$Environment]

Write-Host "[inspect-view] 🔗 Connecting to $siteUrl" -ForegroundColor Yellow
# Auth helper
$authModule = Join-Path $PSScriptRoot 'modules/SpAuth.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
} else {
  Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
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
