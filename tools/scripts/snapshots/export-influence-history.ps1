<#!
.SYNOPSIS
  Ghi lại lịch sử InfluenceScore theo thời gian.
.DESCRIPTION
  Đọc Opportunities (ID, InfluenceScore, Stage) và append vào influence_history.csv với timestamp.
#>
param(
  [string]$Environment = 'Dev'
)

$clientId = '90ded6f0-b787-4b3c-acea-8baf6403fd63'
$envConfigs = @{
  Dev = 'https://ibstbim.sharepoint.com/sites/idop-dev'
  Test = 'https://ibstbim.sharepoint.com/sites/idop-test'
  Prod = 'https://ibstbim.sharepoint.com/sites/idop-prod'
}
if (-not $envConfigs.ContainsKey($Environment)) { throw 'Invalid environment' }
$siteUrl = $envConfigs[$Environment]

Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId

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
