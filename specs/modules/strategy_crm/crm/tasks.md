
# Backlog — CRM

## Epic 1: Quản lý khách hàng
- [ ] Thiết kế và triển khai list Customers với các trường taxonomy, lookup
- [ ] Tạo form nhập liệu khách hàng, phân quyền theo nhân viên phụ trách
- [ ] Kiểm thử tạo/sửa/xóa khách hàng, validate dữ liệu

## Epic 2: Quản lý cơ hội & pipeline
- [ ] Thiết kế list Opportunities, liên kết lookup với Customers
- [ ] Xây dựng flow tự động tạo cơ hội khi có khách hàng mới
- [ ] Kiểm thử pipeline, trạng thái, nhắc nhở quá hạn

## Epic 3: Quản lý liên hệ & giao dịch
- [ ] Thiết kế list Contacts, Transactions, liên kết lookup
- [ ] Tích hợp taxonomy vai trò liên hệ, trạng thái giao dịch
- [ ] Kiểm thử flows trình ký/phê duyệt giao dịch lớn

## Epic 4: Tích hợp báo cáo & trình ký
- [ ] Kết nối Power BI với lists CRM, tạo dashboard pipeline/doanh thu
- [ ] Tích hợp Power Automate cho trình ký, nhắc nhở, báo cáo tự động
- [ ] Kiểm thử báo cáo, flows, phân quyền

## Checklist kiểm thử
- [ ] Validate schema lists CRM
- [ ] Triển khai lists trên dev/test
- [ ] Kiểm thử flows Power Automate
- [ ] Kiểm thử phân quyền, audit log
- [ ] Kiểm thử báo cáo Power BI
