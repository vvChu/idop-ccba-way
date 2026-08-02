# Implementation Plan - IDOP CCBA v2.0 Data Model & PMO Spec Upgrade

## Overview
Implement 6 JSON schema updates/creations in `datamodel/sharepoint/lists/process_execution/`, update `specs/modules/process_execution/pmo/spec.md`, and validate clean execution with `.\idop.ps1 validate datamodel`.

## Milestone Plan

### Milestone 1: Exploration & Architecture Assessment
- Dispatch `teamwork_preview_explorer` agents to analyze:
  1. Existing JSON schemas in `datamodel/sharepoint/lists/process_execution/` and lookup conventions across the codebase.
  2. The validation engine in `tools/` / `idop.ps1` to understand lookup validation rules.
  3. `specs/modules/process_execution/pmo/spec.md` and related governance documents (QCTK 2815, QCCTNB 3209, Law 135/2025/QH15, NĐ 217/2026/NĐ-CP).

### Milestone 2: Data Model JSON Schemas Implementation (R1)
- Dispatch `teamwork_preview_worker` to:
  1. Update `contract_scopes.json`, `projects.json`, `job_assignments.json`, `assignment_details.json`, and `cde_documents.json`.
  2. Create `scope_department_allocations.json` with lookup reference to `ContractScopes`.
  3. Run `.\idop.ps1 validate datamodel` to verify syntax and schema structure.
- Dispatch `teamwork_preview_reviewer` to review schema correctness and lookup integrity.

### Milestone 3: PMO Specification & Documentation Update (R2)
- Dispatch `teamwork_preview_worker` to:
  1. Update `specs/modules/process_execution/pmo/spec.md` documenting the 5-step PGV sequence, role distinctions, multi-scope & multi-department allocation rules, statutory compliance (Law 135/2025/QH15 & NĐ 217/2026/NĐ-CP), 3-tier role hierarchy, and Ubiquitous Language matrix.
- Dispatch `teamwork_preview_reviewer` to review specification completeness.

### Milestone 4: Data Model Validation & Final Forensic Audit (R3)
- Dispatch `teamwork_preview_worker` to run `.\idop.ps1 validate datamodel` and verify 0 validation errors.
- Dispatch `teamwork_preview_challenger` for empirical stress testing of schemas & validator.
- Dispatch `teamwork_preview_auditor` for forensic integrity audit.
