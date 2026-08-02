import json
import glob
import os

tax_files = glob.glob(r'datamodel/sharepoint/taxonomy/*.json')
term_sets = set()
for tf in tax_files:
    with open(tf, 'r', encoding='utf-8') as f:
        data = json.load(f)
        ts_name = data.get('Name') or data.get('TermSetName') or os.path.splitext(os.path.basename(tf))[0]
        term_sets.add(ts_name)

print(f"Discovered {len(term_sets)} term sets: {sorted(list(term_sets))}")

pe_files = glob.glob(r'datamodel/sharepoint/lists/process_execution/*.json')
tax_errors = 0
for fpath in pe_files:
    fname = os.path.basename(fpath)
    with open(fpath, 'r', encoding='utf-8') as f:
        data = json.load(f)
        cols = data.get('Columns', [])
        for col in cols:
            if col.get('Type') in ['ManagedMetadata', 'Taxonomy']:
                ts_def = col.get('TermSet', {})
                ts_name = ts_def.get('Name')
                if ts_name not in term_sets:
                    print(f"[TAXONOMY ERROR] {fname} -> column '{col.get('Name')}': term set '{ts_name}' not found!")
                    tax_errors += 1
                else:
                    print(f"[TAXONOMY MATCH] {fname} -> '{col.get('Name')}' uses '{ts_name}'")

print(f"Process Execution Taxonomy Errors: {tax_errors}")
