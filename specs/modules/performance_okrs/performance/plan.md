# Kế hoạch Kỹ thuật — Performance (Đánh giá Hiệu suất OKR/KPI & Quỹ thưởng Tầng 3)

## Kiến trúc
- Kiến trúc lưu trữ và tính toán điểm OKR/KPI trên 5 SharePoint Lists (`OKRSObjectives`, `OKRSKeyResults`, `Measurables`, `Quarters`, `ScorecardData`).
- Engine tính toán tự động tỷ lệ hoàn thành OKR và điểm KPI bằng Azure Functions / Power Automate Scheduled Cloud Flows.
- Tích hợp công thức tính thưởng Quỹ sản xuất Tầng 3 theo QCCTNB 3209.

## Data model
- Liên kết hierarchical: `Quarters` -> `OKRSObjectives` -> `OKRSKeyResults`.
- Thẻ điểm `ScorecardData` liên kết chỉ số `Measurables` qua Lookup `MetricId`.

## Flows
- **Flow 1**: `Quarterly_OKR_Snapshot_Flow` — Khóa điểm OKRs/KPIs cuối quý và snapshot dữ liệu để tính toán quỹ thưởng Tầng 3.
- **Flow 2**: `Scorecard_Reminder_Flow` — Gửi thông báo nhắc nhở cập nhật chỉ số Scorecard định kỳ hàng tuần/tháng.

## Env & security
- Phân quyền: `CCBA_Board_Of_Directors` & `CCBA_HR` (Full View & Approve), `CCBA_Heads_Of_Dept` (Manage Dept OKRs), `CCBA_Staff` (Edit Assigned KeyResults).
- Đóng băng dữ liệu đánh giá sau khi BGD phê duyệt.

## Tích hợp & cấu hình đặc thù
- Liên thông với Module `cash_data` (`SharedCostAllocations`) để lấy tổng Quỹ thưởng Tầng 3 thực tế trích lập từ doanh thu hợp đồng.

## Triển khai & kiểm thử
- Kiểm thử thuật toán tính toán tỷ lệ hoàn thành OKR và tiền thưởng Tầng 3.
- Kiểm tra tính chính xác của các trường Lookup trong hệ thống OKR.
- Validation bằng `.\idop.ps1 validate datamodel`.
