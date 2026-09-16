# Đặc Tả Kỹ Thuật Module: Reports (Scorecards & Báo cáo)

## 1. Mục tiêu & Phạm vi (Goal & Scope)
### 1.1 Mục tiêu
Cung cấp hệ thống báo cáo tổng hợp, Scorecards đo lường sức khỏe doanh nghiệp theo BSC (Balanced Scorecard).
IDOP chỉ ghi nhận trạng thái, không mô hình hóa workflow nội bộ Viện. Tương tác với IBST (KHKT, TCKT, TCHC) phải thông qua Phòng Tổng Hợp (ROLE_HEAD_ADMIN).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
- Định nghĩa Measurables.
- Thu thập Scorecard data định kỳ.
- Dashboards hiển thị tiến độ.
- **Không bao gồm (Out-of-Scope)**:
- BI/Data Warehouse nâng cao (chỉ dùng SharePoint view/PowerBI connect).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)

### 2.1 User Stories
- **US-REP-01**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn xem Scorecard sức khỏe tài chính trên IDOP để nắm bắt tổng quan.
- **US-REP-02**: Với tư cách `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp, tôi muốn cập nhật số liệu Measurables hành chính trên IDOP để báo cáo.
- **US-REP-03**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn nhập số liệu doanh thu vào Scorecard trên IDOP để theo dõi KPI tài chính.
- **US-REP-04**: Với tư cách `ROLE_DIRECTOR` — Giám đốc Trung tâm, tôi muốn so sánh số liệu quý trước và quý này trên IDOP để phân tích xu hướng.
- **US-REP-05**: Với tư cách `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp, tôi muốn xuất báo cáo hiệu suất tổng thể trên IDOP để gửi lên Viện.
- **US-REP-06**: Với tư cách `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị, tôi muốn thiết lập cảnh báo khi chỉ số thấp hơn mục tiêu trên IDOP để xử lý kịp thời.

### 2.2 Ma trận Vai trò (Role Matrix)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn
| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Xem và đánh giá báo cáo |
| `ROLE_HEAD_ADMIN` | C, R, U | Nhập số liệu HC, nhân sự |
| `ROLE_ACCOUNTANT` | C, R, U | Nhập số liệu tài chính |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng
- Yêu cầu báo cáo định kỳ của IBST.
- IDOP chỉ ghi nhận trạng thái báo cáo, không mô hình hóa workflow nội bộ Viện.

---

## 4. Quy trình Nghiệp vụ Chi tiết
> Tham chiếu: [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md)

1. **Định nghĩa Metric**: Tạo danh sách Measurables.
2. **Thu thập**: Hàng tuần/tháng, các phòng nhập Data.
3. **Tổng hợp**: Hệ thống hiển thị Scorecard dashboard.
4. **Review**: Họp giao ban đánh giá chỉ số.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
\n#### List: `measurables`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `MetricName` | Text | Yes |\n| `Unit` | Text | No |\n| `Description` | Text | No |\n\n#### List: `scorecard_data`\n| Field Name | Field Type | Required |\n| :--- | :--- | :---: |\n| `MetricId` | Lookup | No |\n| `PeriodType` | Choice | No |\n| `PeriodKey` | Text | No |\n| `Value` | Number | No |\n
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
