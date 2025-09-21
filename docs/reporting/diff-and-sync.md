# Diff & Sync Deployment Guide

## Modes
- `-Diff`: So sánh schema trong JSON với hiện trạng list (hiện hỗ trợ Choice/MultiChoice so sánh giá trị).
- `-SyncChoices`: Đồng bộ lại tập giá trị Choice/MultiChoice khi thay đổi trong JSON.

## Example Commands
```powershell
# Chỉ xem khác biệt (không thay đổi)
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -Diff

# Vừa update field mới vừa xem diff
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -UpdateExisting -Diff

# Đồng bộ choices sau khi chỉnh JSON
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -SyncChoices
```

## Output Interpretation
- `🔍 DIFF Field 'Stage': +Choices: Renewed` => JSON có thêm Choice mới.
- `♻️ Đã đồng bộ Choices` => Cập nhật thành công.
- `ℹ️ Choices field ... đã khớp` => Không cần thay đổi.

## Limitations / Roadmap
- Chưa diff sâu các thuộc tính như Required thay đổi.
- Chưa xử lý rename field (cần migration tay).
- Roadmap: hỗ trợ diff ManagedMetadata (TermSet mismatch), Lookup target drift.
