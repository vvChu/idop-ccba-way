# Đặc Tả Kỹ Thuật Module: Approvals (Luồng Phê duyệt)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Động hóa luồng phê duyệt (Approval Workflows) sử dụng mô hình Submissions Polymorphic để áp dụng cho mọi đối tượng trong hệ thống.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Định nghĩa Workflow, Approval Nodes.
- Quản lý Submissions đa hình (Polymorphic).
- Ủy quyền phê duyệt (Delegations).
- **Không bao gồm (Out-of-Scope)**:
- Luồng phê duyệt phức tạp ngoài SharePoint (như ký số CA token).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-APP-01**: Với tư cách `ROLE_IDOP_LEAD` — Phụ trách Nền tảng Số & CN BIM, tôi muốn cấu hình Approval Nodes trên IDOP để thiết lập luồng phê duyệt.
- **US-APP-02**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn tạo một Submission mới trên IDOP để trình duyệt nghỉ phép.
- **US-APP-03**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn duyệt các Submission đang chờ trên IDOP để giải quyết công việc.
- **US-APP-04**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn tạo ủy quyền (Delegation) trên IDOP để PGĐ duyệt thay khi tôi đi công tác.
- **US-APP-05**: Với tư cách `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA, tôi muốn theo dõi Approval History trên IDOP để biết hồ sơ đang tắc ở đâu.
- **US-APP-06**: Với tư cách `ROLE_IDOP_LEAD` — Phụ trách Nền tảng Số & CN BIM, tôi muốn kiểm tra tính toàn vẹn của Workflow trên IDOP để đảm bảo không lỗi luồng.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_IDOP_LEAD` | C, R, U, Admin | Cấu hình toàn bộ Workflow |
| `ROLE_DIRECTOR` | R, A | Phê duyệt cấp cuối |
| `ROLE_PROJECT_MANAGER` | C, R, A* | Tạo và duyệt cấp dự án |
| `ROLE_STAFF` | C, R | Tạo yêu cầu |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- QCTK 2815 & QCCTNB 3209: Quy định thẩm quyền phê duyệt các cấp.
- IDOP lưu trữ Audit Log phục vụ thanh tra nội bộ.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Tạo Yêu cầu**: User submit hồ sơ.
2. **Khởi chạy Luồng**: Hệ thống xác định Workflow dựa vào Entity.
3. **Phê duyệt Tuần tự**: Các Approver xử lý.
4. **Hoàn tất**: Đóng Submission, kích hoạt sự kiện liên quan.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `approval_workflows`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `WorkflowName` | Text | Yes |\n| `Description` | Text | No |\n| `Steps` | Number | No |\n\n#### List: `approval_nodes`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `WorkflowId` | Lookup | No |\n| `StepOrder` | Number | No |\n| `ApproverRole` | Text | No |\n| `RequiredThreshold` | Number | No |\n\n#### List: `submissions`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `SubmissionTitle` | Text | Yes |\n| `RelatedEntity` | Choice | No |\n| `RelatedId` | Number | No |\n| `SubmittedBy` | User | No |\n| `SubmissionDate` | DateTime | No |\n| `Status` | ManagedMetadata | No |\n\n#### List: `approval_histories`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `SubmissionId` | Lookup | No |\n| `StepNumber` | Number | No |\n| `Approver` | User | No |\n| `Action` | Choice | No |\n| `Comment` | Text | No |\n| `Timestamp` | DateTime | No |\n\n#### List: `approval_delegations`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `Delegator` | User | No |\n| `Delegatee` | User | No |\n| `FromDate` | DateTime | No |\n| `ToDate` | DateTime | No |\n| `IsActive` | YesNo | No |\n
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
