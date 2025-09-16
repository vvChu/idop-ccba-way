param(
    [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",
    [switch]$DryRun
)

Import-Module PnP.PowerShell -ErrorAction Stop

# --- KHỐI LỆNH KẾT NỐI CHUẨN CỦA CCBA ---
$siteUrl = "https://ibstbim-admin.sharepoint.com"
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$tenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"

try {
    Write-Host "Đang kết nối đến trang SharePoint Admin của CCBA..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $tenantId -DeviceLogin
    Write-Host "Kết nối thành công đến: $($siteUrl)" -ForegroundColor Green
} catch {
    Write-Host "KẾT NỐI THẤT BẠI. Vui lòng kiểm tra lại." -ForegroundColor Red
    throw $_
}

$groupName = "CCBA Taxonomy"
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
    
    # Tạo object cơ bản
    $setObj = [PSCustomObject]@{
        Name = $set.Name
        Id = $set.Id.ToString()
        Description = if($set.Description) { $set.Description } else { "" }
        Terms = @()
    }
    
    try {
        # Dùng phương pháp khác để lấy tất cả terms trong termset (bao gồm cả child terms)
        Write-Host "  Retrieving all terms including child terms..." -ForegroundColor DarkGray
        
        # Lấy tất cả terms bằng cách dùng -Recursive (nếu có) hoặc lấy từng level
        $allTermsInSet = Get-PnPTerm -TermSet $set.Id -TermGroup $groupName -Includes "Parent,TermsCount"
        
        # Function để xây dựng cây phân cấp
        function Build-TermTree($terms) {
            $termTree = @()
            $termLookup = @{}
            
            # Tạo lookup table cho tất cả terms
            foreach ($term in $terms) {
                $termObj = [PSCustomObject]@{
                    Name = $term.Name
                    Id = $term.Id.ToString()
                    Description = if($term.Description) { $term.Description } else { "" }
                    Level = if($term.PathOfTerm) { ($term.PathOfTerm -split ';').Count - 1 } else { 0 }
                    Path = if($term.PathOfTerm) { $term.PathOfTerm } else { $term.Name }
                    ParentId = if($term.Parent) { $term.Parent.Id.ToString() } else { $null }
                    ChildTerms = @()
                }
                $termLookup[$term.Id.ToString()] = $termObj
            }
            
            # Xây dựng cây phân cấp
            foreach ($termId in $termLookup.Keys) {
                $term = $termLookup[$termId]
                if ($term.ParentId -and $termLookup.ContainsKey($term.ParentId)) {
                    # Term này là con của term khác
                    $termLookup[$term.ParentId].ChildTerms += $term
                } else {
                    # Term này là root level
                    $termTree += $term
                }
            }
            
            return $termTree
        }
        
        $setObj.Terms = Build-TermTree $allTermsInSet
        $totalTermsCount = ($allTermsInSet | Measure-Object).Count
        Write-Host "  Found $($setObj.Terms.Count) root terms, $totalTermsCount total terms" -ForegroundColor Gray
    }
    catch {
        Write-Warning "  Could not retrieve hierarchical structure for $($set.Name): $($_.Exception.Message)"
        # Fallback to simple term list
        try {
            $terms = Get-PnPTerm -TermSet $set.Id -TermGroup $groupName
            foreach ($term in $terms) {
                $termObj = [PSCustomObject]@{
                    Name = $term.Name
                    Id = $term.Id.ToString()
                    Description = if($term.Description) { $term.Description } else { "" }
                    Level = 0
                    Path = $term.Name
                    ChildTerms = @()
                }
                $setObj.Terms += $termObj
            }
        } catch {
            Write-Warning "  Could not retrieve any terms for $($set.Name)"
        }
    }
    
    $outFile = Join-Path $fullTaxonomyPath "$($set.Name).json"
    if ($DryRun) {
        Write-Host "[DryRun] Would export to $outFile" -ForegroundColor Magenta
    } else {
        try {
            $setObj | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $outFile
            Write-Host "Exported to $outFile" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to export $($set.Name): $($_.Exception.Message)"
        }
    }
}

Write-Host "Export hoàn tất!" -ForegroundColor Green