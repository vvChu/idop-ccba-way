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

> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md) — Phần 4 (Hướng dẫn Spec Authors)

### 2.1 User Stories
| Mã US | Vai trò | Mô tả User Story | Tham chiếu |
| :--- | :--- | :--- | :--- |
| US-CRM-01 | `ROLE_DEPUTY_DIRECTOR` — Phó Giám đốc Khối DV&KD | Với tư cách Phó Giám đốc Khối DV&KD, tôi muốn cập nhật thông tin khách hàng trọng điểm trên IDOP để quản lý doanh số và phát triển thị trường | Phụ lục 01 Quy chế CCBA |
| US-CRM-02 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ | Với tư cách Chủ trì HĐ, tôi muốn tra cứu thông tin liên hệ của khách hàng trên IDOP để trao đổi công việc và đôn đốc nghiệm thu dự án | QCTK 2815 |
| US-CRM-03 | `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp | Với tư cách Trưởng phòng Tổng Hợp, tôi muốn theo dõi danh sách khách hàng trên IDOP để phối hợp với các phòng chức năng của Viện IBST khi cần đối ngoại | Phụ lục 01 Quy chế CCBA |
| US-CRM-04 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn xem báo cáo danh mục khách hàng trên IDOP để định hướng chiến lược kinh doanh và đối ngoại | Phụ lục 01 Quy chế CCBA |
| US-CRM-05 | `ROLE_LEGAL_QA` — Cố vấn Pháp lý | Với tư cách Cố vấn Pháp lý, tôi muốn tra cứu hồ sơ khách hàng trên IDOP để thẩm định tính hợp lệ pháp nhân trước khi ký HĐ | Điều 9 Quy chế CCBA |
| US-CRM-06 | `ROLE_STAFF` — NLĐ | Với tư cách Viên chức NLĐ, tôi muốn xem thông tin cơ bản của khách hàng trong dự án mình tham gia trên IDOP để phục vụ công việc chuyên môn | QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)

> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | crm (customers / contacts / service_catalog) |
|:---|:---:|
| `ROLE_DIRECTOR` | R, A |
| `ROLE_DEPUTY_DIRECTOR` | C, R, U |
| `ROLE_LEGAL_QA` | R |
| `ROLE_HEAD_ADMIN` | R |
| `ROLE_HEAD_RD` | R |
| `ROLE_HEAD_BIM_DESIGN` | R |
| `ROLE_HEAD_BIM_PROJECT` | R |
| `ROLE_PROJECT_MANAGER` | C, R, U |
| `ROLE_STAFF` | R* |

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

> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md) — Phần 3 Trục 1 (Kỹ thuật với Phòng KHKT)

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

> Tham chiếu: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md) — Phần 3 (SharePoint Permission Groups)

- `CCBA_BanGiamDoc`: Full Control (Phê duyệt và quản lý toàn bộ dữ liệu CRM)
- `CCBA_ChuTri_All`: Contribute (Thêm và cập nhật khách hàng liên quan đến dự án)
- `CCBA_PhongTongHop` + `CCBA_Legal_QA`: Read / Contribute (Để kiểm tra pháp nhân và liên hệ đối ngoại)
- `CCBA_VCNLD_All`: Read (Hạn chế xem trong phạm vi dự án tham gia)

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Thời điểm khởi tạo bản ghi |
| `Author` (CreatedBy) | User | Người tạo bản ghi |
| `Modified` | DateTime | Thời điểm cập nhật cuối cùng |
| `Editor` (ModifiedBy) | User | Người thực hiện cập nhật cuối cùng |
| `SystemVersion` | Integer | Số phiên bản ghi nhận thay đổi (SharePoint Versioning enabled) |
