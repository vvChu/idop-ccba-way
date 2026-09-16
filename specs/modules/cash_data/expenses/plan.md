# Kế hoạch Kỹ thuật Module: Expenses

## Kiến trúc
- Kiến trúc quản lý chi phí dự án và kiểm soát định mức chi tiêu nội bộ QCCTNB 3209.

## Data Model
- SharePoint Lists: `Expenses`, `ExpenseChecklists`.
- Foreign Lookup links: `Projects`.

## Flows
1. Khởi tạo Đề nghị thanh toán chi phí dự án (`Expenses`).
2. Kiểm tra danh mục chứng từ hợp lệ qua `ExpenseChecklists`.
3. Duyệt cấp Phòng/TPM và Kế toán TCKT.
4. Lãnh đạo CCBA / Viện phê duyệt lệnh chi và giải ngân.

## Env & Security
- Phân quyền theo Role Matrix: PM, TPM, TCKT, BGD Viện/CCBA.

## Tích hợp & Cấu hình Đặc thù
- Tự động áp dụng trần định mức: Phụ cấp lưu trú công tác tối đa 500.000đ/ngày, trang phục 5.000.000đ/năm, ăn ca 1.500.000đ/tháng.

## Triển khai & Kiểm thử
- Kiểm thử quy trình kiểm soát chứng từ và phát hiện cảnh báo chi vượt định mức.
