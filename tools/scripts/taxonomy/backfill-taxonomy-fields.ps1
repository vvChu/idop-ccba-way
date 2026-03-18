param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [string]$MigrationPlanPath = "migration-plan.json",
  [switch]$DryRun,
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'

# Import PnP module (assuming it's available)
# Import-Module PnP.PowerShell -ErrorAction Stop

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

if (-not $envConfigs.ContainsKey($Environment)) { Write-Log "[backfill] ❌ Unknown environment: $Environment" 'ERR'; exit 1 }
$siteUrl = $envConfigs[$Environment]

# Auth helper
$authModule = Join-Path $PSScriptRoot '../modules/PnPHelpers.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }

Write-Log "[backfill] 🔗 Connecting to $siteUrl"
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
} else {
  Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
}
Write-Log "[backfill] ✅ Connected" 'OK'

# Load migration plan
if (-not (Test-Path $MigrationPlanPath)) { Write-Log "[backfill] ❌ Migration plan not found: $MigrationPlanPath" 'ERR'; exit 1 }
$migrationPlan = Get-Content -Raw -Path $MigrationPlanPath | ConvertFrom-Json
Write-Log "[backfill] 📋 Loaded migration plan with $($migrationPlan.Count) items"

$backfilled = 0; $skipped = 0; $errors = 0

foreach ($item in $migrationPlan) {
  $listName = $item.List
  $originalField = $item.OriginalField
  $parallelField = $item.ParallelField
  $termGroupName = $item.TermGroup
  $termSetName = $item.TermSet

  Write-Log "[backfill] ▶ Processing $listName.$originalField -> $parallelField"

  try {
    $list = Get-PnPList -Identity $listName -ErrorAction Stop
    $group = Get-PnPTermGroup -Identity $termGroupName -ErrorAction Stop
    $termSet = Get-PnPTermSet -Identity $termSetName -TermGroup $group -ErrorAction Stop

    # Load terms from taxonomy JSON
    $taxonomyPath = "datamodel/sharepoint/taxonomy/${termSetName}.json"
    if (-not (Test-Path $taxonomyPath)) { throw "Taxonomy file not found: $taxonomyPath" }
    $taxonomy = Get-Content -Raw -Path $taxonomyPath | ConvertFrom-Json
    $termMap = @{}
    function BuildTermMap($terms) {
      foreach ($term in $terms) {
        $termMap[$term.Name] = $term.Id
        if ($term.Children) { BuildTermMap $term.Children }
      }
    }
    BuildTermMap $taxonomy.Terms

    # Get list items
    $items = Get-PnPListItem -List $list -Fields $originalField, $parallelField -PageSize 5000

    foreach ($listItem in $items) {
      $originalValue = $listItem[$originalField]
      if (-not $originalValue -or $originalValue -eq '') { continue }

      $parallelValue = $listItem[$parallelField]
      if ($parallelValue) { continue } # Already backfilled

      $termId = $termMap[$originalValue]
      if (-not $termId) {
        Write-Log "[backfill] ⚠️ No matching term for '$originalValue' in $termSetName" 'WARN'
        continue
      }

      if ($DryRun) {
        Write-Log "[backfill] ⏩ Would set $parallelField to term ID $termId for item $($listItem.Id)"
      } else {
        # Set the taxonomy field value
        $termValue = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValue
        $termValue.TermGuid = $termId
        $termValue.Label = $originalValue
        $termValue.WssId = -1

        Set-PnPListItem -List $list -Identity $listItem.Id -Values @{ $parallelField = $termValue } | Out-Null
        Write-Log "[backfill] ✅ Backfilled item $($listItem.Id)"
        $backfilled++
      }
    }
  } catch {
    Write-Log "[backfill] ❌ Failed to process ${listName}.$originalField`: $($_.Exception.Message)" 'ERR'
    $errors++
  }
}

Write-Log "[backfill] ✅ Done. Backfilled: $backfilled, Skipped: $skipped, Errors: $errors" 'OK'
exit 0