# BÁO CÁO PHÂN TÍCH TÀI LIỆU VÀ QUY CHẾ (ANALYSIS REPORT)

**Tác giả**: `teamwork_preview_explorer_m1_1`  
**Ngày thực hiện**: 2026-07-28 (UTC: 2026-07-28T08:45:56Z)  
**Phạm vi**: 
1. Kiểm tra 8 file tài liệu gốc tại `d:\idop-ccba-way\extracted_docs\`
2. Thống kê toàn bộ các file `spec.md` tại `d:\idop-ccba-way\specs\modules\`
3. Phân tích đối chiếu & Đếm số lần tham chiếu đến các văn bản pháp lý/quy chế: `QCTK 2815`, `QCCTNB 3209`, `CCBA Charter`, `IBST`, `IDOP v2`

---

## 1. Kiểm tra và Thống kê Tài liệu Gốc (`extracted_docs`)

Thư mục `d:\idop-ccba-way\extracted_docs\` chứa đúng **8 file Markdown** được trích xuất từ các tài liệu quy chế, kiến trúc hệ thống gốc:

| STT | Tên File Exact (`extracted_docs/`) | Dung lượng (Bytes) | Header / Tiêu đề / Metadata chính |
|-----|-----------------------------------|-------------------|-----------------------------------|
| 1 | `Du thao_QuyCheToChucHoatDong_CCBA_2026_v2.2.md` | 67,778 bytes (67.78 KB) | `# QUY CHẾ TỔ CHỨC VÀ HOẠT ĐỘNG CỦA TRUNG TÂM TƯ VẤN VÀ ỨNG DỤNG BIM TRONG XÂY DỰNG (CCBA)` |
| 2 | `IDOP_v2.0_F1_Architecture.md` | 23,359 bytes (23.36 KB) | `# 📘 FILE 1/4 - KIẾN TRÚC TỔNG QUAN IDOP v2.0`<br>*(Phần I-VIII: Tổng quan & Kiến trúc, CCBA, 27/06/2026)* |
| 3 | `IDOP_v2.0_F2_Operations_Finance.md` | 22,411 bytes (22.41 KB) | `# 📘 FILE 2/4 - VẬN HÀNH VÀ TÀI CHÍNH IDOP v2.0`<br>*(Phần IX-XI: Vận hành & Tài chính, CCBA, 27/06/2026)* |
| 4 | `IDOP_v2.0_F3_Technical_Implementation.md` | 20,364 bytes (20.36 KB) | `# 📘 FILE 3/4 - YÊU CẦU KỸ THUẬT VÀ TRIỂN KHAI IDOP v2.0`<br>*(Phần XII-XIV: Kỹ thuật & Triển khai, CCBA, 27/06/2026)* |
| 5 | `IDOP_v2.0_F4_Enterprise_Architecture.md` | 46,486 bytes (46.49 KB) | `# 📘 FILE 4/4 - ENTERPRISE ARCHITECTURE EXTENSION IDOP v2.0+`<br>*(Định hướng IBST-level & Enterprise, 27/06/2026)* |
| 6 | `qcctnb_2025.md` | 135,746 bytes (135.75 KB) | YAML Frontmatter:<br>`title: "QUY CHẾ CHI TIÊU NỘI BỘ CỦA VIỆN KHCN XÂY DỰNG"`<br>`short_title: "QĐ 3209"`, `decision_number: "3209/QĐ-VKH"`, `issue_date: "2025-12-31"` |
| 7 | `qctk_01.12.2025.md` | 77,302 bytes (77.30 KB) | YAML Frontmatter:<br>`title: "Quy chế thực hiện nhiệm vụ phục vụ QLNN và dịch vụ kỹ thuật - QĐ 2815/QĐ-VKH"`<br>`short_title: "QCTK 01.12.2025"`, `decision_number: "2815/QĐ-VKH"`, `issue_date: "2025-12-01"` |
| 8 | `quy_che_khcn_ibst_01.12.2025.md` | 76,876 bytes (76.88 KB) | YAML Frontmatter:<br>`title: "Quy chế thực hiện nhiệm vụ KH&CN - QĐ 2816/QĐ-VKH"`<br>`short_title: "Quy chế KHCN IBST 01.12.2025"`, `decision_number: "2816/QĐ-VKH"`, `issue_date: "2025-12-01"` |

---

## 2. Thống kê Danh sách 21 File `spec.md` (`specs/modules/`)

Thư mục `d:\idop-ccba-way\specs\modules\` có cấu trúc phân chia thành 6 nhóm module chuyên môn với tổng cộng **21 file `spec.md`**:

### Nhóm 1: `cash_data` (4 file)
1. `cash_data/spec.md` (Module root specification)
2. `cash_data/allocations/spec.md`
3. `cash_data/expenses/spec.md`
4. `cash_data/finance/spec.md`

### Nhóm 2: `people_assets` (2 file)
5. `people_assets/assets/spec.md`
6. `people_assets/hr/spec.md`

### Nhóm 3: `performance_okrs` (2 file)
7. `performance_okrs/performance/spec.md`
8. `performance_okrs/reports/spec.md`

### Nhóm 4: `process_execution` (6 file)
9. `process_execution/cde_documents/spec.md`
10. `process_execution/contracts/spec.md`
11. `process_execution/lessons_learned/spec.md`
12. `process_execution/pmo/spec.md`
13. `process_execution/projects/spec.md`
14. `process_execution/work_packages/spec.md`

### Nhóm 5: `strategy_crm` (4 file)
15. `strategy_crm/crm/spec.md`
16. `strategy_crm/lead_capture/spec.md`
17. `strategy_crm/opportunities/spec.md`
18. `strategy_crm/potential_projects/spec.md`

### Nhóm 6: `system_governance` (3 file)
19. `system_governance/approvals/spec.md`
20. `system_governance/forms/spec.md`
21. `system_governance/governance/spec.md`

---

## 3. Kết quả Regex / Grep Search về các Tham chiếu Quy chế & Chuẩn mực

Tìm kiếm trên 21 file `spec.md` đối với 5 từ khóa/văn bản quy định:

### 3.1. Tổng hợp Số lần Xuất hiện (Exact Phrase vs Semantic/Alias Variants)

| STT | Từ khóa Yêu cầu | Exact Matches (Case-Insensitive) | Số file chứa Exact Match | Semantic / Alias Pattern Matches | Ghi chú & Tương đương trong Tiếng Việt |
|-----|----------------|----------------------------------|--------------------------|----------------------------------|---------------------------------------|
| 1 | `QCTK 2815` | **65** | **21 / 21 files** (100%) | `QCTK`: 134 lần<br>`2815`: 67 lần | Quy chế Triển khai QĐ 2815/QĐ-VKH (01/12/2025). |
| 2 | `QCCTNB 3209` | **38** | **21 / 21 files** (100%) | `QCCTNB`: 40 lần<br>`3209`: 38 lần | Quy chế Chi tiêu Nội bộ QĐ 3209/QĐ-VKH (31/12/2025). |
| 3 | `CCBA Charter` | **0** | **0 / 21 files** | `Quy chế CCBA`: 22 lần (20 files)<br>`Quy chế CCBA 2026`: 20 lần | Tham chiếu qua thuật ngữ tiếng Việt "Quy chế CCBA 2026" (Quy chế Tổ chức & Hoạt động CCBA). |
| 4 | `IBST` | **1** | **1 / 21 files** | `VKH`: 42 lần (21 files)<br>`Viện KHCN Xây dựng`: 7 lần (6 files) | Match exact `IBST_ERP_CONNECTOR` tại `system_governance/governance/spec.md:91`. Tiếng Việt viết tắt là `VKH` hoặc `Viện KHCN Xây dựng`. |
| 5 | `IDOP v2` | **0** | **0 / 21 files** | `IDOP`: 43 lần (20 files) | Trong các module spec, hệ thống dùng từ tắt `IDOP` hoặc `IDOP-CCBA-WAY` thay vì cụm từ "IDOP v2". |

---

### 3.2. Ma trận Chi tiết Số lần Xuất hiện Exact Phrase trong từng File `spec.md`

| STT | Đường dẫn File Spec (`specs/modules/`) | QCTK 2815 | QCCTNB 3209 | CCBA Charter | IBST | IDOP v2 | Tổng Exact / File |
|-----|---------------------------------------|-----------|-------------|--------------|------|---------|-------------------|
| 1 | `cash_data/allocations/spec.md` | 4 | 2 | 0 | 0 | 0 | **6** |
| 2 | `cash_data/expenses/spec.md` | 2 | 5 | 0 | 0 | 0 | **7** |
| 3 | `cash_data/finance/spec.md` | 2 | 1 | 0 | 0 | 0 | **3** |
| 4 | `cash_data/spec.md` | 8 | 3 | 0 | 0 | 0 | **11** |
| 5 | `people_assets/assets/spec.md` | 1 | 1 | 0 | 0 | 0 | **2** |
| 6 | `people_assets/hr/spec.md` | 1 | 2 | 0 | 0 | 0 | **3** |
| 7 | `performance_okrs/performance/spec.md` | 1 | 5 | 0 | 0 | 0 | **6** |
| 8 | `performance_okrs/reports/spec.md` | 1 | 4 | 0 | 0 | 0 | **5** |
| 9 | `process_execution/cde_documents/spec.md` | 2 | 1 | 0 | 0 | 0 | **3** |
| 10 | `process_execution/contracts/spec.md` | 6 | 1 | 0 | 0 | 0 | **7** |
| 11 | `process_execution/lessons_learned/spec.md` | 5 | 1 | 0 | 0 | 0 | **6** |
| 12 | `process_execution/pmo/spec.md` | 9 | 1 | 0 | 0 | 0 | **10** |
| 13 | `process_execution/projects/spec.md` | 7 | 1 | 0 | 0 | 0 | **8** |
| 14 | `process_execution/work_packages/spec.md` | 1 | 1 | 0 | 0 | 0 | **2** |
| 15 | `strategy_crm/crm/spec.md` | 1 | 1 | 0 | 0 | 0 | **2** |
| 16 | `strategy_crm/lead_capture/spec.md` | 1 | 1 | 0 | 0 | 0 | **2** |
| 17 | `strategy_crm/opportunities/spec.md` | 4 | 1 | 0 | 0 | 0 | **5** |
| 18 | `strategy_crm/potential_projects/spec.md` | 1 | 1 | 0 | 0 | 0 | **2** |
| 19 | `system_governance/approvals/spec.md` | 5 | 2 | 0 | 0 | 0 | **7** |
| 20 | `system_governance/forms/spec.md` | 2 | 2 | 0 | 0 | 0 | **4** |
| 21 | `system_governance/governance/spec.md` | 1 | 1 | 0 | 1 | 0 | **3** |
| **TỔNG** | **21 File Spec** | **65** | **38** | **0** | **1** | **0** | **104** |

---

## 4. Nhận xét Phân tích Kiến trúc & Tính Tuân thủ (Insights)

1. **Tuân thủ Quy chế Pháp lý (QCTK 2815 & QCCTNB 3209)**:
   - **100% (21/21) các file `spec.md`** đều viện dẫn trực tiếp cả hai văn bản quy chế cốt lõi `QCTK 2815` và `QCCTNB 3209` trong mục *3. Cơ sở Pháp lý & Quy chế Áp dụng*.
   - Mật độ viện dẫn cao nhất nằm ở các module nghiệp vụ cốt lõi: `process_execution/pmo` (10 lần), `cash_data/spec.md` (11 lần), `process_execution/projects` (8 lần), `process_execution/contracts` (7 lần).

2. **Sử dụng Thuật ngữ Tiếng Việt cho CCBA Charter và IBST**:
   - Thuật ngữ **CCBA Charter** trong bản yêu cầu gốc tương ứng chính xác với **"Quy chế CCBA 2026"** (Dự thảo Quy chế Tổ chức và Hoạt động của CCBA v2.2), được dẫn chiếu 22 lần tại 20 file spec.
   - Viện KHCN Xây dựng (**IBST**) trong các văn bản quy chế tiếng Việt được viết tắt là **"VKH"** (như trong các số quyết định `2815/QĐ-VKH`, `3209/QĐ-VKH`, `2816/QĐ-VKH`) với 42 lần xuất hiện và 7 lần viết rõ "Viện KHCN Xây dựng". Ký tự exact `IBST` xuất hiện 1 lần dưới dạng mã kết nối API `IBST_ERP_CONNECTOR`.

3. **Thuật ngữ IDOP**:
   - Khung kiến trúc tổng thể được gọi tắt là **`IDOP`** (43 lần xuất hiện) hoặc `IDOP-CCBA-WAY`, trùng khớp về bản chất với tài liệu thiết kế hệ thống **IDOP v2.0** (4 file F1-F4 trong `extracted_docs`).
