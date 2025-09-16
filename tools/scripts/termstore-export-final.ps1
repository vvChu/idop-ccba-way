# Termstore Export Script - Complete Hierarchical Export
# CCBA WAY Project - Export taxonomy from SharePoint to JSON
# Phiên bản: 3.0 - Hierarchical Support với đệ quy

# Cấu hình connection
$AdminUrl = "https://ibstbim-admin.sharepoint.com"
$ClientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
$RedirectUri = "http://localhost"
$ExportFolder = "datamodel\sharepoint\taxonomy"

# Function để xử lý đệ quy Term và Children
function Get-TermHierarchy {
    param(
        [Parameter(Mandatory = $true)]
        $Term,
        
        [Parameter(Mandatory = $true)]
        $TermSet
    )
    
    try {
        # Lấy thông tin cơ bản của term
        $termObject = [PSCustomObject]@{
            Id = $Term.Id.ToString()
            Name = $Term.Name
            IsRoot = $Term.IsRoot
            PathOfTerm = $Term.PathOfTerm
            IsAvailableForTagging = $Term.IsAvailableForTagging
            CustomProperties = $Term.CustomProperties
            Children = @()
        }
        
        # Kiểm tra và lấy child terms nếu có
        Write-Host "    Checking for child terms of: $($Term.Name)"
        
        # Phương pháp 1: Sử dụng Get-PnPTermSet với recursive
        try {
            $allTermsInSet = Get-PnPTermSet -Identity $TermSet.Name -TermGroup "CCBA Taxonomy" -Includes Terms
            $childTerms = @()
            
            foreach ($t in $allTermsInSet.Terms) {
                if ($t.PathOfTerm -like "$($Term.PathOfTerm);*" -and $t.PathOfTerm -ne $Term.PathOfTerm) {
                    # Đây là child term
                    $pathDepth = ($t.PathOfTerm -split ";").Count
                    $parentPathDepth = ($Term.PathOfTerm -split ";").Count
                    
                    if ($pathDepth -eq ($parentPathDepth + 1)) {
                        # Direct child
                        $childTerms += $t
                        Write-Host "      Found direct child: $($t.Name)"
                    }
                }
            }
            
            # Xử lý đệ quy cho từng child term
            foreach ($childTerm in $childTerms) {
                $childObject = Get-TermHierarchy -Term $childTerm -TermSet $TermSet
                $termObject.Children += $childObject
            }
            
        } catch {
            Write-Warning "    Could not retrieve children for $($Term.Name): $($_.Exception.Message)"
        }
        
        return $termObject
        
    } catch {
        Write-Warning "Error processing term $($Term.Name): $($_.Exception.Message)"
        return $null
    }
}

# Main script
Write-Host "Đang kết nối đến trang SharePoint Admin của CCBA..."

try {
    Connect-PnPOnline -Url $AdminUrl -Interactive -ClientId $ClientId
    Write-Host "Kết nối thành công đến: $AdminUrl"
    
    # Tạo thư mục export nếu chưa có
    if (!(Test-Path -Path $ExportFolder)) {
        New-Item -ItemType Directory -Path $ExportFolder -Force
    }
    
    # Lấy danh sách tất cả Term Sets từ group "CCBA Taxonomy"
    $termGroup = Get-PnPTermGroup -Identity "CCBA Taxonomy"
    $termSets = Get-PnPTermSet -TermGroup "CCBA Taxonomy"
    $ccbaTermSets = $termSets | Where-Object { $_.Name -like "CCBA_*" }
    
    Write-Host "Tìm thấy $($ccbaTermSets.Count) term sets"
    
    foreach ($termSet in $ccbaTermSets) {
        Write-Host "Exporting term set: $($termSet.Name)"
        
        try {
            # Lấy tất cả root terms trong term set
            $termSetWithTerms = Get-PnPTermSet -Identity $termSet.Name -TermGroup "CCBA Taxonomy" -Includes Terms
            $rootTerms = $termSetWithTerms.Terms | Where-Object { $_.IsRoot -eq $true }
            
            Write-Host "  Found $($rootTerms.Count) root terms"
            
            $exportData = [PSCustomObject]@{
                TermSetInfo = [PSCustomObject]@{
                    Name = $termSet.Name
                    Id = $termSet.Id.ToString()
                    Description = $termSet.Description
                    CreatedDate = $termSet.CreatedDate
                    LastModifiedDate = $termSet.LastModifiedDate
                    IsOpenForTermCreation = $termSet.IsOpenForTermCreation
                    Contact = $termSet.Contact
                    Owner = $termSet.Owner
                }
                Terms = @()
                Statistics = [PSCustomObject]@{
                    TotalRootTerms = 0
                    TotalTermsWithChildren = 0
                    MaxDepth = 0
                    ExportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }
            }
            
            # Xử lý từng root term với đệ quy
            foreach ($rootTerm in $rootTerms) {
                Write-Host "  Processing root term: $($rootTerm.Name)"
                $termHierarchy = Get-TermHierarchy -Term $rootTerm -TermSet $termSet
                if ($termHierarchy) {
                    $exportData.Terms += $termHierarchy
                }
            }
            
            # Cập nhật statistics
            $exportData.Statistics.TotalRootTerms = $rootTerms.Count
            
            # Export to JSON file
            $fileName = "$($termSet.Name).json"
            $filePath = Join-Path -Path $ExportFolder -ChildPath $fileName
            $exportData | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Encoding UTF8
            
            Write-Host "  Exported to $filePath"
            
        } catch {
            Write-Error "Lỗi khi export term set $($termSet.Name): $($_.Exception.Message)"
        }
    }
    
    Write-Host "Export hoàn tất!"
    
} catch {
    Write-Error "Lỗi kết nối: $($_.Exception.Message)"
}

# Disconnect
Disconnect-PnPOnline