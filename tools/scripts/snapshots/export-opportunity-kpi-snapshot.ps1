<#!
.SYNOPSIS
  Export snapshot KPI dữ liệu Opportunities + Services + Stakeholders.
.DESCRIPTION
  Tạo file CSV timestamp trong folder snapshots/output để phục vụ phân tích lịch sử.
.PARAMETER Environment
  Dev/Test/Prod mapping site URL.
#>
param(
  [string]$Environment = "Dev"
)

$ErrorActionPreference = 'Stop'
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = Join-Path $PSScriptRoot 'output'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$envConfigs = @{
    Dev = "https://ibstbim.sharepoint.com/sites/idop-dev"
    Test = "https://ibstbim.sharepoint.com/sites/idop-test"
    Prod = "https://ibstbim.sharepoint.com/sites/idop-prod"
}
if (-not $envConfigs.ContainsKey($Environment)) { throw "Invalid environment" }
$siteUrl = $envConfigs[$Environment]
Write-Host "Connecting $siteUrl" -ForegroundColor Cyan
Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId

function Get-ListItemsSimplified {
  param($ListName)
  $items = Get-PnPListItem -List $ListName -PageSize 200 -ScriptBlock { Param($items) $items.Context.ExecuteQuery() }
  $rows = @()
  foreach ($i in $items) {
    $obj = [ordered]@{ ID = $i.Id }
    foreach ($f in $i.FieldValues.Keys) {
      if ($f -in @('Attachments','FileSystemObjectType','ContentTypeId','GUID','ComplianceAssetId')) { continue }
      $val = $i.FieldValues[$f]
      if ($val -is [Microsoft.SharePoint.Client.FieldLookupValue]) { $obj[$f] = $val.LookupId }
      elseif ($val -is [System.Array]) { $obj[$f] = ($val -join ';') }
      else { $obj[$f] = $val }
    }
    $rows += [pscustomobject]$obj
  }
  return $rows
}

Write-Host "Fetching Opportunities..." -ForegroundColor Green
$opps = Get-ListItemsSimplified -ListName 'Opportunities'
Write-Host "Fetching OpportunityServices..." -ForegroundColor Green
$svc = Get-ListItemsSimplified -ListName 'OpportunityServices'
Write-Host "Fetching OpportunityStakeholders..." -ForegroundColor Green
$stks = Get-ListItemsSimplified -ListName 'OpportunityStakeholders'

$oppFile = Join-Path $outDir "opportunities_$ts.csv"
$svcFile = Join-Path $outDir "opportunity_services_$ts.csv"
$stkFile = Join-Path $outDir "opportunity_stakeholders_$ts.csv"

$opps | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $oppFile
$svc   | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $svcFile
$stks  | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $stkFile

Write-Host "Snapshot exported:" -ForegroundColor Yellow
Write-Host "  $oppFile" -ForegroundColor Yellow
Write-Host "  $svcFile" -ForegroundColor Yellow
Write-Host "  $stkFile" -ForegroundColor Yellow
