import os
import json
import re
from pathlib import Path

BASE_DIR = Path(r"d:\idop-ccba-way")
SPECS_DIR = BASE_DIR / "specs" / "modules"
DATAMODEL_DIR = BASE_DIR / "datamodel" / "sharepoint" / "lists"

def detailed_mapping_matrix():
    json_schemas = list(DATAMODEL_DIR.rglob("*.json"))
    spec_md_files = list(SPECS_DIR.rglob("spec.md"))

    print(f"Total JSON Schemas: {len(json_schemas)}")
    print(f"Total Spec Files: {len(spec_md_files)}")

    matrix = []

    for jf in sorted(json_schemas):
        rel_json = jf.relative_to(DATAMODEL_DIR)
        module = rel_json.parts[0]
        schema_stem = jf.stem
        filename = jf.name
        
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        title = data.get("Title") or data.get("title") or schema_stem
        columns = data.get("Columns", [])
        col_names = [c.get("Name") for c in columns if isinstance(c, dict) and "Name" in c]

        matching_specs = []
        for smf in spec_md_files:
            rel_spec = smf.relative_to(BASE_DIR)
            with open(smf, 'r', encoding='utf-8') as f:
                spec_text = f.read()

            if schema_stem in spec_text or filename in spec_text or title in spec_text:
                matching_specs.append(str(rel_spec))

        matrix.append({
            "module": module,
            "json_path": str(rel_json),
            "stem": schema_stem,
            "title": title,
            "cols_count": len(col_names),
            "matching_specs": matching_specs
        })

    # Output detailed report
    print("\n================ DETAILED SCHEMA MAPPING MATRIX ================")
    for idx, item in enumerate(matrix, 1):
        spec_str = ", ".join(item['matching_specs']) if item['matching_specs'] else "UNMAPPED"
        print(f"{idx:02d}. [{item['module']}] {item['stem']} ({item['cols_count']} cols) -> Specs: {spec_str}")

    return matrix

if __name__ == "__main__":
    detailed_mapping_matrix()
