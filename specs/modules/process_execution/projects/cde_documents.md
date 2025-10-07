# CDEDocuments — Project Document Index

Purpose: Central index for project documents stored in SharePoint CDE libraries/folders,
enabling governance, approvals linkage, and analytics.

Key fields (from datamodel):
-  `Title` (required)
-  `ProjectId` (Lookup → Projects)
-  `ProjectCode` (Text, denormalized)
-  `DocumentCode` (Text, unique)
-  `DocumentType` (ManagedMetadata → CCBA_LoaiTaiLieu)
-  `Discipline` (ManagedMetadata → CCBA_ChucDanhXayDung)
-  `ServiceType` (ManagedMetadata → CCBA_LoaiHinhDichVu)
-  `Status` (ManagedMetadata → CCBA_TrangThaiChung)
-  `Version` (Text)
-  `FileUrl` (Hyperlink)
-  `SubmissionId` (Lookup → Submissions)
-  `RetentionUntil` (DateTime)
-  `Owner` (User)

Flows:
-  On document creation/update, populate `ProjectCode`, `DocumentCode` per naming convention.
-  Optional approval: create/associate a record in `Submissions` and link back via `SubmissionId`.
-  Retention: set `RetentionUntil` based on `DocumentType` policy.

RLS & Permissions:
-  Contributors: ProjectMembers + PMO; Readers: BLĐ.
-  Power BI RLS by `ProjectId`.

Open items:
-  JSON formatting for `Status` and `FileUrl`.
-  Enforce uniqueness for `DocumentCode` (via flow or validation rule).
