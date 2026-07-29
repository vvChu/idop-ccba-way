import os
import glob
import json
import re
from pathlib import Path

BASE_DIR = Path(r"d:\idop-ccba-way")
SPECS_DIR = BASE_DIR / "specs" / "modules"
DATAMODEL_DIR = BASE_DIR / "datamodel" / "sharepoint" / "lists"

def check_placeholders():
    print("=== CHECKING FOR '...' PLACEHOLDERS IN SPECS ===")
    spec_files = list(SPECS_DIR.rglob("*.md"))
    print(f"Found {len(spec_files)} markdown files in {SPECS_DIR}:")
    for sf in spec_files:
        print(f" - {sf.relative_to(BASE_DIR)}")

    placeholder_matches = []
    
    # Regex to catch '...' as standalone or within text, ignoring standard markdown code block markers or ellipsis if any,
    # but we want to catch literal '...' placeholder indicators.
    placeholder_pattern = re.compile(r'\.\.\.')

    for sf in spec_files:
        with open(sf, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        in_code_block = False
        for line_num, line in enumerate(lines, 1):
            if line.strip().startswith("```"):
                in_code_block = not in_code_block
            
            # Search for '...'
            if '...' in line:
                placeholder_matches.append({
                    "file": str(sf.relative_to(BASE_DIR)),
                    "line": line_num,
                    "content": line.strip(),
                    "in_code_block": in_code_block
                })

    print(f"\nTotal '...' matches found: {len(placeholder_matches)}")
    for m in placeholder_matches:
        print(f"  [{m['file']}:{m['line']}] {m['content']}")

    return spec_files, placeholder_matches

def check_schema_mappings(spec_files):
    print("\n=== CHECKING SHAREPOINT SCHEMA MAPPINGS ===")
    json_files = list(DATAMODEL_DIR.rglob("*.json"))
    print(f"Total JSON schema files found in {DATAMODEL_DIR}: {len(json_files)}")

    schemas_by_module = {}
    all_schemas = {}

    for jf in json_files:
        rel_path = jf.relative_to(DATAMODEL_DIR)
        module_name = rel_path.parts[0] if len(rel_path.parts) > 1 else "root"
        
        try:
            with open(jf, 'r', encoding='utf-8') as f:
                content = json.load(f)
        except Exception as e:
            content = {}
            print(f"Error reading {jf}: {e}")

        title = content.get("Title") or content.get("title") or jf.stem
        list_name = content.get("Url") or content.get("url") or jf.stem
        
        schema_info = {
            "full_path": jf,
            "rel_path": str(rel_path),
            "filename": jf.name,
            "stem": jf.stem,
            "title": title,
            "module": module_name,
            "content": content
        }
        
        all_schemas[jf.stem] = schema_info
        schemas_by_module.setdefault(module_name, []).append(schema_info)

    print("\nSchema count per module:")
    for mod, s_list in sorted(schemas_by_module.items()):
        print(f"  - {mod}: {len(s_list)} schemas")

    # Read spec files contents
    spec_contents = {}
    for sf in spec_files:
        with open(sf, 'r', encoding='utf-8') as f:
            spec_contents[sf.relative_to(BASE_DIR)] = f.read()

    # Check mapping for each schema
    mapping_results = []
    unmapped_schemas = []
    mapped_schemas = []

    for stem, info in sorted(all_schemas.items()):
        # Look for filename, stem, or title in spec files
        found_in = []
        for spec_path, text in spec_contents.items():
            # Check if filename or stem or title is referenced in spec
            # Also check matching patterns like list name
            pattern = re.compile(re.escape(info['stem']) + r'|\b' + re.escape(info['title']) + r'\b', re.IGNORECASE)
            if info['stem'] in text or info['filename'] in text or (info['title'] and info['title'] in text):
                found_in.append(str(spec_path))
        
        if found_in:
            mapped_schemas.append((info, found_in))
        else:
            unmapped_schemas.append(info)

    print(f"\nTotal Mapped Schemas: {len(mapped_schemas)} / {len(all_schemas)}")
    print(f"Total Unmapped Schemas: {len(unmapped_schemas)} / {len(all_schemas)}")

    if unmapped_schemas:
        print("\nUNMAPPED SCHEMAS:")
        for u in unmapped_schemas:
            print(f"  - [{u['module']}] {u['rel_path']} (Title: '{u['title']}')")

    # Check if there are duplicate or 1-to-1 verification details
    print("\nDetailed Schema Mapping per Spec file:")
    for sf in spec_files:
        rel_spec = sf.relative_to(BASE_DIR)
        text = spec_contents[rel_spec]
        matched_in_this_spec = [info['stem'] for stem, info in all_schemas.items() if info['stem'] in text or info['filename'] in text or (info['title'] and info['title'] in text)]
        print(f"  Spec: {rel_spec} -> Mapped {len(matched_in_this_spec)} schemas")

    return json_files, mapped_schemas, unmapped_schemas

if __name__ == "__main__":
    spec_files, placeholder_matches = check_placeholders()
    json_files, mapped_schemas, unmapped_schemas = check_schema_mappings(spec_files)
    
    print("\n=== SUMMARY RESULT ===")
    print(f"1. Placeholder sweep: {len(placeholder_matches)} occurrences of '...' found.")
    print(f"2. Schema count: {len(json_files)} schemas found in datamodel/sharepoint/lists/.")
    print(f"3. Schema mapping: {len(mapped_schemas)} mapped, {len(unmapped_schemas)} unmapped.")
