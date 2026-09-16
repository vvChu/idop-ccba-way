# Technical Analysis Report: Core Modules 4–6 (`people_assets`, `performance_okrs`, `system_governance`)

**Target Repository**: `idop-ccba-way`  
**Milestone**: Milestone 2 (Part B) — Technical Deep-Dive  
**Author**: Explorer 3 (`teamwork_preview_explorer_m2_peop_perf_sys`)  
**Date**: 2026-07-28  

---

## 1. Executive Summary

This technical analysis covers the data model, entity relationships, SharePoint lookup structure, taxonomy term sets (Managed Metadata), and spec vs JSON schema alignment for the following three core modules of the `idop-ccba-way` platform:

1. **Module 4: `people_assets`** — HR, Assets, Timesheets (`cham_cong`), Organizational Structure (`so_do_to_chuc`).
2. **Module 5: `performance_okrs`** — OKRs, KPIs, Scorecards, Performance Measurement.
3. **Module 6: `system_governance`** — Approvals system, Dynamic Forms, Workflows, System Environment Variables.

### Key Findings Across Modules 4–6
- **Total Entities Analyzed**: 21 SharePoint lists across 3 core modules (12 in `people_assets`, 5 in `performance_okrs`, 4 in `system_governance`).
- **Referential Integrity**: All single-list foreign keys use `Type: "Lookup"` with `"Behavior": "restrict"`, protecting parent entities against cascade deletion. However, cross-module relationships (e.g., `ProjectMembers` → `Projects`, `Submissions` → `Contract`/`Invoice`/`Expense`/`Project`) use either hard lookups to external lists or soft string key pairs (`RelatedEntity` + `RelatedId`).
- **Taxonomy Utilization**: Managed Metadata fields are used selectively (`CCBA_TrangThaiNhanSu`, `CCBA_TrangThaiTaiSan`, `CCBA_TrangThaiPheDuyet`). Module 5 (`performance_okrs`) has **0** taxonomy integrations. Key corporate taxonomies like `CCBA_DonViPhongBan` (Department structure) and `CCBA_ChucDanhBIM` / `CCBA_ChucDanhXayDung` (Job titles) exist in the taxonomy term store but are NOT linked in `employees.json` or `departments.json`.
- **Spec vs Schema Discrepancies**:
  - The specification markdown files (`spec.md`) for `hr`, `performance`, `reports`, `approvals`, `forms`, and `governance` are empty template skeletons containing placeholder headers. Only `assets/spec.md` contains functional user stories.
  - **Module 6 Critical Gap**: Dynamic Forms (`forms`) is specified as a core module topic, but **zero** form definition schemas (`FormDefinitions`, `FormFields`, `FormResponses`) exist in `datamodel/sharepoint/lists/system_governance/`.
  - **Schema Bug**: `submissions.json` has an incorrect relative `$schema` path (`../../schemas/sp-list.schema.json` instead of `datamodel/sharepoint/schemas/sp-list.schema.json`).

---

## 2. Deep-Dive Analysis: Module 4 (`people_assets`)

### 2.1 Entities List
Module 4 consists of 12 SharePoint list entities located in `datamodel/sharepoint/lists/people_assets/`:

| List Name | Display Name | Internal Name | Purpose & Business Function |
|---|---|---|---|
| `Departments` | Departments | `Departments` | Stores organizational department hierarchy, department codes, and department manager assignments. |
| `Employees` | Employees | `Employees` | Master employee profile, tracking full names, employee codes, assigned department, position, hire date, and HR lifecycle status. |
| `Assets` | Assets | `Assets` | Equipment and asset inventory master list, recording asset names, asset codes, current assignee, purchase date, and lifecycle status. |
| `Timesheets` | Timesheets | `Timesheets` | Employee timekeeping / work hours log (`cham_cong`), recording date, hours worked, and notes per employee. |
| `BenefitPackages` | BenefitPackages | `BenefitPackages` | Catalog of standard company benefit packages and descriptions. |
| `Certifications` | Certifications | `Certifications` | Professional certificates earned by employees, issuing institution, issue date, and expiration date. |
| `EmployeeBenefits` | EmployeeBenefits | `EmployeeBenefits` | Junction entity assigning specific `BenefitPackages` to `Employees` with start and end dates. |
| `EmployeeHistory` | EmployeeHistory | `EmployeeHistory` | Audit trail of employee employment status history over time with current status flag (`IsCurrent`). |
| `EmploymentContracts` | EmploymentContracts | `EmploymentContracts` | Labor contracts recording contract numbers, start/end dates, and contract types (`Full-time`, `Part-time`, `Internship`, `Freelance`). |
| `MaintenanceLogs` | MaintenanceLogs | `MaintenanceLogs` | Log of maintenance/repair events performed on specific `Assets`, recording date, description, and servicing user. |
| `ProjectMembers` | ProjectMembers | `ProjectMembers` | Junction entity assigning `Employees` to `Projects` (`process_execution`) with project-specific roles. |
| `Rewards` | Rewards | `Rewards` | Commendations, rewards, and recognition records for employees. |

### 2.2 Lookup Relationships & Referential Integrity
The diagram below illustrates the lookup dependency tree for `people_assets`:

```
Departments (Root)
   └── Employees (Core)
         ├── Assets └── MaintenanceLogs
         ├── Timesheets
         ├── Certifications
         ├── EmployeeBenefits (Junction: Employees + BenefitPackages)
         ├── EmployeeHistory
         ├── EmploymentContracts
         ├── ProjectMembers (Junction: Employees + Projects [cross-module])
         └── Rewards
```

#### Detailed Lookup Mapping Table

| Source List | Lookup Field Internal Name | Target List | Target Field | Delete Behavior | Display Field / Purpose |
|---|---|---|---|---|---|
| `Employees` | `DepartmentId` | `Departments` | `ID` | `restrict` | Primary department assignment |
| `Assets` | `AssignedTo` | `Employees` | `ID` | `restrict` | Current employee holding/using the asset |
| `Timesheets` | `EmployeeId` | `Employees` | `ID` | `restrict` | Employee logging hours |
| `Certifications` | `EmployeeId` | `Employees` | `ID` | `restrict` | Certificate holder |
| `EmployeeBenefits` | `EmployeeId` | `Employees` | `ID` | `restrict` | Employee receiving benefit |
| `EmployeeBenefits` | `BenefitPackageId` | `BenefitPackages` | `ID` | `restrict` | Benefit package assigned |
| `EmployeeHistory` | `EmployeeId` | `Employees` | `ID` | `restrict` | Employee historical audit record |
| `EmploymentContracts` | `EmployeeId` | `Employees` | `ID` | `restrict` | Contract holder |
| `MaintenanceLogs` | `AssetId` | `Assets` | `ID` | `restrict` | Asset undergoing maintenance |
| `ProjectMembers` | `EmployeeId` | `Employees` | `ID` | `restrict` | Project member employee |
| `ProjectMembers` | `ProjectId` | `Projects` | `ID` | `restrict` | Cross-module link to `process_execution/projects.json` |
| `Rewards` | `EmployeeId` | `Employees` | `ID` | `restrict` | Commended employee |

### 2.3 Taxonomy Term Sets Mapping
The following taxonomy term sets in `datamodel/sharepoint/taxonomy/` are bound or relevant to `people_assets`:

| Term Set Name | Term Set ID | Target List & Field | Terms / Values | Business Logic & Usage |
|---|---|---|---|---|
| `CCBA_TrangThaiNhanSu` | `f0e8b6a3-7d1b-4b0e-9c3f-9a1b2c3d4e06` | `Employees.Status` (`ManagedMetadata`) | `Ứng tuyển`, `Thử việc`, `Chính thức`, `Tạm nghỉ`, `Chấm dứt` | HR employee lifecycle state machine. Controls active employment status vs probation vs termination. |
| `CCBA_TrangThaiTaiSan` | `c3b1a9a4-2e3f-4b1a-a7f8-4d1c0b8cbf01` | `Assets.Status` (`ManagedMetadata`) | `Mới nhập`, `Đang sử dụng`, `Bảo trì`, `Tạm dừng`, `Thanh lý` | Asset operational status. Triggers maintenance workflows or marks assets available for assignment/disposal. |
| `CCBA_DonViPhongBan` *(Unlinked)* | `2690649d-4d2c-409b-b3e8-176e7d16ea8c` | `Departments.DepartmentName` *(Currently plain Text)* | `100. BAN LÃNH ĐẠO`, `200. KHỐI VĂN PHÒNG`, `300. KHỐI CHUYÊN MÔN`, `IBST` | Official corporate department taxonomy. Should be bound to `Departments` or `Employees` to standardize department names. |
| `CCBA_ChucDanhBIM` *(Unlinked)* | `7011cab3-1146-469f-a9ae-911ec8115549` | `Employees.Position` *(Currently plain Text)* | `Giám đốc BIM`, `Quản lý BIM`, `Điều phối viên BIM`, `BIM Modeler`, `Dynamo/Python Developer` | Standardized job titles for BIM technical roles. Currently `Employees.Position` is an unstructured Text field. |

### 2.4 Spec vs JSON Schema Audit (`people_assets`)
- **Spec Completeness Gap**: `specs/modules/people_assets/hr/spec.md` is empty (template headers only). `assets/spec.md` outlines functional requirements for tracking asset position, assignment, maintenance, and depreciation calculations.
- **Financial & Depreciation Fields Missing in `assets.json`**:
  ```json
  // Current assets.json schema:
  { "Name": "AssetName", "Type": "Text", "Required": true },
  { "Name": "AssetCode", "Type": "Text" },
  { "Name": "AssignedTo", "Type": "Lookup", "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "PurchaseDate", "Type": "DateTime" },
  { "Name": "Status", "Type": "ManagedMetadata", "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiTaiSan" } }
  ```
  *Audit Note*: Spec calls for financial depreciation reporting (`tính toán khấu hao và giá trị tài sản`). However, `assets.json` lacks financial columns (`PurchaseCost`, `ResidualValue`, `DepreciationMethod`, `DepreciationPeriodMonths`, `Location`, `SerialNumber`).
- **Timesheet Granularity Gap**: `timesheets.json` contains only `EmployeeId`, `Date`, `HoursWorked`, `Notes`. It lacks `ProjectId` or `WorkPackageId` lookup, making it impossible to attribute time entry to specific construction/BIM project packages for cost accounting (`cham_cong theo dự án`).
- **Organigram Hierarchy Gap**: `departments.json` lacks `ParentDepartmentId` (Lookup to `Departments`), preventing multi-level organizational chart modeling (`so_do_to_chuc`).

---

## 3. Deep-Dive Analysis: Module 5 (`performance_okrs`)

### 3.1 Entities List
Module 5 consists of 5 SharePoint list entities located in `datamodel/sharepoint/lists/performance_okrs/`:

| List Name | Display Name | Internal Name | Purpose & Business Function |
|---|---|---|---|
| `Quarters` | Quarters | `Quarters` | Time period master list defining operational quarters (`Year`, `Quarter` choice Q1-Q4, `StartDate`, `EndDate`). |
| `OKRS_Objectives` | OKRS_Objectives | `OKRS_Objectives` | Qualitative objectives defined per quarter (`ObjectiveTitle`, `Owner`, `QuarterId`, `Description`). |
| `OKRS_KeyResults` | OKRS_KeyResults | `OKRS_KeyResults` | Quantitative targets linked to objectives (`ObjectiveId`, `KeyResultTitle`, `TargetValue`, `CurrentValue`). |
| `Measurables` | Measurables | `Measurables` | Master metric catalog defining KPI metrics (`MetricName`, `Unit`, `Description`). |
| `ScorecardData` | ScorecardData | `ScorecardData` | Time-series scorecard data points recording actual values for metrics across periods (`PeriodType`, `PeriodKey`, `Value`). |

### 3.2 Lookup Relationships & Referential Integrity
The diagram below shows the structural hierarchy of `performance_okrs`:

```
Quarters
   └── OKRS_Objectives
         └── OKRS_KeyResults

Measurables
   └── ScorecardData
```

#### Detailed Lookup Mapping Table

| Source List | Lookup Field Internal Name | Target List | Target Field | Delete Behavior | Display Field / Purpose |
|---|---|---|---|---|---|
| `OKRS_Objectives` | `QuarterId` | `Quarters` | `ID` | `restrict` | Links objective to specific fiscal quarter |
| `OKRS_KeyResults` | `ObjectiveId` | `OKRS_Objectives` | `ID` | `restrict` | Parent objective for the key result |
| `ScorecardData` | `MetricId` | `Measurables` | `ID` | `restrict` | Metric definition for weekly/monthly/quarterly score tracking |

### 3.3 Taxonomy Term Sets Mapping
- **Current State**: **0** ManagedMetadata fields are defined in `performance_okrs`. All choices use string literals or Choice fields (`Quarter`: `["Q1","Q2","Q3","Q4"]`; `PeriodType`: `["Week","Month","Quarter","Year"]`).
- **Gaps & Opportunity**:
  - Objective levels (Company vs Department vs Individual) could benefit from taxonomy mapping.
  - KPI categories in `Measurables` could be classified via taxonomy terms (e.g. Financial, Operational, Quality, Safety).

### 3.4 Spec vs JSON Schema Audit (`performance_okrs`)
- **Spec Completeness Gap**: `specs/modules/performance_okrs/performance/spec.md` and `reports/spec.md` are empty skeleton files.
- **Structural OKR Cascading Gap**:
  - `OKRS_Objectives` contains:
    ```json
    { "Name": "ObjectiveTitle", "Type": "Text", "Required": true },
    { "Name": "Owner", "Type": "User" },
    { "Name": "QuarterId", "Type": "Lookup", "Lookup": { "List": "Quarters", "Field": "ID", "Behavior": "restrict" } },
    { "Name": "Description", "Type": "Text" }
    ```
    *Audit Note*: OKRs cannot be aligned hierarchically because `OKRS_Objectives` is missing a `ParentObjectiveId` lookup field (Self-lookup) and a `DepartmentId` lookup to `Departments`.
- **Key Result Scoring & Progress Tracking Gap**:
  - `OKRS_KeyResults` only has `TargetValue` and `CurrentValue`. It lacks `StartValue` (needed for progress % calculation), `Unit`, `Status` (On Track / At Risk / Behind), and `Weight`.
- **Scorecard Target & Assignment Gap**:
  - `ScorecardData` records actual `Value` per `PeriodKey` (e.g. `2026-W30`), but `ScorecardData` / `Measurables` has no `TargetValue` field or `Owner`/`DepartmentId` field to measure performance variance (Target vs Actual) per owner.

---

## 4. Deep-Dive Analysis: Module 6 (`system_governance`)

### 4.1 Entities List
Module 6 consists of 4 SharePoint list entities located in `datamodel/sharepoint/lists/system_governance/`:

| List Name | Display Name | Internal Name | Purpose & Business Function |
|---|---|---|---|
| `ApprovalWorkflows` | ApprovalWorkflows | `ApprovalWorkflows` | Header entity for approval workflow definitions, storing `WorkflowName`, `Description`, and step count (`Steps`). |
| `Submissions` | Submissions | `Submissions` | Master approval request ledger storing request title, submitter, submission date, generic target reference (`RelatedEntity`, `RelatedId`), and approval status. |
| `EnvironmentVariables` | EnvironmentVariables | `EnvironmentVariables` | System configuration key-value pairs (`VariableName`, `Value`, `Description`). |
| `IntegrationPoints` | IntegrationPoints | `IntegrationPoints` | System integration endpoint registry (`IntegrationName`, `SystemName`, `APIEndpoint`, `AuthMethod`: `None`/`Basic`/`OAuth2`/`APIKey`). |

### 4.2 Lookup Relationships & Referential Integrity
- **Polymorphic Key Pattern in `Submissions`**:
  ```json
  { "Name": "SubmissionTitle", "Type": "Text", "Required": true },
  { "Name": "RelatedEntity", "Type": "Choice", "Choices": ["Contract","Invoice","Expense","Project"] },
  { "Name": "RelatedId", "Type": "Number" },
  { "Name": "SubmittedBy", "Type": "User" },
  { "Name": "SubmissionDate", "Type": "DateTime" },
  { "Name": "Status", "Type": "ManagedMetadata", "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiPheDuyet" } }
  ```
  *Design Analysis*: `Submissions` uses a composite soft key (`RelatedEntity` + `RelatedId`) to link to items in external lists (`Contracts` in `process_execution`, `Invoices`/`Expenses` in `cash_data`, `Projects` in `process_execution`). This allows a single `Submissions` list to serve as the unified approval hub for multiple modules without creating separate lookup columns for each entity type.
- **Missing Foreign Key to Workflows**: `Submissions` does NOT contain a `WorkflowId` lookup to `ApprovalWorkflows`.

### 4.3 Taxonomy Term Sets Mapping

| Term Set Name | Term Set ID | Target List & Field | Terms / Values | Business Logic & Usage |
|---|---|---|---|---|
| `CCBA_TrangThaiPheDuyet` | `7f6e5d4c-3b2a-1908-7f6e-5d4c3b2a1908` | `Submissions.Status` (`ManagedMetadata`) | `Nháp`, `Đệ trình`, `Yêu cầu bổ sung`, `Phê duyệt`, `Từ chối` | State machine lifecycle for approval submissions. Manages submission workflow progression across all business objects. |

### 4.4 Spec vs JSON Schema Audit (`system_governance`)

#### Critical Discrepancy 1: Missing Dynamic Forms Infrastructure
- **Spec Scope**: Module 6 is explicitly specified to cover "Dynamic Forms" (`forms`).
- **Schema Missing**: There are **NO** list schemas defined for Dynamic Forms in `datamodel/sharepoint/lists/system_governance/` (e.g. `FormDefinitions.json`, `FormFields.json`, `FormSubmissions.json` are absent).

#### Critical Discrepancy 2: Approval Workflow Execution Gaps
- `ApprovalWorkflows.json` contains only:
  ```json
  { "Name": "WorkflowName", "Type": "Text", "Required": true },
  { "Name": "Description", "Type": "Text" },
  { "Name": "Steps", "Type": "Number" }
  ```
  *Gap*: It lacks workflow step configuration details (approver roles per step, threshold rules, auto-approve conditions).
- `Submissions.json` lacks:
  - `WorkflowId` (Lookup to `ApprovalWorkflows`)
  - `CurrentStep` (Number)
  - `ApprovalHistory` / Audit trail (No list or JSON field to log individual approver decisions, comments, timestamps).

#### Critical Discrepancy 3: JSON Schema Relative Path Bug in `submissions.json`
- In `submissions.json` line 2:
  ```json
  "$schema": "../../schemas/sp-list.schema.json"
  ```
- Across all other 51 list JSON files in `datamodel/sharepoint/lists/`:
  ```json
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json"
  ```
  *Audit Note*: `submissions.json` uses an invalid relative `$schema` path format compared to the rest of the repository schema files, breaking schema validation scripts (`validate-sp-schemas.ps1`).

---

## 5. Architectural Synthesis & Recommendations

### 5.1 Immediate Remediation Matrix

| Module | Affected File | Recommended Fix | Priority |
|---|---|---|---|
| `system_governance` | `submissions.json` | Fix `$schema` path to `"datamodel/sharepoint/schemas/sp-list.schema.json"`. Add `WorkflowId` lookup to `ApprovalWorkflows` and `CurrentStep` number field. | **High (Bug)** |
| `system_governance` | *(New Schemas Needed)* | Create `FormDefinitions.json` and `FormFields.json` under `system_governance/` to fulfill the Dynamic Forms scope requirement. | **High** |
| `people_assets` | `assets.json` | Add `PurchaseCost`, `DepreciationPeriodMonths`, `ResidualValue`, `Location`, and `SerialNumber` columns to satisfy asset accounting specs. | **Medium** |
| `people_assets` | `timesheets.json` | Add `ProjectId` lookup to `Projects` and `WorkPackageId` lookup to `WorkPackages` to enable project-level timekeeping (`cham_cong`). | **Medium** |
| `people_assets` | `departments.json` | Add `ParentDepartmentId` lookup (self-referencing `Departments.ID`) to support hierarchical organizational structures (`so_do_to_chuc`). | **Medium** |
| `people_assets` | `employees.json` | Bind `Position` to `CCBA_ChucDanhBIM` or `CCBA_ChucDanhXayDung` taxonomy term sets. | **Low** |
| `performance_okrs` | `okrs_objectives.json` | Add `ParentObjectiveId` (Lookup to `OKRS_Objectives`) and `DepartmentId` (Lookup to `Departments`) for OKR alignment. | **Medium** |
| `performance_okrs` | `okrs_key_results.json` | Add `StartValue`, `Unit`, `Status` (Choice: On Track, At Risk, Behind), and `Weight`. | **Medium** |
| `performance_okrs` | `scorecard_data.json` | Add `TargetValue` field and `DepartmentId` / `Owner` fields to track variance. | **Medium** |

---
