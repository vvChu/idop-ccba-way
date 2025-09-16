# Module: Projects

## Bối cảnh & thuật ngữ CCBA

- Quản lý toàn bộ vòng đời dự án: khởi tạo, phê duyệt, thực thi, giám sát, nghiệm thu, đóng dự án.
- Thuật ngữ: Project Charter (Đề cương dự án), Work Package (Gói công việc), Milestone (Cột mốc), Stakeholder (Các bên liên quan), Project Status (Trạng thái dự án).

## Mục tiêu

- Đảm bảo mọi dự án được quản lý minh bạch, đúng quy trình, kiểm soát tiến độ, chi phí, chất lượng.
- Tích hợp dữ liệu dự án với các module tài chính, nhân sự, rủi ro.

## Phạm vi

- Khởi tạo, cập nhật, đóng dự án.
- Quản lý thông tin dự án, các gói công việc, milestone, thành viên, tài liệu liên quan.
- Theo dõi tiến độ, trạng thái, cảnh báo rủi ro/chậm tiến độ.

## User stories

- Là PMO, tôi muốn tạo mới dự án và phân công thành viên để khởi động dự án đúng quy trình.
- Là quản lý, tôi muốn theo dõi tiến độ, trạng thái các dự án để kịp thời điều phối nguồn lực.
- Là thành viên dự án, tôi muốn cập nhật tiến độ công việc, báo cáo vấn đề phát sinh.
- Là kiểm toán viên, tôi muốn truy xuất lịch sử thay đổi dự án để kiểm tra compliance.

## Acceptance criteria

- Người dùng có thể tạo, cập nhật, đóng dự án theo phân quyền.
- Hệ thống lưu lịch sử thay đổi, truy xuất được mọi trạng thái dự án.
- Có thể xuất báo cáo tiến độ, trạng thái, rủi ro dự án.
- Tích hợp: đồng bộ dữ liệu với module tài chính, nhân sự, rủi ro.
- Phân quyền: PMO (CRUD), Quản lý (Read/Approve), Thành viên (Update work), Kiểm toán viên (Read).

## Quy trình & BPMN

- Quy trình khởi tạo dự án: Nhập thông tin → Phê duyệt → Phân công thành viên → Khởi động dự án.
- Quy trình cập nhật tiến độ: Thành viên cập nhật → PMO kiểm tra → Lưu lịch sử → Cảnh báo nếu chậm tiến độ.
- Quy trình đóng dự án: Đánh giá nghiệm thu → Đóng dự án → Lưu trữ tài liệu.

## Ràng buộc & chỉ dẫn đặc thù

- Trigger: Khi tạo mới, cập nhật, đóng dự án hoặc milestone.
- Phân quyền: PMO (CRUD), Quản lý (Read/Approve), Thành viên (Update), Kiểm toán viên (Read).
- Tích hợp: SharePoint (tài liệu dự án), các module tài chính, nhân sự, rủi ro.
- Lookup: Project Type, Status, Stakeholder lấy từ taxonomy chuẩn của CCBA.
