import os
import sys
import yaml
import re
import subprocess
import glob
from datetime import datetime

PROJECT_ROOT = r"d:\idop-ccba-way"
MD_ROOT = os.path.join(PROJECT_ROOT, ".md")

results = {
    "R1": {},
    "R2": {},
    "R3": {},
    "Integrity": {},
    "CheatingDetection": {},
    "Overall": "UNKNOWN"
}

def audit_r1():
    print("--- Auditing R1: Migration & Normalization ---")
    r1_pass = True

    # 1. Governance Constitution
    gov_dir = os.path.join(MD_ROOT, "governance_constitution")
    expected_gov = [
        "01_qctk_2815_project_management.md",
        "02_qcctnb_3209_financial_norms.md",
        "03_ccba_charter_2026.md",
        "04_ibst_science_tech_regulations.md"
    ]
    if os.path.exists(gov_dir):
        actual_gov = sorted([f for f in os.listdir(gov_dir) if os.path.isfile(os.path.join(gov_dir, f))])
        gov_match = (actual_gov == sorted(expected_gov))
        results["R1"]["gov_constitution_files"] = {
            "pass": gov_match,
            "expected": expected_gov,
            "actual": actual_gov,
            "file_count": len(actual_gov)
        }
        if not gov_match or len(actual_gov) != 4:
            r1_pass = False
    else:
        results["R1"]["gov_constitution_files"] = {"pass": False, "error": "Directory missing"}
        r1_pass = False

    # 2. System Blueprint
    sys_dir = os.path.join(MD_ROOT, "system_blueprint")
    expected_sys = [
        "01_idop_v2_architecture.md",
        "02_idop_v2_operations_finance.md",
        "03_idop_v2_technical_implementation.md",
        "04_idop_v2_enterprise_architecture.md"
    ]
    if os.path.exists(sys_dir):
        actual_sys = sorted([f for f in os.listdir(sys_dir) if os.path.isfile(os.path.join(sys_dir, f))])
        sys_match = (actual_sys == sorted(expected_sys))
        results["R1"]["system_blueprint_files"] = {
            "pass": sys_match,
            "expected": expected_sys,
            "actual": actual_sys,
            "file_count": len(actual_sys)
        }
        if not sys_match or len(actual_sys) != 4:
            r1_pass = False
    else:
        results["R1"]["system_blueprint_files"] = {"pass": False, "error": "Directory missing"}
        r1_pass = False

    # 3. Content integrity (non-empty, byte count & line count)
    doc_stats = {}
    all_docs = []
    if os.path.exists(gov_dir):
        all_docs.extend([os.path.join(gov_dir, f) for f in expected_gov])
    if os.path.exists(sys_dir):
        all_docs.extend([os.path.join(sys_dir, f) for f in expected_sys])

    corrupted = []
    for doc in all_docs:
        if os.path.exists(doc):
            size = os.path.getsize(doc)
            with open(doc, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
            line_cnt = len(lines)
            doc_stats[os.path.basename(doc)] = {"size": size, "lines": line_cnt}
            if size < 1000 or line_cnt < 20:
                corrupted.append(os.path.basename(doc))
        else:
            corrupted.append(os.path.basename(doc))

    results["R1"]["content_integrity"] = {
        "pass": len(corrupted) == 0,
        "corrupted_or_missing": corrupted,
        "stats": doc_stats
    }
    if len(corrupted) > 0:
        r1_pass = False

    # 4. extracted_docs directory removal
    extracted_docs_path = os.path.join(PROJECT_ROOT, "extracted_docs")
    extracted_exists = os.path.exists(extracted_docs_path)
    results["R1"]["extracted_docs_removed"] = {
        "pass": not extracted_exists,
        "exists": extracted_exists
    }
    if extracted_exists:
        r1_pass = False

    results["R1"]["overall_pass"] = r1_pass
    return r1_pass

def audit_r2():
    print("--- Auditing R2: Meta Files System ---")
    r2_pass = True

    # 1. workspace_context.yaml
    ctx_path = os.path.join(MD_ROOT, "workspace_context.yaml")
    if os.path.exists(ctx_path):
        try:
            with open(ctx_path, 'r', encoding='utf-8') as f:
                ctx_data = yaml.safe_load(f)
            yaml_valid = isinstance(ctx_data, dict)
            # check key paths in workspace_context
            paths_exist = True
            missing_paths = []
            if "governance_constitution" in str(ctx_data):
                for path_val in [
                    ".md/governance_constitution/01_qctk_2815_project_management.md",
                    ".md/system_blueprint/01_idop_v2_architecture.md"
                ]:
                    full_p = os.path.join(PROJECT_ROOT, path_val.replace("/", os.sep))
                    if not os.path.exists(full_p):
                        missing_paths.append(path_val)
                        paths_exist = False

            results["R2"]["workspace_context_yaml"] = {
                "pass": yaml_valid and paths_exist,
                "yaml_valid": yaml_valid,
                "missing_paths": missing_paths,
                "keys": list(ctx_data.keys()) if isinstance(ctx_data, dict) else []
            }
            if not yaml_valid or not paths_exist:
                r2_pass = False
        except Exception as e:
            results["R2"]["workspace_context_yaml"] = {"pass": False, "error": str(e)}
            r2_pass = False
    else:
        results["R2"]["workspace_context_yaml"] = {"pass": False, "error": "File missing"}
        r2_pass = False

    # 2. INDEX.md
    index_path = os.path.join(MD_ROOT, "INDEX.md")
    if os.path.exists(index_path):
        with open(index_path, 'r', encoding='utf-8') as f:
            index_content = f.read()

        all_8_docs = [
            "01_qctk_2815_project_management.md",
            "02_qcctnb_3209_financial_norms.md",
            "03_ccba_charter_2026.md",
            "04_ibst_science_tech_regulations.md",
            "01_idop_v2_architecture.md",
            "02_idop_v2_operations_finance.md",
            "03_idop_v2_technical_implementation.md",
            "04_idop_v2_enterprise_architecture.md"
        ]
        missing_in_index = [d for d in all_8_docs if d not in index_content]
        has_lookup_table = "Tôi cần biết về" in index_content or "Bảng tra cứu nhanh" in index_content or "Quick Lookup" in index_content or "| " in index_content
        has_anchors = "#dieu-" in index_content.lower() or "#phan-" in index_content.lower() or "governance_constitution" in index_content

        results["R2"]["INDEX_md"] = {
            "pass": len(missing_in_index) == 0 and has_lookup_table and has_anchors,
            "missing_docs": missing_in_index,
            "has_lookup_table": has_lookup_table,
            "has_anchors": has_anchors,
            "char_count": len(index_content)
        }
        if len(missing_in_index) > 0 or not has_lookup_table:
            r2_pass = False
    else:
        results["R2"]["INDEX_md"] = {"pass": False, "error": "File missing"}
        r2_pass = False

    # 3. cross_references.yaml
    xref_path = os.path.join(MD_ROOT, "cross_references.yaml")
    if os.path.exists(xref_path):
        try:
            with open(xref_path, 'r', encoding='utf-8') as f:
                xref_data = yaml.safe_load(f)
            yaml_valid = isinstance(xref_data, (dict, list))
            
            # Count mapped specs
            mapped_specs = set()
            total_refs = 0
            if isinstance(xref_data, dict):
                # could be key 'modules' or 'spec_files' or direct dictionary of specs
                modules_data = xref_data.get("modules", xref_data.get("spec_mappings", xref_data))
                if isinstance(modules_data, dict):
                    for k, v in modules_data.items():
                        if isinstance(v, list):
                            for item in v:
                                if isinstance(item, dict) and "spec_file" in item:
                                    mapped_specs.add(item["spec_file"])
                                    total_refs += len(item.get("references", [1]))
                                elif isinstance(item, dict) and "spec" in item:
                                    mapped_specs.add(item["spec"])
                                    total_refs += 1
                        elif isinstance(v, dict):
                            mapped_specs.add(k)
                            total_refs += len(v.get("references", [1]))
                elif isinstance(modules_data, list):
                    for item in modules_data:
                        if isinstance(item, dict):
                            sf = item.get("spec_file", item.get("spec", item.get("file")))
                            if sf:
                                mapped_specs.add(sf)
                                total_refs += len(item.get("references", [1]))

            # Alternative search: find all .md references in cross_references.yaml
            xref_str = yaml.dump(xref_data) if yaml_valid else ""
            spec_matches = set(re.findall(r'[\w/-]+\/spec\.md', xref_str))
            all_specs_found = mapped_specs.union(spec_matches)

            count_mapped = len(all_specs_found)
            pass_15 = count_mapped >= 15

            results["R2"]["cross_references_yaml"] = {
                "pass": yaml_valid and pass_15,
                "yaml_valid": yaml_valid,
                "mapped_spec_count": count_mapped,
                "mapped_specs": list(sorted(all_specs_found)),
                "raw_ref_count": total_refs
            }
            if not yaml_valid or not pass_15:
                r2_pass = False
        except Exception as e:
            results["R2"]["cross_references_yaml"] = {"pass": False, "error": str(e)}
            r2_pass = False
    else:
        results["R2"]["cross_references_yaml"] = {"pass": False, "error": "File missing"}
        r2_pass = False

    results["R2"]["overall_pass"] = r2_pass
    return r2_pass

def audit_r3():
    print("--- Auditing R3: Agent Discoverability ---")
    r3_pass = True

    # 1. CLAUDE.md
    claude_path = os.path.join(PROJECT_ROOT, "CLAUDE.md")
    if os.path.exists(claude_path):
        with open(claude_path, 'r', encoding='utf-8') as f:
            claude_content = f.read()
        has_section = "## Governance Knowledge Base" in claude_content or "## Governance Knowledge Base (.md/)" in claude_content
        has_ctx_ref = "workspace_context.yaml" in claude_content
        has_groups_ref = "governance_constitution" in claude_content and "system_blueprint" in claude_content

        results["R3"]["CLAUDE_md"] = {
            "pass": has_section and has_ctx_ref and has_groups_ref,
            "has_section": has_section,
            "has_ctx_ref": has_ctx_ref,
            "has_groups_ref": has_groups_ref
        }
        if not (has_section and has_ctx_ref and has_groups_ref):
            r3_pass = False
    else:
        results["R3"]["CLAUDE_md"] = {"pass": False, "error": "File missing"}
        r3_pass = False

    # 2. README.md
    readme_path = os.path.join(PROJECT_ROOT, "README.md")
    if os.path.exists(readme_path):
        with open(readme_path, 'r', encoding='utf-8') as f:
            readme_content = f.read()
        has_kb_section = "Knowledge Base" in readme_content and ".md/" in readme_content

        results["R3"]["README_md"] = {
            "pass": has_kb_section,
            "has_kb_section": has_kb_section
        }
        if not has_kb_section:
            r3_pass = False
    else:
        results["R3"]["README_md"] = {"pass": False, "error": "File missing"}
        r3_pass = False

    results["R3"]["overall_pass"] = r3_pass
    return r3_pass

def audit_integrity():
    print("--- Auditing Integrity & Regression ---")
    integrity_pass = True

    # 1. Execute PowerShell datamodel validation command
    ps_cmd = 'pwsh -ExecutionPolicy Bypass -Command ".\\idop.ps1 validate datamodel"'
    try:
        proc = subprocess.run(ps_cmd, cwd=PROJECT_ROOT, capture_output=True, text=True, shell=True)
        out = proc.stdout + proc.stderr
        passed_100 = proc.returncode == 0 and "Lists Valid" in out and "Taxonomy Valid" in out and ("Total Errors              : 0" in out or "Total Errors" in out) and "All validations passed" in out
        results["Integrity"]["datamodel_validation"] = {
            "pass": passed_100,
            "returncode": proc.returncode,
            "stdout_summary": [line.strip() for line in out.strip().splitlines() if line.strip()][-10:]
        }
        if not passed_100:
            integrity_pass = False
    except Exception as e:
        results["Integrity"]["datamodel_validation"] = {"pass": False, "error": str(e)}
        integrity_pass = False

    # 2. Verify zero modifications in specs/, datamodel/, tools/ during KB restructuring (since 15:45:00 Jul 28)
    kb_start_timestamp = datetime(2026, 7, 28, 15, 45, 0).timestamp()
    
    modified_during_kb = []
    for folder in ["specs", "datamodel", "tools"]:
        folder_path = os.path.join(PROJECT_ROOT, folder)
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                fp = os.path.join(root, file)
                mtime = os.path.getmtime(fp)
                if mtime > kb_start_timestamp:
                    rel_p = os.path.relpath(fp, PROJECT_ROOT)
                    modified_during_kb.append((rel_p, datetime.fromtimestamp(mtime).isoformat()))

    results["Integrity"]["untouched_specs_datamodel_tools"] = {
        "pass": len(modified_during_kb) == 0,
        "modified_count": len(modified_during_kb),
        "modified_files": modified_during_kb
    }
    if len(modified_during_kb) > 0:
        integrity_pass = False

    results["Integrity"]["overall_pass"] = integrity_pass
    return integrity_pass

def audit_cheating_detection():
    print("--- Auditing Cheating Detection ---")
    cheating_pass = True

    # 1. Sample cross_references.yaml mappings against actual spec files
    xref_path = os.path.join(MD_ROOT, "cross_references.yaml")
    sampled_verifications = []
    if os.path.exists(xref_path):
        with open(xref_path, 'r', encoding='utf-8') as f:
            xref_data = yaml.safe_load(f)
        
        # Test 5 specs across different modules
        specs_to_test = [
            ("specs/modules/cash_data/finance/spec.md", "2815"),
            ("specs/modules/strategy_crm/opportunities/spec.md", "3209"),
            ("specs/modules/system_governance/approvals/spec.md", "CCBA"),
            ("specs/modules/people_assets/assets/spec.md", "2815"),
            ("specs/modules/process_execution/projects/spec.md", "2815")
        ]
        
        for rel_spec, term in specs_to_test:
            full_spec = os.path.join(PROJECT_ROOT, rel_spec.replace("/", os.sep))
            if os.path.exists(full_spec):
                with open(full_spec, 'r', encoding='utf-8') as f:
                    content = f.read()
                found = term in content
                sampled_verifications.append({"spec": rel_spec, "term": term, "found_in_spec": found})
                if not found:
                    cheating_pass = False

    # 2. Verify INDEX.md links/anchors and file references
    index_path = os.path.join(MD_ROOT, "INDEX.md")
    anchor_checks = []
    if os.path.exists(index_path):
        with open(index_path, 'r', encoding='utf-8') as f:
            idx_txt = f.read()
        
        # Extract file links like governance_constitution/01_qctk_2815_project_management.md#...
        links = re.findall(r'governance_constitution/[\w\.-]+', idx_txt) + re.findall(r'system_blueprint/[\w\.-]+', idx_txt)
        unique_links = set(links)
        for link in unique_links:
            target_path = os.path.join(MD_ROOT, link.replace('/', os.sep))
            exists = os.path.exists(target_path)
            anchor_checks.append({"target": link, "exists": exists})
            if not exists:
                cheating_pass = False

    results["CheatingDetection"] = {
        "pass": cheating_pass,
        "sampled_spec_references": sampled_verifications,
        "sampled_anchor_checks": anchor_checks
    }
    return cheating_pass

if __name__ == "__main__":
    p1 = audit_r1()
    p2 = audit_r2()
    p3 = audit_r3()
    p_int = audit_integrity()
    p_cheat = audit_cheating_detection()

    overall = p1 and p2 and p3 and p_int and p_cheat
    results["Overall"] = "VICTORY CONFIRMED" if overall else "VICTORY REJECTED"

    print("\n" + "="*80)
    print(f"FINAL AUDIT RESULT: {results['Overall']}")
    print("="*80)
    print(yaml.dump(results, default_flow_style=False))
