# Đặc Tả Kỹ Thuật Module: Work Packages (Quản lý Gói Công việc & Cấu trúc Phân chia WBS)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý cấu trúc phân chia công việc (Work Breakdown Structure - WBS) thành các gói công việc cụ thể (Work Packages) thuộc từng dự án của CCBA.
- Phân công gói công việc cho cá nhân/bộ môn chịu trách nhiệm, theo dõi tiến độ bắt đầu/kết thúc và trạng thái thực hiện.
- Đảm bảo tính liên thông dữ liệu giữa Gói công việc với Dự án (`Projects`), Phiếu giao việc (`JobAssignments`) và Hồ sơ tài liệu (`CDEDocuments`).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Khởi tạo và phân chia gói công việc thuộc Dự án theo các chuyên ngành (BIM Architecture, Structure, MEP, QA/QC, Thử nghiệm, Kiểm định).
  - Phân công gói công việc cho cán bộ phụ trách (`AssignedTo`).
  - Quản lý tiến độ thời gian thực hiện (`StartDate`, `EndDate`) và trạng thái (`Status`).
  - Tích hợp 1-to-1 với SharePoint List `WorkPackages` (`datamodel/sharepoint/lists/process_execution/work_packages.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Phân công nhỏ đến từng task giờ lẻ hàng ngày (được ghi nhận ở Timesheet / AssignmentDetails).
  - Nghiệm thu tài chính gói công việc (thực hiện ở module `cash_data/finance`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-WP-01**: Là *Chủ nhiệm Dự án (PM CCBA)*, tôi muốn chia dự án thành các Gói công việc (Work Packages) và gán thời gian thực hiện để kiểm soát tiến độ tổng thể.
- **US-WP-02**: Là *Trưởng phòng Chuyên môn / Chủ trì Bộ môn*, tôi muốn nhận Gói công việc và phân công cho kỹ sư thuộc bộ môn mình đảm nhận (`AssignedTo`).
- **US-WP-03**: Là *Kỹ sư thực hiện*, tôi muốn xem danh sách các Gói công việc được giao, cập nhật trạng thái thực hiện và đính kèm sản phẩm bàn giao CDE.
- **US-WP-04**: Là *Phòng Kế hoạch - Kỹ thuật (KHKT Viện)*, tôi xem báo cáo tổng hợp tiến độ hoàn thành các Gói công việc của các đơn vị.
- **US-WP-05**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi truy xuất dashboard theo dõi tỷ lệ hoàn thành các Gói công việc trên toàn bộ dự án.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R | - | - | - | R |
| **Phòng Kế hoạch - Tài chính (KHKT/TCKT Viện)** | - | R (Toàn Viện) | U (Kiểm tra WBS) | - | - | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Phân công) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Phê duyệt WBS) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Dự án giao) | U (Tạo/Cập nhật WP) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Gán nhân sự) | - | A (Duyệt WP) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 3.2.c (Chủ trì bộ môn & chuyên ngành)*: Phân định nhiệm vụ cho người chịu trách nhiệm chính về một lĩnh vực chuyên môn trong dự án (kết cấu, kiến trúc, điện, nước, PCCC và các chuyên ngành kỹ thuật khác).
  - *Điều 8.1*: Quản lý khối lượng và tiến độ thực hiện công việc phù hợp với Phiếu giao việc và hợp đồng đã ký.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Căn cứ khối lượng gói công việc hoàn thành để nghiệm thu giai đoạn và thanh toán tiền công cho nhân sự.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Chuẩn hóa quy trình giao việc theo gói WBS để đo lường hiệu suất công việc trên IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Quản lý Gói Công việc (Work Packages)

```
[Khởi tạo Dự án] -> [PM Phân chia Cấu trúc WBS WorkPackages] -> [TPM Gán Cán bộ Phụ trách (AssignedTo)] -> [Triển khai & Cập nhật Trạng thái] -> [Nghiệm thu Gói Công việc]
```

1. **Bước 1: Khởi tạo WBS**:
   - PM tạo các bản ghi `WorkPackages` cho dự án trong list `WorkPackages`.
   - Nhập `PackageName`, chọn `ProjectId` Lookup, thiết lập `StartDate` và `EndDate`.
2. **Bước 2: Phân công Cán bộ Phụ trách**:
   - TPM/Chủ trì bộ môn chỉ định cán bộ thực hiện vào trường `AssignedTo`.
3. **Bước 3: Thực hiện & Cập nhật Tiến độ**:
   - Cán bộ thực hiện cập nhật `Status` từ `Mới` -> `Đang thực hiện` -> `Hoàn thành` (sử dụng ManagedMetadata `CCBA_TrangThaiChung`).
4. **Bước 4: Nghiệm thu Gói Công việc**:
   - PM và TPM kiểm tra sản phẩm CDE gắn liền với gói công việc trước khi chuyển trạng thái `Hoàn thành`.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List: `WorkPackages` (`datamodel/sharepoint/lists/process_execution/work_packages.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `PackageName` | Text | Yes | - | Tên gói công việc (ví dụ: WP01-Mô hình hóa Kết cấu) |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết bắt buộc tới Dự án cha |
| `AssignedTo` | User | No | - | Nhân sự / Kỹ sư được phân công phụ trách gói công việc |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái: Mới, Đang thực hiện, Đang kiểm tra, Hoàn thành |
| `StartDate` | DateTime | No | - | Ngày bắt đầu gói công việc |
| `EndDate` | DateTime | No | - | Ngày kết thúc gói công việc |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-WP-01**: `PackageName` bắt buộc nhập. Trường `ProjectId` bắt buộc liên kết chính xác với 01 `Project` tồn tại.
- **AC-WP-02**: `EndDate` không được trước `StartDate`. Hệ thống báo lỗi nếu khoảng thời gian không hợp lệ.
- **AC-WP-03**: Trường `Status` phải thuộc Taxonomy Group `CCBA_TrangThaiChung`.
- **AC-WP-04**: Tự động chuyển `Projects.Status` sang `Đang thực hiện` khi gói công việc đầu tiên chuyển trạng thái `Đang thực hiện`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Ban Giám đốc Viện / CCBA**: Xem toàn bộ WBS và Gói công việc của tất cả các dự án.
- **Trưởng phòng Chuyên môn (TPM)**: Xem và phân công cán bộ (`AssignedTo`) cho các gói công việc thuộc phòng.
- **Chủ nhiệm Dự án (PM)**: Toàn quyền Tạo, Sửa, Xóa các Gói công việc thuộc dự án do mình làm PM.
- **Nhân sự được phân công (AssignedTo)**: Xem và cập nhật trạng thái `Status` của gói công việc do mình phụ trách.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày tạo gói công việc |
| `Author` | User | Người tạo gói công việc |
| `Modified` | DateTime | Thời gian cập nhật gói công việc mới nhất |
| `Editor` | User | Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Phiên bản lịch sử dữ liệu gói công việc |
