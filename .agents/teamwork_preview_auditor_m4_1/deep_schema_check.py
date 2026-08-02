import json
import glob
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

pe_files = glob.glob(r'datamodel/sharepoint/lists/process_execution/*.json')

name_pattern = re.compile(r'^[A-Z][a-zA-Z0-9]*$')

print(f"=== Deep Schema Check on {len(pe_files)} Process Execution files ===")

issues = []

for fpath in pe_files:
    fname = os.path.basename(fpath)
    with open(fpath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    list_name = data.get("ListName", "")
    if not name_pattern.match(list_name):
        issues.append(f"{fname}: ListName '{list_name}' does not match PascalCase pattern ^[A-Z][a-zA-Z0-9]*$")
    
    cols = data.get("Columns", [])
    for idx, col in enumerate(cols):
        col_name = col.get("Name", "")
        if not name_pattern.match(col_name):
            issues.append(f"{fname}: Column #{idx+1} Name '{col_name}' does not match PascalCase pattern ^[A-Z][a-zA-Z0-9]*$")
        
        # Check for suspicious hardcoded strings in DisplayName or Description
        disp = col.get("DisplayName", "")
        desc = col.get("Description", "")
        for text_val in [disp, desc]:
            if any(fake in text_val.lower() for fake in ["dummy", "lorem ipsum", "mock test", "fake data", "hardcoded_pass"]):
                issues.append(f"{fname}: Suspicious fake text found in column '{col_name}': {text_val}")

if not issues:
    print("SUCCESS: 0 structural or naming issues found across all process_execution schemas.")
else:
    print(f"ISSUES FOUND ({len(issues)}):")
    for issue in issues:
        print(f"  - {issue}")
