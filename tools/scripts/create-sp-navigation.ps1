<#
.SYNOPSIS
    Script tạo SharePoint Navigation structure cho 42 IDOP Lists
.DESCRIPTION
    Tổ chức 42 SharePoint Lists theo 5 modules với navigation hierarchy
    - Cash Data (11 lists)
    - People Assets (12 lists)
    - Performance OKRs (5 lists) 
    - Process Execution (10 lists)
    - System Governance (4 lists)
.AUTHOR
    IDOP-CCBA-WAY Navigation System
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
Write-Host "🧭 Tạo SharePoint Navigation cho environment: $Environment" -ForegroundColor Green
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

# Định nghĩa cấu trúc modules và lists
$modules = @{
    "Cash Data" = @{
        Icon = "💰"
        Color = "#2E7D32"  # Green
        Lists = @(
            "AllocationRules", "BankAccounts", "DocumentRequirements", 
            "ExpenseChecklists", "Expenses", "FinancialPlans", 
            "InputInvoices", "InvoiceRequests", "OutgoingInvoices", 
            "SharedCostAllocations", "Vendors"
        )
    }
    "People Assets" = @{
        Icon = "👥"
        Color = "#1976D2"  # Blue
        Lists = @(
            "Assets", "BenefitPackages", "Certifications", "Departments",
            "EmployeeBenefits", "EmployeeHistory", "Employees", "EmploymentContracts",
            "MaintenanceLogs", "ProjectMembers", "Rewards", "Timesheets"
        )
    }
    "Performance OKRs" = @{
        Icon = "📊"
        Color = "#7B1FA2"  # Purple
        Lists = @(
            "Measurables", "OKRS_KeyResults", "OKRS_Objectives", 
            "Quarters", "ScorecardData"
        )
    }
    "Process Execution" = @{
        Icon = "⚙️"
        Color = "#F57C00"  # Orange
        Lists = @(
            "Activities", "AssignmentDetails", "Contracts", "JobAssignments",
            "LessonsLearned", "ProjectHistory", "ProjectIssues", "ProjectRisks",
            "Projects", "WorkPackages"
        )
    }
    "System Governance" = @{
        Icon = "🛡️"
        Color = "#D32F2F"  # Red
        Lists = @(
            "ApprovalWorkflows", "EnvironmentVariables", 
            "IntegrationPoints", "Submissions"
        )
    }
}

Write-Host "📋 Tìm thấy $($modules.Keys.Count) modules với tổng cộng $(($modules.Values | ForEach-Object { $_.Lists.Count } | Measure-Object -Sum).Sum) lists" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 CHẠY CHẾ ĐỘ DRY-RUN - Hiển thị structure sẽ được tạo" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($moduleName in $modules.Keys) {
        $module = $modules[$moduleName]
        Write-Host "📁 $($module.Icon) $moduleName ($($module.Lists.Count) lists)" -ForegroundColor Green
        foreach ($listName in $module.Lists) {
            Write-Host "  ├─ $listName" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    Write-Host "🔍 DRY-RUN completed - no actual changes made" -ForegroundColor Yellow
    exit 0
}

# Hàm tạo navigation structure
function New-ModuleNavigation {
    param(
        [string]$ModuleName,
        [hashtable]$ModuleConfig,
        [switch]$DryRun
    )
    
    try {
        Write-Host "🔨 Tạo navigation cho module: $($ModuleConfig.Icon) $ModuleName..." -ForegroundColor Yellow
        
        # Tạo navigation node cho module (không cần landing page)
        $moduleNode = Add-PnPNavigationNode -Location "QuickLaunch" -Title "$($ModuleConfig.Icon) $ModuleName" -Url "#"
        Write-Host "  ✅ Created module node: $($moduleNode.Title)" -ForegroundColor Green
        
        # Thêm các lists vào module
        $addedLists = 0
        foreach ($listName in $ModuleConfig.Lists) {
            # Kiểm tra list có tồn tại không
            $list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
            if ($list) {
                # Sử dụng DefaultViewUrl từ list object
                $listUrl = $list.DefaultViewUrl
                Add-PnPNavigationNode -Location "QuickLaunch" -Title $listName -Url $listUrl -Parent $moduleNode.Id
                Write-Host "    ➕ Added list: $listName" -ForegroundColor DarkGray
                $addedLists++
            } else {
                Write-Host "    ⚠️ List not found: $listName" -ForegroundColor Yellow
            }
        }
        
        Write-Host "  📊 Module completed: $addedLists/$($ModuleConfig.Lists.Count) lists added" -ForegroundColor Cyan
        return @{
            ModuleName = $ModuleName
            Node = $moduleNode
            ListsAdded = $addedLists
            TotalLists = $ModuleConfig.Lists.Count
        }
    }
    catch {
        Write-Host "  ❌ Lỗi tạo module $ModuleName`: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Xóa navigation cũ (optional - để tránh duplicate)
Write-Host "🧹 Xóa navigation nodes cũ (IDOP modules)..." -ForegroundColor Cyan
try {
    $existingNodes = Get-PnPNavigationNode -Location QuickLaunch | Where-Object { 
        $_.Title -match "💰|👥|📊|⚙️|🛡️|Cash Data|People Assets|Performance OKRs|Process Execution|System Governance" 
    }
    foreach ($node in $existingNodes) {
        Remove-PnPNavigationNode -Identity $node.Id -Force
        Write-Host "  🗑️ Removed: $($node.Title)" -ForegroundColor DarkGray
    }
} catch {
    Write-Host "  ⚠️ Không thể xóa navigation cũ: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Tạo navigation cho từng module
Write-Host "🏗️ Bắt đầu tạo navigation structure..." -ForegroundColor Yellow
$results = @()

foreach ($moduleName in $modules.Keys) {
    $moduleConfig = $modules[$moduleName]
    $result = New-ModuleNavigation -ModuleName $moduleName -ModuleConfig $moduleConfig
    if ($result) {
        $results += $result
    }
}

# Tổng kết
Write-Host ""
Write-Host "=== NAVIGATION CREATION SUMMARY ===" -ForegroundColor Yellow
Write-Host "🏗️ Modules created: $($results.Count)/$($modules.Keys.Count)" -ForegroundColor Cyan

$totalListsAdded = ($results | Measure-Object -Property ListsAdded -Sum).Sum
$totalListsExpected = ($results | Measure-Object -Property TotalLists -Sum).Sum

Write-Host "📋 Lists added to navigation: $totalListsAdded/$totalListsExpected" -ForegroundColor Cyan

if ($totalListsAdded -eq $totalListsExpected) {
    Write-Host "✅ Navigation structure created successfully!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Some lists were not added to navigation. Check warnings above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Visit $siteUrl to see the new navigation" -ForegroundColor White
Write-Host "2. Create landing pages for each module (optional)" -ForegroundColor White
Write-Host "3. Add descriptions và icons to enhance UX" -ForegroundColor White

Write-Host ""
Write-Host "🏁 Navigation creation completed!" -ForegroundColor Green