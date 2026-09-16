# 🗺️ IDOP-CCBA-WAY — Bản Đồ Định Hướng Kiến Trúc & Phát Triển SharePoint Intranet

> **Hệ thống:** Nền tảng Hoạt động Số Tích hợp IDOP (Integrated Digital Operations Platform)  
> **Tenant Mục Tiêu:** `https://ibstbim.sharepoint.com/sites/idop`  
> **Trạng thái:** `Active / Wayfinding Execution`  
> **Cập nhật:** 2026-08-15 12:05:00 (+07:00)  
> **Đồng bộ từ Hub:** `d:\GitHubProjects\ccba-agent-platform\.md\knowledge\issues\sharepoint-intranet-architecture\map.md`

---

## 1. Điểm Đích (Destination)

Xác lập và triển khai hoàn chỉnh toàn bộ kiến trúc mở rộng (SPFx 1.20+ / Serverless Azure Functions), cấu trúc thông tin (IA & Term Store), mô hình bảo mật phân quyền (Entra ID & Microsoft Purview) và luồng tự động hóa quy trình nghiệp vụ (Power Automate Trình ký đa cấp, Power BI dashboards) cho nền tảng **IDOP-CCBA-WAY** trên SharePoint Online (Microsoft 365), phục vụ toàn diện các phòng ban và dự án BIM của CCBA/IBST.

---

## 2. Ghi Chú & Kỹ Năng Điều Phối (Notes & Skills)

* **Kỹ năng cốt lõi:**
  * [`wayfinder`](file:///d:/GitHubProjects/ccba-agent-platform/.agents/skills/wayfinder/SKILL.md) — Theo dõi tiến độ bản đồ và unblock Frontier Tickets.
  * [`domain-modeling`](file:///d:/GitHubProjects/ccba-agent-platform/.agents/skills/domain-modeling/SKILL.md) — Ghi nhận các thuật ngữ nghiệp vụ vào `INDEX.md` và `cross_references.yaml`.
  * [`ccba-prototype`](file:///d:/GitHubProjects/ccba-agent-platform/.agents/skills/ccba-prototype/SKILL.md) — Dựng mẫu thử giao diện Viva Connections ACEs và SPFx Web Parts.
  * [`to-spec`](file:///d:/GitHubProjects/ccba-agent-platform/.agents/skills/to-spec/SKILL.md) — Cập nhật các module spec tại `specs/modules/`.
* **Tham chiếu kỹ thuật:** [`docs/sharepoint_intranet_technical_research.md`](file:///D:/idop-ccba-way/docs/sharepoint_intranet_technical_research.md) (Báo cáo Nghiên cứu Toàn diện 6 Trụ Cột).

---

## 3. Quyết Định Đã Chốt (Decisions So Far)

* [x] **[Quy chuẩn Flat Topology & Hub Sites IDOP]**: Loại bỏ hoàn toàn Subsites; sử dụng Root Hub (`/sites/idop`) liên kết các Spoke Sites chuyên biệt (BIM Projects, R&D, Tổng hợp, Thiết kế).
* [x] **[Nền tảng Phát triển SPFx 1.20+ Client-side]**: Sử dụng React 18, Fluent UI v9 tokens và PnPjs v4 làm chuẩn lập trình mở rộng Web Parts và Viva Connections ACEs.
* [x] **[Loại trừ Intranet-in-a-box Thương Mại]**: Tự chủ phát triển trên SharePoint Online + Power Platform + SPFx để tối ưu hóa TCO và kiểm soát dữ liệu.

---

## 4. Biên Giới Câu Hỏi & Danh Sách Tickets Mở (Frontier Tickets)

| Mã | Tên Ticket & Hành Động | Loại | Assignee | Trạng thái |
| :---: | :--- | :---: | :---: | :---: |
| **`T01`** | **`[Đặc tả SPFx Components & Serverless Azure Functions Seam]`** | `Research [AFK]` | *Unassigned* | **UNBLOCKED (Sẵn sàng)** |
| **`T02`** | **`[Stress-Test Datamodel Lists, IA & Term Store Taxonomy]`** | `Grilling [HITL]` | *Unassigned* | **UNBLOCKED (Sẵn sàng)** |
| **`T03`** | **`[Stress-Test Quy trình Trình Ký & Microsoft Purview Security]`** | `Grilling [HITL]` | *Unassigned* | **UNBLOCKED (Sẵn sàng)** |
| **`T04`** | **`[Dựng Mẫu Thử Giao Diện Viva Connections Dashboard ACEs]`** | `Prototype [HITL]` | *Unassigned* | **UNBLOCKED (Sẵn sàng)** |

---

### Chi Tiết Các Ticket Tại Biên Giới

#### Ticket T01: `[Research] Đặc tả Kiến trúc SPFx Components & Serverless Azure Functions Seam` [AFK]
* **Mục tiêu:** Thiết kế contract giao tiếp giữa SPFx Client (Web Parts/ACEs) và Serverless Backend (Azure Functions với Managed Identity) để thực thi các tác vụ backend nặng hoặc gọi API an toàn.
* **Đầu ra:** Bản đặc tả kỹ thuật `specs/modules/system_governance/spfx_azure_functions_seam.md`.

#### Ticket T02: `[Grilling] Stress-Test Datamodel Lists, IA & Term Store Taxonomy` [HITL]
* **Mục tiêu:** Rà soát và chuẩn hóa 59 Lists và 21 Taxonomy Term Sets hiện có trong `datamodel/sharepoint/` đối chiếu với cấu trúc điều hành và quản lý dự án BIM của CCBA.
* **Đầu ra:** Bảng sơ đồ IA hoàn chỉnh và báo cáo đối soát schema `datamodel/`.

#### Ticket T03: `[Grilling] Stress-Test Quy trình Trình Ký & Microsoft Purview Security` [HITL]
* **Mục tiêu:** Chốt luồng phê duyệt Trình ký đa cấp (Chủ trì → Trưởng phòng → Pháp lý/QLCL → Ban Giám đốc theo QCTK 2815 & QCCTNB 3209) kết hợp nhãn nhạy cảm Purview Sensitivity Labels và phân quyền Entra ID.
* **Đầu ra:** Đặc tả module `specs/modules/system_governance/approvals/spec.md` cập nhật.

#### Ticket T04: `[Prototype] Dựng Mẫu Thử Giao Diện Viva Connections Dashboard ACEs` [HITL]
* **Mục tiêu:** Dựng file HTML Standalone Prototype mô phỏng thẻ Viva Connections ACE Card "Trình ký & Phê duyệt nhanh IDOP" chạy trên Teams/Mobile có floating theme/role picker.
* **Đầu ra:** Prototype HTML và tài liệu `docs/viva_ace_card_prototype.md`.

---

## 5. Sương Mù Chiến Trận / Chưa Xác Định Rõ (Not Yet Specified)

1. *Cơ chế chỉ mục ngữ nghĩa Semantic Index & SharePoint Custom Copilot Agents cho hồ sơ kỹ thuật BIM/PCCC.* (Phụ thuộc vào Ticket T02).
2. *Chiến lược lưu trữ và nén hồ sơ bản vẽ lớn CDE: SharePoint Online Native vs OneDrive Archive Tier.* (Phụ thuộc vào Ticket T01 & T03).
3. *Tự động hóa CI/CD đóng gói SPFx package và deploy lên Tenant App Catalog qua GitHub Actions / PowerShell PnP.* (Phụ thuộc vào Ticket T01).

---

## 6. Ngoài Phạm Vi (Out of Scope)

* **Intranet-in-a-box thương mại:** Không mua giải pháp đóng gói bên ngoài.
* **Migration On-Premises cũ:** Bắt đầu trực tiếp trên hạ tầng Modern SharePoint Online Cloud của IBST/CCBA.
