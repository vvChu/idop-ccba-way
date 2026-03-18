# IDOP Platform Refactoring Guide

## Overview

This document describes the refactored structure of the IDOP platform codebase, including new shared modules, unified CLI, and improved organization.

## What Changed

### 1. Centralized Configuration

**Before:** Environment URLs and Client IDs were hardcoded across 56+ scripts
**After:** Single configuration file at [tools/config/environments.psd1](tools/config/environments.psd1)

```powershell
# Load configuration
$config = Get-IDOPConfig -Environment Dev
Write-Host $config.SharePointUrl
```

### 2. Shared PowerShell Modules

**Before:** Common functions duplicated across scripts
**After:** Three reusable modules in [tools/scripts/modules/](tools/scripts/modules/)

#### PnPHelpers.psm1
Handles PnP connection management and SharePoint operations:
- `Connect-IDOPSharePoint` - Establishes PnP connection
- `Get-IDOPConfig` - Loads environment configuration
- `Test-IDOPConnection` - Validates connection status
- `Get-IDOPList` - Gets SharePoint list with error handling
- `Invoke-IDOPWithRetry` - Retry logic for operations

#### LoggingHelpers.psm1
Provides consistent logging and formatting:
- `Write-IDOPSuccess` / `Write-IDOPInfo` / `Write-IDOPWarning` / `Write-IDOPError`
- `Write-IDOPHeader` - Section headers
- `Write-IDOPProgress` - Progress indicators
- `Start-IDOPTimer` / `Stop-IDOPTimer` - Performance tracking
- `Write-IDOPSummary` - Summary reports
- `Confirm-IDOPAction` - User confirmations

#### ValidationHelpers.psm1
Validates schemas and naming conventions:
- `Test-IDOPListSchema` - Validates SharePoint list JSON
- `Test-IDOPFieldNaming` - Validates field naming conventions
- `Test-IDOPListNaming` - Validates list naming conventions
- `Test-IDOPTaxonomyJson` - Validates taxonomy JSON
- `Test-IDOPLookupReferences` - Validates lookup field references
- `Test-IDOPDataModel` - Validates entire datamodel

### 3. Unified CLI Wrapper

**Before:** 56 separate PowerShell scripts to remember
**After:** Single entry point [idop.ps1](idop.ps1) with intuitive commands

```powershell
# Deployment
.\idop.ps1 deploy lists -Environment Dev -DryRun
.\idop.ps1 deploy navigation -Environment Dev -Prune
.\idop.ps1 deploy lead-capture -Environment Prod

# Taxonomy management
.\idop.ps1 taxonomy import -Environment Dev -DryRun
.\idop.ps1 taxonomy export -Environment Dev
.\idop.ps1 taxonomy audit -Environment Dev

# Validation
.\idop.ps1 validate datamodel
.\idop.ps1 validate schemas
.\idop.ps1 validate naming
.\idop.ps1 validate lookups

# Connection
.\idop.ps1 connect -Environment Test

# Maintenance
.\idop.ps1 maintenance folders -DryRun

# Testing
.\idop.ps1 test lead-capture
```

## Migration Guide

### For Existing Scripts

To migrate existing scripts to use the new modules:

```powershell
# Add to beginning of script
$ModulePath = Join-Path $PSScriptRoot "modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
Import-Module "$ModulePath/ValidationHelpers.psm1" -Force

# Replace hardcoded environment URLs
# Before:
$siteUrl = "https://ibstbim.sharepoint.com/sites/idop-dev"

# After:
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

# Replace connection code
# Before:
Connect-PnPOnline -Url $siteUrl -Interactive -ClientId "90ded..."

# After:
Connect-IDOPSharePoint -Environment $Environment

# Replace console output
# Before:
Write-Host "Success!" -ForegroundColor Green

# After:
Write-IDOPSuccess "Success!"
```

### For New Scripts

Use this template:

```powershell
#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Your script description
#>

#Requires -Version 7.0

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Dev', 'Test', 'Prod')]
    [string]$Environment = 'Dev',

    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

# Import modules
$ModulePath = Join-Path $PSScriptRoot "modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force

try {
    # Get configuration
    $config = Get-IDOPConfig -Environment $Environment

    # Connect to SharePoint
    Connect-IDOPSharePoint -Environment $Environment

    # Your logic here
    Write-IDOPHeader "Doing Something"

    # Operations
    $timer = Start-IDOPTimer -Name "Operation"

    # ... your code ...

    Stop-IDOPTimer -Timer $timer

    # Summary
    Write-IDOPSummary -Stats @{
        "Items Processed" = 42
        "Errors" = 0
    }

    Write-IDOPSuccess "Operation completed"
}
catch {
    Write-IDOPError "Operation failed: $_"
    exit 1
}
```

## Best Practices

### 1. Always Use the Unified CLI

Instead of running scripts directly:
```powershell
# ❌ Old way
& .\tools\scripts\apply-sp-lists.ps1 -Environment Dev -DryRun

# ✅ New way
.\idop.ps1 deploy lists -Environment Dev -DryRun
```

### 2. Use Shared Modules

Don't duplicate common functionality:
```powershell
# ❌ Don't do this
Write-Host "✓ Success" -ForegroundColor Green

# ✅ Do this
Write-IDOPSuccess "Success"
```

### 3. Use Configuration File

Don't hardcode environment values:
```powershell
# ❌ Don't do this
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"

# ✅ Do this
$config = Get-IDOPConfig -Environment $Environment
$clientId = $config.ClientId
```

### 4. Consistent Error Handling

Use try-catch with proper error messages:
```powershell
try {
    $result = Invoke-IDOPWithRetry -ScriptBlock {
        # Your operation
    } -ErrorMessage "Failed to process item"
}
catch {
    Write-IDOPError "Operation failed: $_"
    exit 1
}
```

### 5. Validate Before Deploying

Always validate your datamodel before deployment:
```powershell
# Validate first
.\idop.ps1 validate datamodel

# Then deploy
.\idop.ps1 deploy lists -Environment Dev -DryRun
.\idop.ps1 deploy lists -Environment Dev  # After reviewing dry-run
```

## Testing

Test the new modules:

```powershell
# Test configuration loading
$config = Get-IDOPConfig -Environment Dev
$config | Format-List

# Test connection
Connect-IDOPSharePoint -Environment Dev -Force
Test-IDOPConnection

# Test validation
.\idop.ps1 validate datamodel

# Test CLI help
.\idop.ps1 help
```

## Troubleshooting

### Module Import Errors

If you see "Module not found" errors:
```powershell
# Check module path
$ModulePath = Join-Path $PSScriptRoot "modules"
Test-Path $ModulePath

# Import with absolute path
Import-Module "d:\idop-ccba-way\tools\scripts\modules\PnPHelpers.psm1" -Force
```

### Connection Issues

If connection fails:
```powershell
# Check existing connection
Get-PnPConnection

# Disconnect and reconnect
Disconnect-PnPOnline
Connect-IDOPSharePoint -Environment Dev -Force
```

### Configuration Issues

If configuration doesn't load:
```powershell
# Check config file exists
Test-Path "tools/config/environments.psd1"

# Load manually to debug
$config = Import-PowerShellDataFile "tools/config/environments.psd1"
$config.Dev
```

## Future Improvements

1. **Script Reorganization**: Move scripts into subdirectories by purpose (deployment, taxonomy, validation, etc.)
2. **Consolidate Duplicate Scripts**: Merge the 5 termstore-export variants into one
3. **Expand Test Coverage**: Add Pester tests for all modules
4. **JSON Schema Validation**: Implement proper JSON schema validation
5. **Auto-generated Documentation**: Generate docs from comment-based help
6. **Pre-commit Hooks**: Validate schemas and naming before commits
7. **CI/CD Integration**: Use unified CLI in GitHub Actions workflows

## Resources

- [CLAUDE.md](CLAUDE.md) - Project instructions for AI assistants
- [README.md](README.md) - Main project documentation
- [Constitution.md](constitution.md) - Development rules
- [Tools Scripts](tools/scripts/) - Legacy scripts (being refactored)

## Questions?

For issues or suggestions, create a GitHub issue or contact the CCBA development team.
