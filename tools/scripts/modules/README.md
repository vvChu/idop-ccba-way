# IDOP Shared PowerShell Modules

This directory contains reusable PowerShell modules used across all IDOP platform scripts.

## Modules

### PnPHelpers.psm1

**Purpose:** PnP PowerShell connection management and SharePoint operations

**Functions:**
- `Get-IDOPConfig` - Load environment configuration
- `Connect-IDOPSharePoint` - Establish PnP connection with retry logic
- `Test-IDOPConnection` - Validate connection status
- `Assert-PowerShell7` - Ensure PowerShell 7+ is being used
- `Get-IDOPList` - Get SharePoint list with error handling
- `Invoke-IDOPWithRetry` - Execute operations with retry logic

**Example:**
```powershell
Import-Module "$PSScriptRoot/PnPHelpers.psm1" -Force

# Get configuration
$config = Get-IDOPConfig -Environment Dev

# Connect to SharePoint
Connect-IDOPSharePoint -Environment Dev

# Get a list
$list = Get-IDOPList -ListName "projects"
```

### LoggingHelpers.psm1

**Purpose:** Consistent logging, formatting, and user interaction

**Functions:**
- `Write-IDOPSuccess` - Success messages with ✓ icon
- `Write-IDOPInfo` - Info messages with ℹ icon
- `Write-IDOPWarning` - Warning messages with ⚠ icon
- `Write-IDOPError` - Error messages with ✗ icon
- `Write-IDOPHeader` - Section headers
- `Write-IDOPProgress` - Progress bars
- `Write-IDOPTable` - Formatted tables
- `Start-IDOPTimer` / `Stop-IDOPTimer` - Performance tracking
- `Write-IDOPSummary` - Summary reports
- `Confirm-IDOPAction` - User confirmations
- `Write-IDOPLog` - File and console logging

**Example:**
```powershell
Import-Module "$PSScriptRoot/LoggingHelpers.psm1" -Force

# Headers
Write-IDOPHeader "Deploying Lists"

# Messages
Write-IDOPInfo "Starting deployment..."
Write-IDOPSuccess "Deployment completed"
Write-IDOPWarning "Some items were skipped"

# Timer
$timer = Start-IDOPTimer -Name "Deployment"
# ... your operations ...
Stop-IDOPTimer -Timer $timer

# Summary
Write-IDOPSummary -Stats @{
    "Lists Deployed" = 15
    "Errors" = 0
    "Duration" = "2.5s"
}
```

### ValidationHelpers.psm1

**Purpose:** Schema validation, naming conventions, and data integrity checks

**Functions:**
- `Test-IDOPListSchema` - Validate SharePoint list JSON structure
- `Test-IDOPFieldNaming` - Validate field naming conventions (PascalCase)
- `Test-IDOPListNaming` - Validate list naming conventions (lowercase_underscore)
- `Test-IDOPJsonFile` - Validate JSON syntax
- `Test-IDOPTaxonomyJson` - Validate taxonomy term set JSON
- `Test-IDOPLookupReferences` - Validate lookup field references between lists
- `Test-IDOPDataModel` - Validate entire datamodel (lists + taxonomy)

**Example:**
```powershell
Import-Module "$PSScriptRoot/ValidationHelpers.psm1" -Force

# Validate entire datamodel
$result = Test-IDOPDataModel -DataModelPath "datamodel/sharepoint"

if ($result.Errors.Count -eq 0) {
    Write-Host "✓ All validations passed"
} else {
    Write-Host "✗ Found $($result.Errors.Count) errors"
}

# Validate specific list
$validation = Test-IDOPListSchema -JsonPath "datamodel/sharepoint/lists/strategy_crm/projects.json"

# Validate lookup references
$lookups = Test-IDOPLookupReferences -ListsPath "datamodel/sharepoint/lists"
```

## Usage in Scripts

### Standard Template

```powershell
#!/usr/bin/env pwsh
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
Import-Module "$ModulePath/ValidationHelpers.psm1" -Force

try {
    Write-IDOPHeader "My Script"

    # Get configuration
    $config = Get-IDOPConfig -Environment $Environment

    # Connect to SharePoint
    Connect-IDOPSharePoint -Environment $Environment

    # Your operations here
    $timer = Start-IDOPTimer -Name "Operation"

    # ... your code ...

    Stop-IDOPTimer -Timer $timer

    Write-IDOPSuccess "Script completed"
}
catch {
    Write-IDOPError "Script failed: $_"
    exit 1
}
```

### Using the Unified CLI

Instead of running scripts directly, use the unified CLI:

```powershell
# From repository root
.\idop.ps1 deploy lists -Environment Dev -DryRun
.\idop.ps1 taxonomy import -Environment Dev
.\idop.ps1 validate datamodel
```

The CLI automatically imports these modules and provides a consistent interface.

## Configuration

Environment configuration is centralized in `tools/config/environments.psd1`:

```powershell
@{
    Common = @{
        ClientId = "c055c7a4-9150-4bd5-bf01-445c65467feb"
        TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
        TenantDomain = "ibstbim.onmicrosoft.com"
    }

    IDOP = @{
        SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop"
        AllowDestructiveOperations = $true
    }

    # ... Dev, Test, Prod (legacy) ...
}
```

Access via `Get-IDOPConfig`:

```powershell
$config = Get-IDOPConfig -Environment IDOP
$config.SharePointUrl  # https://ibstbim.sharepoint.com/sites/idop
$config.ClientId       # c055c7a4-9150-4bd5-bf01-445c65467feb
```

## Best Practices

1. **Always import modules at script start**
   ```powershell
   $ModulePath = Join-Path $PSScriptRoot "modules"
   Import-Module "$ModulePath/PnPHelpers.psm1" -Force
   ```

2. **Use `Get-IDOPConfig` instead of hardcoding**
   ```powershell
   # ❌ Don't do this
   $url = "https://ibstbim.sharepoint.com/sites/idop-dev"

   # ✅ Do this
   $config = Get-IDOPConfig -Environment Dev
   $url = $config.SharePointUrl
   ```

3. **Use consistent logging functions**
   ```powershell
   # ❌ Don't do this
   Write-Host "Success!" -ForegroundColor Green

   # ✅ Do this
   Write-IDOPSuccess "Success!"
   ```

4. **Wrap operations with try-catch**
   ```powershell
   try {
       # Your operations
   }
   catch {
       Write-IDOPError "Operation failed: $_"
       exit 1
   }
   ```

5. **Use timers for performance tracking**
   ```powershell
   $timer = Start-IDOPTimer -Name "List Deployment"
   # ... operations ...
   Stop-IDOPTimer -Timer $timer  # Shows elapsed time
   ```

6. **Validate before deploying**
   ```powershell
   # Always validate first
   $validation = Test-IDOPDataModel -DataModelPath $path
   if ($validation.Errors.Count -gt 0) {
       Write-IDOPError "Validation failed"
       exit 1
   }

   # Then deploy
   # ... deployment code ...
   ```

## Testing Modules

Test the modules work correctly:

```powershell
# Use the unified CLI
.\idop.ps1 validate datamodel
.\idop.ps1 connect -Environment Dev
```

## Troubleshooting

### Module Import Errors

```powershell
# Check module exists
Test-Path "$PSScriptRoot/modules/PnPHelpers.psm1"

# Import with verbose output
Import-Module "$PSScriptRoot/modules/PnPHelpers.psm1" -Force -Verbose
```

### Configuration Not Loading

```powershell
# Check config file exists
Test-Path "tools/config/environments.psd1"

# Load manually to debug
$config = Import-PowerShellDataFile "tools/config/environments.psd1"
$config.Dev
```

### Connection Issues

```powershell
# Check current connection
Get-PnPConnection

# Reconnect
Disconnect-PnPOnline
Connect-IDOPSharePoint -Environment Dev -Force
```

## Contributing

When adding new common functionality:

1. Choose the appropriate module (PnP, Logging, or Validation)
2. Follow existing function naming pattern: `Verb-IDOPNoun`
3. Add comment-based help with examples
4. Export the function in `Export-ModuleMember`
5. Update this README with the new function
6. Test in multiple scripts before committing

## Support

For issues or questions:
- See [CLAUDE.md](../../../CLAUDE.md) for project instructions
- Create a GitHub issue
- Contact CCBA development team
