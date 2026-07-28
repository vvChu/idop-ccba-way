# Đặc Tả Kỹ Thuật Module: Expenses (Quản lý Chi phí Dự án & Định mức Chi tiêu Nội bộ)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý tập trung toàn bộ chi phí phát sinh thực tế trong quá trình thực hiện dự án, hợp đồng dịch vụ kỹ thuật và hoạt động vận hành của CCBA.
- Đảm bảo 100% các khoản chi tuân thủ tuyệt đối định mức chi tiêu nội bộ tại QCCTNB 3209 (tiền lương, bảo hiểm, ăn ca, đồng phục, công tác phí, hội nghị, vật tư) và quy định giao khoán kinh phí tại Điều 12.4 QCTK 2815.
- Quản lý quy trình kiểm soát chứng từ tài chính qua Checklist kiểm tra chi phí (`ExpenseChecklists`) trước khi trình Kế toán và Ban Giám đốc phê duyệt thanh toán.

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quản lý thông tin chi phí dự án: loại chi phí (`ExpenseType`), đồng tiền (`Currency`), thuế GTGT (`VATRate`), số tiền trước thuế (`NetAmount`), số tiền sau thuế (`GrossAmount`), ngày chi (`ExpenseDate`), gắn với dự án (`ProjectId`).
  - Kiểm tra điều kiện chứng từ tài chính hợp lệ thông qua `ExpenseChecklists` (Hóa đơn GTGT, Giấy đi đường, Vé máy bay/tàu xe, Bảng chấm công, Hợp đồng giao khoán/thanh lý).
  - Phân loại chi phí theo ManagedMetadata Taxonomy `CCBA_LoaiChiPhi` (Chi nhân công, Chi máy móc thiết bị, Chi vật liệu, Chi công tác phí, Chi dịch vụ mua ngoài, Chi quản lý).
  - Tích hợp 1-to-1 với SharePoint Lists: `Expenses` (`datamodel/sharepoint/lists/cash_data/expenses.json`) và `ExpenseChecklists` (`datamodel/sharepoint/lists/cash_data/expense_checklists.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Chi trả tiền mặt trực tiếp từ thủ quỹ (chỉ quản lý hồ sơ đề nghị thanh toán và chứng từ trên IDOP).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-EXP-01**: Là *Chủ nhiệm Dự án (PM / Chủ trì HĐ)*, tôi muốn lập Đề nghị thanh toán chi phí dự án (`Expenses`) từ phần kinh phí giao khoán (Tier 3) để chi trả công tác phí, thuê thiết bị và mua vật tư.
- **US-EXP-02**: Là *Kế toán viên CCBA / Phòng TCKT Viện*, tôi muốn kiểm tra `ExpenseChecklists` để đảm bảo đầy đủ hóa đơn hợp pháp và đúng định mức QCCTNB 3209 trước khi duyệt chi.
- **US-EXP-03**: Là *Cán bộ đi công tác*, tôi muốn nộp chứng từ công tác phí (vé máy bay, hóa đơn phòng nghỉ, giấy đi đường) để thanh toán theo đúng phụ cấp lưu trú (tối đa 500.000đ/ngày).
- **US-EXP-04**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi thẩm định tính hợp lý của chi phí kỹ thuật trước khi trình Ban Giám đốc CCBA phê duyệt.
- **US-EXP-05**: Là *Ban Giám đốc (BGD Viện/CCBA)*, tôi phê duyệt các khoản đề nghị chi phí dự án và xem báo cáo tổng hợp chi phí so với ngân sách được giao.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (Duyệt xe/Công tác) | - | A (Xác nhận TCHC) | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | - | R (Toàn Viện) | U (Đối soát dự toán) | - | - | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | C | R (Toàn Viện) | U (Kiểm tra chứng từ) | - | A (Duyệt Thanh toán) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Đề nghị chi phí) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Phê duyệt Chi tiêu) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Dự án giao) | U (Lập Đề nghị chi) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Duyệt chi phí phòng) | - | A (Duyệt Chi phí Phòng) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - *Điều 8.2.1 (Tiền lương & Trích nộp bảo hiểm)*: Cơ quan trích nộp 17% BHXH, 0.5% BHTNLĐ, 3% BHYT, 1% BHTN, 2% Kinh phí công đoàn (Tổng 23.5%); Người lao động nộp 10.5%.
  - *Điều 8.2.2.d (Chi ăn ca)*: Tối đa 1.500.000 đồng/người/tháng.
  - *Điều 8.2.2.e (Trang phục, đồng phục)*: Mức chi bằng tiền tối đa 5.000.000 đồng/người/năm.
  - *Điều 8.2.3 (Công tác phí trong nước)*:
    - *Vé máy bay*: Lãnh đạo Viện (Phổ thông đặc biệt/Linh hoạt/Thương gia khi đột xuất); VCNLĐ (Hạng phổ thông).
    - *Phụ cấp lưu trú*: Tối đa 500.000 đồng/người/ngày (nếu thanh toán hóa đơn tiền ăn thì không hưởng phụ cấp lưu trú).
    - *Khoán công tác phí lưu động*: Đi công tác > 10 ngày/tháng, khoán tối đa 700.000 đồng/người/tháng.
- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 9.1.c*: Trưởng đơn vị chịu trách nhiệm kiểm tra, ký các hồ sơ tài chính và chứng từ chi phí, quản lý chi phí trong phần giao khoán đảm bảo đầy đủ chứng từ hợp lý, hợp pháp.
  - *Điều 12.4.a*: Chi phí giao Chủ trì (Tier 3) dùng để chi nhân công, thiết bị, vật liệu và những chi phí cần thiết khác để thực hiện HĐ. Không sử dụng kinh phí quản lý chung tại đơn vị cho chi phí riêng của Chủ trì.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Kiểm soát rủi ro tài chính và lưu vết chứng từ chi phí điện tử trên nền tảng IDOP.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Quản lý & Phê duyệt Chi phí Dự án

```
[Lập Đề nghị Chi phí (Expenses)] -> [Kiểm tra Checklist Chứng từ (ExpenseChecklists)] -> [TPM & Kế toán Thẩm định] -> [BGD CCBA / Viện Phê duyệt] -> [Thanh toán Giải ngân & Hạch toán]
```

1. **Khởi tạo Đề nghị Chi phí (Step 1)**:
   - PM / Cán bộ lập bản ghi `Expenses` trong list `Expenses`.
   - Chọn `ProjectId` Lookup, `ExpenseType` (`CCBA_LoaiChiPhi`), nhập `NetAmount`, `VATRate`, `ExpenseDate`.
   - Tự động tính `GrossAmount = NetAmount * (1 + VATRate)`.
2. **Kiểm tra Checklist Chứng từ (`ExpenseChecklists`) (Step 2)**:
   - Tạo danh sách các mục checklist chứng từ tương ứng (`ChecklistItem`): Hóa đơn GTGT, Giấy đi đường, Cuống vé máy bay, Bảng chấm công và các chứng từ liên quan khác.
   - Kế toán viên đối soát chứng từ và đánh dấu `IsCompleted = true`.
3. **Thẩm định & Phê duyệt (Step 3)**:
   - TPM kiểm tra tính phù hợp với tiến độ và kỹ thuật.
   - Kế toán đối soát định mức QCCTNB 3209.
   - Ban Giám đốc CCBA / Viện phê duyệt lệnh chi.
4. **Giải ngân & Hạch toán (Step 4)**:
   - TCKT thực hiện chuyển khoản giải ngân và lưu hồ sơ chứng từ điện tử.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List 1: `Expenses` (`datamodel/sharepoint/lists/cash_data/expenses.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ProjectId` | Lookup | No | List: `Projects`, Field: `ID` | Liên kết đến Dự án chịu chi phí |
| `ExpenseType` | ManagedMetadata | No | `CCBA_LoaiChiPhi` | Nhóm chi phí: Nhân công, Máy thiết bị, Vật liệu, Công tác phí, Quản lý |
| `Currency` | Choice | No | `VND`, `USD`, `EUR` | Đồng tiền hạch toán |
| `VATRate` | Number | No | Values: 0, 0.05, 0.08, 0.10 | Thuế suất GTGT của chứng từ chi |
| `GrossAmount` | Number | No | Calculated | Tổng chi phí thanh toán sau thuế GTGT |
| `NetAmount` | Number | No | - | Chi phí trước thuế GTGT |
| `ExpenseDate` | DateTime | No | - | Ngày phát sinh chi phí |

#### List 2: `ExpenseChecklists` (`datamodel/sharepoint/lists/cash_data/expense_checklists.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ExpenseId` | Lookup | No | List: `Expenses`, Field: `ID` | Liên kết bắt buộc đến Chi phí dự án cha |
| `ChecklistItem` | Text | No | - | Tên chứng từ/yêu cầu kiểm tra (ví dụ: Hóa đơn tài chính hợp pháp) |
| `IsCompleted` | YesNo | No | Default: `false` | Trạng thái đã hoàn thành kiểm tra chứng từ |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-EXP-01**: `ProjectId` bắt buộc liên kết với 01 `Project` tồn tại. `GrossAmount = NetAmount * (1 + VATRate)`.
- **AC-EXP-02**: Không được phép phê duyệt khoản chi nếu tất cả các `ExpenseChecklists` bắt buộc có `IsCompleted == false`.
- **AC-EXP-03**: Mọi khoản chi công tác phí vượt quá 500.000đ/ngày phụ cấp lưu trú hoặc chi đồng phục vượt 5.000.000đ/năm phải bị hệ thống tự động chặn và báo lỗi vượt định mức QCCTNB 3209.
- **AC-EXP-04**: Trường `ExpenseType` phải liên kết 100% với TermStore `CCBA_LoaiChiPhi`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Ban Giám đốc Viện / CCBA**: Phê duyệt các đề nghị chi phí dự án và chi hoạt động chung.
- **Phòng TCKT Viện**: Kiểm tra chứng từ, hoàn thiện `ExpenseChecklists` và thực hiện giải ngân.
- **Trưởng phòng Chuyên môn (TPM)**: Xem và duyệt các đề nghị chi phí thuộc phòng quản lý.
- **Chủ nhiệm Dự án (PM)**: Lập đề xuất chi phí và theo dõi hạn mức kinh phí giao khoán của dự án.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo đề nghị chi phí |
| `Author` | User | Người lập đề nghị chi |
| `Modified` | DateTime | Thời gian cập nhật chứng từ / thanh toán |
| `Editor` | User | Kế toán viên / Người sửa đổi cuối cùng |
| `SystemVersion` | Integer | Phiên bản lịch sử dữ liệu chi phí |
