<#
.SYNOPSIS
    Export stage velocity aggregate: join OpportunityStageHistory + Opportunities for velocity analytics.
.DESCRIPTION
    Joins OpportunityStageHistory (stage transitions) with Opportunities (current info) to produce a pre-aggregated CSV for Power BI/reporting.
    Output: OpportunityId, FromStage, ToStage, ChangedDate, DaysInPrevStage, OpportunityName, CurrentStage, Owner, Amount, Status
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

# Fetch StageHistory
$stageList = "OpportunityStageHistory"
$oppList = "Opportunities"

Write-Host "📥 Đang lấy OpportunityStageHistory..." -ForegroundColor Yellow
$stageRows = Get-PnPListItem -List $stageList -PageSize 2000 | Select-Object -ExpandProperty FieldValues

Write-Host "📥 Đang lấy Opportunities..." -ForegroundColor Yellow
$oppRows = Get-PnPListItem -List $oppList -PageSize 2000 | Select-Object -ExpandProperty FieldValues

if (-not $stageRows -or -not $oppRows) {
    Write-Host "⚠️ Không có đủ dữ liệu để join" -ForegroundColor Yellow
    exit 0
}

# Build lookup by OpportunityId
$oppMap = @{}
foreach ($o in $oppRows) { $oppMap[$o.Id] = $o }

# Join and project
$exportRows = $stageRows | ForEach-Object {
    $opp = $null
    if ($_.OpportunityId -and $oppMap.ContainsKey($_.OpportunityId)) {
        $opp = $oppMap[$_.OpportunityId]
    }
    [PSCustomObject]@{
        OpportunityId   = $_.OpportunityId
        FromStage       = $_.FromStage
        ToStage         = $_.ToStage
        ChangedDate     = $_.ChangedDate
        DaysInPrevStage = $_.DaysInPrevStage
        OpportunityName = if ($opp) { $opp.Title } else { $null }
        CurrentStage    = if ($opp) { $opp.Stage } else { $null }
        Owner           = if ($opp) { $opp.Owner } else { $null }
        Amount          = if ($opp) { $opp.Amount } else { $null }
        Status          = if ($opp) { $opp.Status } else { $null }
    }
}

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$outFile = "snapshots/StageVelocityAggregate-$ts.csv"
$exportRows | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8

Write-Host "✅ Export thành công: $outFile" -ForegroundColor Green
