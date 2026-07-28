# Kế hoạch Kỹ thuật — Forms (Biểu mẫu Động & Cấu hình Hệ thống)

## Kiến trúc
- Dynamic Form Engine xây dựng trên nền tảng React / PCF Component đọc cấu hình trực tiếp từ `DynamicForms` và `SystemSettings`.
- Quản lý quy tắc validation client-side và server-side liên thông với `EnvironmentVariables`.
- Tự động sinh giao diện form và ánh xạ dữ liệu 1-1 với SharePoint Target Lists.

## Data model
- Danh sách `EnvironmentVariables`: Lưu trữ biến cấu hình quy tắc form.
- Danh sách mở rộng `DynamicForms`: Lưu trữ cấu trúc JSON Schema layout.
- Danh sách mở rộng `SystemSettings`: Lưu trữ thiết lập ứng dụng toàn hệ thống.

## Flows
- **Flow 1**: `Form_Schema_Validation_Flow` — Kiểm tra tính hợp lệ của cấu trúc JSON Schema khi Admin tạo form mới.
- **Flow 2**: `Form_Submission_Processor` — Tiếp nhận dữ liệu submit từ Form và cập nhật vào Target List tương ứng.

## Env & security
- Xử lý sanitize dữ liệu chống XSS và Injection.
- Phân quyền khởi tạo và cấu hình form cho `CCBA_System_Administrators`.

## Tích hợp & cấu hình đặc thù
- Tích hợp với tất cả các SharePoint Lists thuộc 6 modules IDOP.
- Tự động hiển thị các điều khiển nhập liệu chuyên dụng (Datepicker, Lookup picker, Taxonomy TreeView).

## Triển khai & kiểm thử
- Thử nghiệm render biểu mẫu động và submit dữ liệu vào SharePoint Lists.
- Kiểm tra tính hoạt động của các quy tắc validation.
- Chạy validation `.\idop.ps1 validate datamodel`.
