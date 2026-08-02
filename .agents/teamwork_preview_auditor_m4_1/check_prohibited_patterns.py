import glob
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

target_files = glob.glob(r'datamodel/sharepoint/lists/process_execution/*.json')
target_files.append(r'specs/modules/process_execution/pmo/spec.md')

suspicious_terms = [
    "mock", "dummy", "fake", "hardcoded", "lorem ipsum",
    "todo: implement", "placeholder", "fixme", "test_pass_constant"
]

print(f"=== Prohibited Pattern Search in {len(target_files)} target files ===")

findings = 0
for fpath in target_files:
    fname = os.path.basename(fpath)
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.splitlines()
        for idx, line in enumerate(lines, start=1):
            line_lower = line.lower()
            for term in suspicious_terms:
                if term in line_lower:
                    print(f"  [FLAG] {fpath}:{idx} -> contains term '{term}': {line.strip()[:100]}")
                    findings += 1

print(f"Total Suspicious Flags: {findings}")
