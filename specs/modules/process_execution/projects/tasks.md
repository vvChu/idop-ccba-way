# Backlog — Projects

## Business & User Tasks

- [x] **Infrastructure Ready:** SharePoint Lists deployed to Dev (42 lists) and Test (49 lists)
- [ ] Thiết kế UI khởi tạo, cập nhật, đóng dự án (SharePoint forms + Power Apps)
- [ ] Xây dựng chức năng phân công thành viên, quản lý milestone, work package
- [ ] Phân quyền thao tác cho PMO, quản lý, thành viên, kiểm toán viên
- [ ] Tích hợp truy xuất lịch sử dự án, xuất báo cáo tiến độ, trạng thái

## Technical Tasks

- [x] **Data Model Complete:** Projects, WorkPackages, ProjectHistory lists created with proper schema
- [x] **Environment Setup:** IDOP environment configured with Client ID c055c7a4-9150-4bd5-bf01-445c65467feb
- [ ] Xây dựng API quản lý Project, WorkPackage, Milestone, ProjectHistory
- [ ] Thiết lập Power Automate trigger phê duyệt, cảnh báo tiến độ, đóng dự án
- [ ] Xây dựng data model Project, WorkPackage, Milestone, ProjectHistory
- [ ] Áp dụng managed identity cho kết nối bảo mật

## Implementation Tasks (Phase 1)

- [ ] **Create Project Form:** Customize SharePoint form for Projects list with validation
- [ ] **Work Package Management:** Implement sub-forms for managing work packages within projects
- [ ] **Status Workflow:** Configure choice fields and validation for project status transitions
- [ ] **User Assignment:** Set up People Picker fields for project owners and team members
- [ ] **Date Validation:** Implement date range validation for project start/end dates
- [ ] **Budget Integration:** Connect with Financial Plans list for budget tracking

## Power Automate Integration (Phase 2)

- [ ] **Approval Workflow:** Create flow for project approval process (PMO → Manager → Director)
- [ ] **Progress Alerts:** Set up automated notifications for milestone deadlines
- [ ] **Status Change Triggers:** Automate notifications on project status changes
- [ ] **Team Notifications:** Send alerts to assigned team members
- [ ] **Escalation Rules:** Configure automatic escalation for overdue tasks

## Testing & Validation

- [ ] Unit test logic cập nhật trạng thái, validate dữ liệu đầu vào
- [ ] Integration test kết nối SharePoint, các API tài chính, nhân sự, rủi ro
- [ ] Manual test UI, phân quyền, quy trình nghiệp vụ
- [ ] Kiểm thử xuất báo cáo, truy xuất lịch sử

## Checklist

- [x] SharePoint Lists infrastructure deployed
- [ ] Tạo mới dự án
- [ ] Cập nhật trạng thái, tiến độ dự án
- [ ] Quản lý milestone, work package
- [ ] Lưu và truy xuất lịch sử dự án
- [ ] Xuất báo cáo tiến độ, trạng thái
- [ ] Kiểm thử phân quyền, audit log

## Dependencies & Prerequisites

- ✅ **SharePoint Site:** idop-dev.sharepoint.com and idop-test.sharepoint.com configured
- ✅ **Client ID:** c055c7a4-9150-4bd5-bf01-445c65467feb registered and authorized
- ✅ **PnP.PowerShell:** Module installed and configured
- ✅ **Taxonomy:** TermStore deployed with project-related terms
- ⏳ **Power Automate:** License and environment setup needed
- ⏳ **Power BI:** Pro license for dashboard development
- ⏳ **Azure AD Groups:** Security groups for role-based access
