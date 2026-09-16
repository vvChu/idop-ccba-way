# SharePoint Navigation Governance — IDOP Modules

Last updated: 2026-08-02

## Principles
- Group every SharePoint list under a module label directly below `Home` in the top/left navigation.
- Module labels reflect IDOP components; lists are auto-discovered from `datamodel/sharepoint/lists/<module>/` and `datamodel/sharepoint/navigation/global-navigation.json`.
- Idempotent updates: re-running the script won’t duplicate nodes; missing nodes are created and updated gracefully.
- Support external cross-site and OneDrive links via automated fallback (`-External`).

## Modules and Global Navigation Structure
- **Intranet Portal**: Home link, Rules & Knowledge pages
- **CRM**: Customers, Contacts, Opportunities, Potential Projects
- **Projects & CDE**: Projects, CDE Documents, iCDE System, Bidding Folder (OneDrive Master)
- **People & Assets**: Employees, Assets

## Runbook
- Dry-run preview:
```powershell
.\idop.ps1 deploy navigation -Environment IDOP -DryRun
```
- Apply navigation sync to PROD (`sites/idop`):
```powershell
.\idop.ps1 deploy navigation -Environment IDOP
```
- Or run sub-script directly via PnP session:
```powershell
pwsh -NoProfile -File .\tools\scripts\deployment\sync-sp-navigation.ps1 -Environment IDOP -Location Top
```

## Adding new lists or navigation links
- When a new list or custom link is added, update `datamodel/sharepoint/navigation/global-navigation.json` and re-run `.\idop.ps1 deploy navigation -Environment IDOP`.
- Ensure the live list exists (via `.\idop.ps1 deploy lists -Environment IDOP -Full`) so its URL resolves smoothly.

## Troubleshooting
- If a link fails due to cross-site or external URL validation, `sync-sp-navigation.ps1` automatically applies the `-External` fallback flag.
- If duplicate nodes appear from manual edits, use `-Prune` or clean up nodes via PnP cmdlets.
