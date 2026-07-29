# Đặc Tả Kỹ Thuật Module: Lead Capture (Tiếp nhận & Chuyển đổi Khách hàng Tiềm năng)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Tự động hóa quá trình thu thập thông tin khách hàng tiềm năng (Leads) từ Microsoft Forms, Landing Page, Email tiếp thị và sự kiện hội thảo chuyên ngành của CCBA.
- Thiết lập quy trình chấm điểm Lead (Lead Scoring), phân công xử lý tự động và chuỗi email chăm sóc (Follow-up sequence).
- Đảm bảo 100% Leads thu thập được đánh giá và chuyển đổi thành Khách hàng (`Customers`) và Cơ hội kinh doanh (`Opportunities`) hoặc ghi nhận lý do mất cơ hội (`Lost`).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Tích hợp Microsoft Forms webhook / Power Automate đẩy dữ liệu nộp form trực tiếp vào SharePoint List `Leads`.
  - Thuật toán tính toán Lead Score (từ 1 đến 100) dựa trên thông tin công ty, ngân sách, tiến độ và loại dịch vụ quan tâm.
  - Quản lý chuỗi email chăm sóc tự động 5 giai đoạn (`Initial` -> `FirstFollow` -> `SecondFollow` -> `ThirdFollow` -> `Completed`).
  - Quy trình đánh giá, phân công phụ trách và phê duyệt chuyển đổi Lead thành Customer & Opportunity.
- **Không bao gồm (Out-of-Scope)**:
  - Quản lý chiến dịch quảng cáo trả phí (Google Ads, Facebook Ads API).
  - Soạn thảo hợp đồng chính thức (thực hiện ở module `contracts`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md) — Phần 4 (Hướng dẫn Spec Authors)

### 2.1 User Stories
| Mã US | Vai trò | Mô tả User Story | Tham chiếu |
| :--- | :--- | :--- | :--- |
| US-LC-01 | `ROLE_DEPUTY_DIRECTOR` — Phó Giám đốc Khối DV&KD | Với tư cách Phó Giám đốc Khối DV&KD, tôi muốn phân công xử lý các Lead trên IDOP để đảm bảo chỉ tiêu doanh số và phễu khách hàng | Phụ lục 01 Quy chế CCBA |
| US-LC-02 | `ROLE_STAFF` — NLĐ | Với tư cách Viên chức NLĐ, tôi muốn tạo Lead trên IDOP trong phạm vi công việc của mình để ghi nhận thông tin khách hàng tiềm năng mới | QCTK 2815 |
| US-LC-03 | `ROLE_HEAD_RD` — Trưởng phòng R&D | Với tư cách Trưởng phòng R&D, tôi muốn cập nhật thông tin Lead trên IDOP để hỗ trợ tư vấn kỹ thuật chuyên sâu (Pre-sales) | Phụ lục 01 Quy chế CCBA |
| US-LC-04 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn xem và phê duyệt danh sách Lead quan trọng trên IDOP để định hướng chiến lược tiếp cận | Phụ lục 01 Quy chế CCBA |
| US-LC-05 | `ROLE_HEAD_BIM_DESIGN` — Trưởng phòng BIM TK | Với tư cách Trưởng phòng BIM Thiết kế, tôi muốn tạo Lead trên IDOP khi có khách hàng quan tâm đến dịch vụ thiết kế để theo dõi cơ hội | Phụ lục 01 Quy chế CCBA |
| US-LC-06 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ | Với tư cách Chủ trì HĐ, tôi muốn cập nhật trạng thái Lead do mình phụ trách trên IDOP để phản ánh đúng tình trạng liên hệ với khách hàng | QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)

> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | lead_capture |
|:---|:---:|
| `ROLE_DIRECTOR` | R, A |
| `ROLE_DEPUTY_DIRECTOR` | C, R, U, A |
| `ROLE_LEGAL_QA` | R |
| `ROLE_HEAD_ADMIN` | R |
| `ROLE_HEAD_RD` | C, R, U |
| `ROLE_HEAD_BIM_DESIGN` | C*, R |
| `ROLE_HEAD_BIM_PROJECT` | C*, R |
| `ROLE_PROJECT_MANAGER` | C, R, U |
| `ROLE_STAFF` | C*, R* |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 5.1 (Khuyến khích thông tin thị trường)*: Khuyến khích VCNLĐ đăng ký thông tin công trình, dự án; thông tin tiềm năng được ghi nhận đầu mối qua Phòng KHKT Viện.
  - *Điều 13.1 (Thưởng thị trường & dự thi)*: Cơ sở để ghi nhận đóng góp cá nhân/đơn vị trong việc tìm kiếm cơ hội và chuyển đổi thành hợp đồng chính thức.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - *Điều 8.2.5 (Chi phí quảng cáo, tiếp thị, giao dịch)*: Chi phí marketing và tiếp cận Lead phải có mã theo dõi để hạch toán hiệu quả.
- **Quy chế CCBA 2026**:
  - *Điều 3 (Ứng dụng công nghệ số)*: Bắt buộc thu thập dữ liệu Lead qua cổng số IDOP/MS Forms để minh bạch hóa pipeline bán hàng.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Xử lý & Chuyển đổi Lead

```
[Nộp Form / Nhập Lead] -> [Tính Lead Score & Phân công] -> [Email Chăm sóc Tự động] -> [Đánh giá Qualify/Disqualify] -> [Phê duyệt Chuyển đổi] -> [Tạo Customer & Opportunity]
```

1. **Bước 1: Tiếp nhận Lead tự động**: Dữ liệu từ MS Form gửi qua Power Automate flow, tạo bản ghi mới trong list `Leads` với `Status = "New"`.
2. **Bước 2: Chấm điểm & Phân công**:
   - Thuật toán tự động tính `LeadScore` (0-100) dựa trên: Có tên công ty (+20), có số điện thoại (+20), có ngân sách rõ ràng (+30), tiến độ trong vòng 3 tháng (+30).
   - TPM phân công cán bộ phụ trách (`AssignedTo`).
3. **Bước 3: Thực hiện Chuỗi Follow-up**:
   - Hệ thống tự động gửi Email chào mừng và tài liệu giới thiệu năng lực CCBA (`FollowUpSequenceStage = "Initial"`).
   - Đặt lịch hẹn tự động `NextFollowUpDate` và gửi các email nhắc nhở theo chuỗi (FirstFollow -> SecondFollow -> ThirdFollow).
4. **Bước 4: Đánh giá Phân loại (Qualification)**:
   - Cán bộ cập nhật `Status = "Contacted"` -> `"Qualified"` nếu khách hàng có nhu cầu thực tế.
   - Cập nhật `Status = "Lost"` nếu khách hàng không có nhu cầu hoặc sai thông tin liên hệ.
5. **Bước 5: Chuyển đổi (Conversion)**:
   - Khi Lead đạt chuẩn `Qualified`, người phụ trách bấm nút "Chuyển đổi Lead".
   - Hệ thống tự động tạo bản ghi Khách hàng trong `Customers` (điền `ConvertedToCustomer`).
   - Tự động tạo Cơ hội kinh doanh trong `Opportunities` (điền `ConvertedToOpportunity`).
   - Cập nhật `Status = "Converted"`.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List: `Leads` (`datamodel/sharepoint/lists/strategy_crm/leads.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `LeadName` | Text | Yes | - | Tên người liên hệ hoặc tên tổ chức |
| `Email` | Text | Yes | - | Email liên hệ chính |
| `Phone` | Text | No | - | Số điện thoại liên hệ |
| `Company` | Text | No | - | Tên công ty/tổ chức |
| `Position` | Text | No | - | Chức vụ người liên hệ |
| `Source` | ManagedMetadata | No | `CCBA_NguonGocCoHoi` | Nguồn gốc Lead (Website, MS Form, Seminar, Giới thiệu) |
| `ServiceInterest` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Dịch vụ quan tâm (Tư vấn BIM, Thẩm tra, Kiểm định, Đào tạo) |
| `Industry` | ManagedMetadata | No | `CCBA_NganhLinhVuc` | Ngành nghề (Dân dụng, Giao thông, Hạ tầng, Công nghiệp) |
| `Status` | Choice | No | `New`, `Contacted`, `Qualified`, `Converted`, `Lost` | Trạng thái xử lý Lead |
| `Priority` | ManagedMetadata | No | `CCBA_MucDoUuTien` | Mức độ ưu tiên (Cao, Trung bình, Thấp) |
| `Notes` | Note | No | - | Ghi chú chi tiết quá trình liên hệ |
| `ProjectDescription` | Note | No | - | Mô tả yêu cầu dự án từ form nộp |
| `Budget` | Text | No | - | Ngân sách dự kiến của khách hàng |
| `Timeline` | Text | No | - | Thời gian dự kiến triển khai dự án |
| `AssignedTo` | User | No | - | Cán bộ/Chuyên viên được phân công phụ trách |
| `LastContactDate` | DateTime | No | - | Thời gian lần liên hệ gần nhất |
| `NextFollowUpDate` | DateTime | No | - | Ngày hẹn liên hệ tiếp theo |
| `ConvertedToOpportunity` | Lookup | No | List: `Opportunities`, Field: `ID` | Liên kết Cơ hội kinh doanh tạo ra sau chuyển đổi |
| `ConvertedToCustomer` | Lookup | No | List: `Customers`, Field: `ID` | Liên kết Khách hàng tạo ra sau chuyển đổi |
| `LeadScore` | Number | No | Range: 1 - 100 | Điểm đánh giá mức độ tiềm năng |
| `FormSubmissionId` | Text | No | - | ID của bài nộp Microsoft Forms |
| `FormResponseDate` | DateTime | No | - | Ngày nộp form |
| `FollowUpSequenceStage` | Choice | No | `Initial`, `FirstFollow`, `SecondFollow`, `ThirdFollow`, `Completed` | Giai đoạn email tự động chăm sóc |
| `EmailsSent` | Number | No | Default: 0 | Số email đã gửi trong chuỗi |
| `LastEmailSent` | DateTime | No | - | Thời điểm gửi email cuối cùng |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-LC-01**: Khi có bài nộp từ MS Form, hệ thống tự động tạo 01 bản ghi `Leads` trong vòng 30 giây với `FormSubmissionId` và `FormResponseDate` đầy đủ.
- **AC-LC-02**: Mọi Lead có `LeadScore >= 70` phải tự động đánh dấu `Priority = "Cao"` và gửi thông báo Teams/Email cho TPM.
- **AC-LC-03**: Chỉ được thực hiện thao tác Chuyển đổi khi `Status == "Qualified"`. Sau khi chuyển đổi, `ConvertedToCustomer` và `ConvertedToOpportunity` không được để trống.
- **AC-LC-04**: Không cho phép xóa Lead đã ở trạng thái `Converted`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

> Tham chiếu: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md) — Phần 3 (SharePoint Permission Groups)

- `CCBA_BanGiamDoc`: Full Control (Phê duyệt và quản lý toàn bộ Leads)
- `CCBA_PhongRD_HTQT` + `CCBA_TruongPhong_All`: Contribute (Thêm và cập nhật Lead, hỗ trợ Pre-sales)
- `CCBA_ChuTri_All`: Contribute (Cập nhật Lead phụ trách)
- `CCBA_VCNLD_All`: Contribute (Hạn chế tạo và xem Lead trong phạm vi công việc)

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày giờ thu thập Lead |
| `Author` | User | Hệ thống (Form Integration) hoặc người nhập tay |
| `Modified` | DateTime | Thời gian cập nhật trạng thái / thông tin Lead |
| `Editor` | User | Người thực hiện cập nhật cuối cùng |
| `SystemVersion` | Integer | Lịch sử phiên bản thay đổi dữ liệu Lead |