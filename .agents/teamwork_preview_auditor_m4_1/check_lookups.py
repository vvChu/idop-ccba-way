import json
import glob
import os

files = glob.glob(r'datamodel/sharepoint/lists/**/*.json', recursive=True)
list_names = set()
lists_by_name = {}

for fpath in files:
    with open(fpath, 'r', encoding='utf-8') as f:
        data = json.load(f)
        lname = data.get('ListName')
        list_names.add(lname)
        lists_by_name[lname] = fpath

print(f"Discovered {len(list_names)} unique ListNames across {len(files)} files.")

pe_files = glob.glob(r'datamodel/sharepoint/lists/process_execution/*.json')
lookup_errors = 0
for fpath in pe_files:
    fname = os.path.basename(fpath)
    with open(fpath, 'r', encoding='utf-8') as f:
        data = json.load(f)
        cols = data.get('Columns', [])
        for col in cols:
            if col.get('Type') == 'Lookup':
                lookup_def = col.get('Lookup', {})
                target_list = lookup_def.get('List')
                if target_list not in list_names:
                    print(f"[LOOKUP ERROR] {fname} -> column '{col.get('Name')}': target list '{target_list}' does not exist!")
                    lookup_errors += 1
                else:
                    target_field = lookup_def.get('Field', 'ID')
                    if target_field not in ['ID', 'Title']:
                        target_fpath = lists_by_name[target_list]
                        with open(target_fpath, 'r', encoding='utf-8') as tf:
                            tdata = json.load(tf)
                            tcols = [tc.get('Name') for tc in tdata.get('Columns', [])]
                            tcols.extend(['ID', 'Title'])
                            if target_field not in tcols:
                                print(f"[LOOKUP WARNING] {fname} -> column '{col.get('Name')}': target field '{target_field}' not in target list '{target_list}'")

print(f"Process Execution Lookup Errors: {lookup_errors}")
