
# Kế hoạch kỹ thuật — CRM

## Kiến trúc
- Sử dụng SharePoint Lists làm backend lưu trữ dữ liệu khách hàng, cơ hội, liên hệ, giao dịch.
- Tích hợp Power Automate cho các flow trình ký, nhắc nhở, tự động hóa pipeline.
- Power BI kết nối trực tiếp lists để tạo dashboard báo cáo.
- Lookup liên kết với lists hợp đồng, dự án, tài chính.

## Data model
- List: Customers (Khách hàng)
	- Trường: CustomerName, CustomerType (taxonomy), Industry (taxonomy), Source (taxonomy), Contacts (lookup), Opportunities (lookup) và các trường thuộc tính khác.
- List: Opportunities (Cơ hội)
	- Trường: OpportunityName, Customer (lookup), Stage (choice), Value, ExpectedCloseDate, Status và các trường thuộc tính khác.
- List: Contacts (Liên hệ)
	- Trường: ContactName, Role (taxonomy), Email, Phone, Customer (lookup) và các trường thuộc tính khác.
- List: Transactions (Giao dịch)
	- Trường: TransactionName, Opportunity (lookup), Amount, Status, ApprovalState và các trường thuộc tính khác.
- Chuẩn hóa các trường taxonomy: loại khách hàng, lĩnh vực, nguồn gốc, vai trò liên hệ.

## Flows
- Tự động tạo cơ hội khi có khách hàng mới.
- Flow trình ký/phê duyệt cho giao dịch lớn (Power Automate).
- Nhắc nhở pipeline quá hạn, tự động cập nhật trạng thái.
- Gửi email thông báo khi có thay đổi trạng thái cơ hội/giao dịch.

## Env & security
- Phân quyền theo vai trò: nhân viên, quản lý, ban giám đốc.
- Chỉ người phụ trách mới được sửa thông tin khách hàng/cơ hội mình quản lý.
- Lưu vết mọi thay đổi (audit log SharePoint).
- Bảo mật thông tin liên hệ, giao dịch theo quy định nội bộ.

## Tích hợp & cấu hình đặc thù
- Lookup liên kết lists hợp đồng, dự án, tài chính.
- Tích hợp Power Automate: trình ký, nhắc nhở, báo cáo tự động.
- Kết nối Power BI: dashboard pipeline, doanh thu, tỷ lệ chuyển đổi.
- Biến môi trường: endpoint API, connection reference cho Power Automate.
- Xử lý lỗi: log chi tiết, cảnh báo khi flow thất bại.

## Triển khai & kiểm thử
- Validate schema lists bằng script `validate-sp-schemas.js`.
- Triển khai lists bằng `.\idop.ps1 deploy lists -Environment Dev`.
- Kiểm thử flows Power Automate với dữ liệu mẫu.
- Kiểm thử phân quyền, audit log, báo cáo Power BI.
