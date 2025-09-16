# Termstore Export Script - Working Hierarchical Export
# CCBA WAY Project - Export taxonomy from SharePoint to JSON
# Phiên bản: 4.0 - Fixed Hierarchical Support

# Cấu hình connection
$AdminUrl = "https://ibstbim-admin.sharepoint.com"
$ClientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$ExportFolder = "datamodel\sharepoint\taxonomy"

# Function để xử lý đệ quy Term và Children
function Get-TermHierarchy {
    param(
        [Parameter(Mandatory = $true)]
        $Term,
        
        [Parameter(Mandatory = $true)]
        [string]$TermSetName,
        
        [Parameter(Mandatory = $true)]
        [string]$TermGroupName
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
        
        # Lấy child terms trực tiếp bằng Get-PnPTerm với Includes Terms
        if ($Term.TermsCount -gt 0) {
            Write-Host "      Found $($Term.TermsCount) child terms for: $($Term.Name)" -ForegroundColor Green
            
            try {
                $termWithChildren = Get-PnPTerm -TermSet $TermSetName -TermGroup $TermGroupName -Identity $Term.Id -Includes Terms
                
                if ($termWithChildren.Terms) {
                    foreach ($childTerm in $termWithChildren.Terms) {
                        Write-Host "        Processing child: $($childTerm.Name)"
                        $childObject = Get-TermHierarchy -Term $childTerm -TermSetName $TermSetName -TermGroupName $TermGroupName
                        if ($childObject) {
                            $termObject.Children += $childObject
                        }
                    }
                }
            } catch {
                Write-Warning "        Could not retrieve children for $($Term.Name): $($_.Exception.Message)"
            }
        } else {
            Write-Host "      No child terms for: $($Term.Name)" -ForegroundColor Gray
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
    $termGroupName = "CCBA Taxonomy"
    $termGroup = Get-PnPTermGroup -Identity $termGroupName
    $termSets = Get-PnPTermSet -TermGroup $termGroupName
    $ccbaTermSets = $termSets | Where-Object { $_.Name -like "CCBA_*" }
    
    Write-Host "Tìm thấy $($ccbaTermSets.Count) term sets"
    
    # Export tất cả CCBA term sets
    foreach ($termSet in $ccbaTermSets) {
        Write-Host "`nExporting term set: $($termSet.Name)" -ForegroundColor Yellow
        
        try {
            # Lấy tất cả root terms trong term set
            $termSetWithTerms = Get-PnPTermSet -Identity $termSet.Name -TermGroup $termGroupName -Includes Terms
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
                Write-Host "    Processing root term: $($rootTerm.Name)" -ForegroundColor Cyan
                $termHierarchy = Get-TermHierarchy -Term $rootTerm -TermSetName $termSet.Name -TermGroupName $termGroupName
                if ($termHierarchy) {
                    $exportData.Terms += $termHierarchy
                }
            }
            
            # Cập nhật statistics
            $exportData.Statistics.TotalRootTerms = $rootTerms.Count
            $termsWithChildren = $exportData.Terms | Where-Object { $_.Children.Count -gt 0 }
            $exportData.Statistics.TotalTermsWithChildren = $termsWithChildren.Count
            
            # Export to JSON file
            $fileName = "$($termSet.Name).json"
            $filePath = Join-Path -Path $ExportFolder -ChildPath $fileName
            $exportData | ConvertTo-Json -Depth 10 | Set-Content -Path $filePath -Encoding UTF8
            
            Write-Host "    Exported to $filePath" -ForegroundColor Green
            
        } catch {
            Write-Error "Lỗi khi export term set $($termSet.Name): $($_.Exception.Message)"
        }
    }
    
    Write-Host "`nExport hoàn tất!" -ForegroundColor Green
    
} catch {
    Write-Error "Lỗi kết nối: $($_.Exception.Message)"
}

# Disconnect
Disconnect-PnPOnline