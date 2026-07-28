# Kế hoạch Kỹ thuật Module: Finance

## Kiến trúc
- Kiến trúc quản lý tài chính, hóa đơn GTGT và dòng tiền ngân hàng trên IDOP.

## Data Model
- SharePoint Lists: `FinancialPlans`, `InvoiceRequests`, `OutgoingInvoices`, `InputInvoices`, `BankAccounts`, `Vendors`.

## Flows
1. Lập Yêu cầu xuất hóa đơn từ Biên bản Nghiệm thu Step 6.
2. TCKT phát hành Hóa đơn GTGT đầu ra (`OutgoingInvoices`).
3. Đối soát tiền về tài khoản ngân hàng (`BankAccounts`).
4. Tiếp nhận Hóa đơn đầu vào (`InputInvoices`) từ `Vendors` và theo dõi công nợ.

## Env & Security
- Phân quyền theo Role Matrix: PM, TPM, TCKT Viện, KHKT Viện, BGD Viện/CCBA.

## Tích hợp & Cấu hình Đặc thù
- Quản lý nghĩa vụ thuế GTGT và cảnh báo nợ VAT quá 01 năm theo Điều 14.2 QCTK 2815.

## Triển khai & Kiểm thử
- Kiểm thử luồng xuất hóa đơn và đối soát công nợ tự động.
