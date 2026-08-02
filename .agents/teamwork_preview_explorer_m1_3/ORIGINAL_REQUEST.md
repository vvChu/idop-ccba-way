## 2026-08-02T07:49:34Z
You are Explorer 3 (teamwork_preview_explorer) for Milestone 1 of project IDOP-CCBA-WAY.
Working directory: d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_3

Your task is to inspect all existing JSON schemas in `datamodel/sharepoint/lists/process_execution/` as well as other list directories in `datamodel/sharepoint/lists/` and `tools/idop.ps1` validator logic.

DO NOT read old files from previous runs. Freshly inspect:
- `tools/idop.ps1` and validator modules in `tools/` to understand how schema fields, types, choices, lookup lists, and lookup fields are validated.
- All existing JSON schemas in `datamodel/sharepoint/lists/process_execution/` to understand current structure.

Analyze and design the exact JSON schema specifications for R1:
1. `contract_scopes.json`: Add financial tier 1 allocation fields (`NhomHopDongKT`, `TyLeGiaoDonVi`, `TyLeVienCPQL`, `TyLeVienKHTS`, `GiaTriGiaoDonVi`).
2. `scope_department_allocations.json` [NEW]: Create schema for multi-department scope allocations (`ContractScopeId`, `Department`, `Role`, `AllocationShare`, `AllocatedAmount`, `DepartmentHead`). Must define valid Lookup reference to `ContractScopes`.
3. `projects.json`: Add `NationalProjectID` and `ServiceType`.
4. `job_assignments.json`: Add `ContractScopeId`, `ContractLeadUser`, `DesignChiefUser`, `FinancialOfficerUser`.
5. `assignment_details.json`: Add `ContractScopeId`, `ScopeDeptAllocId`, `GenericRoleName`, `AssignedTechnicalChiefUser`, `ResolvedLegalRole`, `RequiresCertCheck`, `DisciplineLead`, `TeamMembers`, `QCChecker`, `AllocatedHours`. Must define valid Lookup references to `JobAssignments`, `ContractScopes`, and `ScopeDepartmentAllocations`.
6. `cde_documents.json`: Update ISO 19650 approval status (`S0`->`S1`->`S2`->`S3`->`A1`) and naming metadata fields.

Write your complete field-by-field JSON design recommendations to `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_3\schema_design.md` and write a 5-component handoff report at `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_3\handoff.md`.
Send a completion message when done.
