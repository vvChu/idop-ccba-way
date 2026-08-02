# Project: IDOP-CCBA-WAY Data Model & PMO Spec Upgrade

## Architecture
- SharePoint Online List Schemas (`datamodel/sharepoint/lists/process_execution/`)
- Module Specifications (`specs/modules/process_execution/pmo/spec.md`)
- PowerShell CLI Engine (`tools/idop.ps1` -> `validate datamodel`)

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Exploration & Architecture Assessment | Read schemas, validator, specs, and produce field specs | None | DONE |
| M2 | Data Model JSON Schemas Implementation (R1) | Update 5 schemas and create `scope_department_allocations.json` | M1 | DONE |
| M3 | PMO Specification & Documentation Update (R2) | Update `specs/modules/process_execution/pmo/spec.md` | M1 | DONE |
| M4 | Data Model Validation & Final Forensic Audit (R3) | Execute `.\idop.ps1 validate datamodel`, Challenger, and Forensic Audit | M2, M3 | DONE |

## Interface Contracts & Schemas
### 1. `contract_scopes.json`
- `NhomHopDongKT`: Choice (Group 1, Group 2, etc.) / Text
- `TyLeGiaoDonVi`: Number / Float (%)
- `TyLeVienCPQL`: Number / Float (%)
- `TyLeVienKHTS`: Number / Float (%)
- `GiaTriGiaoDonVi`: Currency / Number

### 2. `scope_department_allocations.json` [NEW]
- `ContractScopeId`: Lookup -> `ContractScopes`
- `Department`: Choice / Text
- `Role`: Choice / Text
- `AllocationShare`: Number / Float (%)
- `AllocatedAmount`: Currency / Number
- `DepartmentHead`: User / Principal

### 3. `projects.json`
- `NationalProjectID`: Single line of text
- `ServiceType`: Choice / Text

### 4. `job_assignments.json`
- `ContractScopeId`: Lookup -> `ContractScopes`
- `ContractLeadUser`: User / Principal
- `DesignChiefUser`: User / Principal
- `FinancialOfficerUser`: User / Principal

### 5. `assignment_details.json`
- `ContractScopeId`: Lookup -> `ContractScopes`
- `ScopeDeptAllocId`: Lookup -> `ScopeDepartmentAllocations`
- `GenericRoleName`: Text
- `AssignedTechnicalChiefUser`: User / Principal
- `ResolvedLegalRole`: Text / Choice
- `RequiresCertCheck`: Boolean
- `DisciplineLead`: User / Principal
- `TeamMembers`: User (Multi)
- `QCChecker`: User / Principal
- `AllocatedHours`: Number

### 6. `cde_documents.json`
- Approval Status lifecycle: S0 -> S1 -> S2 -> S3 -> A1
- Naming metadata fields: ISO 19650 compliant metadata

## Code Layout
- Schemas: `datamodel/sharepoint/lists/process_execution/*.json`
- Specs: `specs/modules/process_execution/pmo/spec.md`
- CLI: `idop.ps1` / `tools/`
