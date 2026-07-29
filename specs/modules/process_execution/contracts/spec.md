# Đặc Tả Kỹ Thuật Module: Contracts (Quản lý Ký kết & Lưu trữ Hợp đồng Kinh tế)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý toàn bộ quy trình Trình ký, Ký kết, Phân cấp Ủy quyền và Lưu trữ Hợp đồng Kinh tế (HĐKT) của CCBA.
- Số hóa 100% Step 2 Trình ký Hợp đồng (`trinh_ky_hd`) trong Chuỗi 7 bước nghiệp vụ IDOP theo đúng quy định tại Điều 6 QCTK 2815.
- Quản lý chính xác thông tin tài chính hợp đồng và phân loại thẩm quyền ký kết (Viện ký vs Đơn vị phân cấp ký) dựa trên 2 luồng hợp đồng quy định tại Điều 6.1 QCTK 2815.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Phân loại thẩm quyền ký kết Hợp đồng theo hạn mức và loại hình (Điều 6.1 QCTK 2815): HĐ Nhóm 1, HĐ Kỹ thuật phức tạp, HĐ giá trị lớn (>= 2 tỷ kiểm định, >= 5 tỷ tư vấn, >= 10 tỷ thi công).
  - Quản lý 02 hình thức ký kết: Hợp đồng điện tử (Ký số) và Hợp đồng ký trực tiếp.
  - Quy trình lưu trữ hợp đồng trong vòng 30 ngày kể từ ngày ký đủ các bên (Điều 6.3 QCTK 2815).
  - Tích hợp 1-to-1 với SharePoint List `Contracts` (`datamodel/sharepoint/lists/process_execution/contracts.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Phân bổ kinh phí chi tiết (thực hiện ở module `process_execution/pmo`).
  - Xuất hóa đơn tài chính (thực hiện ở module `cash_data/finance`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
| US-CON-01 | `ROLE_PROJECT_MANAGER` — Chủ trì HĐ / Chủ nhiệm DA | Với tư cách Chủ trì HĐ / Chủ nhiệm DA, tôi muốn tạo Phiếu trình ký Hợp đồng kèm dự thảo HĐKT trên IDOP để bắt đầu quy trình trình ký | Điều 6.1 QCTK 2815 |
| US-CON-02 | `ROLE_HEAD_BIM_PROJECT` — Trưởng phòng BIM Dự án | Với tư cách Trưởng phòng BIM Dự án, tôi muốn kiểm tra nội dung kỹ thuật và giải pháp chuyên môn trong Hợp đồng trên IDOP để duyệt nội bộ | Điều 6.1 QCTK 2815 |
| US-CON-03 | `ROLE_LEGAL_QA` — Cố vấn Pháp lý, TC & QLCL | Với tư cách Cố vấn Pháp lý, TC & QLCL, tôi muốn thẩm định tính pháp lý của Hợp đồng trên IDOP để đảm bảo tuân thủ quy định | Điều 6.1 QCTK 2815 |
| US-CON-04 | `ROLE_ACCOUNTANT` — Phụ trách Kế toán Đơn vị | Với tư cách Phụ trách Kế toán Đơn vị, tôi muốn xem thông tin thanh toán của Hợp đồng trên IDOP để quản lý tài chính | Điều 6.1 QCTK 2815 |
| US-CON-05 | `ROLE_DIRECTOR` — Giám đốc Trung tâm | Với tư cách Giám đốc Trung tâm, tôi muốn phê duyệt Phiếu trình ký trên IDOP để xác nhận HĐ hoặc trình Viện ký | Điều 6.1 QCTK 2815 |
| US-CON-06 | `ROLE_HEAD_ADMIN` — Trưởng phòng Tổng Hợp | Với tư cách Trưởng phòng Tổng Hợp, tôi muốn cập nhật trạng thái lưu trữ, làm gateway đối ngoại với Viện trên IDOP để theo dõi HĐ | Điều 6.3 QCTK 2815 |

### 2.2 Ma trận Vai trò (Role Matrix)
> Tham chiếu SSOT: [06_ccba_org_role_matrix.md](../../../../.md/system_blueprint/06_ccba_org_role_matrix.md)
> Ký hiệu: C = Create, R = Read, U = Update, A = Approve, * = phạm vi giới hạn

| Vai trò | Quyền hạn | Ghi chú |
| :--- | :---: | :--- |
| `ROLE_DIRECTOR` | R, A | Xem và Phê duyệt HĐ (Ký hoặc trình Viện) |
| `ROLE_DEPUTY_DIRECTOR` | R, A | Ủy quyền từ GĐ |
| `ROLE_LEGAL_QA` | R, A | Thẩm định pháp lý (Approve) |
| `ROLE_HEAD_ADMIN` | R, U | Lưu trữ HĐ, cập nhật trạng thái đối ngoại |
| `ROLE_ACCOUNTANT` | R | Xem thông tin tài chính HĐ |
| `ROLE_HEAD_BIM_DESIGN` | R* | Xem HĐ thuộc phạm vi phòng |
| `ROLE_HEAD_BIM_PROJECT` | R* | Xem HĐ thuộc phạm vi phòng |
| `ROLE_PROJECT_MANAGER` | C, R, U | Soạn thảo, cập nhật dự thảo HĐ |
| `ROLE_STAFF` | R* | Xem HĐ dự án tham gia |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- Tham chiếu 05_ccba_ibst_boundary_map.md (Phần 4: Phân loại 2 Luồng Hợp đồng).
- **QCTK 2815**:
  - *Điều 4.2 & Điều 6.1 (Phân cấp & Ủy quyền ký Hợp đồng)*: 2 Luồng Hợp đồng: Viện Ký và Đơn vị phân cấp ký (CCBA ký).
  - *Điều 6.3 (Quy định lưu giữ Hợp đồng - Thời hạn 30 ngày)*.
- **QCCTNB 3209**: Quy định thuế suất GTGT (`VATRate`).

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow)

Tham chiếu file [05_ccba_ibst_boundary_map.md](../../../../.md/system_blueprint/05_ccba_ibst_boundary_map.md) Bước 2 & Phần 4 về 2 luồng hợp đồng.

1. **Khởi tạo Dự thảo Hợp đồng**: PM tạo `Contracts`.
2. **Duyệt Nội bộ & Thẩm định**: Cố vấn Pháp lý thẩm định pháp lý (`ROLE_LEGAL_QA`).
3. **Phê duyệt**: `ROLE_DIRECTOR` phê duyệt (Ký bằng pháp nhân CCBA) hoặc trình lãnh đạo Viện thông qua gateway `ROLE_HEAD_ADMIN`.
4. **Lưu trữ**: `ROLE_HEAD_ADMIN` thực hiện đóng dấu, lưu trữ bản cứng và lưu kho CDE trong vòng 30 ngày. 

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1
#### List: `Contracts` (`datamodel/sharepoint/lists/process_execution/contracts.json`)
| Field Name | Field Type | Required | Lookup / Taxonomy / Choices |
| :--- | :--- | :---: | :--- |
| `ContractCode` | Text | Yes | - |
| `ContractName` | Text | Yes | - |
| `CustomerId` | Lookup | No | List: `Customers`, Field: `ID` |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-CON-01**: `ContractCode` bắt buộc nhập và duy nhất.
- **AC-CON-04**: `Status` thuộc Taxonomy Group `CCBA_TrangThaiChung`. Chỉ khi `Status == "Đã ký"` mới cho lập PGV.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (SharePoint Groups)
Theo file 06_ccba_org_role_matrix.md:
- `CCBA_BanGiamDoc`: Full Control / Approve.
- `CCBA_Legal_QA`: Contribute + Approve (Thẩm định pháp lý).
- `CCBA_PhongTongHop`: Contribute + Manage (Quản lý hồ sơ, trạng thái đối ngoại).
- `CCBA_KeToan`: Read-only (Tài chính).
- `CCBA_ChuTri_All`: Contribute (Phạm vi dự án).
- `CCBA_VCNLD_All`: Read-only (Phạm vi dự án).

### 6.2 Nhật ký Kiểm toán (Audit Trail)
Ghi nhận `Created`, `Author`, `Modified`, `Editor` và `SystemVersion`.
