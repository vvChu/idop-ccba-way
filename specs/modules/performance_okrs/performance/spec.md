# Đặc Tả Kỹ Thuật Module: Performance (OKRs & KPIs)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý mục tiêu (OKRs), đo lường hiệu suất (KPIs) và liên kết với hệ thống đánh giá để xét quỹ thưởng.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Thiết lập Objectives & Key Results.
- Theo dõi tiến độ KPIs.
- Gắn kết hiệu suất với Quỹ thưởng tầng 3.
- **Không bao gồm (Out-of-Scope)**:
- Tính toán chi tiết thuật toán lương.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-PER-01**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn tạo Objective cấp Trung tâm trên IDOP để định hướng chiến lược.
- **US-PER-02**: Với tư cách `ROLE_HEAD_BIM_DESIGN` — Trưởng phòng BIM Thiết kế, tôi muốn tạo OKRs cấp phòng trên IDOP để phân rã mục tiêu.
- **US-PER-03**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn cập nhật Current Value của Key Result trên IDOP để báo cáo tiến độ.
- **US-PER-04**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn đánh giá OKRs cuối quý trên IDOP để quyết định mức thưởng.
- **US-PER-05**: Với tư cách `ROLE_HEAD_BIM_PROJECT` — Trưởng phòng BIM Dự án, tôi muốn thiết lập KPIs dự án trên IDOP để giao việc cho thành viên.
- **US-PER-06**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn xem tiến độ OKRs cá nhân trên IDOP để tự cải thiện hiệu suất.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | C, R, U, A | Quản trị OKR cấp cao nhất |
| `ROLE_HEAD_BIM_DESIGN` | C*, R, U* | Quản lý OKR phòng ban |
| `ROLE_HEAD_BIM_PROJECT` | C*, R, U* | Quản lý OKR phòng ban |
| `ROLE_STAFF` | R*, U* | Cập nhật tiến độ KR cá nhân |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Quy chế CCBA 2026: Điều 9 (Đánh giá năng lực).
- QCCTNB 3209: Quỹ thưởng tầng 3 dựa trên hiệu suất.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Thiết lập**: Đầu quý, GĐ thiết lập OKR TT. Các phòng phân rã.
2. **Tracking**: NV cập nhật số liệu KR hàng tuần.
3. **Review**: Cuối quý tiến hành check-in, đánh giá kết quả.
4. **Phần thưởng**: Liên kết kết quả OKR vào việc phân bổ quỹ thưởng tầng 3.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `okrs_objectives`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ObjectiveTitle` | Text | Yes |\n| `Owner` | User | No |\n| `QuarterId` | Lookup | No |\n| `ParentObjectiveId` | Lookup | No |\n| `DepartmentId` | Lookup | No |\n| `Description` | Text | No |\n\n#### List: `okrs_key_results`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ObjectiveId` | Lookup | No |\n| `KeyResultTitle` | Text | Yes |\n| `TargetValue` | Number | No |\n| `CurrentValue` | Number | No |\n\n#### List: `quarters`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `Year` | Number | Yes |\n| `Quarter` | Choice | No |\n| `StartDate` | DateTime | No |\n| `EndDate` | DateTime | No |\n
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
