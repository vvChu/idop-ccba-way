# PotentialProjects — Pre-Contract Bridge

Purpose: Capture potential projects derived from CRM opportunities, before a contract and a formal project are created.

Key fields (from datamodel):
-  `Title` (required)
-  `OpportunityId` (Lookup → Opportunities)
-  `CustomerId` (Lookup → Customers)
-  `ContactId` (Lookup → Contacts)
-  `ExpectedContractValue` (Number)
-  `ServiceType` (ManagedMetadata → CCBA_LoaiHinhDichVu)
-  `Industry` (ManagedMetadata → CCBA_NganhLinhVuc)
-  `ProjectType` (ManagedMetadata → CCBA_LoaiCongTrinh)
-  `Priority` (ManagedMetadata → CCBA_MucDoUuTien)
-  `Stage` (Choice)
-  `EstimatedStart`/`EstimatedEnd` (DateTime)
-  `PMOOwner` (User)

Flows:
-  Create PotentialProject when Opportunity reaches a configured stage.
-  Validate uniqueness by `(OpportunityId, Title)` or naming rule.
-  When converted to Project, link back to the created `Projects` record.

Permissions:
-  Kinh doanh (Contribute), PMO (Read), BLĐ (Read).

Open items:
-  Add JSON formatting for `Stage` and board view.
