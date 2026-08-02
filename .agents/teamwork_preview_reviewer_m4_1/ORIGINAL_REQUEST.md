## 2026-08-02T07:51:15Z

You are Reviewer 1 (teamwork_preview_reviewer) for Milestone 4 of project IDOP-CCBA-WAY.
Working directory: d:\idop-ccba-way\.agents\teamwork_preview_reviewer_m4_1

Your task is to independently review and verify the 6 updated/created SharePoint list JSON schemas in `datamodel/sharepoint/lists/process_execution/`:
1. `contract_scopes.json`
2. `scope_department_allocations.json`
3. `projects.json`
4. `job_assignments.json`
5. `assignment_details.json`
6. `cde_documents.json`

Verify:
- All 6 JSON schemas parse cleanly as valid JSON.
- Lookup references are valid (`ContractScopes` -> `Contracts`, `ScopeDepartmentAllocations` -> `ContractScopes`, `JobAssignments` -> `Projects`, `AssignmentDetails` -> `JobAssignments`, `ContractScopes`, `ScopeDepartmentAllocations`).
- Field limits (<= 28 fields) and lookup limits (<= 8 lookups) per list are respected.
- Execute `.\idop.ps1 validate datamodel` using `run_command` and verify that the CLI validator passes with 0 errors across all list schemas.

Write your review report to `d:\idop-ccba-way\.agents\teamwork_preview_reviewer_m4_1\handoff.md`.
Send a completion message when done.
