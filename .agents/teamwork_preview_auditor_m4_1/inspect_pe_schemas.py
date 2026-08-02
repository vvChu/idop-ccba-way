import json
import glob
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

pe_files = glob.glob(r'datamodel/sharepoint/lists/process_execution/*.json')

print(f"=== Inspecting {len(pe_files)} Process Execution Schema Files ===")

valid_types = [
    "Text", "SingleLine", "Note", "Number", "Currency", "DateTime", "Date",
    "YesNo", "Boolean", "Choice", "MultiChoice", "Lookup", "User", "URL",
    "Hyperlink", "ManagedMetadata", "Taxonomy"
]

for fpath in sorted(pe_files):
    fname = os.path.basename(fpath)
    with open(fpath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    list_name = data.get("ListName")
    desc = data.get("Description")
    cols = data.get("Columns", [])
    
    print(f"\nFile: {fname}")
    print(f"  ListName: {list_name}")
    print(f"  Description: {desc[:60]}..." if desc and len(desc) > 60 else f"  Description: {desc}")
    print(f"  Total Columns: {len(cols)}")
    
    col_names = []
    invalid_cols = []
    for col in cols:
        name = col.get("Name")
        ctype = col.get("Type")
        col_names.append(name)
        if ctype not in valid_types:
            invalid_cols.append((name, ctype))
        
        # Check specific constraints
        if ctype in ["Choice", "MultiChoice"]:
            choices = col.get("Choices")
            if not isinstance(choices, list) or len(choices) == 0:
                print(f"    [ERROR] Column {name} of type {ctype} has invalid Choices: {choices}")
        
        if ctype == "Lookup":
            lk = col.get("Lookup")
            if not isinstance(lk, dict) or "List" not in lk:
                print(f"    [ERROR] Column {name} of type Lookup missing required Lookup.List: {lk}")
        
        if ctype in ["ManagedMetadata", "Taxonomy"]:
            ts = col.get("TermSet")
            if not isinstance(ts, dict) or "Group" not in ts or "Name" not in ts:
                print(f"    [ERROR] Column {name} of type {ctype} missing required TermSet (Group, Name): {ts}")

    if invalid_cols:
        print(f"  [ERROR] Invalid Column Types: {invalid_cols}")
    else:
        print(f"  Columns overview: {col_names}")

