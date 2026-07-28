# Đặc Tả Kỹ Thuật Module: Allocations (Cơ chế Phân bổ Kinh phí 3 Tầng & Quyết toán Hợp đồng)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Thiết lập quy tắc phân bổ tài chính 3 tầng (3-Tier Financial Allocation Mechanism) chính xác 100% theo Bảng 1 QCTK 2815 và QCCTNB 3209 cho tất cả các loại hình hợp đồng dịch vụ kỹ thuật của CCBA.
- Số hóa Step 7 Quyết toán & Phân phối Hợp đồng (`quyet_toan_thanh_ly`) trong Chuỗi 7 bước nghiệp vụ IDOP.
- Quản lý các quy tắc phân bổ (`AllocationRules`) và phân bổ chi phí chung (`SharedCostAllocations`) giữa các đơn vị chủ trì, đơn vị phối hợp và các cá nhân tham gia thực hiện dự án.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Công thức tính toán và phân bổ chi tiết 3 Tầng tài chính:
    - **Tier 1 (Thu hồi tại Viện)**: Chi phí quản lý Viện (`CPQL Viện`), Khấu hao tài sản cố định Viện (`KHTSCĐ Viện`), Thuế GTGT (`VATRate`).
    - **Tier 2 (Giao kinh phí quản lý Đơn vị CCBA)**: Chi phí quản lý đơn vị (`CPQL Đơn vị`), Trích nộp bảo hiểm theo lương (23.5%), Thu nhập dịch vụ Ban Giám đốc và bộ phận Tổng hợp đơn vị.
    - **Tier 3 (Giao kinh phí thực hiện cho Chủ trì / PM)**: Kinh phí giao Chủ trì chi trả nhân công, máy móc thiết bị, vật liệu và chi phí thực hiện trực tiếp.
  - Ma trận tỷ lệ giao khoán theo Bảng 1 QCTK 2815 cho 10 nhóm Hợp đồng kỹ thuật (N1a, N1b, N2a, N2b, N2c, N2d, N2e, N2f, N2g, N3, N4).
  - Tích hợp 1-to-1 với SharePoint Lists: `AllocationRules` (`datamodel/sharepoint/lists/cash_data/allocation_rules.json`) và `SharedCostAllocations` (`datamodel/sharepoint/lists/cash_data/shared_cost_allocations.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Phát hành hóa đơn VAT đầu ra (thực hiện ở submodule `cash_data/finance`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-ALC-01**: Là *Phụ trách Kế toán CCBA*, tôi muốn áp dụng đúng Quy tắc phân bổ (`AllocationRules`) cho hợp đồng tư vấn BIM (Nhóm N2a: Chủ trì 78%, Đơn vị 13%, Viện CPQL 7%, Viện KHTSCĐ 2%).
- **US-ALC-02**: Là *Chủ trì Hợp đồng / PM*, tôi muốn xem bản tính Tờ phân phối hợp đồng 3 tầng để biết chính xác phần kinh phí giao khoán thực hiện Hợp đồng (Tier 3) được giải ngân.
- **US-ALC-03**: Là *Phòng Tài chính - Kế toán (TCKT Viện)*, tôi kiểm tra và trình Lãnh đạo Viện phê duyệt Tờ phân phối quyết toán hợp đồng trong vòng 03 ngày làm việc kể từ khi tiền về (Điều 11.1 QCTK 2815).
- **US-ALC-04**: Là *Trưởng đơn vị phối hợp trong Viện*, tôi muốn đối soát tỷ lệ phân chia kinh phí quản lý chung giữa đơn vị chủ trì và đơn vị phối hợp đã thỏa thuận trên Phiếu giao việc (PGV).
- **US-ALC-05**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi duyệt Tờ phân phối hợp đồng và theo dõi báo cáo trích nộp CPQL Viện/CCBA hàng tháng.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (BHXH trích lương) | - | - | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | - | R (Toàn Viện) | U (Đối soát tỷ lệ) | - | - | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | C | R (Toàn Viện) | U (Tính phân phối 3 Tầng) | - | A (Phân phối Viện) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Đề xuất phân chia) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Duyệt Phân phối) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | - | R (Hợp đồng giao) | U (Tờ phân phối PM) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Phân bổ phòng) | - | A (Duyệt Tờ PP Đơn vị) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 7.7*: Kinh phí giao thực hiện hợp đồng tính trên giá trị hợp đồng trước thuế GTGT lấy theo Bảng 1.
  - *Điều 11 (Step 7 Operational Flow)*: Quyết toán và phân phối hợp đồng. TCKT giải ngân trong vòng không quá 03 ngày làm việc kể từ khi đủ hồ sơ chứng từ và tiền về tài khoản.
  - *Điều 12 & BẢNG 1 (Chi tiết Định mức Phân bổ Kinh phí 3 Tầng)*:

| Nhóm HĐ | Nội dung loại HĐKT | Tier 3: Kinh phí Giao Chủ trì (%) | Tier 2: Kinh phí Giao Đơn vị (%) | Tổng Giao Đơn vị (%) | Tier 1: Viện CPQL, LN (%) | Tier 1: Viện KHTSCĐ (%) | Thuế GTGT (%) |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **N1a** | Giám định XD, kiểm định đánh giá sự cố theo yêu cầu QLNN | 89.00 | 7.00 | **96.00** | 2.00 | 2.00 | 10% |
| **N1b** | Nhiệm vụ QLNN Bộ/Ngành kinh phí cấp trực tiếp | Thực thanh thực chi theo dự toán được duyệt | - | - | 0 | 0 | 0% |
| **N2a** | TVQLDA, Tư vấn đầu tư XD, Chuyển giao công nghệ | 78.00 | 13.00 | **91.00** | 7.00 | 2.00 | 10% |
| **N2b** | Chứng nhận HCHQ, Hiệu chuẩn thiết bị | 72.00 | 13.00 | **85.00** | 13.00 | 2.00 | 5% |
| **N2c** | Tập huấn, đào tạo | 70.00 | 15.00 | **85.00** | 13.00 | 2.00 | 0% |
| **N2d** | Khảo sát XD, kiểm định CLCT, quan trắc, trắc đạc, TN hiện trường | 77.00 | 10.00 | **87.00** | 8.00 | 5.00 | 10% |
| **N2e** | TN VL tại phòng TN hiện trường, TN cấu kiện trong phòng | 72.00 | 10.00 | **82.00** | 8.00 | 10.00 | 10% |
| **N2f** | Thí nghiệm VL trong phòng | 59.00 | 15.00 | **74.00** | 16.00 | 10.00 | 10% |
| **N2g** | Thí nghiệm đặc thù (chịu lửa, hệ bao che, thổi khí, động đất) | 81.00 | 10.00 | **91.00** | 6.00 | 3.00 | 10% |
| **N3** | Thi công xây dựng | 89.00 | 6.00 | **95.00** | 4.50 | 0.50 | 10% |
| **N4** | Cung ứng vật tư, máy móc, thiết bị | 92.00 | 4.00 | **96.00** | 3.50 | 0.50 | 10% |

  - *Ghi chú Bảng 1*:
    - *HĐ Thầu phụ*: Viện giao đơn vị 97%, giữ lại 3% nếu HĐ ký tại Viện; Viện giao đơn vị 99%, giữ lại 1% nếu HĐ ký tại đơn vị.
    - *HĐ không thuộc nhóm 1 do Viện ký*: Giảm 0.5% với nhóm 2 (Chủ trì 0.3%, Đơn vị 0.2%); Giảm 0.2% với nhóm 3, 4 (Chủ trì 0.1%, Đơn vị 0.1%).
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Quy định trích nộp các khoản bảo hiểm (23.5%) tính trên tiền lương cấp bậc từ nguồn kinh phí giao quản lý tại đơn vị (Tier 2).

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Step 7 Quyết toán & Phân phối Kinh phí 3 Tầng

```
[Xác nhận Tiền về Tài khoản Viện] -> [Tra cứu Tỷ lệ Bảng 1 QCTK] -> [Tính toán Tờ phân phối 3 Tầng] -> [TCKT & Lãnh đạo Viện Phê duyệt] -> [Chuyển khoản Giải ngân (Trong 03 ngày)]
```

1. **Bước 7.1: Xác nhận Tiền về**:
   - Phòng TCKT nhận báo Có từ Ngân hàng (`BankAccounts`), ghi nhận số tiền thực nộp của Bên A cho Hợp đồng.
2. **Bước 7.2: Áp dụng Quy tắc Phân bổ (`AllocationRules`)**:
   - Căn cứ Loại hình Hợp đồng (N1a -> N4) và Cấp ký (Viện ký hay Đơn vị ký), hệ thống áp dụng bảng tỷ lệ phân bổ 3 Tầng chuẩn.
3. **Bước 7.3: Lập Tờ phân phối Hợp đồng 3 Tầng**:
   - **Tier 1 (Viện)** = `NetAmount` * (% CPQL Viện + % KHTSCĐ Viện) + (`NetAmount` * % VAT).
   - **Tier 2 (CCBA)** = `NetAmount` * % CPQL Đơn vị.
   - **Tier 3 (PM/Chủ trì)** = `NetAmount` * % Kinh phí Giao Chủ trì.
4. **Bước 7.4: Phê duyệt & Giải ngân (Thời hạn 03 ngày)**:
   - TCKT trình Lãnh đạo Viện duyệt Tờ phân phối.
   - Thực hiện chuyển khoản giải ngân kinh phí về tài khoản CCBA (Tier 2) và Chủ trì/PM (Tier 3).

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `AllocationRules` (`datamodel/sharepoint/lists/cash_data/allocation_rules.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `RuleName` | Text | Yes | - | Tên quy tắc phân bổ (ví dụ: Quy tắc Bảng 1 - HĐ Nhóm N2a) |
| `Description` | Text | No | - | Mô tả chi tiết tỷ lệ phân bổ Tier 1, Tier 2, Tier 3 |

#### List 2: `SharedCostAllocations` (`datamodel/sharepoint/lists/cash_data/shared_cost_allocations.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ExpenseId` | Lookup | No | List: `Expenses`, Field: `ID` | Liên kết đến Chi phí cần phân bổ |
| `AllocationRuleId` | Lookup | No | List: `AllocationRules`, Field: `ID` | Liên kết đến Quy tắc phân bổ áp dụng |
| `Amount` | Number | No | - | Số tiền phân bổ chi tiết (VND) |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-ALC-01**: Tổng tỷ lệ phân bổ của Tier 1 + Tier 2 + Tier 3 bắt buộc bằng đúng 100% `NetAmount` (Giá trị hợp đồng trước thuế GTGT).
- **AC-ALC-02**: Mọi Tờ phân phối hợp đồng phải được xử lý giải ngân từ TCKT Viện trong vòng không quá 03 ngày làm việc kể từ ngày tiền về tài khoản.
- **AC-ALC-03**: Tất cả các giao dịch phân bổ chi phí chung phải gắn liền với 01 `ExpenseId` và 01 `AllocationRuleId` hợp lệ qua Lookup restrict.
- **AC-ALC-04**: Tự động áp dụng quy tắc giảm tỷ lệ giao khoán (0.5% nhóm 2, 0.2% nhóm 3-4) nếu Hợp đồng không thuộc nhóm 1 nhưng do Viện ký.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Lãnh đạo Viện**: Phê duyệt Tờ phân phối quyết toán hợp đồng toàn Viện.
- **Phòng TCKT Viện**: Quản lý toàn bộ danh mục Quy tắc Phân bổ và lập Tờ phân phối 3 Tầng.
- **Ban Giám đốc CCBA**: Xem và duyệt tờ phân phối kinh phí thuộc CCBA (Tier 2 & Tier 3).
- **Chủ trì HĐ / PM**: Xem giá trị kinh phí giao khoán thực hiện HĐ (Tier 3) của dự án mình phụ trách.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo bảng tính phân bổ kinh phí |
| `Author` | User | Người lập tờ phân phối kinh phí |
| `Modified` | DateTime | Thời gian duyệt / giải ngân tài chính |
| `Editor` | User | Kế toán viên / Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Phiên bản lịch sử dữ liệu phân bổ |
