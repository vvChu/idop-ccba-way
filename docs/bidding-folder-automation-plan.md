# Bidding Folder Automation — Opportunities

Last updated: 2025-09-22

## Objective
Automate creation and lifecycle of OneDrive/SharePoint bidding folders linked to `Opportunities`, using the enriched schema fields.

## Driving fields (Opportunities)
- `PotentialProject` (Lookup → PotentialProjects)
- `BiddingFolderDriveItemId` (Text)
- `BiddingFolderUrl` (URL)
- `BiddingFolderPath` (Text)
- `BiddingFolderState` (Choice: Not Created | Creating | Created | Failed)
- `BiddingFolderPhase` (Choice: Draft | Confirmed | Archived)
- `BiddingCode` (Text)
- `ParticipationDecision` (Choice: Unknown | Yes | No)
- `DecisionDate` (DateTime)
- `DecisionNote` (Note)
- `DecisionEmailLink` (URL)
- `BidTeam` (UserMulti)

## Flow set
- Flow A — Create Draft folder
  - Trigger: When an item is created or ParticipationDecision moves from `Unknown` → `Yes` OR explicit “Create folder” button via a Power Apps/JSON-formatting link.
  - Steps:
    - Set `BiddingFolderState = Creating`.
    - Create folder path: `/OneDrive/CCBA/Bidding/${Year}/${BiddingCode or OpportunityId}/` with standard subfolders.
    - Save `DriveItemId`, `Url`, `Path`; set `BiddingFolderState = Created`; set `BiddingFolderPhase = Draft`.
    - Grant access to `BidTeam` users (Members) and PMO group (Owners).

- Flow B — Confirm handover
  - Trigger: Manual approval or when Stage moves to `Proposal/HSDX` and `ParticipationDecision = Yes`.
  - Steps:
    - Ensure folder exists; ensure metadata is set.
    - Lock structure (optional): create a marker file; set retention label if required.
    - Set `BiddingFolderPhase = Confirmed`.

- Flow C — Archive/cleanup
  - Trigger: When Stage becomes `Closed - Lost` or `Closed - Not Pursued` OR Contract is created and Project started.
  - Steps:
    - Move folder to Archive path `/OneDrive/CCBA/Archive/Bidding/${Year}/...` or apply retention.
    - Downgrade permissions to read-only for team; keep PMO Owners.
    - Set `BiddingFolderPhase = Archived`.

## Idempotency & safety
- Use “Get or create” pattern by Path; if `DriveItemId` present, verify it resolves; repair if path changed.
- Track state transitions using `BiddingFolderState`/`BiddingFolderPhase`; only act when moving to a new state.
- Wrap Graph calls with retries; handle 409/429 responses; log errors back to item with `DecisionNote` append.

## Permissions & security
- Use connection with least privilege; prefer Entra app + application permissions with constrained scopes and approval.
- Use group-based assignment for PMO and functional teams when possible; add individual `BidTeam` members dynamically.

## Implementation sketch (Power Automate)
- Triggers: “When an item is created” and “When an item is modified” for `Opportunities` with filter expressions on the key columns.
- Actions: HTTP with Azure AD (Graph) to create/resolve DriveItem, grant permissions; SharePoint connectors to update the item; Compose for paths.
- Environment variables: Base OneDrive root, PMO group id, standard subfolders JSON.

## Testing & rollout
- Dev: run against a small set; verify fields populate and permissions apply.
- Test: user acceptance with real BidTeam accounts.
- Prod: gradual rollout; monitor errors; add dashboard for folder states.
