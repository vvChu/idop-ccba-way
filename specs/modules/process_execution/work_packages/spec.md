# Đặc Tả Kỹ Thuật Module: Work Packages (Quản lý Gói Công việc & Cấu trúc Phân chia WBS)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
- Quản lý cấu trúc WBS thành các Work Packages cụ thể.
- Theo dõi tiến độ chi tiết của các gói công việc.

### 1.2 Phạm vi
- Khởi tạo WBS, phân công người phụ trách, cập nhật trạng thái.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
| US-WP-01 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA | Với tư cách Chủ trì HĐ, tôi muốn phân chia dự án thành gói công việc (WBS) trên IDOP để kiểm soát tiến độ | Điều 8 QCTK 2815 |
| US-WP-02 | `ROLE_HEAD_BIM_DESIGN` — Trưởng phòng BIM Thiết kế | Với tư cách Trưởng phòng BIM Thiết kế, tôi muốn phân công nhân sự thiết kế vào gói công việc trên IDOP để điều hành sản xuất | Điều 8 QCTK 2815 |
| US-WP-03 | `ROLE_STAFF` — Cá nhân / Viên chức NLĐ | Với tư cách Viên chức NLĐ, tôi muốn cập nhật tiến độ công việc được giao trên IDOP để PM nghiệm thu | Điều 8 QCTK 2815 |
| US-WP-04 | `ROLE_EXTERNAL_PARTNER` — Cộng tác viên / Đối tác | Với tư cách CTV, tôi muốn báo cáo tiến độ gói việc khoán trên IDOP để làm căn cứ thanh toán | Điều 7 QCTK 2815 |
| US-WP-05 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn xem tỷ lệ hoàn thành WBS trên IDOP để đánh giá hiệu suất | Điều 8 QCTK 2815 |
| US-WP-06 | `ROLE_HEAD_BIM_PROJECT` — Trưởng phòng BIM Dự án | Với tư cách Trưởng phòng BIM Dự án, tôi muốn giám sát các WP quá hạn trên IDOP để nhắc nhở PM | Điều 8 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R | Xem WBS toàn hệ thống |
| `ROLE_PROJECT_MANAGER` | C, R, U | Phân chia WBS, cập nhật tiến độ |
| `ROLE_HEAD_BIM_DESIGN` | C*, R, U* | Phân công nhân sự bộ môn |
| `ROLE_HEAD_BIM_PROJECT` | C*, R, U* | Phân công nhân sự quản lý dự án |
| `ROLE_STAFF` | R*, U* | Cập nhật tiến độ WBS cá nhân |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Quy chế CCBA 2026.
- QCTK 2815 (Điều 8).

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow)
1. `ROLE_PROJECT_MANAGER` chia WBS.
2. Trưởng phòng gán `AssignedTo`.
3. `ROLE_STAFF` cập nhật tiến độ phạm vi được giao.

---

## 5. Acceptance Criteria & List Mapping
Tích hợp list `WorkPackages`.

---

## 6. Bảo mật, Phân quyền & Audit Trail
### 6.1 Phân quyền Truy cập (SharePoint Groups)
- `CCBA_BanGiamDoc`: Xem toàn bộ.
- `CCBA_ChuTri_All`: Quản lý cấp dự án (Contribute).
- `CCBA_VCNLD_All`: Cập nhật gói việc cá nhân (Contribute).
