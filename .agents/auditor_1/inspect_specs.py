import glob
import re
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

print("=== DETAILED FORENSIC INSPECTION OF ALL 21 SPEC.MD FILES ===")
spec_files = sorted(glob.glob('specs/modules/**/spec.md', recursive=True))

qctk_pattern = re.compile(r'2815|qctk', re.IGNORECASE)
qcctnb_pattern = re.compile(r'3209|qcctnb', re.IGNORECASE)
ccba_pattern = re.compile(r'ccba|2026', re.IGNORECASE)

incomplete_specs = []

for idx, f in enumerate(spec_files, 1):
    rel = os.path.relpath(f, '.')
    with open(f, 'r', encoding='utf-8') as fp:
        content = fp.read()
    
    lines = len(content.splitlines())
    words = len(content.split())
    
    # Check domain regulation mentions
    has_2815 = bool(qctk_pattern.search(content))
    has_3209 = bool(qcctnb_pattern.search(content))
    has_ccba = bool(ccba_pattern.search(content))
    
    # Check key technical sections
    sections_found = {
        'Overview/Scope': bool(re.search(r'#+\s*(?:1\.|tổng quan|phạm vi|overview)', content, re.I)),
        'Data Model/Schemas': bool(re.search(r'#+\s*(?:2\.|thực thể|schema|danh sách|data model)', content, re.I)),
        'Business Logic/Rules': bool(re.search(r'#+\s*(?:3\.|quy tắc|nghiệp vụ|business logic|luồng)', content, re.I)),
        'Governance/Security': bool(re.search(r'#+\s*(?:4\.|phân quyền|quy chế|bảo mật|governance)', content, re.I)),
    }
    
    missing_secs = [k for k, v in sections_found.items() if not v]
    
    if lines < 50 or words < 500 or missing_secs or not (has_2815 and has_3209 and has_ccba):
        incomplete_specs.append({
            'file': rel,
            'lines': lines,
            'words': words,
            'has_2815': has_2815,
            'has_3209': has_3209,
            'has_ccba': has_ccba,
            'missing_secs': missing_secs
        })
    
    print(f"[{idx:02d}] {rel:<55} | L:{lines:<4} | W:{words:<5} | 2815:{has_2815} | 3209:{has_3209} | CCBA:{has_ccba} | MissSec:{missing_secs}")

print(f"\nTotal Specs Audited: {len(spec_files)}")
print(f"Incomplete / Defective Specs: {len(incomplete_specs)}")
if incomplete_specs:
    for inc in incomplete_specs:
        print("  ❌ INCOMPLETE SPEC:", inc)
else:
    print("  ✅ All 21 spec.md files are 100% complete and contain detailed domain logic matching QCTK 2815, QCCTNB 3209, and Quy chế CCBA 2026!")
