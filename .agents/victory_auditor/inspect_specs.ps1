$specs = Get-ChildItem -Path "specs/modules" -Recurse -Filter "spec.md"
Write-Host "Total spec.md files found: $($specs.Count)"
Write-Host "--------------------------------------------------------------------------------"

$allValid = $true
foreach ($spec in $specs) {
    $content = Get-Content -Path $spec.FullName -Raw
    $hasS1 = $content -match '1\.\s+(Mục tiêu|Goal)'
    $hasS2 = $content -match '2\.\s+(User Stories|Ma trận|Role)'
    $hasS3 = $content -match '3\.\s+(Cơ sở|Legal)'
    $hasS4 = $content -match '4\.\s+(Quy trình|Operational)'
    $hasS5 = $content -match '5\.\s+(Acceptance|List)'
    $hasS6 = $content -match '6\.\s+(Bảo mật|Security)'
    $hasQCTK = $content -match '2815'
    $hasQCCTNB = $content -match '3209'
    $hasCCBA2026 = $content -match '2026'
    $hasEllipsis = $content -match '\.\.\.'

    $rel = $spec.FullName.Replace('d:\idop-ccba-way\', '')
    $lineCount = ($content -split "\r?\n").Count
    
    $valid = $hasS1 -and $hasS2 -and $hasS3 -and $hasS4 -and $hasS5 -and $hasS6 -and (-not $hasEllipsis)
    if (-not $valid) { $allValid = $false }

    Write-Host ("{0,-55} | Lines: {1,4} | S1-6: {2}{3}{4}{5}{6}{7} | QCTK:{8} QCCTNB:{9} | Ellipsis:{10}" -f `
        $rel, $lineCount, `
        [int]$hasS1, [int]$hasS2, [int]$hasS3, [int]$hasS4, [int]$hasS5, [int]$hasS6, `
        [int]$hasQCTK, [int]$hasQCCTNB, [int]$hasEllipsis)
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "All 21 specs valid and standard 6-part complete: $allValid"
