
# Module: CRM (Quản lý Quan hệ Khách hàng)

## Mục tiêu
- Quản lý toàn bộ vòng đời khách hàng, cơ hội, liên hệ, giao dịch và lịch sử tương tác của CCBA.
- Hỗ trợ chu trình CRM → Hợp đồng → Dự án → Thực thi → Nghiệm thu → Thanh/Quyết toán.
- Tích hợp quy trình “Trình ký” và phê duyệt nhiều tầng cho các giao dịch quan trọng.
- Là nguồn dữ liệu đầu vào cho các module hợp đồng, dự án, tài chính, báo cáo.

## Phạm vi
- Quản lý danh sách khách hàng (doanh nghiệp, cá nhân, đối tác)
- Quản lý cơ hội kinh doanh (opportunities), pipeline bán hàng
- Quản lý liên hệ (contacts), vai trò, lịch sử tương tác
- Quản lý giao dịch, báo giá, hợp đồng liên quan đến khách hàng
- Tích hợp với các module: hợp đồng, dự án, tài chính, trình ký, Power BI

## User stories
- Là nhân viên kinh doanh, tôi muốn tạo mới và cập nhật thông tin khách hàng để theo dõi pipeline bán hàng.
- Là quản lý, tôi muốn xem báo cáo tổng hợp về cơ hội, tỷ lệ chuyển đổi, doanh thu dự kiến.
- Là nhân viên hỗ trợ, tôi muốn ghi nhận lịch sử tương tác với khách hàng để nâng cao chất lượng dịch vụ.
- Là trưởng phòng, tôi muốn phê duyệt các giao dịch lớn qua quy trình trình ký.
- Là ban giám đốc, tôi muốn truy xuất nhanh các hợp đồng, dự án liên quan đến từng khách hàng.

## Acceptance criteria
- Có thể tạo/sửa/xóa khách hàng, cơ hội, liên hệ, giao dịch.
- Có thể gắn nhãn, phân loại khách hàng theo taxonomy chuẩn (loại khách hàng, lĩnh vực, nguồn gốc...)
- Có thể theo dõi pipeline, trạng thái cơ hội, lịch sử chuyển đổi.
- Tích hợp quy trình phê duyệt (trình ký) cho giao dịch lớn.
- Dữ liệu CRM liên thông với module hợp đồng, dự án, tài chính.
- Có báo cáo tổng hợp, dashboard Power BI.

## Quy trình & BPMN
- Chu trình: Tiếp nhận khách hàng → Tạo cơ hội → Theo dõi pipeline → Giao dịch → Trình ký/phê duyệt → Ký hợp đồng → Bàn giao dự án.
- BPMN: Xem diagrams/CRM-pipeline.bpmn, diagrams/CRM-approval.bpmn

## Ràng buộc & chỉ dẫn đặc thù
- Phân quyền: Nhân viên chỉ xem/sửa khách hàng mình phụ trách; quản lý xem toàn bộ; trình ký theo ma trận vai trò.
- Tích hợp: Lookup liên kết với module hợp đồng, dự án, tài chính.
- Taxonomy: Chuẩn hóa các trường loại khách hàng, lĩnh vực, nguồn gốc theo termstore.
- Trigger: Tự động tạo cơ hội khi có khách hàng mới; tự động nhắc nhở khi pipeline quá hạn.
- Lưu vết: Ghi log mọi thay đổi, phục vụ kiểm toán nội bộ.
