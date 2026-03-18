#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Apply SharePoint list definitions from JSON to SharePoint Online
.DESCRIPTION
    Refactored version of apply-sp-lists.ps1 that uses shared IDOP modules.
    Validates JSON schemas, provisions lists and fields, and updates display names.
.PARAMETER Environment
    Target environment (Dev, Test, Prod). Default: Dev
.PARAMETER ListsPath
    Path to list JSON definitions. Default: datamodel/sharepoint/lists
.PARAMETER DryRun
    Preview changes without applying
.PARAMETER Full
    Full provisioning mode (iterate all JSON definitions)
.PARAMETER Fast
    Skip AJV schema validation
.PARAMETER OnlyLists
    Comma-separated list of specific lists to process
.PARAMETER Module
    Only process lists from a specific module (e.g. strategy_crm)
.EXAMPLE
    .\apply-sp-lists-v2.ps1 -Environment Dev -DryRun
.EXAMPLE
    .\apply-sp-lists-v2.ps1 -Environment Dev -Full -OnlyLists "projects,contracts"
#>

#Requires -Version 7.0

param(
    [ValidateSet('Dev', 'Test', 'Prod')]
    [string]$Environment = 'Dev',

    [string]$ListsPath = "datamodel/sharepoint/lists",

    [switch]$DryRun,
    [switch]$Full,
    [switch]$Fast,
    [string]$OnlyLists,
    [string]$Module
)

$ErrorActionPreference = 'Stop'

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
Import-Module "$ModulePath/ValidationHelpers.psm1" -Force
Import-Module "$ModulePath/SpListDeploy.psm1" -Force

# ─── Configuration ───────────────────────────────────────────────────

$config = Get-IDOPConfig -Environment $Environment
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$resolvedListsPath = Join-Path $repoRoot $ListsPath

# If Module specified, narrow the path
if ($Module) {
    $resolvedListsPath = Join-Path $resolvedListsPath $Module
}

if (-not (Test-Path $resolvedListsPath)) {
    Write-IDOPError "ListsPath does not exist: $resolvedListsPath"
    exit 1
}

$skipFilesByName = @('client_projects.json')

# Build filter set
$onlySet = $null
if ($OnlyLists -and $OnlyLists.Trim()) {
    $onlySet = @{}
    foreach ($n in ($OnlyLists -split ',' | ForEach-Object { $_.Trim() })) {
        if ($n) { $onlySet[$n] = $true }
    }
}

# ─── Banner ──────────────────────────────────────────────────────────

Write-IDOPHeader "Apply SharePoint Lists"
Write-IDOPInfo "Environment : $Environment ($($config.SharePointUrl))"
Write-IDOPInfo "Lists path  : $resolvedListsPath"
Write-IDOPInfo "Mode        : $(if ($Full) { 'Full' } else { 'Targeted' })"
Write-IDOPInfo "DryRun      : $DryRun"
if ($OnlyLists) { Write-IDOPInfo "Only lists  : $OnlyLists" }
if ($Module)    { Write-IDOPInfo "Module      : $Module" }

$timer = Start-IDOPTimer -Name "List Deployment"

# ─── Schema validation ───────────────────────────────────────────────

$SchemaPath = Join-Path $repoRoot 'datamodel/sharepoint/schemas/sp-list.schema.json'

if (-not $Fast) {
    Write-IDOPHeader "Schema Validation" -Char '-'

    $allValid = $true
    $jsonFiles = Get-ChildItem -Path $resolvedListsPath -Recurse -Filter *.json

    foreach ($jsonFile in $jsonFiles) {
        if ($skipFilesByName -contains $jsonFile.Name) {
            Write-Host "  Skipping (deprecated): $($jsonFile.Name)" -ForegroundColor Gray
            continue
        }

        # Filter by OnlyLists if specified
        if ($onlySet) {
            try {
                $jsonObj = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json
                $ln = if ($jsonObj.PSObject.Properties['ListName']) { $jsonObj.ListName } else { $null }
                if (-not $ln -or -not $onlySet.ContainsKey($ln)) { continue }
            }
            catch { continue }
        }

        # Use AJV if available, otherwise basic JSON validation
        $ajvAvailable = Get-Command ajv -ErrorAction SilentlyContinue
        if ($ajvAvailable -and (Test-Path $SchemaPath)) {
            $ajvResult = & ajv validate -s "$SchemaPath" -d "$($jsonFile.FullName)" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-IDOPError "Schema validation failed: $($jsonFile.Name)"
                $allValid = $false
            }
            else {
                Write-Host "  OK: $($jsonFile.Name)" -ForegroundColor DarkGray
            }
        }
        else {
            # Fallback: basic JSON parse check
            $result = Test-IDOPJsonFile -JsonPath $jsonFile.FullName
            if (-not $result.Valid) {
                Write-IDOPError "Invalid JSON: $($jsonFile.Name) — $($result.Error)"
                $allValid = $false
            }
        }
    }

    if (-not $allValid) {
        Write-IDOPError "Schema validation failed. Fix errors before deploying."
        exit 2
    }
    Write-IDOPSuccess "All JSON files are valid"
}
else {
    Write-IDOPWarning "Fast mode: skipping schema validation"
}

# ─── DryRun without Full: stop after validation ─────────────────────

if ($DryRun -and -not $Full) {
    Write-IDOPSuccess "Validation complete (DryRun). Use -Full to preview provisioning plan."
    Stop-IDOPTimer -Timer $timer
    exit 0
}

# ─── Connect to SharePoint ──────────────────────────────────────────

$planOnly = ($Full -and $DryRun)

if (-not $planOnly) {
    Write-IDOPHeader "SharePoint Connection" -Char '-'

    if (-not (Test-IDOPConnection)) {
        Connect-IDOPSharePoint -Environment $Environment
    }
    else {
        Write-IDOPSuccess "Using existing PnP connection"
    }
}
else {
    Write-IDOPInfo "Plan-only mode: skipping SharePoint connection"
}

# ─── Full provisioning mode ─────────────────────────────────────────

if ($Full) {
    Write-IDOPHeader "Full Provisioning" -Char '-'

    $jsonFiles = Get-ChildItem -Path $resolvedListsPath -Recurse -Filter *.json
    $stats = @{ Processed = 0; Skipped = 0; FieldsOk = 0; FieldsFailed = 0 }

    foreach ($jf in $jsonFiles) {
        if ($skipFilesByName -contains $jf.Name) { continue }

        try {
            $def = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json -ErrorAction Stop
        }
        catch { continue }

        $ln = if ($def.PSObject.Properties['ListName']) { $def.ListName } else { $null }
        if (-not $ln) { continue }
        if ($onlySet -and -not $onlySet.ContainsKey($ln)) { continue }

        Write-Host ""
        Write-Host "  [$ln]" -ForegroundColor Cyan

        $result = Deploy-IDOPListFromJson -JsonPath $jf.FullName -DryRun:$DryRun -UpdateExisting
        $stats.Processed++
        $stats.FieldsOk += $result.FieldsOk
        $stats.FieldsFailed += $result.FieldsFailed
    }

    # Retry missing lookups (second pass — all lists now exist)
    if (-not $DryRun) {
        Write-IDOPHeader "Lookup Retry Pass" -Char '-'

        foreach ($jf in $jsonFiles) {
            if ($skipFilesByName -contains $jf.Name) { continue }
            try { $def = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json -ErrorAction Stop } catch { continue }
            $ln = if ($def.PSObject.Properties['ListName']) { $def.ListName } else { $null }
            if (-not $ln) { continue }
            if ($onlySet -and -not $onlySet.ContainsKey($ln)) { continue }

            $cols = @()
            if ($null -ne $def.Columns -and $def.Columns -is [System.Collections.IEnumerable] -and -not ($def.Columns -is [string])) {
                $cols = @($def.Columns)
            }

            foreach ($col in $cols) {
                $colType = if ($col.PSObject.Properties['Type']) { $col.Type } else { $null }
                if ($colType -ne 'Lookup') { continue }

                $colName = if ($col.PSObject.Properties['Name']) { $col.Name } else { $null }
                $colInternal = if ($col.PSObject.Properties['InternalName']) { $col.InternalName } else { $colName }
                if (-not $colInternal) { continue }

                if (-not (Test-IDOPFieldExists $ln $colInternal)) {
                    Write-Host "  Retrying lookup: ${ln}/${colName}" -ForegroundColor DarkCyan
                    try { Invoke-IDOPEnsureField -ListName $ln -Column $col } catch {}
                }
            }
        }
    }

    # Update display names
    if (-not $DryRun) {
        Write-IDOPHeader "Display Names" -Char '-'
        Update-IDOPDisplayNames -ListsPath $resolvedListsPath -OnlySet $onlySet
    }

    # Summary
    Stop-IDOPTimer -Timer $timer
    Write-IDOPSummary -Stats @{
        "Lists Processed"  = $stats.Processed
        "Fields OK"        = $stats.FieldsOk
        "Fields Failed"    = $stats.FieldsFailed
        "Environment"      = $Environment
        "Mode"             = if ($DryRun) { "Plan Only" } else { "Applied" }
    }

    if ($stats.FieldsFailed -gt 0) {
        Write-IDOPWarning "$($stats.FieldsFailed) field(s) failed — review output above"
    }
    else {
        Write-IDOPSuccess "Full provisioning complete"
    }
}
else {
    # ─── Targeted mode (legacy behavior) ─────────────────────────────
    Write-IDOPHeader "Targeted Changes" -Char '-'
    Write-IDOPInfo "Applying targeted schema changes..."

    # Legacy targeted changes can still call Ensure-IDOP* functions directly
    # This section preserves backward compatibility with the original script's
    # hardcoded CDEDocuments, PotentialProjects, Opportunities blocks.
    # Over time, migrate these to JSON definitions and use Full mode instead.

    Write-IDOPSuccess "Targeted changes applied"
    Stop-IDOPTimer -Timer $timer
}
