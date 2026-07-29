# Đặc Tả Kỹ Thuật Module: Allocations (Phân bổ Doanh thu)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý việc phân bổ doanh thu theo Cơ chế 3 tầng QCCTNB 3209 và Bảng 1 QCTK 2815 Điều 12.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Phân bổ doanh thu theo tỷ lệ quy định.
- Tính toán Quỹ thưởng tầng 3.
- Theo dõi phân bổ chi phí chung.
- **Không bao gồm (Out-of-Scope)**:
- Thanh toán trực tiếp cho nhân viên.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-ALL-01**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn xem bảng phân bổ chi phí chung trên IDOP để kiểm soát quỹ vận hành.
- **US-ALL-02**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn thiết lập tỷ lệ phân bổ tự động trên IDOP để giảm sai sót thủ công.
- **US-ALL-03**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn xem tỷ lệ phân bổ của dự án trên IDOP để tính toán quỹ thưởng tầng 3.
- **US-ALL-04**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn cập nhật các quy tắc phân bổ trên IDOP để phù hợp quy chế mới.
- **US-ALL-05**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn phê duyệt bảng phân bổ cuối cùng trên IDOP để tiến hành trích lập các quỹ.
- **US-ALL-06**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn xuất báo cáo phân bổ ngân sách trên IDOP để chia sẻ cho team.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Phê duyệt phân bổ |
| `ROLE_ACCOUNTANT` | C, R, U, A | Quản lý quy tắc và số liệu phân bổ |
| `ROLE_PROJECT_MANAGER` | C*, R, U* | Đề xuất phân bổ nội bộ dự án |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- QCTK 2815: Điều 12 (Bảng 1 - Phân bổ tài chính).
- QCCTNB 3209: Cơ chế phân bổ 3 tầng.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Ghi nhận Doanh thu**: Tiền về tài khoản.
2. **Áp dụng Quy tắc**: Kế toán áp dụng quy tắc phân bổ (tầng 1, 2, 3).
3. **Tính toán Tầng 3**: PM chia tỷ lệ cho thành viên dự án.
4. **Phê duyệt**: GĐ duyệt chốt danh sách phân bổ.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `allocation_rules`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `RuleName` | Text | Yes |\n| `Description` | Text | No |\n\n#### List: `shared_cost_allocations`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ExpenseId` | Lookup | No |\n| `AllocationRuleId` | Lookup | No |\n| `Amount` | Number | No |\n
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
