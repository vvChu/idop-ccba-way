# Đặc Tả Kỹ Thuật Module: Finance (Quản lý Kế hoạch Tài chính, Hóa đơn & Đối tác)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý toàn bộ Kế hoạch tài chính (`FinancialPlans`), Quy trình Yêu cầu và Phát hành Hóa đơn GTGT (Step 6 Nghiệm thu & Xuất hóa đơn theo Điều 11 QCTK 2815), Hóa đơn đầu vào (`InputInvoices`), Tài khoản ngân hàng (`BankAccounts`) và Danh mục Nhà cung cấp / Đối tác (`Vendors`).
- Số hóa 100% Step 6 Nghiệm thu & Xuất hóa đơn (`nghiem_thu_xuat_hoa_don`) trong Chuỗi 7 bước nghiệp vụ IDOP.
- Quản lý chính xác công nợ phải thu của bên A, công nợ phải trả cho nhà cung cấp, nghĩa vụ thuế GTGT và theo dõi dòng tiền qua tài khoản ngân hàng của Viện KHCN Xây dựng.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Lập và theo dõi Kế hoạch Tài chính năm (`FinancialPlans`).
  - Quản lý Quy trình Yêu cầu xuất hóa đơn (`InvoiceRequests`) và Phát hành Hóa đơn đầu ra (`OutgoingInvoices`) gắn với Hợp đồng (`Contracts`).
  - Quản lý Hóa đơn đầu vào (`InputInvoices`) gắn với Nhà cung cấp (`Vendors`).
  - Quản lý Danh mục Tài khoản Ngân hàng giao dịch (`BankAccounts`).
  - Quản lý Danh mục Nhà cung cấp / Thầu phụ (`Vendors`).
  - Quản lý Danh mục Yêu cầu Hồ sơ Chứng từ (`DocumentRequirements`).
  - Tích hợp 1-to-1 với 7 SharePoint Lists: `FinancialPlans`, `InvoiceRequests`, `OutgoingInvoices`, `InputInvoices`, `BankAccounts`, `Vendors`, `DocumentRequirements`.
- **Không bao gồm (Out-of-Scope)**:
  - Khai báo và truyền dữ liệu hóa đơn điện tử trực tiếp sang cơ quan Thuế (thực hiện qua phần mềm MISA/MeInvoice tích hợp của TCKT).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-FIN-01**: Là *Chủ nhiệm Dự án (PM / Chủ trì HĐ)*, tôi muốn lập Yêu cầu xuất hóa đơn (`InvoiceRequests`) sau khi có Biên bản Nghiệm thu khối lượng hoàn thành với Bên A.
- **US-FIN-02**: Là *Phòng Tài chính - Kế toán (TCKT Viện)*, tôi muốn kiểm tra Biên bản Nghiệm thu, duyệt Yêu cầu xuất hóa đơn và phát hành Hóa đơn GTGT đầu ra (`OutgoingInvoices`).
- **US-FIN-03**: Là *Phụ trách Kế toán CCBA*, tôi muốn nhập Hóa đơn đầu vào (`InputInvoices`) từ các Nhà cung cấp (`Vendors`) để đối soát công nợ phải trả.
- **US-FIN-04**: Là *Kế toán Ngân hàng Viện*, tôi cập nhật thông tin tiền chuyển khoản về các Tài khoản Ngân hàng (`BankAccounts`) và gán số tiền thu hồi cho Hợp đồng tương ứng.
- **US-FIN-05**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi xem Kế hoạch Tài chính năm (`FinancialPlans`) và báo cáo tổng hợp hóa đơn đầu ra/đầu vào trên IDOP.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | - | - | - | R |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | C | R (Toàn Viện) | U (Kế hoạch tài chính) | - | A (Kế hoạch năm) | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | C | R (Toàn Viện) | U (Hóa đơn/Ngân hàng) | - | A (Xuất Hóa đơn) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Đề nghị xuất HĐ) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Kế hoạch/Hóa đơn) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Hợp đồng giao) | U (Tạo InvoiceRequest) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Duyệt Đề nghị xuất HĐ) | - | A (Duyệt Đề nghị) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 11.1 (Step 6 Operational Flow - Nghiệm thu & Xuất hóa đơn)*:
    - Chủ trì HĐ và Phụ trách Kế toán căn cứ biên bản nghiệm thu giai đoạn/hoàn thành đề nghị Phòng TCKT xuất hóa đơn GTGT.
    - Phòng TCKT giải quyết xuất hóa đơn trong vòng không quá 03 ngày làm việc kể từ khi đủ hồ sơ hợp lệ.
  - *Điều 14.2.7 (Nghĩa vụ thuế GTGT khi xuất hóa đơn)*: Chủ trì HĐ phải nộp đủ nghĩa vụ VAT trong vòng 01 năm kể từ ngày xuất hóa đơn, ngay cả khi Bên A chưa thanh toán.
  - *Điều 9.7 (Trách nhiệm Phòng TCKT)*: Quản lý chứng từ thu chi, xuất hóa đơn, đôn đốc thu hồi nợ và đối chiếu tài chính.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - *Điều 4 - 6*: Quy định quản lý nguồn kinh phí NSNN, nguồn thu hoạt động sự nghiệp và nguồn tài chính khác.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Số hóa quy trình quản lý hóa đơn và đối soát công nợ tự động trên IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Step 6 Nghiệm thu & Quản lý Hóa đơn Tài chính

```
[Biên bản Nghiệm thu Stage/Final] -> [Lập Yêu cầu Xuất HĐ (InvoiceRequests)] -> [TCKT Duyệt & Phát hành OutgoingInvoices] -> [Theo dõi Tiền về BankAccounts] -> [Quản lý Hóa đơn Đầu vào InputInvoices & Vendors]
```

1. **Bước 6.1: Lập Yêu cầu Xuất Hóa đơn (`InvoiceRequests`)**:
   - PM / Cán bộ lập bản ghi `InvoiceRequests` trong list `InvoiceRequests`.
   - Chọn `ContractId` Lookup, `RequestDate`, `Amount`, `Currency`. Đính kèm Biên bản Nghiệm thu.
2. **Bước 6.2: Thẩm định & Xuất Hóa đơn GTGT (`OutgoingInvoices`)**:
   - TCKT kiểm tra tính đầy đủ của hồ sơ nghiệm thu.
   - Phát hành hóa đơn trong list `OutgoingInvoices`, nhập `InvoiceNumber`, `InvoiceDate`, `NetAmount`, `VATRate`, tự động tính `GrossAmount = NetAmount * (1 + VATRate)`.
3. **Bước 6.3: Ghi nhận Tiền về Ngân hàng (`BankAccounts`)**:
   - Kế toán ngân hàng đối soát số tiền Bên A thanh toán về tài khoản `BankAccounts`, gán số tiền thu hồi cho `OutgoingInvoices` và Hợp đồng.
4. **Bước 6.4: Quản lý Hóa đơn Đầu vào (`InputInvoices`) & Nhà cung cấp (`Vendors`)**:
   - Tiếp nhận hóa đơn từ thầu phụ/nhà cung cấp (`Vendors`), lưu thông tin vào `InputInvoices` (`VendorId`, `InvoiceNumber`, `NetAmount`, `VATRate`, `GrossAmount`, `InvoiceDate`) để khấu trừ thuế GTGT và thanh toán công nợ.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `FinancialPlans` (`datamodel/sharepoint/lists/cash_data/financial_plans.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `PlanName` | Text | Yes | - | Tên kế hoạch tài chính (ví dụ: Kế hoạch Tài chính CCBA năm 2026) |
| `Year` | Number | No | - | Năm kế hoạch (ví dụ: 2026) |
| `TotalBudget` | Number | No | - | Tổng ngân sách kế hoạch (VND) |

#### List 2: `InvoiceRequests` (`datamodel/sharepoint/lists/cash_data/invoice_requests.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ContractId` | Lookup | No | List: `Contracts`, Field: `ID` | Liên kết bắt buộc tới Hợp đồng kinh tế |
| `RequestDate` | DateTime | No | - | Ngày đề nghị xuất hóa đơn |
| `Amount` | Number | No | - | Số tiền đề nghị xuất hóa đơn |
| `Currency` | Choice | No | `VND`, `USD`, `EUR` | Đồng tiền hạch toán |

#### List 3: `OutgoingInvoices` (`datamodel/sharepoint/lists/cash_data/outgoing_invoices.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ContractId` | Lookup | No | List: `Contracts`, Field: `ID` | Liên kết đến Hợp đồng kinh tế |
| `InvoiceNumber` | Text | Yes | - | Số hóa đơn GTGT đầu ra (Unique) |
| `Currency` | Choice | No | `VND`, `USD`, `EUR` | Đồng tiền hạch toán |
| `VATRate` | Number | No | Values: 0, 0.05, 0.08, 0.10 | Thuế suất GTGT (ví dụ: 0.10 cho 10%) |
| `GrossAmount` | Number | No | Calculated | Tổng giá trị hóa đơn sau thuế |
| `NetAmount` | Number | No | - | Giá trị hóa đơn trước thuế |
| `InvoiceDate` | DateTime | No | - | Ngày phát hành hóa đơn |

#### List 4: `InputInvoices` (`datamodel/sharepoint/lists/cash_data/input_invoices.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `VendorId` | Lookup | No | List: `Vendors`, Field: `ID` | Liên kết đến Nhà cung cấp |
| `InvoiceNumber` | Text | Yes | - | Số hóa đơn GTGT đầu vào |
| `Currency` | Choice | No | `VND`, `USD`, `EUR` | Đồng tiền hạch toán |
| `VATRate` | Number | No | Values: 0, 0.05, 0.08, 0.10 | Thuế suất GTGT |
| `GrossAmount` | Number | No | Calculated | Tổng giá trị hóa đơn sau thuế |
| `NetAmount` | Number | No | - | Giá trị hóa đơn trước thuế |
| `InvoiceDate` | DateTime | No | - | Ngày nhận hóa đơn |

#### List 5: `BankAccounts` (`datamodel/sharepoint/lists/cash_data/bank_accounts.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `BankName` | Text | Yes | - | Tên ngân hàng (ví dụ: VietinBank - Chi nhánh Hà Nội) |
| `AccountNumber` | Text | Yes | - | Số tài khoản ngân hàng (Unique) |
| `AccountName` | Text | No | - | Tên chủ tài khoản (Viện KHCN Xây dựng / CCBA) |
| `Currency` | Choice | No | `VND`, `USD`, `EUR` | Loại tiền tệ tài khoản |

#### List 6: `Vendors` (`datamodel/sharepoint/lists/cash_data/vendors.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `VendorName` | Text | Yes | - | Tên Nhà cung cấp / Đối tác / Thầu phụ |
| `VendorCode` | Text | No | - | Mã số nhà cung cấp (Unique) |
| `ServiceType` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Loại hình dịch vụ nhà cung cấp cung cấp |

#### List 7: `DocumentRequirements` (`datamodel/sharepoint/lists/cash_data/document_requirements.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `RequirementName` | Text | Yes | - | Tên quy định / yêu cầu hồ sơ chứng từ |
| `Description` | Text | No | - | Mô tả chi tiết yêu cầu hồ sơ chứng từ |
| `AppliesTo` | Choice | No | `Contract`, `Invoice`, `Expense` | Phạm vi áp dụng (Hợp đồng, Hóa đơn, Chi phí) |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-FIN-01**: `InvoiceNumber` trong `OutgoingInvoices` và `InputInvoices` bắt buộc nhập và không được trùng lặp.
- **AC-FIN-02**: Mọi bản ghi `InvoiceRequests` và `OutgoingInvoices` bắt buộc có `ContractId` Lookup liên kết đến 01 Hợp đồng hợp lệ.
- **AC-FIN-03**: Hệ thống tự động tính toán `GrossAmount = NetAmount * (1 + VATRate)` trên tất cả các hóa đơn.
- **AC-FIN-04**: Trường `ServiceType` trong `Vendors` bắt thuộc nhóm Taxonomy `CCBA_LoaiHinhDichVu`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Lãnh đạo Viện / Ban Giám đốc CCBA**: Xem toàn bộ báo cáo kế hoạch tài chính, hóa đơn và dòng tiền ngân hàng.
- **Phòng TCKT Viện**: Toàn quyền Phát hành `OutgoingInvoices`, ghi nhận `InputInvoices`, quản lý `BankAccounts` và `Vendors`.
- **Trưởng phòng / PM CCBA**: Lập `InvoiceRequests` và xem trạng thái hóa đơn của hợp đồng do mình quản lý.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo bản ghi hóa đơn/kế hoạch |
| `Author` | User | Người tạo bản ghi |
| `Modified` | DateTime | Thời gian phát hành / hạch toán |
| `Editor` | User | Kế toán viên / Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Phiên bản lịch sử dữ liệu tài chính |
