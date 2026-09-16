import glob
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("Starting Deep Empirical Audit of 57 JSON Schemas and 21 Specs...")

# 1. Detailed breakdown of 57 JSON List Schemas
json_files = sorted(glob.glob('datamodel/sharepoint/lists/**/*.json', recursive=True))
print(f"\n=== VERIFYING 57 LIST SCHEMAS (Found: {len(json_files)}) ===")

schemas_by_dir = {}
total_fields = 0

for idx, f in enumerate(json_files, 1):
    rel = os.path.relpath(f, '.')
    dir_name = os.path.dirname(rel)
    if dir_name not in schemas_by_dir:
        schemas_by_dir[dir_name] = []
    
    with open(f, 'r', encoding='utf-8') as fp:
        data = json.load(fp)
    
    list_name = data.get('list_name') or data.get('ListName') or data.get('title') or data.get('name') or os.path.basename(f)
    fields = data.get('fields') or data.get('columns') or data.get('properties') or []
    num_fields = len(fields) if isinstance(fields, (list, dict)) else 0
    total_fields += num_fields
    
    schemas_by_dir[dir_name].append({
        'index': idx,
        'rel': rel,
        'filename': os.path.basename(f),
        'list_name': list_name,
        'num_fields': num_fields
    })

for dir_path, items in schemas_by_dir.items():
    print(f"\nDirectory: {dir_path} ({len(items)} schemas)")
    for item in items:
        print(f"  [{item['index']:02d}] {item['filename']:<35} | ListName: {item['list_name']:<30} | Fields: {item['num_fields']}")

print(f"\nTOTAL LIST SCHEMAS: {len(json_files)}")
print(f"TOTAL FIELDS ACROSS ALL SCHEMAS: {total_fields}")

# 2. Detailed verification of 21 Spec files
spec_files = sorted(glob.glob('specs/modules/**/spec.md', recursive=True))
print(f"\n=== VERIFYING 21 SPEC FILES (Found: {len(spec_files)}) ===")

for idx, f in enumerate(spec_files, 1):
    rel = os.path.relpath(f, '.')
    with open(f, 'r', encoding='utf-8') as fp:
        c = fp.read()
    
    lines = len(c.splitlines())
    words = len(c.split())
    
    # Check key sections
    has_overview = 'tổng quan' in c.lower() or 'overview' in c.lower() or 'mô tả' in c.lower()
    has_entities = 'thực thể' in c.lower() or 'entity' in c.lower() or 'danh sách' in c.lower() or 'schema' in c.lower()
    has_rules = 'quy tắc' in c.lower() or 'business rule' in c.lower() or 'nghiệp vụ' in c.lower() or 'logic' in c.lower()
    
    print(f"[{idx:02d}] {rel:<55} | Lines: {lines:<4} | Words: {words:<5} | Overview: {has_overview} | Entities: {has_entities} | Rules: {has_rules}")

print("\nAudit Script Execution Complete.")
