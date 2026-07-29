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
    print("================================================================================")
    print("TASK 1: EMPIRICAL PLACEHOLDER SWEEP ('...')")
    print("================================================================================")
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
                
    print(f"Total markdown files scanned in specs/modules: {len(md_files)}")
    print(f"Total lines containing '...': {len(matches)}\n")
    for idx, m in enumerate(matches, 1):
        print(f"Match #{idx}: {m['file']}:{m['line']}")
        print(m['context'])
        print("-" * 60)
    return matches

def inspect_spec_files():
    print("\n================================================================================")
    print("TASK 2: SPEC FILES EXISTENCE AND COMPLETENESS VERIFICATION")
    print("================================================================================")
    spec_files = sorted(list(SPECS_DIR.glob("**/spec.md")))
    print(f"Total spec.md files found: {len(spec_files)}")
    
    details = []
    for sfile in spec_files:
        rel_path = str(sfile.relative_to(ROOT_DIR))
        size = sfile.stat().st_size
        with open(sfile, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()
            lines = content.splitlines()
        
        headers = [line.strip() for line in lines if line.strip().startswith("#")]
        
        # Check standard sections
        has_overview = any("Tổng quan" in h or "Overview" in h or "Mục đích" in h for h in headers)
        has_datamodel = any("Data Model" in h or "SharePoint" in h or "Cấu trúc" in h or "Thực thể" in h for h in headers)
        has_api_flow = any("API" in h or "Workflow" in h or "Luồng" in h or "Nghiệp vụ" in h for h in headers)
        
        details.append({
            "path": rel_path,
            "size": size,
            "lines": len(lines),
            "headers_count": len(headers),
            "top_header": headers[0] if headers else "N/A",
            "has_datamodel": has_datamodel
        })
        print(f"[{rel_path}]")
        print(f"  Size: {size:,} bytes | Lines: {len(lines)} | Headers: {len(headers)}")
        print(f"  Top Header: {headers[0] if headers else 'N/A'}")
        
    return details

def inspect_schema_mapping():
    print("\n================================================================================")
    print("TASK 3: SHAREPOINT LIST JSON SCHEMA MAPPING VERIFICATION (52 SCHEMAS)")
    print("================================================================================")
    json_files = sorted(list(DATAMODEL_DIR.glob("**/*.json")))
    print(f"Total SharePoint List JSON schemas in datamodel/sharepoint/lists/: {len(json_files)}")
    
    spec_files = sorted(list(SPECS_DIR.glob("**/spec.md")))
    specs_content = {}
    for sfile in spec_files:
        rel_path = str(sfile.relative_to(ROOT_DIR))
        with open(sfile, "r", encoding="utf-8", errors="replace") as f:
            specs_content[rel_path] = f.read()

    schema_results = []
    
    for jfile in json_files:
        rel_json = str(jfile.relative_to(ROOT_DIR))
        module_dir = jfile.parent.name # e.g. cash_data, people_assets
        stem = jfile.stem
        
        with open(jfile, "r", encoding="utf-8") as f:
            jdata = json.load(f)
            list_name = jdata.get("list_name") or stem
            title = jdata.get("title") or ""
            
        # Search for exact stem or list_name (word boundary / backticks / json refs)
        matched_specs = []
        primary_module_spec = None
        
        for spec_path, content in specs_content.items():
            # Match stem or list_name explicitly using regex word boundary or exact occurrence
            pattern = r'\b' + re.escape(stem) + r'\b|\b' + re.escape(list_name) + r'\b'
            if re.search(pattern, content, re.IGNORECASE):
                matched_specs.append(spec_path)
                
            # Check if this spec is in the matching module directory
            if module_dir in spec_path:
                primary_module_spec = spec_path
                
        schema_results.append({
            "json": rel_json,
            "module_dir": module_dir,
            "stem": stem,
            "list_name": list_name,
            "title": title,
            "matched_specs": matched_specs,
            "match_count": len(matched_specs),
            "primary_module_spec": primary_module_spec,
            "in_primary_spec": primary_module_spec in matched_specs if primary_module_spec else False
        })
        
    print(f"\n--- MAPPING STATS ---")
    mapped_exact_1 = [s for s in schema_results if s["match_count"] == 1]
    mapped_multi = [s for s in schema_results if s["match_count"] > 1]
    mapped_zero = [s for s in schema_results if s["match_count"] == 0]
    in_own_module_spec = [s for s in schema_results if s["in_primary_spec"]]
    
    print(f"Total Schemas: {len(schema_results)}")
    print(f"Schemas referenced in their OWN module spec.md: {len(in_own_module_spec)} / {len(schema_results)}")
    print(f"Schemas with exactly 1 spec.md match across codebase: {len(mapped_exact_1)}")
    print(f"Schemas referenced in multiple spec.md files (cross-module/submodule integration): {len(mapped_multi)}")
    print(f"Schemas with ZERO spec.md matches: {len(mapped_zero)}")
    
    if mapped_zero:
        print("\n--- ZERO MATCH SCHEMAS ---")
        for z in mapped_zero:
            print(f"  JSON: {z['json']} | stem: {z['stem']} | list_name: {z['list_name']} | expected in: {z['primary_module_spec']}")
            
    print("\n--- DETAILED SCHEMA TO SPEC MAPPING TABLE ---")
    for sr in schema_results:
        status = "OK (1-to-1)" if sr["match_count"] == 1 else (f"SHARED ({sr['match_count']} specs)" if sr["match_count"] > 1 else "UNMAPPED")
        print(f"{sr['stem']:<32} | {sr['module_dir']:<18} | {status:<15} | Specs: {sr['matched_specs']}")
        
    return schema_results

if __name__ == "__main__":
    inspect_placeholders()
    inspect_spec_files()
    inspect_schema_mapping()
