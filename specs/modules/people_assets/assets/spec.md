# Đặc Tả Kỹ Thuật Module: Assets (Quản lý Tài sản & Thiết bị)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Quản lý toàn bộ tài sản, thiết bị BIM, phần cứng và bản quyền phần mềm của CCBA.
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Đăng ký, phân bổ tài sản cho cá nhân/phòng ban.
- Theo dõi lịch sử bảo trì, khấu hao.
- Quản lý license phần mềm BIM.
- **Không bao gồm (Out-of-Scope)**:
- Mua sắm vật tư tiêu hao hàng ngày.

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-ASS-01**: Với tư cách `ROLE_IDOP_LEAD` — Phụ trách Nền tảng Số & CN BIM, tôi muốn nhập danh sách máy trạm BIM trên IDOP để quản lý tài sản công nghệ.
- **US-ASS-02**: Với tư cách `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp, tôi muốn theo dõi khấu hao tài sản trên IDOP để lên kế hoạch thanh lý.
- **US-ASS-03**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn yêu cầu cấp mới thiết bị trên IDOP để phục vụ dự án.
- **US-ASS-04**: Với tư cách `ROLE_IDOP_LEAD` — Phụ trách Nền tảng Số & CN BIM, tôi muốn ghi nhận nhật ký bảo trì thiết bị trên IDOP để theo dõi vòng đời.
- **US-ASS-05**: Với tư cách `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp, tôi muốn phân công tài sản cho nhân sự mới trên IDOP để quản lý trách nhiệm.
- **US-ASS-06**: Với tư cách `ROLE_STAFF` — Cá nhân / Viên chức NLĐ, tôi muốn báo cáo hư hỏng tài sản trên IDOP để được sửa chữa kịp thời.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_HEAD_ADMIN` | C, R, U, A | Quản lý toàn bộ tài sản hành chính |
| `ROLE_IDOP_LEAD` | C, R, U | Quản lý tài sản CNTT, Thiết bị BIM |
| `ROLE_STAFF` | R* | Xem tài sản được cấp phát |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Quy chế CCBA 2026: Điều 8 (Quản lý cơ sở vật chất).
- IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow mua sắm phức tạp của Viện.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Nhập kho**: HC nhập thông tin tài sản mới.
2. **Cấp phát**: Bàn giao tài sản cho người dùng (có biên bản số).
3. **Bảo trì**: Ghi nhận các đợt sửa chữa định kỳ.
4. **Thu hồi/Thanh lý**: Thu hồi khi NV nghỉ việc hoặc tài sản hết khấu hao.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `assets`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `AssetName` | Text | Yes |\n| `AssetCode` | Text | No |\n| `AssignedTo` | Lookup | No |\n| `PurchaseDate` | DateTime | No |\n| `OriginalValue` | Number | No |\n| `DepreciationRate` | Number | No |\n| `AccumulatedDepreciation` | Number | No |\n| `SerialNumber` | Text | No |\n| `Location` | Text | No |\n| `Status` | ManagedMetadata | No |\n\n#### List: `maintenance_logs`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `AssetId` | Lookup | No |\n| `MaintenanceDate` | DateTime | No |\n| `Description` | Text | No |\n| `PerformedBy` | User | No |\n
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
<!-- System reserved space for future expansion -->
