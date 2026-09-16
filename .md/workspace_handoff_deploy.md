# 🚀 HANDOFF: Lộ trình Triển khai IDOP PROD-First

> **Ngày**: 2026-08-02 | **Môi trường**: `https://ibstbim.sharepoint.com/sites/idop`  
> **Trạng thái**: **Stage 1 Deployment HOÀN THÀNH 100%** → Chuyển giao Stage 2

---

## 1. Trạng thái Hiện tại (Stage 1 Completed)

### ✅ Đã hoàn thành 100% (Stage 1 PROD-First Deployment)
- **59/59 Lists** deployed trên PROD, **399 Fields OK**, 0 lỗi.
- **21/21 Taxonomy Term Sets** đã import đầy đủ vào Tenant Term Store CCBA.
- **Top Navigation Bar** đã đồng bộ 4 nhóm menu (`Intranet Portal`, `CRM`, `Projects & CDE`, `People & Assets`).
- **PnP Baseline Snapshot** đã lưu tại `backups/idop-prod-baseline-20260802-1836.xml`.
- **Phân bổ 3 cấp vai trò kỹ thuật** theo QCTK 2815 Điều 3.2:
  - `ContractLeadUser` → JobAssignments (Chủ trì HĐ, Điều 3.2a)
  - `ScopeChiefUser` → ContractScopes (Chủ nhiệm theo hoạt động XD, Điều 3.2b)
  - `AssignedTechnicalChiefUser` → AssignmentDetails (Chủ trì bộ môn, Điều 3.2c)
- **Auth**: AppOnly Certificate `CN=IDOP-SPO-Deploy` (Client App ID: `c055c7a4-9150-4bd5-bf01-445c65467feb`).

---

## 2. Tiến Độ Lộ Trình 7 Bước

| # | Bước | Lệnh | Trạng thái | Ghi chú |
|:---:|:---|:---|:---:|:---|
| 1 | DryRun kiểm tra | `.\idop.ps1 deploy lists -Environment IDOP -DryRun` | ✅ **DONE** | 59 Lists schemas valid |
| 2 | Import Taxonomy | `.\idop.ps1 taxonomy import -Environment IDOP` | ✅ **DONE** | 21 Term Sets imported |
| 3 | Deploy 59 Lists | `.\idop.ps1 deploy lists -Environment IDOP -Full` | ✅ **DONE** | 59 Lists, 399 Fields OK (15.96 min) |
| 4 | Deploy Navigation | `.\idop.ps1 deploy navigation -Environment IDOP` | ✅ **DONE** | Top Nav synced 4 groups |
| 5 | PnP Snapshot | PnP Baseline Template Export | ✅ **DONE** | Backup at `backups/idop-prod-baseline-*.xml` |
| 6 | Bidding Folders | `.\idop.ps1 deploy folders -Environment IDOP` | ⏳ **NEXT** | Cấu trúc 5TB OneDrive `ccba@ibst-bim.vn` |
| 7 | Power Automate & Soft-Launch | Cloud flows cho Rollup & Soft-Launch | ⏳ **PENDING** | Thí điểm Core Users |

---

## 3. Ràng buộc Kỹ thuật Quan trọng

- **CLI Wrapper**: `idop.ps1` yêu cầu PowerShell 7 (`pwsh`).
- **Cờ `-Environment IDOP`**: Bắt buộc cho mọi lệnh CLI để chỉ định đúng site PROD `https://ibstbim.sharepoint.com/sites/idop`.
- **Auth Mode**: AppOnly Certificate dùng `idop_deploy.pfx` từ `.env`.

---

## 4. Files Chính Tra Cứu

```
1. .md/workspace_context.yaml           → Context bootstrap & milestone
2. AGENTS.md                            → 15 ROLE_ID + 5 Non-Negotiables
3. .md/system_blueprint/03_*.md         → Blueprint + PROD-first Roadmap
4. datamodel/sharepoint/lists/          → 59 JSON Schemas
5. idop.ps1                             → CLI entry point
```
