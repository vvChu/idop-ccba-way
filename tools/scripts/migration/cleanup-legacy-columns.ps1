param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [string]$MigrationPlanPath = "migration-plan.json",
  [switch]$DryRun,
  [switch]$Force,
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'

function Write-Log([string]$msg, [string]$level = 'INFO') {
  switch ($level) {
    'OK'    { Write-Host $msg -ForegroundColor Green }
    'WARN'  { Write-Host $msg -ForegroundColor DarkYellow }
    'ERR'   { Write-Host $msg -ForegroundColor Red }
    default { Write-Host $msg }
  }
}

$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$envConfigs = @{
  Dev  = "https://ibstbim.sharepoint.com/sites/idop-dev"
  Test = "https://ibstbim.sharepoint.com/sites/idop-test"
  Prod = "https://ibstbim.sharepoint.com/sites/idop-prod"
}

if (-not $envConfigs.ContainsKey($Environment)) { Write-Log "[cleanup] ❌ Unknown environment: $Environment" 'ERR'; exit 1 }
$siteUrl = $envConfigs[$Environment]

# Auth helper
$authModule = Join-Path $PSScriptRoot '../modules/PnPHelpers.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }

Write-Log "[cleanup] 🔗 Connecting to $siteUrl"
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
} else {
  Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
}
Write-Log "[cleanup] ✅ Connected" 'OK'

if (-not (Test-Path $MigrationPlanPath)) { Write-Log "[cleanup] ❌ Migration plan not found: $MigrationPlanPath" 'ERR'; exit 1 }
$plan = Get-Content -Raw -Path $MigrationPlanPath | ConvertFrom-Json
Write-Log "[cleanup] 📋 Loaded migration plan with $($plan.Count) mappings"

$deleted = 0; $skipped = 0; $errors = 0

foreach ($map in $plan) {
  $listName = $map.List
  $legacyField = $map.OriginalField
  $parallelField = $map.ParallelField

  Write-Log "[cleanup] ▶ Considering removal: $listName.$legacyField (parallel: $parallelField)"
  try {
    $list = Get-PnPList -Identity $listName -ErrorAction Stop
    $legacy = Get-PnPField -List $list -Identity $legacyField -ErrorAction SilentlyContinue
    if (-not $legacy) { Write-Log "[cleanup] ℹ️ Legacy field missing already: $listName.$legacyField"; $skipped++; continue }

    $parallel = Get-PnPField -List $list -Identity $parallelField -ErrorAction SilentlyContinue
    if (-not $parallel) { Write-Log "[cleanup] ⚠️ Parallel field not found: $listName.$parallelField; skip" 'WARN'; $skipped++; continue }

    # Safety check: ensure every item that has legacy value also has parallel value
    $items = Get-PnPListItem -List $list -Fields $legacyField, $parallelField -PageSize 5000
    $needs = @();
    foreach ($it in $items) {
      $legacyVal = $it[$legacyField]
      if ($legacyVal -and -not $it[$parallelField]) { $needs += $it.Id }
    }
    if ($needs.Count -gt 0 -and -not $Force) {
      Write-Log "[cleanup] ❌ Found $($needs.Count) items missing parallel values for $listName.$legacyField -> cannot drop (use -Force to override)" 'ERR'
      $skipped++; continue
    }

    if ($DryRun) {
      Write-Log "[cleanup] ⏩ Would remove field '$legacyField' from list '$listName'" 'WARN'
    } else {
      Remove-PnPField -List $list -Identity $legacyField -Force -ErrorAction Stop
      Write-Log "[cleanup] 🗑️ Removed field '$legacyField' from '$listName'" 'OK'
      $deleted++
    }
  } catch {
    Write-Log "[cleanup] ❌ Error on ${listName}.${legacyField}: $($_.Exception.Message)" 'ERR'
    $errors++
  }
}

Write-Log "[cleanup] ✅ Done. Removed: $deleted, Skipped: $skipped, Errors: $errors" 'OK'
exit 0
