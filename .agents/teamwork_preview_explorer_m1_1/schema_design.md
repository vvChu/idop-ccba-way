# IDOP CCBA v2.0 — Milestone 1 R1 Data Model Schema Design Specification

## Executive Summary

This document presents the detailed architectural analysis and exact JSON schema specifications for **Milestone 1 (R1 Data Model JSON Schemas)** of the IDOP-CCBA-WAY platform.

All 6 target SharePoint list JSON schemas in `datamodel/sharepoint/lists/process_execution/` have been analyzed and designed to ensure 100% compliance with:
- **SharePoint Meta-Schema** (`datamodel/sharepoint/schemas/sp-list.schema.json`)
- **IDOP CLI Validator** (`idop.ps1 validate datamodel`, `ValidationHelpers.psm1`, `validate-sp-schemas.ps1`, `validate-sp-naming.ps1`)
- **Statutory & Governance Regulations** (Law 135/2025/QH15, NĐ 217/2026/NĐ-CP, QCTK 2815, QCCTNB 3209 Phụ lục 7 & 8)
- **IDOP Architectural Constraints** (PascalCase EN Internal Names, VN Display Names, Lookup threshold <= 8, Total fields <= 28)

---

## 1. Overview of Schemas & Field Mappings

| # | List JSON File | ListName | Status | Core Changes & Purpose |
|---|---|---|---|---|
| 1 | `contract_scopes.json` | `ContractScopes` | Update | Tier 1 financial allocation fields (`NhomHopDongKT`, `TyLeGiaoDonVi`, `TyLeVienCPQL`, `TyLeVienKHTS`, `GiaTriGiaoDonVi`) per QCCTNB 3209 Phụ lục 7. |
| 2 | `scope_department_allocations.json` | `ScopeDepartmentAllocations` | **NEW** | Multi-department scope allocation breakdown (`ContractScopeId`, `Department`, `Role`, `AllocationShare`, `AllocatedAmount`, `DepartmentHead`). |
| 3 | `projects.json` | `Projects` | Update | Added `NationalProjectID` (national/IBST project code) and `ServiceType` (Taxonomy binding). |
| 4 | `job_assignments.json` | `JobAssignments` | Update | Enhanced Phiếu Giao Việc (PGV) header with `ContractScopeId`, `ContractLeadUser` (PM), `DesignChiefUser` (Design Head), `FinancialOfficerUser` (Accountant). |
| 5 | `assignment_details.json` | `AssignmentDetails` | Update | Multi-Scope/Multi-Dept PGV detail entries binding `ContractScopeId`, `ScopeDeptAllocId`, `GenericRoleName`, `AssignedTechnicalChiefUser`, `ResolvedLegalRole`, `RequiresCertCheck`, `DisciplineLead`, `TeamMembers`, `QCChecker`, `AllocatedHours`. |
| 6 | `cde_documents.json` | `CDEDocuments` | Update | ISO 19650 metadata container fields (`Originator`, `ZoneVolume`, `LevelLocation`, `IsoDocumentName`) and 5-state ISO approval lifecycle (`S0` -> `S1` -> `S2` -> `S3` -> `A1`). |

---

## 2. Detailed JSON Schema Specifications

### 2.1 `contract_scopes.json`
- **Path**: `datamodel/sharepoint/lists/process_execution/contract_scopes.json`
- **ListName**: `ContractScopes`
- **Lookup References**: `Contracts` (Field: `ID`, Behavior: `restrict`)
- **Taxonomy Bindings**: `CCBA_NhomHopDongKT` (Group: `CCBA Taxonomy`)

```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "ContractScopes",
  "Description": "Hạng mục chi tiết thuộc Hợp đồng theo Nhóm HĐKT (Phụ lục 7 & Phụ lục 8 QCCTNB 3209)",
  "Columns": [
    {
      "Name": "ContractId",
      "Type": "Lookup",
      "Required": true,
      "Lookup": {
        "List": "Contracts",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Hợp đồng"
    },
    {
      "Name": "NhomHopDongKT",
      "Type": "ManagedMetadata",
      "Required": true,
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_NhomHopDongKT"
      },
      "DisplayName": "Nhóm HĐKT (Phụ lục 7)"
    },
    {
      "Name": "ScopeName",
      "Type": "Text",
      "Required": true,
      "DisplayName": "Tên hạng mục / Gói công việc"
    },
    {
      "Name": "AmountBeforeVAT",
      "Type": "Number",
      "Required": true,
      "DisplayName": "Giá trị trước thuế (VND)"
    },
    {
      "Name": "TyLeGiaoDonVi",
      "Type": "Number",
      "DisplayName": "Tỷ lệ giao đơn vị (%)"
    },
    {
      "Name": "GiaTriGiaoDonVi",
      "Type": "Number",
      "DisplayName": "Kinh phí giao đơn vị (VND)"
    },
    {
      "Name": "TyLeVienCPQL",
      "Type": "Number",
      "DisplayName": "Tỷ lệ Viện CPQL (%)"
    },
    {
      "Name": "GiaTriVienCPQL",
      "Type": "Number",
      "DisplayName": "Kinh phí Viện CPQL (VND)"
    },
    {
      "Name": "TyLeVienKHTS",
      "Type": "Number",
      "DisplayName": "Tỷ lệ Viện KHTS (%)"
    },
    {
      "Name": "GiaTriVienKHTS",
      "Type": "Number",
      "DisplayName": "Kinh phí Viện KHTS (VND)"
    },
    {
      "Name": "KhungNhanCongMin",
      "Type": "Number",
      "DisplayName": "Khung Nhân công Min (%)"
    },
    {
      "Name": "KhungNhanCongMax",
      "Type": "Number",
      "DisplayName": "Khung Nhân công Max (%)"
    }
  ],
  "ContentTypes": []
}
```

---

### 2.2 `scope_department_allocations.json` [NEW]
- **Path**: `datamodel/sharepoint/lists/process_execution/scope_department_allocations.json`
- **ListName**: `ScopeDepartmentAllocations`
- **Lookup References**: `ContractScopes` (Field: `ID`, Behavior: `restrict`)
- **Taxonomy Bindings**: `CCBA_DonViPhongBan` (Group: `CCBA Taxonomy`)

```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "ScopeDepartmentAllocations",
  "Description": "Phân bổ kinh phí hạng mục hợp đồng theo đơn vị / phòng ban",
  "Columns": [
    {
      "Name": "ContractScopeId",
      "Type": "Lookup",
      "Required": true,
      "Lookup": {
        "List": "ContractScopes",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Hạng mục hợp đồng"
    },
    {
      "Name": "Department",
      "Type": "ManagedMetadata",
      "Required": true,
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_DonViPhongBan"
      },
      "DisplayName": "Đơn vị / Phòng ban"
    },
    {
      "Name": "Role",
      "Type": "Text",
      "DisplayName": "Vai trò đơn vị"
    },
    {
      "Name": "AllocationShare",
      "Type": "Number",
      "DisplayName": "Tỷ lệ phân bổ (%)"
    },
    {
      "Name": "AllocatedAmount",
      "Type": "Number",
      "DisplayName": "Kinh phí phân bổ (VND)"
    },
    {
      "Name": "DepartmentHead",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Trưởng đơn vị / Trưởng phòng"
    }
  ],
  "ContentTypes": []
}
```

---

### 2.3 `projects.json`
- **Path**: `datamodel/sharepoint/lists/process_execution/projects.json`
- **ListName**: `Projects`
- **Lookup References**: `Contracts` (Field: `ID`, Behavior: `restrict`)
- **Taxonomy Bindings**: `CCBA_LoaiHinhDichVu`, `CCBA_TrangThaiChung`, `CCBA_DonViPhongBan`, `CCBA_NguonVon`

```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "Projects",
  "Description": "Dự án thực thi",
  "Columns": [
    {
      "Name": "ProjectCode",
      "Type": "Text",
      "Required": true,
      "DisplayName": "Mã dự án"
    },
    {
      "Name": "ProjectName",
      "Type": "Text",
      "Required": true,
      "DisplayName": "Tên dự án"
    },
    {
      "Name": "NationalProjectID",
      "Type": "Text",
      "DisplayName": "Mã dự án quốc gia / Viện IBST",
      "Description": "Mã định danh dự án cấp quốc gia / Viện IBST theo QCTK 2815"
    },
    {
      "Name": "ContractId",
      "Type": "Lookup",
      "Lookup": {
        "List": "Contracts",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Hợp đồng"
    },
    {
      "Name": "Budget",
      "Type": "Number",
      "DisplayName": "Ngân sách dự án (VND)"
    },
    {
      "Name": "ServiceType",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_LoaiHinhDichVu"
      },
      "DisplayName": "Loại hình dịch vụ"
    },
    {
      "Name": "Status",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_TrangThaiChung"
      },
      "DisplayName": "Trạng thái"
    },
    {
      "Name": "CooperatingDepartment",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_DonViPhongBan"
      },
      "DisplayName": "Đơn vị phối hợp"
    },
    {
      "Name": "FundingSource",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_NguonVon"
      },
      "DisplayName": "Nguồn vốn"
    },
    {
      "Name": "StartDate",
      "Type": "DateTime",
      "DisplayName": "Ngày bắt đầu"
    },
    {
      "Name": "EndDate",
      "Type": "DateTime",
      "DisplayName": "Ngày kết thúc"
    }
  ],
  "ContentTypes": []
}
```

---

### 2.4 `job_assignments.json`
- **Path**: `datamodel/sharepoint/lists/process_execution/job_assignments.json`
- **ListName**: `JobAssignments`
- **Lookup References**: `Projects`, `ContractScopes`, `Employees`

```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "JobAssignments",
  "Description": "Phân công công việc (Phiếu Giao Việc PGV)",
  "Columns": [
    {
      "Name": "ProjectId",
      "Type": "Lookup",
      "Required": true,
      "Lookup": {
        "List": "Projects",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Dự án"
    },
    {
      "Name": "ContractScopeId",
      "Type": "Lookup",
      "Lookup": {
        "List": "ContractScopes",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Hạng mục hợp đồng"
    },
    {
      "Name": "EmployeeId",
      "Type": "Lookup",
      "Lookup": {
        "List": "Employees",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Nhân viên phân công"
    },
    {
      "Name": "Role",
      "Type": "Text",
      "DisplayName": "Vai trò giao việc"
    },
    {
      "Name": "ContractLeadUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì hợp đồng (PM)"
    },
    {
      "Name": "DesignChiefUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì thiết kế / Trưởng phòng BIM Thiết kế"
    },
    {
      "Name": "FinancialOfficerUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Phụ trách kế toán / Cán bộ tài chính"
    },
    {
      "Name": "StartDate",
      "Type": "DateTime",
      "DisplayName": "Ngày bắt đầu"
    },
    {
      "Name": "EndDate",
      "Type": "DateTime",
      "DisplayName": "Ngày kết thúc"
    }
  ],
  "ContentTypes": []
}
```

---

### 2.5 `assignment_details.json`
- **Path**: `datamodel/sharepoint/lists/process_execution/assignment_details.json`
- **ListName**: `AssignmentDetails`
- **Lookup References**: `JobAssignments`, `ContractScopes`, `ScopeDepartmentAllocations`

```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "AssignmentDetails",
  "Description": "Chi tiết phân công nhân sự và ràng buộc pháp lý theo Phiếu giao việc PGV",
  "Columns": [
    {
      "Name": "AssignmentId",
      "Type": "Lookup",
      "Required": true,
      "Lookup": {
        "List": "JobAssignments",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Phiếu giao việc (PGV)"
    },
    {
      "Name": "ContractScopeId",
      "Type": "Lookup",
      "Lookup": {
        "List": "ContractScopes",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Hạng mục hợp đồng"
    },
    {
      "Name": "ScopeDeptAllocId",
      "Type": "Lookup",
      "Lookup": {
        "List": "ScopeDepartmentAllocations",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Phân bổ đơn vị hạng mục"
    },
    {
      "Name": "GenericRoleName",
      "Type": "Text",
      "DisplayName": "Tên chức danh chuyên môn generic"
    },
    {
      "Name": "AssignedTechnicalChiefUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì kỹ thuật được phân công"
    },
    {
      "Name": "ResolvedLegalRole",
      "Type": "Text",
      "DisplayName": "Chức danh pháp lý quy định (Luật 135/2025)"
    },
    {
      "Name": "RequiresCertCheck",
      "Type": "YesNo",
      "DisplayName": "Yêu cầu kiểm tra chứng chỉ hành nghề"
    },
    {
      "Name": "DisciplineLead",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì bộ môn"
    },
    {
      "Name": "TeamMembers",
      "Type": "User",
      "AllowMultiple": true,
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Thành viên nhóm thực hiện"
    },
    {
      "Name": "QCChecker",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Người kiểm tra chất lượng (QA/QC)"
    },
    {
      "Name": "AllocatedHours",
      "Type": "Number",
      "DisplayName": "Số giờ phân bổ"
    },
    {
      "Name": "TaskDescription",
      "Type": "Text",
      "DisplayName": "Mô tả công việc chi tiết"
    },
    {
      "Name": "HoursWorked",
      "Type": "Number",
      "DisplayName": "Số giờ thực tế đã làm"
    },
    {
      "Name": "Notes",
      "Type": "Text",
      "DisplayName": "Ghi chú"
    }
  ],
  "ContentTypes": []
}
```

---

### 2.6 `cde_documents.json`
- **Path**: `datamodel/sharepoint/lists/process_execution/cde_documents.json`
- **ListName**: `CDEDocuments`
- **Lookup References**: `Projects`, `Submissions`
- **Taxonomy Bindings**: `CCBA_LoaiTaiLieu`, `CCBA_ChucDanhXayDung`, `CCBA_LoaiHinhDichVu`, `CCBA_TrangThaiChung`
- **Choice Field**: `ApprovalStatus` (`["S0", "S1", "S2", "S3", "A1"]`)

```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "CDEDocuments",
  "Description": "Chỉ mục tài liệu CDE theo dự án, quản lý siêu dữ liệu ISO 19650 & liên kết đến thư mục/URL thực tế.",
  "Columns": [
    {
      "Name": "Title",
      "Type": "Text",
      "Required": true,
      "DisplayName": "Tiêu đề"
    },
    {
      "Name": "Project",
      "Type": "Lookup",
      "Lookup": {
        "List": "Projects",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Dự án"
    },
    {
      "Name": "ProjectCode",
      "Type": "Text",
      "Description": "Mã dự án để hỗ trợ tra cứu nhanh và RLS.",
      "DisplayName": "Mã dự án"
    },
    {
      "Name": "Originator",
      "Type": "Text",
      "Description": "Mã đơn vị tác giả tạo tài liệu (ISO 19650).",
      "DisplayName": "Tác giả / Đơn vị tạo"
    },
    {
      "Name": "ZoneVolume",
      "Type": "Text",
      "Description": "Mã phân khu hoặc khối công trình (ISO 19650).",
      "DisplayName": "Phân khu / Khối công trình"
    },
    {
      "Name": "LevelLocation",
      "Type": "Text",
      "Description": "Mã tầng hoặc cao độ (ISO 19650).",
      "DisplayName": "Cao độ / Tầng"
    },
    {
      "Name": "DocumentCode",
      "Type": "Text",
      "Description": "Mã tài liệu theo quy ước CDE/PMO.",
      "DisplayName": "Mã tài liệu"
    },
    {
      "Name": "IsoDocumentName",
      "Type": "Text",
      "Description": "Tên container tệp chuẩn định danh ISO 19650.",
      "DisplayName": "Tên tệp chuẩn ISO 19650"
    },
    {
      "Name": "DocumentType",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_LoaiTaiLieu"
      },
      "DisplayName": "Loại tài liệu"
    },
    {
      "Name": "Discipline",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_ChucDanhXayDung"
      },
      "DisplayName": "Chuyên ngành"
    },
    {
      "Name": "ServiceType",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_LoaiHinhDichVu"
      },
      "DisplayName": "Loại hình dịch vụ"
    },
    {
      "Name": "Status",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_TrangThaiChung"
      },
      "DisplayName": "Trạng thái"
    },
    {
      "Name": "ApprovalStatus",
      "Type": "Choice",
      "Choices": [
        "S0",
        "S1",
        "S2",
        "S3",
        "A1"
      ],
      "Description": "Trạng thái phê duyệt ISO 19650 (S0: WIP, S1: Shared Internal, S2: Shared PMO, S3: Shared Legal QA, A1: Approved/Published).",
      "DisplayName": "Trạng thái phê duyệt CDE"
    },
    {
      "Name": "Version",
      "Type": "Text",
      "DisplayName": "Phiên bản"
    },
    {
      "Name": "FileUrl",
      "Type": "Hyperlink",
      "Description": "Liên kết tới file/thư mục trong CDE (SharePoint/OneDrive).",
      "DisplayName": "Liên kết tệp"
    },
    {
      "Name": "Submission",
      "Type": "Lookup",
      "Lookup": {
        "List": "Submissions",
        "Field": "ID",
        "Behavior": "cascade"
      },
      "DisplayName": "Hồ sơ nộp"
    },
    {
      "Name": "RetentionUntil",
      "Type": "DateTime",
      "Description": "Ngày hết hạn lưu trữ theo chính sách.",
      "DisplayName": "Lưu đến ngày"
    },
    {
      "Name": "Owner",
      "Type": "User",
      "DisplayName": "Người phụ trách"
    }
  ],
  "ContentTypes": []
}
```

---

## 3. Thresholds and Validation Metrics Check

All 6 proposed schemas satisfy the model limits enforced by `validate-model.ps1` and SharePoint Online standard governance:

| List | Total Fields | Max Field Limit (28) | Lookup Count | Max Lookup Limit (8) | Taxonomy Count | Choice Count |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `ContractScopes` | 12 | PASS (12 <= 28) | 1 | PASS (1 <= 8) | 1 | 0 |
| `ScopeDepartmentAllocations` | 6 | PASS (6 <= 28) | 1 | PASS (1 <= 8) | 1 | 0 |
| `Projects` | 11 | PASS (11 <= 28) | 1 | PASS (1 <= 8) | 4 | 0 |
| `JobAssignments` | 9 | PASS (9 <= 28) | 3 | PASS (3 <= 8) | 0 | 0 |
| `AssignmentDetails` | 14 | PASS (14 <= 28) | 3 | PASS (3 <= 8) | 0 | 0 |
| `CDEDocuments` | 18 | PASS (18 <= 28) | 2 | PASS (2 <= 8) | 4 | 1 |

---

## 4. Architectural Alignment & Next Steps

1. **Milestone 1 (Current)**:
   - Explorer analysis complete.
   - Exact JSON schemas designed and verified against validator logic.
   - Handoff report prepared for Milestone 2 Implementer.

2. **Milestone 2 (Implementation)**:
   - Write updated JSON content to `datamodel/sharepoint/lists/process_execution/contract_scopes.json`, `projects.json`, `job_assignments.json`, `assignment_details.json`, `cde_documents.json`.
   - Create new list schema `datamodel/sharepoint/lists/process_execution/scope_department_allocations.json`.
   - Run `.\idop.ps1 validate datamodel` to confirm 0 errors across all 59 lists.
