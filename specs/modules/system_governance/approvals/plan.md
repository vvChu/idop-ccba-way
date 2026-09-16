# Kế hoạch Kỹ thuật — Approvals (Engine Trình ký & Phê duyệt Đa cấp)

## Kiến trúc
- Engine phê duyệt đa cấp linh hoạt áp dụng mô hình Polymorphic Soft Key thông qua danh sách `Submissions` (`RelatedEntity`, `RelatedId`).
- Luồng duyệt 05 cấp theo QCTK 2815 định nghĩa trong `ApprovalWorkflows`, `ApprovalNodes`, `ApprovalHistories` và `ApprovalDelegations`.
- Xử lý phê duyệt qua Power Automate Cloud Flows và Push Notification trên Mobile App.

## Data model
- Danh sách `Submissions`: Lưu trữ thông tin hồ sơ trình ký.
- Danh sách `ApprovalWorkflows`: Khai báo quy trình duyệt và số bước.
- Danh sách mở rộng: `ApprovalNodes` (Định nghĩa nút duyệt), `ApprovalHistories` (Nhật ký duyệt), `ApprovalDelegations` (Ủy quyền).

## Flows
- **Flow 1**: `Master_Approval_Engine_Flow` — Luồng xử lý trình ký chính, điều hướng hồ sơ qua 5 cấp duyệt, kiểm tra ủy quyền và trigger cập nhật thực thể gốc.
- **Flow 2**: `Approval_Reminder_Flow` — Nhắc nhở người duyệt khi hồ sơ quá hạn thụ lý.

## Env & security
- Bảo mật chữ ký số và nhật ký phê duyệt chống chối bỏ.
- Phân quyền thao tác nút duyệt chính xác theo danh tính người duyệt hiện tại.

## Tích hợp & cấu hình đặc thù
- Tích hợp polymorphic với `Contracts`, `Invoices`, `Expenses`, `Projects`.
- Áp dụng Taxonomy `CCBA_TrangThaiPheDuyet` để quản lý trạng thái hồ sơ.

## Triển khai & kiểm thử
- Chạy thử luồng trình ký Hợp đồng 5 cấp và xác minh tính hoạt động của ủy quyền `ApprovalDelegations`.
- Thẩm định dữ liệu lưu vết trong `ApprovalHistories`.
- Chạy `.\idop.ps1 validate datamodel`.
