# Đặc Tả Kỹ Thuật Module: Potential Projects (Quản lý Tiềm năng Dự án)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý danh mục Tiềm năng dự án (Potential Projects) được hình thành từ CRM, làm cầu nối tiền đề giữa giai đoạn phát triển thị trường/đấu thầu và giai đoạn thực thi dự án chính thức (`Projects`) sau khi ký Hợp đồng Kinh tế (`Contracts`).
- Tích hợp chặt chẽ việc truy xuất dữ liệu thông qua liên kết `OpportunityId` Lookup đến `Opportunities`.
- Giúp Ban Giám đốc và các Phòng Chuyên môn lập kế hoạch nhân sự, chuẩn bị năng lực kỹ thuật và ước tính khối lượng sản lượng công việc trong tương lai.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quản lý pipeline Tiềm năng dự án qua các giai đoạn: `Identified`, `Qualified`, `On Hold`, `Converted`, `Dropped`.
  - Liên kết 1-1 hoặc 1-nhiều với Cơ hội kinh doanh (`Opportunities`) qua trường `OpportunityId`.
  - Theo dõi giá trị hợp đồng dự kiến (`ExpectedContractValue`), loại hình dịch vụ (`ServiceType`), loại công trình (`ProjectType`), mức độ ưu tiên (`Priority`) và thời gian dự kiến bắt đầu/hoàn thành.
  - Chuyển đổi tự động từ `PotentialProjects` sang `Projects` khi Hợp đồng chính thức được ký kết.
- **Không bao gồm (Out-of-Scope)**:
  - Phân công công việc chi tiết cho kỹ sư (thực hiện ở module `process_execution/pmo` qua Phiếu giao việc).
  - Quản lý tiến độ thanh toán tài chính (thực hiện ở module `cash_data`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-PP-01**: Là *Chuyên viên Kinh doanh CCBA*, tôi muốn tạo bản ghi Tiềm năng dự án từ Cơ hội kinh doanh đã thắng thầu (`OpportunityId`) để chuẩn bị hồ sơ chuyển tiếp cho bộ phận thực thi.
- **US-PP-02**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi muốn xem danh sách Tiềm năng dự án để đánh giá nguồn lực nhân sự hiện có và chuẩn bị các tiêu chuẩn/quy chuẩn kỹ thuật tương ứng.
- **US-PP-03**: Là *Chủ nhiệm Dự án (PM)*, tôi muốn xem lịch sử và các thông tin thỏa thuận sơ bộ trong Tiềm năng dự án để lập đề xuất Phiếu giao việc (PGV).
- **US-PP-04**: Là *Phòng Kế hoạch - Kỹ thuật (KHKT Viện)*, tôi đối soát danh mục Tiềm năng dự án với kế hoạch sản lượng năm của CCBA.
- **US-PP-05**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi truy xuất báo cáo dự báo sản lượng (`Pipeline Revenue Forecast`) dựa trên giá trị dự kiến của các Tiềm năng dự án.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R | - | - | - | R |
| **Phòng Kế hoạch - Tài chính (KHKT/TCKT Viện)** | R | R (Toàn Viện) | U (Kế hoạch sản lượng) | - | - | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Chuẩn bị kỹ thuật) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Phê duyệt kế hoạch) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Dự án giao) | U | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Phân bổ nguồn lực) | - | A (Đồng ý chuyển đổi) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 5.2 (Xây dựng hợp đồng & Chuẩn bị triển khai)*: Tiềm năng dự án là cơ sở để chuẩn bị nội dung dự thảo Hợp đồng kinh tế và Phiếu giao việc.
  - *Điều 7.3 (Đơn vị chủ trì và phối hợp)*: Căn cứ thông tin Tiềm năng dự án để xác định đơn vị chủ trì và các đơn vị phối hợp trong Viện.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Dự báo doanh thu và kế hoạch phân bổ chi phí chuẩn bị sản xuất dựa trên giá trị HĐ dự kiến của Tiềm năng dự án.
- **Quy chế CCBA 2026**:
  - *Điều 3 (Quản trị theo mục tiêu & OKRs)*: Tiềm năng dự án là chỉ số đo lường đầu vào cho các kết quả then chốt về sản lượng của các Phòng Chuyên môn.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Quản lý & Chuyển đổi Tiềm năng Dự án

```
[Tạo Potential Project từ OpportunityId] -> [Thẩm định & Phân loại Giai đoạn] -> [Lập Kế hoạch Nguồn lực] -> [Ký Hợp đồng Kinh tế] -> [Tự động Chuyển đổi sang Projects]
```

1. **Bước 1: Khởi tạo từ Cơ hội CRM**:
   - Sau khi `Opportunity` đạt trạng thái `Closed - Won`, hệ thống tự động khởi tạo 01 bản ghi trong `PotentialProjects`.
   - Trường `OpportunityId` được gán chính xác `ID` của Cơ hội tương ứng.
   - Sao chép các thông tin `Customer`, `Contact`, `ExpectedContractValue`, `ServiceType`, `Industry` từ Cơ hội.
2. **Bước 2: Phân loại Giai đoạn & Mức độ Ưu tiên**:
   - Cán bộ/PM cập nhật `Stage = "Identified"` -> `"Qualified"`.
   - Chọn `ProjectType` (Công trình dân dụng, công nghiệp, hạ tầng và các loại công trình khác) và `Priority` theo chuẩn Taxonomy.
3. **Bước 3: Lập Kế hoạch Chuẩn bị Nguồn lực**:
   - TPM và PM rà soát tiến độ dự kiến (`EstimatedStart`, `EstimatedEnd`) để đăng ký nhân sự và thiết bị với Trung tâm/Viện.
4. **Bước 4: Chuyển đổi thành Dự án Thực thi (`Projects`)**:
   - Khi Hợp đồng Kinh tế chính thức được ký kết (Step 2 Hợp đồng trong 7 bước IDOP), người dùng bấm "Chuyển đổi sang Dự án".
   - Hệ thống khởi tạo bản ghi trong list `Projects` với `ContractId` và `ProjectCode` chính thức.
   - Cập nhật `Stage = "Converted"` trên `PotentialProjects`.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List: `PotentialProjects` (`datamodel/sharepoint/lists/strategy_crm/potential_projects.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `Title` | Text | Yes | - | Tiêu đề/Tên dự án tiềm năng |
| `OpportunityId` | Lookup | No | List: `Opportunities`, Field: `ID` | Liên kết bắt buộc tới Cơ hội CRM tương ứng |
| `Customer` | Lookup | No | List: `Customers`, Field: `ID` | Khách hàng chủ đầu tư/đối tác |
| `Contact` | Lookup | No | List: `Contacts`, Field: `ID` | Liên hệ đại diện |
| `ExpectedContractValue` | Number | No | - | Giá trị hợp đồng dự kiến (VND) |
| `ServiceType` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Loại hình dịch vụ kỹ thuật |
| `Industry` | ManagedMetadata | No | `CCBA_NganhLinhVuc` | Ngành/Lĩnh vực xây dựng |
| `ProjectType` | ManagedMetadata | No | `CCBA_LoaiCongTrinh` | Phân cấp/Loại công trình |
| `Priority` | ManagedMetadata | No | `CCBA_MucDoUuTien` | Mức độ ưu tiên |
| `Stage` | Choice | No | `Identified`, `Qualified`, `On Hold`, `Converted`, `Dropped` | Giai đoạn tiềm năng |
| `EstimatedStart` | DateTime | No | - | Ngày bắt đầu dự kiến |
| `EstimatedEnd` | DateTime | No | - | Ngày kết thúc dự kiến |
| `PMOOwner` | User | No | - | Quản trị PMO phụ trách tiềm năng |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-PP-01**: Mọi bản ghi `PotentialProjects` khởi tạo từ CRM phải chứa thông tin `OpportunityId` Lookup hợp lệ chỉ tới 01 `Opportunity`.
- **AC-PP-02**: Không được phép chuyển `Stage = "Converted"` nếu chưa có Hợp đồng chính thức tương ứng trong list `Contracts`.
- **AC-PP-03**: Mọi taxonomy (`ServiceType`, `Industry`, `ProjectType`, `Priority`) phải liên kết chính xác với `CCBA Taxonomy`.
- **AC-PP-04**: Tự động chặn trùng lặp Tiềm năng dự án được tạo từ cùng 01 `OpportunityId`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Ban Giám đốc Viện / CCBA**: Xem toàn bộ Tiềm năng dự án; Duyệt kế hoạch doanh thu dự báo.
- **Trưởng phòng Chuyên môn (TPM)**: Xem và cập nhật dữ liệu các Tiềm năng dự án do phòng mình đảm nhận.
- **Chủ nhiệm Dự án (PM)**: Xem và cập nhật tiến độ dự kiến, ghi chú của Tiềm năng dự án được giao.
- **Phòng KHKT Viện**: Xem toàn bộ để tổng hợp báo cáo sản lượng dự kiến toàn Viện.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo bản ghi tiềm năng |
| `Author` | User | Người tạo bản ghi |
| `Modified` | DateTime | Thời gian cập nhật thông tin cuối cùng |
| `Editor` | User | Người cập nhật cuối cùng |
| `SystemVersion` | Integer | Số phiên bản thay đổi dữ liệu |
