param(
  [ValidateSet('Dev','Test','Prod','IDOP')]
  [string]$Environment = 'Test',
  [string[]]$Lists = @('Projects','Customers','Contacts','Submissions','Opportunities')
)

$ErrorActionPreference = 'Stop'

# Reuse same-process PnP context to avoid prompts
& (Join-Path $PSScriptRoot 'connect-sp.ps1') -Environment $Environment -Auth Interactive

Import-Module PnP.PowerShell -ErrorAction Stop

function Initialize-List {
  param([string]$Title)
  $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
  if (-not $list) {
    Write-Host "[ensure-core-lists] Creating list: $Title" -ForegroundColor Yellow
    New-PnPList -Title $Title -Template GenericList | Out-Null
    $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if ($list) {
      Write-Host "[ensure-core-lists] Created list '$($list.Title)' at '$($list.RootFolder.ServerRelativeUrl)'" -ForegroundColor DarkGray
    } else {
      Write-Host "[ensure-core-lists] (warn) Failed to create list: $Title" -ForegroundColor DarkYellow
    }
  } else {
    Write-Host "[ensure-core-lists] Exists: $Title" -ForegroundColor DarkGreen
  }
}

Write-Host "[ensure-core-lists] Ensuring core lists for ${Environment}: $($Lists -join ', ')" -ForegroundColor Cyan
foreach ($ln in $Lists) { Initialize-List -Title $ln }

Write-Host "[ensure-core-lists] Completed." -ForegroundColor Green
