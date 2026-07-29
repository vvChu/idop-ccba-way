# Đặc Tả Kỹ Thuật Module: Lessons Learned (Quản lý Bài học Kinh nghiệm & Kiểm tra Nội bộ)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
- Ghi nhận tri thức Bài học kinh nghiệm (Lessons Learned) nội bộ CCBA.
- Số hóa công tác ghi nhận kết quả Kiểm tra nội bộ (Điều 10 QCTK 2815).

### 1.2 Phạm vi
- Ghi nhận bài học kinh nghiệm về kỹ thuật, pháp lý, tiến độ, an toàn.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
| US-LL-01 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA | Với tư cách Chủ trì HĐ, tôi muốn ghi nhận bài học kinh nghiệm từ dự án trên IDOP để chia sẻ tri thức | Điều 10 QCTK 2815 |
| US-LL-02 | `ROLE_LEGAL_QA` — Cố vấn Pháp lý, TC & QLCL | Với tư cách Cố vấn QA, tôi muốn tạo bản ghi Lessons Learned sau khi audit trên IDOP để phòng ngừa rủi ro | Điều 10 QCTK 2815 |
| US-LL-03 | `ROLE_HEAD_BIM_DESIGN` — Trưởng phòng BIM Thiết kế | Với tư cách Trưởng phòng BIM Thiết kế, tôi muốn duyệt các bài học thiết kế của phòng trên IDOP trước khi công khai | Điều 10 QCTK 2815 |
| US-LL-04 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc, tôi muốn tra cứu kho tri thức Lessons Learned trên IDOP để ra quyết định quản trị | Quy chế CCBA |
| US-LL-05 | `ROLE_STAFF` — Cá nhân / Viên chức NLĐ | Với tư cách Viên chức NLĐ, tôi muốn xem các Lessons Learned trên IDOP để học hỏi kinh nghiệm | Quy chế CCBA |
| US-LL-06 | `ROLE_HEAD_BIM_PROJECT` — Trưởng phòng BIM Dự án | Với tư cách Trưởng phòng BIM Dự án, tôi muốn ghi nhận bài học quản lý hiện trường trên IDOP để đào tạo PMO | Điều 10 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R | Xem tất cả bài học |
| `ROLE_DEPUTY_DIRECTOR` | R | Xem tất cả bài học |
| `ROLE_LEGAL_QA` | R | Đọc bài học QA |
| `ROLE_HEAD_BIM_DESIGN` | C*, R | Ghi nhận và duyệt bài học phòng Thiết kế |
| `ROLE_HEAD_BIM_PROJECT` | C*, R | Ghi nhận và duyệt bài học phòng Dự án |
| `ROLE_PROJECT_MANAGER` | C, R, U | Ghi nhận bài học từ dự án |
| `ROLE_STAFF` | C*, R | Tra cứu tri thức, đóng góp bài học |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- **QCTK 2815**: Điều 10 (Kiểm tra Nội bộ - Step 5 Operational Flow).
- **Quy chế CCBA 2026**: Văn hóa chia sẻ tri thức.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow)
1. Phát hiện bài học hoặc qua Kiểm tra nội bộ.
2. `ROLE_PROJECT_MANAGER` hoặc `ROLE_LEGAL_QA` khởi tạo bản ghi.
3. Trưởng phòng chuyên môn phê duyệt.
4. Công khai trên kho tri thức IDOP để toàn thể `ROLE_STAFF` tra cứu.

---

## 5. Acceptance Criteria & List Mapping
Tích hợp `LessonsLearned`.

---

## 6. Bảo mật, Phân quyền & Audit Trail
### 6.1 Phân quyền Truy cập (SharePoint Groups)
- `CCBA_BanGiamDoc`: Xem toàn bộ.
- `CCBA_PhongBIMThietKe`, `CCBA_PhongBIMDuAn`: Contribute + Approve (phòng).
- `CCBA_ChuTri_All`: Contribute.
- `CCBA_VCNLD_All`: Contribute (Tạo bài học, đọc chung).
