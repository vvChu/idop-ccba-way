import os
import sys
import json
import re
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')

ROOT_DIR = Path(r"d:\idop-ccba-way")
SPECS_DIR = ROOT_DIR / "specs" / "modules"
DATAMODEL_DIR = ROOT_DIR / "datamodel" / "sharepoint" / "lists"

def build_full_report():
    json_files = sorted(list(DATAMODEL_DIR.glob("**/*.json")))
    spec_files = sorted(list(SPECS_DIR.glob("**/spec.md")))
    
    specs_content = {}
    for sfile in spec_files:
        rel_path = str(sfile.relative_to(ROOT_DIR)).replace("\\", "/")
        with open(sfile, "r", encoding="utf-8", errors="replace") as f:
            specs_content[rel_path] = f.read()

    results = []
    
    for jfile in json_files:
        rel_json = str(jfile.relative_to(ROOT_DIR)).replace("\\", "/")
        module_dir = jfile.parent.name
        stem = jfile.stem
        
        with open(jfile, "r", encoding="utf-8") as f:
            jdata = json.load(f)
            list_name = jdata.get("list_name") or jdata.get("ListName") or stem
            title = jdata.get("title") or ""
            
        matched_specs = []
        for spec_path, content in specs_content.items():
            pattern = r'\b' + re.escape(stem) + r'\b|\b' + re.escape(list_name) + r'\b'
            if re.search(pattern, content, re.IGNORECASE):
                matched_specs.append(spec_path)
                
        # Primary spec candidate in the same module
        primary_spec = None
        for s in matched_specs:
            if module_dir in s:
                primary_spec = s
                break
                
        results.append({
            "json": rel_json,
            "module_dir": module_dir,
            "stem": stem,
            "list_name": list_name,
            "title": title,
            "matched_specs": matched_specs,
            "match_count": len(matched_specs),
            "primary_spec": primary_spec
        })
        
    print(f"Total Schemas Analyzed: {len(results)}")
    print(f"Schemas with >=1 match in spec.md: {len([r for r in results if r['match_count'] > 0])}")
    print(f"Unmapped schemas: {len([r for r in results if r['match_count'] == 0])}")
    
    print("\n| # | List JSON File | List Name | Module | Primary Spec.md | Additional Specs | Status |")
    print("|---|---|---|---|---|---|---|")
    for idx, r in enumerate(results, 1):
        add_specs = [s for s in r['matched_specs'] if s != r['primary_spec']]
        add_str = ", ".join(add_specs) if add_specs else "None"
        prim_str = r['primary_spec'] or "MISSING"
        status = "MAPPED 1-TO-1" if (r['primary_spec'] and len(r['matched_specs'])==1) else ("CROSS-REFERENCED" if r['primary_spec'] else "UNMAPPED")
        print(f"| {idx} | `{r['json']}` | `{r['list_name']}` | `{r['module_dir']}` | `{prim_str}` | `{add_str}` | **{status}** |")

if __name__ == "__main__":
    build_full_report()
