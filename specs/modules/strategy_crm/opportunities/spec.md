# Đặc Tả Kỹ Thuật Module: Opportunities (Quản lý Cơ hội Kinh doanh & Đấu thầu)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý toàn bộ đường ống cơ hội kinh doanh (Opportunity Pipeline), từ giai đoạn tìm kiếm thông tin, lập Hồ sơ Dự thầu (HSDT/HSDX), đánh giá rủi ro, phân tích điểm ảnh hưởng đến quyết định phê duyệt tham gia đấu thầu.
- Số hóa Step 1 Đấu thầu (`dot_thau`) trong Chuỗi 7 bước nghiệp vụ IDOP theo đúng quy định tại Điều 5 QCTK 2815.
- Tự động tạo cấu trúc Thư mục Hồ sơ thầu (Bidding Folder) trên SharePoint/OneDrive, phân công nhóm dự thầu (Bid Team) và liên kết chặt chẽ dữ liệu Cơ hội với Tiềm năng dự án (`PotentialProjects`), Hợp đồng (`Contracts`) và Dự án (`Projects`).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quản lý pipeline cơ hội qua 6 giai đoạn: `New`, `Qualification Review`, `Proposal/HSDX`, `Closed - Won`, `Closed - Lost`, `Closed - Not Pursued`.
  - Quy trình Phê duyệt Quyết định Tham gia Đấu thầu (`ParticipationDecision`): Yes / No / Unknown kèm liên kết email/văn bản chỉ đạo.
  - Tự động khởi tạo và quản lý trạng thái Thư mục Hồ sơ thầu (`BiddingFolderDriveItemId`, `BiddingFolderUrl`, `BiddingFolderState`, `BiddingFolderPhase`).
  - Đánh giá xác suất điều chỉnh (`AdjustedProbability`), điểm ảnh hưởng đối tác (`InfluenceScore`), và cờ rủi ro (`RiskFlags`).
  - Quản lý 3 list vệ tinh: Chi tiết Dịch vụ (`OpportunityServices`), Lịch sử Chuyển giai đoạn (`OpportunityStageHistory`), Các bên liên quan (`OpportunityStakeholders`).
- **Không bao gồm (Out-of-Scope)**:
  - Soạn thảo nội dung bản vẽ/thuyết minh kỹ thuật chi tiết của HSDT (thực hiện trên phần mềm chuyên ngành).
  - Quản lý chi phí tài chính thực tế phát sinh trong quá trình đấu thầu (thực hiện ở module `cash_data/expenses`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md) — Phần 4 (Hướng dẫn Spec Authors)

### 2.1 User Stories
| Mã US | Vai trò | Mô tả User Story | Tham chiếu |
| :--- | :--- | :--- | :--- |
| US-OPP-01 | `ROLE_DEPUTY_DIRECTOR` — Phó Giám đốc Khối DV&KD | Với tư cách Phó Giám đốc Khối DV&KD, tôi muốn phê duyệt cơ hội dự thầu trên IDOP để quyết định việc tham gia đấu thầu | Điều 5 QCTK 2815 |
| US-OPP-02 | `ROLE_HEAD_RD` — Trưởng phòng R&D | Với tư cách Trưởng phòng R&D, tôi muốn cập nhật giải pháp kỹ thuật cho cơ hội trên IDOP để hỗ trợ Pre-sales | Phụ lục 01 Quy chế CCBA |
| US-OPP-03 | `ROLE_LEGAL_QA` — Cố vấn Pháp lý | Với tư cách Cố vấn Pháp lý, tôi muốn thẩm định hồ sơ dự thầu trên IDOP để đảm bảo tính hợp lệ pháp lý của cơ hội | QCTK 2815 |
| US-OPP-04 | `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp | Với tư cách Trưởng phòng Tổng Hợp, tôi muốn theo dõi cơ hội trên IDOP để đăng ký đơn vị đầu mối với Viện | Điều 5.1c QCTK 2815 |
| US-OPP-05 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ | Với tư cách Chủ trì HĐ, tôi muốn cập nhật hồ sơ dự thầu trên IDOP để chuẩn bị tham gia đấu thầu | Điều 5.1d QCTK 2815 |
| US-OPP-06 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn phê duyệt các cơ hội đấu thầu trên IDOP để trình Lãnh đạo Viện khi cần | Điều 6.1 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)

> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | opportunities |
|:---|:---:|
| `ROLE_DIRECTOR` | R, A |
| `ROLE_DEPUTY_DIRECTOR` | C, R, U, A |
| `ROLE_LEGAL_QA` | R, A (thẩm định HSDT) |
| `ROLE_HEAD_ADMIN` | R |
| `ROLE_HEAD_RD` | C, R, U (Pre-sales) |
| `ROLE_HEAD_BIM_DESIGN` | C*, R, U* |
| `ROLE_HEAD_BIM_PROJECT` | C*, R, U* |
| `ROLE_PROJECT_MANAGER` | C, R, U |
| `ROLE_STAFF` | R* |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 5.1 (Đấu thầu & Tìm kiếm việc làm - Step 1 Operational Flow)*:
    - *Khoản a, b*: Giám đốc đơn vị chịu trách nhiệm chính về công tác thị trường. VCNLĐ có thông tin cơ hội/dự án phải báo cáo Giám đốc đơn vị.
    - *Khoản c*: Giám đốc đơn vị đăng ký đơn vị đầu mối với Phòng KHKT Viện. Phòng KHKT trình Lãnh đạo Viện chỉ đạo phân công đầu mối đấu thầu.
    - *Khoản d*: Giám đốc đơn vị chỉ định người chủ trì tổ chức lập HSDT; Giám đốc kiểm tra, quyết định và chịu trách nhiệm toàn diện về HSDT.
    - *Khoản đ*: Tuân thủ quy định quản lý, khai thác CSDL phục vụ đấu thầu và đấu thầu qua mạng của Viện.
  - *Điều 4.7*: Trước khi ký văn bản thỏa thuận liên danh với đơn vị ngoài Viện, phải thông báo bằng văn bản cho Phòng KHKT.
  - *Điều 6.1*: Các gói thầu với giá dự thầu >= 2 tỷ (kiểm định), >= 5 tỷ (tư vấn), >= 10 tỷ (thi công) phải báo cáo xin ý kiến chỉ đạo của Viện trưởng.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Chi phí mua hồ sơ mời thầu, bảo lãnh dự thầu và chi phí liên quan đến công tác dự thầu hạch toán vào chi phí quản lý thị trường của đơn vị.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Minh bạch thông tin dự thầu và lưu trữ tập trung Hồ sơ thầu số trên hạ tầng CDE/IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md) — Phần 2, Bước 1 (Đấu thầu, Điều 5 QCTK 2815)

### 4.1 Quy trình Step 1 Đấu thầu (`dot_thau`) & Quản lý Cơ hội

```
[Phát hiện Cơ hội / HSMT] -> [Đăng ký Đầu mối với KHKT] -> [BGD Viện Phân công Đầu mối] -> [Đánh giá Rủi ro & Bidding Folder] -> [Lập HSDT & Phê duyệt Quyết định] -> [Nộp HSDT & Cập nhật Kết quả (Won/Lost)]
```

1. **Bước 1.1: Phát hiện & Nhập thông tin Cơ hội**:
   - VCNLĐ/Chuyên viên nhập thông tin Cơ hội vào list `Opportunities` với trạng thái `Stage = "New"`.
   - Chọn thông tin Khách hàng (`Customer`), Liên hệ (`Contact`), Ngành nghề (`Industry`), Loại hình dịch vụ (`ServiceType`).
2. **Bước 1.2: Đăng ký Đơn vị Đầu mối (Điều 5.1.c QCTK 2815)**:
   - Giám đốc CCBA đăng ký đơn vị đầu mối với Phòng KHKT Viện.
   - Phòng KHKT kiểm tra trùng lặp đơn vị đầu mối, trình Lãnh đạo Viện phê duyệt chỉ đạo.
3. **Bước 1.3: Khởi tạo Thư mục Hồ sơ thầu (Bidding Folder Automation)**:
   - Sau khi Lãnh đạo Viện chấp thuận, hệ thống tự động gọi API tạo thư mục Bidding Folder trên SharePoint.
   - Cập nhật `BiddingFolderState = "Created"`, `BiddingFolderUrl`, và cấp quyền cho nhóm `BidTeam`.
4. **Bước 1.4: Lập HSDT & Đánh giá Rủi ro**:
   - Nhóm `BidTeam` tải lên các thành phần HSDT, hồ sơ năng lực, đề xuất tài chính.
   - Đánh giá các cờ rủi ro (`RiskFlags`: InfluenceLow, MissingRoles, StakeholderOpposition, DataGap) và tính `AdjustedProbability`.
   - Cập nhật `Stage = "Proposal/HSDX"`.
5. **Bước 1.5: Phê duyệt Quyết định Tham gia & Ký Hồ sơ**:
   - Đơn giá/Giá trị thầu lớn (>= 2 tỷ kiểm định, >= 5 tỷ tư vấn): Trình Lãnh đạo Viện phê duyệt `ParticipationDecision = "Yes"`.
   - Giám đốc đơn vị kiểm tra, chịu trách nhiệm toàn diện HSDT trước khi nộp.
6. **Bước 1.6: Kết quả Đấu thầu & Chuyển giao**:
   - Nếu trúng thầu (`Closed - Won`): Tự động chuyển dữ liệu sang Step 2 Trình ký Hợp đồng (`Contracts`) và Tiềm năng dự án (`PotentialProjects`).
   - Nếu trượt thầu/không theo đuổi (`Closed - Lost` / `Closed - Not Pursued`): Ghi rõ lý do và đóng bản ghi cơ hội.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `Opportunities` (`datamodel/sharepoint/lists/strategy_crm/opportunities.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `OpportunityName` | Text | Yes | - | Tên cơ hội kinh doanh / Gói thầu |
| `PotentialProject` | Lookup | No | List: `PotentialProjects`, Field: `ID` | Tiềm năng dự án tương ứng |
| `Customer` | Lookup | No | List: `Customers`, Field: `ID` | Khách hàng/Chủ đầu tư |
| `Contact` | Lookup | No | List: `Contacts`, Field: `ID` | Liên hệ đại diện phía Khách hàng |
| `Stage` | Choice | No | `New`, `Qualification Review`, `Proposal/HSDX`, `Closed - Won`, `Closed - Lost`, `Closed - Not Pursued` | Giai đoạn pipeline cơ hội |
| `ParticipationDecision` | Choice | No | `Unknown`, `Yes`, `No` | Quyết định tham gia đấu thầu của Lãnh đạo |
| `DecisionDate` | DateTime | No | - | Ngày ra quyết định tham gia |
| `DecisionNote` | Note | No | - | Ghi chú/Ý kiến chỉ đạo của Lãnh đạo |
| `DecisionEmailLink` | Hyperlink | No | - | Liên kết email/văn bản chỉ đạo quyết định |
| `BiddingFolderDriveItemId` | Text | No | - | ID thư mục Hồ sơ thầu trên OneDrive/SharePoint |
| `BiddingFolderUrl` | Hyperlink | No | - | URL đường dẫn tới thư mục Hồ sơ thầu |
| `BiddingFolderPath` | Text | No | - | Đường dẫn tuyệt đối của thư mục thầu |
| `BiddingFolderState` | Choice | No | `Not Created`, `Creating`, `Created`, `Failed` | Trạng thái tự động khởi tạo thư mục thầu |
| `BiddingFolderPhase` | Choice | No | `Draft`, `Confirmed`, `Archived` | Pha lưu trữ của thư mục thầu |
| `BiddingCode` | Text | No | - | Mã số hồ sơ thầu chính thức |
| `BidTeam` | User | No | Multi-user selection | Danh sách thành viên nhóm dự thầu |
| `Value` | Number | No | - | Giá trị gói thầu dự kiến (VND) |
| `Probability` | Number | No | Range: 0 - 100 | Xác suất trúng thầu ban đầu (%) |
| `AdjustedProbability` | Number | No | Calculated | Xác suất điều chỉnh sau khi tính điểm InfluenceScore & Risk |
| `InfluenceScore` | Number | No | Calculated | Điểm ảnh hưởng của các bên liên quan |
| `RiskFlags` | MultiChoice | No | `InfluenceLow`, `MissingRoles`, `StakeholderOpposition`, `DataGap` | Cờ cảnh báo rủi ro đấu thầu |
| `ServiceMixSummary` | Note | No | - | Chuỗi tóm tắt cơ cấu dịch vụ |
| `ExpectedCloseDate` | DateTime | No | - | Ngày dự kiến chốt hợp đồng/mở thầu |
| `Status` | Choice | No | `Active`, `Closed`, `OnHold` | Trạng thái chung của cơ hội |
| `ServiceType` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Loại hình dịch vụ chủ đạo |
| `Industry` | ManagedMetadata | No | `CCBA_NganhLinhVuc` | Ngành/Lĩnh vực dự án |
| `Source` | ManagedMetadata | No | `CCBA_NguonGocCoHoi` | Nguồn gốc cơ hội kinh doanh |
| `RelatedContracts` | Lookup | No | List: `Contracts`, Field: `ID` | Hợp đồng sinh ra từ cơ hội này |
| `RelatedProjects` | Lookup | No | List: `Projects`, Field: `ID` | Dự án sinh ra từ cơ hội này |
| `Owner` | User | No | - | Cán bộ/PM chính phụ trách cơ hội |

#### List 2: `OpportunityServices` (`datamodel/sharepoint/lists/strategy_crm/opportunity_services.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `Opportunity` | Lookup | No | List: `Opportunities`, Field: `ID` | Liên kết đến Cơ hội kinh doanh |
| `ServiceType` | ManagedMetadata | No | `CCBA_LoaiHinhDichVu` | Loại hình dịch vụ thành phần |
| `ServiceDescription` | Text | No | - | Mô tả chi tiết dịch vụ |
| `EstimatedValue` | Number | No | - | Giá trị ước tính của dịch vụ (VND) |
| `Probability` | Number | No | - | Xác suất thành công của dịch vụ (%) |
| `Status` | Choice | No | `Draft`, `Active`, `Negotiating`, `Won`, `Lost`, `Dropped` | Trạng thái dòng dịch vụ |
| `PlannedStart` | DateTime | No | - | Ngày dự kiến bắt đầu dịch vụ |
| `PlannedEnd` | DateTime | No | - | Ngày dự kiến kết thúc dịch vụ |

#### List 3: `OpportunityStageHistory` (`datamodel/sharepoint/lists/strategy_crm/opportunity_stage_history.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `Opportunity` | Lookup | No | List: `Opportunities`, Field: `ID` | Liên kết đến Cơ hội kinh doanh |
| `FromStage` | Choice | No | `Lead`, `Qualified`, `Proposal`, `Negotiation`, `Won`, `Lost` | Giai đoạn trước chuyển đổi |
| `ToStage` | Choice | No | `Lead`, `Qualified`, `Proposal`, `Negotiation`, `Won`, `Lost` | Giai đoạn sau chuyển đổi |
| `DaysInPrevStage` | Number | No | - | Số ngày lưu lại ở giai đoạn trước |
| `ChangedAt` | DateTime | No | - | Thời điểm chuyển đổi giai đoạn |
| `ChangedBy` | User | No | - | Người thực hiện chuyển đổi giai đoạn |

#### List 4: `OpportunityStakeholders` (`datamodel/sharepoint/lists/strategy_crm/opportunity_stakeholders.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `Opportunity` | Lookup | No | List: `Opportunities`, Field: `ID` | Liên kết đến Cơ hội kinh doanh |
| `Contact` | Lookup | No | List: `Contacts`, Field: `ID` | Người liên hệ đại diện |
| `RoleType` | ManagedMetadata | No | `CCBA_VaiTroLienHe` | Vai trò của bên liên quan |
| `InfluenceWeight` | Number | No | - | Trọng số ảnh hưởng của bên liên quan |
| `SupportLevel` | Choice | No | `Champion`, `Supportive`, `Neutral`, `Opposed` | Mức độ ủng hộ/phản đối |
| `EngagementStatus` | Choice | No | `New`, `Nurturing`, `Active`, `AtRisk` | Trạng thái tương tác với bên liên quan |
| `Notes` | Text | No | - | Ghi chú bổ sung về bên liên quan |


### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-OPP-01**: Với gói thầu tư vấn >= 5 tỷ hoặc kiểm định >= 2 tỷ, hệ thống bắt buộc kiểm tra trường `ParticipationDecision == "Yes"` và `DecisionEmailLink` không trống trước khi cho phép chuyển sang `Stage = "Proposal/HSDX"`.
- **AC-OPP-02**: Khi `Stage` chuyển sang `Proposal/HSDX`, hệ thống tự động kích hoạt tiến trình tạo Bidding Folder, cập nhật `BiddingFolderState = "Created"` và gán quyền cho các tài khoản trong `BidTeam`.
- **AC-OPP-03**: Khi chuyển trạng thái `Stage = "Closed - Won"`, hệ thống tự động gợi ý tạo Hợp đồng mới trong list `Contracts` và điền sẵn thông tin Khách hàng, Giá trị, Mã gói thầu.
- **AC-OPP-04**: Tất cả ManagedMetadata phải khớp 100% với TermStore `CCBA Taxonomy`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

> Tham chiếu: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md) — Phần 3 (SharePoint Permission Groups)

- `CCBA_BanGiamDoc`: Full Control (Phê duyệt Quyết định thầu)
- `CCBA_Legal_QA`: Contribute + Approve (Thẩm định pháp lý HSDT)
- `CCBA_PhongRD_HTQT`, `CCBA_ChuTri_All`: Contribute (Thêm/Sửa giải pháp và HSDT)
- `CCBA_PhongTongHop`: Read (Theo dõi cơ hội để đăng ký đơn vị đầu mối)
- `CCBA_VCNLD_All`: Read (Hạn chế xem phạm vi được giao)

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo cơ hội |
| `Author` | User | Người đăng ký cơ hội |
| `Modified` | DateTime | Thời gian cập nhật thông tin thầu mới nhất |
| `Editor` | User | Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Phiên bản lịch sử dữ liệu cơ hội |
