# Diff/Apply Runbook and Fast Iteration Guide

Last updated: 2025-09-22

## What we implemented

- Focused diff in `tools/scripts/validation/sp-diff.ps1`:
  - Parameters:
    - `-Focus all|issues|changed` (default `all`)
    - `-OnlyLists <CSV of list names>`
    - `-SinceGit <ref>` (optional)
  - State caching: `tools/output/state/sp-diff-last.json` stores per-list result and JSON hash to enable fast re-runs.
- Targeted + fast apply in `tools/scripts/deployment/apply-sp-lists.ps1`:
  - Parameters:
    - `-OnlyLists <CSV of list names>`
    - `-Fast` (skip AJV validation — use when changes are small and trusted)
- VS Code tasks (see `.vscode/tasks.json`):
  - `SP: diff lists` (full scan)
  - `SP: diff lists (focus failures)`
  - `SP: diff lists (changed schemas)`
  - `SP: diff lists (only selection)`
  - `SP: apply lists (only selection, fast)`

## Typical workflows

### Full scan (baseline or periodic audit)
```powershell
# From repo root
powershell -ExecutionPolicy Bypass -File .\tools\scripts\validation\sp-diff.ps1
```

### Fast re-run: only prior failures
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\validation\sp-diff.ps1 -Focus issues
```

### Fast re-run: only lists whose JSON changed
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\validation\sp-diff.ps1 -Focus changed
```

### Limit to a small set
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\validation\sp-diff.ps1 -OnlyLists CDEDocuments,PotentialProjects,Opportunities
```

### Apply quickly to a small set (skip validation)
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\deployment\apply-sp-lists.ps1 -OnlyLists CDEDocuments,PotentialProjects,Opportunities -Fast
```

## Notes and guardrails
- State file `tools/output/state/sp-diff-last.json` is updated after each diff run; `-Focus issues` and `-Focus changed` use that cache.
- Always run a full scan periodically (e.g., daily or before release) to catch drifts introduced outside the repo.
- `-Fast` skips AJV validation. Prefer full validation when schemas or tooling change.
- New tasks are added in `.vscode/tasks.json` for quick access.

## Current baseline
- As of the last run (Dev): `Total JSON lists: 51, Lists OK: 51, Missing lists: 0, Fields with issues: 0`.

## Troubleshooting
- If `-Focus issues` returns 0 lists but you still want to verify certain lists, use `-OnlyLists`.
- If the cache file becomes corrupted, delete `tools/output/state/sp-diff-last.json` and run a full scan to rebuild.
- If Git narrowing is desired, pass `-SinceGit <ref>`; if Git isn’t available, the script silently falls back to normal behavior.
