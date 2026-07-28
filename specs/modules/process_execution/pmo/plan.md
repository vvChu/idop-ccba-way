# Kế hoạch Kỹ thuật Module: PMO

## Kiến trúc
- Hạ tầng kiến trúc SharePoint Online + IDOP Digital Platform.
- Phân luồng xử lý Phiếu giao việc (PGV) 4 luồng theo Điều 7 QCTK 2815.

## Data Model
- SharePoint Lists: `JobAssignments`, `AssignmentDetails`, `Activities`.
- Lookup links: `Projects`, `Employees`.

## Flows
1. Tiếp nhận Hợp đồng đã ký từ Step 2.
2. Lập Phiếu đề nghị PGV & Quyết định Giao việc.
3. Thẩm tra KHKT / Phòng TH và Phê duyệt Lãnh đạo Viện / BGD CCBA theo 4 luồng.
4. Đóng dấu TCHC và tự động tạo `JobAssignments`.

## Env & Security
- Phân quyền theo Role Matrix: Viện trưởng, BGD CCBA, KHKT, TPM, PM, Kỹ sư.
- Hỗ trợ ký số / ký điện tử trên chứng từ PGV.

## Tích hợp & Cấu hình Đặc thù
- Tự động áp dụng ma trận tỷ lệ giao khoán theo Bảng 1 QCTK 2815.
- Kết nối với Timesheet và Chấm công nhân sự.

## Triển khai & Kiểm thử
- Kiểm thử luồng phê duyệt PGV trên hệ thống staging.
- Kiểm tra tính đầy đủ của dữ liệu `JobAssignments` và `AssignmentDetails`.
