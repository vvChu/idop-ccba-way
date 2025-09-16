# Kế hoạch kỹ thuật — Projects

## Kiến trúc

- Microservice quản lý vòng đời dự án, tích hợp SharePoint (tài liệu), các module tài chính, nhân sự, rủi ro.
- Sử dụng Power Automate để trigger phê duyệt, cảnh báo tiến độ, đóng dự án.

## Data model

- Project: { id, name, charter, type, status, startDate, endDate, owner, stakeholders, createdAt, updatedAt }
- WorkPackage: { id, projectId, name, description, assignee, status, startDate, endDate }
- Milestone: { id, projectId, name, dueDate, status }
- ProjectHistory: { id, projectId, action, actor, timestamp, detail }
- Lookup: ProjectType, Status, Stakeholder lấy từ taxonomy chuẩn CCBA.

## Flows

- Khởi tạo dự án: UI nhập liệu → Phê duyệt → Lưu vào hệ thống → Phân công thành viên.
- Cập nhật tiến độ: Thành viên cập nhật → PMO kiểm tra → Lưu lịch sử → Cảnh báo nếu chậm tiến độ.
- Đóng dự án: Đánh giá nghiệm thu → Đóng dự án → Lưu trữ tài liệu.

## Env & security

- Biến môi trường: SHAREPOINT_URL, TENANT_ID, ENVIRONMENT_ID, FINANCE_API_URL, HR_API_URL.
- Phân quyền: PMO (CRUD), Quản lý (Read/Approve), Thành viên (Update), Kiểm toán viên (Read).
- Audit log: Ghi nhận mọi thao tác tạo/cập nhật/đóng dự án, thay đổi trạng thái.

## Tích hợp & cấu hình đặc thù

- API: Kết nối SharePoint (tài liệu), các module tài chính, nhân sự, rủi ro.
- Power Automate: Trigger phê duyệt, cảnh báo tiến độ, đóng dự án.
- Connection refs: Sử dụng managed identity cho kết nối bảo mật.

## Triển khai & kiểm thử

- Unit test: Kiểm thử logic cập nhật trạng thái, validate dữ liệu đầu vào.
- Integration test: Kiểm thử kết nối SharePoint, các API tài chính, nhân sự, rủi ro.
- Manual test: Kiểm thử UI, phân quyền, quy trình nghiệp vụ.
- Checklist: Đảm bảo mọi trạng thái, lịch sử dự án đều truy xuất được, báo cáo xuất đúng chuẩn.
