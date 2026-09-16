## 2026-07-28T07:56:00Z
You are teamwork_preview_worker working on Modules 4-6 Spec Standardisation & Completion (people_assets, performance_okrs, system_governance).
Your working directory is d:\idop-ccba-way\.agents\worker_m2.
Identity: Archetype teamwork_preview_worker, Working directory d:\idop-ccba-way\.agents\worker_m2.

Your mission:
Write and complete 100% of all `spec.md` technical specification files for Modules 4-6 (`people_assets`, `performance_okrs`, `system_governance`) according to regulations in `extracted_docs` (QCTK 2815, QCCTNB 3209, Quy chế CCBA 2026) and SharePoint JSON datamodel schemas in `datamodel/sharepoint/lists/`.

Standard 6-Part Spec Framework (Mandatory for ALL spec.md files):
1. **Mục tiêu & Phạm vi (Goal & Scope)**
2. **User Stories & Ma trận Vai trò (Role Matrix)**: Include 5 departments (Tổ chức - Hành chính, Kế hoạch - Tài chính, Kỹ thuật - Đào tạo, các Phòng Chuyên môn/Tư vấn, Ban Giám đốc) + 3 CCBA roles (Chủ nhiệm dự án / PM, Trưởng phòng chuyên môn, Giám đốc / BGD).
3. **Cơ sở Pháp lý & Quy chế Áp dụng**: Precise citations of QCTK 2815, QCCTNB 3209, Quy chế CCBA 2026.
4. **Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)**: Operational flows and financial mechanism integration.
5. **Acceptance Criteria & List Mapping**: 1-to-1 mapping with corresponding SharePoint List JSON schemas in `datamodel/sharepoint/lists/` (field names, types, lookups, taxonomy mapping).
6. **Bảo mật, Phân quyền & Audit Trail**: Role permission matrix and audit trail fields.

Specific Spec files to write/update:
- **`people_assets`**:
  - `specs/modules/people_assets/hr/spec.md` (Complete from empty placeholder: 5 depts + 3 CCBA roles, Timesheets, mapping to `employees.json`, `departments.json`, `employment_contracts.json`, `timesheets.json`, `project_members.json`, `employee_history.json`, `certifications.json`, `benefit_packages.json`, `employee_benefits.json`, `rewards.json`)
  - `specs/modules/people_assets/assets/spec.md` (Update: BIM device management & maintenance, mapping to `assets.json`, `maintenance_logs.json`)
- **`performance_okrs`**:
  - `specs/modules/performance_okrs/performance/spec.md` (Complete from empty placeholder: OKRs/KPIs evaluation tied to Tier 3 Production Bonus Fund under QCCTNB 3209, mapping to `okrs_objectives.json`, `okrs_key_results.json`, `measurables.json`, `quarters.json`, `scorecard_data.json`)
  - `specs/modules/performance_okrs/reports/spec.md` (Update: Performance reports spec)
- **`system_governance`**:
  - `specs/modules/system_governance/governance/spec.md` (Update: Environment variables, system parameters, permissions)
  - `specs/modules/system_governance/approvals/spec.md` (Update: Polymorphic Soft Key `Submissions`, multi-stage approval workflows, mapping to `submissions.json`, `approval_nodes.json`, `approval_histories.json`, `approval_delegations.json`)
  - `specs/modules/system_governance/forms/spec.md` (Update: Dynamic forms & system configuration, mapping to `dynamic_forms.json`, `system_settings.json`, `environment_variables.json`)

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Ensure zero `...` placeholders remain.
Write your handoff report to `d:\idop-ccba-way\.agents\worker_m2\handoff.md` and send a message back to parent facc159b-48b9-479d-8ba2-cbdb942c29e0 when finished.

## 2026-07-28T15:04:25Z
You are teamwork_preview_worker performing Remediation for Modules 4-6 & Data Model JSON Schemas based on Reviewer 2 feedback.
Your working directory is d:\idop-ccba-way\.agents\worker_m2.

Mission & Specific Remediation Tasks:
1. Create 5 Missing JSON List Schemas in `datamodel/sharepoint/lists/system_governance/`:
   - `approval_nodes.json` (Approval nodes/steps in multi-stage approval engine)
   - `approval_histories.json` (Audit log of approval actions/decisions)
   - `approval_delegations.json` (Temporary delegation of approval authority)
   - `dynamic_forms.json` (Dynamic form definitions & metadata)
   - `system_settings.json` (System parameters and configuration key-values)
   Follow standard IDOP list JSON schema format (Title, InternalName, Description, Fields array with Name, Type, DisplayName, Required, etc.).
2. Update Data Model JSON Schemas:
   - `datamodel/sharepoint/lists/people_assets/assets.json`: Add financial fields (`OriginalValue` - Number, `DepreciationRate` - Number, `AccumulatedDepreciation` - Number, `SerialNumber` - Text, `Location` - Text).
   - `datamodel/sharepoint/lists/performance_okrs/okrs_objectives.json`: Add `ParentObjectiveId` (Lookup to `okrs_objectives`) and `DepartmentId` (Lookup to `departments`).
   - `datamodel/sharepoint/lists/people_assets/departments.json`: Add `ParentDepartmentId` (Lookup to `departments`).
3. Re-verify all specs in Modules 4-6 (`hr/spec.md`, `assets/spec.md`, `performance/spec.md`, `reports/spec.md`, `governance/spec.md`, `approvals/spec.md`, `forms/spec.md`) against these newly created/updated JSON files so 1-to-1 schema mapping is 100% genuine and verified.
4. Eliminate any remaining `...` placeholders in Modules 4-6 specs.
5. Run `pwsh -ExecutionPolicy Bypass -Command ".\idop.ps1 validate datamodel"` and confirm all lists pass datamodel validation with 0 errors!

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine.

Write your handoff report to `d:\idop-ccba-way\.agents\worker_m2\handoff.md` and send a message back to parent facc159b-48b9-479d-8ba2-cbdb942c29e0 when completed.

