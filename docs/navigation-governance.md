# SharePoint Navigation Governance — IDOP Modules

Last updated: 2025-09-22

## Principles
- Group every SharePoint list under a module label directly below `Home` in the left navigation (QuickLaunch).
- Module labels reflect IDOP components; lists are auto-discovered from `datamodel/sharepoint/lists/<module>/`.
- Idempotent updates: re-running the script won’t duplicate nodes; missing nodes are created.
- Apply the same structure in Dev, Test, and Prod.

## Modules and folders
- Cash Data → `datamodel/sharepoint/lists/cash_data/`
- People Assets → `datamodel/sharepoint/lists/people_assets/`
- Performance OKRs → `datamodel/sharepoint/lists/performance_okrs/`
- Process Execution → `datamodel/sharepoint/lists/process_execution/`
- System Governance → `datamodel/sharepoint/lists/system_governance/`
- Strategy CRM → `datamodel/sharepoint/lists/strategy_crm/`

## Runbook
- Dry-run (see structure):
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\scripts\create-sp-navigation.ps1 -DryRun
```
- Apply to Dev/Test/Prod:
```powershell
# Dev
powershell -ExecutionPolicy Bypass -File .\tools\scripts\create-sp-navigation.ps1 -Environment Dev
# Test
powershell -ExecutionPolicy Bypass -File .\tools\scripts\create-sp-navigation.ps1 -Environment Test
# Prod
powershell -ExecutionPolicy Bypass -File .\tools\scripts\create-sp-navigation.ps1 -Environment Prod
```

## Adding new lists
- When a new list schema is added under a module folder in `datamodel/sharepoint/lists/`, re-run the navigation script to auto-add it to the label.
- Ensure the live list exists (via apply scripts) so its `DefaultViewUrl` resolves.

## Order and visibility
- Module labels appear directly below `Home`.
- Child items under each module are the lists’ display names. You can reorder manually if necessary; reruns won’t overwrite existing placements.

## Troubleshooting
- If a list is not found, confirm it exists on the site and has a default view.
- If duplicate nodes appear from manual changes, delete them and re-run the script.
