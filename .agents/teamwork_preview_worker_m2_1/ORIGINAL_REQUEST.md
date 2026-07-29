## 2026-07-28T08:48:48Z
You are teamwork_preview_worker_m2_1. Your working directory is d:\idop-ccba-way\.agents\teamwork_preview_worker_m2_1\. Create your directory if needed.

Your task: Implement Milestone 2 (Migration & Meta Files Generation).

1. FILE MIGRATION & CLEANUP:
   - Create directories `.md/governance_constitution` and `.md/system_blueprint`.
   - Copy/move 8 files from `extracted_docs/` to their new locations:
     Group A -> `.md/governance_constitution/`:
     - `qctk_01.12.2025.md` -> `01_qctk_2815_project_management.md`
     - `qcctnb_2025.md` -> `02_qcctnb_3209_financial_norms.md`
     - `Du thao_QuyCheToChucHoatDong_CCBA_2026_v2.2.md` -> `03_ccba_charter_2026.md`
     - `quy_che_khcn_ibst_01.12.2025.md` -> `04_ibst_science_tech_regulations.md`
     Group B -> `.md/system_blueprint/`:
     - `IDOP_v2.0_F1_Architecture.md` -> `01_idop_v2_architecture.md`
     - `IDOP_v2.0_F2_Operations_Finance.md` -> `02_idop_v2_operations_finance.md`
     - `IDOP_v2.0_F3_Technical_Implementation.md` -> `03_idop_v2_technical_implementation.md`
     - `IDOP_v2.0_F4_Enterprise_Architecture.md` -> `04_idop_v2_enterprise_architecture.md`
   - Verify 100% content integrity (compare file size/content line by line).
   - Remove `extracted_docs/` folder completely once verified.

2. GENERATE META FILES IN `.md/`:
   - `workspace_context.yaml`: Valid YAML bootstrap configuration for AI Agents (project_name, version, current_milestone, document_groups, initial_reading_sequence).
   - `INDEX.md`: Table of contents for all 8 documents with 2-3 sentence summaries, quick lookup table ("Tôi cần biết về X -> đọc file Y, Điều/Phần Z"), and anchor links to key Articles/Clauses in governance rules.
   - `cross_references.yaml`: Valid YAML file mapping all 21 `spec.md` files in `specs/modules/` to specific Articles/Clauses/Sections in original governance constitution & system blueprint documents. Scan all 21 `spec.md` files to extract exact real-world references (~150+ references).

3. REPORT & HANDOFF:
   - Document your work, file paths created, verification results, and YAML parsing checks in `d:\idop-ccba-way\.agents\teamwork_preview_worker_m2_1\handoff.md`.
   - Send completion message to parent orchestrator.
