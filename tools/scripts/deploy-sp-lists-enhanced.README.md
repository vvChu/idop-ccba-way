# SharePoint List Deployment Script — Enhanced

## Overview
Automates provisioning and updating of SharePoint lists from JSON definitions, supporting:
- All field types (Lookup, Managed Metadata, Choice, MultiChoice, etc.)
- Idempotent updates (safe to re-run)
- Diff & sync modes for schema drift detection and remediation
- Default view and column formatting auto-setup
- Index advisory logging

## Usage
Run from repo root:

```powershell
# Dry-run (no changes, just preview actions)
./tools/scripts/deploy-sp-lists-enhanced.ps1 -DryRun

# Update existing lists (add new fields, skip existing)
./tools/scripts/deploy-sp-lists-enhanced.ps1 -UpdateExisting

# Diff mode (show schema drift vs JSON, no changes)
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Diff

# Sync choices (update Choice/MultiChoice values to match JSON)
./tools/scripts/deploy-sp-lists-enhanced.ps1 -SyncChoices

# Single list only
./tools/scripts/deploy-sp-lists-enhanced.ps1 -SingleList <ListName>
```

## Flags
- `-DryRun` — Preview actions, no changes made
- `-UpdateExisting` — Add new fields to existing lists
- `-Diff` — Show schema drift (see status codes below)
- `-SyncChoices` — Synchronize Choice/MultiChoice values
- `-SingleList` — Only process one list by name

## Diff Status Codes
When running with `-Diff`, output lines are prefixed with status codes:

- `DIFF_NEW` — Field exists in JSON but not in SharePoint (new field)
- `DIFF_REQUIRED` — Required flag mismatch
- `DIFF_LOOKUP` — Lookup target list mismatch
- `DIFF_TERMSET` — Managed Metadata TermSet mismatch
- `DIFF_CHOICES` — Choice/MultiChoice values differ (added/removed)

Example:
```
🔍 DIFF_REQUIRED DIFF_CHOICES Field 'Status': DIFF_REQUIRED: False -> True | DIFF_CHOICES: +Approved, -Pending
```

## Advisory Logging
- If a list exceeds 8 Lookup fields or 28 total fields, a warning is logged to `deploy-warnings.log`.

## Related Scripts
- **Validation harness:** `tools/scripts/tests/validate-model.ps1` — Validate all JSON models, check for drift, print summary.
- **StageHistory snapshot:** `tools/scripts/snapshots/export-stagehistory-snapshot.ps1` — Export OpportunityStageHistory for analytics.

## Requirements
- PowerShell 7+
- PnP.PowerShell module
- SharePoint admin permissions

## See Also
- [flows.md](../../specs/modules/strategy_crm/opportunities/flows.md) — Automation flows & snapshot usage
- [diff-and-sync.md](../../docs/reporting/diff-and-sync.md) — Schema drift & sync documentation

## Health check Serena server

Script kiểm tra tình trạng server Serena:

```powershell
# Kiểm tra endpoint healthz (mặc định http://localhost:8000/healthz)
.\health-check-serena.ps1

# Hoặc chỉ định endpoint khác
.\health-check-serena.ps1 -Url "http://localhost:8080/healthz"
```

- Trả về exit code 0 nếu server hoạt động bình thường (HTTP 2xx).
- Trả về exit code 1 nếu không kết nối được.
- Trả về exit code 2 nếu server trả về mã lỗi khác 2xx.
