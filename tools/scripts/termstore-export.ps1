param(
  [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",
  [string]$ClientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63", # Client ID đã đăng ký cho PnP
  [string]$TenantId = "",
  [switch]$DryRun
)


param(
  [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",
  [switch]$DryRun
)


# ---
# IDOP-CCBA Termstore Export Script
# Requires Azure AD App Registration with TermStore.Read.All permissions.
# Usage:
#   pwsh -ExecutionPolicy Bypass -File .\tools\scripts\termstore-export.ps1 -ClientId <clientId> -TenantId <tenantId>
# See: https://pnp.github.io/powershell/articles/authentication.html
# ---

Import-Module PnP.PowerShell -ErrorAction Stop

# --- KHỐI LỆNH KẾT NỐI CHUẨN CỦA CCBA ---

# 1. Định nghĩa các biến kết nối
$siteUrl = "https://ibstbim-admin.sharepoint.com"
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$tenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3" # Tenant ID của IBST BIM


# 2. Thực hiện kết nối
try {
    Write-Host "Đang kết nối đến trang SharePoint Admin của CCBA..." -ForegroundColor Cyan
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Tenant $tenantId -DeviceLogin
    Write-Host "Kết nối thành công đến: $($siteUrl)" -ForegroundColor Green
}
catch {
    Write-Host "KẾT NỐI THẤT BẠI. Vui lòng kiểm tra lại." -ForegroundColor Red
    throw $_
}

$groupName = "CCBA Taxonomy"

# Kiểm tra các term groups có sẵn nếu không tìm thấy CCBA_Taxonomy
Write-Host "Đang kiểm tra các term groups có sẵn..." -ForegroundColor Yellow
$allGroups = Get-PnPTermGroup
Write-Host "Các term groups tìm thấy:" -ForegroundColor Cyan
$allGroups | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }

$group = Get-PnPTermGroup -Identity $groupName -ErrorAction SilentlyContinue
if (-not $group) {
    Write-Warning "Term group '$groupName' không tồn tại. Vui lòng kiểm tra danh sách trên và cập nhật tên group phù hợp."
    exit 1
}$sets = Get-PnPTermSet -TermGroup $groupName
foreach ($set in $sets) {
  Write-Host "Exporting term set: $($set.Name)" -ForegroundColor Yellow
  $terms = Get-PnPTerm -TermSet $set.Id -TermGroup $groupName
  $termList = @()
  foreach ($term in $terms) {
    $termList += [PSCustomObject]@{
      Name = $term.Name
      Id = $term.Id
      Description = $term.Description
      Language = $term.Language
      Labels = $term.Labels
      CustomSortOrder = $term.CustomSortOrder
      IsAvailableForTagging = $term.IsAvailableForTagging
      Path = $term.Path
    }
  }
  $setObj = [PSCustomObject]@{
    Name = $set.Name
    Id = $set.Id
    Description = $set.Description
    Owner = $set.Owner
    Language = $set.Language
    Terms = $termList
  }
  $outFile = Join-Path $TaxonomyPath "$($set.Name).json"
  if ($DryRun) {
    Write-Host "[DryRun] Would export to $outFile" -ForegroundColor Magenta
  } else {
    # Tạo thư mục nếu chưa tồn tại
    if (!(Test-Path (Split-Path $outFile))) {
      New-Item -ItemType Directory -Force -Path (Split-Path $outFile) | Out-Null
    }
    $setObj | ConvertTo-Json -Depth 5 | Out-File -Encoding UTF8 $outFile
    Write-Host "Exported to $outFile" -ForegroundColor Green
  }
}