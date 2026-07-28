# Kế hoạch Kỹ thuật — Governance (Quản trị Hệ thống, Tham số & Phân quyền)

## Kiến trúc
- Quản trị cấu hình tập trung lưu tại `EnvironmentVariables` và `IntegrationPoints` trên SharePoint Site `System_Governance`.
- Mô hình phân quyền Role-Based Access Control (RBAC) đồng bộ giữa Entra ID (Azure AD), SharePoint Groups và Power Platform Environment Roles.
- Quản trị bộ từ khóa Taxonomy tập trung (CCBA Taxonomy) qua SharePoint TermStore Service.

## Data model
- Danh sách `EnvironmentVariables`: Khai báo biến hệ thống (`VariableName`, `Value`, `Description`).
- Danh sách `IntegrationPoints`: Khai báo kết nối API (`IntegrationName`, `SystemName`, `APIEndpoint`, `AuthMethod`).

## Flows
- **Flow 1**: `Config_Change_Audit_Flow` — Tự động thông báo và ghi log khi biến môi trường hoặc điểm tích hợp bị thay đổi.
- **Flow 2**: `Taxonomy_Sync_Flow` — Đồng bộ bộ từ khóa TermStore xuống các danh sách local.

## Env & security
- Chỉ có `CCBA_System_Administrators` mới có quyền truy cập cấu hình hệ thống.
- Sử dụng Azure Key Vault cho mã hóa secret key và phương thức xác thực API.

## Tích hợp & cấu hình đặc thù
- Tích hợp với tất cả 6 modules của IDOP-CCBA-WAY để cung cấp tham số toàn cục.
- Hỗ trợ REST API & Graph API trong tích hợp hệ thống ngoài.

## Triển khai & kiểm thử
- Kiểm tra tính hợp lệ của việc nạp biến môi trường vào các ứng dụng.
- Thử nghiệm kết nối tới các điểm tích hợp ngoài qua HTTPS.
- Chạy `.\idop.ps1 validate datamodel`.
