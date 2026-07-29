# Đặc Tả Kỹ Thuật Module: PMO (Quản lý Phân công Công việc & Phiếu Giao việc PGV)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý quy trình Giao việc, Phân công nhân sự và Lập Phiếu giao việc (PGV) nội bộ CCBA.
- Số hóa Step 3 Giao việc (`giao_viec_pgv`) trong Chuỗi 7 bước nghiệp vụ IDOP theo 4 luồng PGV (Điều 7 QCTK 2815).
- Phân tách vai trò Gateway của Phòng Tổng Hợp khi tương tác với bên ngoài hệ thống.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quy trình 4 luồng giao việc (Luồng 1, Luồng 2, Luồng 3, Luồng 4).
  - Phân định thẩm quyền phê duyệt nội bộ của Giám đốc CCBA và phân bổ tài chính.
  - Tích hợp với `JobAssignments`, `AssignmentDetails`, `Activities`.
- **Không bao gồm (Out-of-Scope)**:
  - Nộp tài liệu CDE (module `cde_documents`).
  - Chi trả lương thực tế (module `cash_data/expenses`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
| US-PMO-01 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA | Với tư cách Chủ trì HĐ, tôi muốn tạo Phiếu giao việc (PGV) trên IDOP để phân bổ nhân sự và tài chính | Điều 7 QCTK 2815 |
| US-PMO-02 | `ROLE_HEAD_BIM_PROJECT` — Trưởng phòng BIM Dự án | Với tư cách Trưởng phòng BIM Dự án, tôi muốn kiểm duyệt đề xuất nhân sự trên PGV trên IDOP để đảm bảo năng lực thực thi | Điều 7 QCTK 2815 |
| US-PMO-03 | `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp | Với tư cách Trưởng phòng Tổng Hợp, tôi muốn thẩm tra PGV thuộc luồng HĐ đơn vị ký trên IDOP để đảm bảo đúng quy định nội bộ | Điều 7.1 QCTK 2815 |
| US-PMO-04 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn phê duyệt Phiếu giao việc trên IDOP để ban hành QĐ phân công | Điều 7 QCTK 2815 |
| US-PMO-05 | `ROLE_STAFF` — Cá nhân / Viên chức NLĐ | Với tư cách Viên chức NLĐ, tôi muốn xem PGV của mình trên IDOP để nắm rõ trách nhiệm dự án | Điều 7 QCTK 2815 |
| US-PMO-06 | `ROLE_EXTERNAL_PARTNER` — Cộng tác viên / Đối tác | Với tư cách Cộng tác viên, tôi muốn xem phạm vi công việc được giao trên IDOP để thực hiện HĐ khoán | Điều 7.6 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Phê duyệt PGV |
| `ROLE_DEPUTY_DIRECTOR` | R, A* | Phê duyệt PGV trong khối quản lý |
| `ROLE_HEAD_ADMIN` | R | Xem PGV, Gateway thẩm tra luồng 4 |
| `ROLE_HEAD_BIM_PROJECT` | C*, R, U, A* | Tạo và duyệt PGV khối Dự án |
| `ROLE_PROJECT_MANAGER` | C, R, U | Tạo, cập nhật PGV và phân công |
| `ROLE_STAFF` | R* | Xem PGV cá nhân |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Tham chiếu file 05_ccba_ibst_boundary_map.md (Bước 3).
- **QCTK 2815**: Điều 7 (4 luồng PGV).
- **Quy chế CCBA 2026**: Điều 11 (Phân chia tài chính minh bạch).

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow)
Tham chiếu [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md) Bước 3 (PGV 4 luồng).
1. `ROLE_PROJECT_MANAGER` tạo đề xuất PGV trên IDOP.
2. Trưởng phòng chuyên môn kiểm duyệt nhân sự nội bộ.
3. Đối với HĐ liên ngành, `ROLE_HEAD_ADMIN` làm gateway thống nhất tỷ lệ với đơn vị khác (bên ngoài IDOP).
4. `ROLE_DIRECTOR` phê duyệt PGV trên IDOP, chuyển thành `JobAssignments`.

---

## 5. Acceptance Criteria & List Mapping
### 5.1 Bảng Áp dụng Dữ liệu 1-1
Tích hợp `JobAssignments`, `AssignmentDetails`, `Activities`.

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-PMO-01**: `JobAssignment` phải có `ProjectId` và `EmployeeId`.

---

## 6. Bảo mật, Phân quyền & Audit Trail
### 6.1 Phân quyền Truy cập (SharePoint Groups)
Theo 06_ccba_org_role_matrix.md:
- `CCBA_BanGiamDoc`: Phê duyệt mọi cấp (Full Control).
- `CCBA_PhongBIMDuAn`, `CCBA_TruongPhong_All`: Contribute + Approve (phòng).
- `CCBA_ChuTri_All`: Contribute (phạm vi DA).
- `CCBA_VCNLD_All`: Contribute (hạn chế, nhật ký).
- `CCBA_External_Partners`: Read-only.
