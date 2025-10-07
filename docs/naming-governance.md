# Naming Governance — SharePoint Lists and Columns

Last updated: 2025-09-22

## Principles
- Internal names (schema/technical) must be in English and stable (no spaces); display names are in Vietnamese.
- Internal name set at creation time; do not rename internal names post-creation (breaking changes). Use display name changes for VN labels.
- Follow PnP naming best practices for field types and multi-user (`UserMulti`) and reserved names (e.g., use `DocVersion`).

## Recommendations
- Field internal names: `CamelCase` or `PascalCase` (e.g., `ProjectCode`, `DecisionEmailLink`).
- Lookup naming: use the target entity as field name (e.g., `Customer`, `PotentialProject`).
- Multi-select: prefer `*Multi` type when business requires multiple values.
- Taxonomy fields: use consistent names across lists (e.g., `ServiceType`, `Status`).

## Display names (Vietnamese)
- Provide VN titles that match business glossary (e.g., `Mã Dự Án` for `ProjectCode`).
- Keep concise and unambiguous; avoid abbreviations unless standardized.

## Validation
- Use `tools/scripts/validate-sp-naming.ps1` to report any deviation from EN-internal / VN-display conventions.
- Integrate the validator in CI (optional) and run on Dev/Test/Prod before release.

## Change management
- If a structural change is needed, discuss and get approval first, then update datamodel JSON → apply to environments.
