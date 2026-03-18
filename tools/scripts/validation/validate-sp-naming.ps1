param(
  [ValidateSet("Dev","Test","Prod")][string]$Environment = "Dev",
  [ValidateSet('Cached','Interactive','DeviceLogin')][string]$Auth = 'Cached',
  [string]$ListsPath = "datamodel/sharepoint/lists"
)

$ErrorActionPreference = 'Stop'

# Re-exec under PowerShell 7+ for UTF-8 safety
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "[naming] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
  $pwshCmd = $null
  try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
  if (-not $pwshCmd) { Write-Host "[naming] Install PowerShell 7.4.6+" -ForegroundColor Red; exit 5 }
  $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSCommandPath")
  foreach ($k in $PSBoundParameters.Keys) { $v = $PSBoundParameters[$k]; $argList += "-$k"; if ($null -ne $v -and $v -ne $true) { $argList += "$v" } }
  & $pwshCmd @argList; exit $LASTEXITCODE
}

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Load environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

# Resolve paths
try { $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path } catch { $repoRoot = (Get-Location).Path }
if (-not (Test-Path -LiteralPath $ListsPath)) { $candidate = Join-Path $repoRoot $ListsPath; if (Test-Path -LiteralPath $candidate) { $ListsPath = $candidate } }
Write-Host "[naming] Site: $siteUrl" -ForegroundColor Cyan
Write-Host "[naming] ListsPath: $ListsPath" -ForegroundColor Cyan

# Connect
try {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $config.ClientId
  Write-Host "[naming] Connected." -ForegroundColor Green
} catch { Write-Host "[naming] Connect failed: $($_.Exception.Message)" -ForegroundColor Red; exit 2 }

function IsEnglishInternalName($name) { return $name -match '^[A-Za-z][A-Za-z0-9]*$' }
function SeemsVietnamese($text) {
  if ([string]::IsNullOrWhiteSpace($text)) { return $false }
  # Heuristic: contains a space and at least one Vietnamese diacritic or non-ASCII
  return ($text -match '\s') -and ($text -match '[^\x00-\x7F]')
}

$moduleDirs = Get-ChildItem -Directory -Path $ListsPath
$report = @()
foreach ($dir in $moduleDirs) {
  $jsonFiles = Get-ChildItem -Path $dir.FullName -Filter *.json -File
  foreach ($f in $jsonFiles) {
    try { $obj = Get-Content -Raw -Path $f.FullName | ConvertFrom-Json } catch { continue }
    $listName = $obj.ListName
    if (-not $listName) { continue }
    $spList = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
    if (-not $spList) { continue }
    $fields = Get-PnPField -List $spList
    foreach ($col in $obj.Columns) {
      $internal = $col.Name
      $desiredDisplay = $col.DisplayName
      $spField = Get-PnPField -List $spList -Identity $internal -ErrorAction SilentlyContinue
      if (-not $spField) { $spField = $fields | Where-Object { $_.Title -eq $desiredDisplay -or $_.Title -eq $internal } | Select-Object -First 1 }
      $actualDisplay = if ($spField) { $spField.Title } else { $null }
      $row = [pscustomobject]@{
        List = $listName
        Field = $internal
        DesiredDisplay = $desiredDisplay
        ActualDisplay = $actualDisplay
        IsEnglishInternal = IsEnglishInternalName $internal
        DisplayLooksVietnamese = SeemsVietnamese $actualDisplay
        Status = 'OK'
      }
      if (-not $row.IsEnglishInternal -or -not $row.DisplayLooksVietnamese) { $row.Status = 'VIOLATION' }
      $report += $row
    }
  }
}
# Keep session open for reuse; do not disconnect here

$violations = $report | Where-Object { $_.Status -ne 'OK' }
if ($violations.Count -gt 0) {
  Write-Host "[naming] Violations found:" -ForegroundColor Yellow
  $violations | Sort-Object List, Field | Format-Table -AutoSize List,Field,IsEnglishInternal,ActualDisplay,DisplayLooksVietnamese
  exit 1
} else {
  Write-Host "[naming] OK: EN internal / VN display." -ForegroundColor Green
}
