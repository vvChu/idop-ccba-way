# Đặc Tả Kỹ Thuật Module: Lessons Learned (Quản lý Bài học Kinh nghiệm & Kiểm tra Nội bộ)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Ghi nhận, tổng hợp và khai thác tri thức Bài học kinh nghiệm (Lessons Learned) rút ra từ quá trình thực thi dự án và công tác Kiểm tra nội bộ của CCBA và Viện KHCN Xây dựng.
- Số hóa 100% Step 5 Kiểm tra nội bộ (`kiem_tra_noi_bo`) trong Chuỗi 7 bước nghiệp vụ IDOP theo đúng quy định tại Điều 10 QCTK 2815.
- Phòng ngừa tái diễn sai sót kỹ thuật, rủi ro pháp lý/tài chính, đồng thời nhân rộng các giải pháp cải tiến chất lượng sản phẩm tư vấn - dịch vụ kỹ thuật.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quy trình Kiểm tra nội bộ định kỳ/đột xuất theo Điều 10 QCTK 2815.
  - Ghi nhận thông tin Bài học kinh nghiệm: tiêu đề (`LessonTitle`), mô tả chi tiết (`Description`), phân loại (`Category`), liên kết dự án (`ProjectId`).
  - Phân loại bài học theo ManagedMetadata Taxonomy `CCBA_PhanLoaiBaiHoc` (Kỹ thuật, Pháp lý hợp đồng, Quản lý tiến độ, An toàn lao động, Tài chính - Thuế).
  - Tích hợp 1-to-1 với SharePoint List `LessonsLearned` (`datamodel/sharepoint/lists/process_execution/lessons_learned.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Xử lý kỷ luật cán bộ vi phạm (thực hiện theo Hội đồng Kỷ luật Viện quy định tại Điều 14 QCTK 2815).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-LL-01**: Là *Chủ nhiệm Dự án (PM CCBA)*, tôi muốn ghi nhận các bài học kinh nghiệm về xử lý vướng mắc kỹ thuật hiện trường để đồng nghiệp tham khảo cho các dự án sau.
- **US-LL-02**: Là *Đoàn Kiểm tra Nội bộ Viện (KHKT, TCKT, TCHC)*, tôi muốn lập bản ghi bài học kinh nghiệm sau khi phát hiện sai sót trong đợt kiểm tra định kỳ theo Điều 10 QCTK 2815.
- **US-LL-03**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi muốn duyệt các bài học kinh nghiệm của phòng mình trước khi công khai lên kho tri thức chung của Trung tâm.
- **US-PM-04**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi muốn tra cứu kho tri thức Lessons Learned để chỉ đạo các giải pháp phòng ngừa rủi ro cho các gói thầu lớn.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | C | R (Toàn Viện) | U (Kiểm tra TCHC) | - | A (Biên bản KT) | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | C | R (Toàn Viện) | U (Kiểm tra KHKT) | - | A (Biên bản KT) | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | C | R (Toàn Viện) | U (Kiểm tra TCKT) | - | A (Biên bản KT) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | C | R | U (Đào tạo) | - | - | E |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Bài học) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Phê duyệt Tri thức) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Dự án giao) | U | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Sửa bài học) | - | A (Duyệt Bài học) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 10 (Kiểm tra Nội bộ - Step 5 Operational Flow)*:
    - *Khoản 1*: Đơn vị trực thuộc Viện phải thực hiện kiểm tra, kiểm soát việc thực hiện HĐKT do đơn vị phân cấp/ủy quyền ký.
    - *Khoản 2*: Viện tiến hành kiểm tra định kỳ tại các đơn vị theo kế hoạch hàng năm hoặc đột xuất. Thành phần: Lãnh đạo Viện phụ trách, đại diện TCKT, KHKT, TCHC và chuyên gia. Nội dung: Pháp lý, hồ sơ thực hiện, sản phẩm, khối lượng, tiến độ, kinh phí và chứng từ.
    - *Khoản 3*: Kết quả kiểm tra lập biên bản, báo cáo Viện trưởng và thông báo các tập thể/cá nhân liên quan.
    - *Khoản 4*: Kiến nghị, kết luận kiểm tra phải được thực hiện nghiêm túc.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Rút kinh nghiệm về lập chứng từ tài chính, hóa đơn và dự toán chi phí.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Xây dựng văn hóa học tập liên tục và chia sẻ tri thức số trên hạ tầng IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Step 5 Kiểm tra Nội bộ & Ghi nhận Lessons Learned

```
[Thực hiện Kiểm tra Nội bộ (Điều 10 QCTK)] -> [Lập Biên bản Kiểm tra] -> [Nhận diện Bài học / Cải tiến] -> [Nhập bản ghi Lessons Learned] -> [TPM/BGD Phê duyệt] -> [Công khai Kho Tri thức IDOP]
```

1. **Thực hiện Kiểm tra Nội bộ (Step 5.1)**:
   - Thành phần đoàn kiểm tra (Lãnh đạo Viện, KHKT, TCKT, TCHC) tiến hành kiểm tra hồ sơ dự án theo kế hoạch.
2. **Lập Biên bản & Phát hiện (Step 5.2)**:
   - Lập biên bản kết quả kiểm tra. Xác định các sai sót cần khắc phục và các bài học cải tiến.
3. **Khởi tạo bản ghi Lessons Learned (Step 5.3)**:
   - PM/Thành viên đoàn kiểm tra tạo bản ghi mới trong list `LessonsLearned`.
   - Nhập `LessonTitle`, `Description`, chọn `ProjectId` Lookup, và phân loại `Category` (`CCBA_PhanLoaiBaiHoc`).
4. **Phê duyệt & Lưu kho Tri thức (Step 5.4)**:
   - TPM và BGD kiểm duyệt nội dung.
   - Bản ghi được công khai trên kho tri thức IDOP để toàn thể VCNLĐ truy cập tra cứu.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List: `LessonsLearned` (`datamodel/sharepoint/lists/process_execution/lessons_learned.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án xuất hiện bài học kinh nghiệm |
| `LessonTitle` | Text | Yes | - | Tiêu đề bài học kinh nghiệm (bắt buộc) |
| `Description` | Text | No | - | Mô tả chi tiết bối cảnh, sai sót, giải pháp khắc phục và khuyến nghị |
| `Category` | ManagedMetadata | No | `CCBA_PhanLoaiBaiHoc` | Phân loại: Kỹ thuật, Hợp đồng, Tiến độ, An toàn, Tài chính |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-LL-01**: `LessonTitle` bắt buộc nhập, không được để trống.
- **AC-LL-02**: Trường `Category` bắt buộc thuộc nhóm Taxonomy `CCBA_PhanLoaiBaiHoc`.
- **AC-LL-03**: Khi bản ghi `LessonsLearned` được phê duyệt, hệ thống hỗ trợ tính năng tìm kiếm full-text theo từ khóa `Description` trên giao diện IDOP.
- **AC-LL-04**: Trường `ProjectId` liên kết với 01 bản ghi hợp lệ trong `Projects`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Lãnh đạo Viện / Ban Giám đốc CCBA**: Xem toàn bộ Bài học kinh nghiệm; Phê duyệt công khai tri thức.
- **Đoàn Kiểm tra Nội bộ (KHKT, TCKT, TCHC)**: Tạo và chỉnh sửa các bài học kinh nghiệm từ đợt kiểm tra.
- **Trưởng phòng / PM CCBA**: Tạo bài học kinh nghiệm của dự án do mình quản lý.
- **Toàn thể VCNLĐ**: Quyền Xem (Read-only) đối với các Bài học kinh nghiệm đã phê duyệt.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo bài học kinh nghiệm |
| `Author` | User | Người đóng góp bài học |
| `Modified` | DateTime | Thời gian chỉnh sửa nội dung mới nhất |
| `Editor` | User | Người cập nhật cuối cùng |
| `SystemVersion` | Integer | Phiên bản dữ liệu tri thức |
