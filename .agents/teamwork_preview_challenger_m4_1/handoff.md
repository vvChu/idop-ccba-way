# Milestone 4 Handoff & Empirical Validation Report — Empirical Challenger

**Agent Role**: Challenger 1 (`teamwork_preview_challenger`)  
**Working Directory**: `d:\idop-ccba-way\.agents\teamwork_preview_challenger_m4_1`  
**Target Milestone**: Milestone 4 — Stress Test & Empirical Validation  
**Date**: 2026-08-02  

---

## 1. Observation

### 1.1 CLI Validator Execution (`.\idop.ps1 validate datamodel`)
Command executed:
```powershell
.\idop.ps1 validate datamodel
```
Verbatim CLI Output:
```
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
   Operation completed successfully
```
Exit code: `0`.

### 1.2 Schema JSON & Taxonomy Inspection Findings
- **Total List Schemas**: 59 list JSON files found in `datamodel/sharepoint/lists/`.
- **JSON Schema Conformance**: Evaluated all 59 list schemas against `datamodel/sharepoint/schemas/sp-list.schema.json` using Python `jsonschema`:
  - `59/59` files are 100% compliant with `sp-list.schema.json`.
- **Taxonomy Term Set Bindings**:
  - `44` columns across the 59 list schemas use `Type: "ManagedMetadata"` with a `TermSet` property binding.
  - All 44 columns correctly reference one of the `21` taxonomy JSON files located in `datamodel/sharepoint/taxonomy/` (e.g. `CCBA_LoaiChiPhi`, `CCBA_TrangThaiChung`, `CCBA_DonViPhongBan`, etc.).
  - Zero missing, dangling, or misspelled taxonomy term set references.
- **Lookup Field References**:
  - `62` columns across the 59 list schemas use `Type: "Lookup"` or `Type: "LookupMulti"`.
  - All 62 lookup fields reference valid, existing target lists and valid target fields (built-in `ID` or explicit list columns).

### 1.3 CLI Validator Logic Flaw (`ValidationHelpers.psm1`)
Inspection of `tools/scripts/modules/ValidationHelpers.psm1` lines 325–327 revealed a flaw in function `Test-IDOPLookupReferences`:
```powershell
# ValidationHelpers.psm1 lines 322-327
foreach ($listName in $allLists.Keys) {
    $list = $allLists[$listName]
    foreach ($field in $list.Fields) {   # <--- FLAW: Schemas use $json.Columns, NOT $json.Fields
        if ($field.Type -eq 'Lookup' -or $field.Type -eq 'LookupMulti') {
            $lookupList = $field.LookupList  # <--- FLAW: Schemas use $field.Lookup.List
```
Because `Test-IDOPLookupReferences` looks for `$list.Fields` and `$field.LookupList` instead of `$list.Columns` and `$field.Lookup.List`, running `.\idop.ps1 validate lookups` evaluates 0 fields and falsely reports `All lookup references are valid (59 lists checked)`.

### 1.4 Target Process Execution Lookup Graph Analysis
Inspected the 5 targeted process execution lists:
1. **`AssignmentDetails`** (`datamodel/sharepoint/lists/process_execution/assignment_details.json`):
   - Outgoing lookups:
     - `AssignmentId` (Lookup) -> `JobAssignments.ID` [Behavior: `restrict`]
     - `ContractScopeId` (Lookup) -> `ContractScopes.ID` [Behavior: `restrict`]
     - `ScopeDeptAllocId` (Lookup) -> `ScopeDepartmentAllocations.ID` [Behavior: `restrict`]
2. **`JobAssignments`** (`datamodel/sharepoint/lists/process_execution/job_assignments.json`):
   - Outgoing lookups:
     - `ProjectId` (Lookup) -> `Projects.ID` [Behavior: `restrict`]
     - `ContractScopeId` (Lookup) -> `ContractScopes.ID` [Behavior: `restrict`]
     - `EmployeeId` (Lookup) -> `Employees.ID` [Behavior: `restrict`]
3. **`ScopeDepartmentAllocations`** (`datamodel/sharepoint/lists/process_execution/scope_department_allocations.json`):
   - Outgoing lookups:
     - `ContractScopeId` (Lookup) -> `ContractScopes.ID` [Behavior: `restrict`]
4. **`ContractScopes`** (`datamodel/sharepoint/lists/process_execution/contract_scopes.json`):
   - Outgoing lookups:
     - `ContractId` (Lookup) -> `Contracts.ID` [Behavior: `restrict`]
5. **`Projects`** (`datamodel/sharepoint/lists/process_execution/projects.json`):
   - Outgoing lookups:
     - `ContractId` (Lookup) -> `Contracts.ID` [Behavior: `restrict`]

All target entities exist, all target primary key fields (`ID`) are valid standard SharePoint item keys, and all 5 lists form a closed, non-broken graph rooted at `Contracts`.

---

## 2. Logic Chain

1. **Step 1 (CLI Tool Execution)**: Executed `.\idop.ps1 validate datamodel` via `run_command`. Observed process output reporting 59 lists checked, 21 taxonomy files checked, 0 errors, and exit code 0.
2. **Step 2 (Empirical Independent Schema Validation)**: Developed and executed `verify_datamodel.py` to independently validate all 59 list JSON files against `sp-list.schema.json` and verify term set/lookup bindings:
   - Validated that 44 `ManagedMetadata` columns resolve to the 21 taxonomy term set files in `datamodel/sharepoint/taxonomy/`.
   - Validated that 62 `Lookup`/`LookupMulti` columns resolve to valid target list names and target field names.
3. **Step 3 (Validator Code Audit)**: Audited `ValidationHelpers.psm1` to verify if the CLI validator actually inspected lookups. Found that `Test-IDOPLookupReferences` used `$list.Fields` and `$field.LookupList`, which caused the CLI lookup validator sub-command to silently skip evaluating fields while reporting success.
4. **Step 4 (Graph Topology Analysis)**: Traced foreign keys between `AssignmentDetails`, `JobAssignments`, `ScopeDepartmentAllocations`, `ContractScopes`, and `Projects`. Confirmed that foreign key references point exclusively to valid lists (`JobAssignments`, `ContractScopes`, `ScopeDepartmentAllocations`, `Projects`, `Contracts`, `Employees`) and primary key `ID`. Confirmed no dangling edges or broken references exist.

---

## 3. Caveats

- **Runtime SharePoint API Verification**: The tests performed in this report validate the static data model schemas and local CLI scripts. Live PnP PowerShell provisioning against a live SharePoint Online site (`https://ibstbim.sharepoint.com/sites/idop`) was not executed as part of this static/local CLI datamodel validation turn.
- **No code changes applied**: In accordance with the Review-Only / Empirical Challenger constraint, `ValidationHelpers.psm1` was not modified in-place; the finding is documented for remediation.

---

## 4. Conclusion

- **Overall Status**: **PASS with 1 Remediation Finding**.
- **Data Model Schema Quality**: All 59 list schemas and 21 taxonomy term set definitions are 100% structurally valid and internally consistent.
- **Lookup Graph Integrity**: The 5 targeted process execution entities (`AssignmentDetails`, `JobAssignments`, `ScopeDepartmentAllocations`, `ContractScopes`, `Projects`) form a closed, fully consistent relational graph with zero broken references.
- **Actionable Remediation**: Update `Test-IDOPLookupReferences` in `tools/scripts/modules/ValidationHelpers.psm1` to reference `$list.Columns` and `$field.Lookup.List` so that `.\idop.ps1 validate lookups` actively checks lookup fields during automated validation runs.

---

## 5. Verification Method

To independently reproduce and verify these findings:

1. **Run CLI Validator**:
   ```powershell
   .\idop.ps1 validate datamodel
   ```
   Confirm exit code is 0 and output reports 0 errors.

2. **Run Empirical Python Verification Script**:
   ```powershell
   python d:\idop-ccba-way\.agents\teamwork_preview_challenger_m4_1\verify_datamodel.py
   ```
   Confirm 59 list schemas loaded, 21 taxonomy term sets loaded, 44 taxonomy columns verified valid, 62 lookup columns verified valid, and deep graph relationships displayed.

---

## 6. Challenge Report (Adversarial Stress Test)

### Challenge Summary
- **Overall Risk Assessment**: **LOW**.
- The underlying JSON data model schemas, taxonomy definitions, and relational lookup graphs are 100% valid and structurally sound.
- The only vulnerability identified is a false-positive blind spot in one specific CLI helper function (`Test-IDOPLookupReferences`), which passed trivially due to schema property path mismatch.

### Challenges

#### [Medium] Challenge 1: CLI Lookup Reference Validator (`Test-IDOPLookupReferences`) Blind Spot
- **Assumption challenged**: `.\idop.ps1 validate lookups` actively validates lookup references across all SharePoint list schemas.
- **Attack scenario**: If a developer introduces a typo in a lookup target list (e.g. `Lookup.List: "Project"` instead of `"Projects"`), `.\idop.ps1 validate lookups` would still report `All lookup references are valid (59 lists checked)` because it iterates over `$list.Fields` (which is `$null`), ignoring `$list.Columns`.
- **Blast radius**: Broken lookup references in schema definitions could pass local CLI validation and fail during SharePoint site deployment (`.\idop.ps1 deploy lists`).
- **Mitigation**: Update `ValidationHelpers.psm1` line 325 to iterate over `$list.Columns` and read `$field.Lookup.List`.

### Stress Test Results

| Scenario | Expected Behavior | Actual Behavior | Result |
|:---|:---|:---|:---|
| `.\idop.ps1 validate datamodel` execution | Exit code 0, 0 errors | Exit code 0, 0 errors | **PASS** |
| Schema JSON syntax & `sp-list.schema.json` validation | 59/59 list JSON files valid | 59/59 list JSON files valid | **PASS** |
| Taxonomy binding verification | 44/44 ManagedMetadata columns match taxonomy term set files | 44/44 ManagedMetadata columns match taxonomy term set files | **PASS** |
| Cross-list lookup reference resolution | All 62 Lookup target lists & fields resolve | All 62 Lookup target lists & fields resolve | **PASS** |
| 5-List Graph Integrity (`AssignmentDetails` -> `Projects`) | Closed, valid graph without missing keys | Closed, valid graph without missing keys | **PASS** |
| CLI `validate lookups` helper accuracy test | Helper actively checks `Lookup.List` property | Helper checked `$list.Fields` ($null) | **FAIL (Defect logged)** |

### Unchallenged Areas
- Live PnP.PowerShell provisioning against SharePoint Online API endpoint (out of scope for local offline datamodel validation).
