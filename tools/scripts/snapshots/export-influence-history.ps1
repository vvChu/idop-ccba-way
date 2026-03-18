<#!
.SYNOPSIS
  Ghi lại lịch sử InfluenceScore theo thời gian.
.DESCRIPTION
  Đọc Opportunities (ID, InfluenceScore, Stage) và append vào influence_history.csv với timestamp.
#>
param(
  [string]$Environment = 'Dev'
)

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Get environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Connect-IdopOnline -SiteUrl $siteUrl -AuthMode Interactive -ClientId $config.ClientId

$items = Get-PnPListItem -List 'Opportunities' -PageSize 200 -ScriptBlock { Param($b) $b.Context.ExecuteQuery() }
$rows = @()
$now = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
foreach ($i in $items) {
  $rows += [pscustomobject]@{
    Timestamp = $now
    OpportunityId = $i.Id
    Stage = $i["Stage"]
    InfluenceScore = $i["InfluenceScore"]
    AdjustedProbability = $i["AdjustedProbability"]
  }
}

$outDir = Join-Path $PSScriptRoot 'output'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$file = Join-Path $outDir 'influence_history.csv'
if (-not (Test-Path $file)) {
  $rows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $file
  Write-Host "Created history file $file" -ForegroundColor Green
} else {
  $rows | Export-Csv -NoTypeInformation -Append -Encoding UTF8 -Path $file
  Write-Host "Appended to history file $file" -ForegroundColor Yellow
}
