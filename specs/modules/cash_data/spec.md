# Đặc Tả Kỹ Thuật Tổng Thể Module: Cash Data (Quản lý Dòng tiền & Tài chính Tập trung)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý toàn bộ vòng đời tài chính, dòng tiền (Cash Flow), kế hoạch ngân sách, hóa đơn đầu vào/đầu ra, chi phí dự án và cơ chế phân bổ kinh phí 3 tầng cho CCBA và Viện KHCN Xây dựng.
- Số hóa 100% Step 6 Nghiệm thu (`nghiem_thu_xuat_hoa_don`) theo Điều 11 QCTK 2815 và Step 7 Quyết toán (`quyet_toan_thanh_ly`) theo Điều 12 & Bảng 1 QCTK 2815 trong Chuỗi 7 bước nghiệp vụ IDOP.
- Đảm bảo tuân thủ tuyệt đối các định mức chi tiêu nội bộ tại QCCTNB 3209, quy định hạch toán hạch toán kế toán và quản lý công nợ, bảo toàn vốn Nhà nước.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quản lý Dòng tiền & Hóa đơn (Submodule `finance`): Kế hoạch tài chính (`FinancialPlans`), Yêu cầu xuất hóa đơn (`InvoiceRequests`), Hóa đơn đầu ra (`OutgoingInvoices`), Hóa đơn đầu vào (`InputInvoices`), Tài khoản ngân hàng (`BankAccounts`), Danh mục nhà cung cấp (`Vendors`).
  - Quản lý Cơ chế Phân bổ 3 Tầng (Submodule `allocations`): Quy tắc phân bổ (`AllocationRules`), Phân bổ chi phí chung (`SharedCostAllocations`).
  - Quản lý Chi phí & Định mức (Submodule `expenses`): Chi phí dự án (`Expenses`), Checklist kiểm tra chi phí (`ExpenseChecklists`).
  - Tích hợp liên thông 10 SharePoint Lists tài chính với các module `contracts`, `projects`, `pmo`.
- **Không bao gồm (Out-of-Scope)**:
  - Khai báo thuế điện tử trực tiếp tới Tổng cục Thuế (thực hiện qua phần mềm MISA/Fast Accounting chuyên dụng của Phòng TCKT).
  - Chi trả lương trực tiếp qua ATM Ngân hàng (chỉ quản lý bảng phân bổ và chứng từ thanh toán trên IDOP).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-CSH-01**: Là *Chủ trì Hợp đồng / PM CCBA*, tôi muốn lập yêu cầu xuất hóa đơn (`InvoiceRequests`) và lập phương án phân phối quyết toán sau khi thu hồi tiền về tài khoản Viện.
- **US-CSH-02**: Là *Phòng Tài chính - Kế toán (TCKT Viện)*, tôi muốn kiểm tra chứng từ hoàn chỉnh, xuất hóa đơn tài chính GTGT, hạch toán tiền về và thực hiện phân phối 3 tầng theo Bảng 1 QCTK 2815 trong vòng 03 ngày làm việc (Điều 11.1 QCTK 2815).
- **US-CSH-03**: Là *Phụ trách Kế toán / Phòng Tổng hợp CCBA*, tôi đối soát nợ quá hạn, thanh toán công nợ nhà cung cấp (`Vendors`) và kiểm tra các khoản tạm ứng lương/chi phí của cán bộ.
- **US-CSH-04**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi muốn xem tình hình giải ngân chi phí (`Expenses`) và hạn mức khoán của từng hợp đồng thuộc phòng quản lý.
- **US-CSH-05**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi truy xuất báo cáo tài chính tổng thể, tỷ lệ thu hồi nợ, doanh thu thực hiện và dòng tiền tồn quỹ trên IDOP.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (Trích nộp BHXH) | - | - | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | - | R (Toàn Viện) | U (Đối soát Kế hoạch) | - | A (Kế hoạch thầu) | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | C | R (Toàn Viện) | U (Phân phối/Hóa đơn) | - | A (Xuất HĐ/Chuyển tiền) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Đề nghị chi/Hóa đơn) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Quyết toán tài chính) | E |
| **Chủ nhiệm Dự án (PM / Chủ trì HĐ)** | C | R (Hợp đồng giao) | U (Yêu cầu HĐ/Chi phí) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Duyệt chi phí phòng) | - | A (Duyệt Đề nghị chi) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 7.7 (Kinh phí giao thực hiện)*: Định mức kinh phí giao tính trên giá trị hợp đồng trước thuế GTGT theo Bảng 1.
  - *Điều 9.1.c (Trách nhiệm quản lý tài chính của Trưởng đơn vị)*: Quản lý chi phí trong phần giao khoán, nộp thuế TNCN, đóng đủ BHXH/BHYT/BHTN/Kinh phí công đoàn (23.5%).
  - *Điều 9.7 (Trách nhiệm Phòng TCKT Viện)*: Thống nhất quản lý công tác quyết toán, kiểm soát chứng từ chi tiêu, thông báo tiền về và nợ quá hạn.
  - *Điều 11 (Quyết toán thanh lý Hợp đồng - Step 6 & Step 7 Operational Flow)*:
    - *Khoản 1*: Căn cứ biên bản nghiệm thu, lập đề nghị xuất hóa đơn. Sau khi tiền về tài khoản, TCKT trình Lãnh đạo Viện duyệt tờ phân phối hợp đồng và thanh toán cho đơn vị trong vòng không quá 03 ngày làm việc.
    - *Khoản 2*: Với HĐ do đơn vị ký, Viện trưởng phân công Trưởng đơn vị ký duyệt tờ phân phối HĐ.
  - *Điều 12 & BẢNG 1 (Định mức kinh phí giao thực hiện HĐKT)*:
    - Cơ chế Cơ cấu Tài chính 3 Tầng:
      - **Tier 1 (Tầng Viện)**: CPQL, LN Viện (2% - 16%), KHTSCĐ Viện (0.5% - 10%), Thuế GTGT (5% - 10%).
      - **Tier 2 (Tầng Đơn vị / CCBA)**: CPQL đơn vị (4% - 15%), trích nộp lương/bảo hiểm (23.5%), thu nhập dịch vụ lãnh đạo/bộ phận tổng hợp.
      - **Tier 3 (Tầng Chủ trì HĐ / PM)**: Giao khoán thực hiện HĐ (59% - 92%) dùng chi nhân công, thiết bị, vật liệu và chi phí hợp lý khác.
  - *Điều 14.2 (Phạt nợ quá hạn & tạm ứng)*: Phạt nợ quá hạn tạm ứng (130% lãi suất), nợ trễ nộp thuế GTGT quá 1 năm từ ngày xuất hóa đơn.
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - *Điều 8.2.1*: Định mức lương ngạch bậc và trích nộp bảo hiểm (23.5% cơ quan, 10.5% cá nhân).
  - *Điều 8.2.3*: Định mức công tác phí trong nước (Lưu trú max 500.000đ/ngày, khoán xe 700.000đ/tháng, vé máy bay phổ thông/thương gia).
  - *Điều 8.2.5*: Chi phí hội nghị, hội thảo, giao dịch, quảng cáo, tiếp khách.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Minh bạch dòng tiền và quản lý tài chính tập trung trên nền tảng IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Nghiệm thu, Xuất Hóa đơn (Step 6) & Quyết toán Phân phối 3 Tầng (Step 7)

```
[Biên bản Nghiệm thu Step 6] ──> [Yêu cầu Xuất Hóa đơn (InvoiceRequests)] ──> [Xuất Hóa đơn GTGT (OutgoingInvoices)] ──> [Tiền về Tài khoản Viện] ──> [Lập Tờ Phân phối 3 Tầng Step 7] ──> [Duyệt Tờ Phân phối (Trong 03 ngày)] ──> [Thanh toán Giải ngân về CCBA & PM]
```

1. **Step 6: Nghiệm thu & Yêu cầu Xuất Hóa đơn**:
   - Sau khi hoàn thành khối lượng hoặc giai đoạn dự án, PM lập `InvoiceRequests` gửi Phòng TCKT kèm Biên bản Nghiệm thu.
   - TCKT kiểm tra chứng từ và phát hành `OutgoingInvoices` (Hóa đơn GTGT).
2. **Theo dõi Tiền về & Công nợ**:
   - TCKT ghi nhận số tiền chuyển khoản về `BankAccounts` của Viện, thông báo cho CCBA và PM.
3. **Step 7: Quyết toán & Phân phối 3 Tầng (Tờ Phân phối Hợp đồng)**:
   - Căn cứ Bảng 1 QCTK 2815, TCKT trình Lãnh đạo Viện ký Tờ phân phối Hợp đồng:
     - **Tier 1**: Trích nộp Viện (CPQL Viện + KHTSCĐ Viện + Thuế GTGT).
     - **Tier 2**: Chuyển kinh phí quản lý về Đơn vị CCBA (CPQL Đơn vị + Bảo hiểm trích theo lương 23.5%).
     - **Tier 3**: Chuyển phần kinh phí giao khoán thực hiện HĐ (Cột 3 Bảng 1) về cho Chủ trì HĐ / PM thanh toán nhân công, thiết bị, vật tư.
4. **Giải ngân & Thanh lý Hợp đồng**:
   - Trong vòng không quá 03 ngày làm việc kể từ khi đủ hồ sơ tiền về, TCKT thực hiện chuyển tiền giải ngân cho CCBA và PM (Điều 11.1 QCTK 2815).

---

## 5. Acceptance Criteria & Schema Index Mapping

### 5.1 Danh mục SharePoint Lists thuộc Module `cash_data`

1. **`specs/modules/cash_data/finance/spec.md`**:
   - `FinancialPlans` (`PlanName`, `Year`, `TotalBudget`)
   - `InvoiceRequests` (`ContractId`, `RequestDate`, `Amount`, `Currency`)
   - `OutgoingInvoices` (`ContractId`, `InvoiceNumber`, `Currency`, `VATRate`, `GrossAmount`, `NetAmount`, `InvoiceDate`)
   - `InputInvoices` (`VendorId`, `InvoiceNumber`, `Currency`, `VATRate`, `GrossAmount`, `NetAmount`, `InvoiceDate`)
   - `BankAccounts` (`BankName`, `AccountNumber`, `AccountName`, `Currency`)
   - `Vendors` (`VendorName`, `VendorCode`, `ServiceType`)
   - `DocumentRequirements` (`RequirementName`, `Description`, `AppliesTo`)
2. **`specs/modules/cash_data/allocations/spec.md`**:
   - `AllocationRules` (`RuleName`, `Description`)
   - `SharedCostAllocations` (`ExpenseId`, `AllocationRuleId`, `Amount`)
3. **`specs/modules/cash_data/expenses/spec.md`**:
   - `Expenses` (`ProjectId`, `ExpenseType`, `Currency`, `VATRate`, `GrossAmount`, `NetAmount`, `ExpenseDate`)
   - `ExpenseChecklists` (`ExpenseId`, `ChecklistItem`, `IsCompleted`)

### 5.2 Tiêu chí Chấp nhận Tổng thể (Acceptance Criteria)
- **AC-CSH-01**: Thời gian xử lý Tờ phân phối hợp đồng và thanh toán giải ngân từ TCKT Viện cho đơn vị không quá 03 ngày làm việc kể từ khi đủ hồ sơ tiền về.
- **AC-CSH-02**: Mọi giao dịch tài chính bắt buộc tuân thủ đúng tỷ lệ giao khoán Bảng 1 QCTK 2815 và định mức chi QCCTNB 3209.
- **AC-CSH-03**: Hệ thống tự động tính toán đối soát `GrossAmount = NetAmount * (1 + VATRate)`.
- **AC-CSH-04**: Tự động phát cảnh báo công nợ quá hạn đối với các khoản tạm ứng quá ngày 10/01 năm kế tiếp hoặc hóa đơn xuất quá 1 năm chưa thu hồi tiền.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Viện trưởng / BGD Viện**: Phê duyệt Tờ phân phối quyết toán hợp đồng toàn Viện; Duyệt chi ngoại định mức.
- **Phòng TCKT Viện**: Toàn quyền quản lý, kiểm soát chứng từ, xuất hóa đơn và hạch toán dòng tiền toàn Viện.
- **Ban Giám đốc CCBA**: Phê duyệt đề nghị chi tiêu, quyết toán nội bộ đơn vị theo phân cấp.
- **Chủ trì HĐ / PM**: Xem tình hình tiền về, nộp hồ sơ đề nghị xuất hóa đơn và đề nghị thanh toán chi phí dự án.
- **Phụ trách Kế toán CCBA**: Kiểm tra chứng từ chi phí và đối soát công nợ nhà cung cấp.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo chứng từ/giao dịch tài chính |
| `Author` | User | Người tạo chứng từ |
| `Modified` | DateTime | Thời gian cập nhật hạch toán mới nhất |
| `Editor` | User | Kế toán viên / Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Lịch sử các phiên bản thay đổi dữ liệu tài chính |