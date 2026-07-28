# Đặc Tả Kỹ Thuật Module: Contracts (Quản lý Ký kết & Lưu trữ Hợp đồng Kinh tế)

## 1. Mục tiêu & Phạm vi (Goal & Scope)

### 1.1 Mục tiêu
- Quản lý toàn bộ quy trình Trình ký, Ký kết, Phân cấp Ủy quyền và Lưu trữ Hợp đồng Kinh tế (HĐKT) của CCBA và Viện KHCN Xây dựng.
- Số hóa 100% Step 2 Trình ký Hợp đồng (`trinh_ky_hd`) trong Chuỗi 7 bước nghiệp vụ IDOP theo đúng quy định tại Điều 6 QCTK 2815.
- Quản lý chính xác thông tin tài chính hợp đồng (Giá trị trước thuế `NetAmount`, Thuế `VATRate`, Tổng giá trị `GrossAmount`, Đồng tiền `Currency`) và phân loại thẩm quyền ký kết (Viện ký vs Đơn vị phân cấp ký).

### 1.2 Phạm vi
- **Bao gồm (In-Scope)**:
  - Quy trình Trình ký & Thẩm tra Hợp đồng qua các phòng chức năng Viện (KHKT, TCKT, TCHC).
  - Phân loại thẩm quyền ký kết Hợp đồng theo hạn mức và loại hình (Điều 6.1 QCTK 2815): HĐ Nhóm 1, HĐ Kỹ thuật phức tạp, HĐ giá trị lớn (>= 2 tỷ kiểm định, >= 5 tỷ tư vấn, >= 10 tỷ thi công).
  - Quản lý 02 hình thức ký kết: Hợp đồng điện tử (Ký số/Digital Signature) và Hợp đồng ký trực tiếp (Giấy).
  - Quy trình lưu trữ hợp đồng trong vòng 30 ngày kể từ ngày ký đủ các bên (Điều 6.3 QCTK 2815).
  - Tích hợp 1-to-1 với SharePoint List `Contracts` (`datamodel/sharepoint/lists/process_execution/contracts.json`).
- **Không bao gồm (Out-of-Scope)**:
  - Phân bổ kinh phí chi tiết từng phần việc cho các đơn vị (thực hiện ở module `process_execution/pmo` qua Phiếu giao việc và `cash_data/allocations`).
  - Xuất hóa đơn tài chính VAT (thực hiện ở module `cash_data/finance`).

---

## 2. User Stories & Ma trận Vai trò (Role Matrix)

### 2.1 User Stories
- **US-CON-01**: Là *Chuyên viên/PM CCBA*, tôi muốn tạo Phiếu trình ký Hợp đồng kèm dự thảo HĐKT để chuyển đến Trưởng phòng và các phòng chức năng Viện thẩm tra.
- **US-CON-02**: Là *Trưởng phòng Chuyên môn (TPM CCBA)*, tôi muốn kiểm tra nội dung kỹ thuật, giải pháp chuyên môn và đơn giá trong Hợp đồng trước khi xác nhận trình ký.
- **US-CON-03**: Là *Phòng Kế hoạch - Kỹ thuật (KHKT Viện)*, tôi muốn thẩm tra tính hợp lệ, đầy đủ của hồ sơ pháp lý, ký tắt xác nhận trong vòng 01 ngày làm việc (Điều 9.6.c QCTK 2815).
- **US-CON-04**: Là *Phòng Tài chính - Kế toán (TCKT Viện)*, tôi muốn đối soát điều khoản thanh toán, tài khoản ngân hàng và nghĩa vụ thuế GTGT của Hợp đồng.
- **US-CON-05**: Là *Lãnh đạo Viện / Giám đốc CCBA*, tôi xem xét Phiếu trình ký và thực hiện ký số hoặc ký trực tiếp Hợp đồng theo đúng phân cấp ủy quyền.
- **US-CON-06**: Là *Phòng Tổ chức - Hành chính (TCHC Viện)*, tôi nhận Hợp đồng đã ký đủ, đóng dấu cơ quan và lưu trữ 01 bản chính, chuyển 01 bản chính cho TCKT và gửi bản scan cho KHKT trong vòng 30 ngày.

### 2.2 Ma trận Vai trò (Role Matrix)

| Vai trò / Phòng ban | Tạo mới (C) | Xem (R) | Cập nhật (U) | Xóa (D) | Phê duyệt (A) | Trích xuất (E) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Phòng Tổ chức - Hành chính (TCHC)** | - | R (Toàn Viện) | U (Đóng dấu/Lưu trữ) | - | A (Văn thư/Lưu trữ) | E |
| **Phòng Kế hoạch - Tài chính (KHKT Viện)** | C | R (Toàn Viện) | U (Mã HĐ/Kỹ thuật) | - | A (Thẩm tra KHKT) | E |
| **Phòng Tài chính - Kế toán (TCKT Viện)** | - | R (Toàn Viện) | U (Tài chính/VAT) | - | A (Thẩm tra TCKT) | E |
| **Phòng Kỹ thuật - Đào tạo (KTDT)** | - | R | - | - | - | R |
| **Các Phòng Chuyên môn / Tư vấn (PCM)** | C | R (Phòng) | U (Dự thảo) | - | - | E |
| **Ban Giám đốc (BGD Viện/CCBA)** | C | R (Toàn bộ) | U | D | A (Ký Hợp đồng) | E |
| **Chủ nhiệm Dự án (PM CCBA)** | C | R (Hợp đồng giao) | U (Trình ký) | - | - | E |
| **Trưởng phòng Chuyên môn (TPM CCBA)** | C | R (Phòng) | U (Duyệt nội bộ) | - | A (Trình ký Phòng) | E |

---

## 3. Cơ sở Pháp lý & Quy chế Áp dụng

- **QCTK 2815 (Quyết định số 2815/QĐ-VKH ngày 01/12/2025)**:
  - *Điều 4.2 & Điều 6.1 (Phân cấp & Ủy quyền ký Hợp đồng)*:
    - *HĐ Viện ký*: HĐ Nhóm 1 (Phục vụ QLNN, kiểm định đánh giá sự cố), HĐ kỹ thuật phức tạp/chính trị quan trọng/Bộ giao, HĐ có giá trị >= 2 tỷ (kiểm định hiện trạng), >= 5 tỷ (tư vấn), >= 10 tỷ (thi công) do Viện trưởng hoặc Phó Viện trưởng ký theo ủy quyền.
    - *HĐ Đơn vị phân cấp ký*: Viện trưởng ủy quyền cho Giám đốc CCBA ký kết bằng pháp nhân của Trung tâm đối với các HĐ còn lại.
  - *Điều 6.2*: Hàng năm Phòng KHKT làm thủ tục ký ủy quyền chung của Viện trưởng cho Giám đốc đơn vị.
  - *Điều 6.3 (Quy định lưu giữ Hợp đồng - Thời hạn 30 ngày)*:
    - *HĐ điện tử*: Gửi email bản ký số tới Viện trưởng, Lãnh đạo phụ trách, GĐ đơn vị, Phòng TH, TCHC, KHKT, TCKT.
    - *HĐ ký trực tiếp*: Nộp 01 bản sao cho Phòng Tổng hợp đơn vị, 02 bản chính cho Phòng TCHC Viện (TCHC lưu 01 bản, chuyển TCKT 01 bản, gửi bản scan cho KHKT).
- **QCCTNB 3209 (Quyết định số 3209/QĐ-VKH ngày 31/12/2025)**:
  - Quy định chính xác thuế suất GTGT (`VATRate`) 5%, 8%, 10% theo từng loại hình dịch vụ kỹ thuật.
- **Quy chế CCBA 2026**:
  - *Điều 3*: Áp dụng ký số Hợp đồng điện tử trên hệ thống IDOP và lưu trữ tập trung.

---

## 4. Quy trình Nghiệp vụ Chi tiết (Operational Flow & BPMN)

### 4.1 Quy trình Step 2 Trình ký Hợp đồng (`trinh_ky_hd`)

```
[Khởi tạo Dự thảo HĐ] -> [TPM Duyệt Nội bộ] -> [Thẩm tra KHKT & TCKT] -> [Phê duyệt Lãnh đạo Viện/CCBA] -> [Ký số / Ký trực tiếp] -> [Đóng dấu & Lưu trữ TCHC (Trong 30 ngày)] -> [Tạo Dự án / PGV]
```

1. **Bước 2.1: Khởi tạo Dự thảo Hợp đồng**:
   - PM/Chuyên viên tạo bản ghi mới trong list `Contracts`.
   - Nhập `ContractCode`, `ContractName`, chọn `CustomerId` Lookup, `Currency`, `NetAmount`, `VATRate`, tự động tính `GrossAmount = NetAmount * (1 + VATRate)`.
2. **Bước 2.2: Trưởng phòng Chuyên môn Duyệt**:
   - TPM CCBA kiểm tra giải pháp kỹ thuật, tiến độ và đơn giá, bấm duyệt trình ký.
3. **Bước 2.3: Thẩm tra Pháp lý & Tài chính (Phòng KHKT & TCKT Viện)**:
   - KHKT kiểm tra tư cách pháp nhân, năng lực nhà thầu, mã số gói thầu trong vòng 01 ngày làm việc.
   - TCKT kiểm tra tài khoản nhận tiền, điều khoản tạm ứng và nghĩa vụ thuế.
4. **Bước 2.4: Ký kết Hợp đồng**:
   - Nếu HĐ thuộc thẩm quyền Viện ký: Chuyển Lãnh đạo Viện ký số hoặc ký trực tiếp.
   - Nếu HĐ thuộc thẩm quyền CCBA ký: Giám đốc CCBA ký kết theo giấy ủy quyền hàng năm.
5. **Bước 2.5: Đóng dấu & Lưu trữ (Thời hạn 30 ngày)**:
   - Phòng TCHC đóng dấu con dấu Viện/CCBA.
   - Nộp lưu trữ đúng quy định tại Điều 6.3 QCTK 2815.
   - Cập nhật `Status` sang ManagedMetadata `Đã ký` (`CCBA_TrangThaiChung`).
6. **Bước 2.6: Chuyển giao Step 3 (Phiếu giao việc - PGV)**:
   - Kích hoạt khởi tạo Phiếu giao việc tại module `process_execution/pmo`.

---

## 5. Acceptance Criteria & List Mapping

### 5.1 Bảng Áp dụng Dữ liệu 1-1 (SharePoint List Mapping)

#### List: `Contracts` (`datamodel/sharepoint/lists/process_execution/contracts.json`)

| Field Name | Field Type | Required | Lookup / Taxonomy / Choices | Field Description |
| :--- | :--- | :---: | :--- | :--- |
| `ContractCode` | Text | Yes | - | Mã số hợp đồng chính thức (ví dụ: 125/2026/HĐKT-BIM) |
| `ContractName` | Text | Yes | - | Tên hợp đồng kinh tế đầy đủ |
| `CustomerId` | Lookup | No | List: `Customers`, Field: `ID` | Liên kết bắt buộc tới Khách hàng ký hợp đồng |
| `Currency` | Choice | No | `VND`, `USD`, `EUR` | Đồng tiền thanh toán (Mặc định: VND) |
| `VATRate` | Number | No | Values: 0, 0.05, 0.08, 0.10 | Thuế suất thuế GTGT (ví dụ: 0.10 cho 10%) |
| `GrossAmount` | Number | No | Calculated | Tổng giá trị hợp đồng sau thuế GTGT |
| `NetAmount` | Number | No | - | Giá trị hợp đồng trước thuế GTGT |
| `Status` | ManagedMetadata | No | `CCBA_TrangThaiChung` | Trạng thái hợp đồng: Dự thảo, Đang trình ký, Đã ký, Đang thực hiện, Thanh lý, Hủy |

### 5.2 Tiêu chí Chấp nhận (Acceptance Criteria)
- **AC-CON-01**: `ContractCode` và `ContractName` bắt buộc nhập, không được để trống. `ContractCode` phải là duy nhất (Unique) trên hệ thống.
- **AC-CON-02**: Trường `CustomerId` bắt buộc liên kết với 01 bản ghi hợp lệ trong SharePoint List `Customers`.
- **AC-CON-03**: Hệ thống tự động tính toán `GrossAmount = NetAmount * (1 + VATRate)`. Cảnh báo nếu số liệu nhập tay bị lệch.
- **AC-CON-04**: Trường `Status` bắt thuộc nhóm Taxonomy `CCBA_TrangThaiChung`. Chỉ khi `Status == "Đã ký"` mới cho phép lập Phiếu giao việc (PGV).
- **AC-CON-05**: Bắt buộc đính kèm tệp scan Hợp đồng đã đóng dấu hoặc file PDF ký số chính thức trước khi chuyển trạng thái sang `Đã ký`.

---

## 6. Bảo mật, Phân quyền & Audit Trail

### 6.1 Phân quyền Truy cập (Permission Matrix)

- **Lãnh đạo Viện**: Xem toàn bộ hợp đồng toàn Viện; Phê duyệt & Ký các Hợp đồng thuộc thẩm quyền Viện.
- **Ban Giám đốc CCBA**: Ký các Hợp đồng phân cấp ủy quyền; Xem/Quản lý toàn bộ Hợp đồng CCBA.
- **Phòng KHKT / TCKT Viện**: Kiểm tra, thẩm tra, ký tắt và xem toàn bộ Hợp đồng toàn Viện.
- **Phòng TCHC Viện**: Đóng dấu, lưu trữ bản chính và quản lý kho Hợp đồng.
- **Trưởng phòng / PM CCBA**: Xem và cập nhật các Hợp đồng do đơn vị/phòng mình trực tiếp thực hiện.

### 6.2 Nhật ký Kiểm toán (Audit Trail)

| Trường thuộc tính | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `Created` | DateTime | Ngày khởi tạo hồ sơ trình ký Hợp đồng |
| `Author` | User | Người lập hồ sơ trình ký |
| `Modified` | DateTime | Thời gian cập nhật trạng thái Hợp đồng mới nhất |
| `Editor` | User | Người thực hiện cập nhật cuối cùng |
| `SystemVersion` | Integer | Lịch sử các phiên bản thay đổi dữ liệu Hợp đồng |
