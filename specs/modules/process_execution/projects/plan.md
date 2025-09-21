# Kế hoạch kỹ thuật — Projects

## Kiến trúc

- Microservice quản lý vòng đời dự án, tích hợp SharePoint (tài liệu), các module tài chính, nhân sự, rủi ro.
- Sử dụng Power Automate để trigger phê duyệt, cảnh báo tiến độ, đóng dự án.
- **Đã triển khai:** SharePoint Lists infrastructure hoàn chỉnh trên Dev và Test environments.

## Data model

- **Projects List:** { ProjectCode, ProjectName, ContractId, Status, StartDate, EndDate, Owner, Budget, Description }
- **WorkPackages List:** { PackageName, ProjectId, Assignee, Status, StartDate, EndDate, Progress }
- **ProjectHistory List:** { ProjectId, Action, Actor, Timestamp, Details }
- **Lookup fields:** Status, ProjectType từ taxonomy chuẩn CCBA
- **Đã triển khai:** 49 SharePoint Lists với đầy đủ schema và relationships

## Flows

- Khởi tạo dự án: UI nhập liệu → Phê duyệt → Lưu vào hệ thống → Phân công thành viên.
- Cập nhật tiến độ: Thành viên cập nhật → PMO kiểm tra → Lưu lịch sử → Cảnh báo nếu chậm tiến độ.
- Đóng dự án: Đánh giá nghiệm thu → Đóng dự án → Lưu trữ tài liệu.

## Env & security

- **Environments:** Dev (ibstbim.sharepoint.com/sites/idop-dev), Test (ibstbim.sharepoint.com/sites/idop-test), Prod (ibstbim.sharepoint.com/sites/idop-prod)
- **Client ID:** 90ded6f0-b787-4b3c-acea-8baf6403fd63 (đã đăng ký)
- **Biến môi trường:** SHAREPOINT_URL, TENANT_ID, ENVIRONMENT_ID, FINANCE_API_URL, HR_API_URL.
- **Phân quyền:** PMO (CRUD), Quản lý (Read/Approve), Thành viên (Update), Kiểm toán viên (Read).
- **Audit log:** Ghi nhận mọi thao tác tạo/cập nhật/đóng dự án, thay đổi trạng thái.

## Tích hợp & cấu hình đặc thù

- **SharePoint Integration:** Đã triển khai 49 lists với PnP.PowerShell
- **API:** Kết nối SharePoint (tài liệu), các module tài chính, nhân sự, rủi ro.
- **Power Automate:** Trigger phê duyệt, cảnh báo tiến độ, đóng dự án.
- **Connection refs:** Sử dụng managed identity cho kết nối bảo mật.
- **Taxonomy:** Đã triển khai TermStore với các terms chuẩn CCBA

## Triển khai & kiểm thử

- **Infrastructure:** ✅ SharePoint Lists deployed to Dev (42 lists) and Test (49 lists)
- **Unit test:** Kiểm thử logic cập nhật trạng thái, validate dữ liệu đầu vào.
- **Integration test:** Kiểm thử kết nối SharePoint, các API tài chính, nhân sự, rủi ro.
- **Manual test:** Kiểm thử UI, phân quyền, quy trình nghiệp vụ.
- **Checklist:** Đảm bảo mọi trạng thái, lịch sử dự án đều truy xuất được, báo cáo xuất đúng chuẩn.

## Next Steps Implementation

1. **Phase 1:** Phát triển UI forms cho Projects (SharePoint forms + Power Apps)
2. **Phase 2:** Implement Power Automate workflows cho approval và notifications
3. **Phase 3:** Tích hợp với Finance và HR modules
4. **Phase 4:** Build Power BI dashboards cho project monitoring
5. **Phase 5:** Implement audit logging và compliance features
