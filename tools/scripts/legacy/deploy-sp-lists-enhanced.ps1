<#
.SYNOPSIS
    Script cải tiến deploy SharePoint Lists với support đầy đủ cho tất cả Field Types
.DESCRIPTION
    Tạo các SharePoint Lists từ JSON definitions với xử lý đầy đủ:
    - Lookup fields với reference list validation
    - ManagedMetadata fields với TermSet mapping
    - Choice fields với proper syntax
    - Required fields với validation
    - Comprehensive error handling
.AUTHOR
    IDOP-CCBA-WAY Enhanced Deployment System
.VERSION
    2.0 - 2025-09-17
#>

param(
    [string]$Environment = "Dev",
    [switch]$DryRun,
    [switch]$UpdateExisting,
    [switch]$Diff,
    [switch]$SyncChoices,
    [string]$SingleList,
    [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

# --- KHỐI LỆNH KẾT NỐI CHUẨN CỦA CCBA ---
$modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/modules/SpListDeploy.psm1'
if (Test-Path $modulePath) {
    Write-Host ("🧩 Loading module: {0}" -f $modulePath) -ForegroundColor DarkCyan
    try {
        Import-Module $modulePath -Force -ErrorAction Stop
    } catch {
        Write-Host ("⚠️ Import-Module failed: {0}. Falling back to dot-sourcing." -f $_.Exception.Message) -ForegroundColor DarkYellow
        . $modulePath
    }
}
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
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
Write-Host "🚀 Bắt đầu ENHANCED deployment cho environment: $Environment" -ForegroundColor Green
Write-Host "🌐 SharePoint Site: $siteUrl" -ForegroundColor Cyan

# Kết nối SharePoint
try {
    Write-Host "🔗 Đang kết nối đến SharePoint..." -ForegroundColor Cyan
    # Auth helper
    $authModule = Join-Path $PSScriptRoot 'modules/SpAuth.psm1'
    if (Test-Path $authModule) { Import-Module $authModule -Force }
    if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
        Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
    } else {
        Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
    }
    Write-Host "✅ Kết nối thành công!" -ForegroundColor Green
}
catch {
    Write-Host "❌ KẾT NỐI THẤT BẠI: $($_.Exception.Message)" -ForegroundColor Red
    exit 2
}

if (-not (Get-Command -Name New-EnhancedSharePointList -ErrorAction SilentlyContinue)) {
    if (Test-Path $modulePath) {
        Write-Host "⚠️ Exported function not found after import, attempting dot-source fallback..." -ForegroundColor Yellow
        . $modulePath
    }
    if (-not (Get-Command -Name New-EnhancedSharePointList -ErrorAction SilentlyContinue)) {
        Write-Host "⚠️ Module chức năng đầy đủ chưa refactor hoàn chỉnh – function vẫn không khả dụng." -ForegroundColor Yellow
    }
}

# Main execution
$listsPath = "datamodel/sharepoint/lists"

if ($SingleList) {
    # Xử lý single list
    $jsonFiles = Get-ChildItem -Path $listsPath -Recurse -Filter "*.json" | Where-Object { $_.BaseName -eq $SingleList }
    if (-not $jsonFiles) {
        Write-Host "❌ Không tìm thấy JSON file cho list: $SingleList" -ForegroundColor Red
        exit 3
    }
} else {
    # Xử lý tất cả lists
    $jsonFiles = Get-ChildItem -Path $listsPath -Recurse -Filter *.json
}

Write-Host "📊 Sẽ xử lý $($jsonFiles.Count) list definition files" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 CHẠY CHẾ ĐỘ DRY-RUN - Không tạo/update thực tế" -ForegroundColor Yellow
}

if ($UpdateExisting) {
    Write-Host "🔄 CHẾ ĐỘ UPDATE - Sẽ thêm fields vào lists hiện có" -ForegroundColor Cyan
}

Write-Host ""

# Process lists
$stats = @{
    TotalProcessed = 0
    ListsCreated = 0
    ListsUpdated = 0
    ListsSkipped = 0
    ListsFailed = 0
    FieldsSuccess = 0
    FieldsFailed = 0
}

foreach ($jsonFile in $jsonFiles) {
    $relativePath = $jsonFile.FullName.Replace((Get-Location).Path + "\", "")
    Write-Host "📁 Processing: $relativePath" -ForegroundColor White
    
    $result = New-EnhancedSharePointList -JsonPath $jsonFile.FullName -DryRun:$DryRun -UpdateExisting:$UpdateExisting -Diff:$Diff -SyncChoices:$SyncChoices

    # Index / lookup advisory
    try {
        $listDef = Get-Content $jsonFile.FullName -Raw | ConvertFrom-Json
        $lookupCount = ($listDef.Columns | Where-Object { $_.Type -eq 'Lookup' }).Count
        $colCount = $listDef.Columns.Count
        if ($lookupCount -gt 8 -or $colCount -gt 28) {
            $warn = "[WARNING] $($listDef.ListName): Lookup=$lookupCount Columns=$colCount -> Consider indexing high-traffic lookups."
            Write-Host "⚠️ $warn" -ForegroundColor DarkYellow
            Add-Content -Path "deploy-warnings.log" -Value $warn
        }
    } catch { }
    
    $stats.TotalProcessed++
    if ($result.Success) {
        if ($result.Created) { $stats.ListsCreated++ }
        elseif ($result.Updated) { $stats.ListsUpdated++ }
        else { $stats.ListsSkipped++ }
        
        if ($result.FieldsSuccess) { $stats.FieldsSuccess += $result.FieldsSuccess }
        if ($result.FieldsFailed) { $stats.FieldsFailed += $result.FieldsFailed }
    } else {
        $stats.ListsFailed++
    }
}

# Summary Report
Write-Host ""
Write-Host "=== ENHANCED DEPLOYMENT SUMMARY ===" -ForegroundColor Yellow
Write-Host "📊 Total processed: $($stats.TotalProcessed)" -ForegroundColor Cyan
if ($Diff) { Write-Host "📝 Mode: DIFF (so sánh schema fields)" -ForegroundColor Yellow }
if ($SyncChoices) { Write-Host "🔁 Mode: SYNC CHOICES (đồng bộ giá trị choice/multichoice)" -ForegroundColor Yellow }
if (-not $DryRun) {
    Write-Host "🆕 Lists created: $($stats.ListsCreated)" -ForegroundColor Green
    Write-Host "🔄 Lists updated: $($stats.ListsUpdated)" -ForegroundColor Blue
    Write-Host "⏭️ Lists skipped: $($stats.ListsSkipped)" -ForegroundColor Gray
    Write-Host "❌ Lists failed: $($stats.ListsFailed)" -ForegroundColor Red
    Write-Host "✅ Fields created: $($stats.FieldsSuccess)" -ForegroundColor Green
    Write-Host "❌ Fields failed: $($stats.FieldsFailed)" -ForegroundColor Red
} else {
    Write-Host "🔍 DRY-RUN completed - no actual changes made" -ForegroundColor Yellow
}

Write-Host ""
if ($stats.FieldsFailed -gt 0) {
    Write-Host "⚠️ Một số fields gặp lỗi. Kiểm tra logs ở trên để biết chi tiết." -ForegroundColor DarkYellow
    Write-Host "💡 Lookup fields cần target lists tồn tại trước." -ForegroundColor Blue
    Write-Host "💡 ManagedMetadata fields cần config TermStore manually." -ForegroundColor Blue
}

Write-Host "🏁 Enhanced deployment hoàn thành!" -ForegroundColor Green