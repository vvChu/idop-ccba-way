param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [switch]$HideOld,
  [switch]$RemoveOld,
  [switch]$AllowReplace,
  [switch]$DryRun,
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$envMap = @{ Dev="https://ibstbim.sharepoint.com/sites/idop-dev"; Test="https://ibstbim.sharepoint.com/sites/idop-test"; Prod="https://ibstbim.sharepoint.com/sites/idop-prod" }
$siteUrl = $envMap[$Environment]

Import-Module PnP.PowerShell -ErrorAction Stop
$authModule = Join-Path $PSScriptRoot '../modules/PnPHelpers.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }

Write-Host "[migrate-mm] 🔗 Connecting to $siteUrl" -ForegroundColor Yellow
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
} else {
  Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
}
Write-Host "[migrate-mm] ✅ Connected" -ForegroundColor Green

# Map lists and parallel fields to migrate from *_MM to clean names
$plan = @{
  Activities      = @(@{ From='Status_MM';      To='Status' })
  Assets          = @(@{ From='Status_MM';      To='Status' })
  Employees       = @(@{ From='Status_MM';      To='Status' })
  LessonsLearned  = @(@{ From='Category_MM';    To='Category' })
  Submissions     = @(@{ From='Status_MM';      To='Status' })
  Contracts       = @(@{ From='Status_MM';      To='Status' })
  Vendors         = @(@{ From='ServiceType_MM'; To='ServiceType' })
  Projects        = @(@{ From='ServiceType_MM'; To='ServiceType' }, @{ From='Status_MM'; To='Status' })
  ProjectIssues   = @(@{ From='Status_MM';      To='Status' })
  ProjectRisks    = @(@{ From='Status_MM';      To='Status' })
  WorkPackages    = @(@{ From='Status_MM';      To='Status' })
  Expenses        = @(@{ From='ExpenseType_MM'; To='ExpenseType' })
}

foreach ($entry in $plan.GetEnumerator()) {
  $listName = $entry.Key
  $pairs = $entry.Value
  Write-Host "[migrate-mm] ▶ $listName" -ForegroundColor White
  $list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
  if (-not $list) { Write-Host "[migrate-mm]   ⚠ List not found, skipping." -ForegroundColor DarkYellow; continue }

  foreach ($p in $pairs) {
    $from = $p.From; $to = $p.To
  $fromField = Get-PnPField -List $listName -Identity $from -ErrorAction SilentlyContinue
  $toField   = Get-PnPField -List $listName -Identity $to   -ErrorAction SilentlyContinue
  if ($toField -and $toField.InternalName -ne $to) { $toField = $null }

    if (-not $fromField) { Write-Host "[migrate-mm]   ℹ️ Source field '$from' not found, skip pair." -ForegroundColor Gray; continue }

    # Get TermSetPath from datamodel JSON if possible
    $termSetPath = $null
    try {
      $jsonFiles = Get-ChildItem -Path "datamodel/sharepoint/lists" -Recurse -Filter *.json
      foreach ($jf in $jsonFiles) {
        $def = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json
        if ($def.ListName -ne $listName) { continue }
        # prefer the 'to' field spec; else fallback to 'from'
        $col = $null
        foreach ($c in $def.Columns) { if ($c.Name -eq $to) { $col = $c; break } }
        if (-not $col) { foreach ($c in $def.Columns) { if ($c.Name -eq $from) { $col = $c; break } } }
        if ($col -and $col.TermSet -and $col.TermSet.Group -and $col.TermSet.Name) {
          $termSetPath = "{0}|{1}" -f $col.TermSet.Group, $col.TermSet.Name
          break
        }
      }
    } catch {}

    if ($toField -and ($toField.TypeAsString -notmatch 'Taxonomy')) {
      if ($AllowReplace) {
        if ($DryRun) { Write-Host "[migrate-mm]   [DRY] Would remove non-taxonomy field '$to' to replace with Taxonomy" -ForegroundColor Magenta }
        else {
          Write-Host "[migrate-mm]   🗑️ Removing non-taxonomy field '$to' to replace with Taxonomy" -ForegroundColor Yellow
          try { Remove-PnPField -List $listName -Identity $to -Force -ErrorAction Stop | Out-Null } catch { Write-Host "[migrate-mm]   ⚠ Remove failed: $($_.Exception.Message)" -ForegroundColor DarkYellow }
        }
        $toField = $null
      }
      else {
        Write-Host "[migrate-mm]   ⚠ Field '$to' exists and is not taxonomy. Re-run with -AllowReplace to replace it." -ForegroundColor DarkYellow
      }
    }

    if (-not $toField) {
      if ($DryRun) { Write-Host "[migrate-mm]   [DRY] Would create field '$to' (MM)" -ForegroundColor Magenta }
      else {
        Write-Host "[migrate-mm]   ➕ Creating field '$to' (MM)" -ForegroundColor Yellow
        if ($termSetPath) {
          Add-PnPTaxonomyField -List $listName -DisplayName $to -InternalName $to -TermSetPath $termSetPath | Out-Null
        }
        else {
          # Last resort: try by copying term set id from source if available via schema xml
          $tsId = $null
          try {
            $xml = [xml]$fromField.SchemaXml
            $tsId = $xml.Field.Attributes["TermSetId"].Value
          } catch { $tsId = $null }
          if ($tsId) { Add-PnPTaxonomyField -List $listName -DisplayName $to -InternalName $to -TermSetId $tsId | Out-Null }
          else { Write-Host "[migrate-mm]   ⚠ Could not resolve TermSet for '$to'" -ForegroundColor DarkYellow }
        }
      }
      $toField = Get-PnPField -List $listName -Identity $to -ErrorAction SilentlyContinue
    }

    if ($toField) {
      if ($DryRun) { Write-Host "[migrate-mm]   [DRY] Would backfill '$to' from '$from' if empty" -ForegroundColor Magenta }
      else {
        Write-Host "[migrate-mm]   🔁 Backfilling '$to' from '$from' (only for items with empty '$to')" -ForegroundColor Yellow
        $items = Get-PnPListItem -List $listName -PageSize 2000
        foreach ($it in $items) {
          $toVal = $it[$to]
          if ($null -ne $toVal -and $toVal.Label) { continue }
          $fromVal = $it[$from]
          if ($null -ne $fromVal -and $fromVal.Label) {
            Set-PnPListItem -List $listName -Identity $it.Id -Values @{ $to = $fromVal } | Out-Null
          }
        }
      }
    }

    if ($HideOld -and $fromField) {
      if ($DryRun) { Write-Host "[migrate-mm]   [DRY] Would hide '$from' on forms" -ForegroundColor Magenta }
      else {
        try { Set-PnPField -List $listName -Identity $from -Values @{ ShowInNewForm=$false; ShowInEditForm=$false; ShowInDisplayForm=$false } -ErrorAction SilentlyContinue | Out-Null } catch {}
      }
    }

    if ($RemoveOld -and $fromField) {
      if ($DryRun) { Write-Host "[migrate-mm]   [DRY] Would remove '$from'" -ForegroundColor Magenta }
      else {
        Write-Host "[migrate-mm]   🗑️ Removing old field '$from'" -ForegroundColor Yellow
        try { Remove-PnPField -List $listName -Identity $from -Force -ErrorAction Stop | Out-Null } catch { Write-Host "[migrate-mm]   ⚠ Remove failed: $($_.Exception.Message)" -ForegroundColor DarkYellow }
      }
    }
  }
}

# Update default views to prefer clean names (maps *_MM -> clean)
& "$PSScriptRoot\update-views-mm.ps1" -Environment $Environment -HideLegacy:$HideOld -Lists $plan.Keys

Disconnect-PnPOnline
Write-Host "[migrate-mm] Done." -ForegroundColor Green
