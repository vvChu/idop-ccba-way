#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Export taxonomy term sets from SharePoint to JSON files
.DESCRIPTION
    Consolidated termstore export script (replaces termstore-export-simple,
    termstore-export-hierarchical, termstore-export-final, termstore-export-working).
    Supports flat and hierarchical export with statistics.
.PARAMETER Environment
    Target environment (Dev, Test, Prod). Default: Dev
.PARAMETER TaxonomyPath
    Output directory for JSON files. Default: datamodel/sharepoint/taxonomy
.PARAMETER TermGroupName
    Term group to export. Default: CCBA Taxonomy
.PARAMETER Flat
    Export flat term list instead of hierarchical tree
.PARAMETER DryRun
    Preview export without writing files
.PARAMETER Filter
    Only export term sets matching this pattern (e.g. "CCBA_*")
.EXAMPLE
    .\termstore-export.ps1 -Environment Dev
.EXAMPLE
    .\termstore-export.ps1 -Environment Dev -Flat -DryRun
.EXAMPLE
    .\termstore-export.ps1 -Filter "CCBA_Trang*"
#>

#Requires -Version 7.0

param(
    [ValidateSet('Dev', 'Test', 'Prod')]
    [string]$Environment = 'Dev',

    [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",

    [string]$TermGroupName = "CCBA Taxonomy",

    [switch]$Flat,

    [switch]$DryRun,

    [string]$Filter = "*"
)

$ErrorActionPreference = 'Stop'

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force

# --- Hierarchical term tree builder ---
function Build-TermTree {
    param(
        [Parameter(Mandatory)]
        $Terms
    )

    $tree = @()
    $lookup = @{}

    foreach ($term in $Terms) {
        $obj = [PSCustomObject]@{
            Id                   = $term.Id.ToString()
            Name                 = $term.Name
            Description          = if ($term.Description) { $term.Description } else { "" }
            IsRoot               = $term.IsRoot
            PathOfTerm           = if ($term.PathOfTerm) { $term.PathOfTerm } else { $term.Name }
            IsAvailableForTagging = $term.IsAvailableForTagging
            CustomProperties     = $term.CustomProperties
            Children             = @()
        }
        $lookup[$term.Id.ToString()] = $obj
    }

    foreach ($id in $lookup.Keys) {
        $node = $lookup[$id]
        $pathParts = $node.PathOfTerm -split ';'

        if ($pathParts.Count -le 1) {
            # Root term
            $tree += $node
        }
        else {
            # Find parent by trimming last path segment
            $parentPath = ($pathParts[0..($pathParts.Count - 2)]) -join ';'
            $parent = $lookup.Values | Where-Object { $_.PathOfTerm -eq $parentPath } | Select-Object -First 1
            if ($parent) {
                $parent.Children += $node
            }
            else {
                # Orphan — treat as root
                $tree += $node
            }
        }
    }

    return $tree
}

# --- Flat term list builder ---
function Build-FlatTermList {
    param(
        [Parameter(Mandatory)]
        $Terms
    )

    $list = @()
    foreach ($term in $Terms) {
        $list += [PSCustomObject]@{
            Id                    = $term.Id.ToString()
            Name                  = $term.Name
            Description           = if ($term.Description) { $term.Description } else { "" }
            Path                  = if ($term.PathOfTerm) { $term.PathOfTerm } else { $term.Name }
            Level                 = if ($term.PathOfTerm) { ($term.PathOfTerm -split ';').Count - 1 } else { 0 }
            IsAvailableForTagging = $term.IsAvailableForTagging
        }
    }
    return $list
}

# --- Main ---
try {
    Write-IDOPHeader "Taxonomy Export"

    $config = Get-IDOPConfig -Environment $Environment
    $timer = Start-IDOPTimer -Name "Taxonomy Export"

    # Resolve output path
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
    $fullTaxonomyPath = Join-Path $repoRoot $TaxonomyPath
    if (-not (Test-Path $fullTaxonomyPath)) {
        New-Item -ItemType Directory -Force -Path $fullTaxonomyPath | Out-Null
    }

    Write-IDOPInfo "Environment : $Environment"
    Write-IDOPInfo "Output path : $fullTaxonomyPath"
    Write-IDOPInfo "Term group  : $TermGroupName"
    Write-IDOPInfo "Mode        : $(if ($Flat) { 'Flat' } else { 'Hierarchical' })"
    Write-IDOPInfo "DryRun      : $DryRun"

    # Connect (use admin URL for taxonomy access)
    $adminUrl = $config.SharePointUrl -replace '\.sharepoint\.com/.*', '-admin.sharepoint.com'
    Write-IDOPInfo "Connecting to $adminUrl ..."

    if (-not $DryRun) {
        try {
            $existing = Get-PnPConnection -ErrorAction SilentlyContinue
            if (-not $existing -or $existing.Url -ne $adminUrl) {
                Connect-PnPOnline -Url $adminUrl -Interactive -ClientId $config.ClientId
            }
            Write-IDOPSuccess "Connected to $adminUrl"
        }
        catch {
            Write-IDOPError "Connection failed: $_"
            exit 3
        }
    }

    # Get term group
    if (-not $DryRun) {
        $group = Get-PnPTermGroup -Identity $TermGroupName -ErrorAction SilentlyContinue
        if (-not $group) {
            Write-IDOPError "Term group '$TermGroupName' not found"
            Write-IDOPInfo "Available groups:"
            Get-PnPTermGroup | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
            exit 1
        }

        $allSets = Get-PnPTermSet -TermGroup $TermGroupName
        $termSets = $allSets | Where-Object { $_.Name -like $Filter }
    }
    else {
        # DryRun: scan existing JSON files to show what would be exported
        $existingFiles = Get-ChildItem -Path $fullTaxonomyPath -Filter "*.json" -ErrorAction SilentlyContinue
        Write-IDOPInfo "Found $($existingFiles.Count) existing taxonomy JSON files"
        foreach ($f in $existingFiles) {
            Write-Host "  [DryRun] Would overwrite: $($f.Name)" -ForegroundColor Magenta
        }
        Write-IDOPSuccess "DryRun complete — no files written"
        Stop-IDOPTimer -Timer $timer
        exit 0
    }

    Write-IDOPInfo "Found $($termSets.Count) term sets matching filter '$Filter'"

    # Export each term set
    $stats = @{
        Exported = 0
        Failed   = 0
        TotalTerms = 0
    }

    foreach ($set in $termSets) {
        Write-IDOPHeader "  $($set.Name)" -Char '-'

        try {
            # Retrieve all terms with parent info for hierarchy building
            $allTerms = Get-PnPTerm -TermSet $set.Id -TermGroup $TermGroupName `
                -Includes "Parent,TermsCount,IsRoot,PathOfTerm,IsAvailableForTagging,CustomProperties"

            $termCount = ($allTerms | Measure-Object).Count

            # Build export structure
            if ($Flat) {
                $termsData = Build-FlatTermList -Terms $allTerms
            }
            else {
                $termsData = Build-TermTree -Terms $allTerms
            }

            $exportData = [PSCustomObject]@{
                Name        = $set.Name
                Id          = $set.Id.ToString()
                Description = if ($set.Description) { $set.Description } else { "" }
                Owner       = $set.Owner
                Terms       = $termsData
                Statistics  = [PSCustomObject]@{
                    TotalTerms = $termCount
                    RootTerms  = if ($Flat) { $termCount } else { $termsData.Count }
                    ExportDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    Mode       = if ($Flat) { "Flat" } else { "Hierarchical" }
                }
            }

            # Write JSON
            $outFile = Join-Path $fullTaxonomyPath "$($set.Name).json"
            $exportData | ConvertTo-Json -Depth 10 | Set-Content -Path $outFile -Encoding UTF8

            Write-IDOPSuccess "$($set.Name) — $termCount terms -> $outFile"
            $stats.Exported++
            $stats.TotalTerms += $termCount
        }
        catch {
            Write-IDOPError "Failed to export $($set.Name): $_"
            $stats.Failed++
        }
    }

    # Summary
    Stop-IDOPTimer -Timer $timer
    Write-IDOPSummary -Stats @{
        "Term Sets Exported" = $stats.Exported
        "Term Sets Failed"   = $stats.Failed
        "Total Terms"        = $stats.TotalTerms
        "Output Path"        = $fullTaxonomyPath
    }

    if ($stats.Failed -gt 0) {
        Write-IDOPWarning "$($stats.Failed) term set(s) failed to export"
        exit 1
    }

    Write-IDOPSuccess "Export complete"
}
catch {
    Write-IDOPError "Export failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
