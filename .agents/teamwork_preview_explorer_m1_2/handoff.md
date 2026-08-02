# Handoff Report — Teamwork Preview Explorer M1-2

**Author**: `teamwork_preview_explorer_m1_2` (Explorer 2)  
**Target Recipient**: Parent Orchestrator (`57e49422-7846-4e01-9c23-31812bbc93e4`)  
**Working Directory**: `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_2`  
**Timestamp**: 2026-08-02T14:49:30Z  

---

## 1. Observation (Quát sát Thực tế)

- **Target Specification File**: `specs/modules/process_execution/pmo/spec.md`
  - Total Lines: 79 lines. Currently contains a 4-step generic flow, basic user stories, and high-level role matrix. Lacks detailed 5-step data entry sequence, 4 technical role distinctions (`ContractLeadUser`, `DesignChiefUser`, `FinancialOfficerUser`, `AssignedTechnicalChiefUser`), Multi-Scope / Multi-Department allocation business rules, and explicit statutory compliance clauses for Law 135/2025/QH15 & NĐ 217/2026/NĐ-CP (Khoản 4 & Khoản 5 Điều 26).
- **Governance Constitutions Inspected**:
  - `01_qctk_2815_project_management.md` (QCTK 2815/QĐ-VKH): Inspected lines 1 to 420. Key clauses identified: Điều 3.2a-c (definitions of 主持 HĐ, Chủ nhiệm, Chủ trì bộ môn/kỹ thuật), Điều 4.8 (independent internal control), Điều 4.9 (role liabilities), Điều 5 (Bidding), Điều 6 (Contract signing & offloading), Điều 7 (PGV 4 flows, roles, inter-departmental allocation, CTV rules), Điều 8 (Contract management), Điều 9 (Responsibilities of Unit Head, Lead, Tech leads).
  - `02_qcctnb_3209_financial_norms.md` (QCCTNB 3209/QĐ-VKH): Inspected lines 1 to 480. Key clauses identified: Điều 8.2 (salaries & timesheets), Điều 22.2 (Disbursement & retainage), Phụ lục 7 (Retention rates for contract groups N1a through N4), Phụ lục 8 (Labor percentage frames).
- **System Blueprints Inspected**:
  - `06_ccba_org_role_matrix.md`: Inspected lines 1 to 243. Verified 15 SSOT `ROLE_ID`s, 11 organizational seats, and CRUD+A permissions across 6 modules.
  - `05_ccba_ibst_boundary_map.md`: Inspected lines 1 to 358. Verified Step 3 PGV internal CCBA operational boundary, Gateway role of `ROLE_HEAD_ADMIN` for inter-departmental / external IBST interactions, and 5TB Master OneDrive Offloading architecture.
- **Data Model JSON Schemas Inspected**:
  - `datamodel/sharepoint/lists/process_execution/job_assignments.json`
  - `datamodel/sharepoint/lists/process_execution/contract_scopes.json`
  - `datamodel/sharepoint/lists/process_execution/assignment_details.json`

---

## 2. Logic Chain (Chuỗi Lý luận)

1. **Alignment of PMO Specification with SSOT**:
   - The current `specs/modules/process_execution/pmo/spec.md` is an initial draft (79 lines) that needs to be updated to Revision R2 to reflect the architectural consensus.
   - The updated specification must strictly adhere to the 15 `ROLE_ID` SSOT defined in `06_ccba_org_role_matrix.md` and the 5 non-negotiable architectural constraints in `AGENTS.md`.

2. **Integration of Technical & Polymorphic Roles**:
   - `ContractLeadUser` maps to `ROLE_PROJECT_MANAGER` (Chủ trì HĐ / CNDA) who owns overall P&L and contract execution (QCTK 2815 Điều 3.2a & 9.4).
   - `DesignChiefUser` maps to `ROLE_HEAD_BIM_DESIGN` (Chủ nhiệm Thiết kế) who approves design QA/QC and technical solutions (QCTK 2815 Điều 3.2b & 9.1b).
   - `FinancialOfficerUser` maps to `ROLE_ACCOUNTANT` (Phụ trách Kế toán Đơn vị) who validates the 3-tier financial allocation ratios (QCCTNB 3209 Phụ lục 7 & Điều 8.2).
   - `AssignedTechnicalChiefUser` maps to `ROLE_STAFF` / `ROLE_HEAD_BIM_PROJECT` (Giám sát trưởng, Chỉ huy trưởng, Chủ trì bộ môn) who directly executes work and holds professional practice certificates (QCTK 2815 Điều 3.2c & 7.5).

3. **Formulation of the 5-Step Data Entry Sequence**:
   - **Step 1: Khởi tạo PGV & Khung Hợp đồng (`PGV Initiation & Scope Binding`)** — `ContractLeadUser` initiates PGV and binds `ContractScopeId`.
   - **Step 2: Phân bổ Tài chính 3 Tầng (`3-Tier Financial Allocation`)** — `FinancialOfficerUser` validates Tier 1 Viện retention, Tier 2 CCBA overhead, Tier 3 project production budget.
   - **Step 3: Phân công Nhân sự Kỹ thuật & Vai trò (`Technical Assignment & License Check`)** — `DesignChiefUser` checks practice certificates and assigns technical leads/staff/CTV.
   - **Step 4: Thẩm tra Tuân thủ & Gateway (`Compliance & Gateway Audit`)** — `ROLE_LEGAL_QA` checks statutory compliance (Luật 135/2025 & NĐ 217/2026 Khoản 4, 5 Điều 26) and `ROLE_HEAD_ADMIN` handles gateway verification for inter-departmental contracts.
   - **Step 5: Phê duyệt Giám đốc & Offloading (`Executive Approval & Offloading`)** — `ROLE_DIRECTOR` signs off electronically; system generates `WorkPackages` and offloads PDF PGV to 5TB Master OneDrive (`05_Projects`).

4. **Multi-Scope & Multi-Department Business Rules**:
   - Multi-Scope: Each scope item in a contract requires a separate `ContractScopeId` and applies its specific Tier 1 retention percentage per Phụ lục 7 QCCTNB 3209.
   - Multi-Department: Inter-departmental contracts require explicit allocation percentages on PGV, with `ROLE_HEAD_ADMIN` acting as gateway for external IBST unit agreements.

5. **Statutory Compliance Integration**:
   - **Luật 135/2025/QH15**: Mandates electronic signature validity, digital message auditability, and SHA-256 non-repudiation logging.
   - **NĐ 217/2026/NĐ-CP Khoản 4 Điều 26**: Mandates strict separation of financial control, joint financial liability of unit director and contract lead, and independent QA audit (`ROLE_LEGAL_QA`).
   - **NĐ 217/2026/NĐ-CP Khoản 5 Điều 26**: Mandates PGV data immutability post-approval and 5TB Master OneDrive offloading for digital document preservation.

---

## 3. Caveats (Các Điểm Chưa Trình Bày & Giả Định)

- **Read-Only Scope**: In accordance with the Explorer role constraints, source code and project files outside `.agents/teamwork_preview_explorer_m1_2/` were NOT directly modified. All R2 specification update recommendations have been written to `spec_update_plan.md`.
- **Assumption on JSON Schema Updates**: It is assumed that Implementer 1 will update `job_assignments.json` and `assignment_details.json` to include the new Lookup fields (`ContractScopeId`, `ContractLeadUser`, `DesignChiefUser`, `FinancialOfficerUser`, `AssignedTechnicalChiefUser`) outlined in `spec_update_plan.md`.

---

## 4. Conclusion (Kết luận & Đề xuất HĐ)

- The complete specification update plan for `specs/modules/process_execution/pmo/spec.md` (R2 Revision) has been fully formulated and saved to `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_2\spec_update_plan.md`.
- Section 8 of `spec_update_plan.md` contains the complete ready-to-apply Markdown text for `specs/modules/process_execution/pmo/spec.md`.
- The R2 text incorporates all 5 required elements:
  1. 5-step PGV data entry sequence.
  2. Role distinctions (`ContractLeadUser`, `DesignChiefUser`, `FinancialOfficerUser`, `AssignedTechnicalChiefUser`).
  3. Multi-Scope and Multi-Department allocation business rules.
  4. Statutory compliance with Law 135/2025/QH15 & NĐ 217/2026/NĐ-CP (Khoản 4 & Khoản 5 Điều 26).
  5. Ubiquitous Language matrix, 3-tier role hierarchy, and Law 135/2025 verification workflow.

---

## 5. Verification Method (Phương pháp Kiểm tra)

To independently verify the outputs produced by Explorer 2:
1. Inspect `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_2\spec_update_plan.md` to confirm the complete structural recommendations and full R2 Markdown text.
2. Cross-reference `spec_update_plan.md` Section 8 against governance documents `01_qctk_2815_project_management.md` and `02_qcctnb_3209_financial_norms.md` to verify legal clause accuracy.
3. Verify that all 15 `ROLE_ID`s in the Role Matrix match `06_ccba_org_role_matrix.md`.
