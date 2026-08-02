import glob
import json
import os
import sys

project_root = r"d:\idop-ccba-way"
lists_dir = os.path.join(project_root, "datamodel", "sharepoint", "lists")
taxonomy_dir = os.path.join(project_root, "datamodel", "sharepoint", "taxonomy")

# 1. Load all 59 lists
lists_by_name = {}
list_files = glob.glob(f"{lists_dir}/**/*.json", recursive=True)

for f in list_files:
    with open(f, 'r', encoding='utf-8') as fp:
        data = json.load(fp)
        name = data.get('ListName')
        if name:
            lists_by_name[name] = {
                'file': f,
                'rel_path': os.path.relpath(f, project_root),
                'data': data,
                'columns': {col['Name']: col for col in data.get('Columns', [])}
            }

print(f"Loaded {len(lists_by_name)} list schemas from {lists_dir}.")

# Standard built-in SharePoint columns
STANDARD_SP_COLS = {'ID', 'Title', 'Created', 'Modified', 'Author', 'Editor', 'Attachments', 'ContentType'}

# 2. Load all 21 taxonomy term sets
taxonomy_sets = {}
tax_files = glob.glob(f"{taxonomy_dir}/*.json")
for f in tax_files:
    with open(f, 'r', encoding='utf-8') as fp:
        data = json.load(fp)
        ts_info = data.get('TermSetInfo', {})
        name = ts_info.get('Name')
        if name:
            taxonomy_sets[name] = {
                'file': f,
                'rel_path': os.path.relpath(f, project_root),
                'info': ts_info,
                'terms': data.get('Terms', [])
            }

print(f"Loaded {len(taxonomy_sets)} taxonomy term set definitions from {taxonomy_dir}.\n")

# 3. Check Taxonomy bindings across all lists
tax_errors = []
tax_checked = 0

for list_name, ldata in sorted(lists_by_name.items()):
    for col_name, col in ldata['columns'].items():
        if col.get('Type') == 'ManagedMetadata' or 'TermSet' in col:
            tax_checked += 1
            ts = col.get('TermSet', {})
            ts_name = ts.get('Name')
            ts_group = ts.get('Group')
            if not ts_name:
                tax_errors.append(f"[{list_name}.{col_name}] Missing TermSet.Name")
            elif ts_name not in taxonomy_sets:
                tax_errors.append(f"[{list_name}.{col_name}] References unknown TermSet: {ts_name}")

print(f"Taxonomy check results: {tax_checked} taxonomy columns checked across 59 lists.")
if tax_errors:
    print(f"Taxonomy Errors ({len(tax_errors)}):")
    for err in tax_errors:
        print("  -", err)
else:
    print("  ALL taxonomy term set references are 100% VALID!\n")

# 4. Check Lookup references across all lists
lookup_errors = []
lookups_checked = 0

for list_name, ldata in sorted(lists_by_name.items()):
    for col_name, col in ldata['columns'].items():
        if col.get('Type') in ['Lookup', 'LookupMulti']:
            lookups_checked += 1
            lk = col.get('Lookup')
            if not lk:
                lookup_errors.append(f"[{list_name}.{col_name}] Missing Lookup configuration object")
                continue
            target_list_name = lk.get('List')
            target_field_name = lk.get('Field')
            
            if not target_list_name:
                lookup_errors.append(f"[{list_name}.{col_name}] Missing Lookup.List target name")
                continue
            if target_list_name not in lists_by_name:
                lookup_errors.append(f"[{list_name}.{col_name}] Target list does NOT exist: '{target_list_name}'")
                continue
            
            target_list = lists_by_name[target_list_name]
            if target_field_name not in STANDARD_SP_COLS and target_field_name not in target_list['columns']:
                lookup_errors.append(f"[{list_name}.{col_name}] Target field '{target_field_name}' does NOT exist in target list '{target_list_name}'")

print(f"Lookup check results: {lookups_checked} lookup columns checked across 59 lists.")
if lookup_errors:
    print(f"Lookup Errors ({len(lookup_errors)}):")
    for err in lookup_errors:
        print("  -", err)
else:
    print("  ALL lookup references across 59 lists are 100% VALID!\n")

# 5. Deep Graph Analysis for Requirement 3:
# AssignmentDetails -> JobAssignments -> ScopeDepartmentAllocations -> ContractScopes -> Projects
target_graph_lists = ['AssignmentDetails', 'JobAssignments', 'ScopeDepartmentAllocations', 'ContractScopes', 'Projects']
print("="*60)
print("DEEP GRAPH ANALYSIS FOR REQUIREMENT 3 TARGET LISTS:")
print("="*60)

for t_list in target_graph_lists:
    if t_list not in lists_by_name:
        print(f"CRITICAL ERROR: Target graph list '{t_list}' NOT FOUND in schemas!")
        continue
    
    ldata = lists_by_name[t_list]
    print(f"\nList: {t_list} ({ldata['rel_path']})")
    
    # List outgoing lookups
    outgoing = []
    for col_name, col in ldata['columns'].items():
        if col.get('Type') in ['Lookup', 'LookupMulti']:
            lk = col.get('Lookup', {})
            outgoing.append({
                'Column': col_name,
                'Type': col.get('Type'),
                'TargetList': lk.get('List'),
                'TargetField': lk.get('Field'),
                'Behavior': lk.get('Behavior')
            })
    
    print("  Outgoing Lookups:")
    if outgoing:
        for out in outgoing:
            print(f"    - {out['Column']} ({out['Type']}) -> {out['TargetList']}.{out['TargetField']} [Behavior: {out['Behavior']}]")
    else:
        print("    (None)")

print("\n" + "="*60)
print("CHECKING CLOSED GRAPH TOPOLOGY & INCOMING REFERENCES:")
print("="*60)

for t_list in target_graph_lists:
    incoming = []
    for l_name, ldata in lists_by_name.items():
        for col_name, col in ldata['columns'].items():
            if col.get('Type') in ['Lookup', 'LookupMulti']:
                lk = col.get('Lookup', {})
                if lk.get('List') == t_list:
                    incoming.append({
                        'SourceList': l_name,
                        'Column': col_name,
                        'TargetField': lk.get('Field')
                    })
    print(f"\nList: {t_list} incoming lookups ({len(incoming)} references):")
    for inc in incoming:
        print(f"    <- {inc['SourceList']}.{inc['Column']} (targeting {t_list}.{inc['TargetField']})")

