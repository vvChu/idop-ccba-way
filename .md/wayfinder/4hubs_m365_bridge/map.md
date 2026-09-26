# 🗺️ Wayfinder Map: 4-Hubs × M365 Bridge — Python Tooling & Integration

> **Mã bản đồ**: `WAYFINDER-4HUB-M365-BRIDGE-20260926`  
> **Ngày khởi lập**: 2026-09-26T15:16:00+07:00  
> **Cập nhật cuối**: 2026-09-26T15:22:00+07:00  
> **Nhãn GitHub**: `wayfinder:map`  
> **Nguồn gốc**: Phân tích từ [`hub_spoke_architecture_deep_research.md`](file:///home/vvc/.gemini/antigravity/brain/438a4db4-a819-4cb8-bb8e-ebe31d399642/hub_spoke_architecture_deep_research.md) (2026-09-25) và Thẩm định Adversarial (2026-09-26)

---

## 🎯 Điểm Đích (Destination)

Hoàn thiện **bộ công cụ Python chuẩn mực** cho repo `IDOP-CCBA-WAY` để:

1. Kiểm tra tính hợp lệ của 59 SharePoint List Schemas và 21 Taxonomy Term Sets bằng Python thuần (không phụ thuộc Node.js / PowerShell).
2. Cầu nối đồng bộ 2 chiều giữa DGX Spark AI Hub và Microsoft 365 SharePoint Online qua Graph Delta Queries (Zero Inbound Ingress).
3. Phát hiện sai lệch schema (Forward + Reverse Drift) giữa Git và tenant Production live.
4. Cưỡng chế quy trình QA/QC 5 cấp cho tài liệu CDE theo ISO 19650-2 và Điều 10 QCTK 2815.
5. Hỗ trợ AI thẩm định HSMT qua RAG Service DGX Spark kết nối Milvus `legal_docs_v11`.

**Bản đồ hoàn thành khi**: Lộ trình đến đích đã rõ ràng — mọi quyết định kiến trúc, phân quyền, xác thực và tích hợp đều đã được chốt, sẵn sàng bàn giao cho các phiên `/ccba-implement` hoặc `/boost` thực thi.

---

## 📝 Ghi Chú (Notes)

- **Mô hình vận hành**: Kết hợp Planning + Execution. Các ticket Frontier (unblocked) có thể chuyển thẳng sang `/ccba-new-feature #<id>` để thực thi ngay.
- **Kiến trúc Dual-Track Tooling (KISS)**:
  - *Track 1 (PowerShell / PnP)*: Chuyên trách Provisioning, DDL, Term Store Taxonomy & Admin Maintenance.
  - *Track 2 (Python / Graph API)*: Chuyên trách Runtime Data Sync, Validation, DML, AI Bridge Worker & Integration.
- **Skills bổ trợ**: `/ccba-new-feature`, `/ccba-implement`, `/boost`, `/ccba-grilling`
- **Tài liệu nghiên cứu gốc**: `hub_spoke_architecture_deep_research.md` (859 dòng, 80KB)

---

## ✅ Quyết Định Đã Chốt (Decisions so far)

1. **[Kiến trúc 4-Hubs × Federated Spokes](file:///home/vvc/.gemini/antigravity/brain/438a4db4-a819-4cb8-bb8e-ebe31d399642/hub_spoke_architecture_deep_research.md#L25)**: Phân tầng rõ ràng DGX Spark (Compute Hub) / ccba-agent-platform (Governance Hub) / ccba-legal-knowledge (Data Hub) / VvC_Notes (Synthesis Hub). Điểm ưu tiên 8.33/10 — đã chọn là LỰA CHỌN TỐI ƯU.
2. **[Outbound Polling > Webhook](file:///home/vvc/.gemini/antigravity/brain/438a4db4-a819-4cb8-bb8e-ebe31d399642/hub_spoke_architecture_deep_research.md#L652)**: Graph Delta Queries là SSOT bắt buộc. Webhook chỉ là tín hiệu đánh thức (Wake-up Interrupt), không mang dữ liệu nghiệp vụ. Zero Inbound Attack Surface.
3. **[Bỏ PowerShell Drift → Python Graph API](file:///home/vvc/ccba/IDOP-CCBA-WAY/tools/scripts/validation/sp-diff.ps1)**: Script `sp-diff.ps1` bị 3 lỗi nghiêm trọng (đường dẫn chết, khóa tham số, 1 chiều). Thay thế hoàn toàn bằng Python dùng Graph API `$batch`.
4. **[SharePoint không hỗ trợ Regex](file:///home/vvc/ccba/IDOP-CCBA-WAY/specs/modules/process_execution/cde_documents/spec.md)**: Column Validation Formula chỉ là cú pháp Excel. Validate tên ISO 19650 phải thực hiện ở Bridge Worker (Async).
5. **[ROLE_DIRECTOR chỉ Read-only CDE](file:///home/vvc/ccba/IDOP-CCBA-WAY/specs/modules/process_execution/cde_documents/spec.md#L28-L36)**: Giám đốc xem tổng thể, không duyệt từng file. Cấp duyệt cao nhất `A1` thuộc `ROLE_LEGAL_QA`.
6. **[InfluenceScore là công thức tất định](file:///home/vvc/ccba/IDOP-CCBA-WAY/specs/modules/strategy_crm/opportunities/flows.md)**: Không dùng LLM. AI chỉ hỗ trợ thẩm định nội dung HSMT.
7. **[Submissions.json thiếu CDEDocument](file:///home/vvc/ccba/IDOP-CCBA-WAY/datamodel/sharepoint/lists/system_governance/submissions.json#L8-L9)**: Trường `RelatedEntity` chỉ có 4 giá trị. Cần bổ sung `"CDEDocument"`.
8. **[Biến môi trường xác thực chuẩn hóa](file:///home/vvc/ccba/IDOP-CCBA-WAY/tools/scripts/modules/PnPHelpers.psm1#L89-L94)**: `IDOP_SP_CERT_PATH`, `IDOP_SP_CERT_PASSWORD`, `IDOP_SP_CLIENT_ID`, `IDOP_SP_TENANT_ID`.
9. **[Issue #7 Hoàn thành](https://github.com/vvChu/idop-ccba-way/issues/7)**: Đã hoàn thiện `schema_validator.py` và generator `models.py` (726 dòng) hỗ trợ Pydantic v2 type-safe, bổ sung `"CDEDocument"` vào `submissions.json`. Vượt qua 100% tests và khóa kiểm định tất định ADR-0058 (`verify-patch`).
10. **[Issue #8 Hoàn thành](https://github.com/vvChu/idop-ccba-way/issues/8)**: Đã hoàn thiện `tools/auth/graph_auth.py` và `scripts/check_graph_auth.py` hỗ trợ nạp chứng chỉ PKCS#12 (.pfx) an toàn, quản lý client credential caching qua MSAL, và kiểm tra quyền hạn Microsoft Graph API (`Sites.FullControl.All`, `Files.ReadWrite.All`).
11. **[Issue #9 Hoàn thành](https://github.com/vvChu/idop-ccba-way/issues/9)**: Đã hoàn thiện `tools/bridge/m365_bridge_worker.py` và `tests/test_m365_bridge.py` (28 unit tests, 100% pass), tích hợp Graph Delta Queries, 3-tier LoopBreaker, TokenBucketRateLimiter (5 req/s), DeadLetterQueue SQLite tại `tools/output/state/m365_bridge.db`, Pydantic v2 validation guard, và OutboundSyncEngine OCC. Vượt qua 100% tests và khóa kiểm định tất định ADR-0058.

---

## 🎫 Danh Sách Tickets (Frontier & Blocked)

### 🟢 Frontier — Unblocked (Có thể thực thi ngay)

| Ticket | GitHub Issue | Loại | Chế độ | Ưu tiên | Trạng thái |
|:---|:---|:---:|:---:|:---:|:---:|
| [Live Schema Drift Detector](https://github.com/vvChu/idop-ccba-way/issues/10) | `#10` | Feature | AFK | P1 | 🟢 Open (Unblocked by #8) |
| [CDE ISO 19650 Gatekeeper](https://github.com/vvChu/idop-ccba-way/issues/11) | `#11` | Feature | HITL | P1 | 🟢 Open (Unblocked by #9) |
| [Bidding HSMT Compliance AI](https://github.com/vvChu/idop-ccba-way/issues/12) | `#12` | Feature | AFK | P2 | 🟢 Open (Unblocked by #9) |

### 🟣 Resolved — Đã Hoàn Thành

| Ticket | GitHub Issue | Loại | Chế độ | Ưu tiên | Trạng thái |
|:---|:---|:---:|:---:|:---:|:---:|
| [Python Typed Models & Schema Validator](https://github.com/vvChu/idop-ccba-way/issues/7) | `#7` | Feature | AFK | P0 | 🟣 Closed (Resolved) |
| [App-Only Certificate & Graph Permissions](https://github.com/vvChu/idop-ccba-way/issues/8) | `#8` | Task | HITL | P0 | 🟣 Closed (Resolved) |
| [M365 Outbound Bridge Worker](https://github.com/vvChu/idop-ccba-way/issues/9) | `#9` | Feature | AFK | P0 | 🟣 Closed (Resolved) |

### 🔴 Blocked — Chờ phụ thuộc

*Hiện không còn ticket nào bị chặn phụ thuộc!*

### Sơ đồ phụ thuộc (Dependency Graph)

```
                  ┌───────────────────────────────┐       ┌───────────────────────────────┐
                  │  #7 Schema Validator & Models │       │  #8 App-Only Cert & Graph     │
                  │  [🟣 RESOLVED / CLOSED]       │       │  [🟣 RESOLVED / CLOSED]       │
                  └──────────────┬────────────────┘       └──────────────┬────────────────┘
                                 │                                       │
              ┌──────────────────┴───────────────────────────────────────┤
              │                                                          │
              ▼                                                          ▼
    ┌────────────────────┐                                     ┌────────────────────┐
    │  #9 Bridge Worker  │                                     │  #10 Drift Detector│
    │  [🟣 RESOLVED]     │                                     │  [🟢 UNBLOCKED P1] │
    └─────────┬──────────┘                                     └────────────────────┘
              │
              ├────────────────────────────┐
              │                            │
              ▼                            ▼
    ┌────────────────────┐       ┌────────────────────┐
    │ #11 CDE Gatekeeper │       │ #12 Bidding HSMT   │
    │ [🟢 UNBLOCKED P1]  │       │ [🟢 UNBLOCKED P2]  │
    └────────────────────┘       └────────────────────┘
```

---

## 🌫️ Chưa Xác Định Rõ (Not yet specified — Fog of War)

1. **Bảng ánh xạ Taxonomy ↔ mã ISO 19650**: Cần chốt bảng ánh xạ chính thức giữa `CCBA_LoaiTaiLieu.json` (tiếng Việt) với mã 2 ký tự ISO 19650 (`DR`, `RP`, `MO`...). Sẽ giải quyết trong ticket `#11` qua `/ccba-grilling`.
2. **Cấu trúc mẫu báo cáo thẩm định HSMT**: Cần thống nhất template prompt cho RAG Service (:8005) khi quét HSMT. Sẽ giải quyết trong ticket `#12`.
3. **Môi trường Live M365 Production**: Chạy kiểm thử kết nối trực tiếp với tenant SharePoint thật khi có file chứng chỉ `.pfx` và `.env` trên DGX Spark.

---

## 🚫 Ngoài Phạm Vi (Out of Scope)

1. **Viết lại toàn bộ PowerShell bằng Python**: Track 1 (PowerShell / PnP) vẫn giữ cho Provisioning, DDL, Term Store Taxonomy. Chỉ thay thế các script bị lỗi hoặc không chạy được trên Linux.
2. **Triển khai Webhook Ingress công khai**: Đã loại bỏ. Nếu có Webhook qua Cloudflare Tunnel, chỉ là tín hiệu đánh thức (Wake-up Interrupt).
3. **Dùng LLM thay thế các chỉ số CRM tất định** (`InfluenceScore`, `RiskFlags`): Đã chốt là KHÔNG.
4. **Tạo trường mới trên schema `opportunities.json`** cho AI output: Đã chốt là CẤM. Dùng trường có sẵn (`DecisionNote`, `DecisionEmailLink`) hoặc lưu file trên OneDrive.
5. **Quản lý quy trình phía Viện IBST** (phê duyệt KHKT, giải ngân TCKT): Ngoài ranh giới IDOP (Non-Negotiable 1).

---

*Bản đồ được lập bởi Antigravity Agent — Phiên `/ccba-wayfinder` ngày 2026-09-26.*
