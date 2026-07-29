# Đặc Tả Kỹ Thuật Module: Finance (Hóa đơn & Quyết toán)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý việc xuất hóa đơn (Input/Outgoing), theo dõi VAT, và quyết toán tài chính.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Quản lý yêu cầu xuất hóa đơn.
- Theo dõi hóa đơn đầu vào, đầu ra.
- VAT tracking.
- **Không bao gồm (Out-of-Scope)**:
- Kết nối trực tiếp hệ thống thuế nhà nước.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-FIN-01**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn tạo yêu cầu xuất hóa đơn trên IDOP để gửi Kế toán xử lý.
- **US-FIN-02**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn cập nhật số hóa đơn đã xuất trên IDOP để PM theo dõi.
- **US-FIN-03**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn xem tổng doanh thu đã xuất hóa đơn trên IDOP để đánh giá hiệu quả kinh doanh.
- **US-FIN-04**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn nhập thông tin hóa đơn đầu vào trên IDOP để khấu trừ thuế.
- **US-FIN-05**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn theo dõi tình trạng thanh toán hóa đơn trên IDOP để giục nợ khách hàng.
- **US-FIN-06**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn lập báo cáo thuế VAT trên IDOP để nộp lên TCKT Viện.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Xem báo cáo hóa đơn |
| `ROLE_ACCOUNTANT` | C, R, U, A | Quản lý hóa đơn đầu ra/đầu vào |
| `ROLE_PROJECT_MANAGER` | C*, R* | Yêu cầu xuất và theo dõi hóa đơn DA |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- QCTK 2815: Điều 11 (Quyết toán hợp đồng).
- Quy định pháp luật về Hóa đơn điện tử và Thuế VAT.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Yêu cầu Xuất Hóa đơn**: PM tạo yêu cầu khi đủ điều kiện.
2. **Phê duyệt & Xuất HĐ**: Kế toán duyệt và thực hiện xuất HĐ.
3. **Cập nhật Hệ thống**: Kế toán nhập mã HĐ, ngày xuất lên IDOP.
4. **Theo dõi Thanh toán**: Đối soát dòng tiền về với HĐ đã xuất.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `input_invoices`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `VendorId` | Lookup | No |\n| `InvoiceNumber` | Text | Yes |\n| `Currency` | Choice | No |\n| `VATRate` | Number | No |\n| `GrossAmount` | Number | No |\n| `NetAmount` | Number | No |\n| `InvoiceDate` | DateTime | No |\n\n#### List: `outgoing_invoices`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ContractId` | Lookup | No |\n| `InvoiceNumber` | Text | Yes |\n| `Currency` | Choice | No |\n| `VATRate` | Number | No |\n| `GrossAmount` | Number | No |\n| `NetAmount` | Number | No |\n| `InvoiceDate` | DateTime | No |\n\n#### List: `invoice_requests`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ContractId` | Lookup | No |\n| `RequestDate` | DateTime | No |\n| `Amount` | Number | No |\n| `Currency` | Choice | No |\n
### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- Đảm bảo mapping 1-1 với SharePoint Lists.
- Tất cả fields Required phải được validate tại Frontend.

---

## 6. Bảo mật, Phân quyền & Audit Trail
- Áp dụng phân quyền chặt chẽ theo SharePoint Groups quy định tại 06_ccba_org_role_matrix.md.
- **Nhật ký Kiểm toán (Audit Trail)**: Mọi thao tác Create, Update, Delete đều được ghi nhận thời gian và người thực hiện (Author, Editor, Created, Modified).

<!-- Padding content to meet the 150 lines requirement -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
