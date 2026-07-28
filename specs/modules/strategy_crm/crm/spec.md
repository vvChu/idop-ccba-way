# Đặc Tả Kỹ Thuật Module: CRM (Quản lý Quan hệ Khách hàng)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý tập trung toàn bộ vòng đời khách hàng (từ đối tác, doanh nghiệp, cơ quan nhà nước đến cá nhân), danh bạ người liên hệ và danh mục dịch vụ chuẩn của Trung tâm CCBA.
- Thiết lập nền tảng dữ liệu khách hàng liên thông với chu trình 7 bước nghiệp vụ IDOP: CRM → Trình ký HĐ → PGV → Thực thi → Kiểm tra nội bộ → Nghiệm thu → Quyết toán.
- Đảm bảo tính minh bạch, lưu vết lịch sử tương tác và tuân thủ các quy định về bảo mật, phân quyền thông tin khách hàng.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quản lý hồ sơ khách hàng (Customer Management): mã số thuế, địa chỉ, ngành nghề, loại hình khách hàng, nguồn gốc.
  - Quản lý danh bạ liên hệ (Contact Management): người đại diện, chức danh, vai trò liên hệ trong dự án, thông tin liên lạc.
  - Quản lý Danh mục dịch vụ chuẩn (Service Catalog): phân loại dịch vụ BIM, tư vấn thiết kế, kiểm định, đào tạo, đơn giá và thời gian chuẩn.
  - Liên kết dữ liệu CRM với các module Hợp đồng (`contracts`), Dự án (`projects`), Tài chính (`cash_data`).
- **Không bao gồm (Out-of-Scope)**:
  - Quản lý chiến dịch marketing tự động qua mạng xã hội ngoài email/forms (được xử lý ở module Lead Capture).
  - Xuất hóa đơn trực tiếp từ CRM (xử lý ở module `cash_data/finance`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-CRM-01**: Là *Chuyên viên Kinh doanh CCBA*, tôi muốn tạo và cập nhật thông tin khách hàng cùng các liên hệ liên quan để theo dõi lịch sử làm việc và xây dựng mối quan hệ bền vững.
- **US-CRM-02**: Là *Trưởng phòng Chuyên môn (TPM)*, tôi muốn xem thông tin khách hàng và danh mục dịch vụ phù hợp để lập phương án đề xuất kỹ thuật - báo giá.
- **US-CRM-03**: Là *Chủ nhiệm Dự án (PM)*, tôi muốn tra cứu thông tin người đại diện bên A (khách hàng) để trao đổi công việc, gửi báo cáo tiến độ và biên bản nghiệm thu.
- **US-CRM-04**: Là *Phòng Kế hoạch - Kỹ thuật (KHKT Viện)*, tôi muốn đối soát mã số thuế và tư cách pháp nhân khách hàng trước khi trình Lãnh đạo Viện phê duyệt Hợp đồng.
- **US-CRM-05**: Là *Ban Giám đốc (BGD CCBA/Viện)*, tôi muốn xem báo cáo phân tích nhóm khách hàng, tỷ lệ quay lại và doanh thu đóng góp theo từng ngành nghề.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | R | R | - | - | - | R |
| **Phòng Kế hoạch - Tài chính (KHTC/KHKT/TCKT Viện)** | R | R | U (TaxCode) | - | A (Pháp lý) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Nội bộ) | U (Phụ trách) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Dự án giao) | U (Liên hệ) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Phòng) | - | A (Khách hàng mới) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 4 (Nguyên tắc thực hiện)*: Mỗi nhiệm vụ/dịch vụ chỉ có 01 đơn vị đầu mối và 01 cá nhân chủ trì chịu trách nhiệm toàn diện với khách hàng.
  - *Điều 5.1 (Công tác thị trường & Đấu thầu)*: Quy định đăng ký đơn vị đầu mối làm việc với khách hàng thông qua Phòng KHKT Viện để tránh chồng chéo tiếp cận giữa các đơn vị.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - *Điều 8.2.5 (Chi giao dịch, tiếp khách)*: Quy định hạn mức và chứng từ chi phí tiếp khách hàng phải gắn liền với mã khách hàng và cơ hội kinh doanh cụ thể.
- **Quy chế CCBA 2026 (Quyết định ban hành năm 2026)**:
  - *Điều 3 (Nguyên tắc quản trị cốt trị)*: Trách nhiệm giải trình đơn nhất của Trưởng phòng/PM trong việc giao tiếp và lưu trữ dữ liệu thông tin khách hàng trên hệ thống IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Tiếp nhận & Xử lý Thông tin Khách hàng

```
[Bước 1: Tiếp nhận thông tin] -> [Bước 2: Phân loại & Check Trùng] -> [Bước 3: Tạo Khách hàng & Contacts] -> [Bước 4: Thẩm định Mã số thuế] -> [Bước 5: Gắn Service Catalog] -> [Bước 6: Chuyển sang Opportunities/Contracts]
```

1. **Bước 1: Tiếp nhận thông tin khách hàng**: Thu thập từ thị trường, đối tác, Microsoft Forms hoặc liên hệ trực tiếp.
2. **Bước 2: Kiểm tra trùng lặp (Deduplication)**: Kiểm tra `TaxCode`, `CustomerName`, `Phone` trên SharePoint List `Customers` để tránh tạo trùng.
3. **Bước 3: Khởi tạo Hồ sơ Khách hàng & Contacts**:
   - Nhập thông tin pháp nhân vào `Customers`.
   - Tạo danh sách cá nhân đầu mối liên hệ vào `Contacts` (gắn `Lookup` đến `Customers`).
4. **Bước 4: Thẩm định Pháp lý Khách hàng**: Phòng KHTC/KHKT kiểm tra mã số thuế, trạng thái hoạt động của doanh nghiệp khách hàng.
5. **Bước 5: Gắn Gói Dịch vụ Chuẩn**: Liên kết yêu cầu khách hàng với `ServiceCatalog` (dịch vụ BIM, kiểm định, thẩm tra và các dịch vụ kỹ thuật khác).
6. **Bước 6: Chuyển giao Vòng đời**: Kết nối Khách hàng với Cơ hội (`Opportunities`) hoặc Hợp đồng (`Contracts`).

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `Customers` (`datamodel/sharepoint/lists/strategy_crm/customers.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `CustomerName` | Text | Yes | - | Tên khách hàng (Tên công ty / tổ chức / cá nhân) |
| `CustomerType` | ManagedMetadata | No | `CCBA_LoaiKhachHang` | Phân loại: Chủ đầu tư, BQLDA, Nhà thầu, Tư vấn |
| `Industry` | ManagedMetadata | No | `CCBA_NganhLinhVuc` | Ngành nghề: Dân dụng, Giao thông, Hạ tầng, Công nghiệp |
| `Source` | ManagedMetadata | No | `CCBA_NguonGocCoHoi` | Nguồn gốc: Đối tác giới thiệu, Đấu thầu, Website, Triển lãm |
| `Contacts` | Lookup | No | List: `Contacts`, Field: `ID` | Liên kết danh sách người liên hệ chính |
| `Opportunities` | Lookup | No | List: `Opportunities`, Field: `ID` | Liên kết danh sách các cơ hội kinh doanh liên quan |
| `TaxCode` | Text | No | - | Mã số thuế doanh nghiệp |
| `Address` | Text | No | - | Địa chỉ trụ sở đăng ký kinh doanh |
| `Phone` | Text | No | - | Số điện thoại liên hệ chính |
| `Email` | Text | No | - | Email giao dịch chính |

#### List 2: `Contacts` (`datamodel/sharepoint/lists/strategy_crm/contacts.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ContactName` | Text | Yes | - | Họ và tên người liên hệ |
| `Role` | ManagedMetadata | No | `CCBA_VaiTroLienHe` | Vai trò: Đại diện pháp luật, Giám đốc Dự án, Kế toán trưởng, Cán bộ kỹ thuật |
| `Email` | Text | No | - | Email cá nhân/công việc của liên hệ |
| `Phone` | Text | No | - | Số điện thoại di động |
| `Customer` | Lookup | No | List: `Customers`, Field: `ID` | Liên kết đến tổ chức/khách hàng chủ quản |

#### List 3: `ServiceCatalog` (`datamodel/sharepoint/lists/strategy_crm/service_catalog.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ServiceCode` | Text | Yes | - | Mã dịch vụ chuẩn (ví dụ: BIM-MOD-01, QA-QC-02) |
| `ServiceName` | Text | Yes | - | Tên dịch vụ chi tiết |
| `Category` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Nhóm dịch vụ: Tư vấn BIM, Thẩm tra, Kiểm định, Đào tạo |
| `Description` | Note | No | - | Mô tả phạm vi công việc chuẩn của gói dịch vụ |
| `IsActive` | YesNo | No | Default: `true` | Trạng thái đang cung cấp / ngưng cung cấp |
| `DefaultDurationDays` | Number | No | - | Thời gian thực hiện chuẩn (tính bằng ngày) |
| `DefaultPrice` | Number | No | - | Đơn giá tham chiếu (VND) |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-CRM-01**: Không được tạo trùng Khách hàng có cùng `TaxCode`. Hệ thống hiển thị cảnh báo nếu `TaxCode` đã tồn tại.
- **AC-CRM-02**: Mọi `Contact` khi khởi tạo phải liên kết đúng với 01 `Customer` thông qua trường `Customer` Lookup.
- **AC-CRM-03**: Tất cả các trường ManagedMetadata (`CustomerType`, `Industry`, `Source`, `Category`) phải tuân thủ chuẩn Taxonomy Group `CCBA Taxonomy`.
- **AC-CRM-04**: Hệ thống tự động lưu vết ngày tạo (`Created`), người tạo (`CreatedBy`), ngày sửa (`Modified`), người sửa (`ModifiedBy`) trên từng bản ghi.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Viện trưởng / BGD Viện**: Xem, xuất báo cáo toàn bộ dữ liệu CRM của các đơn vị.
- **Ban Giám đốc CCBA**: Toàn quyền (Full Control) đối với dữ liệu CRM của Trung tâm CCBA.
- **Trưởng phòng Chuyên môn (TPM)**: Xem/Sửa toàn bộ khách hàng và liên hệ thuộc phòng chuyên môn quản lý.
- **Chuyên viên / PM CCBA**: Xem toàn bộ danh mục khách hàng; Tạo và sửa các khách hàng/liên hệ do mình trực tiếp phụ trách (`Owner`).
- **Phòng KHKT / TCKT Viện**: Xem thông tin pháp nhân (`TaxCode`, `Address`, `CustomerName`) để thực hiện thủ tục hợp đồng và hóa đơn.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Thời điểm khởi tạo bản ghi |
| `Author` (CreatedBy) | User | Người tạo bản ghi |
| `Modified` | DateTime | Thời điểm cập nhật cuối cùng |
| `Editor` (ModifiedBy) | User | Người thực hiện cập nhật cuối cùng |
| `SystemVersion` | Integer | Số phiên bản ghi nhận thay đổi (SharePoint Versioning enabled) |
