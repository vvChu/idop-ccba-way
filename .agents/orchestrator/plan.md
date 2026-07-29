# Implementation Plan: Knowledge Base Restructuring for IDOP-CCBA-WAY

## Overview
Restructure project knowledge base by migrating source documents from `extracted_docs/` to `.md/governance_constitution/` and `.md/system_blueprint/`, creating metadata indexing files (`workspace_context.yaml`, `INDEX.md`, `cross_references.yaml`), updating agent discoverability (`CLAUDE.md`, `README.md`), and ensuring zero regression via `.\idop.ps1 validate datamodel`.

## Milestone Structure
1. **M1: Exploration & Baseline Verification**
   - Dispatch `teamwork_preview_explorer` to inspect `extracted_docs/`, `specs/modules/`, `CLAUDE.md`, `README.md`.
   - Dispatch `teamwork_preview_worker` to run baseline validation `.\idop.ps1 validate datamodel`.
2. **M2: Migration & Meta Files Generation**
   - Dispatch `teamwork_preview_worker` to migrate 8 files into `.md/governance_constitution/` and `.md/system_blueprint/` with strict content preservation.
   - Remove `extracted_docs/` directory after verifying file copy integrity.
   - Scan all `spec.md` files in `specs/modules/` to generate `cross_references.yaml` mapping (>=15 spec files, ~150 references).
   - Generate `workspace_context.yaml` and `INDEX.md` (with summaries, lookup table, and anchor links).
3. **M3: Agent Discoverability Updates**
   - Dispatch `teamwork_preview_worker` to update `CLAUDE.md` (`## Governance Knowledge Base`) and `README.md` (`## 📚 Knowledge Base (.md/)`).
4. **M4: E2E Verification & Forensic Audit**
   - Dispatch `teamwork_preview_reviewer` & `teamwork_preview_challenger` to verify YAML validity, link integrity, and run `.\idop.ps1 validate datamodel`.
   - Dispatch `teamwork_preview_auditor` to audit content integrity, absence of hardcoded bypasses/cheating, and git status / file boundary compliance.
