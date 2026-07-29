$lists = Get-ChildItem -Path "datamodel/sharepoint/lists" -Filter "*.json" -Recurse
$taxonomy = Get-ChildItem -Path "datamodel/sharepoint/taxonomy" -Filter "*.json"

$listMap = @{}
foreach ($l in $lists) {
    $j = Get-Content $l.FullName -Raw | ConvertFrom-Json
    $listMap[$j.ListName] = $j
}

$taxMap = @{}
foreach ($t in $taxonomy) {
    $j = Get-Content $t.FullName -Raw | ConvertFrom-Json
    $taxMap[$j.TermSetInfo.Name] = $j
}

Write-Host "Total Lists Found: $($listMap.Count)"
Write-Host "Total Taxonomy Term Sets Found: $($taxMap.Count)"

$lookupIssues = @()
$taxIssues = @()

foreach ($listName in $listMap.Keys) {
    $list = $listMap[$listName]
    foreach ($col in $list.Columns) {
        if ($col.Type -eq 'Lookup' -or $col.Type -eq 'LookupMulti') {
            $targetList = $col.Lookup.List
            if (-not $targetList) {
                $lookupIssues += "List [$listName] Column [$($col.Name)] missing Lookup.List"
            } elseif (-not $listMap.ContainsKey($targetList)) {
                $lookupIssues += "List [$listName] Column [$($col.Name)] references non-existent list [$targetList]"
            }
        }
        if ($col.Type -eq 'ManagedMetadata' -or $col.Type -eq 'Taxonomy') {
            $termSetName = $col.TermSet.Name
            if (-not $termSetName) {
                $taxIssues += "List [$listName] Column [$($col.Name)] missing TermSet.Name"
            } elseif (-not $taxMap.ContainsKey($termSetName)) {
                $taxIssues += "List [$listName] Column [$($col.Name)] references non-existent TermSet [$termSetName]"
            }
        }
    }
}

Write-Host "`n--- LOOKUP ISSUES ---"
if ($lookupIssues.Count -eq 0) { Write-Host "None (100% Lookup target lists exist!)" }
else { $lookupIssues | ForEach-Object { Write-Host " - $_" } }

Write-Host "`n--- TAXONOMY TERM SET REFERENCE ISSUES ---"
if ($taxIssues.Count -eq 0) { Write-Host "None (100% TermSet names exist!)" }
else { $taxIssues | ForEach-Object { Write-Host " - $_" } }
