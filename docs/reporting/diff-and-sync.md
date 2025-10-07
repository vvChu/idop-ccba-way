# Diff & Sync Deployment Guide

## Modes
- `-Diff`: So sánh schema trong JSON với hiện trạng list (hiện hỗ trợ Choice/MultiChoice so sánh giá trị).
- `-SyncChoices`: Đồng bộ lại tập giá trị Choice/MultiChoice khi thay đổi trong JSON.

## Example Commands
```powershell
# Chỉ xem khác biệt (không thay đổi)
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -Diff

# Vừa update field mới vừa xem diff
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -UpdateExisting -Diff

# Đồng bộ choices sau khi chỉnh JSON
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -SyncChoices
```

## Output Interpretation
- `🔍 DIFF Field 'Stage': +Choices: Renewed` => JSON có thêm Choice mới.
- `♻️ Đã đồng bộ Choices` => Cập nhật thành công.
- `ℹ️ Choices field ... đã khớp` => Không cần thay đổi.

## Limitations / Roadmap
- Chưa diff sâu các thuộc tính như Required thay đổi.
- Chưa xử lý rename field (cần migration tay).
- Roadmap: hỗ trợ diff ManagedMetadata (TermSet mismatch), Lookup target drift.

## Status — latest run (2025-09-21)
-  Environment: Dev (`https://ibstbim.sharepoint.com/sites/idop-dev`).
-  Schema validation: all JSON lists valid. Deprecated `client_projects.json` removed from scope.
-  Lineage corrected to: `Customer → PotentialProjects → Opportunities → Contracts → Projects`.
-  Expected diff highlights (post-lineage fix):
-  Create (if missing): `CDEDocuments` (process_execution).
-  Update: `Opportunities` fields — add `PotentialProject` lookup; new bidding-folder lifecycle and decision fields
    (`BiddingFolder*`, `ParticipationDecision`, decision metadata); Stage choices updated.
-  Update: `Projects` — remove any legacy `ClientProject` lookup (if present) and ensure `Contract` linkage remains.
-  Update: `PotentialProjects` — ensure no back-ref to `Opportunities`; keep `Customer`/`Contact` and metadata.
-  No other drifts expected.
-  Apply (dry-run): executed under PowerShell 7; validation passed; scanning planned changes (no mutations performed).

Next steps
-  Run "SP: diff lists" and review deltas; then run "SP: apply lists (dry-run)" to preview mutations.
-  After approval, apply changes to Dev, re-run diff to confirm zero drift.
-  Optional:
-  Add view/formatting for `BiddingFolder*` and `ParticipationDecision` on `Opportunities`.
-  Implement Flow A/B/C per `docs/bidding-folder-automation.md`.
-  Update Power BI RLS and dashboards referencing lineage.
