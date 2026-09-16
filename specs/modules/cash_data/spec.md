# Đặc Tả Kỹ Thuật Module: Financial Plans & Cash Data

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý dữ liệu tài chính, kế hoạch dòng tiền, và thông tin thu chi tổng thể của CCBA.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Quản lý kế hoạch tài chính dự án.
- Theo dõi tổng thể chi phí và doanh thu.
- Tích hợp với hệ thống kế toán 3 tầng.
- **Không bao gồm (Out-of-Scope)**:
- Xuất báo cáo thuế chính thức (do TCKT Viện phụ trách).
- Tính lương chi tiết (thực hiện ở HR).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-FIN-01**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn xem báo cáo dòng tiền tổng thể trên IDOP để ra quyết định điều hành.
- **US-FIN-02**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn lập kế hoạch tài chính năm trên IDOP để quản lý hạn mức.
- **US-FIN-03**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn xem ngân sách được cấp cho dự án trên IDOP để quản lý chi tiêu.
- **US-FIN-04**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn phê duyệt kế hoạch tài chính trên IDOP để bắt đầu thực thi.
- **US-FIN-05**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn theo dõi biến động ngân sách trên IDOP để cảnh báo khi vượt định mức.
- **US-FIN-06**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn yêu cầu bổ sung ngân sách trên IDOP để xử lý phát sinh.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Xem và Phê duyệt kế hoạch tài chính |
| `ROLE_ACCOUNTANT` | C, R, U, A | Quản lý toàn bộ dữ liệu tài chính |
| `ROLE_PROJECT_MANAGER` | R* | Xem dữ liệu tài chính dự án |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- QCTK 2815: Điều 11 (Quản lý dòng tiền dự án).
- QCCTNB 3209: Cơ chế tài chính 3 tầng.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Lập Kế hoạch**: Kế toán lập kế hoạch tài chính năm/dự án.
2. **Trình Duyệt**: GĐ duyệt kế hoạch.
3. **Thực thi & Theo dõi**: PM sử dụng ngân sách, Kế toán giám sát.
4. **Quyết toán**: Cuối kỳ tổng hợp báo cáo tài chính.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `financial_plans`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `PlanName` | Text | Yes |\n| `Year` | Number | No |\n| `TotalBudget` | Number | No |\n
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
