import os
import sys
import json
import re
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')

ROOT_DIR = Path(r"d:\idop-ccba-way")
SPECS_DIR = ROOT_DIR / "specs" / "modules"
DATAMODEL_DIR = ROOT_DIR / "datamodel" / "sharepoint" / "lists"

def inspect_placeholders():
    print("=== DEEP INSPECTION: PLACEHOLDERS ('...') ===")
    md_files = sorted(list(SPECS_DIR.glob("**/*.md")))
    dots_pattern = re.compile(r'\.\.\.')
    
    matches = []
    for md_file in md_files:
        rel_path = md_file.relative_to(ROOT_DIR)
        with open(md_file, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
        for idx, line in enumerate(lines, 1):
            if dots_pattern.search(line):
                # get context lines
                start_c = max(0, idx - 2)
                end_c = min(len(lines), idx + 1)
                context = [f"    L{i+1}: {lines[i].strip()}" for i in range(start_c, end_c)]
                matches.append({
                    "file": str(rel_path),
                    "line": idx,
                    "line_content": line.strip(),
                    "context": "\n".join(context)
                })
                
    print(f"Total files scanned: {len(md_files)}")
    print(f"Total placeholder lines found: {len(matches)}\n")
    for m in matches:
        print(f"FILE: {m['file']}:{m['line']}")
        print(m['context'])
        print("-" * 50)

def inspect_unmapped_and_primary_mappings():
    print("\n=== DEEP INSPECTION: SHAREPOINT LIST MAPPINGS (52 SCHEMAS) ===")
    
    json_files = sorted(list(DATAMODEL_DIR.glob("**/*.json")))
    
    # 21 spec.md files
    spec_files = sorted(list(SPECS_DIR.glob("**/spec.md")))
    specs_content = {}
    for sfile in spec_files:
        rel_path = str(sfile.relative_to(ROOT_DIR))
        with open(sfile, "r", encoding="utf-8", errors="replace") as f:
            specs_content[rel_path] = f.read()

    # Also load all md files in specs/modules/ to see if unmapped JSONs are in plan.md / tasks.md
    all_specs_md = sorted(list(SPECS_DIR.glob("**/*.md")))
    all_md_content = {}
    for mfile in all_specs_md:
        rel_path = str(mfile.relative_to(ROOT_DIR))
        with open(mfile, "r", encoding="utf-8", errors="replace") as f:
            all_md_content[rel_path] = f.read()

    print(f"Checking {len(json_files)} schemas against {len(spec_files)} spec.md files...\n")
    
    detailed_mappings = []
    
    for jfile in json_files:
        rel_json_path = str(jfile.relative_to(ROOT_DIR))
        folder_module = jfile.parent.name # e.g. cash_data, people_assets, process_execution...
        stem = jfile.stem # e.g. document_requirements
        
        with open(jfile, "r", encoding="utf-8") as f:
            jdata = json.load(f)
            list_name = jdata.get("list_name", stem)
            title = jdata.get("title", "")

        # Find in spec.md files
        spec_matches = []
        spec_primary_matches = []
        
        for spec_path, content in specs_content.items():
            # Check if mentioned in spec.md
            mentioned = (stem in content) or (list_name in content) or (title in content)
            if mentioned:
                spec_matches.append(spec_path)
                # Check if it's primary in data model section of spec.md
                # (e.g., inside a table or section heading mentioning the list)
                if re.search(r'`?' + re.escape(stem) + r'`?', content, re.IGNORECASE) or \
                   re.search(r'`?' + re.escape(list_name) + r'`?', content, re.IGNORECASE):
                    spec_primary_matches.append(spec_path)

        # Find in ANY md file (plan.md, tasks.md, etc.)
        any_md_matches = []
        for md_path, content in all_md_content.items():
            if (stem in content) or (list_name in content):
                any_md_matches.append(md_path)

        # Primary submodule expected based on directory matching
        # e.g. datamodel/sharepoint/lists/cash_data/expenses.json -> specs/modules/cash_data/expenses/spec.md
        expected_spec_pattern = f"{folder_module}\\"
        submodule_specs = [s for s in spec_files if folder_module in str(s)]

        detailed_mappings.append({
            "json": rel_json_path,
            "folder_module": folder_module,
            "stem": stem,
            "list_name": list_name,
            "title": title,
            "spec_matches": spec_matches,
            "spec_match_count": len(spec_matches),
            "any_md_matches": any_md_matches
        })

    # Output detailed findings
    unmapped_in_specs = [d for d in detailed_mappings if d["spec_match_count"] == 0]
    exactly_1_spec = [d for d in detailed_mappings if d["spec_match_count"] == 1]
    multi_spec = [d for d in detailed_mappings if d["spec_match_count"] > 1]

    print(f"=== SUMMARY ===")
    print(f"Total Schemas: {len(detailed_mappings)}")
    print(f"Mapped to exactly 1 spec.md: {len(exactly_1_spec)}")
    print(f"Mapped to >1 spec.md: {len(multi_spec)}")
    print(f"Unmapped in any spec.md: {len(unmapped_in_specs)}")

    if unmapped_in_specs:
        print("\n=== UNMAPPED SCHEMAS IN spec.md FILES ===")
        for u in unmapped_in_specs:
            print(f"JSON: {u['json']}")
            print(f"  stem: {u['stem']} | list_name: {u['list_name']} | title: {u['title']}")
            print(f"  Found in any .md file: {u['any_md_matches']}")

    print("\n=== MULTI-SPEC SCHEMAS BREAKDOWN ===")
    for m in multi_spec:
        print(f"JSON: {m['json']} (stem: {m['stem']})")
        print(f"  Specs ({m['spec_match_count']}): {m['spec_matches']}")

if __name__ == "__main__":
    inspect_placeholders()
    inspect_unmapped_and_primary_mappings()
