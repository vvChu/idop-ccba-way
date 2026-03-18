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
    [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached',
    [string]$ListsPath = "datamodel/sharepoint/lists"
)

# Re-exec under PowerShell 7+ if currently running in Windows PowerShell 5.1 (to handle UTF-8/emoji reliably)
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "[nav] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
    $pwshCmd = $null
    try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
    if (-not $pwshCmd) {
        Write-Host "[nav] pwsh (PowerShell 7) not found. Please install PowerShell 7.4.6+ and re-run: https://github.com/PowerShell/PowerShell" -ForegroundColor Red
        exit 5
    }
    $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSCommandPath")
    foreach ($k in $PSBoundParameters.Keys) {
        $v = $PSBoundParameters[$k]
        $argList += "-$k"
        if ($null -ne $v -and $v -ne $true) { $argList += "$v" }
    }
    & $pwshCmd @argList
    exit $LASTEXITCODE
}

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
Write-Host "[nav] Tạo SharePoint Navigation cho environment: $Environment" -ForegroundColor Green
Write-Host "[nav] SharePoint Site: $siteUrl" -ForegroundColor Cyan

# Normalize ListsPath to absolute path (repo-root relative if necessary)
try {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
} catch { $repoRoot = (Get-Location).Path }
if (-not (Test-Path -LiteralPath $ListsPath)) {
    $candidate = Join-Path $repoRoot $ListsPath
    if (Test-Path -LiteralPath $candidate) { $ListsPath = $candidate }
}
Write-Host "[nav] ListsPath: $ListsPath" -ForegroundColor Cyan

# Kết nối SharePoint (ưu tiên helper pnp-session để tái sử dụng phiên)
try {
    Write-Host "[nav] Đang kết nối đến SharePoint..." -ForegroundColor Cyan
    $__pnpHelper = Join-Path $PSScriptRoot 'pnp-session.ps1'
    if (Test-Path $__pnpHelper) { . $__pnpHelper }
    if (Get-Command -Name Get-IdopPnPConnection -ErrorAction SilentlyContinue) {
    $fallbackAuth = if ($env:IDOP_SP_AUTH_MODE -and $env:IDOP_SP_AUTH_MODE.Trim()) { $env:IDOP_SP_AUTH_MODE } else { 'Delegated' }
    $mode = if ($Auth -eq 'DeviceLogin') { 'Delegated' } elseif ($Auth -eq 'Interactive') { 'Delegated' } else { $fallbackAuth }
        $null = Get-IdopPnPConnection -Url $siteUrl -Auth $mode -SetDefault
    } else {
        Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
    }
    Write-Host "[nav] Kết nối thành công." -ForegroundColor Green
}
catch {
    Write-Host "[nav] KẾT NỐI THẤT BẠI: $($_.Exception.Message)" -ForegroundColor Red
    exit 2
}

function Get-ListsByModule {
    param([string]$root)
    $map = @{}
    # Icons removed for cross-shell compatibility
    $folderToModule = @{
        'cash_data'        = @{ Name = 'Cash Data';        Icon = '' }
        'people_assets'    = @{ Name = 'People Assets';    Icon = '' }
        'performance_okrs' = @{ Name = 'Performance OKRs'; Icon = '' }
        'process_execution'= @{ Name = 'Process Execution';Icon = '' }
        'system_governance'= @{ Name = 'System Governance';Icon = '' }
        'strategy_crm'     = @{ Name = 'Strategy CRM';     Icon = '' }
    }
    foreach ($kv in $folderToModule.GetEnumerator()) {
        $sub = Join-Path $root $kv.Key
        if (-not (Test-Path -LiteralPath $sub)) { continue }
        $jsonFiles = Get-ChildItem -Path $sub -Filter *.json -File -Recurse
        $lists = @()
        foreach ($f in $jsonFiles) {
            try { $obj = Get-Content -Raw -Path $f.FullName | ConvertFrom-Json } catch { continue }
            if ($obj.ListName) { $lists += $obj.ListName }
        }
        $lists = $lists | Sort-Object -Unique
        $map[$kv.Value.Name] = @{ Icon = $kv.Value.Icon; Lists = $lists }
    }
    return $map
}

# Build modules dynamically from datamodel folder
try {
    $modules = Get-ListsByModule -root $ListsPath
} catch {
    Write-Host "⚠️ Auto-discovery failed, falling back to built-in mapping" -ForegroundColor Yellow
    $modules = @{}
}

Write-Host "[nav] Tìm thấy $($modules.Keys.Count) modules với tổng cộng $(($modules.Values | ForEach-Object { $_.Lists.Count } | Measure-Object -Sum).Sum) lists" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "[nav] DRY-RUN - Hiển thị structure sẽ được tạo" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($moduleName in $modules.Keys) {
        $module = $modules[$moduleName]
    Write-Host "[Module] $moduleName ($($module.Lists.Count) lists)" -ForegroundColor Green
        foreach ($listName in $module.Lists) {
            Write-Host "  ├─ $listName" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    Write-Host "[nav] DRY-RUN completed - no actual changes made" -ForegroundColor Yellow
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
    Write-Host "[nav] Tạo navigation cho module: $ModuleName..." -ForegroundColor Yellow
        
        # Tạo navigation node cho module (không cần landing page), bảo đảm đặt dưới Home
        $existing = Get-PnPNavigationNode -Location QuickLaunch | Where-Object { $_.Title -eq "$ModuleName" }
        if ($existing) {
            $moduleNode = $existing | Select-Object -First 1
            Write-Host "  [nav] Using existing module node: $($moduleNode.Title)" -ForegroundColor DarkGray
        } else {
            $moduleNode = Add-PnPNavigationNode -Location "QuickLaunch" -Title "$ModuleName" -Url "#"
            Write-Host "  [nav] Created module node: $($moduleNode.Title)" -ForegroundColor Green
        }
        Write-Host "  [nav] Module node ready: $($moduleNode.Title)" -ForegroundColor Green
        
        # Thêm các lists vào module
        $addedLists = 0
        foreach ($listName in $ModuleConfig.Lists) {
            # Kiểm tra list có tồn tại không
            $list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
            if ($list) {
                # Sử dụng DefaultViewUrl từ list object
                $listUrl = $list.DefaultViewUrl
                $existingChild = Get-PnPNavigationNode -Location QuickLaunch | Where-Object { $_.ParentId -eq $moduleNode.Id -and $_.Title -eq $listName }
                if (-not $existingChild) {
                    Add-PnPNavigationNode -Location "QuickLaunch" -Title $listName -Url $listUrl -Parent $moduleNode.Id | Out-Null
                    Write-Host "    [+] Added list: $listName" -ForegroundColor DarkGray
                    $addedLists++
                } else {
                    Write-Host "    [=] Skipped (exists): $listName" -ForegroundColor DarkGray
                }
            } else {
                Write-Host "    [warn] List not found: $listName" -ForegroundColor Yellow
            }
        }
        
        Write-Host "  [nav] Module completed: $addedLists/$($ModuleConfig.Lists.Count) lists added" -ForegroundColor Cyan
        return @{
            ModuleName = $ModuleName
            Node = $moduleNode
            ListsAdded = $addedLists
            TotalLists = $ModuleConfig.Lists.Count
        }
    }
    catch {
        Write-Host "  [nav] Lỗi tạo module $ModuleName`: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Xóa navigation cũ (optional - để tránh duplicate)
Write-Host "[nav] Xóa navigation nodes cũ (IDOP modules)..." -ForegroundColor Cyan
try {
    $existingNodes = Get-PnPNavigationNode -Location QuickLaunch | Where-Object { 
        $_.Title -match "Cash Data|People Assets|Performance OKRs|Process Execution|System Governance|Strategy CRM" 
    }
    foreach ($node in $existingNodes) {
        Remove-PnPNavigationNode -Identity $node.Id -Force
        Write-Host "  [-] Removed: $($node.Title)" -ForegroundColor DarkGray
    }
} catch {
    Write-Host "  [warn] Không thể xóa navigation cũ: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Tạo navigation cho từng module
Write-Host "[nav] Bắt đầu tạo navigation structure..." -ForegroundColor Yellow
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
Write-Host "[nav] Modules created: $($results.Count)/$($modules.Keys.Count)" -ForegroundColor Cyan

$totalListsAdded = ($results | Measure-Object -Property ListsAdded -Sum).Sum
$totalListsExpected = ($results | Measure-Object -Property TotalLists -Sum).Sum

Write-Host "[nav] Lists added to navigation: $totalListsAdded/$totalListsExpected" -ForegroundColor Cyan

if ($totalListsAdded -eq $totalListsExpected) {
    Write-Host "[nav] Navigation structure created successfully." -ForegroundColor Green
} else {
    Write-Host "[nav] Some lists were not added to navigation. Check warnings above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[nav] Next Steps:" -ForegroundColor Cyan
Write-Host "1. Visit $siteUrl to see the new navigation" -ForegroundColor White
Write-Host "2. Create landing pages for each module (optional)" -ForegroundColor White
Write-Host "3. Add descriptions và icons to enhance UX" -ForegroundColor White

Write-Host ""
Write-Host "[nav] Navigation creation completed." -ForegroundColor Green