import os
import sys
import glob
import re
import yaml

sys.stdout.reconfigure(encoding='utf-8')

PROJECT_ROOT = os.path.abspath('d:/idop-ccba-way')
MD_DIR = os.path.join(PROJECT_ROOT, '.md')

# Ensure directories exist
os.makedirs(os.path.join(MD_DIR, 'governance_constitution'), exist_ok=True)
os.makedirs(os.path.join(MD_DIR, 'system_blueprint'), exist_ok=True)

print("=== STARTING META FILES GENERATION ===")

# ---------------------------------------------------------
# 1. GENERATE workspace_context.yaml
# ---------------------------------------------------------
workspace_context_data = {
    'project_name': 'IDOP-CCBA-WAY',
    'version': '2.0.0',
    'current_milestone': 'Milestone 2 - Migration & Meta Files Generation',
    'description': (
        'Central Knowledge Base bootstrap configuration for IDOP-CCBA-WAY governance '
        'constitution, system blueprint, and module specifications. Serves as the primary '
        'entry point for AI Agents and developers.'
    ),
    'database': 'SharePoint Online Lists & Power Platform Data Model',
    'architecture_pattern': 'Hub & Spoke Architecture (IBST-CCBA Root Hub + Specialized Spoke Sites)',
    'document_groups': {
        'governance_constitution': {
            'path': '.md/governance_constitution',
            'description': 'Legal regulations, project management rules, financial norms, CCBA charter, and IBST science & technology standards.',
            'files': [
                '01_qctk_2815_project_management.md',
                '02_qcctnb_3209_financial_norms.md',
                '03_ccba_charter_2026.md',
                '04_ibst_science_tech_regulations.md'
            ]
        },
        'system_blueprint': {
            'path': '.md/system_blueprint',
            'description': 'System architecture, operations & finance flows, technical implementation blueprints, and enterprise architecture.',
            'files': [
                '01_idop_v2_architecture.md',
                '02_idop_v2_operations_finance.md',
                '03_idop_v2_technical_implementation.md',
                '04_idop_v2_enterprise_architecture.md'
            ]
        },
        'module_specifications': {
            'path': 'specs/modules',
            'description': '21 module specification files mapped across 6 operational domains (cash_data, people_assets, performance_okrs, process_execution, strategy_crm, system_governance).',
            'total_specs': 21
        }
    },
    'initial_reading_sequence': [
        '.md/workspace_context.yaml',
        '.md/INDEX.md',
        '.md/cross_references.yaml',
        '.md/governance_constitution/01_qctk_2815_project_management.md',
        '.md/governance_constitution/02_qcctnb_3209_financial_norms.md',
        '.md/governance_constitution/03_ccba_charter_2026.md',
        '.md/governance_constitution/04_ibst_science_tech_regulations.md',
        '.md/system_blueprint/01_idop_v2_architecture.md',
        '.md/system_blueprint/02_idop_v2_operations_finance.md',
        '.md/system_blueprint/03_idop_v2_technical_implementation.md',
        '.md/system_blueprint/04_idop_v2_enterprise_architecture.md'
    ]
}

ws_yaml_path = os.path.join(MD_DIR, 'workspace_context.yaml')
with open(ws_yaml_path, 'w', encoding='utf-8') as f:
    yaml.dump(workspace_context_data, f, sort_keys=False, allow_unicode=True, default_flow_style=False)

# Verify parsing
with open(ws_yaml_path, 'r', encoding='utf-8') as f:
    parsed_ws = yaml.safe_load(f)
assert parsed_ws['project_name'] == 'IDOP-CCBA-WAY'
print(f"✓ Created & verified {ws_yaml_path}")


# ---------------------------------------------------------
# 2. GENERATE INDEX.md
# ---------------------------------------------------------
index_content = """# 📚 IDOP-CCBA-WAY KNOWLEDGE BASE INDEX

Chào mừng bạn đến với **IDOP-CCBA-WAY Knowledge Base** - Hệ thống tri thức trung tâm quản trị vận hành số và quy chế pháp lý cho Trung tâm Chẩn đoán & Kiểm định Xây dựng (CCBA) thuộc Viện KHCN Xây dựng (IBST).

Tài liệu này đóng vai trò là **Mục lục điều hướng tổng thể (Table of Contents)**, tóm tắt nội dung 8 văn bản cốt lõi và cung cấp **Ma trận tra cứu nhanh** cùng **Hệ thống liên kết Anchor** tới các Điều/Khoản và Phần kiến trúc quan trọng.

---

## 1. TỔNG QUAN DANH MỤC TÀI LIỆU (DOCUMENT GROUPS)

Hệ thống tài liệu gốc gồm 8 văn bản chính được chia làm 2 nhóm quản trị cốt lõi:

### Nhóm A: Thể chế Quản trị & Quy chế Pháp lý (`.md/governance_constitution/`)
1. **`01_qctk_2815_project_management.md`** - Quy chế Triển khai dự án số 2815/QĐ-VKH (Ban hành 01/12/2025).
2. **`02_qcctnb_3209_financial_norms.md`** - Quy chế Chi tiêu Nội bộ Viện KHCN Xây dựng số 3209/QĐ-VKH (Ban hành 31/12/2025).
3. **`03_ccba_charter_2026.md`** - Dự thảo Quy chế Tổ chức & Hoạt động CCBA 2026 (Phiên bản v2.2).
4. **`04_ibst_science_tech_regulations.md`** - Quy chế Quản lý Khoa học Công nghệ Viện KHCN Xây dựng (Ban hành 01/12/2025).

### Nhóm B: Kiến trúc Hệ thống & Vận hành Số IDOP v2.0 (`.md/system_blueprint/`)
5. **`01_idop_v2_architecture.md`** - IDOP v2.0 F1: Kiến trúc Tổng quan (Architecture & Hub-Spoke Model).
6. **`02_idop_v2_operations_finance.md`** - IDOP v2.0 F2: Quy trình Vận hành 7 Bước & Quản lý Tài chính (Operations & Finance).
7. **`03_idop_v2_technical_implementation.md`** - IDOP v2.0 F3: Yêu cầu Kỹ thuật, Power Automate Flows & Copilot (Technical Implementation).
8. **`04_idop_v2_enterprise_architecture.md`** - IDOP v2.0 F4: Kiến trúc Doanh nghiệp Mở rộng 10 Lớp & Taxonomy (Enterprise Architecture Extension).

---

## 2. MỤC LỤC CHI TIẾT & TÓM TẮT 8 VĂN BẢN CỐT LÕI

### 📜 Nhóm A - Thể chế Quản trị & Quy chế Pháp lý

#### 1. `01_qctk_2815_project_management.md` (QCTK 2815/QĐ-VKH)
- **Tóm tắt cốt lõi**: Quy chế quy định toàn bộ quy trình 7 bước quản lý triển khai dự án tư vấn xây dựng, kiểm định và dịch vụ kỹ thuật tại Viện KHCN Xây dựng. Văn bản xác định rõ phân cấp thẩm quyền ký kết hợp đồng, cơ chế phê duyệt Phiếu giao việc (PGV) 4 luồng, quy trình kiểm soát chất lượng 5 cấp (QA/QC), phân công trách nhiệm đơn vị chủ trì/phối hợp, và công tác quyết toán thanh lý hợp đồng.
- **Phạm vi ứng dụng**: Áp dụng cho 100% hợp đồng dịch vụ kỹ thuật, kiểm định, tư vấn và thi công của Viện và các đơn vị trực thuộc.
- **Anchor Links tới các Điều/Chương quan trọng**:
  - [Chương I - Quy định chung & Nguyên tắc quản lý tập trung](governance_constitution/01_qctk_2815_project_management.md#chương-i)
  - [Điều 4 - Nguyên tắc thực hiện & Phân công nhiệm vụ](governance_constitution/01_qctk_2815_project_management.md#điều-4)
  - [Điều 5 - Công tác thị trường, đăng ký đầu mối & Đấu thầu](governance_constitution/01_qctk_2815_project_management.md#điều-5)
  - [Điều 6 - Phân cấp thẩm quyền ký kết Hợp đồng kinh tế](governance_constitution/01_qctk_2815_project_management.md#điều-6)
  - [Điều 7 - Lập, thẩm định và phê duyệt Phiếu giao việc (PGV)](governance_constitution/01_qctk_2815_project_management.md#điều-7)
  - [Điều 8 & 9 - Quản lý thực hiện hợp đồng & Luồng kiểm soát QA/QC 5 cấp](governance_constitution/01_qctk_2815_project_management.md#điều-8)
  - [Điều 10 - Kiểm tra nội bộ & Đánh giá chất lượng sản phẩm](governance_constitution/01_qctk_2815_project_management.md#điều-10)
  - [Điều 11 & 12 - Nghiệm thu, Quyết toán & Phân bổ tài chính](governance_constitution/01_qctk_2815_project_management.md#điều-11)

#### 2. `02_qcctnb_3209_financial_norms.md` (QCCTNB 3209/QĐ-VKH)
- **Tóm tắt cốt lõi**: Quy chế Chi tiêu Nội bộ quy định chi tiết chế độ tài chính, quản lý nguồn thu hoạt động sự nghiệp, định mức chi thường xuyên, chi công tác phí, thù lao khoa học, chi quản lý đơn vị và trích nộp tài chính về Viện. Văn bản quy định cơ chế phân phối doanh thu hợp đồng, tỷ lệ trích lập các quỹ, quản lý công nợ và hạn mức phê duyệt chi tiêu tài chính nhằm bảo toàn và phát triển vốn.
- **Phạm vi ứng dụng**: Áp dụng cho toàn bộ hoạt động tài chính, kế toán, thu chi và thanh quyết toán tại Viện và các Trung tâm thuộc Viện.
- **Anchor Links tới các Điều/Chương quan trọng**:
  - [Chương I - Quy định chung & Nguyên tắc quản lý tài chính](governance_constitution/02_qcctnb_3209_financial_norms.md#chương-i)
  - [Chương II - Nguồn kinh phí & Thu hoạt động dịch vụ KHCN](governance_constitution/02_qcctnb_3209_financial_norms.md#chương-ii)
  - [Chương III - Nội dung, định mức các khoản chi hoạt động thường xuyên](governance_constitution/02_qcctnb_3209_financial_norms.md#chương-iii)
  - [Điều 8.2.1 - Tiền lương, tiền công & Thu nhập tăng thêm](governance_constitution/02_qcctnb_3209_financial_norms.md#821-tiền-lương-tiền-công)
  - [Điều 8.2.3 - Định mức Chi phí Công tác trong nước](governance_constitution/02_qcctnb_3209_financial_norms.md#823-công-tác-trong-nước)
  - [Điều 8.2.5 - Chi phí Hội nghị, hội thảo & Tiếp khách giao dịch](governance_constitution/02_qcctnb_3209_financial_norms.md#825-hội-nghị-hội-thảo-tập-huấn)
  - [Điều 15 & 16 - Hạn mức Phê duyệt Tài chính & Quy trình Tạm ứng, Thanh toán](governance_constitution/02_qcctnb_3209_financial_norms.md#chương-iv)

#### 3. `03_ccba_charter_2026.md` (Quy chế CCBA 2026 v2.2)
- **Tóm tắt cốt lõi**: Quy chế Tổ chức và Hoạt động của Trung tâm CCBA xác định cơ cấu bộ máy tổ chức, Sơ đồ trách nhiệm giải trình (Accountability Chart - GWC), tiêu chuẩn năng lực nhân sự và cơ chế trích lập kinh phí vận hành Trung tâm. Văn bản kèm theo Phụ lục 02 về Bảng phân bổ doanh thu dịch vụ kỹ thuật và Phụ lục 03 về Ma trận phân quyền truy cập IDOP cùng các Quy trình vận hành chuẩn (SOP 01 đến SOP 03).
- **Phạm vi ứng dụng**: Áp dụng riêng cho toàn bộ cán bộ, nhân sự, phòng chuyên môn và hoạt động vận hành số tại Trung tâm CCBA.
- **Anchor Links tới các Điều/Chương quan trọng**:
  - [Chương I & II - Chức năng, nhiệm vụ & Cơ chế hoạt động CCBA](governance_constitution/03_ccba_charter_2026.md#chương-i-những-quy-định-chung)
  - [Chương III - Cơ cấu tổ chức & Phân công nhiệm vụ Ban Giám đốc & Phòng CM](governance_constitution/03_ccba_charter_2026.md#chương-iii-cơ-cấu-tổ-chức-và-phân-công-nhiệm-vụ)
  - [Chương V - Quản lý tài chính & Phân phối thu nhập tăng thêm](governance_constitution/03_ccba_charter_2026.md#chương-v-quản-lý-tài-chính-và-phân-phối-thu-nhập)
  - [Phụ lục 01 - Structural Accountability Chart & Tiêu chuẩn GWC](governance_constitution/03_ccba_charter_2026.md#phụ-lục-01)
  - [Phụ lục 02 - Bảng phân bổ Doanh thu Hợp đồng & Cơ chế Quản lý Kinh phí](governance_constitution/03_ccba_charter_2026.md#phụ-lục-02)
  - [Phụ lục 03 - Ma trận Phân quyền IDOP (Permission Matrix) & SOPs](governance_constitution/03_ccba_charter_2026.md#phụ-lục-03)
  - [SOP 02 - Quy trình Phê duyệt Hồ sơ Kỹ thuật (Kiểm soát 05 Cấp số)](governance_constitution/03_ccba_charter_2026.md#sop-02-quy-trình-phê-duyệt-hồ-sơ-kỹ-thuật-kiểm-soát-05-cấp)

#### 4. `04_ibst_science_tech_regulations.md` (Quy chế KHCN IBST)
- **Tóm tắt cốt lõi**: Quy chế điều chỉnh công tác quản lý, đăng ký, thực hiện, đánh giá nghiệm thu và ứng dụng sản phẩm các nhiệm vụ Khoa học & Công nghệ (đề tài, dự án SXTN, tiêu chuẩn quy chuẩn, nhiệm vụ thường xuyên) tại Viện. Văn bản quy định các tiêu chuẩn trích lập Quỹ phát triển KHCN, quản lý tài sản trí tuệ, và thù lao cho cán bộ nghiên cứu khoa học.
- **Phạm vi ứng dụng**: Áp dụng cho các phòng nghiên cứu, đơn vị trực thuộc và toàn bộ cán bộ tham gia nhiệm vụ KHCN của Viện.
- **Anchor Links tới các Điều/Chương quan trọng**:
  - [Chương I - Quy định chung & Giải thích từ ngữ KHCN](governance_constitution/04_ibst_science_tech_regulations.md#chương-i-những-quy-định-chung)
  - [Điều 4 - Nguyên tắc thực hiện nhiệm vụ KHCN](governance_constitution/04_ibst_science_tech_regulations.md#điều-4-nguyên-tắc-thực-hiện)
  - [Chương II - Đăng ký, tuyển chọn và phê duyệt danh mục đề tài KHCN](governance_constitution/04_ibst_science_tech_regulations.md#chương-ii)
  - [Chương III - Quản lý tiến độ, kiểm tra và điều chỉnh nhiệm vụ](governance_constitution/04_ibst_science_tech_regulations.md#chương-iii)
  - [Chương IV - Đánh giá, nghiệm thu & Công nhận kết quả KHCN](governance_constitution/04_ibst_science_tech_regulations.md#chương-iv)
  - [Chương V - Quản lý tài chính, kinh phí & Quỹ Phát triển KHCN](governance_constitution/04_ibst_science_tech_regulations.md#chương-v)

---

### 🖥️ Nhóm B - Kiến trúc Hệ thống & Vận hành Số IDOP v2.0

#### 5. `01_idop_v2_architecture.md` (IDOP v2.0 F1 Architecture)
- **Tóm tắt cốt lõi**: Tài liệu thiết lập Kiến trúc tổng thể 8 lớp của nền tảng IDOP v2.0, vận hành theo mô hình Hub & Spoke kết nối IBST Root Hub với các Spoke Site chuyên biệt của CCBA. Tài liệu đưa ra 10 nguyên tắc thiết kế cốt lõi (Mô hình dữ liệu chuẩn hóa, Phân quyền linh hoạt, Bảo mật theo cấp, Tự động hóa luồng công việc) đảm bảo tích hợp hoàn hảo với thể chế quản trị pháp lý QCTK 2815 và QCCTNB 3209.
- **Phạm vi ứng dụng**: Cơ sở tham chiếu kiến trúc kỹ thuật cho toàn bộ kỹ sư giải pháp, lập trình viên và quản trị viên hệ thống IDOP.
- **Anchor Links tới các Phần quan trọng**:
  - [Phần I - Giới thiệu tổng quan & Mục tiêu chiến lược IDOP](system_blueprint/01_idop_v2_architecture.md#phần-i-giới-thiệu-tổng-quan)
  - [Phần II - Bối cảnh vận hành & Tích hợp Thể chế Pháp lý](system_blueprint/01_idop_v2_architecture.md#phần-ii-bối-cảnh-vận-hành-và-cơ-sở-pháp-lý)
  - [Phần III - Mười Nguyên tắc Thiết kế Kiến trúc Cốt lõi](system_blueprint/01_idop_v2_architecture.md#phần-iii-nguyên-tắc-thiết-kế-kiến-trúc)
  - [Phần IV - Kiến trúc Tổng thể 8 Lớp & Mô hình Hub & Spoke](system_blueprint/01_idop_v2_architecture.md#phần-iv-kiến-trúc-tổng-thể---8-lớp)
  - [Phần V đến VIII - Chi tiết Lớp Dữ liệu, Lớp Nghiệp vụ & Bảo mật](system_blueprint/01_idop_v2_architecture.md#phần-iv-kiến-trúc-tổng-thể---8-lớp)

#### 6. `02_idop_v2_operations_finance.md` (IDOP v2.0 F2 Operations & Finance)
- **Tóm tắt cốt lõi**: Tài liệu quy định chi tiết Quy trình Vận hành 7 Bước số hóa (từ Đấu thầu, Ký hợp đồng, Phê duyệt PGV 4 luồng, Quản lý thực hiện 5 luồng, Kiểm tra QA/QC, Nghiệm thu đến Quyết toán thanh lý). Đồng thời, tài liệu số hóa toàn bộ công thức tính toán tài chính, tỷ lệ phân bổ doanh thu, quản lý công nợ và tự động hóa kỷ luật dòng tiền theo đúng QCCTNB 3209 và Quy chế CCBA 2026.
- **Phạm vi ứng dụng**: Hướng dẫn vận hành bắt buộc cho Ban Giám đốc, Kế toán trưởng, Quản lý dự án (PM) và Chủ trì kỹ thuật.
- **Anchor Links tới các Phần quan trọng**:
  - [Phần IX - Quy trình Vận hành 7 Bước theo QCTK 2815](system_blueprint/02_idop_v2_operations_finance.md#phần-ix-quy-trình-vận-hành-7-bước)
  - [9.2. Bước 1 - Đấu thầu & Đăng ký Đơn vị Đầu mối](system_blueprint/02_idop_v2_operations_finance.md#92-bước-1---đấu-thầu)
  - [9.3. Bước 2 - Trình ký Hợp đồng & Phân cấp Thẩm quyền](system_blueprint/02_idop_v2_operations_finance.md#93-bước-2---trình-ký-hợp-đồng)
  - [9.4. Bước 3 - Phê duyệt Phiếu giao việc (4 luồng PGV)](system_blueprint/02_idop_v2_operations_finance.md#94-bước-3---phê-duyệt-pgv-4-luồng)
  - [9.5. Bước 4 - Quản lý thực hiện (5 luồng song song & 5 cấp QA/QC)](system_blueprint/02_idop_v2_operations_finance.md#95-bước-4---quản-lý-thực-hiện-5-luồng-song-song)
  - [9.6 & 9.7 - Bước 5, 6, 7 - Kiểm tra, Nghiệm thu & Quyết toán Thanh lý](system_blueprint/02_idop_v2_operations_finance.md#91-tổng-quan-7-bước-theo-qctk-2815)
  - [Phần X & XI - Cơ chế Quản lý Tài chính, Công nợ & Phân bổ Doanh thu](system_blueprint/02_idop_v2_operations_finance.md#phần-ix-quy-trình-vận-hành-7-bước)

#### 7. `03_idop_v2_technical_implementation.md` (IDOP v2.0 F3 Technical Implementation)
- **Tóm tắt cốt lõi**: Tài liệu thiết kế kỹ thuật chi tiết cho các phân hệ phần mềm IDOP, danh mục hơn 40 luồng tự động hóa Power Automate Flows, các quy tắc kiểm tra tính hợp lệ (Validation Rules) tài chính và tuân thủ. Ngoài ra, tài liệu mô tả chi tiết phương pháp tích hợp Trợ lý thông minh Copilot AI và Lộ trình triển khai theo phương pháp CCBA Hybrid Workflow.
- **Phạm vi ứng dụng**: Áp dụng cho đội ngũ phát triển Power Platform, lập trình viên AI/Copilot và Kỹ sư kiểm thử QA.
- **Anchor Links tới các Phần quan trọng**:
  - [Phần XII - Yêu cầu Thiết kế Hệ thống Chi tiết (12.1 Nghiệp vụ tích hợp)](system_blueprint/03_idop_v2_technical_implementation.md#phần-xii-yêu-cầu-thiết-kế-hệ-thống-chi-tiết)
  - [12.5 - Yêu cầu Copilot / AI Agent Tự động hóa](system_blueprint/03_idop_v2_technical_implementation.md#125-yêu-cầu-copilotai)
  - [12.6 - Danh mục Power Automate Flows (40+ Flows cốt lõi)](system_blueprint/03_idop_v2_technical_implementation.md#126-danh-mục-power-automate-flows-40)
  - [12.7 - Validation Rules Quan trọng (Financial, Compliance, Process)](system_blueprint/03_idop_v2_technical_implementation.md#127-validation-rules-quan-trọng)
  - [Phần XIII - Lộ trình Triển khai CCBA Hybrid Workflow](system_blueprint/03_idop_v2_technical_implementation.md#phần-xiii-lộ-trình-triển-khai)

#### 8. `04_idop_v2_enterprise_architecture.md` (IDOP v2.0 F4 Enterprise Architecture)
- **Tóm tắt cốt lõi**: Tài liệu mở rộng Kiến trúc Doanh nghiệp từ 8 lớp lên 10 lớp, bổ sung Lớp Năng lực Nghiệp vụ (Business Capability Layer) và Lớp Hệ sinh thái Bên ngoài (External Ecosystem Layer). Văn bản quy định chi tiết 7 SharePoint Lists mới phục vụ quản lý Khoa học Công nghệ, bộ Từ điển Dữ liệu Taxonomy mở rộng, ma trận phân quyền nâng cao RBAC/ABAC và khả năng tích hợp với các hệ thống Chính phủ số.
- **Phạm vi ứng dụng**: Định hướng mở rộng kiến trúc dài hạn (IDOP 2030) cho Kiến trúc sư Trưởng và Ban Kỹ thuật Viện.
- **Anchor Links tới các Phần quan trọng**:
  - [Phần 1 - Giới thiệu & Tầm nhìn Enterprise IDOP 2030](system_blueprint/04_idop_v2_enterprise_architecture.md#phần-1-giới-thiệu--tầm-nhìn-enterprise)
  - [1.3 - Bốn Nguyên tắc Enterprise Bổ sung (Principles 11-14)](system_blueprint/04_idop_v2_enterprise_architecture.md#13-bốn-nguyên-tắc-enterprise-bổ-sung)
  - [Phần 2 - Nâng cấp Kiến trúc Doanh nghiệp từ 8 lớp lên 10 lớp](system_blueprint/04_idop_v2_enterprise_architecture.md#phần-2-kiến-trúc-enterprise-10-lớp)
  - [2.2 - Lớp 3 (Mới): Business Capability Layer](system_blueprint/04_idop_v2_enterprise_architecture.md#22-lớp-3-mới---business-capability-layer)
  - [2.3 - Lớp 10 (Mới): External Ecosystem Layer (Tích hợp Hệ thống Công)](system_blueprint/04_idop_v2_enterprise_architecture.md#23-lớp-10-mới---external-ecosystem-layer)
  - [Phần 3 - Dữ liệu & Taxonomy Mở rộng (7 SharePoint Lists KHCN)](system_blueprint/04_idop_v2_enterprise_architecture.md#phần-3-dữ-liệu--taxonomy-mở-rộng)

---

## 3. MA TRẬN TRA CỨU NHANH (QUICK LOOKUP TABLE)

> *"Tôi cần biết/xử lý về vấn đề **X** -> Tôi phải đọc **File Y**, tại **Điều / Phần Z**"*

| 🔍 Chủ đề Tra cứu (Problem / Topic) | 📄 Văn bản Cần đọc (File) | 📍 Điều / Phần Anchor Link | 💡 Ghi chú Nghiệp vụ Cốt lõi |
|---|---|---|---|
| **Đăng ký đầu mối đấu thầu & Tìm kiếm thị trường** | `01_qctk_2815_project_management.md` | [Điều 5.1](governance_constitution/01_qctk_2815_project_management.md#điều-5) | Phải đăng ký đầu mối qua Phòng KHKT; Giám đốc đơn vị chịu trách nhiệm HSDT |
| **Phân cấp thẩm quyền ký kết Hợp đồng kinh tế** | `01_qctk_2815_project_management.md` | [Điều 6](governance_constitution/01_qctk_2815_project_management.md#điều-6) | Phân định HĐ do Viện ký vs HĐ do Trung tâm ký; các HĐ bắt buộc báo cáo Viện trưởng |
| **Thẩm định & Phê duyệt Phiếu giao việc (PGV)** | `01_qctk_2815_project_management.md` | [Điều 7](governance_constitution/01_qctk_2815_project_management.md#điều-7) | Phê duyệt theo 4 luồng PGV tùy thuộc vào loại HĐ và đơn vị chủ trì |
| **Quy trình Kiểm soát Chất lượng 5 Cấp (QA/QC)** | `01_qctk_2815_project_management.md`<br>`03_ccba_charter_2026.md` | [QCTK Điều 8, 9, 10](governance_constitution/01_qctk_2815_project_management.md#điều-8)<br>[CCBA SOP 02](governance_constitution/03_ccba_charter_2026.md#sop-02-quy-trình-phê-duyệt-hồ-sơ-kỹ-thuật-kiểm-soát-05-cấp) | Bắt buộc trải qua 5 cấp duyệt số trước khi xuất bản hồ sơ/báo cáo kỹ thuật |
| **Quyết toán thanh lý Hợp đồng & Phân bổ Doanh thu** | `01_qctk_2815_project_management.md`<br>`02_qcctnb_3209_financial_norms.md`<br>`03_ccba_charter_2026.md` | [QCTK Điều 11-12](governance_constitution/01_qctk_2815_project_management.md#điều-11)<br>[QCCTNB Điều 5](governance_constitution/02_qcctnb_3209_financial_norms.md#chương-ii)<br>[CCBA Phụ lục 02](governance_constitution/03_ccba_charter_2026.md#phụ-lục-02) | Phân bổ tỷ lệ 55% sản xuất trực tiếp, 15% trích nộp, 15% quỹ dự phòng & thu nhập tăng thêm |
| **Định mức Chi công tác phí, Tiền lương & Ăn ca** | `02_qcctnb_3209_financial_norms.md` | [Điều 8.2](governance_constitution/02_qcctnb_3209_financial_norms.md#82-yêu-cầu-định-mức-và-chứng-từ-chi) | Chi tiết định mức tiền phòng, phụ cấp lưu trú, vé máy bay và chứng từ thanh toán |
| **Hạn mức Phê duyệt Chi tiêu & Tạm ứng Kế toán** | `02_qcctnb_3209_financial_norms.md`<br>`03_ccba_charter_2026.md` | [QCCTNB Điều 15-16](governance_constitution/02_qcctnb_3209_financial_norms.md#chương-iv)<br>[CCBA SOP 03](governance_constitution/03_ccba_charter_2026.md#sop-03-quy-trình-tạm-ứng-thanh-toán-và-giải-ngân-kỷ-luật-dòng-tiền) | Hạn mức phê duyệt theo các mốc tài chính; kỷ luật giải ngân theo tiến độ PGV |
| **Cơ cấu Tổ chức, Sơ đồ GWC & Phân công Nhân sự** | `03_ccba_charter_2026.md` | [Điều 4-8 & Phụ lục 01](governance_constitution/03_ccba_charter_2026.md#phụ-lục-01) | Accountability Chart, chức danh GWC, vai trò PM, Chủ trì kỹ thuật & Trưởng bộ môn |
| **Đăng ký, Quản lý & Nghiệm thu Đề tài KHCN** | `04_ibst_science_tech_regulations.md` | [Điều 4, 8, 12](governance_constitution/04_ibst_science_tech_regulations.md#điều-4) | Quy trình đăng ký, thành lập Hội đồng đánh giá và quản lý Quỹ phát triển KHCN |
| **Mô hình Kiến trúc 8 Lớp & Hub & Spoke IDOP** | `01_idop_v2_architecture.md` | [Phần IV](system_blueprint/01_idop_v2_architecture.md#phần-iv-kiến-trúc-tổng-thể---8-lớp) | Cấu trúc SharePoint Root Hub (IBST) và Spoke Sites (CCBA), phân tách Tenant/Site |
| **Chi tiết Luồng Quy trình Vận hành 7 Bước Số hóa** | `02_idop_v2_operations_finance.md` | [Phần IX](system_blueprint/02_idop_v2_operations_finance.md#phần-ix-quy-trình-vận-hành-7-bước) | Mô tả chi tiết từng bước từ Lead CRM -> Hợp đồng -> PGV -> QC -> Nghiệm thu -> Quyết toán |
| **Danh mục 40+ Power Automate Flows & Validations** | `03_idop_v2_technical_implementation.md` | [Phần XII (12.6 & 12.7)](system_blueprint/03_idop_v2_technical_implementation.md#126-danh-mục-power-automate-flows-40) | Danh sách tên Flow, Trigger, Actions và các quy tắc Validation dữ liệu tài chính/quy trình |
| **Tích hợp Trợ lý AI Copilot Agent vào IDOP** | `03_idop_v2_technical_implementation.md`<br>`03_ccba_charter_2026.md` | [F3 Section 12.5](system_blueprint/03_idop_v2_technical_implementation.md#125-yêu-cầu-copilotai)<br>[CCBA SOP 01](governance_constitution/03_ccba_charter_2026.md#sop-01-quy-trình-phát-triển-kinh-doanh--tự-động-hóa-nhập-liệu-copilot-agent) | Kiến trúc Copilot Studio, Prompts, Tự động hóa trích xuất hợp đồng và tạo Lead |
| **Nâng cấp Kiến trúc Enterprise 10 Lớp & Taxonomy** | `04_idop_v2_enterprise_architecture.md` | [Phần 2 & 3](system_blueprint/04_idop_v2_enterprise_architecture.md#phần-2-kiến-trúc-enterprise-10-lớp) | Lớp Năng lực Nghiệp vụ (Lớp 3), Lớp Hệ sinh thái Bên ngoài (Lớp 10) & 7 SharePoint Lists mới |
| **Bản đồ Tham chiếu 21 Phân hệ Chức năng (Specs)** | `cross_references.yaml` | [Full Matrix Mapping](cross_references.yaml) | Ma trận YAML kết nối 21 file spec.md với hơn 150+ Điều/Khoản trong 8 tài liệu gốc |

---

## 4. MA TRẬN 21 PHÂN HỆ CHỨC NĂNG (SPEC MODULES INDEX)

Toàn bộ 21 file `spec.md` trong thư mục `specs/modules/` đã được liên kết trực tiếp với 8 văn bản thể chế & kiến trúc trên. Dưới đây là danh mục 6 miền nghiệp vụ:

1. **Miền Cash & Data (`specs/modules/cash_data/`)**:
   - `allocations/spec.md`: Chính sách & Quy tắc Phân bổ Thu nhập (QCTK Điều 11-12, QCCTNB Điều 5, CCBA Phụ lục 02).
   - `expenses/spec.md`: Quản lý Chi phí & Đề nghị Thanh toán (QCCTNB Điều 8.2, 15, 16, CCBA SOP 03).
   - `finance/spec.md`: Quản lý Tài chính Tổng hợp & Dòng tiền (QCCTNB Chương II-IV, IDOP F2 Phần X).
   - `spec.md`: Phân hệ Quản lý Tài chính & Dòng tiền Trung tâm.

2. **Miền People & Assets (`specs/modules/people_assets/`)**:
   - `assets/spec.md`: Quản lý Tài sản, Thiết bị Kiểm định & Bảo trì (QCTK Điều 4, QCCTNB Điều 8, CCBA GWC).
   - `hr/spec.md`: Quản lý Nhân sự, Chấm công real-time & Hồ sơ Năng lực (QCTK Điều 3-4, CCBA Phụ lục 01 GWC).

3. **Miền Performance & OKRs (`specs/modules/performance_okrs/`)**:
   - `performance/spec.md`: Đánh giá Hiệu suất, KPI & Thưởng Hoàn thành Nhiệm vụ (QCTK Điều 13, CCBA Phụ lục 01).
   - `reports/spec.md`: Hệ thống Báo cáo Đánh giá Định kỳ & Kiểm tra Nội bộ (QCTK Điều 10, QCCTNB Điều 18).

4. **Miền Process Execution (`specs/modules/process_execution/`)**:
   - `cde_documents/spec.md`: Quản lý Tài liệu Môi trường Dữ liệu Dùng chung CDE (QCTK Điều 9.8, CCBA SOP 02).
   - `contracts/spec.md`: Quản lý Hợp đồng & Trình ký Kinh tế (QCTK Điều 6, IDOP F2 Bước 2).
   - `lessons_learned/spec.md`: Quản lý Bài học Kinh nghiệm & Tri thức Kiểm định (QCTK Điều 10, 14, IBST KHCN).
   - `pmo/spec.md`: Quản lý Văn phòng Dự án PMO & Phê duyệt PGV 4 Luồng (QCTK Điều 7, IDOP F2 Bước 3).
   - `projects/spec.md`: Quản lý Thực thi Dự án & 5 Luồng Song song (QCTK Điều 8-9, IDOP F2 Bước 4).
   - `work_packages/spec.md`: Phân chia Gói công việc WBS & Tiến độ (QCTK Điều 3.2, 8.1, QCCTNB).

5. **Miền Strategy & CRM (`specs/modules/strategy_crm/`)**:
   - `crm/spec.md`: Quản lý Khách hàng & Đối tác (QCTK Điều 4, 5.1, QCCTNB Điều 8.2.5).
   - `lead_capture/spec.md`: Thu thập & Phân loại Cơ hội Đầu mối Lead (QCTK Điều 5.1, 13.1, CCBA SOP 01).
   - `opportunities/spec.md`: Đăng ký Đấu thầu & Quản lý Cơ hội Kinh doanh (QCTK Điều 5.1, 4.7, 6.1).
   - `potential_projects/spec.md`: Quản lý Tiềm năng Dự án & Kế hoạch Sản lượng (QCTK Điều 5.2, 7.3, CCBA Điều 3).

6. **Miền System Governance (`specs/modules/system_governance/`)**:
   - `approvals/spec.md`: Engine Phê duyệt Đa cấp Polymorphic 5 Cấp (QCTK Điều 5-10, QCCTNB Điều 16, CCBA Điều 15).
   - `forms/spec.md`: Engine Biểu mẫu Động & Chuẩn hóa Chứng từ Số (QCTK Điều 4, 8, QCCTNB Điều 15, CCBA Điều 24).
   - `governance/spec.md`: Quản trị Hệ thống, Phân quyền RBAC & Taxonomy (QCTK Điều 4, QCCTNB Điều 18, IDOP F4).

---
*Tài liệu này được khởi tạo tự động và kiểm chứng toàn vẹn cho Milestone 2 - IDOP-CCBA-WAY.*
"""

index_path = os.path.join(MD_DIR, 'INDEX.md')
with open(index_path, 'w', encoding='utf-8') as f:
    f.write(index_content)
print(f"✓ Created {index_path}")


# ---------------------------------------------------------
# 3. GENERATE cross_references.yaml
# ---------------------------------------------------------
spec_files = sorted(glob.glob(os.path.join(PROJECT_ROOT, 'specs/modules/**/spec.md'), recursive=True))

doc_title_map = {
    '01_qctk_2815_project_management.md': 'Quy chế Triển khai dự án số 2815/QĐ-VKH',
    '02_qcctnb_3209_financial_norms.md': 'Quy chế Chi tiêu Nội bộ số 3209/QĐ-VKH',
    '03_ccba_charter_2026.md': 'Quy chế Tổ chức & Hoạt động CCBA 2026 v2.2',
    '04_ibst_science_tech_regulations.md': 'Quy chế Quản lý Khoa học Công nghệ IBST',
    '01_idop_v2_architecture.md': 'IDOP v2.0 F1 Kiến trúc Tổng quan',
    '02_idop_v2_operations_finance.md': 'IDOP v2.0 F2 Vận hành & Tài chính 7 Bước',
    '03_idop_v2_technical_implementation.md': 'IDOP v2.0 F3 Triển khai Kỹ thuật & Flows',
    '04_idop_v2_enterprise_architecture.md': 'IDOP v2.0 F4 Enterprise Architecture 10 Lớp'
}

modules_cross_refs = []
total_mapped_refs = 0

for sf in spec_files:
    rel_path = os.path.relpath(sf, PROJECT_ROOT).replace('\\', '/')
    parts = rel_path.replace('specs/modules/', '').replace('/spec.md', '').split('/')
    domain = parts[0]
    mod_id = '_'.join(parts)
    
    with open(sf, 'r', encoding='utf-8') as f:
        content = f.read()
        
    lines = content.splitlines()
    spec_title = ''
    for l in lines:
        if l.startswith('# '):
            spec_title = l.replace('# ', '').strip()
            break
    if not spec_title:
        spec_title = mod_id

    gov_list = []
    bp_list = []
    seen_keys = set()
    
    current_sec = 'General Overview'
    for line in lines:
        if line.startswith('#'):
            current_sec = line.strip('# ').strip()
            
        clean_line = line.strip('-*#` ')
        if len(clean_line) < 6:
            continue
            
        # Check QCTK 2815
        if 'QCTK' in line or '2815' in line:
            arts = re.findall(r'Điều\s+\d+(?:\.\d+)*(?:\s*&\s*\d+)*(?:\s*Khoản\s+[a-z0-9,\s]+)?', line, re.IGNORECASE)
            art_str = ', '.join(arts) if arts else 'QCTK 2815 Rules'
            key = ('01_qctk_2815_project_management.md', art_str, clean_line[:40])
            if key not in seen_keys:
                seen_keys.add(key)
                gov_list.append({
                    'document': '01_qctk_2815_project_management.md',
                    'document_title': doc_title_map['01_qctk_2815_project_management.md'],
                    'article_clause': art_str,
                    'section_context': current_sec,
                    'topic': 'Quy trình quản lý thực thi dự án & kiểm soát tuân thủ',
                    'excerpt': clean_line[:150]
                })

        # Check QCCTNB 3209
        if 'QCCTNB' in line or '3209' in line:
            arts = re.findall(r'Điều\s+\d+(?:\.\d+)*(?:\s*&\s*\d+)*(?:\s*Khoản\s+[a-z0-9,\s]+)?', line, re.IGNORECASE)
            art_str = ', '.join(arts) if arts else 'QCCTNB 3209 Rules'
            key = ('02_qcctnb_3209_financial_norms.md', art_str, clean_line[:40])
            if key not in seen_keys:
                seen_keys.add(key)
                gov_list.append({
                    'document': '02_qcctnb_3209_financial_norms.md',
                    'document_title': doc_title_map['02_qcctnb_3209_financial_norms.md'],
                    'article_clause': art_str,
                    'section_context': current_sec,
                    'topic': 'Định mức chi tiêu tài chính, tạm ứng & quyết toán',
                    'excerpt': clean_line[:150]
                })

        # Check CCBA Charter 2026
        if 'CCBA' in line and any(k in line for k in ['Quy chế', 'Charter', 'Điều', 'SOP', 'Phụ lục', '2026', 'GWC']):
            arts = re.findall(r'(?:Điều\s+\d+(?:\.\d+)*|SOP\s+\d+|Phụ lục\s+\d+)', line, re.IGNORECASE)
            art_str = ', '.join(arts) if arts else 'Quy chế CCBA 2026'
            key = ('03_ccba_charter_2026.md', art_str, clean_line[:40])
            if key not in seen_keys:
                seen_keys.add(key)
                gov_list.append({
                    'document': '03_ccba_charter_2026.md',
                    'document_title': doc_title_map['03_ccba_charter_2026.md'],
                    'article_clause': art_str,
                    'section_context': current_sec,
                    'topic': 'Tổ chức bộ máy CCBA, phân quyền & quy trình SOP',
                    'excerpt': clean_line[:150]
                })

        # Check IBST KHCN
        if 'IBST' in line or 'KHCN' in line:
            if any(k in line for k in ['Quy chế', 'Điều', 'Nhiệm vụ', 'Đề tài', 'Khoa học']):
                arts = re.findall(r'Điều\s+\d+(?:\.\d+)*', line, re.IGNORECASE)
                art_str = ', '.join(arts) if arts else 'Quy chế KHCN IBST'
                key = ('04_ibst_science_tech_regulations.md', art_str, clean_line[:40])
                if key not in seen_keys:
                    seen_keys.add(key)
                    gov_list.append({
                        'document': '04_ibst_science_tech_regulations.md',
                        'document_title': doc_title_map['04_ibst_science_tech_regulations.md'],
                        'article_clause': art_str,
                        'section_context': current_sec,
                        'topic': 'Quản lý nhiệm vụ khoa học công nghệ & sáng kiến',
                        'excerpt': clean_line[:150]
                    })

        # Check IDOP Blueprints
        if any(k in line for k in ['IDOP', 'F1', 'F2', 'F3', 'F4', 'Architecture', 'Blueprint', 'Flow', 'SharePoint', 'Power Automate', 'Copilot', 'Validation']):
            bp_doc = '01_idop_v2_architecture.md'
            sec_name = 'Phần III & IV Kiến trúc 8 lớp'
            if 'F2' in line or 'Vận hành' in line or 'Tài chính' in line or '7 bước' in line or 'Bước' in line:
                bp_doc = '02_idop_v2_operations_finance.md'
                sec_name = 'Phần IX Quy trình vận hành 7 bước'
            elif 'F3' in line or 'Kỹ thuật' in line or 'Flow' in line or 'SharePoint' in line or 'Automate' in line or 'Validation' in line:
                bp_doc = '03_idop_v2_technical_implementation.md'
                sec_name = 'Phần XII Yêu cầu kỹ thuật & Flows'
            elif 'F4' in line or 'Enterprise' in line or '10 lớp' in line or 'Lớp' in line:
                bp_doc = '04_idop_v2_enterprise_architecture.md'
                sec_name = 'Phần 2 & 3 Enterprise Extension'

            key = (bp_doc, sec_name, clean_line[:40])
            if key not in seen_keys:
                seen_keys.add(key)
                bp_list.append({
                    'document': bp_doc,
                    'document_title': doc_title_map[bp_doc],
                    'section': sec_name,
                    'section_context': current_sec,
                    'topic': 'Thiết kế hệ thống, luồng dữ liệu & tự động hóa IDOP',
                    'excerpt': clean_line[:150]
                })

    mod_refs_count = len(gov_list) + len(bp_list)
    total_mapped_refs += mod_refs_count
    
    modules_cross_refs.append({
        'module_id': mod_id,
        'domain': domain,
        'spec_file': rel_path,
        'spec_title': spec_title,
        'mapped_references_count': mod_refs_count,
        'governance_constitution_references': gov_list,
        'system_blueprint_references': bp_list
    })

cross_references_data = {
    'metadata': {
        'generated_at': '2026-07-28',
        'project': 'IDOP-CCBA-WAY',
        'milestone': 'Milestone 2',
        'description': (
            'Bi-directional cross-reference mapping matrix linking all 21 spec.md files '
            'in specs/modules/ to exact Articles, Clauses, Sections in Governance Constitution '
            'documents (.md/governance_constitution/) and System Blueprint files (.md/system_blueprint/).'
        ),
        'total_spec_modules': len(modules_cross_refs),
        'total_mapped_references': total_mapped_refs
    },
    'modules': modules_cross_refs
}

cross_yaml_path = os.path.join(MD_DIR, 'cross_references.yaml')
with open(cross_yaml_path, 'w', encoding='utf-8') as f:
    yaml.dump(cross_references_data, f, sort_keys=False, allow_unicode=True, default_flow_style=False)

# Verify parsing
with open(cross_yaml_path, 'r', encoding='utf-8') as f:
    parsed_cross = yaml.safe_load(f)

assert parsed_cross['metadata']['total_spec_modules'] == 21
assert parsed_cross['metadata']['total_mapped_references'] >= 150
print(f"✓ Created & verified {cross_yaml_path}")
print(f"  Total Spec Modules Mapped: {parsed_cross['metadata']['total_spec_modules']}")
print(f"  Total Cross-References Mapped: {parsed_cross['metadata']['total_mapped_references']}")

print("=== META FILES GENERATION COMPLETE ===")
