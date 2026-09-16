# Handoff Report — Explorer 4 (Milestone 3 & Milestone 4)

**Agent**: Explorer 4 (`teamwork_preview_explorer_m3_m4`)  
**Working Directory**: `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m3_m4`  
**Target Milestone**: Milestone 3 (Validation & Testing Scenarios Evaluation) & Milestone 4 (Technical Debt & Strategic Roadmap)  
**Date**: 28/07/2026  

---

## 1. Observation

Direct observations from inspecting codebase files, scripts, JSON definitions, and test files:

1. **JSON Schema vs Validation Engine Property Mismatch**:
   - `datamodel/sharepoint/schemas/sp-list.schema.json` lines 11, 20, 39:
     ```json
     "ListName": { "type": "string" },
     "Columns": { "type": "array" },
     "Name": { "type": "string" }
     ```
   - `tools/scripts/modules/ValidationHelpers.psm1` lines 40, 49, 55, 56, 65:
     ```powershell
     $requiredProps = @('Title', 'InternalName', 'Description', 'Fields')
     if ($json.InternalName -and $json.InternalName -cnotmatch '^[a-z_]+$') ...
     foreach ($field in $json.Fields) ...
     if (-not $field.InternalName) ...
     ```
   - Actual JSON list definitions (e.g. `datamodel/sharepoint/lists/strategy_crm/leads.json:3,5,6` and `lists/cash_data/expenses.json:4,6,7`):
     ```json
     "ListName": "Leads",
     "Columns": [ { "Name": "LeadName", "Type": "Text" }, ... ]
     ```
   - `tools/scripts/testing/modules.Tests.ps1` lines 25, 27, 28 vs 107-108:
     - Test fixture defines `ListName` and `Columns`, but `Test-IDOPListSchema` expects `Title` and `Fields`.

2. **Referential Integrity Validation Scope**:
   - `tools/scripts/modules/ValidationHelpers.psm1` lines 297-337 (`Test-IDOPLookupReferences`):
     - Line 318: Checks `$lookupList = $field.LookupList` against `$allLists.ContainsKey($lookupList)`.
     - Observation: It does NOT parse `$field.Lookup.Field` nor check if the targeted lookup column exists in the target list schema.
   - `ValidationHelpers.psm1` lines 345-399 (`Test-IDOPDataModel`):
     - Observation: Runs `Test-IDOPListSchema` and `Test-IDOPTaxonomyJson`, but contains NO logic linking `TermSet.Name` (e.g., `CCBA_LoaiChiPhi`) in list JSONs to `datamodel/sharepoint/taxonomy/*.json`.

3. **Validation Script Execution Flow & Fallback Behavior**:
   - `idop.ps1` lines 268-320:
     - `validate datamodel` calls `Test-IDOPDataModel`.
     - `validate schemas` invokes `tools/scripts/validation/validate-sp-schemas.ps1`.
     - `validate naming` invokes `tools/scripts/validation/validate-sp-naming.ps1`.
     - `validate lookups` calls `Test-IDOPLookupReferences`.
   - `tools/scripts/validation/validate-sp-schemas.ps1` lines 25-43:
     - Lines 25-27 check `Get-Command ajv`. If `ajv` is missing, lines 35-42 fall back to basic `ConvertFrom-Json` parsing and output `[OK] JSON parsed successfully` without schema validation.

4. **Pester Test & Linting Utilities**:
   - `tools/scripts/tests/validate-model.ps1` lines 37, 47, 48:
     - Checks `$json.ListName` and `$json.Columns`, flags `lookupCount > 8` and `fieldCount > 28`.
   - `tools/scripts/testing/apply-sp-lists.Tests.ps1` lines 14-25:
     - Mock test fixture uses legacy properties `Title` and `Fields`.

---

## 2. Logic Chain

1. **Observation 1 & 4** show that the repository has two conflicting models of list definition schemas:
   - *Model A (Canonical & Runtime)*: `sp-list.schema.json`, `SpListDeploy.psm1`, `validate-model.ps1`, `sp-diff.ps1`, and all 48+ list JSON files use `ListName`, `Columns`, `Name`.
   - *Model B (Outdated Validator)*: `ValidationHelpers.psm1` (`Test-IDOPListSchema`) and `modules.Tests.ps1` use `Title`, `InternalName`, `Fields`.
2. **From Step 1**, calling `idop.ps1 validate datamodel` triggers `Test-IDOPDataModel` -> `Test-IDOPListSchema`. Because all 48+ list JSON files follow Model A, `Test-IDOPListSchema` fails on every single list JSON file, producing `Missing required property: Title`, `Missing required property: InternalName`, `Missing required property: Fields`.
3. **Observation 2** shows that referential integrity validation is incomplete:
   - For Lookups: `Test-IDOPLookupReferences` checks if the target list name exists, but ignores whether the target field exists or is valid.
   - For Managed Metadata: Neither `Test-IDOPDataModel` nor `Test-IDOPLookupReferences` checks whether `TermSet.Name` specified in a list JSON matches any taxonomy JSON file in `datamodel/sharepoint/taxonomy/`.
4. **Observation 3** shows that `validate-sp-schemas.ps1` silently falls back to basic JSON parsing if `ajv` CLI is not installed, masking schema errors as `[OK]` passes.
5. **Synthesis**: The validation framework requires refactoring to align `ValidationHelpers.psm1` with `sp-list.schema.json`, extend referential integrity checks to include target lookup fields and taxonomy cross-references, and establish a unified 5-tier Deployment Readiness Check matrix.

---

## 3. Caveats

- Live SharePoint Online deployment testing was not executed directly in this read-only investigation phase (PnP commands were analyzed structurally via code inspection).
- Assumptions made: `sp-list.schema.json` and `SpListDeploy.psm1` represent the true intended runtime schema dialect.
- Alternative interpretations considered: If `Title`/`Fields` were intended for a multi-tenant or legacy deployment module, we verified that no list JSON files in `datamodel/sharepoint/lists/` use `Title`/`Fields`. All use `ListName`/`Columns`.

---

## 4. Conclusion

- **Validation Engine Status**: High-priority technical debt exists in `ValidationHelpers.psm1` (`Test-IDOPListSchema`), causing `idop.ps1 validate datamodel` and Pester tests to fail falsely against valid list definitions.
- **Referential Integrity**: Looking up target lists is functional, but checking target fields and cross-referencing taxonomy term sets is absent.
- **Actionable Proposals**:
  1. Fix `ValidationHelpers.psm1` to validate `ListName`, `Columns`, `Name`.
  2. Extend `Test-IDOPLookupReferences` and add `Test-IDOPTaxonomyReferences`.
  3. Standardize CLI entry points and enforce AJV validation warnings.
  4. Implement the 5-Tier Deployment Readiness Check test matrix.
  5. Execute Short-Term (< 3 months) and Long-Term (3-12 months) Roadmap.

---

## 5. Verification Method

To independently verify these findings:

1. **Verify Schema Property Mismatch**:
   - Inspect `d:\idop-ccba-way\tools\scripts\modules\ValidationHelpers.psm1` lines 40 & 55 vs `d:\idop-ccba-way\datamodel\sharepoint\schemas\sp-list.schema.json` lines 11 & 20.
   - Run command: `pwsh -Command "Import-Module ./tools/scripts/modules/ValidationHelpers.psm1; Test-IDOPListSchema -JsonPath ./datamodel/sharepoint/lists/strategy_crm/leads.json"`
   - *Expected Failure*: Output returns `Valid = $false` with missing `Title`, `InternalName`, `Fields` errors.

2. **Verify AJV Fallback Behavior**:
   - Inspect `d:\idop-ccba-way\tools\scripts\validation\validate-sp-schemas.ps1` lines 25-43.

3. **Verify Analysis Report**:
   - Inspect full analysis report at `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m3_m4\analysis_m3_m4.md`.
