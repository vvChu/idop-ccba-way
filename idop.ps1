#!/usr/bin/env pwsh
<#
.SYNOPSIS
    IDOP Platform Unified CLI
.DESCRIPTION
    Central command-line interface for all IDOP operations including deployment,
    validation, taxonomy management, and maintenance tasks.
.EXAMPLE
    .\idop.ps1 deploy lists -Environment Dev -DryRun
.EXAMPLE
    .\idop.ps1 taxonomy import -Environment Dev
.EXAMPLE
    .\idop.ps1 validate datamodel
.NOTES
    Requires PowerShell 7+ and PnP.PowerShell module
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet(
        'deploy',
        'taxonomy',
        'validate',
        'connect',
        'maintenance',
        'test',
        'help'
    )]
    [string]$Command,

    [Parameter(Mandatory = $false, Position = 1)]
    [string]$SubCommand,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Dev', 'Test', 'Prod')]
    [string]$Environment = 'Dev',

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [string[]]$OnlyLists,

    [Parameter(Mandatory = $false)]
    [string]$Module,

    [Parameter(Mandatory = $false)]
    [switch]$Full,

    [Parameter(Mandatory = $false)]
    [switch]$Prune,

    [Parameter(Mandatory = $false)]
    [string]$LogFile
)

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "tools/scripts/modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
Import-Module "$ModulePath/ValidationHelpers.psm1" -Force

# Script paths
$ScriptsPath = Join-Path $PSScriptRoot "tools/scripts"

# Show banner
function Show-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           IDOP Platform Management CLI                  ║" -ForegroundColor Cyan
    Write-Host "║     Integrated Digital Operation Platform - CCBA         ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Show help
function Show-Help {
    Write-Host "IDOP CLI - Available Commands" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "DEPLOYMENT:" -ForegroundColor Yellow
    Write-Host "  deploy lists          Deploy SharePoint lists"
    Write-Host "    -Environment        Target environment (Dev, Test, Prod)"
    Write-Host "    -DryRun            Preview changes without applying"
    Write-Host "    -OnlyLists         Deploy specific lists only"
    Write-Host "    -Module            Deploy lists from specific module"
    Write-Host "    -Full              Full deployment mode"
    Write-Host ""
    Write-Host "  deploy navigation     Deploy SharePoint navigation"
    Write-Host "  deploy lead-capture   Deploy lead capture workflow"
    Write-Host ""
    Write-Host "TAXONOMY:" -ForegroundColor Yellow
    Write-Host "  taxonomy import       Import taxonomy term sets"
    Write-Host "  taxonomy export       Export taxonomy term sets"
    Write-Host "  taxonomy audit        Audit taxonomy usage"
    Write-Host ""
    Write-Host "VALIDATION:" -ForegroundColor Yellow
    Write-Host "  validate datamodel    Validate all JSON schemas"
    Write-Host "  validate schemas      Validate SharePoint list schemas"
    Write-Host "  validate naming       Validate naming conventions"
    Write-Host "  validate lookups      Validate lookup field references"
    Write-Host ""
    Write-Host "MAINTENANCE:" -ForegroundColor Yellow
    Write-Host "  maintenance folders   Create bidding folders"
    Write-Host "  maintenance cleanup   Cleanup operations"
    Write-Host ""
    Write-Host "CONNECTION:" -ForegroundColor Yellow
    Write-Host "  connect              Connect to SharePoint environment"
    Write-Host ""
    Write-Host "TESTING:" -ForegroundColor Yellow
    Write-Host "  test lead-capture    Test lead capture workflow"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\idop.ps1 deploy lists -Environment Dev -DryRun"
    Write-Host "  .\idop.ps1 taxonomy import -Environment Dev"
    Write-Host "  .\idop.ps1 validate datamodel"
    Write-Host "  .\idop.ps1 connect -Environment Test"
    Write-Host ""
}

# Main execution
try {
    Show-Banner

    # Setup logging
    if ($LogFile) {
        $logPath = $LogFile
    }
    else {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $logPath = ".logs/idop-$timestamp.log"
    }

    switch ($Command) {
        'help' {
            Show-Help
            exit 0
        }

        'connect' {
            Write-IDOPHeader "Connecting to SharePoint"
            Connect-IDOPSharePoint -Environment $Environment
            Write-IDOPSuccess "Connected successfully"
        }

        'deploy' {
            switch ($SubCommand) {
                'lists' {
                    Write-IDOPHeader "Deploying SharePoint Lists"

                    # Ensure connection
                    if (-not (Test-IDOPConnection)) {
                        Write-IDOPInfo "Establishing connection..."
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $params = @{
                        Environment = $Environment
                    }

                    if ($DryRun) { $params['DryRun'] = $true }
                    if ($Full) { $params['Full'] = $true }
                    if ($OnlyLists) { $params['OnlyLists'] = $OnlyLists -join ',' }
                    if ($Module) { $params['Module'] = $Module }

                    $scriptPath = Join-Path $ScriptsPath "deployment/apply-sp-lists.ps1"
                    & $scriptPath @params
                }

                'navigation' {
                    Write-IDOPHeader "Deploying SharePoint Navigation"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $params = @{
                        Environment = $Environment
                        Location = 'Top'
                    }

                    if ($DryRun) { $params['DryRun'] = $true }
                    if ($Prune) { $params['Prune'] = $true }

                    $scriptPath = Join-Path $ScriptsPath "deployment/sync-sp-navigation.ps1"
                    & $scriptPath @params
                }

                'lead-capture' {
                    Write-IDOPHeader "Deploying Lead Capture Workflow"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $scriptPath = Join-Path $ScriptsPath "deployment/deploy-lead-capture.ps1"
                    & $scriptPath -Environment $Environment
                }

                default {
                    Write-IDOPError "Unknown deploy subcommand: $SubCommand"
                    Write-Host "Available: lists, navigation, lead-capture"
                    exit 1
                }
            }
        }

        'taxonomy' {
            switch ($SubCommand) {
                'import' {
                    Write-IDOPHeader "Importing Taxonomy"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $params = @{ Environment = $Environment }
                    if ($DryRun) { $params['DryRun'] = $true }

                    $scriptPath = Join-Path $ScriptsPath "taxonomy/termstore-import.ps1"
                    & $scriptPath @params
                }

                'export' {
                    Write-IDOPHeader "Exporting Taxonomy"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $scriptPath = Join-Path $ScriptsPath "taxonomy/termstore-export.ps1"

                    $params = @{ Environment = $Environment }
                    if ($DryRun) { $params['DryRun'] = $true }
                    & $scriptPath @params
                }

                'audit' {
                    Write-IDOPHeader "Auditing Taxonomy"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $scriptPath = Join-Path $ScriptsPath "taxonomy/termstore-audit.ps1"
                    & $scriptPath -Environment $Environment
                }

                default {
                    Write-IDOPError "Unknown taxonomy subcommand: $SubCommand"
                    Write-Host "Available: import, export, audit"
                    exit 1
                }
            }
        }

        'validate' {
            Write-IDOPHeader "Running Validation"

            $config = Get-IDOPConfig -Environment $Environment
            $dataModelPath = Join-Path $PSScriptRoot $config.Paths.DataModelLists

            switch ($SubCommand) {
                'datamodel' {
                    Write-IDOPInfo "Validating entire datamodel..."
                    $result = Test-IDOPDataModel -DataModelPath (Split-Path $dataModelPath)

                    Write-IDOPSummary -Stats @{
                        "Lists Checked" = $result.ListsChecked
                        "Lists Valid" = $result.ListsValid
                        "Taxonomy Checked" = $result.TaxonomyChecked
                        "Taxonomy Valid" = $result.TaxonomyValid
                        "Total Errors" = $result.Errors.Count
                    }

                    if ($result.Errors.Count -gt 0) {
                        Write-IDOPError "Validation failed with $($result.Errors.Count) error(s)"
                        $result.Errors | ForEach-Object {
                            Write-Host "  [$($_.Type)] $($_.File):" -ForegroundColor Red
                            $_.Errors | ForEach-Object { Write-Host "    - $_" -ForegroundColor Gray }
                        }
                        exit 1
                    }
                    else {
                        Write-IDOPSuccess "All validations passed"
                    }
                }

                'schemas' {
                    $scriptPath = Join-Path $ScriptsPath "validation/validate-sp-schemas.ps1"
                    & $scriptPath
                }

                'naming' {
                    $scriptPath = Join-Path $ScriptsPath "validation/validate-sp-naming.ps1"
                    & $scriptPath
                }

                'lookups' {
                    Write-IDOPInfo "Validating lookup field references..."
                    $result = Test-IDOPLookupReferences -ListsPath $dataModelPath

                    if ($result.Valid) {
                        Write-IDOPSuccess "All lookup references are valid ($($result.TotalListsChecked) lists checked)"
                    }
                    else {
                        Write-IDOPError "Found $($result.Issues.Count) lookup reference issue(s)"
                        $result.Issues | ForEach-Object {
                            Write-Host "  [$($_.List)] $($_.Field): $($_.Issue)" -ForegroundColor Red
                        }
                        exit 1
                    }
                }

                default {
                    Write-IDOPError "Unknown validate subcommand: $SubCommand"
                    Write-Host "Available: datamodel, schemas, naming, lookups"
                    exit 1
                }
            }
        }

        'maintenance' {
            switch ($SubCommand) {
                'folders' {
                    Write-IDOPHeader "Creating Bidding Folders"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $params = @{}
                    if ($DryRun) { $params['DryRun'] = $true }

                    $scriptPath = Join-Path $ScriptsPath "deployment/opportunity-bidding-folders.ps1"
                    & $scriptPath @params
                }

                default {
                    Write-IDOPError "Unknown maintenance subcommand: $SubCommand"
                    Write-Host "Available: folders, cleanup"
                    exit 1
                }
            }
        }

        'test' {
            switch ($SubCommand) {
                'lead-capture' {
                    Write-IDOPHeader "Testing Lead Capture Workflow"

                    if (-not (Test-IDOPConnection)) {
                        Connect-IDOPSharePoint -Environment $Environment
                    }

                    $scriptPath = Join-Path $ScriptsPath "testing/test-lead-capture.ps1"
                    & $scriptPath
                }

                default {
                    Write-IDOPError "Unknown test subcommand: $SubCommand"
                    Write-Host "Available: lead-capture"
                    exit 1
                }
            }
        }

        default {
            Write-IDOPError "Unknown command: $Command"
            Show-Help
            exit 1
        }
    }

    Write-Host ""
    Write-IDOPSuccess "Operation completed successfully"
}
catch {
    Write-Host ""
    Write-IDOPError "Operation failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
