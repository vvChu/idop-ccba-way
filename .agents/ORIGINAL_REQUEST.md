# Original User Request

## Initial Request — 2026-07-28T15:45:24+07:00

Cấu trúc lại Knowledge Base cho dự án IDOP-CCBA-WAY: di chuyển `extracted_docs/` vào `.md/`, tách thành 2 phân nhóm ngữ nghĩa, chuẩn hóa tên file, tạo hệ thống indexing, và cập nhật Agent discoverability.

Working directory: d:\idop-ccba-way
Integrity mode: development

## Requirements

### R1. Di chuyển và chuẩn hóa tên file

Di chuyển 8 file từ `extracted_docs/` tại Project Root vào 2 thư mục con trong `.md/`, phân loại theo bản chất tài liệu:

**Nhóm A — Quy chế Pháp lý** → `.md/governance_constitution/`:

| Tên cũ | Tên mới |
|--------|--------|
| `qctk_01.12.2025.md` | `01_qctk_2815_project_management.md` |
| `qcctnb_2025.md` | `02_qcctnb_3209_financial_norms.md` |
| `Du thao_QuyCheToChucHoatDong_CCBA_2026_v2.2.md` | `03_ccba_charter_2026.md` |
| `quy_che_khcn_ibst_01.12.2025.md` | `04_ibst_science_tech_regulations.md` |

**Nhóm B — Yêu cầu Thiết kế Hệ thống** → `.md/system_blueprint/`:

| Tên cũ | Tên mới |
|--------|--------|
| `IDOP_v2.0_F1_Architecture.md` | `01_idop_v2_architecture.md` |
| `IDOP_v2.0_F2_Operations_Finance.md` | `02_idop_v2_operations_finance.md` |
| `IDOP_v2.0_F3_Technical_Implementation.md` | `03_idop_v2_technical_implementation.md` |
| `IDOP_v2.0_F4_Enterprise_Architecture.md` | `04_idop_v2_enterprise_architecture.md` |

Sau khi di chuyển thành công toàn bộ 8 file, xóa thư mục `extracted_docs/`.

### R2. Tạo hệ thống meta files

Tạo 3 file meta trong `.md/`:

1. **`workspace_context.yaml`**: Thông tin bootstrap cho AI Agent — tên dự án, phiên bản, milestone hiện tại, đường dẫn đến governance docs và system blueprint, danh sách file cần đọc khi bắt đầu phiên làm việc.

2. **`INDEX.md`**: Mục lục tổng hợp 2 phân nhóm tài liệu. Mỗi file có tóm tắt nội dung 2-3 câu và bảng tra cứu nhanh "Tôi cần biết về X → đọc file Y, Điều/Phần Z". Tạo anchor links đến các Điều/Khoản chính trong mỗi file quy chế.

3. **`cross_references.yaml`**: Ánh xạ machine-readable từ mỗi file `spec.md` trong `specs/modules/` đến các Điều/Khoản/Phần cụ thể trong tài liệu nguồn mà nó tham chiếu. Scan toàn bộ nội dung spec.md files để trích xuất chính xác các tham chiếu thực tế (QCTK 2815 Điều X, QCCTNB 3209 Khoản Y, Quy chế CCBA Điều Z, IDOP v2 Phần W).

### R3. Cập nhật Agent Discoverability

Cập nhật 2 file có sẵn để AI Agent mới tự động phát hiện bộ "Hiến pháp hệ thống":

1. **`CLAUDE.md`**: Thêm section `## Governance Knowledge Base` giải thích:
   - Đọc `.md/workspace_context.yaml` đầu tiên khi bắt đầu phiên làm việc
   - 2 phân nhóm tài liệu (governance_constitution = quy chế pháp lý bất di bất dịch, system_blueprint = yêu cầu thiết kế có thể evolve)
   - Tra cứu `cross_references.yaml` khi cần tìm cơ sở pháp lý cho bất kỳ module/spec nào

2. **`README.md`**: Thêm section `## 📚 Knowledge Base (.md/)` mô tả cấu trúc `.md/` cho developer/collaborator, giải thích triết lý "Hiến pháp hệ thống".

## Acceptance Criteria

### File Migration
- [ ] Thư mục `.md/governance_constitution/` chứa đúng 4 file với tên đã chuẩn hóa
- [ ] Thư mục `.md/system_blueprint/` chứa đúng 4 file với tên đã chuẩn hóa
- [ ] Nội dung mỗi file sau di chuyển giữ nguyên 100% so với bản gốc (không thêm/bớt nội dung)
- [ ] Thư mục `extracted_docs/` tại Project Root không còn tồn tại

### Meta Files Quality
- [ ] `workspace_context.yaml` parseable bởi YAML parser (không syntax error)
- [ ] `INDEX.md` chứa mục lục đầy đủ 8 file với tóm tắt và bảng tra cứu nhanh
- [ ] `cross_references.yaml` ánh xạ ≥ 15 file spec.md đến các Điều/Khoản cụ thể (phản ánh ~150 tham chiếu thực tế trong codebase)

### Discoverability
- [ ] `CLAUDE.md` chứa section `## Governance Knowledge Base` với hướng dẫn rõ ràng
- [ ] `README.md` chứa section mô tả cấu trúc `.md/`

### No Regression
- [ ] Lệnh `.\idop.ps1 validate datamodel` vẫn pass 100% (migration không ảnh hưởng code logic)
- [ ] Không có file nào trong `specs/`, `datamodel/`, `tools/` bị thay đổi

## Follow-up — 2026-08-02T07:47:46Z

Implement and validate the IDOP CCBA v2.0 Data Model JSON Schemas and PMO Specification according to the comprehensive architectural consensus (Law 135/2025/QH15 compliance, Multi-Scope, Multi-Department allocation, and Polymorphic Role binding).

Working directory: d:\idop-ccba-way
Integrity mode: demo

## Requirements

### R1. Data Model JSON Schemas Implementation
Update and create the 6 core SharePoint list JSON schemas in datamodel/sharepoint/lists/process_execution/:
- contract_scopes.json: Add financial tier 1 allocation fields (NhomHopDongKT, TyLeGiaoDonVi, TyLeVienCPQL, TyLeVienKHTS, GiaTriGiaoDonVi).
- scope_department_allocations.json [NEW]: Create schema for multi-department scope allocations (ContractScopeId, Department, Role, AllocationShare, AllocatedAmount, DepartmentHead).
- projects.json: Add NationalProjectID and ServiceType.
- job_assignments.json: Add ContractScopeId, ContractLeadUser, DesignChiefUser, FinancialOfficerUser.
- assignment_details.json: Add ContractScopeId, ScopeDeptAllocId, GenericRoleName, AssignedTechnicalChiefUser, ResolvedLegalRole, RequiresCertCheck, DisciplineLead, TeamMembers, QCChecker, AllocatedHours.
- cde_documents.json: Update ISO 19650 approval status (S0->S1->S2->S3->A1) and naming metadata fields.

### R2. PMO Specification & Documentation Update
Update specs/modules/process_execution/pmo/spec.md to document:
- The 5-step PGV data entry sequence.
- Role distinctions (ContractLeadUser, DesignChiefUser, FinancialOfficerUser, AssignedTechnicalChiefUser).
- Multi-Scope and Multi-Department allocation business rules.
- Statutory compliance with Law 135/2025/QH15 & NĐ 217/2026/NĐ-CP (Khoản 4 & Khoản 5 Điều 26).

### R3. Data Model Validation
Execute .\idop.ps1 validate datamodel to ensure all 58 list schemas, lookup dependencies, and JSON syntax pass validation cleanly without errors.

## Acceptance Criteria

### Schema Integrity & Syntax
- [ ] All 6 JSON schema files in datamodel/sharepoint/lists/process_execution/ pass valid JSON schema parsing.
- [ ] scope_department_allocations.json is created with valid Lookup references to ContractScopes.
- [ ] assignment_details.json contains valid Lookup references to JobAssignments, ContractScopes, and ScopeDepartmentAllocations.

### CLI Validation
- [ ] Running .\idop.ps1 validate datamodel returns 0 validation errors.

### PMO Specification Completeness
- [ ] specs/modules/process_execution/pmo/spec.md includes the Ubiquitous Language matrix, 3-tier role hierarchy, and Law 135/2025 verification workflow.

