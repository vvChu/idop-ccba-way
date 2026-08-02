# Implementation Changes Report — Milestone 2 (M2)

**Worker**: Worker 1 (`teamwork_preview_worker_m2_1`)  
**Date**: 2026-08-02  
**Target Module**: `datamodel/sharepoint/lists/process_execution/`

---

## 1. Summary of Changes

| # | List JSON File | Action | Summary of Changes | Total Fields |
|---|---|---|---|:---:|
| 1 | `contract_scopes.json` | Update | Verified and formatted schema with Tier 1 financial allocation fields (`NhomHopDongKT`, `TyLeGiaoDonVi`, `GiaTriGiaoDonVi`, `TyLeVienCPQL`, `GiaTriVienCPQL`, `TyLeVienKHTS`, `GiaTriVienKHTS`, `KhungNhanCongMin`, `KhungNhanCongMax`). Lookup target: `Contracts`. | 12 |
| 2 | `scope_department_allocations.json` | **NEW** | Created list schema for multi-department scope allocation breakdown (`ContractScopeId`, `Department`, `Role`, `AllocationShare`, `AllocatedAmount`, `DepartmentHead`). Lookup target: `ContractScopes`. | 6 |
| 3 | `projects.json` | Update | Added `NationalProjectID` (National/IBST project identifier) and `ServiceType` (Taxonomy `CCBA_LoaiHinhDichVu`). Lookup target: `Contracts`. | 11 |
| 4 | `job_assignments.json` | Update | Added `ContractScopeId` (Lookup `ContractScopes`), `ContractLeadUser` (User PM), `DesignChiefUser` (User Design Lead), `FinancialOfficerUser` (User Accountant). Header list for Phiếu Giao Việc (PGV). | 9 |
| 5 | `assignment_details.json` | Update | Added `ContractScopeId` (Lookup `ContractScopes`), `ScopeDeptAllocId` (Lookup `ScopeDepartmentAllocations`), `GenericRoleName`, `AssignedTechnicalChiefUser`, `ResolvedLegalRole`, `RequiresCertCheck`, `DisciplineLead`, `TeamMembers`, `QCChecker`, `AllocatedHours`. Detail list for PGV items. | 14 |
| 6 | `cde_documents.json` | Update | Added ISO 19650 metadata fields (`Originator`, `ZoneVolume`, `LevelLocation`, `IsoDocumentName`) and updated `ApprovalStatus` choice values to ISO 5-state lifecycle (`S0`, `S1`, `S2`, `S3`, `A1`). | 18 |

---

## 2. Detailed File Modifications

### 2.1 `datamodel/sharepoint/lists/process_execution/contract_scopes.json`
- **ListName**: `ContractScopes`
- **Fields**:
  - `ContractId` (Lookup -> `Contracts`)
  - `NhomHopDongKT` (ManagedMetadata -> `CCBA_NhomHopDongKT`)
  - `ScopeName` (Text)
  - `AmountBeforeVAT` (Number)
  - `TyLeGiaoDonVi` (Number)
  - `GiaTriGiaoDonVi` (Number)
  - `TyLeVienCPQL` (Number)
  - `GiaTriVienCPQL` (Number)
  - `TyLeVienKHTS` (Number)
  - `GiaTriVienKHTS` (Number)
  - `KhungNhanCongMin` (Number)
  - `KhungNhanCongMax` (Number)

### 2.2 `datamodel/sharepoint/lists/process_execution/scope_department_allocations.json` [NEW]
- **ListName**: `ScopeDepartmentAllocations`
- **Fields**:
  - `ContractScopeId` (Lookup -> `ContractScopes`, Required: `true`)
  - `Department` (ManagedMetadata -> `CCBA_DonViPhongBan`, Required: `true`)
  - `Role` (Text)
  - `AllocationShare` (Number)
  - `AllocatedAmount` (Number)
  - `DepartmentHead` (User, UserSelectionMode: `PeopleOnly`)

### 2.3 `datamodel/sharepoint/lists/process_execution/projects.json`
- **ListName**: `Projects`
- **Fields Added**:
  - `NationalProjectID` (Text, Description: "Mã định danh dự án cấp quốc gia / Viện IBST theo QCTK 2815")
  - `ServiceType` (ManagedMetadata -> `CCBA_LoaiHinhDichVu`)

### 2.4 `datamodel/sharepoint/lists/process_execution/job_assignments.json`
- **ListName**: `JobAssignments`
- **Fields Added**:
  - `ContractScopeId` (Lookup -> `ContractScopes`)
  - `ContractLeadUser` (User, UserSelectionMode: `PeopleOnly`)
  - `DesignChiefUser` (User, UserSelectionMode: `PeopleOnly`)
  - `FinancialOfficerUser` (User, UserSelectionMode: `PeopleOnly`)

### 2.5 `datamodel/sharepoint/lists/process_execution/assignment_details.json`
- **ListName**: `AssignmentDetails`
- **Fields Added**:
  - `ContractScopeId` (Lookup -> `ContractScopes`)
  - `ScopeDeptAllocId` (Lookup -> `ScopeDepartmentAllocations`)
  - `GenericRoleName` (Text)
  - `AssignedTechnicalChiefUser` (User, UserSelectionMode: `PeopleOnly`)
  - `ResolvedLegalRole` (Text)
  - `RequiresCertCheck` (YesNo)
  - `DisciplineLead` (User, UserSelectionMode: `PeopleOnly`)
  - `TeamMembers` (User, AllowMultiple: `true`, UserSelectionMode: `PeopleOnly`)
  - `QCChecker` (User, UserSelectionMode: `PeopleOnly`)
  - `AllocatedHours` (Number)

### 2.6 `datamodel/sharepoint/lists/process_execution/cde_documents.json`
- **ListName**: `CDEDocuments`
- **Fields Added / Updated**:
  - `Originator` (Text, ISO 19650 author/creator code)
  - `ZoneVolume` (Text, ISO 19650 zone/volume code)
  - `LevelLocation` (Text, ISO 19650 level/location code)
  - `IsoDocumentName` (Text, ISO 19650 standard container name)
  - `ApprovalStatus` (Choice: `["S0", "S1", "S2", "S3", "A1"]`, 5-stage ISO approval status)

---

## 3. Validation Results

Execution of `.\idop.ps1 validate datamodel`:

```text
Running Validation
==================
? Validating entire datamodel...

Summary
-------
  Lists Checked             : 59
  Lists Valid               : 59
  Taxonomy Checked          : 21
  Taxonomy Valid            : 21
  Total Errors              : 0

 All validations passed
```
