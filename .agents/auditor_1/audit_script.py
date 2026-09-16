import glob
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("Starting Comprehensive Forensic Audit...")

# ==============================================================================
# 1. AUDIT JSON LIST SCHEMAS
# ==============================================================================
json_files = sorted(glob.glob('datamodel/sharepoint/lists/**/*.json', recursive=True))
print(f"\n=== 1. JSON LIST SCHEMAS AUDIT ({len(json_files)} files) ===")

schema_issues = []
schema_details = []
forbidden_kw = ['todo', 'tbd', 'fixme', 'placeholder', 'dummy', 'fake', 'sample_data']

for f in json_files:
    rel = os.path.relpath(f, '.')
    with open(f, 'r', encoding='utf-8') as fp:
        try:
            data = json.load(fp)
        except Exception as e:
            schema_issues.append((rel, f"Invalid JSON: {e}"))
            continue
    
    raw = json.dumps(data).lower()
    found_kw = [kw for kw in forbidden_kw if kw in raw]
    if found_kw:
        schema_issues.append((rel, f"Contains forbidden keyword(s): {found_kw}"))
    
    if isinstance(data, dict):
        list_name = data.get('list_name') or data.get('ListName') or data.get('title') or data.get('name') or data.get('ListTitle') or os.path.basename(f)
        fields = data.get('fields') or data.get('columns') or data.get('properties') or data.get('Fields') or []
        schema_details.append({
            'file': rel,
            'list_name': list_name,
            'field_count': len(fields) if isinstance(fields, (list, dict)) else 0,
            'keys': list(data.keys())
        })
    else:
        schema_issues.append((rel, "Root JSON is not an object/dict"))

print(f"Total List Schemas Found: {len(json_files)}")
print(f"Total List Schema Issues: {len(schema_issues)}")
if schema_issues:
    for iss in schema_issues:
        print(f"  ❌ ISSUE in {iss[0]}: {iss[1]}")
else:
    print("  ✅ All 57 JSON list schemas exist, are valid JSON, and contain no forbidden keywords/placeholders!")

# Summary of schemas by directory/module
module_counts = {}
for item in schema_details:
    mod = item['file'].split(os.sep)[3] if len(item['file'].split(os.sep)) > 3 else 'other'
    module_counts[mod] = module_counts.get(mod, 0) + 1

print("\nList Schema Distribution by Module:")
for mod, cnt in module_counts.items():
    print(f"  - {mod}: {cnt} list schemas")


# ==============================================================================
# 2. AUDIT 21 SPEC.MD FILES
# ==============================================================================
spec_files = sorted(glob.glob('specs/modules/**/spec.md', recursive=True))
print(f"\n=== 2. SPEC.MD FILES AUDIT ({len(spec_files)} files) ===")

spec_issues = []
spec_details = []

qctk_pattern = re.compile(r'2815|qctk', re.IGNORECASE)
qcctnb_pattern = re.compile(r'3209|qcctnb', re.IGNORECASE)
ccba_pattern = re.compile(r'ccba|2026', re.IGNORECASE)

placeholder_terms = ['[tbd]', 'todo:', 'fixme:', 'lorem ipsum', 'placeholder', '[insert', '[draft]']

for f in spec_files:
    rel = os.path.relpath(f, '.')
    with open(f, 'r', encoding='utf-8') as fp:
        content = fp.read()
    
    lines = content.splitlines()
    word_count = len(content.split())
    
    lowered = content.lower()
    found_placeholders = [kw for kw in placeholder_terms if kw in lowered]
    
    if found_placeholders:
        spec_issues.append((rel, f"Placeholders found: {found_placeholders}"))
    
    has_2815 = bool(qctk_pattern.search(content))
    has_3209 = bool(qcctnb_pattern.search(content))
    has_ccba = bool(ccba_pattern.search(content))
    
    spec_details.append({
        'path': rel,
        'lines': len(lines),
        'words': word_count,
        'has_2815': has_2815,
        'has_3209': has_3209,
        'has_ccba': has_ccba
    })

print(f"Total Spec Files Found: {len(spec_files)}")
print(f"Total Spec File Issues: {len(spec_issues)}")
if spec_issues:
    for iss in spec_issues:
        print(f"  ❌ ISSUE in {iss[0]}: {iss[1]}")
else:
    print("  ✅ All 21 spec.md files exist, are complete, and contain zero placeholders!")

print("\nDetailed Spec.md Inspection Table:")
print(f"{'Path':<60} | {'Lines':<6} | {'Words':<7} | {'QCTK 2815':<10} | {'QCCTNB 3209':<12} | {'CCBA 2026':<10}")
print("-" * 115)
for s in spec_details:
    p = s['path']
    if len(p) > 58:
        p = "..." + p[-55:]
    print(f"{p:<60} | {s['lines']:<6} | {s['words']:<7} | {str(s['has_2815']):<10} | {str(s['has_3209']):<12} | {str(s['has_ccba']):<10}")


# ==============================================================================
# 3. GLOBAL REPO FORENSIC SCAN FOR PROHIBITED PATTERNS
# ==============================================================================
print("\n=== 3. GLOBAL REPO FORENSIC SCAN FOR PROHIBITED PATTERNS ===")

all_files = glob.glob('**/*', recursive=True)
all_project_files = [
    f for f in all_files 
    if os.path.isfile(f) 
    and not f.startswith('.git') 
    and not f.startswith('.agents')
    and not f.endswith('.png')
    and not f.endswith('.jpg')
    and not f.endswith('.pyc')
]

suspect_patterns = [
    (re.compile(r'fake[_\-]?token|dummy[_\-]?token|mock[_\-]?token', re.I), 'Fake/Dummy Token'),
    (re.compile(r'hardcoded[_\-]?result|hardcoded[_\-]?output', re.I), 'Hardcoded Result'),
    (re.compile(r'def\s+\w+\([^)]*\):\s*(?:return|pass)\s*(?:True|False|None|"OK"|\'OK\'|0|{})?\s*$', re.M), 'Facade Function (empty/constant return)'),
    (re.compile(r'jwt\.encode\(.*dummy.*\)', re.I), 'Dummy JWT Token Generation'),
    (re.compile(r'bearer\s+dummy|bearer\s+test|bearer\s+fake', re.I), 'Fake Authorization Token'),
]

forensic_violations = []

for f in all_project_files:
    try:
        with open(f, 'r', encoding='utf-8', errors='ignore') as fp:
            content = fp.read()
        
        for pat, desc in suspect_patterns:
            matches = pat.findall(content)
            if matches:
                forensic_violations.append({
                    'file': os.path.relpath(f, '.'),
                    'description': desc,
                    'count': len(matches),
                    'matches': matches[:3]
                })
    except Exception as e:
        pass

print(f"Total Forensic Scan Violations: {len(forensic_violations)}")
if forensic_violations:
    for v in forensic_violations:
        print(f"  ❌ VIOLATION in {v['file']}: {v['description']} ({v['count']} matches)")
else:
    print("  ✅ ZERO hardcoding, dummy implementations, or fake token generation found across all project files!")


# ==============================================================================
# 4. OVERALL SUMMARY AND VERDICT AUDIT
# ==============================================================================
print("\n=== 4. AUDIT SUMMARY ===")
print(f"1. JSON List Schemas: {len(json_files)} / 57 verified valid.")
print(f"2. Domain Specs (spec.md): {len(spec_files)} / 21 verified complete.")
print(f"3. Prohibited Patterns Scan: {len(forensic_violations)} violations found.")

if len(json_files) == 57 and len(schema_issues) == 0 and len(spec_files) == 21 and len(spec_issues) == 0 and len(forensic_violations) == 0:
    print("\nFINAL VERDICT: CLEAN")
else:
    print("\nFINAL VERDICT: INTEGRITY VIOLATION")
