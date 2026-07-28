# Kế hoạch Kỹ thuật — Assets (Quản lý Tài sản & Bảo trì)

## Kiến trúc
- Kiến trúc lưu trữ danh mục tài sản `Assets` và nhật ký bảo trì `MaintenanceLogs` trên SharePoint Online Site `People_Assets`.
- Tích hợp Power Automate kích hoạt lịch bảo trì định kỳ cho các thiết bị đo đạc và máy tính cấu hình cao BIM.
- Giao diện quản lý quét mã QR Code / AssetCode trên ứng dụng di động Power Apps.

## Data model
- Danh sách `Assets`: Lưu thông tin tài sản, gán nhân sự `AssignedTo` (Lookup `Employees`) và trạng thái `Status` (ManagedMetadata `CCBA_TrangThaiTaiSan`).
- Danh sách `MaintenanceLogs`: Lưu vết lịch sử sửa chữa/bảo dưỡng liên kết `AssetId` (Lookup `Assets`).

## Flows
- **Flow 1**: `Asset_Maintenance_Scheduler` — Tự động thông báo cho phòng TCHC và KTDT khi thiết bị đến kỳ hiệu chuẩn/bảo dưỡng.
- **Flow 2**: `Asset_Handover_Flow` — Xác nhận bàn giao tài sản giữa phòng TCHC và cán bộ tiếp nhận `AssignedTo`.

## Env & security
- Phân quyền: `CCBA_Asset_Managers` (Full Control), `CCBA_Technical_Team` (Edit MaintenanceLogs), `CCBA_Employees` (Read Assigned Assets).
- Mã hóa thông tin cấu hình phần mềm bản quyền trong `EnvironmentVariables`.

## Tích hợp & cấu hình đặc thù
- Tích hợp API kiểm định thiết bị ngoài qua `IntegrationPoints`.
- Liên thông dữ liệu khấu hao tài sản với Module `cash_data`.

## Triển khai & kiểm thử
- Thử nghiệm tạo bản ghi tài sản và cập nhật nhật ký bảo trì.
- Kiểm tra tính toàn vẹn của liên kết Lookup giữa `Assets` và `MaintenanceLogs`.
- Chạy validation `.\idop.ps1 validate datamodel`.
