import os
import json
import re
from pathlib import Path

BASE_DIR = Path(r"d:\idop-ccba-way")
SPECS_DIR = BASE_DIR / "specs" / "modules"
DATAMODEL_DIR = BASE_DIR / "datamodel" / "sharepoint" / "lists"

def deep_placeholder_check():
    print("=== DEEP PLACEHOLDER CHECK ===")
    spec_md_files = list(SPECS_DIR.rglob("spec.md"))
    print(f"Found {len(spec_md_files)} spec.md files specifically.")

    patterns = {
        "literal_ellipsis_3_dots": re.compile(r'\.\.\.'),
        "unicode_ellipsis": re.compile(r'…'),
        "todo_tbd_markers": re.compile(r'\b(TODO|TBD|FIXME)\b', re.IGNORECASE),
        "bracket_placeholders": re.compile(r'\[\s*(insert|fill|placeholder|your|xyz)\s*.*\]', re.IGNORECASE)
    }

    findings = {p: [] for p in patterns}

    for smf in spec_md_files:
        with open(smf, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        for line_idx, line in enumerate(lines, 1):
            for p_name, p_regex in patterns.items():
                if p_regex.search(line):
                    findings[p_name].append({
                        "file": str(smf.relative_to(BASE_DIR)),
                        "line": line_idx,
                        "text": line.strip()
                    })

    for p_name, matches in findings.items():
        print(f"\nPattern '{p_name}': {len(matches)} matches")
        for m in matches[:10]: # Print first 10 if any
            print(f"  [{m['file']}:{m['line']}] {m['text']}")

    return spec_md_files, findings

def deep_schema_mapping_check(spec_md_files):
    print("\n=== DEEP 1-TO-1 SCHEMA MAPPING CHECK ===")
    
    # Collect all 57 schema files
    json_schemas = list(DATAMODEL_DIR.rglob("*.json"))
    print(f"Total JSON schema files in datamodel/sharepoint/lists: {len(json_schemas)}")

    schema_map = {}
    for jf in json_schemas:
        rel = jf.relative_to(DATAMODEL_DIR)
        module = rel.parts[0]
        schema_name = jf.stem
        
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)

        title = data.get("Title") or data.get("title") or schema_name
        url = data.get("Url") or data.get("url") or ""
        fields = [col.get("Name") or col.get("name") for col in data.get("Columns", []) if isinstance(col, dict)]
        
        schema_map[schema_name] = {
            "path": jf,
            "rel_path": str(rel),
            "module": module,
            "title": title,
            "url": url,
            "fields_count": len(fields),
            "mapped_in_spec": [],
            "mapped_in_exact_module_spec": []
        }

    # Now read all spec.md files and search for explicit schema mappings
    spec_md_map = {}
    for smf in spec_md_files:
        rel_spec = smf.relative_to(BASE_DIR)
        with open(smf, 'r', encoding='utf-8') as f:
            content = f.read()
        spec_md_map[rel_spec] = content

    for schema_name, s_info in schema_map.items():
        stem = schema_name
        title = s_info['title']
        url = s_info['url']
        module = s_info['module']

        for rel_spec, content in spec_md_map.items():
            # Match by stem, filename, title, or url
            matched = False
            if stem in content or f"{stem}.json" in content:
                matched = True
            elif title and title in content:
                matched = True
            elif url and url in content:
                matched = True

            if matched:
                s_info['mapped_in_spec'].append(str(rel_spec))
                if module in str(rel_spec):
                    s_info['mapped_in_exact_module_spec'].append(str(rel_spec))

    # Verify per module breakdown
    module_summary = {}
    unmapped_exact = []
    unmapped_any = []

    for s_name, s_info in schema_map.items():
        mod = s_info['module']
        module_summary.setdefault(mod, {"total": 0, "mapped_any": 0, "mapped_exact_mod": 0})
        module_summary[mod]["total"] += 1
        
        if s_info['mapped_in_spec']:
            module_summary[mod]["mapped_any"] += 1
        else:
            unmapped_any.append(s_info)

        if s_info['mapped_in_exact_module_spec']:
            module_summary[mod]["mapped_exact_mod"] += 1
        else:
            unmapped_exact.append(s_info)

    print("\n--- Summary by Module ---")
    for mod, stats in sorted(module_summary.items()):
        print(f"Module '{mod}': {stats['mapped_exact_mod']}/{stats['total']} schemas mapped in exact module spec.md ({stats['mapped_any']} in any spec.md)")

    print(f"\nTotal Schemas: {len(schema_map)}")
    print(f"Schemas mapped in ANY spec.md: {len(schema_map) - len(unmapped_any)} / {len(schema_map)}")
    print(f"Schemas mapped in EXACT module spec.md: {len(schema_map) - len(unmapped_exact)} / {len(schema_map)}")

    if unmapped_any:
        print("\nUNMAPPED SCHEMAS (ANY SPEC):")
        for u in unmapped_any:
            print(f"  - [{u['module']}] {u['rel_path']} (Title: '{u['title']}')")

    if unmapped_exact:
        print("\nUNMAPPED SCHEMAS (EXACT MODULE SPEC):")
        for u in unmapped_exact:
            print(f"  - [{u['module']}] {u['rel_path']} (Title: '{u['title']}')")

    return schema_map, unmapped_any, unmapped_exact

if __name__ == "__main__":
    spec_md_files, findings = deep_placeholder_check()
    schema_map, unmapped_any, unmapped_exact = deep_schema_mapping_check(spec_md_files)
