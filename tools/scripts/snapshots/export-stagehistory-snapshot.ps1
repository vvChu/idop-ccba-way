<#
.SYNOPSIS
    Export snapshot of OpportunityStageHistory list to CSV for analytics/velocity tracking.
.DESCRIPTION
    Exports all items from the OpportunityStageHistory SharePoint list to a timestamped CSV file in the snapshots directory.
    Columns: OpportunityId, FromStage, ToStage, ChangedBy, ChangedDate, DaysInPrevStage
#>

param(
    [string]$Environment = "Dev"
)

$ErrorActionPreference = 'Stop'

$envConfigs = @{
    Dev = "https://ibstbim.sharepoint.com/sites/idop-dev"
    Test = "https://ibstbim.sharepoint.com/sites/idop-test"
    Prod = "https://ibstbim.sharepoint.com/sites/idop-prod"
}

if (-not $envConfigs.ContainsKey($Environment)) {
    Write-Host "❌ Environment '$Environment' không hợp lệ. Chọn: Dev, Test, Prod" -ForegroundColor Red
    exit 1
}

$siteUrl = $envConfigs[$Environment]
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"

Write-Host "🔗 Kết nối SharePoint..." -ForegroundColor Cyan
Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId

$listName = "OpportunityStageHistory"

Write-Host "📥 Đang export OpportunityStageHistory..." -ForegroundColor Yellow
$items = Get-PnPListItem -List $listName -PageSize 2000 | Select-Object -ExpandProperty FieldValues

if (-not $items) {
    Write-Host "⚠️ Không có dữ liệu trong $listName" -ForegroundColor Yellow
    exit 0
}

# Map fields for export
$exportRows = $items | ForEach-Object {
    [PSCustomObject]@{
        OpportunityId = $_.OpportunityId
        FromStage     = $_.FromStage
        ToStage       = $_.ToStage
        ChangedBy     = $_.ChangedBy
        ChangedDate   = $_.ChangedDate
        DaysInPrevStage = $_.DaysInPrevStage
    }
}

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$outFile = "snapshots/OpportunityStageHistory-snapshot-$ts.csv"
$exportRows | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8

Write-Host "✅ Export thành công: $outFile" -ForegroundColor Green
