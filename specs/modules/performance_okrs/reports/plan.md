# Kế hoạch Kỹ thuật — Reports (Báo cáo Hiệu suất & Phân tích OKR/KPI)

## Kiến trúc
- Kiến trúc báo cáo đa tầng kết hợp dữ liệu từ SharePoint Online Lists và Power BI Desktop / Power BI Service.
- Sử dụng Power BI Gateway để đồng bộ dữ liệu thời gian thực từ các List OKR, Nhân sự và Tài chính.
- Báo cáo phân quyền theo ma trận vai trò (Row-Level Security - RLS).

## Data model
- Data Model tổng hợp dạng Star Schema trong Power BI nối giữa Fact Table (`OKRSKeyResults`, `ScorecardData`, `SharedCostAllocations`) và Dimension Tables (`OKRSObjectives`, `Employees`, `Quarters`, `Projects`).

## Flows
- **Flow 1**: `PowerBI_Dataset_Refresh_Flow` — Kích hoạt làm mới dữ liệu báo cáo 4 lần/ngày.
- **Flow 2**: `Executive_Summary_Email_Flow` — Gửi email tóm tắt báo cáo OKRs quý cho Ban Giám đốc vào ngày 1 hàng tháng.

## Env & security
- Cấu hình Row-Level Security (RLS): Trưởng phòng chỉ xem dữ liệu phòng ban; PM xem dữ liệu dự án; BGD xem toàn bộ.
- Mã hóa dữ liệu trích xuất báo cáo cá nhân.

## Tích hợp & cấu hình đặc thù
- Tích hợp Power BI Embedded vào ứng dụng IDOP Portal.
- Trích xuất dữ liệu báo cáo dạng Excel và PDF theo mẫu chuẩn của Viện.

## Triển khai & kiểm thử
- Kiểm tra tính chính xác của các chỉ số DAX trong báo cáo Power BI.
- Xác minh quyền RLS đối với từng nhóm người dùng.
- Validation dữ liệu bằng `.\idop.ps1 validate datamodel`.
