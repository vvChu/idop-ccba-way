#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Example script demonstrating the new shared modules
.DESCRIPTION
    This script shows how to use PnPHelpers, LoggingHelpers, and ValidationHelpers
    modules in your own scripts.
.PARAMETER Environment
    Target environment (Dev, Test, Prod)
.EXAMPLE
    .\example-with-modules.ps1 -Environment Dev
#>

#Requires -Version 7.0

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Dev', 'Test', 'Prod')]
    [string]$Environment = 'Dev'
)

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
Import-Module "$ModulePath/ValidationHelpers.psm1" -Force

try {
    # ===== Configuration Example =====
    Write-IDOPHeader "Configuration"

    $config = Get-IDOPConfig -Environment $Environment
    Write-IDOPInfo "Environment: $($config.Environment)"
    Write-IDOPInfo "SharePoint URL: $($config.SharePointUrl)"
    Write-IDOPInfo "Client ID: $($config.ClientId)"

    # ===== Connection Example =====
    Write-IDOPHeader "SharePoint Connection"

    Connect-IDOPSharePoint -Environment $Environment

    if (Test-IDOPConnection) {
        Write-IDOPSuccess "Connected successfully"
    }
    else {
        Write-IDOPError "Connection failed"
        exit 1
    }

    # ===== Timer Example =====
    Write-IDOPHeader "Performance Tracking"

    $timer = Start-IDOPTimer -Name "Data Processing"

    # Simulate some work
    Write-IDOPInfo "Processing items..."
    for ($i = 1; $i -le 5; $i++) {
        Write-IDOPProgress -Activity "Processing" -Current $i -Total 5 -Status "Item $i of 5"
        Start-Sleep -Milliseconds 500
    }

    Stop-IDOPTimer -Timer $timer

    # ===== Validation Example =====
    Write-IDOPHeader "Data Validation"

    $dataModelPath = Join-Path $PSScriptRoot "../../datamodel/sharepoint"

    if (Test-Path $dataModelPath) {
        Write-IDOPInfo "Validating datamodel at: $dataModelPath"
        $result = Test-IDOPDataModel -DataModelPath $dataModelPath

        Write-IDOPSummary -Stats @{
            "Lists Checked"    = $result.ListsChecked
            "Lists Valid"      = $result.ListsValid
            "Taxonomy Checked" = $result.TaxonomyChecked
            "Taxonomy Valid"   = $result.TaxonomyValid
            "Total Errors"     = $result.Errors.Count
        }

        if ($result.Errors.Count -gt 0) {
            Write-IDOPWarning "Found validation errors"
        }
        else {
            Write-IDOPSuccess "All validations passed"
        }
    }
    else {
        Write-IDOPWarning "Datamodel path not found: $dataModelPath"
    }

    # ===== Retry Example =====
    Write-IDOPHeader "Retry Logic"

    $result = Invoke-IDOPWithRetry -ScriptBlock {
        Write-Host "Attempting operation..."
        # Your operation here
        Get-PnPWeb
    } -MaxRetries 3 -RetryDelaySeconds 1 -ErrorMessage "Failed to get web"

    Write-IDOPSuccess "Operation completed"

    # ===== List Example =====
    Write-IDOPHeader "SharePoint List Operations"

    $list = Get-IDOPList -ListName "projects"
    if ($list) {
        Write-IDOPSuccess "Found list: $($list.Title)"
        Write-IDOPInfo "Item count: $($list.ItemCount)"
    }
    else {
        Write-IDOPWarning "List 'projects' not found"
    }

    # ===== Confirmation Example =====
    Write-IDOPHeader "User Confirmation"

    if (Confirm-IDOPAction -Message "Do you want to proceed with deployment?" -DefaultYes) {
        Write-IDOPSuccess "User confirmed - proceeding"
    }
    else {
        Write-IDOPInfo "User cancelled - aborting"
        exit 0
    }

    # ===== Final Summary =====
    Write-IDOPHeader "Summary"

    Write-IDOPSummary -Stats @{
        "Environment"       = $Environment
        "Lists Validated"   = $result.ListsChecked
        "Operations"        = "Success"
        "Duration"          = "$(($timer.Stopwatch.Elapsed.TotalSeconds).ToString('N2'))s"
    }

    Write-Host ""
    Write-IDOPSuccess "Example script completed successfully"
}
catch {
    Write-Host ""
    Write-IDOPError "Script failed: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
