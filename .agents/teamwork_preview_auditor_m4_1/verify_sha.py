import os
import hashlib

files = [
    ('.md/governance_constitution/01_qctk_2815_project_management.md', 'qctk_01.12.2025.md'),
    ('.md/governance_constitution/02_qcctnb_3209_financial_norms.md', 'qcctnb_2025.md'),
    ('.md/governance_constitution/03_ccba_charter_2026.md', 'Du thao_QuyCheToChucHoatDong_CCBA_2026_v2.2.md'),
    ('.md/governance_constitution/04_ibst_science_tech_regulations.md', 'quy_che_khcn_ibst_01.12.2025.md'),
    ('.md/system_blueprint/01_idop_v2_architecture.md', 'IDOP_v2.0_F1_Architecture.md'),
    ('.md/system_blueprint/02_idop_v2_operations_finance.md', 'IDOP_v2.0_F2_Operations_Finance.md'),
    ('.md/system_blueprint/03_idop_v2_technical_implementation.md', 'IDOP_v2.0_F3_Technical_Implementation.md'),
    ('.md/system_blueprint/04_idop_v2_enterprise_architecture.md', 'IDOP_v2.0_F4_Enterprise_Architecture.md')
]

print("="*160)
print(f"{'Destination Path (.md)':<65} | {'Original Name':<45} | {'Bytes':<8} | {'Lines':<6} | {'Actual SHA-256'}")
print("="*160)

for fpath, orig_name in files:
    if not os.path.exists(fpath):
        print(f"MISSING: {fpath}")
        continue
    with open(fpath, 'rb') as f:
        data = f.read()
    size = len(data)
    lines = len(data.splitlines())
    sha = hashlib.sha256(data).hexdigest()
    print(f"{fpath:<65} | {orig_name:<45} | {size:<8} | {lines:<6} | {sha}")

print("="*160)
