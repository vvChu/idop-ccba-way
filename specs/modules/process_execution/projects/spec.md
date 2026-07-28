# Đặc Tả Kỹ Thuật Module: Projects (Quản lý Thực thi Dự án & 5 Luồng Quản lý)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý toàn bộ vòng đời thực thi các dự án tư vấn, dịch vụ kỹ thuật, thi công và cung ứng của CCBA và Viện KHCN Xây dựng.
- Số hóa 100% Step 4 Thực hiện (`thuc_hien_du_an`) trong Chuỗi 7 bước nghiệp vụ IDOP theo đúng quy định tại Điều 8 & 9 QCTK 2815 với 5 luồng quản lý thực hiện chuyên biệt.
- Quản lý tiến độ, ngân sách (`Budget`), lịch sử điều chỉnh (`ProjectHistory`), danh mục vấn đề phát sinh (`ProjectIssues`) và quản trị rủi ro (`ProjectRisks`).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quy trình 5 Luồng Quản lý Thực hiện Hợp đồng (Điều 8 & 9 QCTK 2815):
    - *Luồng 1*: HĐ Tư vấn (N2a, N2d và các phụ lục liên quan khác).
    - *Luồng 2*: HĐ Thí nghiệm / Kiểm định / Giám định (N1a, N2e, N2f, N2g).
    - *Luồng 3*: HĐ Thi công xây dựng (N3).
    - *Luồng 4*: HĐ Cung ứng Vật tư - Thiết bị (N4).
    - *Luồng 5*: Mô hình Quản lý Tập trung CCBA (Điều 3.2.p, Điều 4.3, Điều 8.5).
  - Phân định trách nhiệm điều hành, kiểm soát giải pháp kỹ thuật, tiến độ, an toàn lao động của Trưởng đơn vị, Chủ trì HĐ và Chủ trì kỹ thuật.
  - Tích hợp 1-to-1 với 4 SharePoint Lists: `Projects`, `ProjectHistory`, `ProjectIssues`, `ProjectRisks`.
- **Không bao gồm (Out-of-Scope)**:
  - Lưu trữ tài liệu sản phẩm BIM/CDE chi tiết (thực hiện ở module `cde_documents`).
  - Quyết toán tài chính thanh lý hợp đồng (thực hiện ở module `cash_data/finance` & `allocations`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-PRJ-01**: Là *Chủ nhiệm Dự án (PM CCBA)*, tôi muốn theo dõi tiến độ tổng thể, ngân sách dự án và cập nhật thông tin thực thi hàng tuần.
- **US-PRJ-02**: Là *Kỹ sư / Cán bộ Kỹ thuật*, tôi muốn ghi nhận các vấn đề phát sinh (`ProjectIssues`) và báo cáo các cờ rủi ro (`ProjectRisks`) để PM và TPM kịp thời xử lý.
- **US-PRJ-03**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi kiểm soát giải pháp kỹ thuật, duyệt kế hoạch ứng phó rủi ro (`MitigationPlan`) và chịu trách nhiệm về chất lượng sản phẩm (Điều 9.1.b QCTK 2815).
- **US-PRJ-04**: Là *Giám đốc CCBA*, tôi trực tiếp điều hành các dự án theo Mô hình Quản lý Tập trung (Luồng 5), bố trí nhân sự và kiểm soát toàn diện hồ sơ kỹ thuật - tài chính.
- **US-PRJ-05**: Là *Phòng Kế hoạch - Kỹ thuật (KHKT Viện)*, tôi kiểm tra định kỳ hoặc đột xuất tiến độ, khối lượng và chất lượng thực hiện các dự án (Điều 9.6 QCTK 2815).

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (An toàn lao động) | - | - | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | C | R (Toàn Viện) | U (Kiểm tra tiến độ) | - | A (Phúc tra KHKT) | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | - | R (Toàn Viện) | U (Đối soát ngân sách) | - | - | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Thực thi/Issue) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Phê duyệt dự án) | E |
| **Chủ nhiệm Dự án (PM / Chủ trì HĐ)** | C | R (Dự án giao) | U (Tiến độ/Rủi ro) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Kỹ thuật/Rủi ro) | - | A (Giải pháp KT) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 8 (Quản lý Thực hiện Hợp đồng)*:
    - *Khoản 1*: Trưởng đơn vị, chủ trì có nhiệm vụ tổ chức thực hiện hợp đồng đúng tiến độ, đảm bảo an toàn, đạt chất lượng.
    - *Khoản 2*: Hồ sơ kết quả chỉ được đóng dấu khi HĐ đã ký kết. Trường hợp HĐ chờ ký phải được Lãnh đạo Viện / Giám đốc đơn vị chấp thuận.
    - *Khoản 3*: Khi Trưởng đơn vị làm Chủ trì HĐ thì phải giao 01 Phó đơn vị quản lý đối với HĐ đó.
    - *Khoản 5 & Điều 3.2.p*: Mô hình Quản lý Tập trung tại đơn vị đối với HĐ TVGS, TVQLDA, Thi công (Giám đốc đơn vị trực tiếp quản lý, điều hành).
  - *Điều 9 (Trách nhiệm và Quyền hạn)*:
    - *Khoản 1 (Trưởng đơn vị)*: Chịu trách nhiệm toàn diện trước Viện trưởng về giải pháp kỹ thuật, tiến độ, khối lượng, an toàn lao động.
    - *Khoản 4 (Chủ trì HĐ & Chủ trì Kỹ thuật)*: Chịu trách nhiệm trực tiếp về sản phẩm thiết kế, báo cáo kiểm định, hồ sơ thẩm tra.
  - *Điều 14.3*: Xử lý vi phạm gây sự cố kỹ thuật và trách nhiệm bồi thường.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Quản lý chi phí ngân sách dự án (`Budget`) trong phạm vi kinh phí giao khoán tại Bảng 1 QCTK 2815.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Áp dụng quy chuẩn số IDOP trong theo dõi và giám sát tiến độ thực thi dự án.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Step 4 Thực hiện Dự án (`thuc_hien_du_an`) 5 Luồng

```
                     ┌───> [Luồng 1: HĐ Tư vấn (N2a, N2d)] ──────> Kiểm soát Hồ sơ Thiết kế/TVGS ──┐
                     ├───> [Luồng 2: HĐ Thí nghiệm/Kiểm định] ───> Thí nghiệm & Ký Báo cáo KT ─────┤
[PGV Duyệt Step 3] ──┼───> [Luồng 3: HĐ Thi công (N3)] ──────────> Chỉ huy trưởng Quản lý Cung ứng ┼─> [Cập nhật Lịch sử / Issue / Risk] -> [Chuyển Step 5 Kiểm tra Nội bộ]
                     ├───> [Luồng 4: HĐ Cung ứng (N4)] ──────────> Bàn giao VT-TB & Chứng thư ─────┤
                     └───> [Luồng 5: Mô hình Tập trung CCBA] ───> GĐ CCBA Trực tiếp Điều hành ────┘
```

1. **Khởi tạo Dự án Thực thi (Step 4.1)**:
   - Bản ghi `Projects` được tạo tự động từ `Contracts` (Step 2) và `JobAssignments` (Step 3).
   - Nhập `ProjectCode`, `ProjectName`, `ContractId`, `Budget`, `StartDate`, `EndDate`, `ServiceType`.
2. **Triển khai theo 5 Luồng chuyên biệt (Step 4.2)**:
   - Cán bộ/PM thực hiện nhiệm vụ kỹ thuật tương ứng theo đúng phân luồng (Tư vấn, Thí nghiệm/Kiểm định, Thi công, Cung ứng, hoặc Quản lý tập trung).
3. **Quản lý Lịch sử & Thay đổi (Step 4.3)**:
   - Ghi nhận mọi điều chỉnh tiến độ/phạm vi vào list `ProjectHistory` (`ChangeDescription`, `ChangeDate`, `IsCurrent`).
4. **Quản lý Vấn đề & Rủi ro (Step 4.4)**:
   - Ghi nhận `ProjectIssues` (`IssueTitle`, `Priority`, `Owner`, `Status`).
   - Đánh giá `ProjectRisks` (`RiskTitle`, `Severity`, `MitigationPlan`, `Owner`, `Status`).
5. **Chuyển giao Step 5 (Kiểm tra Nội bộ)**:
   - Hoàn thành sản phẩm kỹ thuật, chuẩn bị hồ sơ cho Step 5 Kiểm tra nội bộ (Điều 10 QCTK 2815).

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `Projects` (`datamodel/sharepoint/lists/process_execution/projects.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectCode` | Text | Yes | - | Mã số dự án chính thức (Unique) |
| `ProjectName` | Text | Yes | - | Tên dự án |
| `ContractId` | Lookup | No | List: `Contracts`, Field: `ID` | Liên kết đến Hợp đồng kinh tế |
| `Budget` | Number | No | - | Ngân sách chi phí dự án (VND) |
| `ServiceType` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Loại hình dịch vụ |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái: Chuẩn bị, Đang thực hiện, Tạm dừng, Hoàn thành |
| `StartDate` | DateTime | No | - | Ngày bắt đầu thực tế |
| `EndDate` | DateTime | No | - | Ngày kết thúc dự kiến |

#### List 2: `ProjectHistory` (`datamodel/sharepoint/lists/process_execution/project_history.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án cha |
| `ChangeDate` | DateTime | No | - | Ngày ghi nhận thay đổi |
| `ChangeDescription` | Text | No | - | Mô tả chi tiết nội dung thay đổi |
| `IsCurrent` | YesNo | No | - | Cờ xác định phiên bản hiện tại |

#### List 3: `ProjectIssues` (`datamodel/sharepoint/lists/process_execution/project_issues.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án cha |
| `IssueTitle` | Text | Yes | - | Tiêu đề vấn đề phát sinh |
| `Priority` | Choice | No | `High`, `Medium`, `Low` | Mức độ ưu tiên/khẩn cấp |
| `Description` | Text | No | - | Mô tả chi tiết vấn đề |
| `Owner` | User | No | - | Người phụ trách xử lý |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái xử lý |
| `ReportedDate` | DateTime | No | - | Ngày phát hiện |
| `ResolvedDate` | DateTime | No | - | Ngày giải quyết xong |

#### List 4: `ProjectRisks` (`datamodel/sharepoint/lists/process_execution/project_risks.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án cha |
| `RiskTitle` | Text | Yes | - | Tiêu đề rủi ro nhận diện |
| `Severity` | Choice | No | `Low`, `Medium`, `High` | Mức độ nghiêm trọng |
| `MitigationPlan` | Text | No | - | Phương án giảm thiểu / ứng phó rủi ro |
| `Owner` | User | No | - | Người phụ trách theo dõi rủi ro |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái rủi ro |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-PRJ-01**: `ProjectCode` phải là duy nhất. Mọi bản ghi `Projects` phải liên kết với 01 `ContractId` hợp lệ.
- **AC-PRJ-02**: Mọi sự thay đổi tiến độ (`StartDate`, `EndDate`) phải tự động ghi lại bản ghi lịch sử trong `ProjectHistory`.
- **AC-PRJ-03**: Tất cả các `ProjectIssues` có `Priority == "High"` phải tự động gửi cảnh báo Teams/Email cho TPM và GĐ CCBA.
- **AC-PRJ-04**: Bắt buộc nhập `MitigationPlan` khi tạo bản ghi `ProjectRisks` có `Severity == "High"`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Ban Giám đốc Viện**: Xem toàn bộ dự án toàn Viện; Kiểm tra tiến độ và chất lượng.
- **Ban Giám đốc CCBA**: Quản lý toàn bộ dự án CCBA; Trực tiếp điều hành các dự án Luồng 5 (Quản lý tập trung).
- **Trưởng phòng Chuyên môn (TPM)**: Quản lý và phê duyệt mặt kỹ thuật cho các dự án thuộc phòng.
- **Chủ nhiệm Dự án (PM)**: Xem/Cập nhật tiến độ, ngân sách, issues và risks đối với các dự án được phân công.
- **Phòng KHKT Viện**: Xem và tiến hành phúc tra, kiểm tra định kỳ.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày tạo bản ghi dự án |
| `Author` | User | Người khởi tạo dự án |
| `Modified` | DateTime | Thời gian cập nhật trạng thái mới nhất |
| `Editor` | User | Người cập nhật cuối cùng |
| `SystemVersion` | Integer | Phiên bản dữ liệu dự án |
