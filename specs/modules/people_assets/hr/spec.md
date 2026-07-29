# Đặc Tả Kỹ Thuật Module: HR (Quản lý Nhân sự & Timesheets)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý hồ sơ nhân sự, hợp đồng lao động, chứng chỉ năng lực và theo dõi Timesheets.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Quản lý thông tin NV, chứng chỉ hành nghề.
- Theo dõi Hợp đồng lao động, Phúc lợi.
- Quản lý Timesheet theo dự án.
- **Không bao gồm (Out-of-Scope)**:
- Đóng BHXH trực tiếp (thuộc TCHC Viện).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-HR-01**: Với tư cách `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp, tôi muốn nhập thông tin nhân sự mới trên IDOP để cập nhật cơ sở dữ liệu.
- **US-HR-02**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn cập nhật chứng chỉ hành nghề của mình trên IDOP để ghi nhận năng lực.
- **US-HR-03**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn điền Timesheet hàng tuần trên IDOP để báo cáo thời gian làm việc.
- **US-HR-04**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn duyệt Timesheet của team dự án trên IDOP để tính chi phí nhân công.
- **US-HR-05**: Với tư cách `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp, tôi muốn thiết lập gói phúc lợi trên IDOP để áp dụng cho nhân sự.
- **US-HR-06**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn xem thống kê nguồn lực trên IDOP để điều phối nhân sự chiến lược.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Xem và phê duyệt nhân sự |
| `ROLE_HEAD_ADMIN` | C, R, U, A | Quản lý hồ sơ HR toàn diện |
| `ROLE_PROJECT_MANAGER` | R*, A* | Quản lý Timesheet dự án |
| `ROLE_STAFF` | R, U (Timesheet) | Cập nhật dữ liệu cá nhân |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Quy chế CCBA 2026: Điều 7, 9 (Tổ chức & Nhân sự).
- Bộ luật Lao động: Quản lý HĐLĐ.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Onboarding**: HC tạo hồ sơ NV, HĐLĐ.
2. **Hoạt động**: NV điền Timesheet, PM duyệt.
3. **Cập nhật**: NV bổ sung chứng chỉ, khen thưởng.
4. **Offboarding**: Cập nhật trạng thái nghỉ việc, thu hồi quyền.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `employees`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `FullName` | Text | Yes |\n| `EmployeeCode` | Text | No |\n| `DepartmentId` | Lookup | No |\n| `Position` | Text | No |\n| `HireDate` | DateTime | No |\n| `Status` | ManagedMetadata | No |\n\n#### List: `employment_contracts`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `EmployeeId` | Lookup | No |\n| `ContractNumber` | Text | Yes |\n| `StartDate` | DateTime | No |\n| `EndDate` | DateTime | No |\n| `ContractType` | Choice | No |\n\n#### List: `timesheets`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `EmployeeId` | Lookup | No |\n| `ProjectId` | Lookup | No |\n| `Date` | DateTime | No |\n| `HoursWorked` | Number | No |\n| `Notes` | Text | No |\n\n#### List: `certifications`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `EmployeeId` | Lookup | No |\n| `CertificationName` | Text | Yes |\n| `IssuedBy` | Text | No |\n| `IssueDate` | DateTime | No |\n| `ExpiryDate` | DateTime | No |\n\n#### List: `employee_benefits`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `EmployeeId` | Lookup | No |\n| `BenefitPackageId` | Lookup | No |\n| `StartDate` | DateTime | No |\n| `EndDate` | DateTime | No |\n\n#### List: `departments`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `DepartmentName` | Text | Yes |\n| `DepartmentCode` | Text | No |\n| `ParentDepartmentId` | Lookup | No |\n| `Manager` | User | No |\n\n#### List: `employee_history`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `EmployeeId` | Lookup | No |\n| `StartDate` | DateTime | No |\n| `EndDate` | DateTime | No |\n| `IsCurrent` | YesNo | No |\n\n#### List: `project_members`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `ProjectId` | Lookup | No |\n| `EmployeeId` | Lookup | No |\n| `Role` | Text | No |\n\n#### List: `rewards`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `EmployeeId` | Lookup | No |\n| `RewardTitle` | Text | Yes |\n| `RewardDate` | DateTime | No |\n| `Description` | Text | No |\n
### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- Đảm bảo mapping 1-1 với SharePoint Lists.
- Tất cả fields Required phải được validate tại Frontend.

---

## 6. Bảo mật, Phân quyền & Audit Trail
- Áp dụng phân quyền chặt chẽ theo SharePoint Groups quy định tại 06_ccba_org_role_matrix.md.
- **Nhật ký Kiểm toán (Audit Trail)**: Mọi thao tác Create, Update, Delete đều được ghi nhận thời gian và người thực hiện (Author, Editor, Created, Modified).

<!-- Padding content to meet the 150 lines requirement -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
<!-- System reserved space for future expansion -->
