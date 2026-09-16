import os
import re
import sys
from pathlib import Path

# Force stdout to utf-8
sys.stdout.reconfigure(encoding='utf-8')

modules_dir = Path(r"d:\idop-ccba-way\specs\modules")
spec_files = sorted(list(modules_dir.glob("**/spec.md")))

terms = ["QCTK 2815", "QCCTNB 3209", "CCBA Charter", "IBST", "IDOP v2"]

# Also search individual component terms and variations
variations = {
    "QCTK 2815": [r"QCTK\s*2815", r"2815/QĐ-VKH", r"QCTK", r"2815"],
    "QCCTNB 3209": [r"QCCTNB\s*3209", r"3209/QĐ-VKH", r"QCCTNB", r"3209"],
    "CCBA Charter": [r"CCBA\s+Charter", r"Quy\s+chế\s+CCBA", r"Quy\s+chế.*CCBA", r"Charter"],
    "IBST": [r"\bIBST\b", r"Viện\s+KHCN\s+Xây\s+dựng", r"\bVKH\b"],
    "IDOP v2": [r"IDOP\s*v?2(?:\.0)?", r"IDOP\s*v2", r"IDOP"]
}

out_lines = []
out_lines.append(f"Total spec.md files found: {len(spec_files)}")
out_lines.append("=" * 60)

# Exact match results
exact_summary = {t: 0 for t in terms}
exact_file_matches = {t: [] for t in terms}

file_details = []

for f in spec_files:
    rel_path = f.relative_to(modules_dir).as_posix()
    content = f.read_text(encoding="utf-8")
    
    file_exact_counts = {}
    file_var_counts = {}
    
    for term in terms:
        # Case insensitive exact string match count
        exact_matches = len(re.findall(re.escape(term), content, re.IGNORECASE))
        if exact_matches > 0:
            file_exact_counts[term] = exact_matches
            exact_summary[term] += exact_matches
            exact_file_matches[term].append((rel_path, exact_matches))
            
        # Variation counts
        file_var_counts[term] = {}
        for var_pat in variations[term]:
            v_matches = len(re.findall(var_pat, content, re.IGNORECASE))
            if v_matches > 0:
                file_var_counts[term][var_pat] = v_matches
                
    file_details.append({
        "path": rel_path,
        "exact": file_exact_counts,
        "variations": file_var_counts
    })

out_lines.append("\n--- 1. EXACT PHRASE MATCHES SUMMARY ---")
grand_total_exact = 0
for t in terms:
    cnt = exact_summary[t]
    grand_total_exact += cnt
    out_lines.append(f"\nTerm: '{t}' -> Total Occurrences: {cnt} (in {len(exact_file_matches[t])} files)")
    for fp, count in exact_file_matches[t]:
        out_lines.append(f"  - {fp}: {count}")

out_lines.append(f"\nGrand Total Exact Matches: {grand_total_exact}")

out_lines.append("\n" + "=" * 60)
out_lines.append("\n--- 2. DETAILED VARIATION / ALIAS MATCHES ---")
for t in terms:
    out_lines.append(f"\n=== Target Keyword: '{t}' ===")
    for var_pat in variations[t]:
        total_v = sum(fd["variations"][t].get(var_pat, 0) for fd in file_details)
        matching_files = [fd["path"] for fd in file_details if fd["variations"][t].get(var_pat, 0) > 0]
        out_lines.append(f"  Pattern r'{var_pat}': {total_v} occurrences in {len(matching_files)} files")
        for fd in file_details:
            c = fd["variations"][t].get(var_pat, 0)
            if c > 0:
                out_lines.append(f"    - {fd['path']}: {c}")

out_lines.append("\n" + "=" * 60)
out_lines.append("\n--- 3. PER-FILE MATRIX ---")
header = f"{'File':<45} | " + " | ".join([f"{t:<12}" for t in terms])
out_lines.append(header)
out_lines.append("-" * len(header))
for fd in file_details:
    counts_str = " | ".join([f"{fd['exact'].get(t, 0):<12}" for t in terms])
    out_lines.append(f"{fd['path']:<45} | {counts_str}")

result_text = "\n".join(out_lines)
print(result_text)

# Also save to search_results.txt
out_file = Path(r"d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_1\search_results.txt")
out_file.write_text(result_text, encoding="utf-8")
