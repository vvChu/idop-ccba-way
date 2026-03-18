param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [switch]$HideLegacy,
  [switch]$DryRun,
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

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Get environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Log "[normalize] 🔗 Connecting to $siteUrl"
Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $config.ClientId
Write-Log "[normalize] ✅ Connected" 'OK'

# Find MM fields with _MM suffix and rename display name to drop suffix.
# Also hide legacy “(Term)” companion fields from forms.

$lists = Get-PnPList | Where-Object { $_.BaseTemplate -eq 100 } # GenericList

foreach ($list in $lists) {
  Write-Log "[normalize] ▶ $($list.Title)"
  $fields = Get-PnPField -List $list

  foreach ($f in $fields) {
    $internal = $f.InternalName
    $display  = $f.Title
    $type     = $f.TypeAsString

    # 1) If taxonomy field ends with _MM by display name, drop suffix for consistency
    if ($type -eq 'TaxonomyFieldType' -and $display -like '*_MM') {
      $newDisplay = $display -replace '_MM$',''
      if ($DryRun) {
        Write-Log "[normalize]   [DRY] Would rename display '$display' -> '$newDisplay' on list '$($list.Title)'" -ForegroundColor Magenta
      } else {
        try {
          Set-PnPField -List $list -Identity $internal -Values @{ Title = $newDisplay } | Out-Null
          Write-Log "[normalize]   🏷️ Renamed display '$display' -> '$newDisplay'"
  } catch { Write-Log "[normalize]   ⚠️ Rename failed for ${internal}: $($_.Exception.Message)" 'WARN' }
      }
    }

    # 2) Hide legacy companion “(Term)” fields from forms if requested
    if ($HideLegacy -and $display -like '*(Term)') {
      if ($DryRun) {
        Write-Log "[normalize]   [DRY] Would hide legacy field '$display' on '$($list.Title)'" -ForegroundColor Magenta
      } else {
        try {
          Set-PnPField -List $list -Identity $internal -Values @{ ShowInNewForm=$false; ShowInEditForm=$false; ShowInDisplayForm=$false } | Out-Null
          Write-Log "[normalize]   👁️‍🗨️ Hidden legacy field '$display' from forms"
  } catch { Write-Log "[normalize]   ⚠️ Hide failed for ${internal}: $($_.Exception.Message)" 'WARN' }
      }
    }
  }

  # 3) Ensure default view includes proper MM fields (without suffix) and removes legacy companions
  try {
    $view = (Get-PnPView -List $list | Where-Object { $_.DefaultView }) | Select-Object -First 1
    if (-not $view) { $view = Get-PnPView -List $list -Identity 'All Items' -ErrorAction SilentlyContinue }
    if ($view) {
      $vf = @($view.ViewFields)
      # remove any fields whose display contains '(Term)'
      $legacyFields = @()
      foreach ($f in $fields) {
        if ($f.Title -like '*(Term)' -and $vf -contains $f.InternalName) { $legacyFields += $f.InternalName }
      }
      $vf = $vf | Where-Object { $_ -notin $legacyFields }
      # rename references to *_MM internals not needed — internal names stay; ensure present
      # nothing further here since internal names don’t change

      if ($DryRun) {
        Write-Log "[normalize]   [DRY] Would set default view fields to: $(($vf -join ', '))" -ForegroundColor Magenta
      } else {
        $id = if ($view.Id) { $view.Id } else { $view.Title }
        Set-PnPView -List $list -Identity $id -Fields $vf | Out-Null
        Write-Log "[normalize]   ✅ Default view adjusted"
      }
    }
  } catch { Write-Log "[normalize]   ⚠️ View adjust failed: $($_.Exception.Message)" 'WARN' }
}

# Keep session open for reuse; do not disconnect explicitly
Write-Log "[normalize] Done." 'OK'
