import os
import sys
import json
import re
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')

ROOT_DIR = Path(r"d:\idop-ccba-way")
SPECS_DIR = ROOT_DIR / "specs" / "modules"
DATAMODEL_DIR = ROOT_DIR / "datamodel" / "sharepoint" / "lists"

def task_1_placeholder_sweep():
    print("=== TASK 1: SEARCH FOR '...' PLACEHOLDERS IN specs/modules/**/*.md ===")
    md_files = list(SPECS_DIR.glob("**/*.md"))
    placeholder_matches = []
    
    # Regular expression for literal '...'
    dots_pattern = re.compile(r'\.\.\.')
    
    for md_file in md_files:
        rel_path = md_file.relative_to(ROOT_DIR)
        with open(md_file, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
        for idx, line in enumerate(lines, 1):
            if dots_pattern.search(line):
                placeholder_matches.append({
                    "file": str(rel_path),
                    "line": idx,
                    "content": line.strip()
                })
                
    print(f"Total markdown files scanned: {len(md_files)}")
    print(f"Total lines containing '...': {len(placeholder_matches)}")
    for match in placeholder_matches:
        print(f"  [{match['file']}:{match['line']}] {match['content']}")
    return placeholder_matches

def task_2_spec_files_check():
    print("\n=== TASK 2: CONFIRM ALL TARGET spec.md FILES EXIST AND ARE FULLY POPULATED ===")
    spec_files = sorted(list(SPECS_DIR.glob("**/spec.md")))
    print(f"Found {len(spec_files)} spec.md files in {SPECS_DIR.relative_to(ROOT_DIR)}:")
    
    spec_info = []
    for sfile in spec_files:
        rel_path = sfile.relative_to(ROOT_DIR)
        size = sfile.stat().st_size
        with open(sfile, "r", encoding="utf-8", errors="replace") as f:
            content = f.read()
            lines = content.splitlines()
        
        headers = [line for line in lines if line.startswith("#")]
        
        info = {
            "path": str(rel_path),
            "size_bytes": size,
            "line_count": len(lines),
            "header_count": len(headers),
            "top_header": headers[0] if headers else "NO HEADER",
            "is_empty": size == 0 or len(content.strip()) == 0
        }
        spec_info.append(info)
        print(f"  {info['path']} | Size: {size} B | Lines: {info['line_count']} | Headers: {info['header_count']} | Top: {info['top_header']}")
        
    return spec_info

def task_3_schema_mapping_verification():
    print("\n=== TASK 3: VERIFY SHAREPOINT LIST JSON SCHEMAS MAPPED 1-TO-1 IN spec.md FILES ===")
    
    json_files = sorted(list(DATAMODEL_DIR.glob("**/*.json")))
    print(f"Total JSON files in datamodel/sharepoint/lists/: {len(json_files)}")
    
    # Parse list metadata
    lists_meta = []
    for jfile in json_files:
        rel_path = jfile.relative_to(ROOT_DIR)
        subfolder = jfile.parent.name
        basename = jfile.stem
        try:
            with open(jfile, "r", encoding="utf-8") as f:
                data = json.load(f)
                list_name = data.get("list_name", basename)
                title = data.get("title", "")
                entity_type = data.get("entity_type", "")
        except Exception as e:
            list_name = basename
            title = ""
            entity_type = ""
            print(f"  [ERROR reading {rel_path}]: {e}")
            
        lists_meta.append({
            "path": str(rel_path),
            "subfolder": subfolder,
            "file_stem": basename,
            "list_name": list_name,
            "title": title
        })

    # Load content of all spec.md files
    spec_files = sorted(list(SPECS_DIR.glob("**/spec.md")))
    specs_content = {}
    for sfile in spec_files:
        rel_path = str(sfile.relative_to(ROOT_DIR))
        with open(sfile, "r", encoding="utf-8", errors="replace") as f:
            specs_content[rel_path] = f.read()

    # Map each list JSON to spec.md files
    mapping_results = []
    for lmeta in lists_meta:
        matches = []
        stem = lmeta["file_stem"]
        lname = lmeta["list_name"]
        
        for spec_path, content in specs_content.items():
            # Check if list filename stem or list_name appears in spec
            # Using exact word / substring check for stem and list_name
            found_stem = stem in content
            found_lname = lname in content if lname else False
            
            if found_stem or found_lname:
                matches.append(spec_path)
                
        mapping_results.append({
            "json_path": lmeta["path"],
            "subfolder": lmeta["subfolder"],
            "file_stem": stem,
            "list_name": lname,
            "mapped_specs": matches,
            "match_count": len(matches)
        })
        
    unmapped = [m for m in mapping_results if m["match_count"] == 0]
    multi_mapped = [m for m in mapping_results if m["match_count"] > 1]
    exactly_one = [m for m in mapping_results if m["match_count"] == 1]
    
    print(f"\nSchema Mapping Summary:")
    print(f"  Total SharePoint List schemas: {len(mapping_results)}")
    print(f"  Mapped to exactly 1 spec.md: {len(exactly_one)}")
    print(f"  Mapped to >1 spec.md: {len(multi_mapped)}")
    print(f"  Unmapped (0 spec.md): {len(unmapped)}")
    
    if unmapped:
        print("\n--- UNMAPPED SCHEMAS ---")
        for u in unmapped:
            print(f"  {u['json_path']} (stem: {u['file_stem']}, list_name: {u['list_name']})")
            
    if multi_mapped:
        print("\n--- MULTI-MAPPED SCHEMAS ---")
        for m in multi_mapped:
            print(f"  {m['json_path']} -> mapped in {m['match_count']} specs: {m['mapped_specs']}")

    return mapping_results

if __name__ == "__main__":
    t1 = task_1_placeholder_sweep()
    t2 = task_2_spec_files_check()
    t3 = task_3_schema_mapping_verification()
