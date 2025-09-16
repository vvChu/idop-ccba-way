# Constitution — Nguyên tắc kỹ thuật & kiểm soát chất lượng CCBA


## 1) Tư tưởng cốt lõi (First Principles)


## 2) Pipeline IDOP‑CCBA‑WAY (từ scaffold → vận hành)

```mermaid
flowchart LR
  %% Cross-cutting swimlanes
## 3) Vai trò & phê duyệt

## 4) Quy ước đặt tên & cấu trúc repo
## 4a) Nguyên tắc thiết kế & quản trị Taxonomy (Termstore)

### 4a.1) Cấu trúc taxonomy đã triển khai CCBA
### 4a.2) Nguyên tắc quản trị taxonomy

### 4a.3) Quy trình cập nhật taxonomy
## 5) Checklist bắt buộc theo từng bước

### S1 — Scaffold & Configure
### S2 — Detailed Design (AI)

### S3 — Review & Merge (PR)
### S4 — Technical Deployment

### S5 — Testing & Acceptance
### S6 — Operate & Improve

## 6) Liên kết tài liệu chiến lược (nguồn tham chiếu)
## 7) Cách dùng nhanh (SpecKit + VS Code)

---
Tài liệu này cần được cập nhật liên tục khi phát hiện ràng buộc mới trong quá trình triển khai. Mọi chỉnh sửa phải đi qua PR và được “Trình ký”.
# Constitution — Nguyên tắc kỹ thuật & kiểm soát chất lượng CCBA

---

## Định nghĩa và bối cảnh hoạt động của CCBA

- **Tên đầy đủ:** Trung tâm Tư vấn và Ứng dụng BIM trong xây dựng
- **Tư cách pháp nhân:** Đơn vị trực thuộc Viện Khoa học Công nghệ Xây dựng (IBST), có con dấu và tài khoản riêng
- **Tên tiếng Anh:** Center for Consulting Services and BIM Application in construction
- **Tên viết tắt:** CCBA
- **Địa chỉ:** Số 81 Trần Cung, phường Nghĩa Tân, Cầu Giấy, Hà Nội

---

## Bối cảnh hoạt động của CCBA

- **Chức năng:**
  - Tư vấn xây dựng: thiết kế, quản lý dự án, giám sát, thẩm tra, kiểm định...
  - Tư vấn, triển khai ứng dụng BIM xuyên suốt các giai đoạn dự án
  - Nghiên cứu khoa học, phát triển và chuyển giao công nghệ BIM
  - Đào tạo nhân lực BIM
  - Hợp tác trong nước và quốc tế
  - Thực hiện nhiệm vụ phục vụ quản lý nhà nước khi được giao

- **Nguyên tắc vận hành:**
  - Tuân thủ pháp luật, quy định Bộ Xây dựng và quy chế của Viện
  - Tự chủ, minh bạch, hiệu quả
  - Lấy ứng dụng BIM làm trục xuyên suốt
  - Số hóa và tự động hóa bằng nền tảng IDOP

- **Cơ cấu tổ chức:**
  - Ban Giám đốc
  - Phòng Tổng hợp
  - Phòng R&D và Hợp tác quốc tế
  - Phòng BIM Dự án
  - Phòng BIM Thiết kế
  - Các đơn vị trực thuộc khác khi cần thiết

---

## Định nghĩa và phạm vi của IDOP trong CCBA

- **IDOP (Integrated Digital Operation Platform):** Nền tảng hoạt động số tích hợp của CCBA trên Microsoft 365 (SharePoint Online, Power Automate, Power BI, Teams).
- **Mục đích:** Số hóa, tự động hóa quy trình, quản lý dữ liệu, hỗ trợ điều hành–ra quyết định.
- **Các thành phần trọng tâm:**
  - SharePoint Lists cho CRM–Hợp đồng–Dự án–Công việc–Chi phí–Hóa đơn–Tờ trình
  - Power Automate cho trình ký và phê duyệt động theo quy tắc
  - Power BI cho dashboards tiến độ, tài chính, chất lượng
  - Teams cho cộng tác và thực thi quy trình “Trình ký”

---

## Quy trình nghiệp vụ cốt lõi (CCBA WAY) gắn với IDOP

- **Chu trình CRM → Hợp đồng → Dự án → Thực thi → Nghiệm thu → Thanh/Quyết toán–Hoàn chứng từ.**
- **Ứng dụng “Trình ký”:** luồng phê duyệt tài liệu nội bộ theo nhiều tầng (Chủ trì → Trưởng phòng → Cố vấn Pháp lý/TC&QLCL → Phó Giám đốc → Giám đốc).
- **Quản lý tài liệu dự án:** CDE trên SharePoint; quy định chuyển lưu trữ sang OneDrive cho archive/dung lượng lớn; cấu trúc thư mục chuẩn.
- **Tài chính–kế toán:** Kế hoạch tài chính hợp đồng, Hóa đơn, Chi phí, quy trình tạm ứng–thanh toán–quyết toán–hoàn chứng từ được tự động hóa.

---

## Khóa neo cho mọi thảo luận và triển khai

- **CCBA = Trung tâm TV&UD BIM của IBST;** mọi “WAY”, “IDOP”, “quy trình” đều gắn với bối cảnh cơ quan nhà nước/đơn vị sự nghiệp thuộc Viện, không phải doanh nghiệp đồ uống.
- **IDOP là nền tảng nội bộ** phục vụ số hóa quy trình của Trung tâm (BIM thiết kế, BIM dự án, R&D, hành chính–tài chính), không phải sản phẩm thương mại đại trà (trừ khi được định hướng thương mại hóa từng phần sau).
- **Thuật ngữ và viết tắt chuẩn hóa:** dùng đúng các định nghĩa trong Quy chế (HĐKT, VCNLĐ, CDE, PMO, Trình ký…) để giữ tính nhất quán pháp lý–nghiệp vụ.
- **ALM và phân quyền:** phải phản ánh ma trận vai trò nội bộ (Giám đốc/Phó Giám đốc/Trưởng phòng/Chủ trì…), phân quyền theo dự án–phòng ban, và yêu cầu lưu vết/kiểm toán.
- **Tuân thủ tài chính:** quy trình chi–thu–hoàn chứng từ tuân thủ Quy chế chi tiêu nội bộ của Viện; tự động hóa chỉ là công cụ, không thay thế kiểm soát chuẩn tắc.
---

---

## Giới thiệu về CCBA

CCBA (Center for Construction & BIM Administration) là đơn vị chuyên trách về quản trị dự án xây dựng, quản lý vận hành, tài chính, nhân sự, tài sản, và triển khai các quy trình BIM tại tổ chức IBST BIM. CCBA đóng vai trò trung tâm trong việc chuẩn hóa, số hóa và tích hợp các hoạt động quản trị, đảm bảo chất lượng, minh bạch hóa và tối ưu hóa hiệu quả vận hành cho toàn bộ hệ sinh thái dự án xây dựng.
---

---

## Bối cảnh hoạt động — CCBA WAY & Trung tâm BIM CCBA

CCBA WAY là hệ thống quản trị vận hành số hóa toàn diện cho Trung tâm BIM CCBA, được thiết kế để tích hợp, chuẩn hóa và liên kết dữ liệu giữa các bộ phận: dự án, tài chính, nhân sự, tài sản, quy trình BIM, CRM và quản lý vận hành. Hệ thống này dựa trên nền tảng M365 (SharePoint, Power Platform) và các công cụ số hóa hiện đại, nhằm đảm bảo quản trị đa chiều, kiểm soát chất lượng, minh bạch hóa quy trình và hỗ trợ ra quyết định chiến lược.

Đặc thù vận hành:
- Quản trị tổng thể và liên kết dữ liệu giữa các phòng ban, dự án, tài sản, nhân sự, tài chính, quy trình BIM và CRM.
- Chuẩn hóa cấu trúc dữ liệu, số hóa toàn bộ quy trình nghiệp vụ, kiểm soát chất lượng và tuân thủ quy chế nội bộ.
- Tích hợp các module nghiệp vụ, datamodel, taxonomy, quy trình phê duyệt, đảm bảo traceability, versioning, audit trail và compliance.
- Hỗ trợ ra quyết định, minh bạch hóa trách nhiệm, kiểm soát vòng đời dữ liệu và vận hành.
- Định hướng phát triển: Tăng cường tự động hóa, AI, dashboard quản trị, phân tích dữ liệu và kiểm soát chất lượng theo chuẩn quốc tế.

Phạm vi áp dụng: CCBA WAY phục vụ toàn bộ hoạt động của Trung tâm BIM CCBA, không áp dụng cho tổ chức ngoài. Mọi thay đổi, cập nhật phải tuân thủ quy trình review/approval và được trình ký bởi Integrator.
---

Tài liệu này là “luật chơi” thống nhất cho IDOP – CCBA WAY. Nó điều phối cách đặc tả, thiết kế, triển khai, kiểm thử và vận hành các module nghiệp vụ trên nền tảng M365 (SharePoint, Power Automate, Power BI, Power Apps) theo mô hình Spec‑Driven Development + DevOps.

## 1) Tư tưởng cốt lõi (First Principles)
- Specification‑as‑Code: Đặc tả (`spec.md`) là nguồn chân lý dẫn dắt `plan.md` → `tasks.md` → triển khai kỹ thuật; không phát triển khi chưa có đặc tả đã duyệt.
- Data Source of Truth: Cấu trúc SharePoint Lists/Taxonomy phải tồn tại dưới dạng file trong repo (`datamodel/sharepoint/**`) và được đồng bộ 2 chiều với môi trường triển khai.
- Git‑centric ALM: Mọi thay đổi đi qua Pull Request, review/approval bắt buộc, có traceability, versioning, rollback.
- Environments rõ ràng: Dev/Test/Prod với secrets, connection refs, env vars tách bạch; không dùng thủ công tài khoản cá nhân cho Prod.
- Security & Compliance by design: Quy tắc đặt tên, phân quyền, audit trail, retention, uniqueness là bắt buộc, được kiểm tra tự động.

## 2) Pipeline IDOP‑CCBA‑WAY (từ scaffold → vận hành)

```mermaid

flowchart LR
  %% Cross-cutting swimlanes
  subgraph ENV[Environments — Dev / Test / Prod]
    direction TB
    ENV1[Secrets / Connection refs / Env vars]
    ENV2[Row-level access by Owner/Dept/Project]
  end

  subgraph GOV[Governance & Compliance]
    direction TB
    GOV1[Audit trail (before/after), approvals]
    GOV2[Retention & records, naming & codes, uniqueness]
  end

  subgraph S1[Scaffold & Configure]
    A1[[IDOP scaffold<br/>(JSON datamodel, taxonomy, scripts)]]
    A2[[Init Spec‑Kit<br/>constitution, prompts, templates, scripts]]
    A3[[Repo + GitHub Actions (stub)]]
  end

  subgraph S2[Detailed Design in VS Code (AI)]
    B1[/specify → spec.md/]
    B2[/plan → plan.md/]
    B3[/tasks → tasks.md/]
    B4[[Áp dụng constitution + checklist]]
  end

  subgraph S3[Review & Merge]
    C1[[Review spec/plan/tasks trong VS Code]]
    C2[[Đồng bộ với JSON datamodel & taxonomy]]
    C3[[Commit & push → Pull Request → Merge]]
  end

  subgraph S4[Technical Deployment]
    D1[[apply-sp-lists.(ps1|sh) → SharePoint Lists]]
    D2[[import-termstore.(ps1|sh) → Taxonomy]]
    D3[[ALM: validate schema, diff (dry-run), backup, rollback]]
  end

  subgraph S5[Testing & Acceptance]
    E1[[Seed data, approval flows, dashboards]]
    E2[[Data quality: required/regex/dedup]]
    E3[[Log kết quả vào tasks.md (done/pending)]]
  end

  subgraph S6[Operate & Improve]
    F1[[Prod: dashboards, RAG, SLA]]
    F2[[Change → update spec → plan → tasks → redeploy]]
    F3[[Versioning, audit logs, approvals, retention]]
  end

  A1 --> A2 --> A3 --> B1 --> B2 --> B3 --> B4 --> C1 --> C2 --> C3 --> D1 --> D2 --> D3 --> E1 --> E2 --> E3 --> F1 --> F2 --> F3

  %% Cross-cutting edges (conceptual linkage)
  ENV1 --- A3
  ENV2 --- D1
  GOV1 --- C3
  GOV2 --- D3

```

Màu sắc đề xuất (khi render bằng công cụ vẽ):

- S1: xanh nhạt; S2: xanh ngọc; S3: xanh lá; S4: vàng; S5: cam; S6: tím. Cross‑cutting: Environments (teal nhạt), Governance (xám nhạt).



## 3) Vai trò & phê duyệt

- Integrator (Giám đốc): Chủ trì review/approval ở Pull Request, quyết định merge. Kiểm chứng alignment với chiến lược CCBA và quy chế.
- Lead Kỹ thuật: Bảo đảm tuân thủ kiến trúc, bảo mật, diff/rollback khả dụng, chất lượng triển khai.
- BA/Owner Module: Làm rõ yêu cầu, đồng bộ đặc tả với thực tế vận hành, ký nhận nghiệm thu.
- Dev/Analyst: Triển khai theo `plan.md`/`tasks.md`, cập nhật datamodel JSON và taxonomy khi phát sinh.


## 4) Quy ước đặt tên & cấu trúc repo

- Danh mục SharePoint Lists: `datamodel/sharepoint/lists/<domain>/<listname>.json`.
- Taxonomy: `datamodel/sharepoint/taxonomy/**` (CSV/XML/JSON tuỳ lựa chọn), import bằng script.
- Schema: `datamodel/sharepoint/schemas/*.json` (ví dụ `sp-list.schema.json`).
- Modules: `specs/modules/<hợp-phần>/<module>/{spec.md,plan.md,tasks.md,api-spec.json,diagrams/}`.
- Prompts: `prompts/{spec.md,plan.md,tasks.md}`.
- Scripts: `tools/scripts/*.ps1|*.sh`, SpecKit wrapper: `tools/speckit/specify.ps1`.
- Bảo vệ file: `.vscode/settings.json` khóa `.speckit.yml`, datamodel/schemas.

Quy tắc đặt tên chính:

- ListName, cột/thuộc tính: PascalCase, rõ nghĩa, có mã/ký hiệu nếu cần (ví dụ `ProjectCode`).

- Term set: `CCBA_*` nhất quán; mã hoá song ngữ khi cần.
- Branch: `feat/<area>-<short>`, `fix/<area>-<short>`, `docs/<area>-<short>`.


## 4a) Nguyên tắc thiết kế & quản trị Taxonomy (Termstore)



### 4a.1) Cấu trúc taxonomy đã triển khai CCBA

Dựa trên đồng bộ từ SharePoint termstore thực tế (`CCBA Taxonomy`), hệ thống hiện có **14 term sets** với **66 terms** được phân loại:

**Tổ chức & Nhân sự (4 sets):**

- `CCBA_DonViPhongBan`: Cơ cấu tổ chức, phòng ban CCBA (4 terms)

- `CCBA_ChucDanhBIM`: Chức danh BIM chuyên môn (3 terms)
- `CCBA_ChucDanhXayDung`: Chức danh xây dựng truyền thống (8 terms)
- `CCBA_VaiTroLienHe`: Vai trò trong liên hệ/giao tiếp (3 terms)

**Tài chính & Nguồn lực (2 sets):**

- `CCBA_LoaiChiPhiPhanBo`: Phân loại chi phí theo QCCTNB (4 terms)

- `CCBA_NguonVon`: Nguồn vốn, tài trợ dự án (4 terms)

**Dự án & Kỹ thuật (3 sets):**

- `CCBA_LoaiCongTrinh`: Phân loại công trình theo chuyên ngành (4 terms)

- `CCBA_LoaiHinhDichVu`: Loại hình dịch vụ BIM/tư vấn (5 terms)
- `CCBA_MucDoUuTien`: Mức độ ưu tiên dự án/task (4 terms)

**CRM & Cơ hội (3 sets):**

- `CCBA_LoaiKhachHang`: Phân khúc khách hàng (6 terms)

- `CCBA_NguonGocCoHoi`: Nguồn gốc cơ hội kinh doanh (5 terms)
- `CCBA_NganhLinhVuc`: Ngành nghề, lĩnh vực hoạt động (6 terms)

**Quản lý chung (2 sets):**

- `CCBA_LoaiTaiLieu`: Phân loại tài liệu theo mục đích (5 terms)

- `CCBA_TrangThaiChung`: Trạng thái workflow tổng quát (5 terms)


### 4a.2) Nguyên tắc quản trị taxonomy

- **Ownership:** Mỗi term set có owner rõ ràng (department/role), chỉ owner được modify terms.
- **Versioning:** Thay đổi taxonomy qua Pull Request, export/import qua script, có changelog.
- **Naming convention:**
  - Term set: `CCBA_<DomainCamelCase>` (VD: `CCBA_LoaiChiPhiPhanBo`)
  - Terms: Vietnamese rõ nghĩa, có mã khi cần (VD: "Chi phí Trực tiếp (CPTT)")
- **Description bắt buộc:** Mỗi term set phải có mô tả mục đích sử dụng cụ thể.
- **Consistency:** Terms được sử dụng nhất quán trong SharePoint Lists, Power Apps, Power Automate.


### 4a.3) Quy trình cập nhật taxonomy

1. **Thiết kế:** Cập nhật file JSON trong `datamodel/sharepoint/taxonomy/`
2. **Review:** Pull Request với taxonomy changes, approval từ domain owner
3. **Deploy:** Chạy `termstore-import.ps1` để đồng bộ lên SharePoint
4. **Validate:** Kiểm tra consistency với SharePoint Lists sử dụng taxonomy
5. **Document:** Cập nhật module spec liên quan đến taxonomy changes


Mọi term set, term group, term đều phải được định nghĩa rõ ràng trong repo (`datamodel/sharepoint/taxonomy/**`) dưới dạng JSON, có mô tả, ID duy nhất, và liên kết nghiệp vụ.


- Term group: `CCBA_<Domain>` (ví dụ: `CCBA_Project`, `CCBA_Asset`)
- Term set: `CCBA_<Tên>` (song ngữ nếu cần, ví dụ: `CCBA_TrangThaiChung`)
- Term: PascalCase, có mã duy nhất, mô tả rõ nghĩa, hỗ trợ đa ngôn ngữ.
- Mỗi term set phải có owner, mô tả nghiệp vụ, và quy tắc cập nhật/phê duyệt.
- Quy trình cập nhật:
  - Mọi thay đổi phải qua Pull Request, có review/approval của Integrator.
  - Khi import lên SharePoint, phải validate uniqueness, mapping, và log lại lịch sử thay đổi.
  - Khi export từ SharePoint, phải đồng bộ về repo, ghi rõ lý do và tác động.
- Tuân thủ các nguyên tắc về phân quyền, audit trail, retention, và versioning như Lists.
- Đảm bảo mapping giữa termstore và các trường Managed Metadata trong Lists; mọi thay đổi phải được kiểm thử trước khi áp dụng vào Prod.
- Checklist riêng cho taxonomy:
  - [ ] Định nghĩa đầy đủ term group, term set, term với mã, mô tả, ngôn ngữ.
  - [ ] Mapping rõ ràng tới các trường Managed Metadata trong Lists.
  - [ ] Quy trình cập nhật/phê duyệt rõ ràng, có log lịch sử.
  - [ ] Validate uniqueness, mapping, versioning khi import/export.
  - [ ] Owner và mô tả nghiệp vụ cho từng term set.



## 5) Checklist bắt buộc theo từng bước



### S1 — Scaffold & Configure

- [ ] `.speckit.yml` có `docs.entry`, `docs.output`, placeholders cho spec/plan/tasks.
- [ ] Datamodel JSON, taxonomy, schemas hiện diện và hợp lệ với schema.
- [ ] Scripts rỗng hoặc khung lệnh đã sẵn (`apply-sp-lists`, `termstore-import`, `sp-diff`).


### S2 — Detailed Design (AI)

- [ ] `spec.md` mô tả mục tiêu, phạm vi, user stories, acceptance criteria, quy trình & ràng buộc đặc thù.
- [ ] `plan.md` nêu kiến trúc, data model, flows, env & security, tích hợp & cấu hình đặc thù.
- [ ] `tasks.md` có backlog khả thi; liên kết tới datamodel/taxonomy chịu ảnh hưởng.
- [ ] Tất cả bám theo quy ước tên, bảo mật, uniqueness, retention, audit trail.


### S3 — Review & Merge (PR)

- [ ] Đặc tả phù hợp chiến lược CCBA (theo tài liệu chiến lược/VTO/quy chế).
- [ ] Diff datamodel/taxonomy rõ ràng; lý do thay đổi và tác động.
- [ ] Đã có kế hoạch rollback và snapshot.


### S4 — Technical Deployment

- [ ] Validate schemas trước khi apply; chạy diff (dry‑run) và sao lưu.
- [ ] Áp dụng Lists/Taxonomy bằng script phù hợp OS (ps1|sh).
- [ ] Secrets/connection refs lấy từ môi trường; không hard‑code.


### S5 — Testing & Acceptance

- [ ] Seed data, flow approvals, dashboards cơ bản chạy được.
- [ ] Data quality: required/regex/dedup đạt chuẩn; ghi lại kết quả vào `tasks.md`.


### S6 — Operate & Improve

- [ ] Theo dõi SLA/RAG; khi có thay đổi quay lại vòng `spec → plan → tasks`.
- [ ] Lưu trữ audit logs, approvals; thực thi retention phù hợp quy chế.


## 6) Liên kết tài liệu chiến lược (nguồn tham chiếu)

- Kế hoạch chiến lược & Sơ đồ trách nhiệm giải trình (CCBA, file nội bộ).
- IDOP — Nền tảng Hoạt động Số Tích Hợp (whitepaper nội bộ).
- Quy chế hoạt động Trung tâm BIM (phiên bản 2025), các điều khoản về phân quyền, phê duyệt, lưu trữ.
- V/TO (Vision/Traction Organizer) — mục tiêu, chỉ số, sáng kiến trọng điểm.

Các tài liệu này định hình acceptance criteria ở cấp tổ chức. Khi có xung đột, ưu tiên tuân thủ quy chế và quyết định của Integrator.


## 7) Cách dùng nhanh (SpecKit + VS Code)

- Kiểm tra môi trường: `./tools/speckit/specify.ps1 check`
- Khởi tạo/đồng bộ khung: `./tools/speckit/specify.ps1 init --here --ai copilot --script ps`
- Viết đặc tả/plan/tasks theo prompts và checklist; mở PR để review/merge.


---


Tài liệu này cần được cập nhật liên tục khi phát hiện ràng buộc mới trong quá trình triển khai. Mọi chỉnh sửa phải đi qua PR và được “Trình ký”.

