# 🤖 AGENTS.md — Ngôn ngữ Chung & Hướng dẫn Vận hành cho AI Agents (IDOP-CCBA-WAY)

> **Dự án**: Integrated Digital Operation Platform (IDOP) — CCBA / IBST  
> **Mục đích**: Thiết lập **Ngôn ngữ Chung (Ubiquitous Domain Language)**, Ánh xạ Thuật ngữ Nghiệp vụ ↔ Kỹ thuật, và Khóa cứng các Nguyên tắc Kiến trúc không được phép vi phạm cho tất cả AI Agents làm việc trên codebase này.

---

## 1. 📖 Từ điển Thuật ngữ Nghiệp vụ ↔ Kỹ thuật (Ubiquitous Language)

Tất cả AI Agent khi trao đổi, viết code, tạo schema hay viết tài liệu **BẮT BUỘC** phải tuân thủ bảng ánh xạ thuật ngữ chuẩn dưới đây:

| Thuật ngữ Nghiệp vụ CCBA / IBST | Thự thể / SharePoint List | Module IDOP | Vai trò / Entra ID Group | Quy chế Dẫn chiếu |
|:---|:---|:---|:---|:---|
| **Cơ hội Kinh doanh / Khách hàng Tiềm năng** | `Opportunities`, `Leads` | `strategy_crm` | `ROLE_DEPUTY_DIRECTOR` | QCTK 2815 Điều 5 |
| **Hồ sơ Mời thầu / Dự thầu (HSMT/HSDT)** | `opportunities` + 5TB OneDrive | `strategy_crm` | `ROLE_PROJECT_MANAGER` | QCTK 2815 Điều 5.1 |
| **Đăng ký Đơn vị Đầu mối Đấu thầu** | `opportunities` (stage: Bidding) | `strategy_crm` | `ROLE_HEAD_ADMIN` (Gateway) | QCTK 2815 Điều 5.1c |
| **Hợp đồng Kinh tế (HĐKT)** | `Contracts` | `process_execution` | `ROLE_DIRECTOR`, `ROLE_HEAD_ADMIN` | QCTK 2815 Điều 6 |
| **Ủy quyền / Thẩm quyền Ký HĐ** | `Contracts` (LoaiKyKet) | `process_execution` | `ROLE_DIRECTOR` (Hạn mức 2B/5B/10B) | QCTK 2815 Điều 6.1 |
| **Phiếu Giao Việc (PGV)** | `pmo`, `job_assignments` | `process_execution` | `ROLE_DIRECTOR`, `ROLE_PROJECT_MANAGER` | QCTK 2815 Điều 7 |
| **Giao khoán Tài chính & Nhân sự** | `work_packages`, `allocations` | `process_execution` | `ROLE_PROJECT_MANAGER` | QCTK 2815 Điều 7.7 |
| **Dự án & Tiến độ WBS** | `Projects`, `WorkPackages` | `process_execution` | `ROLE_PROJECT_MANAGER` | QCTK 2815 Điều 8 |
| **Kiểm tra Nội bộ & QA/QC 5 Cấp** | `cde_documents`, `lessons_learned` | `process_execution` | `ROLE_LEGAL_QA`, `ROLE_HEAD_BIM_*` | QCTK 2815 Điều 10 |
| **Nghiệm thu Kỹ thuật & Nghiệm thu A-B** | `finance`, `contracts` | `process_execution` | `ROLE_HEAD_ADMIN` (Nộp KHKT Viện) | QCTK 2815 Điều 11 |
| **Phân bổ Doanh thu 3 Tầng** | `allocations` | `cash_data` | `ROLE_ACCOUNTANT` | QCCTNB 3209 Phụ lục 7 & QCTK Bảng 1 |
| **Trích nộp Viện (Tầng 1)** | `allocations` (Tier1_IBST) | `cash_data` | `ROLE_ACCOUNTANT` → TCKT Viện | QCCTNB 3209 Phụ lục 7 |
| **Kinh phí Đơn vị (Tầng 2)** | `allocations` (Tier2_CCBA) | `cash_data` | `ROLE_ACCOUNTANT` | QCCTNB 3209 Phụ lục 7 |
| **Kinh phí Chủ trì & Q.Thưởng (Tầng 3)** | `allocations` (Tier3_Project) | `cash_data` | `ROLE_PROJECT_MANAGER` | QCCTNB 3209 Phụ lục 7 |
| **Tạm ứng & Giải ngân (≤ 90%)** | `finance`, `allocations` | `cash_data` | `ROLE_ACCOUNTANT` → TCKT Viện | QCCTNB 3209 Điều 22.2 |
| **Chứng từ Chi & Định mức Công tác phí** | `expenses`, `expense_checklists` | `cash_data` | `ROLE_ACCOUNTANT` | QCCTNB 3209 Điều 8.2 |
| **Nhân sự, Chấm công & Timesheets** | `employees`, `timesheets` | `people_assets` | `ROLE_HEAD_ADMIN`, `ROLE_STAFF` | Quy chế CCBA 2026 Điều 9 |
| **Thiết bị & Mô hình BIM (CDE)** | `assets`, `cde_documents` | `people_assets` | `ROLE_HEAD_BIM_DESIGN`, `ROLE_IDOP_LEAD` | ISO 19650 |
| **Mục tiêu OKRs & KPI Scorecards** | `okrs_objectives`, `scorecard_data` | `performance_okrs` | `ROLE_DIRECTOR`, `ROLE_STAFF` | Quy chế CCBA Phụ lục 04 |
| **Luồng Phê duyệt Đa cấp (Submissions)** | `submissions`, `approval_nodes` | `system_governance` | Polymorphic Dynamic Approvals | Quy chế CCBA Phụ lục 03 |

---

## 2. 🔐 SSOT: Danh sách 15 ROLE_ID Chuẩn hóa

> **QUY TẮC CỐT LÕI**: Mọi AI Agent **TUYỆT ĐỐI KHÔNG** tự tạo tên vai trò mới ngoài 15 `ROLE_ID` chuẩn sau đây (lấy từ `.md/system_blueprint/06_ccba_org_role_matrix.md`):

```
1.  ROLE_DIRECTOR          : Giám đốc Trung tâm (Visionary & Integrator)
2.  ROLE_DEPUTY_DIRECTOR   : Phó Giám đốc Khối DV&KD
3.  ROLE_DEPUTY_HCM        : Phó Giám đốc thường trú TP.HCM
4.  ROLE_LEGAL_QA          : Cố vấn Pháp lý, TC & QLCL
5.  ROLE_HEAD_ADMIN        : Trưởng phòng Tổng Hợp (Đầu mối Gateway Viện IBST)
6.  ROLE_ACCOUNTANT         : Phụ trách Kế toán Đơn vị
7.  ROLE_HEAD_RD           : Trưởng phòng R&D & HTQT
8.  ROLE_IDOP_LEAD         : Phụ trách Nền tảng Số & CN BIM
9.  ROLE_HEAD_BIM_DESIGN   : Trưởng phòng BIM Thiết kế
10. ROLE_HEAD_BIM_PROJECT  : Trưởng phòng BIM Dự án
11. ROLE_HEAD_HCM          : Trưởng phòng TV&KĐ XD (HCM)
12. ROLE_PROJECT_MANAGER   : Chủ trì HĐ / Chủ nhiệm Dự án
13. ROLE_STAFF             : Cá nhân / Viên chức NLĐ CCBA
14. ROLE_EXTERNAL_PARTNER  : Cộng tác viên / Đối tác liên danh
15. ROLE_EXTERNAL_CLIENT   : Khách hàng (Bên A)
```

---

## 3. 🚨 5 Rào cản Kiến trúc Không được Phép Vi phạm (Non-Negotiables)

Khi tạo code, script hoặc đề xuất bất kỳ giải pháp nào, Agent **PHẢI** tuân thủ 5 nguyên tắc khóa cứng này:

1. **IDOP = Vận hành NỘI BỘ CCBA**:
   - IDOP **không** model quy trình hoặc tạo task cho phía Viện IBST.
   - **Phòng Tổng Hợp (`ROLE_HEAD_ADMIN`)** là đầu mối duy nhất (gateway) giao tiếp với các phòng Viện (KHKT, TCKT, TCHC).
   - Tương tác với Viện chỉ ghi nhận dưới dạng **Status Fields** (như `Submitted_to_IBST`, `IBST_Approved`, `IBST_Disbursed`).

2. **Metadata-First & 5TB Master Storage Offloading**:
   - 57 SharePoint Lists trên `sites/idop` **CHỈ lưu Metadata (Text, Numbers, Lookups, Taxonomy & URL Links)**. Dung lượng toàn bộ 57 lists < 5GB.
   - **CẤM đính kèm file binary trực tiếp** vào SharePoint List Items để bảo vệ 2TB SharePoint Tenant Quota.
   - File chính thức (PDF, HSMT/HSDT, Scan HĐ, Hóa đơn) được tự động phân luồng sang **5TB Master OneDrive (`ccba@ibst-bim.vn`)** theo 5 thư mục module (`01_Bidding`, `02_Contracts`, `03_Finance`, `04_HR_Assets`, `05_Projects`).

3. **Kiến trúc Single Production Architecture**:
   - Hệ thống vận hành trên **1 site IDOP chính thức**: `https://ibstbim.sharepoint.com/sites/idop`.
   - Tất cả câu lệnh CLI `idop.ps1` dùng cờ **`-Environment IDOP`**.

4. **Bảo mật & Xác thực App-Only Certificate**:
   - **Primary App ID**: `c055c7a4-9150-4bd5-bf01-445c65467feb` (AppOnly Certificate-based, phục vụ CLI & CI/CD).
   - **Interactive Fallback App ID**: `90ded6f0-b787-4b3c-acea-8baf6403fd63` (Browser Interactive).
   - Mọi thông tin nhạy cảm lưu tại `.env`. **Tuyệt đối không hardcode API Keys/Cert passwords vào code hay markdown**.

5. **Dẫn chiếu Thể chế, Không Sao chép (Reference-not-Duplicate)**:
   - Các file `spec.md` và tài liệu kỹ thuật tham chiếu đường dẫn đến các Điều/Khoản trong `.md/governance_constitution/` và `.md/system_blueprint/`. Không duplicate lại nội dung quy chế.

---

## 4. 🗺️ Lộ trình Khám phá Codebase cho Agent (Agent Discovery Sitemap)

Khi mới bắt đầu một phiên làm việc, Agent nên đọc tài liệu theo thứ tự sau để nắm 100% bối cảnh:

```
1. .md/workspace_context.yaml                   ──► Context bootstrap & milestone hiện tại
2. .md/INDEX.md                                 ──► Mục lục tra cứu toàn bộ Quy chế & Blueprint
3. .md/system_blueprint/06_ccba_org_role_matrix.md ──► SSOT về Cơ cấu tổ chức & 15 ROLE_ID
4. .md/system_blueprint/05_ccba_ibst_boundary_map.md ──► Bản đồ ranh giới CCBA ↔ Viện IBST & 7 bước
5. .md/system_blueprint/07_m365_storage_and_offloading_architecture.md ──► Kiến trúc lưu trữ 5TB
6. specs/modules/<module>/<submodule>/spec.md   ──► Đặc tả chi tiết từng tính năng
7. datamodel/sharepoint/lists/                  ──► 57 JSON Schemas thực tế của SharePoint Lists
```

---

## 5. 🛠️ Lệnh CLI Thống nhất (`idop.ps1`)

Agent sử dụng duy nhất CLI Wrapper `idop.ps1` từ root folder:

```powershell
# 1. Kết nối môi trường IDOP
.\idop.ps1 connect -Environment IDOP

# 2. Kiểm tra & Validate Schema/Lookups/Taxonomy
.\idop.ps1 validate datamodel

# 3. Import 19 Taxonomy Term Sets vào Term Store CCBA
.\idop.ps1 taxonomy import -Environment IDOP

# 4. Triển khai 57 SharePoint Lists (DryRun hoặc Deploy thật)
.\idop.ps1 deploy lists -Environment IDOP -DryRun
.\idop.ps1 deploy lists -Environment IDOP -Full

# 5. Triển khai Navigation 3 Tầng & Bidding Folders
.\idop.ps1 deploy navigation -Environment IDOP
.\idop.ps1 maintenance folders
```
