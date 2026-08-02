## 2026-07-28T08:50:37Z

You are teamwork_preview_worker_m3_1. Your working directory is d:\idop-ccba-way\.agents\teamwork_preview_worker_m3_1\. Create your directory if needed.

Your task: Implement Milestone 3 (Agent Discoverability Updates).

1. UPDATE `d:\idop-ccba-way\CLAUDE.md`:
   Add section `## Governance Knowledge Base` (recommended placement: after `## Project Context`, around line 10).
   The section must explain:
   - AI Agents MUST read `.md/workspace_context.yaml` first when starting a working session to get project bootstrap info.
   - Explain the 2 document groups:
     - `governance_constitution` (`.md/governance_constitution/`): Quy chế pháp lý bất di bất dịch (QCTK 2815, QCCTNB 3209, Điều lệ CCBA, Quy chế KHCN IBST).
     - `system_blueprint` (`.md/system_blueprint/`): Yêu cầu thiết kế hệ thống có thể evolve (IDOP v2.0 F1-F4).
   - Instruct agents to look up `.md/cross_references.yaml` when needing legal basis / governance source for any module/spec in `specs/modules/`.

2. UPDATE `d:\idop-ccba-way\README.md`:
   Add section `## 📚 Knowledge Base (.md/)` (recommended placement: before `## 📂 Liên kết nhanh`, around line 203).
   The section must describe for human developers/collaborators:
   - The `.md/` Knowledge Base structure and "Hiến pháp hệ thống" (System Constitution) philosophy.
   - List the directories (`governance_constitution`, `system_blueprint`) and meta files (`workspace_context.yaml`, `INDEX.md`, `cross_references.yaml`).
   - Highlight how indexing and cross-referencing connect governance rules to code modules.

3. REPORT & HANDOFF:
   - Document changes made, insertion locations, and updated file verification in `d:\idop-ccba-way\.agents\teamwork_preview_worker_m3_1\handoff.md`.
   - Send completion message to parent orchestrator.

MANDATORY INTEGRITY WARNING: DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
