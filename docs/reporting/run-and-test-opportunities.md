# Hướng dẫn chạy & kiểm thử Opportunities Module

## 1. Triển khai Lists
```powershell
# Dry-run để kiểm tra schema
.\idop.ps1 deploy lists -Environment Dev -DryRun
# Triển khai thực tế (bao gồm fields mới MultiChoice & Note)
.\idop.ps1 deploy lists -Environment Dev
```
Xác nhận log: không lỗi cho các trường: AdjustedProbability, InfluenceScore, RiskFlags, ServiceMixSummary.

## 2. Seed Dữ Liệu Mẫu
- Customers: tạo 2 record (A, B)
- Opportunities: tạo 3 cơ hội (1 multi-service, 1 thiếu Decision Maker, 1 có stakeholder Opposed)
- ServiceCatalog: khai báo tối thiểu 3 dịch vụ
- OpportunityServices: gán 2–3 lines cho cơ hội multi-service
- OpportunityStakeholders: gán đủ vai trò cho 1 cơ hội, thiếu cho 1 cơ hội, có Opposed cho 1 cơ hội

## 3. Kiểm thử Flows (sau khi implement)
1. InfluenceScore: chỉnh SupportLevel từ Neutral → Champion → Opposed và quan sát AdjustedProbability thay đổi.
2. ServiceMixSummary: thêm/xóa 1 OpportunityService -> summary cập nhật.
3. Cross-sell: đánh dấu 1 service Won -> flow sinh draft line (nếu còn dịch vụ liên quan).
4. RiskFlags: thiếu Decision Maker ở Negotiation -> hiển thị MissingRoles.

## 4. Báo cáo Power BI
- Kết nối SharePoint lists: Opportunities, OpportunityServices, OpportunityStakeholders, ServiceCatalog
- Tạo measures theo file `opportunity-kpi-model.md`
- Visual kiểm thử: Funnel, Matrix ServiceType x Stage, Scatter Influence vs AdjustedProbability

## 5. Alerts (Logic Manual Until Automated)
- Giảm InfluenceScore < 30 ở Stage Proposal -> đánh dấu cảnh báo (ghi chú hoặc gửi mail thủ công kiểm tra)
- Opposed stakeholder InfluenceWeight >=4 -> RiskFlags có StakeholderOpposition

## 6. Hiệu Năng & Giới Hạn
- Kiểm tra tổng lookup mỗi list (< 12)
- Đảm bảo không vượt threshold 5000 items trong 3 tháng đầu (giám sát growth)

## 7. Checklist Hoàn Thành
- [ ] Tất cả fields tạo không lỗi
- [ ] CRUD cơ bản hoạt động
- [ ] Flows tính toán hoạt động đúng (manual hoặc thực tế)
- [ ] Báo cáo hiển thị đủ KPIs
- [ ] RiskFlags cập nhật đúng tình huống
- [ ] Không có lỗi permission

## 8. Lộ Trình Prod
- Sau khi QA pass trên Dev -> replicate Test -> cuối cùng Prod
- Sao lưu taxonomy trước khi deploy Prod
- Ghi lại InfluenceScore baseline (snapshot CSV) trước tuning
