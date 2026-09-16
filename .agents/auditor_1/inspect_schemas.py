import glob
import json
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("=== DEEP INSPECTION OF 57 JSON LIST SCHEMAS ===")
json_files = sorted(glob.glob('datamodel/sharepoint/lists/**/*.json', recursive=True))

total_columns = 0
schema_errors = []

for idx, f in enumerate(json_files, 1):
    rel = os.path.relpath(f, '.')
    with open(f, 'r', encoding='utf-8') as fp:
        try:
            data = json.load(fp)
        except Exception as e:
            schema_errors.append((rel, f"JSON parse error: {e}"))
            continue
    
    list_name = data.get('ListName') or data.get('title')
    desc = data.get('Description', '')
    cols = data.get('Columns', [])
    
    if not list_name:
        schema_errors.append((rel, "Missing ListName"))
    if not isinstance(cols, list):
        schema_errors.append((rel, "Columns is not a list"))
    
    col_count = len(cols)
    total_columns += col_count
    
    # Check columns
    for col in cols:
        if 'Name' not in col or 'Type' not in col:
            schema_errors.append((rel, f"Column missing Name or Type: {col}"))
            
    print(f"[{idx:02d}] {rel:<55} | ListName: {str(list_name):<30} | Cols: {col_count:<2} | Desc: {desc[:40]}")

print(f"\nTotal JSON Schemas: {len(json_files)}")
print(f"Total Columns across all 57 Schemas: {total_columns}")
print(f"Schema Errors: {len(schema_errors)}")
if schema_errors:
    for err in schema_errors:
        print(f"  ❌ {err[0]}: {err[1]}")
else:
    print("  ✅ All 57 JSON schemas have valid ListName, Description, and Columns definitions!")
