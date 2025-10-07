# Bidding Folder Automation — Opportunities

Purpose: Automate OneDrive/SharePoint folder lifecycle for Opportunities.

Lineage: Customer → PotentialProjects → Opportunities → Contracts → Projects

Fields used (Opportunities list):
-  `BiddingFolderDriveItemId` (Text)
-  `BiddingFolderUrl` (Hyperlink)
-  `BiddingFolderPath` (Text)
-  `BiddingFolderState` (Choice: Not Created, Creating, Created, Failed)
-  `BiddingFolderPhase` (Choice: Draft, Confirmed, Archived)
-  `BiddingCode` (Text)
-  `ParticipationDecision` (Choice: Unknown, Yes, No)
-  `DecisionDate` (DateTime)
-  `DecisionNote` (Note)
-  `DecisionEmailLink` (Hyperlink)
-  `BidTeam` (User, multi)

Folder root: OneDrive of `ccba@ibst-bim.vn` → `00 Bidding/<YYYY>/`.

Naming: `<BiddingCode> - <CustomerShort> - <OpportunityName>`; store DriveItemId to survive rename/move.

Flows
-  Flow A — Create draft folder on Opportunity creation
   -  Trigger: When a row is added (SharePoint) in `Opportunities`.
   -  Conditions: `BiddingFolderState = Not Created`.
   -  Actions:
      -  Create folder in OneDrive: `00 Bidding/<YYYY>/<Name>`.
      -  Update `BiddingFolderDriveItemId`, `BiddingFolderUrl`, `BiddingFolderPath`.
      -  Set `BiddingFolderState = Created`, `BiddingFolderPhase = Draft`.

-  Flow B — Confirm participation (rename, scaffold, permissions)
   -  Trigger: On modification where `ParticipationDecision = Yes` OR `Stage = Proposal/HSDX`.
   -  Actions:
      -  Rename folder to finalized pattern, ensure subfolders (e.g., `01-HSDX`, `02-Emails`, `03-Estimates`).
      -  Update `BiddingFolderUrl`, `BiddingFolderPath`.
      -  Set `BiddingFolderPhase = Confirmed`.

-  Flow C — Not pursued (archive)
   -  Trigger: On modification where `ParticipationDecision = No` OR `Stage = Closed - Not Pursued`.
   -  Actions:
      -  Move folder under archive path `00 Bidding/Archive/<YYYY>/` or remove sharing.
      -  Update `BiddingFolderPhase = Archived`.

Permissions
- Restrict write to BidTeam during Draft; expand to leadership after Confirmed.

Notes
- Use Graph `driveItem` by `id` for rename/move to avoid broken links.
- Consider a PowerShell helper (`tools/scripts/create-bidding-folder.ps1`) for admin backfill.
