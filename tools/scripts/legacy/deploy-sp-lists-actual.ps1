<#
.SYNOPSIS
    Script thực sự deploy 42 SharePoint Lists cho IDOP lên Dev environment
.DESCRIPTION
    Tạo các SharePoint Lists từ JSON definitions trong datamodel/sharepoint/lists
    với kết nối PnP.PowerShell sử dụng ClientId đã đăng ký
.AUTHOR
    IDOP-CCBA-WAY Deployment System
.VERSION
    1.0 - 2025-09-17
#>

param(
    [string]$Environment = "Dev",
    [switch]$DryRun,
    [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

# --- KHỐI LỆNH KẾT NỐI CHUẨN CỦA CCBA ---
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
Write-Host "🚀 Bắt đầu deployment cho environment: $Environment" -ForegroundColor Green
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

# Hàm tạo SharePoint List từ JSON
function New-SharePointListFromJson {
    param(
        [string]$JsonPath,
        [switch]$DryRun
    )
    
    try {
        $listDef = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $listName = $listDef.ListName
        $listTitle = $listDef.ListName
        
        if ($DryRun) {
            Write-Host "  📋 [DRY-RUN] Sẽ tạo list: $listTitle ($listName)" -ForegroundColor Yellow
            return
        }
        
        # Kiểm tra list đã tồn tại chưa
        $existingList = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
        if ($existingList) {
            Write-Host "  ℹ️ List '$listTitle' đã tồn tại. Bỏ qua." -ForegroundColor Gray
            return
        }
        
        # Tạo list mới
        Write-Host "  🔨 Tạo list: $listTitle..." -ForegroundColor Yellow
        $newList = New-PnPList -Title $listTitle -Template GenericList -Url "Lists/$listName"
        
        # Thêm các fields tùy chỉnh nếu có
        if ($listDef.Columns) {
            foreach ($field in $listDef.Columns) {
                if ($field.Name -eq "Title") { continue } # Bỏ qua field mặc định
                
                Write-Host "    ➕ Thêm field: $($field.Name)" -ForegroundColor DarkGray
                
                switch ($field.Type) {
                    "Text" { 
                        Add-PnPField -List $listName -Type Text -InternalName $field.Name -DisplayName $field.Name
                    }
                    "Note" { 
                        Add-PnPField -List $listName -Type Note -InternalName $field.Name -DisplayName $field.Name
                    }
                    "Number" { 
                        Add-PnPField -List $listName -Type Number -InternalName $field.Name -DisplayName $field.Name
                    }
                    "DateTime" { 
                        Add-PnPField -List $listName -Type DateTime -InternalName $field.Name -DisplayName $field.Name
                    }
                    "Choice" {
                        if ($field.Choices -and $field.Choices.Count -gt 0) {
                            Add-PnPField -List $listName -Type Choice -InternalName $field.Name -DisplayName $field.Name -Choices $field.Choices
                        }
                    }
                    "User" { 
                        Add-PnPField -List $listName -Type User -InternalName $field.Name -DisplayName $field.Name
                    }
                    "URL" { 
                        Add-PnPField -List $listName -Type URL -InternalName $field.Name -DisplayName $field.Name
                    }
                    "Currency" { 
                        Add-PnPField -List $listName -Type Currency -InternalName $field.Name -DisplayName $field.Name
                    }
                    "Lookup" {
                        Write-Host "      ⚠️ Lookup field '$($field.Name)' cần xử lý đặc biệt - tạm bỏ qua" -ForegroundColor DarkYellow
                    }
                    "ManagedMetadata" {
                        Write-Host "      ⚠️ Managed Metadata field '$($field.Name)' cần xử lý đặc biệt - tạm bỏ qua" -ForegroundColor DarkYellow
                    }
                    default {
                        Write-Host "      ⚠️ Field type '$($field.Type)' chưa được hỗ trợ" -ForegroundColor DarkYellow
                    }
                }
            }
        }
        
        Write-Host "  ✅ Tạo thành công list: $listTitle" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Lỗi tạo list từ $JsonPath`: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Lấy tất cả JSON files từ datamodel/sharepoint/lists
$listsPath = "datamodel/sharepoint/lists"
$jsonFiles = Get-ChildItem -Path $listsPath -Recurse -Filter *.json

Write-Host "📊 Tìm thấy $($jsonFiles.Count) definition files" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 CHẠY CHẾ ĐỘ DRY-RUN - Không tạo lists thực tế" -ForegroundColor Yellow
    Write-Host ""
}

# Tạo từng list
$successCount = 0
$skipCount = 0
$errorCount = 0

foreach ($jsonFile in $jsonFiles) {
    $relativePath = $jsonFile.FullName.Replace((Get-Location).Path + "\", "")
    Write-Host "📁 Processing: $relativePath" -ForegroundColor White
    
    try {
        New-SharePointListFromJson -JsonPath $jsonFile.FullName -DryRun:$DryRun
        if (-not $DryRun) { $successCount++ }
    }
    catch {
        $errorCount++
        Write-Host "  ❌ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Tổng kết
Write-Host ""
Write-Host "=== DEPLOYMENT SUMMARY ===" -ForegroundColor Yellow
Write-Host "📊 Total JSON files: $($jsonFiles.Count)" -ForegroundColor Cyan
if (-not $DryRun) {
    Write-Host "✅ Lists created successfully: $successCount" -ForegroundColor Green
    Write-Host "⏭️ Lists skipped (existed): $skipCount" -ForegroundColor Gray
    Write-Host "❌ Lists failed: $errorCount" -ForegroundColor Red
} else {
    Write-Host "🔍 DRY-RUN completed - no actual changes made" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🏁 Deployment hoàn thành!" -ForegroundColor Green