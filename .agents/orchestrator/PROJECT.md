# Project: IDOP-CCBA-WAY Knowledge Base Restructuring

## Architecture
- Source files: `extracted_docs/` (8 files - migrated and folder removed)
- Governance constitution target: `.md/governance_constitution/` (4 legal regulations - migrated & verified)
- System blueprint target: `.md/system_blueprint/` (4 system architecture & design specs - migrated & verified)
- Meta files: `.md/workspace_context.yaml`, `.md/INDEX.md`, `.md/cross_references.yaml`
- Discoverability files: `CLAUDE.md`, `README.md` (updated with Governance KB sections)
- Modules specs directory: `specs/modules/` (21 spec.md files scanned, 259 cross-references mapped)

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | M1 Exploration & Pre-validation | Verify extracted_docs, specs/modules, run pre-migration datamodel validation | none | DONE |
| 2 | M2 File Migration & Meta Files | Move 8 files, create workspace_context.yaml, INDEX.md, cross_references.yaml, remove extracted_docs/ | M1 | DONE |
| 3 | M3 Agent Discoverability | Update CLAUDE.md (## Governance Knowledge Base) & README.md (## 📚 Knowledge Base (.md/)) | M2 | DONE |
| 4 | M4 E2E Verification & Forensic Audit | Run datamodel validation, check file integrity, no changes in specs/datamodel/tools, forensic audit | M3 | DONE |

## Interface Contracts & Guidelines
- File renaming map:
  - `qctk_01.12.2025.md` -> `.md/governance_constitution/01_qctk_2815_project_management.md` (DONE)
  - `qcctnb_2025.md` -> `.md/governance_constitution/02_qcctnb_3209_financial_norms.md` (DONE)
  - `Du thao_QuyCheToChucHoatDong_CCBA_2026_v2.2.md` -> `.md/governance_constitution/03_ccba_charter_2026.md` (DONE)
  - `quy_che_khcn_ibst_01.12.2025.md` -> `.md/governance_constitution/04_ibst_science_tech_regulations.md` (DONE)
  - `IDOP_v2.0_F1_Architecture.md` -> `.md/system_blueprint/01_idop_v2_architecture.md` (DONE)
  - `IDOP_v2.0_F2_Operations_Finance.md` -> `.md/system_blueprint/02_idop_v2_operations_finance.md` (DONE)
  - `IDOP_v2.0_F3_Technical_Implementation.md` -> `.md/system_blueprint/03_idop_v2_technical_implementation.md` (DONE)
  - `IDOP_v2.0_F4_Enterprise_Architecture.md` -> `.md/system_blueprint/04_idop_v2_enterprise_architecture.md` (DONE)
- YAML syntax requirement: Valid YAML for `workspace_context.yaml` and `cross_references.yaml`.
- Content integrity: 100% exact copy of contents without modification.
- Validation script: `.\idop.ps1 validate datamodel` must pass.
