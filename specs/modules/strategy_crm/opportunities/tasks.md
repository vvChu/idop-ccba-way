
# Backlog — Opportunities

## Epic 1: Foundation (Opportunities Core)
- [ ] Hoàn thiện schema Opportunities (Probability, AdjustedProbability, InfluenceScore, RiskFlags, ServiceMixSummary)
- [ ] Form nhập liệu cơ bản + phân quyền Owner
- [ ] Kiểm thử CRUD & validation tối thiểu

## Epic 2: Multi-Service Architecture
- [ ] Tạo lists OpportunityServices & ServiceCatalog
- [ ] Tạo form quick add service line
- [ ] Flow cập nhật ServiceMixSummary

## Epic 3: Stakeholder Influence
- [ ] Tạo list OpportunityStakeholders + form role mapping
- [ ] Flow tính InfluenceScore & AdjustedProbability
- [ ] Cảnh báo thiếu vai trò critical

## Epic 4: Lifecycle & Compliance
- [ ] Rule chặn chuyển Stage nếu thiếu dữ liệu
- [ ] RiskFlags tự động (MissingRoles, StakeholderOpposition, DataGap)
- [ ] Stage history snapshot (future)

## Epic 5: Cross-sell & Suggestions
- [ ] Flow sinh draft service bổ sung khi 1 service Won
- [ ] Bảng gợi ý cross-sell (view hoặc Power BI)

## Epic 6: Reporting & KPI Dataset
- [ ] Dataset Power BI: FactOpportunityService, DimOpportunity, DimService, BridgeStakeholder
- [ ] Measures: PipelineTotalValue, AdjustedForecast, WinRate, CrossSellIndex, InfluenceCoverage
- [ ] Visuals & alerts triển khai theo spec reporting

## Epic 7: Alerts & Governance
- [ ] InfluenceScore < 30 alert
- [ ] Escalation khi tụt >20%
- [ ] Data completeness audit job

## Epic 8: Performance & Hardening
- [ ] Index các lookup nhiều truy vấn
- [ ] Kiểm tra ngưỡng số lượng item (>5k) & threshold plan
- [ ] Tối ưu batch update flows

## Epic 9: Continuous Improvement
- [ ] A/B test ngưỡng InfluenceScore
- [ ] Bổ sung ServiceCatalog chi tiết (phân rã category)
- [ ] Snapshot nightly historical trending

## Checklist kiểm thử
- [ ] Validate toàn bộ schema (tất cả lists liên quan)
- [ ] Deploy dev/test theo thứ tự dependency
- [ ] Kiểm thử flows (Influence, ServiceMix, Cross-sell)
- [ ] Kiểm thử phân quyền list & item-level
- [ ] Báo cáo Power BI hiển thị đủ measures
- [ ] Alerts gửi đúng điều kiện
- [ ] RiskFlags hiển thị & cập nhật chính xác
