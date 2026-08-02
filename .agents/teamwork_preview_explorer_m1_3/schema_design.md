# IDOP-CCBA-WAY R1 Schema Design Specification & Validation Analysis

**Author**: Explorer 3 (`teamwork_preview_explorer`)  
**Milestone**: Milestone 1 (R1 Design Phase)  
**Date**: 2026-08-02  
**Target Path**: `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_3\schema_design.md`

---

## 1. Executive Summary & Architectural Context

Milestone 1 R1 focuses on finalizing the core data structures for **Process Execution & Financial Tier Allocations** in project IDOP-CCBA-WAY. In accordance with the CCBA Internal Financial Management Regulation (QCCTNB 3209, Phụ lục 7 & 8) and Technical Management Regulation (QCTK 2815), financial allocations are split into 3 tiers:
- **Tier 1**: Gross Contract Allocation (`NhomHopDongKT`, `TyLeGiaoDonVi`, `TyLeVienCPQL`, `TyLeVienKHTS`, `GiaTriGiaoDonVi`).
- **Tier 2**: Department Allocation (`ScopeDepartmentAllocations` for multi-department scope distribution).
- **Tier 3**: Technical & Execution Allocation (`JobAssignments` & `AssignmentDetails` for role assignments, legal role resolutions, certification checks, and allocated hours).

Additionally, execution governance requires tracking **National Bidding / Project Identifiers** (`NationalProjectID` in `Projects`) and implementing **ISO 19650 CDE Naming Containers & Approval Workflows** (`cde_documents.json`).

This document provides:
1. Analysis of `tools/idop.ps1` validator rules.
2. Complete field-by-field specifications for all 6 target JSON schemas.
3. Complete, production-ready JSON schema definitions adhering to `sp-list.schema.json`.

---

## 2. Validator Logic & Naming Conventions Analysis

### 2.1 Tool Inspection Summary (`tools/idop.ps1` & `ValidationHelpers.psm1`)
- **JSON Schema Syntax**: Validated against `datamodel/sharepoint/schemas/sp-list.schema.json`.
- **List Identifier (`ListName`)**: Must strictly follow **PascalCase** regex (`^[A-Z][a-zA-Z0-9]*$`).
- **Column Identifier (`Name`)**: Must strictly follow **PascalCase** regex (`^[A-Z][a-zA-Z0-9]*$`).
- **Field Type Enumeration**: Must be one of `Text`, `SingleLine`, `Note`, `Number`, `Currency`, `DateTime`, `Date`, `YesNo`, `Boolean`, `Choice`, `MultiChoice`, `Lookup`, `User`, `URL`, `Hyperlink`, `ManagedMetadata`, `Taxonomy`.
- **Lookup Integrity**: `Lookup` definitions require `"List"` (target `ListName`) and `"Field"` (default `"ID"`). Referenced target lists must exist in `datamodel/sharepoint/lists/`.
- **Taxonomy Integrity**: `ManagedMetadata` or `Taxonomy` fields require `"TermSet"` object with `"Group"` (e.g. `"CCBA Taxonomy"`) and `"Name"` (e.g. `"CCBA_NhomHopDongKT"`, `"CCBA_DonViPhongBan"`, `"CCBA_LoaiHinhDichVu"`, `"CCBA_ChucDanhXayDung"`).

---

## 3. Field-by-Field Design Specifications

### 3.1 `contract_scopes.json` (Tier 1 Financial Allocations)
- **Target List**: `ContractScopes`
- **Purpose**: Tracks contract breakdown items (scopes) and applies Tier 1 financial allocation percentages according to QCCTNB 3209 Appendix 7.
- **Fields Specification**:
  - `ContractId` (Lookup -> `Contracts`, Field: `ID`, Behavior: `restrict`): Primary contract link. Required: `true`.
  - `NhomHopDongKT` (ManagedMetadata -> `CCBA_NhomHopDongKT`): 10 standard economic contract groups (N1a to N4). Required: `true`.
  - `ScopeName` (Text): Name of scope / work package. Required: `true`.
  - `AmountBeforeVAT` (Number): Value before VAT in VND. Required: `true`.
  - `TyLeGiaoDonVi` (Number): Percentage allocated to unit/center (e.g. 96.00%, 91.00%, 82.00%).
  - `GiaTriGiaoDonVi` (Number): Calculated value allocated to unit/center (VND).
  - `TyLeVienCPQL` (Number): Percentage allocated to Institute Management Overhead (CPQL).
  - `GiaTriVienCPQL` (Number): Calculated Institute Management Overhead value (VND).
  - `TyLeVienKHTS` (Number): Percentage allocated to Institute Asset Depreciation (KHTS).
  - `GiaTriVienKHTS` (Number): Calculated Institute Asset Depreciation value (VND).
  - `KhungNhanCongMin` (Number): Minimum labor framework percentage.
  - `KhungNhanCongMax` (Number): Maximum labor framework percentage.

### 3.2 `scope_department_allocations.json` [NEW] (Tier 2 Multi-Department Allocations)
- **Target List**: `ScopeDepartmentAllocations`
- **Purpose**: Enables multi-department co-execution for a single contract scope, assigning allocation shares and amounts across departments.
- **Fields Specification**:
  - `ContractScopeId` (Lookup -> `ContractScopes`, Field: `ID`, Behavior: `restrict`): Reference to parent contract scope. Required: `true`.
  - `Department` (ManagedMetadata -> `CCBA_DonViPhongBan`): Department / unit executing the scope. Required: `true`.
  - `Role` (Choice: `["Lead", "Coordinating", "Supporting"]`): Role of department (Chủ trì / Phối hợp / Hỗ trợ). Required: `true`.
  - `AllocationShare` (Number): Department percentage share of unit funds (%). Required: `true`.
  - `AllocatedAmount` (Number): Department monetary value (VND). Required: `true`.
  - `DepartmentHead` (User, UserSelectionMode: `PeopleOnly`): Account of the Department Head responsible for execution.

### 3.3 `projects.json` (Execution Project Core)
- **Target List**: `Projects`
- **Purpose**: Internal execution project registry.
- **Fields Specification**:
  - `ProjectCode` (Text): Internal project code (e.g. PRJ-2026-001). Required: `true`.
  - `ProjectName` (Text): Full project title. Required: `true`.
  - `ContractId` (Lookup -> `Contracts`, Field: `ID`, Behavior: `restrict`): Associated economic contract.
  - `NationalProjectID` (Text): National bidding / public procurement system ID (Mã dự án trên Mạng đấu thầu quốc gia).
  - `ServiceType` (ManagedMetadata -> `CCBA_LoaiHinhDichVu`): Type of consulting / technical service.
  - `Budget` (Number): Project budget (VND).
  - `Status` (ManagedMetadata -> `CCBA_TrangThaiChung`): Execution status.
  - `CooperatingDepartment` (ManagedMetadata -> `CCBA_DonViPhongBan`): Coordinating internal unit.
  - `FundingSource` (ManagedMetadata -> `CCBA_NguonVon`): Funding source taxonomy.
  - `StartDate` (DateTime): Execution start date.
  - `EndDate` (DateTime): Execution target end date.

### 3.4 `job_assignments.json` (Tier 3 High-Level Key Person Assignment)
- **Target List**: `JobAssignments`
- **Purpose**: Links projects/scopes to key officers responsible for project execution, technical design, and financial administration.
- **Fields Specification**:
  - `ProjectId` (Lookup -> `Projects`, Field: `ID`, Behavior: `restrict`): Execution project reference.
  - `ContractScopeId` (Lookup -> `ContractScopes`, Field: `ID`, Behavior: `restrict`): Specific contract scope reference.
  - `EmployeeId` (Lookup -> `Employees`, Field: `ID`, Behavior: `restrict`): Employee reference.
  - `Role` (Text): Assignment summary role.
  - `ContractLeadUser` (User, UserSelectionMode: `PeopleOnly`): Contract Lead / Project Manager (ROLE_PROJECT_MANAGER).
  - `DesignChiefUser` (User, UserSelectionMode: `PeopleOnly`): Design / Technical Chief (Chủ trì Kỹ thuật).
  - `FinancialOfficerUser` (User, UserSelectionMode: `PeopleOnly`): Assigned Financial Officer (Cán bộ QL Tài chính).
  - `StartDate` (DateTime): Assignment start date.
  - `EndDate` (DateTime): Assignment end date.

### 3.5 `assignment_details.json` (Tier 3 Granular Work & Legal Role Resolution)
- **Target List**: `AssignmentDetails`
- **Purpose**: Granular task breakdown, mapping technical roles to legal construction titles, practice certificate verification flags, and hour allocations.
- **Fields Specification**:
  - `AssignmentId` (Lookup -> `JobAssignments`, Field: `ID`, Behavior: `restrict`): Parent job assignment. Required: `true`.
  - `ContractScopeId` (Lookup -> `ContractScopes`, Field: `ID`, Behavior: `restrict`): Associated contract scope.
  - `ScopeDeptAllocId` (Lookup -> `ScopeDepartmentAllocations`, Field: `ID`, Behavior: `restrict`): Department scope allocation reference.
  - `GenericRoleName` (Text): Technical / internal operational role name.
  - `AssignedTechnicalChiefUser` (User, UserSelectionMode: `PeopleOnly`): Assigned Lead Technical Officer.
  - `ResolvedLegalRole` (ManagedMetadata -> `CCBA_ChucDanhXayDung`): Mapped legal construction role per Decree 212/2026/NĐ-CP.
  - `RequiresCertCheck` (Boolean): Flag indicating mandatory practice certificate validation.
  - `DisciplineLead` (User, UserSelectionMode: `PeopleOnly`): Discipline Lead account.
  - `TeamMembers` (User, AllowMultiple: `true`, UserSelectionMode: `PeopleOnly`): Team members array.
  - `QCChecker` (User, UserSelectionMode: `PeopleOnly`): QA/QC Officer account.
  - `AllocatedHours` (Number): Planned allocated hours.
  - `TaskDescription` (Text): Detailed task description.
  - `HoursWorked` (Number): Actual recorded hours worked.
  - `Notes` (Note): Additional task execution notes.

### 3.6 `cde_documents.json` (ISO 19650 CDE Metadata & Approval Status)
- **Target List**: `CDEDocuments`
- **Purpose**: ISO 19650 document registry, container naming metadata, and approval stage tracking.
- **Fields Specification**:
  - `Title` (Text): Document title. Required: `true`.
  - `Project` (Lookup -> `Projects`, Field: `ID`, Behavior: `restrict`): Associated project.
  - `ProjectCode` (Text): ISO 19650 Container 1 (Project Code).
  - `Originator` (Text): ISO 19650 Container 2 (Originator Code, e.g. CCBA, IBST).
  - `VolumeOrSystem` (Text): ISO 19650 Container 3 (Volume / System Code, e.g. BLK-A, SYS-01, ZZ).
  - `LevelOrLocation` (Text): ISO 19650 Container 4 (Level / Location Code, e.g. FL-01, RF, ZZ).
  - `DocumentType` (ManagedMetadata -> `CCBA_LoaiTaiLieu`): ISO 19650 Container 5 (Document Type).
  - `Discipline` (ManagedMetadata -> `CCBA_ChucDanhXayDung`): ISO 19650 Container 6 (Discipline).
  - `SequentialNumber` (Text): ISO 19650 Container 7 (Sequential Number, e.g. 0001).
  - `DocumentCode` (Text): Full ISO 19650 Document Code standard string.
  - `ISOApprovalStatus` (Choice: `["S0", "S1", "S2", "S3", "A1"]`): Approval State (`S0`: WIP, `S1`: Shared-Coordination, `S2`: Shared-Info, `S3`: Shared-Review, `A1`: Published).
  - `ServiceType` (ManagedMetadata -> `CCBA_LoaiHinhDichVu`): Service classification.
  - `Status` (ManagedMetadata -> `CCBA_TrangThaiChung`): General document state.
  - `Version` (Text): Revision / Version code (e.g. P01.01, C01).
  - `FileUrl` (Hyperlink): OneDrive / SharePoint document URL link.
  - `Submission` (Lookup -> `Submissions`, Field: `ID`, Behavior: `cascade`): Submission record link.
  - `RetentionUntil` (DateTime): Document retention expiration date.
  - `Owner` (User): Document owner account.

---

## 4. Production JSON Schema Definitions

### 4.1 `contract_scopes.json`
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

### 4.2 `scope_department_allocations.json` [NEW]
```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "ScopeDepartmentAllocations",
  "Description": "Phân bổ kinh phí hạng mục hợp đồng cho nhiều phòng ban thực hiện (Phụ lục 7 QCCTNB 3209)",
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
      "DisplayName": "Hạng mục hợp đồng",
      "Description": "Liên kết đến Hạng mục Hợp đồng kinh tế (ContractScopes)"
    },
    {
      "Name": "Department",
      "Type": "ManagedMetadata",
      "Required": true,
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_DonViPhongBan"
      },
      "DisplayName": "Phòng ban / Đơn vị thực hiện",
      "Description": "Phòng ban hoặc Đơn vị chủ trì/phối hợp thực hiện"
    },
    {
      "Name": "Role",
      "Type": "Choice",
      "Required": true,
      "Choices": [
        "Lead",
        "Coordinating",
        "Supporting"
      ],
      "DisplayName": "Vai trò đơn vị (Chủ trì / Phối hợp)",
      "Description": "Vai trò thực hiện hạng mục của đơn vị"
    },
    {
      "Name": "AllocationShare",
      "Type": "Number",
      "Required": true,
      "DisplayName": "Tỷ lệ phân bổ đơn vị (%)",
      "Description": "Tỷ lệ phần trăm kinh phí đơn vị được phân bổ"
    },
    {
      "Name": "AllocatedAmount",
      "Type": "Number",
      "Required": true,
      "DisplayName": "Kinh phí phân bổ đơn vị (VND)",
      "Description": "Kinh phí quy đổi theo tỷ lệ phân bổ đơn vị"
    },
    {
      "Name": "DepartmentHead",
      "Type": "User",
      "Required": false,
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Trưởng đơn vị / Trưởng phòng",
      "Description": "Tài khoản Trưởng phòng ban / Trưởng đơn vị nhận giao nộp"
    }
  ],
  "ContentTypes": []
}
```

### 4.3 `projects.json`
```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "Projects",
  "Description": "Dự án thực thi nội bộ CCBA",
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
      "Name": "NationalProjectID",
      "Type": "Text",
      "DisplayName": "Mã dự án Quốc gia / Đấu thầu",
      "Description": "Mã định danh dự án trên Mạng đấu thầu quốc gia / Cổng Dịch vụ công Quốc gia"
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
      "Name": "Budget",
      "Type": "Number",
      "DisplayName": "Ngân sách dự án (VND)"
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

### 4.4 `job_assignments.json`
```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "JobAssignments",
  "Description": "Phân công công việc & Điều hành nhân sự chủ trì theo Hợp đồng / Hạng mục",
  "Columns": [
    {
      "Name": "ProjectId",
      "Type": "Lookup",
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
      "DisplayName": "Hạng mục hợp đồng",
      "Description": "Liên kết trực tiếp tới Hạng mục Hợp đồng kinh tế"
    },
    {
      "Name": "EmployeeId",
      "Type": "Lookup",
      "Lookup": {
        "List": "Employees",
        "Field": "ID",
        "Behavior": "restrict"
      },
      "DisplayName": "Cán bộ thực hiện"
    },
    {
      "Name": "Role",
      "Type": "Text",
      "DisplayName": "Vai trò phân công"
    },
    {
      "Name": "ContractLeadUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì Hợp đồng (Chủ nhiệm Dự án)",
      "Description": "Cán bộ giữ vai trò Chủ trì HĐ / Chủ nhiệm Dự án (ROLE_PROJECT_MANAGER)"
    },
    {
      "Name": "DesignChiefUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì Thiết kế / Kỹ thuật",
      "Description": "Cán bộ giữ vai trò Chủ trì Thiết kế / Kỹ thuật chính"
    },
    {
      "Name": "FinancialOfficerUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Cán bộ Quản lý Tài chính",
      "Description": "Cán bộ phụ trách quản lý tài chính & thanh quyết toán dự án"
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

### 4.5 `assignment_details.json`
```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "AssignmentDetails",
  "Description": "Chi tiết giao việc, ánh xạ vai trò kỹ thuật/pháp lý & kiểm soát năng lực hành nghề",
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
      "DisplayName": "Phân công công việc"
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
      "DisplayName": "Phân bổ phòng ban hạng mục"
    },
    {
      "Name": "GenericRoleName",
      "Type": "Text",
      "DisplayName": "Vai trò kỹ thuật / Quy đổi"
    },
    {
      "Name": "AssignedTechnicalChiefUser",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì Kỹ thuật được phân công"
    },
    {
      "Name": "ResolvedLegalRole",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_ChucDanhXayDung"
      },
      "DisplayName": "Vai trò pháp lý được ánh xạ"
    },
    {
      "Name": "RequiresCertCheck",
      "Type": "Boolean",
      "DisplayName": "Yêu cầu kiểm tra chứng chỉ hành nghề"
    },
    {
      "Name": "DisciplineLead",
      "Type": "User",
      "UserSelectionMode": "PeopleOnly",
      "DisplayName": "Chủ trì Chuyên ngành"
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
      "DisplayName": "Cán bộ QA/QC kiểm tra"
    },
    {
      "Name": "AllocatedHours",
      "Type": "Number",
      "DisplayName": "Số giờ phân bổ (Hours)"
    },
    {
      "Name": "TaskDescription",
      "Type": "Text",
      "DisplayName": "Mô tả nhiệm vụ / Công việc"
    },
    {
      "Name": "HoursWorked",
      "Type": "Number",
      "DisplayName": "Số giờ thực tế đã làm"
    },
    {
      "Name": "Notes",
      "Type": "Note",
      "DisplayName": "Ghi chú"
    }
  ],
  "ContentTypes": []
}
```

### 4.6 `cde_documents.json`
```json
{
  "$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  "ListName": "CDEDocuments",
  "Description": "Chỉ mục tài liệu CDE theo chuẩn ISO 19650, quản lý siêu dữ liệu định danh & trạng thái phê duyệt",
  "Columns": [
    {
      "Name": "Title",
      "Type": "Text",
      "Required": true,
      "DisplayName": "Tiêu đề tài liệu"
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
      "DisplayName": "Mã dự án (ISO 19650 Container 1)",
      "Description": "Mã dự án để hỗ trợ tra cứu nhanh và RLS"
    },
    {
      "Name": "Originator",
      "Type": "Text",
      "DisplayName": "Đơn vị phát hành (ISO 19650 Container 2)",
      "Description": "Mã đơn vị/tổ chức phát hành (e.g. CCBA, IBST)"
    },
    {
      "Name": "VolumeOrSystem",
      "Type": "Text",
      "DisplayName": "Khối / Hệ thống (ISO 19650 Container 3)",
      "Description": "Mã khối hoặc hệ thống công trình (e.g. BLK-A, SYS-01, ZZ)"
    },
    {
      "Name": "LevelOrLocation",
      "Type": "Text",
      "DisplayName": "Tầng / Vị trí (ISO 19650 Container 4)",
      "Description": "Mã tầng hoặc vị trí công trình (e.g. FL-01, RF, ZZ)"
    },
    {
      "Name": "DocumentType",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_LoaiTaiLieu"
      },
      "DisplayName": "Loại tài liệu (ISO 19650 Container 5)"
    },
    {
      "Name": "Discipline",
      "Type": "ManagedMetadata",
      "TermSet": {
        "Group": "CCBA Taxonomy",
        "Name": "CCBA_ChucDanhXayDung"
      },
      "DisplayName": "Chuyên ngành (ISO 19650 Container 6)"
    },
    {
      "Name": "SequentialNumber",
      "Type": "Text",
      "DisplayName": "Số thứ tự tài liệu (ISO 19650 Container 7)",
      "Description": "Số thứ tự tài liệu trong container (e.g. 0001, 0002)"
    },
    {
      "Name": "DocumentCode",
      "Type": "Text",
      "DisplayName": "Mã tài liệu ISO 19650 hoàn chỉnh",
      "Description": "Mã tài liệu chuẩn hóa ghép từ 7 thành phần ISO 19650"
    },
    {
      "Name": "ISOApprovalStatus",
      "Type": "Choice",
      "Choices": [
        "S0",
        "S1",
        "S2",
        "S3",
        "A1"
      ],
      "DisplayName": "Trạng thái phê duyệt CDE (ISO 19650)",
      "Description": "S0: WIP, S1: Shared-Coordination, S2: Shared-Info, S3: Shared-Review, A1: Published"
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
      "DisplayName": "Trạng thái chung"
    },
    {
      "Name": "Version",
      "Type": "Text",
      "DisplayName": "Phiên bản"
    },
    {
      "Name": "FileUrl",
      "Type": "Hyperlink",
      "DisplayName": "Liên kết tệp CDE",
      "Description": "Liên kết tới file/thư mục trong CDE (SharePoint/OneDrive)"
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
      "DisplayName": "Ngày hết hạn lưu trữ",
      "Description": "Ngày hết hạn lưu trữ theo chính sách"
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

## 5. Validation & Verification Method

1. **JSON Schema Syntax**:
   Passes `sp-list.schema.json` draft-07 validation.
2. **Datamodel Suite Command**:
   Run `pwsh -Command ".\idop.ps1 validate datamodel"`
3. **Lookup Reference Integrity**:
   Run `pwsh -Command ".\idop.ps1 validate lookups"`
   - `ScopeDepartmentAllocations.ContractScopeId` -> `ContractScopes.ID`
   - `AssignmentDetails.ContractScopeId` -> `ContractScopes.ID`
   - `AssignmentDetails.ScopeDeptAllocId` -> `ScopeDepartmentAllocations.ID`
   - `JobAssignments.ContractScopeId` -> `ContractScopes.ID`

---
