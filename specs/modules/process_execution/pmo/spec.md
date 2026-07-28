# Đặc Tả Kỹ Thuật Module: PMO (Quản lý Phân công Công việc & Phiếu Giao việc PGV)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý quy trình Giao việc, Phân công nhân sự và Lập Phiếu giao việc (PGV) cho các dự án/hợp đồng kỹ thuật của CCBA và Viện KHCN Xây dựng.
- Số hóa 100% Step 3 Giao việc (`giao_viec_pgv`) trong Chuỗi 7 bước nghiệp vụ IDOP theo đúng quy định tại Điều 7 QCTK 2815 với 4 luồng phê duyệt PGV riêng biệt.
- Quản lý chi tiết nhiệm vụ nhân sự (`JobAssignments`), nhật ký khối lượng giờ làm (`AssignmentDetails`) và các hoạt động vận hành chung (`Activities`).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quy trình 4 luồng giao việc (Điều 7.1 QCTK 2815):
    - *Luồng 1*: HĐ do Viện ký thông thường.
    - *Luồng 2*: HĐ thực hiện theo quy chế Quản lý tập trung.
    - *Luồng 3*: HĐ có kỹ thuật phức tạp, chính trị, Bộ giao.
    - *Luồng 4*: HĐ do Đơn vị phân cấp ký.
  - Phân định thẩm quyền và điều kiện của các chức danh (Điều 7.4-7.6 QCTK 2815): Người chỉ đạo HĐ, Đơn vị chủ trì/phối hợp, Chủ trì HĐ, Chủ trì kỹ thuật (Chủ nhiệm dự án, Giám sát trưởng, Chỉ huy trưởng, Chủ trì bộ môn), và Cộng tác viên (CTV).
  - Xác định tỷ lệ phân chia giá trị giao việc giữa các đơn vị/cá nhân theo Bảng 1 QCTK 2815.
  - Tích hợp 1-to-1 với 3 SharePoint Lists: `JobAssignments`, `AssignmentDetails`, `Activities`.
- **Không bao gồm (Out-of-Scope)**:
  - Quản lý chi tiết hồ sơ nộp CDE (thực hiện ở module `cde_documents`).
  - Thanh toán chi chi tiết lương/tiền công thực tế (thực hiện ở module `cash_data/expenses`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-PMO-01**: Là *Chủ trì Hợp đồng / PM*, tôi muốn soạn Phiếu đề nghị giao việc và Quyết định giao việc trên IDOP để phân công nhân sự và xác định tỷ lệ giao khoán thực hiện Hợp đồng.
- **US-PMO-02**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi muốn xác nhận danh sách cán bộ kỹ thuật, chủ trì bộ môn và cộng tác viên tham gia thực hiện dự án.
- **US-PMO-03**: Là *Phòng Kế hoạch - Kỹ thuật (KHKT Viện)*, tôi muốn thẩm tra tính hợp lệ của PGV (đối với HĐ Viện ký) và soạn thảo QĐ giao việc đối với các HĐ phức tạp/Bộ giao.
- **US-PMO-04**: Là *Lãnh đạo Viện / Giám đốc CCBA*, tôi xem xét và phê duyệt Quyết định giao việc, chỉ định đơn vị chủ trì và đơn vị phối hợp trong Viện.
- **US-PMO-05**: Là *Kỹ sư / Cán bộ kỹ thuật*, tôi muốn xem danh sách phân công công việc (`JobAssignments`) và cập nhật nhật ký công việc (`AssignmentDetails`) hàng tuần.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (Đóng dấu PGV) | - | A (Lưu trữ PGV) | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | C (Luồng 3) | R (Toàn Viện) | U (Thẩm tra PGV) | - | A (Thẩm tra PGV) | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | - | R (Toàn Viện) | U (Đối soát tỷ lệ) | - | - | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Phân công) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Quyết định Giao việc) | E |
| **Chủ nhiệm Dự án (PM / Chủ trì HĐ)** | C | R (Dự án giao) | U (Lập PGV/CTV) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Duyệt PGV nội bộ) | - | A (Xác nhận PGV) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 7 (Giao việc & Phiếu giao việc PGV)*:
    - *Điều 7.1.c (4 Luồng PGV)*:
      - **Luồng 1 (HĐ Viện ký)**: Chủ trì soạn Phiếu đề nghị PGV -> Trưởng đơn vị ký xác nhận -> Phòng KHKT thẩm tra -> Lãnh đạo Viện phê duyệt QĐ giao việc -> Phòng TCHC đóng dấu và chuyển đơn vị thực hiện.
      - **Luồng 2 (HĐ Quản lý tập trung)**: Trưởng đơn vị đề xuất nhân sự -> Lãnh đạo Viện xem xét, ký QĐ -> Nhân sự đơn vị thực hiện theo phân công của Giám đốc.
      - **Luồng 3 (HĐ Kỹ thuật phức tạp / Chính trị / Bộ giao)**: Phòng KHKT đề xuất và soạn thảo QĐ giao việc trình Viện trưởng ký duyệt.
      - **Luồng 4 (HĐ Đơn vị phân cấp ký)**: Chủ trì HĐ soạn Phiếu -> Trưởng phòng xác nhận -> Phòng Tổng hợp thẩm tra -> Trưởng đơn vị ký duyệt.
    - *Điều 7.1 Ghi chú*: Hợp đồng do nhiều đơn vị cùng thực hiện thì Trưởng đơn vị chủ trì thống nhất với Trưởng đơn vị phối hợp cử cán bộ và phân chia tỷ lệ giá trị HĐ trên PGV.
    - *Điều 7.4 (Chủ trì Hợp đồng)*: Phải có đủ khả năng tổ chức thực hiện, có chứng chỉ hành nghề phù hợp.
    - *Điều 7.5 (Chủ trì Kỹ thuật)*: Phải có chứng chỉ hành nghề, ký HĐLĐ với Viện/Đơn vị (Chủ nhiệm dự án, Giám sát trưởng, Chỉ huy trưởng, Chủ trì bộ môn).
    - *Điều 7.6 (Cộng tác viên - CTV)*: CTV ngoài Viện phải có Hợp đồng giao khoán công việc do Trưởng đơn vị ký duyệt.
    - *Điều 7.7 (Kinh phí giao thực hiện)*: Theo Bảng 1 QCTK 2815.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Định mức chi trả lương, tiền công và hợp đồng giao khoán cho Chủ trì, Chủ trì kỹ thuật và CTV.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Nguyên tắc trách nhiệm cá nhân và giải trình đơn nhất của Chủ trì HĐ/PM trên hệ thống IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Step 3 Giao việc (`giao_viec_pgv`) 4 Luồng

```
                     ┌───> [Luồng 1: HĐ Viện ký] -------> KHKT Thẩm tra ──> Lãnh đạo Viện Phê duyệt ──┐
                     ├───> [Luồng 2: QL Tập trung] ────> Lãnh đạo Viện Ký QĐ ────────────────────────┤
[Ký xong HĐ Step 2] ─┼───> [Luồng 3: HĐ Phức tạp/Bộ] ──> KHKT Soạn QĐ ───> Viện trưởng Phê duyệt ────┼─> [Phòng TCHC Đóng dấu & Phân công JobAssignments]
                     └───> [Luồng 4: HĐ Đơn vị ký] ────> Phòng TH Thẩm tra ─> Trưởng Đơn vị Phê duyệt ─┘
```

1. **Phân luồng xử lý PGV (Step 3.1)**:
   - Hệ thống tự động căn cứ vào cấp ký Hợp đồng (Step 2) và loại hình dịch vụ để chọn 1 trong 4 Luồng PGV tương ứng.
2. **Lập Phiếu Đề nghị & Quyết định Giao việc (Step 3.2)**:
   - Điền danh sách `ProjectId`, danh sách nhân sự `EmployeeId`, vai trò `Role` (`Chủ trì HĐ`, `Chủ trì Kỹ thuật`, `Chủ trì Bộ môn`, `Kỹ sư`), thời gian `StartDate`, `EndDate`.
   - Nhập tỷ lệ phân chia kinh phí thực hiện theo Bảng 1 QCTK 2815.
3. **Thẩm tra & Phê duyệt PGV (Step 3.3)**:
   - Thực hiện trình ký và phê duyệt theo đúng 4 Luồng quy định tại Điều 7.1.c QCTK 2815.
4. **Khởi tạo JobAssignments & Phân công (Step 3.4)**:
   - Sau khi PGV được duyệt và đóng dấu, hệ thống tự động tạo các bản ghi trong list `JobAssignments`.
   - Cán bộ được phân công cập nhật tiến độ công việc qua `AssignmentDetails`.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `JobAssignments` (`datamodel/sharepoint/lists/process_execution/job_assignments.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án thực thi |
| `EmployeeId` | Lookup | No | List: `Employees`, Field: `ID` | Liên kết đến Nhân sự/Viên chức được giao việc |
| `Role` | Text | No | - | Vai trò đảm nhận: Chủ trì HĐ, Chủ trì Kỹ thuật, Kỹ sư, CTV |
| `StartDate` | DateTime | No | - | Ngày bắt đầu phân công |
| `EndDate` | DateTime | No | - | Ngày kết thúc phân công |

#### List 2: `AssignmentDetails` (`datamodel/sharepoint/lists/process_execution/assignment_details.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `AssignmentId` | Lookup | No | List: `JobAssignments`, Field: `ID` | Liên kết đến bản ghi Phân công công việc cha |
| `TaskDescription` | Text | No | - | Mô tả nội dung công việc chi tiết |
| `HoursWorked` | Number | No | - | Số giờ làm việc ghi nhận (Timesheet hours) |
| `Notes` | Text | No | - | Ghi chú thêm về kết quả thực hiện |

#### List 3: `Activities` (`datamodel/sharepoint/lists/process_execution/activities.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ActivityName` | Text | Yes | - | Tên hoạt động |
| `ActivityType` | Choice | No | `CRM`, `PotentialProject`, `Marketing`, `R&D`, `Admin` | Phân loại hoạt động vận hành/chuyên môn |
| `Owner` | User | No | - | Người phụ trách hoạt động |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái thực hiện hoạt động |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-PMO-01**: Mọi `JobAssignment` bắt buộc phải có `ProjectId` hợp lệ và `EmployeeId` không được để trống.
- **AC-PMO-02**: Hệ thống kiểm tra điều kiện chứng chỉ hành nghề của `Role` thuộc nhóm Chủ trì Kỹ thuật (Chủ nhiệm, Giám sát trưởng và các chức danh chủ trì khác) trước khi duyệt PGV.
- **AC-PMO-03**: Tất cả các `AssignmentDetails` phải gắn chính xác với `AssignmentId` thông qua quan hệ Lookup restrict.
- **AC-PMO-04**: Tỷ lệ giao khoán trên PGV không được vượt quá định mức tại Bảng 1 QCTK 2815 đối với từng nhóm Hợp đồng.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Lãnh đạo Viện**: Xem toàn bộ PGV toàn Viện; Phê duyệt PGV thuộc Luồng 1, 2, 3.
- **Ban Giám đốc CCBA**: Phê duyệt PGV thuộc Luồng 4 (Đơn vị phân cấp ký); Quản lý toàn bộ PGV tại CCBA.
- **Phòng KHKT Viện**: Thẩm tra PGV Luồng 1; Soạn thảo PGV Luồng 3.
- **Trưởng phòng / PM CCBA**: Lập đề xuất PGV, quản lý phân công cán bộ phòng.
- **Nhân sự / Kỹ sư**: Xem phân công của cá nhân mình và cập nhật `AssignmentDetails`.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo Phiếu giao việc PGV |
| `Author` | User | Người lập PGV |
| `Modified` | DateTime | Thời gian cập nhật phân công cuối cùng |
| `Editor` | User | Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Phiên bản thay đổi dữ liệu phân công |
