# Đặc Tả Kỹ Thuật Module: CDE Documents (Quản lý Tài liệu Môi trường Dữ liệu Chung CDE)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý chỉ mục tài liệu kỹ thuật, bản vẽ thiết kế, báo cáo kiểm định và hồ sơ dự án theo tiêu chuẩn Môi trường dữ liệu chung CDE (Common Data Environment - ISO 19650) của CCBA.
- Thiết lập Quy trình Quản lý Tài liệu QA/QC 5 tầng (5-Tier CDE Document Workflow): `WIP` (Work in Progress) -> `Shared` (Nội bộ đơn vị) -> `Published` (Bàn giao / Nộp trình) -> `Approved/Accepted` (Nghiệm thu) -> `Archived` (Lưu trữ).
- Quản lý siêu dữ liệu (Metadata), mã tài liệu (`DocumentCode`), phiên bản (`Version`), liên kết tệp (`FileUrl`), hồ sơ nộp (`Submission`) và thời hạn lưu trữ (`RetentionUntil`).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Đặt mã tài liệu chuẩn theo quy ước CDE/PMO (bao gồm mã dự án, bộ môn, loại tài liệu, số hiệu).
  - Quản lý 5 trạng thái container dữ liệu CDE theo ISO 19650:
    1. *WIP (Work In Progress)*: Đang thực hiện bởi tác giả/bộ môn.
    2. *Shared (Nội bộ)*: Đã chia sẻ cho các bộ môn khác phối hợp kiểm tra.
    3. *Published (Bàn giao)*: Đã soát xét và phát hành cho Chủ đầu tư/Bên A.
    4. *Approved / Accepted (Nghiệm thu)*: Đã được Bên A nghiệm thu chấp thuận.
    5. *Archived (Lưu trữ)*: Hồ sơ đóng dự án lưu trữ lâu dài.
  - Phân loại tài liệu theo ManagedMetadata Taxonomy: `CCBA_LoaiTaiLieu`, `CCBA_ChucDanhXayDung` (Chuyên ngành), `CCBA_LoaiHinhDichVu`.
  - Tích hợp 1-to-1 với SharePoint List `CDEDocuments` (`datamodel/sharepoint/lists/process_execution/cde_documents.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Lưu trữ trực tiếp các tệp tin binary bản vẽ dung lượng lớn trong SharePoint List (chỉ lưu URL/Link kết nối tới SharePoint Document Library / OneDrive CDE Storage).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-CDE-01**: Là *Kỹ sư BIM / Thiết kế*, tôi muốn tạo chỉ mục tài liệu mới ở trạng thái `WIP`, đính kèm `FileUrl` tới thư mục làm việc để soát xét nội bộ.
- **US-CDE-02**: Là *Chủ trì Bộ môn*, tôi muốn kiểm tra tài liệu `WIP` và chuyển sang `Shared` để các bộ môn khác (Kết cấu, MEP, Kiến trúc) phối hợp xung đột (Clash Detection).
- **US-CDE-03**: Là *Chủ nhiệm Dự án (PM)*, tôi muốn phê duyệt tài liệu `Shared` để phát hành sang trạng thái `Published` và gắn với Hồ sơ nộp (`Submission`) gửi Chủ đầu tư.
- **US-CDE-04**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi kiểm soát danh mục tài liệu đã được bên A chấp thuận (`Approved`) và chuẩn bị hồ sơ cho Step 5 Kiểm tra nội bộ.
- **US-CDE-05**: Là *Phòng Tổ chức - Hành chính (TCHC Viện)*, tôi tiếp nhận danh mục tài liệu hoàn thành, thiết lập ngày hết hạn lưu trữ (`RetentionUntil`) và chuyển sang `Archived` (Điều 9.8.h QCTK 2815).

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (Lưu trữ/Archived) | - | A (Lưu trữ) | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | - | R (Toàn Viện) | U (Kiểm tra HS) | - | A (Đối soát HS) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Tài liệu CDE) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Phê duyệt CDE) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Dự án giao) | U (Published) | - | A (Phát hành) | E |
| **Trưởng phòng / Chủ trì Bộ môn** | C | R (Phòng) | U (Shared) | - | A (Duyệt Bộ môn) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 3.2.o (Hồ sơ ký trực tiếp & Ký số)*: Quy định hồ sơ kết quả kiểm định, thiết kế bao gồm cả hồ sơ giấy và hồ sơ ký số dưới dạng thông điệp dữ liệu.
  - *Điều 8.4 (Quản lý hồ sơ)*: Các đơn vị có nhiệm vụ quản lý toàn bộ hồ sơ pháp lý, hồ sơ kỹ thuật của các hợp đồng kinh tế.
  - *Điều 9.8.h (Lưu trữ hồ sơ TCHC)*: Đảm bảo việc lưu trữ và khai thác hồ sơ tài liệu theo Quy chế Văn thư Lưu trữ của Viện.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Danh mục tài liệu CDE `Approved` là chứng từ bắt buộc để làm căn cứ quyết toán và giải ngân tài chính.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Bắt buộc áp dụng tiêu chuẩn CDE/ISO 19650 trong quản lý tài liệu dự án BIM trên nền tảng IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình QA/QC 5 Tầng Quản lý Tài liệu CDE

```
[Khởi tạo Tài liệu (WIP)] -> [Duyệt Bộ môn (Shared)] -> [Duyệt PM / Phản hồi Bên A (Published)] -> [Nghiệm thu Chấp thuận (Approved)] -> [Lưu trữ Lâu dài (Archived)]
```

1. **Tầng 1 - Work In Progress (WIP)**:
   - Kỹ sư khởi tạo bản ghi trong list `CDEDocuments`, nhập `Title`, `Project`, `ProjectCode`, `DocumentCode`, `Discipline`, `Version = "v0.1"`, đính kèm `FileUrl`. `Status = "WIP"`.
2. **Tầng 2 - Shared (Phối hợp Nội bộ)**:
   - Sau khi soát xét kỹ thuật, Chủ trì bộ môn duyệt chuyển `Status = "Shared"`, `Version = "v0.9"`. Các bộ môn khác truy cập để phát hiện xung đột (Clash Detection).
3. **Tầng 3 - Published (Phát hành / Bàn giao)**:
   - PM phê duyệt tài liệu và gắn với hồ sơ nộp `Submission`. Chuyển `Status = "Published"`, `Version = "v1.0"`. Gửi bàn giao cho Bên A / Chủ đầu tư.
4. **Tầng 4 - Approved / Accepted (Nghiệm thu)**:
   - Sau khi Bên A có văn bản chấp thuận, PM cập nhật `Status = "Approved"`. Tài liệu được dùng làm căn cứ nghiệm thu khối lượng hoàn thành (Step 6).
5. **Tầng 5 - Archived (Lưu trữ)**:
   - Kết thúc dự án, Phòng TCHC thiết lập `RetentionUntil` (ngày hết hạn lưu trữ theo quy định pháp luật) và chuyển `Status = "Archived"`.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List: `CDEDocuments` (`datamodel/sharepoint/lists/process_execution/cde_documents.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `Title` | Text | Yes | - | Tiêu đề tài liệu |
| `Project` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án |
| `ProjectCode` | Text | No | - | Mã dự án để hỗ trợ tra cứu nhanh & RLS |
| `DocumentCode` | Text | No | - | Mã tài liệu theo quy ước CDE/PMO |
| `DocumentType` | ManagedMetadata | No | `CCBA_LoaiTaiLieu` | Phân loại tài liệu (Bản vẽ, Thuyết minh, Báo cáo, Biên bản) |
| `Discipline` | ManagedMetadata | No | `CCBA_ChucDanhXayDung` | Chuyên ngành (Kiến trúc, Kết cấu, MEP, PCCC, Khảo sát) |
| `ServiceType` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Loại hình dịch vụ |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái CDE: WIP, Shared, Published, Approved, Archived |
| `Version` | Text | No | - | Số phiên bản tài liệu (v0.1, v1.0, v2.0 và các phiên bản tiếp theo) |
| `FileUrl` | Hyperlink | No | - | Đường dẫn kết nối tới tệp/thư mục trong CDE Storage |
| `Submission` | Lookup | No | List: `Submissions`, Field: `ID` | Liên kết đến Hồ sơ nộp |
| `RetentionUntil` | DateTime | No | - | Ngày hết hạn lưu trữ theo chính sách lưu trữ |
| `Owner` | User | No | - | Người phụ trách / Tác giả tài liệu |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-CDE-01**: `Title` bắt buộc nhập. Trường `FileUrl` bắt buộc chứa liên kết URL hợp lệ chỉ tới SharePoint/OneDrive.
- **AC-CDE-02**: Mã tài liệu `DocumentCode` phải tuân thủ đúng định dạng cấu trúc: `[ProjectCode]-[Discipline]-[DocumentType]-[Index]`.
- **AC-CDE-03**: Chỉ có PM mới có quyền chuyển `Status` từ `Shared` sang `Published`.
- **AC-CDE-04**: Tất cả các trường ManagedMetadata (`DocumentType`, `Discipline`, `ServiceType`, `Status`) phải liên kết 100% với TermStore `CCBA Taxonomy`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Ban Giám đốc Viện / CCBA**: Xem toàn bộ tài liệu CDE của tất cả các dự án.
- **Trưởng phòng / Chủ trì Bộ môn**: Duyệt tài liệu `WIP` sang `Shared` đối với chuyên ngành phụ trách.
- **Chủ nhiệm Dự án (PM)**: Toàn quyền quản lý tài liệu CDE thuộc dự án; Duyệt chuyển sang `Published` và `Approved`.
- **Tác giả / Kỹ sư (Owner)**: Tạo và chỉnh sửa các tài liệu ở trạng thái `WIP` do mình tạo ra.
- **Phòng TCHC Viện**: Xem và cập nhật trạng thái `Archived` và ngày `RetentionUntil`.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo chỉ mục tài liệu |
| `Author` | User | Người tạo tài liệu |
| `Modified` | DateTime | Thời gian cập nhật phiên bản / trạng thái mới nhất |
| `Editor` | User | Người cập nhật cuối cùng |
| `SystemVersion` | Integer | Lịch sử các phiên bản sửa đổi dữ liệu tài liệu |
