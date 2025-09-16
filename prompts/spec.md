# Prompt viết spec.md

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

Mục tiêu: Viết/ cập nhật `spec.md` cho module theo Constitution (IDOP‑CCBA‑WAY), tuân thủ datamodel SharePoint và **taxonomy đã đồng bộ** lưu trong repo.

Yêu cầu đầu ra:

- Mục tiêu (business outcomes) và phạm vi.
- User stories (Given/When/Then), non‑functional requirements.
- Acceptance criteria có thể kiểm thử; ràng buộc & chỉ dẫn đặc thù (tên, phân quyền, audit, retention, uniqueness).
- Quy trình/BPMN tóm lược; liên kết tới Lists/Term sets sẽ dùng/ảnh hưởng.

Guardrails:

- **Tham chiếu JSON trong `datamodel/sharepoint/lists/**` và `datamodel/sharepoint/taxonomy/**` là bắt buộc.**
- **Sử dụng taxonomy terms từ các term sets đã có:** `CCBA_DonViPhongBan`, `CCBA_LoaiChiPhiPhanBo`, `CCBA_TrangThaiChung`, `CCBA_LoaiKhachHang`, `CCBA_MucDoUuTien`, etc.
- **Managed Metadata fields phải reference đúng term set ID và structure từ file JSON.**
- Không yêu cầu triển khai nếu đặc tả chưa được phê duyệt qua PR.
- Ghi rõ các thay đổi dự kiến với datamodel/taxonomy (diff ở mức khái niệm).

**Taxonomy CCBA hiện có (14 term sets, 66 terms):**

- **Tổ chức & Nhân sự:** `CCBA_DonViPhongBan`, `CCBA_ChucDanhBIM`, `CCBA_ChucDanhXayDung`, `CCBA_VaiTroLienHe`

- **Tài chính:** `CCBA_LoaiChiPhiPhanBo`, `CCBA_NguonVon`
- **Dự án & Kỹ thuật:** `CCBA_LoaiCongTrinh`, `CCBA_LoaiHinhDichVu`, `CCBA_MucDoUuTien`
- **CRM:** `CCBA_LoaiKhachHang`, `CCBA_NguonGocCoHoi`, `CCBA_NganhLinhVuc`
- **Quản lý:** `CCBA_LoaiTaiLieu`, `CCBA_TrangThaiChung`

Mẫu khởi tạo nhanh:

```markdown
# Module: <Tên module>

## Mục tiêu
...

## Phạm vi
...

## User stories
- As <role>, I want ... so that ...
...

## Acceptance criteria
- [ ] ...
- [ ] ...

## Quy trình & BPMN
Mô tả high-level, bước chính, trigger, exception.

## Ràng buộc & chỉ dẫn đặc thù
- Naming & codes:
- Phân quyền (Owner/Dept/Project Team):
- Audit trail (before/after), approvals:
- Retention & uniqueness:

## Phụ thuộc datamodel / taxonomy
- Lists liên quan: `datamodel/sharepoint/lists/...`
- **Term sets sử dụng:** (chọn từ 14 term sets đã đồng bộ)
  - `CCBA_TrangThaiChung` → Status fields
  - `CCBA_DonViPhongBan` → Department/Owner
  - `CCBA_LoaiChiPhiPhanBo` → Expense classification
  - `CCBA_LoaiKhachHang` → Customer segmentation
  - (định nghĩa rõ ràng mapping tới trường Managed Metadata, reference term set ID từ JSON)
```
