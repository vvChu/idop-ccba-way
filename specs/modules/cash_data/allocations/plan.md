# Kế hoạch Kỹ thuật Module: Allocations

## Kiến trúc
- Kiến trúc xử lý cơ chế tài chính 3 tầng dựa trên SharePoint Online + Power Automate / IDOP Financial Engine.

## Data Model
- SharePoint Lists: `AllocationRules`, `SharedCostAllocations`.
- Foreign Lookup links: `Expenses`.

## Flows
1. Tiếp nhận xác nhận tiền về từ Ngân hàng.
2. Áp dụng quy tắc phân bổ 3 tầng (Tier 1: Viện, Tier 2: Đơn vị/CCBA, Tier 3: Chủ trì/PM) theo Bảng 1 QCTK 2815.
3. Lập Tờ phân phối hợp đồng trình Lãnh đạo Viện duyệt.
4. Chuyển khoản giải ngân trong vòng 03 ngày làm việc.

## Env & Security
- Phân quyền theo Role Matrix: Lãnh đạo Viện, TCKT Viện, BGD CCBA, PM.

## Tích hợp & Cấu hình Đặc thù
- Khấu trừ tự động các khoản trích theo lương (23.5%) tại Tier 2.
- Giảm tỷ lệ giao khoán 0.5% nhóm 2, 0.2% nhóm 3-4 nếu HĐ do Viện ký.

## Triển khai & Kiểm thử
- Kiểm thử các công thức phân bổ với tất cả 10 nhóm Hợp đồng Bảng 1.
