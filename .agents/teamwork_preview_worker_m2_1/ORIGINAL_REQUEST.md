## 2026-08-02T07:50:20Z

You are Worker 1 (teamwork_preview_worker) for Milestone 2 of project IDOP-CCBA-WAY.
Working directory: d:\idop-ccba-way\.agents\teamwork_preview_worker_m2_1

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your task is to implement the 6 target SharePoint list JSON schemas in `datamodel/sharepoint/lists/process_execution/`:
1. `contract_scopes.json`: Update schema with financial tier 1 allocation fields (`NhomHopDongKT`, `TyLeGiaoDonVi`, `TyLeVienCPQL`, `TyLeVienKHTS`, `GiaTriGiaoDonVi`).
2. `scope_department_allocations.json` [NEW]: Create schema for multi-department scope allocations (`ContractScopeId`, `Department`, `Role`, `AllocationShare`, `AllocatedAmount`, `DepartmentHead`). Must define valid Lookup reference to `ContractScopes`.
3. `projects.json`: Add `NationalProjectID` and `ServiceType`.
4. `job_assignments.json`: Add `ContractScopeId`, `ContractLeadUser`, `DesignChiefUser`, `FinancialOfficerUser`.
5. `assignment_details.json`: Add `ContractScopeId`, `ScopeDeptAllocId`, `GenericRoleName`, `AssignedTechnicalChiefUser`, `ResolvedLegalRole`, `RequiresCertCheck`, `DisciplineLead`, `TeamMembers`, `QCChecker`, `AllocatedHours`. Must define valid Lookup references to `JobAssignments`, `ContractScopes`, and `ScopeDepartmentAllocations`.
6. `cde_documents.json`: Update ISO 19650 approval status (`S0`->`S1`->`S2`->`S3`->`A1`) and naming metadata fields (`Originator`, `ZoneVolume`, `LevelLocation`, `IsoDocumentName`).

Refer to the design specifications in `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_1\schema_design.md` for exact JSON structure.

After modifying/creating the JSON files, execute `.\idop.ps1 validate datamodel` using `run_command` to verify that all list schemas pass validation cleanly with 0 errors.

Write your implementation report to `d:\idop-ccba-way\.agents\teamwork_preview_worker_m2_1\changes.md` and write a 5-component handoff report at `d:\idop-ccba-way\.agents\teamwork_preview_worker_m2_1\handoff.md`.
Send a completion message when done.
