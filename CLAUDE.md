# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

IDOP-CCBA-WAY is a digital operations platform (IDOP - Integrated Digital Operation Platform) for CCBA (Center for Consulting Services and BIM Application in construction), a unit under the Institute of Building Science and Technology (IBST). The platform digitizes and automates business processes using Microsoft 365 (SharePoint Online, Power Automate, Power BI, Teams).

This is a **scaffold repository** (reduced from 1.3GB+ to 7.5MB) containing core components for deploying the platform, including SharePoint datamodels, taxonomy definitions, and automation scripts.

## Governance Knowledge Base

AI Agents working in this repository MUST read `.md/workspace_context.yaml` first when starting a working session to load project bootstrap information, document hierarchy, and initial reading sequences.

The Knowledge Base in `.md/` is structured into two core document groups:
- **`governance_constitution`** (`.md/governance_constitution/`): Immutable legal regulations and governance rules (QCTK 2815 - Quy chế quản lý dự án, QCCTNB 3209 - Quy chế chi tiêu nội bộ, Điều lệ CCBA, and Quy chế KHCN IBST).
- **`system_blueprint`** (`.md/system_blueprint/`): Evolvable system design requirements and operational blueprints (IDOP v2.0 F1-F4).

When requiring the legal basis or governance source for any module/specification located in `specs/modules/`, AI Agents MUST look up `.md/cross_references.yaml` to trace specs back to their underlying governance rules.

## Architecture Overview

The platform has 6 core modules:

- **strategy_crm**: CRM, opportunities, leads, customers, contacts
- **process_execution**: Projects, contracts, activities, work packages, PMO
- **cash_data**: Financial plans, expenses, invoices, allocations
- **people_assets**: HR, employees, assets, timesheets
- **performance_okrs**: OKRs, KPIs, scorecards, measurables
- **system_governance**: Approvals, workflows, forms, environment variables

Each module contains:
- `spec.md`: Detailed specifications
- `plan.md`: Implementation plan
- `tasks.md`: Task breakdown
- `api-spec.json`: API definitions

## Unified CLI

The platform uses a unified CLI wrapper for all operations. Use `idop.ps1` instead of individual scripts.

### Quick Start

```powershell
# Show all available commands
.\idop.ps1 help

# Connect to SharePoint environment
.\idop.ps1 connect -Environment Dev
```

### Deployment Commands

```powershell
# Deploy SharePoint Lists (dry-run first)
.\idop.ps1 deploy lists -Environment Dev -DryRun
.\idop.ps1 deploy lists -Environment Dev

# Deploy specific lists only
.\idop.ps1 deploy lists -Environment Dev -OnlyLists projects,contracts

# Deploy by module
.\idop.ps1 deploy lists -Environment Dev -Module strategy_crm

# Deploy navigation
.\idop.ps1 deploy navigation -Environment Dev -Prune -DryRun

# Deploy lead capture workflow
.\idop.ps1 deploy lead-capture -Environment Prod
```

### Taxonomy Management

```powershell
# Import taxonomy (dry-run first)
.\idop.ps1 taxonomy import -Environment Dev -DryRun
.\idop.ps1 taxonomy import -Environment Dev

# Export taxonomy
.\idop.ps1 taxonomy export -Environment Dev

# Audit taxonomy usage
.\idop.ps1 taxonomy audit -Environment Dev
```

### Validation

```powershell
# Validate entire datamodel (schemas, naming, lookups)
.\idop.ps1 validate datamodel

# Validate specific aspects
.\idop.ps1 validate schemas
.\idop.ps1 validate naming
.\idop.ps1 validate lookups
```

### Maintenance

```powershell
# Create bidding folders for opportunities
.\idop.ps1 maintenance folders -DryRun
```

### Testing

```powershell
# Test lead capture workflow
.\idop.ps1 test lead-capture
```

### Direct Script Usage

You can also run scripts directly:

```powershell
# Establish a reusable PnP session
Connect-PnPOnline -Url https://ibstbim.sharepoint.com/sites/idop-dev -Interactive -ClientId 90ded6f0-b787-4b3c-acea-8baf6403fd63

# Use the call operator (&) to run scripts in the same session
& .\tools\scripts\deployment\apply-sp-lists.ps1 -Environment Dev -DryRun
```

**Important**: Don't start a new PowerShell process (e.g., `pwsh -File`) for scripts that need PnP connection—use the call operator `&` from the same shell where you ran `Connect-PnPOnline`.

## Development Workflow

### Datamodel Structure

SharePoint Lists are defined as JSON files in `datamodel/sharepoint/lists/` organized by module:

```
datamodel/sharepoint/lists/
├── strategy_crm/          # CRM entities
├── process_execution/     # Project execution
├── cash_data/            # Financial data
├── people_assets/        # HR & assets
├── performance_okrs/     # Performance tracking
└── system_governance/    # Governance & approvals
```

Each JSON file defines:
- List metadata (title, description, template)
- Fields with types, validation, lookups
- Taxonomy field mappings
- Views and content types

### Taxonomy Structure

Managed metadata term sets are in `datamodel/sharepoint/taxonomy/` as JSON files (18 term sets covering departments, positions, service types, statuses, expense types, etc.).

## Script Organization

Scripts are organized by purpose in `tools/scripts/`:

```
tools/scripts/
├── modules/          # Shared PowerShell modules
├── deployment/       # List provisioning, navigation, lead capture
├── taxonomy/         # Term store import, export, audit
├── validation/       # Schema validation, naming checks, sp-diff
├── migration/        # One-time migration scripts
├── testing/          # Pester tests, workflow tests
└── connection/       # PnP session helpers, auth setup
```

## Important Conventions

### Shared Modules

The platform uses shared PowerShell modules in `tools/scripts/modules/`:

- **PnPHelpers.psm1**: `Get-IDOPConfig`, `Connect-IDOPSharePoint`, `Connect-IdopOnline`, `Test-IDOPConnection`, `Invoke-IDOPWithRetry`
- **LoggingHelpers.psm1**: `Write-IDOPHeader`, `Write-IDOPInfo`, `Write-IDOPSuccess`, `Write-IDOPError`, `Write-IDOPSummary`
- **ValidationHelpers.psm1**: `Test-IDOPDataModel`, `Test-IDOPLookupReferences`, naming convention checks
- **SpListDeploy.psm1**: `Ensure-*` functions for SharePoint list/field provisioning

Import pattern for new scripts:

```powershell
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
```

### Auth Modes

Scripts accept `-Auth Cached|Interactive|DeviceLogin` (default: `Cached`). Use `Interactive` for first-time auth, `Cached` for subsequent runs.

### Centralized Configuration

All environment configuration is centralized in `tools/config/environments.psd1`:

```powershell
# Load configuration
$config = Get-IDOPConfig -Environment Dev

# Access properties
$config.SharePointUrl     # https://ibstbim.sharepoint.com/sites/idop-dev
$config.ClientId          # 90ded6f0-b787-4b3c-acea-8baf6403fd63
$config.Paths.DataModelLists  # datamodel/sharepoint/lists
```

**Don't hardcode environment values** - always use `Get-IDOPConfig`.

### Environment URLs

- **Dev**: `https://ibstbim.sharepoint.com/sites/idop-dev`
- **Test**: `https://ibstbim.sharepoint.com/sites/idop-test`
- **Prod**: `https://ibstbim.sharepoint.com/sites/idop-prod`

### Client ID

All scripts use the same Entra App Client ID: `90ded6f0-b787-4b3c-acea-8baf6403fd63`

### Field Naming

- Internal names: PascalCase (e.g., `ProjectCode`, `CustomerName`)
- Display names: Vietnamese with proper formatting
- Taxonomy fields: Prefixed with term set name (e.g., `CCBA_TrangThaiChung`)

### List Naming

- Internal names: Lowercase with underscores (e.g., `projects`, `expense_checklists`)
- Display names: Vietnamese descriptive names

## CI/CD Workflows

GitHub Actions workflow `.github/workflows/validate.yml` runs on push/PR to main:

1. **validate**: JSON schema validation (ajv), markdown linting, PowerShell syntax check
2. **test**: Installs PnP.PowerShell, validates deployment scripts exist, runs Pester tests
3. **deploy-test**: Deploys to Test environment on push to main
4. **deploy-prod**: Deploys to Production (manual trigger via `workflow_dispatch`)

## Pre-commit Hook

The hook at `tools/hooks/pre-commit` runs automatically on commit:
- JSON syntax validation on all staged `.json` files
- AJV schema validation on staged `datamodel/sharepoint/lists/**/*.json` (if `ajv` is installed)
- PascalCase field naming check on staged list definitions (if `pwsh` is available)

Install: `cp tools/hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`

## Key Files

- `idop.ps1`: Unified CLI wrapper for all operations
- `README.md`: Main documentation with architecture diagrams
- `tools/config/environments.psd1`: Centralized environment configuration
- `tools/scripts/modules/`: Shared PowerShell modules
- `tools/hooks/pre-commit`: Git pre-commit hook (JSON validation, naming checks)

## Testing

The platform uses:
- JSON schema validation for datamodel integrity
- Dry-run mode for all deployment scripts
- PowerShell Pester tests (e.g., `apply-sp-lists.Tests.ps1`)

## Notes

- All PowerShell scripts require PowerShell 7+ and will auto-upgrade if run in Windows PowerShell 5.1
- Scripts use PnP.PowerShell module for SharePoint operations
- The repository follows Vietnamese naming for business entities but uses English for technical components
- Always run dry-run mode first before applying changes to SharePoint
- The platform is designed for government/public sector compliance with audit trails and approval workflows
