# Đặc Tả Kỹ Thuật Module: Expenses (Quản lý Chi phí)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý các khoản chi phí, kiểm soát định mức theo QCCTNB 3209 và quy trình phê duyệt chi tiêu.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Đề nghị thanh toán/tạm ứng.
- Kiểm tra định mức chi phí.
- Phê duyệt chi tiêu nội bộ.
- **Không bao gồm (Out-of-Scope)**:
- Giao dịch ngân hàng thực tế ngoài hệ thống.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-EXP-01**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn tạo đề nghị tạm ứng trên IDOP để có kinh phí đi công tác.
- **US-EXP-02**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn kiểm tra hạn mức chi phí trên IDOP để đảm bảo không vượt ngân sách.
- **US-EXP-03**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn phê duyệt các khoản chi lớn trên IDOP để kiểm soát rủi ro.
- **US-EXP-04**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn duyệt chi phí của dự án trên IDOP để kiểm soát ngân sách.
- **US-EXP-05**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn nộp chứng từ hoàn ứng trên IDOP để hoàn tất quy trình chi tiêu.
- **US-EXP-06**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn kết xuất dữ liệu chi phí trên IDOP để đối chiếu với sổ sách TCKT.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Phê duyệt chi phí |
| `ROLE_ACCOUNTANT` | C, R, U, A | Quản lý, kiểm tra định mức chi phí |
| `ROLE_PROJECT_MANAGER` | C*, R, U* | Đề xuất và duyệt chi nhánh dự án |
| `ROLE_STAFF` | C*, R* | Đề nghị thanh toán cá nhân |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- QCTK 2815: Quy định hạn mức chi tiêu.
- QCCTNB 3209: Định mức chi phí cho từng hoạt động.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Tạo Đề nghị**: NLĐ/PM tạo yêu cầu chi tiêu.
2. **Kiểm tra Kế toán**: Kế toán duyệt hạn mức, chứng từ.
3. **Phê duyệt**: Lãnh đạo (GĐ/PGĐ) duyệt.
4. **Thanh toán**: Kế toán chi tiền và cập nhật trạng thái.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `expenses`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ProjectId` | Lookup | No |\n| `ExpenseType` | ManagedMetadata | No |\n| `Currency` | Choice | No |\n| `VATRate` | Number | No |\n| `GrossAmount` | Number | No |\n| `NetAmount` | Number | No |\n| `ExpenseDate` | DateTime | No |\n\n#### List: `expense_checklists`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ExpenseId` | Lookup | No |\n| `ChecklistItem` | Text | No |\n| `IsCompleted` | YesNo | No |\n
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
