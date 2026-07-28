
# Kế hoạch kỹ thuật — Opportunities

## Kiến trúc
- Sử dụng SharePoint List "Opportunities" làm backend lưu trữ cơ hội kinh doanh.
- Lookup liên kết với lists Customers (khách hàng), Contacts (liên hệ), Contracts (hợp đồng), Projects (dự án).
- Tích hợp Power Automate cho flows nhắc nhở, trình ký, cập nhật pipeline.
- Power BI kết nối trực tiếp để tạo dashboard pipeline, tỷ lệ chuyển đổi.

## Data model
### List: Opportunities
	- OpportunityName (Text, required)
	- Customer (Lookup: Customers)
	- Project (Lookup: Projects, optional)
	- PrimaryContact (Lookup: Contacts)
	- Stage (Choice: Lead/Qualified/Proposal/Negotiation/Won/Lost/NoGo)
	- Value (Number)
	- Probability (Number, %)
	- AdjustedProbability (Number, % — tính từ InfluenceScore)
	- ExpectedCloseDate (DateTime)
	- Status (Choice: Active/Closed/OnHold)
	- ServiceMixSummary (Text — tổng hợp dịch vụ chính)
	- Industry (ManagedMetadata: Lĩnh vực)
	- Source (ManagedMetadata: Nguồn gốc)
	- Owner (User)
	- InfluenceScore (Number)
	- RiskFlag (Choice: None/InfluenceLow/MissingRoles/StakeholderOpposition)
	- RelatedContracts (Lookup: Contracts)
	- RelatedProjects (Lookup: Projects)
	- Audit fields (Created, Modified, Author, Editor, SystemVersion)

### List: OpportunityServices
	- Opportunity (Lookup: Opportunities)
	- ServiceType (ManagedMetadata: Loại hình dịch vụ)
	- ServiceDescription (Text)
	- EstimatedValue (Number)
	- Probability (Number)
	- Status (Choice: Draft/Active/Negotiating/Won/Lost/Dropped)
	- PlannedStart / PlannedEnd (DateTime)

### List: OpportunityStakeholders
	- Opportunity (Lookup: Opportunities)
	- Contact (Lookup: Contacts)
	- RoleType (ManagedMetadata: Vai trò liên hệ)
	- InfluenceWeight (Number 1–5)
	- SupportLevel (Choice: Champion/Supportive/Neutral/Opposed)
	- EngagementStatus (Choice: New/Nurturing/Active/AtRisk)
	- Notes (Text)

### (Optional) List: ServiceCatalog (tương lai)
	- ServiceCode, ServiceName, CrossSellSuggestions (Multi-line JSON)

## Flows
1. Reminder: Nhắc ExpectedCloseDate & quá hạn Stage.
2. Stakeholder Gate Check: Khi chuyển sang Proposal/Negotiation kiểm tra đủ vai trò.
3. InfluenceScore Recalculate: Khi thêm/sửa Stakeholder hoặc SupportLevel thay đổi.
4. Escalation Flow: Sau 7 ngày Negotiation thiếu Decision Maker → gửi quản lý.
5. Cross‑sell Suggestion: Khi một OpportunityService Won → tạo draft services khác.
6. Auto Adjust Probability: Cập nhật AdjustedProbability = Probability × (InfluenceScore / TargetScore).
7. Post-Win Sync: Tạo draft Contract/Project records.

## Env & security
- Phân quyền theo vai trò: nhân viên, quản lý, ban giám đốc.
- Chỉ người phụ trách mới được sửa thông tin cơ hội mình quản lý.
- Lưu vết mọi thay đổi (audit log SharePoint).
- Bảo mật thông tin giá trị, xác suất, khách hàng theo quy định nội bộ.

## Tích hợp & cấu hình đặc thù
- Lookup liên kết lists khách hàng, hợp đồng, dự án, tài chính.
- Tích hợp Power Automate: nhắc nhở, trình ký, cập nhật pipeline.
- Kết nối Power BI: dashboard pipeline, tỷ lệ chuyển đổi, doanh thu dự kiến.
- Biến môi trường: endpoint API, connection reference cho Power Automate.
- Xử lý lỗi: log chi tiết, cảnh báo khi flow thất bại.

## Triển khai & kiểm thử
1. Validate tất cả schema (Opportunities, OpportunityServices, OpportunityStakeholders).
2. Thứ tự tạo lists: Customers → Contacts → Opportunities → OpportunityServices → OpportunityStakeholders.
3. Chạy `.\idop.ps1 deploy lists -Environment Dev -OnlyLists Opportunities` để smoke test.
4. Kiểm thử flows với bộ dữ liệu seed (ít nhất 3 cơ hội đa dịch vụ, 2 có thiếu vai trò → test cảnh báo).
5. Kiểm thử InfluenceScore tính toán: thay đổi SupportLevel & InfluenceWeight.
6. Kiểm thử cross-sell: đánh dấu 1 service Won → draft service mới.
7. Power BI: tạo dataset với bảng fact (OpportunityServices) & dimension (ServiceCatalog, StakeholderRole).

## Báo cáo & KPI
### Chỉ số chính
- PipelineTotalValue = Σ(EstimatedValue các OpportunityServices chưa Won/Lost)
- AdjustedForecast = Σ(EstimatedValue × AdjustedProbability)
- WinRate = Won Opportunities / (Won + Lost)
- CrossSellIndex = (Số cơ hội có >1 service Won) / (Tổng cơ hội Won)
- Velocity(StageX) = AVG(days trong StageX)
- InfluenceCoverage = % cơ hội có đủ critical roles (Decision Maker + Finance + Technical)
- StakeholderRiskCount = # cơ hội có Opposed stakeholder InfluenceWeight ≥4
- DataCompleteness = % cơ hội đạt đủ điều kiện chuyển Stage theo rule

### Dashboard đề xuất
- Funnel theo Stage (Value & Count)
- Matrix: ServiceType × Stage
- Opportunity Influence Radar (Score vs AdjustedProbability)
- Stakeholder Risk Heatmap
- Cross-sell Opportunity Table (gợi ý draft)

### Cảnh báo (Alerts)
- InfluenceScore < 30% target ở Stage Proposal
- Thiếu Decision Maker >5 ngày ở Stage Negotiation
- Probability > 60% nhưng InfluenceCoverage < 100%

## Lộ trình triển khai tuần tự
### Phase 1: Foundation
- Tạo lists: Customers, Contacts, Opportunities
- Triển khai flows reminder cơ bản & stake gating
- Dashboard pipeline đơn giản

### Phase 2: Multi-Service & Stakeholder Depth
- Thêm OpportunityServices & OpportunityStakeholders
- Implement InfluenceScore recalculation flow
- Dashboard mở rộng (service mix, influence)

### Phase 3: Cross-Sell & Forecast Refinement
- Cross-sell suggestion flow
- AdjustedProbability logic
- Power BI advanced dataset (fact services + dim taxonomy)

### Phase 4: Optimization & Governance
- Alerts nâng cao & escalation
- Data completeness audit report
- Performance tuning (indexing lookups)

### Phase 5: Continuous Improvement
- Bổ sung ServiceCatalog & mapping file
- A/B test các ngưỡng InfluenceScore
- Tự động export snapshot để phân tích xu hướng
