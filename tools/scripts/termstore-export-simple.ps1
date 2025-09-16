param(
    [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",
    [switch]$DryRun
)

Import-Module PnP.PowerShell -ErrorAction Stop

# --- KHỐI LỆNH KẾT NỐI CHUẨN CỦA CCBA ---
# 1. Định nghĩa các biến kết nối
$siteUrl = "https://ibstbim-admin.sharepoint.com"
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$tenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"

# 2. Thực hiện kết nối
try {
    Write-Host "Đang kết nối đến trang SharePoint Admin của CCBA..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $tenantId -DeviceLogin
    Write-Host "Kết nối thành công đến: $($siteUrl)" -ForegroundColor Green
} catch {
    Write-Host "KẾT NỐI THẤT BẠI. Vui lòng kiểm tra lại." -ForegroundColor Red
    throw $_
}

$groupName = "CCBA Taxonomy"

# Tạo thư mục nếu chưa tồn tại
$fullTaxonomyPath = Join-Path (Get-Location) $TaxonomyPath
if (!(Test-Path $fullTaxonomyPath)) {
    New-Item -ItemType Directory -Force -Path $fullTaxonomyPath | Out-Null
}

$group = Get-PnPTermGroup -Identity $groupName -ErrorAction SilentlyContinue
if (-not $group) {
    Write-Error "Term group '$groupName' not found."
    exit 1
}

$sets = Get-PnPTermSet -TermGroup $groupName
Write-Host "Tìm thấy $($sets.Count) term sets" -ForegroundColor Green

foreach ($set in $sets) {
    Write-Host "Exporting term set: $($set.Name)" -ForegroundColor Yellow
    
    # Tạo một object đơn giản trước
    $setObj = [PSCustomObject]@{
        Name = $set.Name
        Id = $set.Id.ToString()
        Description = if($set.Description) { $set.Description } else { "" }
        Terms = @()
    }
    
    # Lấy terms với cấu trúc phân cấp (recursive)
    try {
        $terms = Get-PnPTerm -TermSet $set.Id -TermGroup $groupName -Includes "Terms"
        
        function Get-TermHierarchy($term) {
            $termObj = [PSCustomObject]@{
                Name = $term.Name
                Id = $term.Id.ToString()
                Description = if($term.Description) { $term.Description } else { "" }
                Level = if($term.PathOfTerm) { ($term.PathOfTerm.Split(';')).Count - 1 } else { 0 }
                Path = if($term.PathOfTerm) { $term.PathOfTerm } else { $term.Name }
                ChildTerms = @()
            }
            
            # Lấy các sub-terms nếu có
            try {
                $childTerms = Get-PnPTerm -TermSet $set.Id -TermGroup $groupName -Term $term.Id -Includes "Terms"
                foreach ($childTerm in $childTerms) {
                    $termObj.ChildTerms += Get-TermHierarchy $childTerm
                }
            } catch {
                # Không có child terms hoặc lỗi access
                Write-Host "    No child terms for $($term.Name)" -ForegroundColor DarkGray
            }
            
            return $termObj
        }
        
        foreach ($term in $terms) {
            $setObj.Terms += Get-TermHierarchy $term
        }
        Write-Host "  Found $($setObj.Terms.Count) root terms (with hierarchical structure)" -ForegroundColor Gray
    }
    catch {
        Write-Warning "  Could not retrieve terms for $($set.Name): $($_.Exception.Message)"
        $setObj.Terms = @()
    }
    
    $outFile = Join-Path $fullTaxonomyPath "$($set.Name).json"
    if ($DryRun) {
        Write-Host "[DryRun] Would export to $outFile" -ForegroundColor Magenta
    } else {
        try {
            $setObj | ConvertTo-Json -Depth 5 | Out-File -Encoding UTF8 $outFile
            Write-Host "Exported to $outFile" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to export $($set.Name): $($_.Exception.Message)"
        }
    }
}

Write-Host "Export hoàn tất!" -ForegroundColor Green