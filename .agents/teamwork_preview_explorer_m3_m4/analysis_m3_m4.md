# Phân tích Chuyên sâu Validation, Testing & Strategic Roadmap (Milestone 3 & Milestone 4)

**Dự án**: IDOP-CCBA-WAY (Integrated Digital Operation Platform - CCBA / IBST)  
**Tác giả**: Explorer 4 (`teamwork_preview_explorer_m3_m4`)  
**Ngày thực hiện**: 28/07/2026  
**Thư mục làm việc**: `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m3_m4`  

---

## 1. Tóm tắt Điều hành (Executive Summary)

Báo cáo này cung cấp đánh giá toàn diện về **Hệ thống Validation, Kiểm thử (Milestone 3)** và **Nợ kỹ thuật, Đề xuất Cải tiến & Lộ trình Chiến lược (Milestone 4)** cho nền tảng IDOP CCBA. Qua quá trình đọc và phân tích từng dòng mã nguồn trong `idop.ps1`, `tools/scripts/validation/`, `tools/scripts/modules/`, `tools/scripts/testing/`, `tools/scripts/tests/`, `datamodel/sharepoint/` và `specs/`, chúng tôi đã ghi nhận các phát hiện cốt lõi sau:

1. **Sai lệch Kiến trúc Schema (Architectural Property Mismatch)**:
   - File JSON Schema chuẩn (`datamodel/sharepoint/schemas/sp-list.schema.json`) và Module triển khai (`SpListDeploy.psm1`) định nghĩa cấu trúc list bằng `ListName`, `Columns` và cột bằng `Name`.
   - Trong khi đó, Module kiểm tra chính `ValidationHelpers.psm1` (`Test-IDOPListSchema`) và bộ fixture kiểm thử Pester (`tools/scripts/testing/modules.Tests.ps1`) lại bắt buộc các thuộc tính cũ `Title`, `InternalName` và `Fields`.
   - **Hệ quả**: Lệnh `.\idop.ps1 validate datamodel` sẽ báo lỗi 100% trên toàn bộ 48+ file JSON định nghĩa list của hệ thống!

2. **Hạn chế Kiểm tra Ràng buộc Tham chiếu (Referential Integrity Gaps)**:
   - `Test-IDOPLookupReferences` hiện chỉ kiểm tra xem `LookupList` có tồn tại trong danh sách file JSON hay không, nhưng **KHÔNG kiểm tra sự tồn tại của trường mục tiêu (`LookupField`)** trong list đích.
   - Chưa có bất kỳ hàm validation nào đối soát giữa các trường `ManagedMetadata` (`TermSet.Group`, `TermSet.Name`) trong list JSON với 19 file định nghĩa Taxonomy thực tế trong `datamodel/sharepoint/taxonomy/`.

3. **Rủi ro Fallback & Nợ kỹ thuật trong Validation Scripts**:
   - `validate-sp-schemas.ps1` thực hiện kiểm tra AJV CLI (`ajv validate`), nhưng nếu môi trường thiếu `ajv`, script tự động fallback sang `ConvertFrom-Json` mà không báo lỗi schema, dẫn đến **nguy cơ lọt lưới các lỗi sai cấu trúc JSON schema**.
   - Có sự trùng lặp và không đồng nhất giữa `sp-diff.ps1`, `run-sp-diff.ps1`, `validate-model.ps1` và `apply-sp-lists.ps1`.

---

## 2. Đánh giá Chi tiết Validation & Testing Scenarios (Milestone 3)

### 2.1 Trace Mã nguồn & Execution Flow của các Validation Scripts

#### 1. CLI Entry Point: `idop.ps1 validate` (`idop.ps1:262-326`)
- **Luồng xử lý**:
  - `idop.ps1` tiếp nhận tham số `$Command = 'validate'` và `$SubCommand` (`datamodel`, `schemas`, `naming`, `lookups`).
  - Nạp các shared modules tại `tools/scripts/modules/`: `PnPHelpers.psm1`, `LoggingHelpers.psm1`, `ValidationHelpers.psm1`.
  - **Khi `$SubCommand = 'datamodel'`**: Gọi `Test-IDOPDataModel` (`ValidationHelpers.psm1:345-399`). Hàm này duyệt qua `datamodel/sharepoint/lists` và `datamodel/sharepoint/taxonomy`, lần lượt gọi `Test-IDOPListSchema` và `Test-IDOPTaxonomyJson`.
  - **Khi `$SubCommand = 'schemas'`**: Đột ngột chuyển hướng thực thi script ngoài `tools/scripts/validation/validate-sp-schemas.ps1`.
  - **Khi `$SubCommand = 'naming'`**: Chuyển hướng thực thi `tools/scripts/validation/validate-sp-naming.ps1`.
  - **Khi `$SubCommand = 'lookups'`**: Gọi `Test-IDOPLookupReferences` (`ValidationHelpers.psm1:297-337`).

- **Điểm yếu & Rủi ro**:
  - Thiếu tính nhất quán trong CLI: `datamodel` và `lookups` dùng hàm module (`ValidationHelpers.psm1`), trong khi `schemas` và `naming` lại gọi script lẻ (`validate-sp-schemas.ps1`, `validate-sp-naming.ps1`).

#### 2. Schema Validation Script: `tools/scripts/validation/validate-sp-schemas.ps1`
- **Luồng xử lý**:
  - Nhận tham số `$SchemaDir` (`datamodel/sharepoint/schemas`) và `$ListsPath` (`datamodel/sharepoint/lists`).
  - Kiểm tra xem lệnh `ajv` có sẵn trong hệ thống hay không (`Get-Command ajv -ErrorAction SilentlyContinue`).
  - Nếu có `ajv`: Chạy `ajv validate -s "$schemaPath" -d "$($jsonFile.FullName)"`.
  - Nếu không có `ajv`: Fallback về `ConvertFrom-Json` (chỉ kiểm tra cú pháp JSON, hoàn toàn bỏ qua JSON Schema validation!).
  - Đồng thời tồn tại file Node.js `tools/scripts/validate-sp-schemas.js` chạy `execSync('ajv validate ...')` độc lập.

#### 3. Naming Validation Script: `tools/scripts/validation/validate-sp-naming.ps1`
- **Luồng xử lý**:
  - Tự động kiểm tra phiên bản PowerShell (yêu cầu PowerShell 7+ để đảm bảo an toàn UTF-8 tiếng Việt, nếu running dưới Windows PowerShell 5.1 sẽ tự re-exec bằng `pwsh`).
  - Kết nối tới SharePoint Online qua `Connect-IdopOnline`.
  - Kiểm tra quy tắc đặt tên cột: `InternalName` phải là tiếng Anh (`^[A-Za-z][A-Za-z0-9]*$`), `DisplayName` phải có ký tự diacritic tiếng Việt hoặc khoảng trắng (`SeemsVietnamese`).
  - Báo lỗi nếu tìm thấy violation.

#### 4. Differential Schema Inspection: `sp-diff.ps1` & `run-sp-diff.ps1`
- **Luồng xử lý**:
  - Chạy so sánh cấu trúc danh sách trên site SharePoint Online thực tế với file JSON local.
  - Hỗ trợ tham số `-Focus` (`all`, `issues`, `changed`), tính toán SHA1 hash file JSON (`Get-JsonHash`), lưu cache trạng thái vào `tools/output/state/sp-diff-last.json`.
  - Kiểm tra kiểu dữ liệu nâng cao (`ExpectedToSpType`), nhận diện đúng `TaxonomyFieldType` cho `ManagedMetadata` và `UserMulti` cho `User`.

#### 5. Model Linting & Diagnostic Script: `tools/scripts/tests/validate-model.ps1`
- **Luồng xử lý**:
  - Quét toàn bộ JSON trong `datamodel/sharepoint/lists`.
  - Kiểm tra các thuộc tính `ListName` và `Columns`.
  - Cảnh báo trùng lặp tên trường (`Group-Object Name`).
  - Cảnh báo vi phạm ngưỡng khuyến nghị SharePoint: `Lookup > 8` và `Fields > 28`.
  - Xuất bảng tổng hợp `MODEL VALIDATION SUMMARY`.

#### 6. Bộ Kiểm thử Pester: `tools/scripts/testing/`
- **`modules.Tests.ps1`**: Kiểm thử các hàm đơn vị trong `ValidationHelpers.psm1`, `LoggingHelpers.psm1`, `PnPHelpers.psm1`.
- **`apply-sp-lists.Tests.ps1`**: Kiểm thử DryRun mode cho script triển khai `apply-sp-lists.ps1`.
- **`test-lead-capture.ps1`**: Kiểm thử tích hợp quy trình nhận thông tin Lead từ form và lưu vào list `Leads`.

---

### 2.2 Đánh giá Năng lực Kiểm tra Ràng buộc Tham chiếu (Referential Integrity Capabilities)

#### 1. Kiểm tra Lookup Target Existence
- **Hiện trạng (`ValidationHelpers.psm1:297-337`)**:
  - Hàm `Test-IDOPLookupReferences` nạp tất cả các file JSON trong thư mục lists, tạo bảng băm `$allLists[$json.InternalName]`.
  - Với mỗi trường có `Type == 'Lookup'` hoặc `'LookupMulti'`, hàm kiểm tra xem `$field.LookupList` có tồn tại trong danh sách key của `$allLists` hay không.
- **Lỗ hổng & Hạn chế**:
  1. **Không kiểm tra cột mục tiêu (`LookupField`)**: Trong file JSON, trường Lookup định nghĩa `"Lookup": { "List": "Projects", "Field": "ProjectCode" }`. Hiện tại validator chỉ kiểm tra list `Projects` có tồn tại không, nhưng **KHÔNG kiểm tra xem trường `ProjectCode` có thực sự tồn tại trong list `Projects` hay không**!
  2. **Không kiểm tra Lookup trên môi trường Live**: Không xác nhận xem list/column trên site SharePoint thực tế đã được khởi tạo hay chưa trước khi tạo trường Lookup phụ thuộc.

#### 2. Kiểm tra Taxonomy GUID & Term Set Validation
- **Hiện trạng (`ValidationHelpers.psm1:228-290`)**:
  - Hàm `Test-IDOPTaxonomyJson` kiểm tra định dạng file taxonomy JSON (đối soát thuộc tính `Name`, `Id`, `Terms` và kiểm tra cú pháp GUID bằng `[System.Guid]::Parse`).
- **Lỗ hổng & Hạn chế**:
  1. **Hoàn toàn KHÔNG có liên kết tham chiếu (Cross-Reference Validation)**: Các list JSON khai báo trường ManagedMetadata theo dạng:
     ```json
     "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_LoaiChiPhi" }
     ```
     Tuy nhiên, `ValidationHelpers.psm1` và `idop.ps1 validate` **chưa từng đối soát** xem file `CCBA_LoaiChiPhi.json` có tồn tại trong thư mục `datamodel/sharepoint/taxonomy/` hay không!
  2. **Không kiểm tra tính nhất quán của TermSet GUID**: Không đối chiếu GUID của TermSet trong file taxonomy với khai báo trong list schema.

---

### 2.3 Ma trận Kiểm thử Readiness Check (Deployment Readiness Check Test Matrix)

Để đảm bảo an toàn tuyệt đối trước khi triển khai (Deployment) lên môi trường Test/Prod, chúng tôi thiết kế Ma trận Readiness Check 5 Tầng (5-Tier DRC Matrix) chi tiết dưới đây:

| Tier | Tên Tầng Kiểm thử | Phạm vi & Mục tiêu | Kịch bản Kiểm thử | Trạng thái Hiện tại | Lệnh / Công cụ Xúc tiến |
|---|---|---|---|---|---|
| **Tier 1** | **Static Schema & JSON Syntax Linting** | Kiểm tra cú pháp JSON, đúng schema chuẩn `sp-list.schema.json`, không trùng tên cột | - Verify JSON parse valid.<br>- Verify AJV schema validation against `sp-list.schema.json`.<br>- Check `ListName` & `Name` regex patterns.<br>- Check unique column names within list. | **Đã có một phần** (Tuy nhiên `validate-sp-schemas.ps1` bị bypass nếu thiếu `ajv`) | `ajv validate -s datamodel/sharepoint/schemas/sp-list.schema.json -d datamodel/sharepoint/lists/**/*.json` |
| **Tier 2** | **Referential & Structural Integrity** | Kiểm tra toàn vẹn liên kết Lookup, Term Set và giới hạn hiển thị SharePoint | - Lookup Target List & Target Field exist in datamodel.<br>- Taxonomy TermSet Group & Name exist in `taxonomy/*.json`.<br>- List Column Count <= 28.<br>- Lookup Column Count <= 8.<br>- Circular Lookup dependency check. | **Cần bổ sung nâng cấp** (Hiện thiếu target field & taxonomy cross-ref) | `.\idop.ps1 validate lookups` (Cần refactor) & `pwsh tools/scripts/tests/validate-model.ps1` |
| **Tier 3** | **Environment & Pre-Flight Auth** | Kiểm tra kết nối SharePoint, quyền hạn Entra App / Admin, Term Store access | - Verify PnP Online connection to `$siteUrl`.<br>- Verify site admin / list creation permissions.<br>- Verify Term Store read/write access.<br>- Check Entra App Id & Cert validity. | **Đã có sẵn** | `.\idop.ps1 connect -Environment Dev` & `check-pnp-auth-capability.ps1` |
| **Tier 4** | **Idempotent Deployment & Dry-Run Diff** | Kiểm tra kế hoạch thay đổi (Plan/Diff) trước khi ghi vào SharePoint thực tế | - Run `apply-sp-lists.ps1 -DryRun -Full` without errors.<br>- Run `sp-diff.ps1` to detect schema drift vs live site.<br>- Ensure idempotent field creation (no duplicate fields created on retry). | **Đã có sẵn** | `.\idop.ps1 deploy lists -Environment Dev -DryRun -Full` & `pwsh tools/scripts/validation/sp-diff.ps1` |
| **Tier 5** | **Post-Deployment Smoke & Pester Regression** | Kiểm tra sau triển khai: view mặc định, Pester tests, luồng dữ liệu mẫu | - Verify default view fields via `inspect-view.ps1`.<br>- Run Pester module tests `Invoke-Pester tools/scripts/testing/`.<br>- Test integration flow `test-lead-capture.ps1`. | **Đã có sẵn** (Cần fix test fixtures) | `Invoke-Pester -Path tools/scripts/testing/` & `pwsh tools/scripts/validation/inspect-view.ps1` |

---

## 3. Nợ kỹ thuật & Rủi ro Thiết kế (Technical Debt & Design Risks Audit - Milestone 4)

### 3.1 Nợ kỹ thuật trong JSON Schemas & Datamodel Definitions

1. **Sai lệch Thuộc tính Schema Cốt lõi (Schema Discrepancy)**:
   - File `sp-list.schema.json` định nghĩa chuẩn: `ListName`, `Columns`, `Name`.
   - File `ValidationHelpers.psm1` lại đòi hỏi: `Title`, `InternalName`, `Fields`.
   - **Đánh giá rủi ro**: Rất cao (Critical). Khiến công cụ validation CLI bị vô hiệu hóa hoàn toàn hoặc tạo cảnh báo giả (false positives).

2. **Thiếu ràng buộc Kiểu dữ liệu Tiền tệ & Lựa chọn (Choice & Currency Rigidness)**:
   - Các trường kiểu `Currency` trong schema JSON (ví dụ `expenses.json`, `financial_plans.json`) không khai báo Currency Symbol / Locale code, dựa hoàn toàn vào thiết lập mặc định của SharePoint Site regional settings.
   - Các trường `Choice` khai báo inline danh sách lựa chọn trong từng JSON list mà không có cơ chế kế thừa enumeration dùng chung.

3. **Cảnh báo Ngưỡng Giới hạn SharePoint (Threshold Risk)**:
   - Một số danh sách thuộc module `process_execution` (`projects.json`) và `strategy_crm` (`opportunities.json`) có số lượng trường tiệm cận ngưỡng 28-30 trường và 6-8 trường Lookup. Nếu phát sinh thêm nghiệp vụ sẽ vượt ngưỡng khuyến nghị hiển thị của SharePoint Online (List View Lookup Threshold = 12).

---

### 3.2 Nợ kỹ thuật trong PowerShell Scripts & Helper Modules

1. **Cơ chế Fallback Ngầm gây lừa đảo Trạng thái (Silent Fallback Hazard)**:
   - Trong `validate-sp-schemas.ps1:34-43`, khi hệ thống không cài đặt `ajv` CLI, script tự động chuyển sang đọc JSON bằng `ConvertFrom-Json` và in ra `[OK] JSON parsed successfully`.
   - **Rủi ro**: Developer lầm tưởng file JSON đã vượt qua kiểm tra JSON Schema validation, nhưng thực chất mới chỉ qua bước kiểm tra cú pháp JSON đơn thuần.

2. **Test Fixture Pester bị Lỗi thời (Outdated Test Fixtures)**:
   - Trong `tools/scripts/testing/modules.Tests.ps1:24-31`, fixture `valid-list.json` tạo cấu trúc:
     ```powershell
     $validList = @{ ListName = "TestList"; Columns = @(...) }
     ```
     Nhưng test case `Test-IDOPListSchema` gọi hàm `Test-IDOPListSchema` vốn đang bị bug đòi `Title` và `Fields`. Điều này khiến bộ test Pester bị sai lệch logic kiểm thử.

3. **Tồn tại Code Cổ điển (Legacy Code Spillover)**:
   - Trong `apply-sp-lists.ps1:260-270`, script vẫn duy trì block `Targeted mode (legacy behavior)` chứa các xử lý hardcoded cũ cho `CDEDocuments`, `PotentialProjects`, `Opportunities`.

4. **Lặp lại Mã nguồn Kiểm tra Phiên bản PWSH 7**:
   - Các script `validate-sp-naming.ps1`, `sp-diff.ps1`, `apply-sp-lists.ps1` đều tự viết lại đoạn code kiểm tra `$PSVersionTable.PSVersion.Major -lt 7` và re-exec `pwsh`. Đoạn code này nên được đóng gói vào helper chung.

---

### 3.3 Khoảng trống giữa Spec Docs và Code/Schemas Thực tế

1. **Thiếu Bảng Ánh ánh Tự động (Spec-to-Schema Mapping Gap)**:
   - Các tài liệu `specs/modules/*/spec.md` mô tả nghiệp vụ bằng tiếng Việt rất chi tiết (User stories, Acceptance criteria, BPMN flow), nhưng không có bảng tra cứu trực tiếp giữa Thuật ngữ Nghiệm vụ (ví dụ "Cơ hội kinh doanh", "Mức độ ưu tiên") với Cột JSON thực tế (`OpportunityCode`, `Priority`).

2. **API Spec Stubs Chưa Được Triển khai**:
   - Các file `api-spec.json` trong thư mục specs (như `specs/modules/strategy_crm/crm/api-spec.json`) chỉ đóng vai trò skeleton tĩnh, chưa được tự động tích hợp vào pipeline kiểm thử tích hợp (Contract Testing).

---

## 4. Đề xuất Cải tiến Kiến trúc & Refactoring (KISS-Compliant)

Thực hiện theo quy tắc **Double-Pass Adversarial Review**, mỗi đề xuất bên dưới đã trải qua 2 vòng kiểm chứng: (1) Kiểm tra implementation thực tế trong codebase; (2) Tự phản biện các rủi ro phát sinh.

### Đề xuất 1: Đồng bộ hóa Động cơ Validation (`ValidationHelpers.psm1`) với `sp-list.schema.json`
- **Mục tiêu**: Sửa triệt để bug bất đồng bộ thuộc tính giữa `ValidationHelpers.psm1` và `sp-list.schema.json`.
- **Giải pháp KISS**:
  - Cập nhật hàm `Test-IDOPListSchema` trong `ValidationHelpers.psm1`:
    - Đổi thuộc tính bắt buộc từ `('Title', 'InternalName', 'Description', 'Fields')` thành `('ListName', 'Columns')`.
    - Đổi vòng lặp duyệt trường từ `$json.Fields` thành `$json.Columns` và lấy tên trường từ `$field.Name`.
  - Phân loại rõ ràng: `ListName` theo PascalCase (`^[A-Z][a-zA-Z0-9]*$`), cột `Name` theo PascalCase.
- **Kết quả Kiểm chứng vòng 2**: Giải pháp sửa trực tiếp ~15 dòng code trong `ValidationHelpers.psm1`, không tạo thêm class/dependency mới, lập tức đưa `.\idop.ps1 validate datamodel` về trạng thái hoạt động chính xác.

### Đề xuất 2: Nâng cấp Bộ Kiểm tra Ràng buộc Tham chiếu (`Test-IDOPLookupAndTaxonomyReferences`)
- **Mục tiêu**: Đảm bảo 100% các liên kết Lookup và ManagedMetadata đều tồn tại đối tượng đích.
- **Giải pháp KISS**:
  - Mở rộng `Test-IDOPLookupReferences`:
    - Khi `$field.Type -eq 'Lookup'`, ngoài việc kiểm tra `$lookupList` có trong `$allLists`, kiểm tra thêm `$lookupField = $field.Lookup.Field` (mặc định 'ID'). Nếu `$lookupField -ne 'ID'`, xác minh `$lookupField` có nằm trong mảng `Columns.Name` của list đích hay không.
  - Xây dựng hàm mới `Test-IDOPTaxonomyReferences`:
    - Đọc tất cả file JSON trong `datamodel/sharepoint/taxonomy/`, lập mảng `$availableTermSets = @('CCBA_LoaiChiPhi', 'CCBA_NguonGocCoHoi', ...)`.
    - Khi gặp trường `ManagedMetadata`/`Taxonomy`, lấy `$tsName = $field.TermSet.Name`, kiểm tra `$tsName` có tồn tại trong `$availableTermSets` hay không.
- **Kết quả Kiểm chứng vòng 2**: Đảm bảo phát hiện ngay các lỗi gõ sai tên TermSet hoặc Lookup field từ trước khi chạy lệnh deploy PnP lên SharePoint.

### Đề xuất 3: Chuẩn hóa Pipeline Validation & Thống nhất CLI Gate
- **Mục tiêu**: Loại bỏ việc `idop.ps1` gọi rải rác các script bên ngoài và loại bỏ rủi ro silent fallback AJV.
- **Giải pháp KISS**:
  - Trong `validate-sp-schemas.ps1`: Nếu không tìm thấy `ajv`, phát cảnh báo rõ ràng `[WARN] AJV CLI not found. Falling back to basic syntax check. Install ajv-cli for schema validation.` và trả về return code phù hợp nếu chạy trong chế độ `--Strict`.
  - Tích hợp tất cả vào lệnh thống nhất: `.\idop.ps1 validate --Full` thực hiện tuần tự: (1) List Schema, (2) Taxonomy JSON, (3) Lookup References, (4) Taxonomy References, (5) Field Naming.

### Đề xuất 4: Đồng bộ Fixtures và Mở rộng Bộ Kiểm thử Pester
- **Mục tiêu**: Đưa `tools/scripts/testing/modules.Tests.ps1` trở lại xanh 100%.
- **Giải pháp KISS**:
  - Cập nhật fixture `$validList` trong `modules.Tests.ps1` sử dụng `ListName` và `Columns`.
  - Bổ sung test cases cho `Test-IDOPLookupReferences` và `Test-IDOPTaxonomyReferences`.

---

## 5. Lộ trình Chiến lược (Strategic Roadmap - Milestone 4)

Lộ trình được chia thành 2 giai đoạn: Ngắn hạn (< 3 tháng) tập trung vào củng cố độ tin cậy của mã nguồn hiện tại, và Dài hạn (3-12 tháng) tập trung vào tự động hóa và mở rộng kiến trúc.

```
       SHORT-TERM (< 3 MONTHS)                    LONG-TERM (3 - 12 MONTHS)
┌───────────────────────────────────┐    ┌───────────────────────────────────┐
│ Month 1: Schema & Validator Sync  │    │ Months 4-6: Drift Sync Engine     │
│ - Fix ValidationHelpers.psm1      │ ──►│ - Bidirectional SP-JSON Sync      │
│ - Fix Pester test fixtures        │    │ - Auto Schema Diff Alerting       │
└───────────────────────────────────┘    └───────────────────────────────────┘
                  │                                        │
                  ▼                                        ▼
┌───────────────────────────────────┐    ┌───────────────────────────────────┐
│ Month 2: Referential Integrity    │    │ Months 7-9: Spec-to-Schema Engine │
│ - Lookup Target Field Validation  │ ──►│ - Auto Documentation Sync         │
│ - Taxonomy Cross-Ref Validation   │    │ - Spec Contract Testing           │
└───────────────────────────────────┘    └───────────────────────────────────┘
                  │                                        │
                  ▼                                        ▼
┌───────────────────────────────────┐    ┌───────────────────────────────────┐
│ Month 3: Pre-Flight DRC CLI Gate  │    │ Months 10-12: Dataverse Bridge    │
│ - Unified `idop validate --all`   │ ──►│ - Export Dataverse Solutions      │
│ - CI/CD Integration Readiness     │    │ - Power Platform Alignment        │
└───────────────────────────────────┘    └───────────────────────────────────┘
```

### 5.1 Lộ trình Ngắn hạn (Short-Term Roadmap: < 3 tháng)

#### Giai đoạn 1 (Tháng 1): Đồng bộ hóa Schema & Động cơ Validation
- **Mục tiêu**: Khắc phục toàn bộ lỗi sai lệch thuộc tính và khôi phục hoạt động của bộ test suite.
- **Hành động cụ thể**:
  1. Refactor `ValidationHelpers.psm1` (`Test-IDOPListSchema`) để dùng chuẩn `ListName` / `Columns` / `Name`.
  2. Sửa file fixture Pester `tools/scripts/testing/modules.Tests.ps1`.
  3. Cập nhật `validate-sp-schemas.ps1` để cảnh báo minh bạch khi thiếu `ajv`.
- **Sản phẩm bàn giao**: Bộ validator hoạt động chính xác 100%, Pester tests pass hoàn toàn.

#### Giai đoạn 2 (Tháng 2): Hoàn thiện Bộ Kiểm tra Ràng buộc Tham chiếu
- **Mục tiêu**: Đảm bảo toàn vẹn dữ liệu cho Lookups và ManagedMetadata trước khi provisioning.
- **Hành động cụ thể**:
  1. Nâng cấp `Test-IDOPLookupReferences` kiểm tra cả sự tồn tại của `LookupField`.
  2. Xây dựng `Test-IDOPTaxonomyReferences` kiểm tra `TermSet.Name` đối soát với `datamodel/sharepoint/taxonomy/*.json`.
  3. Đóng gói quy tắc kiểm tra ngưỡng cột (Max 28 columns, Max 8 lookups) vào hàm `Test-IDOPListThresholds`.
- **Sản phẩm bàn giao**: Module `ValidationHelpers.psm1` hoàn chỉnh với đầy đủ tính năng kiểm tra tham chiếu chéo.

#### Giai đoạn 3 (Tháng 3): Chuẩn hóa Lệnh Pre-Flight & CLI Integration Gate
- **Mục tiêu**: Cung cấp lệnh đơn duy nhất để kiểm tra sẵn sàng triển khai (Deployment Readiness Check).
- **Hành động cụ thể**:
  1. Bổ sung subcommand `.\idop.ps1 validate datamodel -Full` hoặc `.\idop.ps1 check-readiness`.
  2. Tích hợp báo cáo bảng tổng hợp Readiness Check (5-Tier DRC Matrix).
- **Sản phẩm bàn giao**: Lệnh `idop.ps1 check-readiness` hoàn chỉnh phục vụ CI/CD.

---

### 5.2 Lộ trình Dài hạn (Long-Term Roadmap: 3-12 tháng)

#### Giai đoạn 4 (Tháng 4 - 6): Động cơ Đồng bộ Drift Hai chiều (Bi-directional Schema Drift Engine)
- **Mục tiêu**: Tự động phát hiện và đồng bộ sự sai lệch giữa môi trường SharePoint Online thực tế và repository JSON.
- **Hành động cụ thể**:
  1. Nâng cấp `sp-diff.ps1` thành động cơ có khả năng xuất file `.patch.json` khi phát hiện thay đổi trên SharePoint.
  2. Xây dựng lệnh `.\idop.ps1 sync from-sp` để hỗ trợ Reverse Engineering từ SharePoint về JSON schema local.
- **Giá trị mang lại**: Giữ cho codebase và môi trường Prod luôn đồng bộ 100%, chống trôi cấu trúc (Schema Drift).

#### Giai đoạn 5 (Tháng 7 - 9): Động cơ Vết Tích hợp Spec-to-Schema (Spec-to-Schema Traceability Engine)
- **Mục tiêu**: Tự động liên kết tài liệu đặc tả (`specs/modules/`) với dữ liệu triển khai thực tế (`datamodel/sharepoint/`).
- **Hành động cụ thể**:
  1. Phát triển công cụ tự động sinh tài liệu Data Dictionary từ file JSON list definitions.
  2. Kiểm tra tính tuân thủ giữa API Specs (`api-spec.json`) và SharePoint list schemas.
- **Giá trị mang lại**: Tài liệu kỹ thuật luôn được cập nhật tự động theo mã nguồn.

#### Giai đoạn 6 (Tháng 10 - 12): Cầu nối Dataverse & Power Platform (Power Platform & Dataverse Bridge)
- **Mục tiêu**: Cho phép IDOP mở rộng từ SharePoint Online sang Microsoft Dataverse / Power Apps Solution khi quy mô dữ liệu doanh nghiệp tăng trưởng.
- **Hành động cụ thể**:
  1. Xây dựng công cụ chuyển đổi (Transpiler) từ IDOP JSON List Definitions sang Dataverse Entity Definitions XML/JSON.
  2. Hỗ trợ provisioning tự động bảng Dataverse tương đương với các SharePoint List hiện tại.
- **Giá trị mang lại**: Sẵn sàng kiến trúc cho lộ trình chuyển đổi số quy mô lớn của CCBA / IBST.

---

## 6. Kết luận & Các bước Tiếp theo

Nghiên cứu cho thấy hệ thống IDOP-CCBA-WAY đã được thiết kế khung kiến trúc khai báo (Declarative Architecture) rất bài bản. Tuy nhiên, việc tồn tại sai lệch thuộc tính giữa module Validation và Schema chuẩn là điểm nghẽn lớn nhất cần được xử lý ngay trong Milestone 3 & 4. Việc thực hiện các đề xuất refactoring đơn giản, tuân thủ nguyên tắc KISS nêu trên sẽ nhanh chóng nâng cao độ tin cậy của toàn bộ nền tảng.
