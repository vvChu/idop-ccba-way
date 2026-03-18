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

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Get environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Host "🔗 Kết nối SharePoint..." -ForegroundColor Cyan
Connect-IdopOnline -SiteUrl $siteUrl -AuthMode Interactive -ClientId $config.ClientId

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
