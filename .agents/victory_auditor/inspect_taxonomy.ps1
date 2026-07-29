Import-Module "./tools/scripts/modules/ValidationHelpers.psm1" -Force

$files = Get-ChildItem -Path "datamodel/sharepoint/taxonomy/*.json"
$list = foreach ($f in $files) {
    $j = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $val = Test-IDOPTaxonomyJson -JsonPath $f.FullName
    [PSCustomObject]@{
        File  = $f.Name
        Name  = $j.TermSetInfo.Name
        Id    = $j.TermSetInfo.Id
        Valid = $val.Valid
        ErrorCount = $val.Errors.Count
        Errors = ($val.Errors -join "; ")
    }
}
$list | Format-Table -AutoSize
