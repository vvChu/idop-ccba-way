# Kế hoạch Kỹ thuật — HR (Quản lý Nhân sự & Bảng chấm công)

## Kiến trúc
- Sử dụng mô hình Hub & Spoke trên nền tảng SharePoint Online và Power Platform.
- Lớp dữ liệu (Data Layer): Lưu trữ trên 10 SharePoint Lists chuẩn hóa (`Employees`, `Departments`, `EmploymentContracts`, `Timesheets`, `ProjectMembers`, `EmployeeHistory`, `Certifications`, `BenefitPackages`, `EmployeeBenefits`, `Rewards`).
- Lớp nghiệp vụ (Logic Layer): Power Automate flows xử lý nhắc hạn hợp đồng lao động, phê duyệt timesheets và thông báo chứng chỉ sắp hết hạn.
- Lớp hiển thị (Presentation Layer): Canvas Apps / Power Apps Component Framework (PCF) cho giao diện chấm công và quản lý hồ sơ nhân sự.

## Data model
- Liên kết 1-to-1 giữa `Employees` và `Departments` qua Lookup `DepartmentId`.
- Quản lý trạng thái nhân sự qua Managed Metadata `Status` liên kết TermSet `CCBA_TrangThaiNhanSu`.
- Chấm công `Timesheets` liên kết `EmployeeId` (Lookup `Employees`) và `ProjectId` (Lookup `Projects`).
- Phân công dự án `ProjectMembers` lưu trữ vai trò nhân sự trong dự án.

## Flows
- **Flow 1**: `Timesheet_Approval_Flow` — Tự động gửi thông báo cho PM khi nhân viên gửi chấm công mới.
- **Flow 2**: `Contract_Expiration_Alert_Flow` — Quét hàng ngày gửi cảnh báo cho phòng TCHC trước 30 ngày khi `EmploymentContracts` sắp hết hạn.
- **Flow 3**: `Certification_Expiry_Flow` — Tự động nhắc nhở nhân sự gia hạn chứng chỉ chuyên môn trước 60 ngày.

## Env & security
- Cấu hình phân quyền SharePoint Groups: `CCBA_HR_Admins` (Edit/Manage), `CCBA_Project_Managers` (Approve Timesheets), `CCBA_All_Employees` (Read Self / Edit Timesheets).
- Sử dụng Environment Variables cho email thông báo và cấu hình hạn mức thời gian duyệt.

## Tích hợp & cấu hình đặc thù
- Tích hợp với Module `cash_data` để trích xuất chi phí nhân công từ `Timesheets` đã duyệt vào Hợp đồng.
- Tích hợp với Module `process_execution` để kiểm tra tư cách thành viên dự án (`ProjectMembers`).

## Triển khai & kiểm thử
- Kiểm thử đơn vị (Unit Test): Kiểm tra tính hợp lệ của các trường Lookup và Managed Metadata khi tạo nhân viên mới.
- Kiểm thử tích hợp (Integration Test): Chạy thử luồng tạo chấm công -> PM duyệt -> dữ liệu phản ánh vào chi phí dự án.
- Validate datamodel bằng `.\idop.ps1 validate datamodel`.
