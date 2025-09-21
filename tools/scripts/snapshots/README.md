# Snapshots & History Scripts

## Scripts

- `export-opportunity-kpi-snapshot.ps1`: Xuất 3 file CSV (opportunities, services, stakeholders) có timestamp trong tên.
- `export-influence-history.ps1`: Append lịch sử InfluenceScore & AdjustedProbability theo thời gian vào `influence_history.csv`.

## Lịch gợi ý

| Tác vụ | Tần suất | Mục đích |
|-------|----------|----------|
| Influence history | Daily (22:00) | Theo dõi biến động tác động stakeholder |
| KPI snapshot | Weekly (Chủ nhật) | Báo cáo pipeline & cross-sell |

## Naming

- `opportunities_YYYYMMDD_HHMMSS.csv`
- `opportunity_services_YYYYMMDD_HHMMSS.csv`
- `opportunity_stakeholders_YYYYMMDD_HHMMSS.csv`
- `influence_history.csv` (append)

## PowerShell Scheduler (Task Scheduler example)

Tạo basic task chạy:

```
powershell.exe -ExecutionPolicy Bypass -File "<path>\export-influence-history.ps1" -Environment Prod
```

## Data Volume & Lưu Ý

- Khi `influence_history.csv` > 50MB: rotate (đổi tên `influence_history_<ts>.csv`) rồi tạo file mới.
- Có thể nén khoá (zip) các snapshot cũ theo tuần để giảm repository weight nếu commit.

## Roadmap

- Hợp nhất snapshot + influence vào một pipeline nếu cần.
- Thêm StageHistory export sau khi flow ghi dữ liệu vào list `OpportunityStageHistory`.
