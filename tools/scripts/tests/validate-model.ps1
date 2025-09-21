<#
.SYNOPSIS
    Validate all SharePoint list JSON models for schema, field count, drift, and summary.
.DESCRIPTION
    Iterates all JSON files in datamodel/sharepoint/lists, checks:
      - JSON parse validity
      - Required properties (ListName, Columns)
      - Field count, lookup count, managed metadata count
      - Detects duplicate field names
      - Prints summary table (list, field count, lookup count, MM count, warnings)
      - Optionally: runs -Diff mode (if deploy module present) to detect drift
#>

param(
    [switch]$Diff
)

$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '../..')
$listsPath = Join-Path $root 'datamodel/sharepoint/lists'

$files = Get-ChildItem -Path $listsPath -Recurse -Filter *.json

$summary = @()
$hasError = $false

foreach ($file in $files) {
    $warns = @()
    try {
        $json = Get-Content $file.FullName -Raw | ConvertFrom-Json
    } catch {
        Write-Host "❌ JSON parse error: $($file.FullName)" -ForegroundColor Red
        $hasError = $true
        continue
    }
    if (-not $json.ListName -or -not $json.Columns) {
        Write-Host "❌ Missing ListName or Columns: $($file.FullName)" -ForegroundColor Red
        $hasError = $true
        continue
    }
    $fieldCount = $json.Columns.Count
    $lookupCount = ($json.Columns | Where-Object { $_.Type -eq 'Lookup' }).Count
    $mmCount = ($json.Columns | Where-Object { $_.Type -eq 'ManagedMetadata' }).Count
    $dupes = $json.Columns | Group-Object Name | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
    if ($dupes) { $warns += "Duplicate fields: $($dupes -join ', ')" }
    if ($lookupCount -gt 8) { $warns += "Lookup > 8 ($lookupCount)" }
    if ($fieldCount -gt 28) { $warns += "Fields > 28 ($fieldCount)" }
    $summary += [PSCustomObject]@{
        List = $json.ListName
        Fields = $fieldCount
        Lookup = $lookupCount
        MM = $mmCount
        Warnings = ($warns -join '; ')
    }
    if ($Diff) {
        try {
            Import-Module (Join-Path $root 'tools/scripts/modules/SpListDeploy.psm1') -ErrorAction SilentlyContinue
            $null = New-EnhancedSharePointList -JsonPath $file.FullName -Diff -DryRun
        } catch {
            Write-Host "⚠️ Diff check failed for $($json.ListName): $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host "\n=== MODEL VALIDATION SUMMARY ===" -ForegroundColor Yellow
$summary | Format-Table -AutoSize

if ($hasError) {
    Write-Host "❌ Model validation FAILED. See errors above." -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ Model validation PASSED for all $($summary.Count) lists" -ForegroundColor Green
}
