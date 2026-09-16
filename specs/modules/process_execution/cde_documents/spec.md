# Đặc Tả Kỹ Thuật Module: CDE Documents (Quản lý Tài liệu Môi trường Dữ liệu Chung CDE)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
- Quản lý tài liệu theo tiêu chuẩn CDE (ISO 19650) trên IDOP.
- Áp dụng Workflow 5 tầng CDE để QA/QC tài liệu thiết kế nội bộ CCBA.

### 1.2 Phạm vi
- **Bao gồm**: 5 trạng thái (WIP, Shared, Published, Approved, Archived), Taxonomy dữ liệu.
- **Không bao gồm**: Lưu trữ file binary trực tiếp trên list (chỉ lưu URL).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
| US-CDE-01 | `ROLE_STAFF` — Cá nhân / Viên chức NLĐ | Với tư cách Kỹ sư, tôi muốn tải tài liệu WIP lên CDE trên IDOP để trưởng phòng kiểm tra | ISO 19650 |
| US-CDE-02 | `ROLE_HEAD_BIM_DESIGN` — Trưởng phòng BIM Thiết kế | Với tư cách Trưởng phòng BIM Thiết kế, tôi muốn review tài liệu (Design QA) trên IDOP để chuyển trạng thái sang Shared | Điều 10 QCTK 2815 |
| US-CDE-03 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA | Với tư cách Chủ nhiệm DA, tôi muốn tập hợp tài liệu Published trên IDOP để nộp Chủ đầu tư | ISO 19650 |
| US-CDE-04 | `ROLE_LEGAL_QA` — Cố vấn Pháp lý, TC & QLCL | Với tư cách QA/QC, tôi muốn Approve tài liệu trên IDOP để xác nhận đạt chuẩn hệ thống (Cấp cao nhất QA) | Điều 10 QCTK 2815 |
| US-CDE-05 | `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp | Với tư cách Trưởng phòng Tổng Hợp, tôi muốn tiếp nhận tài liệu Archived trên IDOP để lưu trữ hồ sơ theo quy định | Điều 9.8.h QCTK 2815 |
| US-CDE-06 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc, tôi muốn xem các tài liệu Approved trên IDOP để nắm chất lượng cuối cùng | Điều 8 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R | Xem tài liệu toàn trung tâm |
| `ROLE_LEGAL_QA` | R, A | QA/QC cấp cao nhất (Approve) |
| `ROLE_HEAD_BIM_DESIGN` | C*, R, U* | Design QA (Cấp phòng) |
| `ROLE_HEAD_BIM_PROJECT` | C*, R, U* | PMO QA (Cấp phòng) |
| `ROLE_PROJECT_MANAGER` | C, R, U | Publish tài liệu |
| `ROLE_STAFF` | C*, R* | Upload bản nháp WIP |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Tham chiếu 05_ccba_ibst_boundary_map.md (Bước 5: Kiểm tra QA/QC 5 cấp).
- **QCTK 2815**: Điều 10 (Kiểm tra Nội bộ).

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow)
Tham chiếu [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md) Bước 5 (Kiểm tra QA/QC).
1. `ROLE_STAFF` upload WIP.
2. `ROLE_HEAD_BIM_DESIGN` duyệt chuyển sang Shared (Design QA).
3. `ROLE_PROJECT_MANAGER` duyệt sang Published.
4. `ROLE_LEGAL_QA` thực hiện Approve cấp cao nhất.
5. Cập nhật trạng thái đối ngoại nếu cần qua `ROLE_HEAD_ADMIN`.

---

## 5. Acceptance Criteria & List Mapping
Tích hợp `CDEDocuments`.

---

## 6. Bảo mật, Phân quyền & Audit Trail
### 6.1 Phân quyền Truy cập (SharePoint Groups)
- `CCBA_Legal_QA`: Contribute + Approve (QA/QC).
- `CCBA_PhongBIMThietKe`, `CCBA_TruongPhong_All`: Contribute + Approve (phòng).
- `CCBA_ChuTri_All`: Contribute.
- `CCBA_VCNLD_All`: Contribute.
