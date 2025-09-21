# Tools Scripts

This directory contains PowerShell scripts for managing the IDOP platform deployment and operations.

## Scripts Overview

### Deployment Scripts

- `apply-sp-lists.ps1`: Applies SharePoint Lists from JSON definitions to SharePoint sites
  - Parameters: `-ListsPath`, `-DryRun`
  - Environment variables: `IDOP_ENVIRONMENT`, `PNP_AUTH_METHOD`
  - Features: Schema validation, diff detection, backup, secure authentication

- `validate-sp-schemas.ps1`: Validates JSON list definitions against schemas
  - Parameters: `-SchemaDir`, `-ListsPath`
  - Uses AJV for validation

### MCP Scripts

- `start-serena-mcp.ps1`: Starts the Serena MCP server for code operations
  - Parameters: Context, mode, transport, port
  - Supports SSE and HTTP transports

- `mcp_call.py`: Python client for MCP server interactions
  - Calls tools like activate_project, get_symbols_overview

### Testing

- `apply-sp-lists.Tests.ps1`: Pester tests for deployment script
  - Run with: `Invoke-Pester -Path tools/scripts/apply-sp-lists.Tests.ps1`

## Usage Examples

### Validate Lists
```powershell
.\validate-sp-schemas.ps1 -ListsPath "datamodel/sharepoint/lists"
```

### Apply Lists (Dry Run)
```powershell
.\apply-sp-lists.ps1 -DryRun
```

### Apply Lists (Production)
```powershell
$env:IDOP_ENVIRONMENT = "Prod"
$env:PNP_AUTH_METHOD = "Certificate"
.\apply-sp-lists.ps1
```

## Security

- Use environment variables for sensitive data
- Prefer certificate-based authentication for production
- Scripts include input validation and error handling

## CI/CD

Scripts are validated in GitHub Actions workflow (.github/workflows/validate.yml):
- JSON schema validation
- PowerShell syntax check
- Pester tests
- Spec compliance check