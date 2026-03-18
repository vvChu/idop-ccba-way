# Debug Script để kiểm tra cấu trúc Term
# CCBA WAY Project - Debug taxonomy hierarchy

# Cấu hình connection
$AdminUrl = "https://ibstbim-admin.sharepoint.com"
$ClientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
param([ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached')

Write-Host "Đang kết nối đến SharePoint Admin..."
# Auth helper
$authModule = Join-Path $PSScriptRoot 'modules/SpAuth.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
    Connect-IdopOnline -SiteUrl $AdminUrl -AuthMode $Auth -ClientId $ClientId
} else {
    Connect-PnPOnline -Url $AdminUrl -Interactive -ClientId $ClientId
}

# Lấy một term set có nhiều khả năng có hierarchy
$termGroup = Get-PnPTermGroup -Identity "CCBA Taxonomy"
$termSet = Get-PnPTermSet -Identity "CCBA_TrangThaiChung" -TermGroup "CCBA Taxonomy" -Includes Terms

Write-Host "=== DEBUGGING TERM SET: $($termSet.Name) ===" -ForegroundColor Yellow
Write-Host "Total terms in set: $($termSet.Terms.Count)" -ForegroundColor Green

foreach ($term in $termSet.Terms) {
    Write-Host "`n--- TERM: $($term.Name) ---" -ForegroundColor Cyan
    Write-Host "  ID: $($term.Id)"
    Write-Host "  IsRoot: $($term.IsRoot)"
    Write-Host "  PathOfTerm: '$($term.PathOfTerm)'"
    Write-Host "  TermsCount: $($term.TermsCount)"
    
    # Thử lấy child terms trực tiếp
    try {
        $childTerms = Get-PnPTerm -TermSet "CCBA_TrangThaiChung" -TermGroup "CCBA Taxonomy" -Identity $term.Id -Includes Terms -ErrorAction Stop
        if ($childTerms.Terms) {
            Write-Host "  HAS CHILDREN: $($childTerms.Terms.Count)" -ForegroundColor Green
            foreach ($child in $childTerms.Terms) {
                Write-Host "    Child: $($child.Name) (Path: '$($child.PathOfTerm)')" -ForegroundColor Magenta
            }
        } else {
            Write-Host "  NO CHILDREN" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ERROR getting children: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Thử với term set khác có thể có hierarchy
Write-Host "`n`n=== TRYING ANOTHER TERM SET ===" -ForegroundColor Yellow
$termSet2 = Get-PnPTermSet -Identity "CCBA_DonViPhongBan" -TermGroup "CCBA Taxonomy" -Includes Terms
Write-Host "Term Set: $($termSet2.Name)" -ForegroundColor Green
Write-Host "Total terms: $($termSet2.Terms.Count)" -ForegroundColor Green

foreach ($term in $termSet2.Terms | Select-Object -First 2) {
    Write-Host "`n--- TERM: $($term.Name) ---" -ForegroundColor Cyan
    Write-Host "  PathOfTerm: '$($term.PathOfTerm)'"
    Write-Host "  TermsCount: $($term.TermsCount)"
    
    try {
        $childTerms = Get-PnPTerm -TermSet "CCBA_DonViPhongBan" -TermGroup "CCBA Taxonomy" -Identity $term.Id -Includes Terms -ErrorAction Stop
        if ($childTerms.Terms) {
            Write-Host "  HAS CHILDREN: $($childTerms.Terms.Count)" -ForegroundColor Green
            foreach ($child in $childTerms.Terms) {
                Write-Host "    Child: $($child.Name) (Path: '$($child.PathOfTerm)')" -ForegroundColor Magenta
            }
        } else {
            Write-Host "  NO CHILDREN" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Disconnect-PnPOnline