# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

IDOP-CCBA-WAY is a digital operations platform (IDOP - Integrated Digital Operation Platform) for CCBA (Center for Consulting Services and BIM Application in construction), a unit under the Institute of Building Science and Technology (IBST). The platform digitizes and automates business processes using Microsoft 365 (SharePoint Online, Power Automate, Power BI, Teams).

This is a **scaffold repository** (reduced from 1.3GB+ to 7.5MB) containing core components for deploying the platform, including SharePoint datamodels, taxonomy definitions, automation scripts, and spec-driven development templates.

## Architecture Overview

The platform follows a spec-driven development approach with 6 core modules:

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

**NEW**: The platform now uses a unified CLI wrapper for all operations. Use `idop.ps1` instead of individual scripts.

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

### Legacy Script Usage (Still Supported)

You can still run scripts directly if needed:

```powershell
# Establish a reusable PnP session
Connect-PnPOnline -Url https://ibstbim.sharepoint.com/sites/idop-dev -Interactive -ClientId 90ded6f0-b787-4b3c-acea-8baf6403fd63

# Use the call operator (&) to run scripts in the same session
& .\tools\scripts\apply-sp-lists.ps1 -Environment Dev -DryRun
```

**Important**: Don't start a new PowerShell process (e.g., `pwsh -File`) for scripts that need PnP connection—use the call operator `&` from the same shell where you ran `Connect-PnPOnline`.

## Development Workflow

### Spec-Driven Development

The repository uses Spec-Kit for AI-assisted development:

1. `/specify` → Generate/update `spec.md` from requirements
2. `/plan` → Generate `plan.md` from spec
3. `/tasks` → Generate `tasks.md` from plan

Prompts are located in `.github/prompts/` and templates in `idop-ccba-way/.specify/templates/`.

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

Managed metadata term sets are in `datamodel/sharepoint/taxonomy/` as JSON files:

- `CCBA_ChucDanhBIM.json`: BIM positions
- `CCBA_ChucDanhXayDung.json`: Construction positions
- `CCBA_DonViPhongBan.json`: Departments
- `CCBA_LoaiChiPhi.json`: Expense types
- `CCBA_LoaiHinhDichVu.json`: Service types
- `CCBA_TrangThaiChung.json`: General statuses
- And 12 more term sets

## Important Conventions

### Shared Modules

The platform now uses shared PowerShell modules for common functionality:

- **PnPHelpers.psm1**: PnP connection management, session handling, retry logic
- **LoggingHelpers.psm1**: Consistent logging, formatting, progress tracking, timers
- **ValidationHelpers.psm1**: Schema validation, naming conventions, data integrity checks

Located in `tools/scripts/modules/`. Import in your scripts:

```powershell
$ModulePath = Join-Path $PSScriptRoot "modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force
Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
Import-Module "$ModulePath/ValidationHelpers.psm1" -Force
```

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

GitHub Actions workflows in `.github/workflows/`:

- `validate.yml`: Validates JSON schemas and markdown linting
- `sp-guard.yml`: SharePoint schema validation
- `taxonomy-sync.yml`: Taxonomy synchronization
- `power-alm.yml`: Power Platform ALM

## Key Files

- `idop.ps1`: **NEW** Unified CLI wrapper for all operations
- `REFACTORING.md`: **NEW** Refactoring guide and migration instructions
- `README.md`: Main documentation with architecture diagrams
- `README-SCAFFOLD.md`: Scaffold usage guide
- `copilot-instructions.md`: GitHub Copilot instructions
- `.speckit.yml`: Spec-Kit configuration
- `constitution.md`: Development rules (in `idop-ccba-way/.specify/memory/`)
- `tools/config/environments.psd1`: **NEW** Centralized environment configuration
- `tools/scripts/modules/`: **NEW** Shared PowerShell modules

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
