# Đặc Tả Kỹ Thuật Module: Projects (Quản lý Thực thi Dự án & 5 Luồng Quản lý)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý vòng đời thực thi các dự án trên IDOP của CCBA.
- Số hóa Step 4 Thực hiện (`thuc_hien_du_an`) theo 5 luồng quản lý thực hiện (QCTK 2815).
- Theo dõi tiến độ, rủi ro, và nhật ký dự án nội bộ.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quy trình 5 Luồng Quản lý Thực hiện: Tư vấn, Thí nghiệm, Thi công, Cung ứng, Quản lý tập trung.
  - Các SharePoint Lists: `Projects`, `ProjectHistory`, `ProjectIssues`, `ProjectRisks`.
- **Không bao gồm (Out-of-Scope)**:
  - Báo cáo tài chính chi tiết thanh lý HĐ.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
| US-PRJ-01 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA | Với tư cách Chủ trì HĐ, tôi muốn cập nhật tiến độ tổng thể dự án trên IDOP để theo dõi KPI thực thi | Điều 8 QCTK 2815 |
| US-PRJ-02 | `ROLE_STAFF` — Cá nhân / Viên chức NLĐ | Với tư cách Viên chức NLĐ, tôi muốn ghi nhận các issue phát sinh trên IDOP để PM kịp xử lý | Điều 8 QCTK 2815 |
| US-PRJ-03 | `ROLE_HEAD_BIM_PROJECT` — Trưởng phòng BIM Dự án | Với tư cách Trưởng phòng BIM Dự án, tôi muốn giám sát tổng thể rủi ro dự án trên IDOP để đảm bảo tiến độ | Điều 9 QCTK 2815 |
| US-PRJ-04 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn điều hành trực tiếp các dự án Quản lý tập trung (Luồng 5) trên IDOP để kiểm soát rủi ro cao | Điều 8.5 QCTK 2815 |
| US-PRJ-05 | `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp | Với tư cách Trưởng phòng Tổng Hợp, tôi muốn xuất báo cáo tiến độ IDOP để gửi Viện IBST khi có yêu cầu | Điều 9 QCTK 2815 |
| US-PRJ-06 | `ROLE_LEGAL_QA` — Cố vấn Pháp lý, TC & QLCL | Với tư cách Cố vấn Pháp lý, TC & QLCL, tôi muốn theo dõi rủi ro chất lượng trên IDOP để đưa ra tư vấn ngăn ngừa | Điều 8 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Xem và Phê duyệt dự án |
| `ROLE_DEPUTY_DIRECTOR` | R, U, A* | Điều hành dự án thuộc khối |
| `ROLE_HEAD_BIM_PROJECT` | R*, U* | Giám sát tổng thể (PMO) |
| `ROLE_HEAD_BIM_DESIGN` | R*, U* | Quản lý tiến độ thiết kế |
| `ROLE_PROJECT_MANAGER` | C, R, U | Lập và cập nhật dự án, rủi ro |
| `ROLE_STAFF` | R* | Xem dự án, tạo issue |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Tham chiếu 05_ccba_ibst_boundary_map.md (Bước 4: Thực hiện 5 luồng).
- **QCTK 2815**: Điều 8, Điều 9 (Quản lý Thực hiện Hợp đồng).

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow)
Tham chiếu [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md) Bước 4.
- `ROLE_PROJECT_MANAGER` cập nhật tình trạng tiến độ dự án trên IDOP.
- `ROLE_HEAD_BIM_PROJECT` đóng vai trò PMO giám sát các vấn đề và rủi ro.
- `ROLE_HEAD_ADMIN` lấy thông tin báo cáo cho Viện hoặc làm thủ tục tạm ứng giải ngân.

---

## 5. Acceptance Criteria & List Mapping
Tích hợp list `Projects`, `ProjectHistory`, `ProjectIssues`, `ProjectRisks`.

---

## 6. Bảo mật, Phân quyền & Audit Trail
### 6.1 Phân quyền Truy cập (SharePoint Groups)
- `CCBA_BanGiamDoc`: Full Control.
- `CCBA_PhongBIMDuAn`, `CCBA_TruongPhong_All`: Contribute (Cấp phòng).
- `CCBA_ChuTri_All`: Contribute (Cấp dự án).
- `CCBA_VCNLD_All`: Read-only, Create Issues (Hạn chế).
