# IDOP-CCBA-WAY Scaffold

## Tổng quan

Đây là scaffold gọn nhẹ của nền tảng IDOP-CCBA-WAY, được tinh gọn từ repo gốc để loại bỏ các thành phần development artifacts và runtime data. Scaffold này chứa đầy đủ các thành phần cốt lõi để triển khai nền tảng số hóa cho Trung tâm Tư vấn và Ứng dụng BIM trong xây dựng (CCBA).

## Cấu trúc Scaffold

```
idop-ccba-way-scaffold/
├── datamodel/                    # JSON schemas cho SharePoint Lists & Taxonomy
│   └── sharepoint/
│       ├── lists/               # 48+ SharePoint List definitions
│       ├── schemas/             # JSON validation schemas
│       └── taxonomy/            # 19 Term Sets cho managed metadata
├── specs/                       # Spec-Driven Development với 6 modules
│   └── modules/
│       ├── cash_data/          # Quản lý tài chính
│       ├── people_assets/      # Quản lý nhân sự & tài sản
│       ├── performance_okrs/   # OKRs & KPIs
│       ├── process_execution/  # Thực thi dự án
│       ├── strategy_crm/       # CRM & cơ hội kinh doanh
│       └── system_governance/  # Quy trình phê duyệt
├── tools/
│   └── scripts/                # PowerShell automation scripts
├── list-formatting/            # JSON formatting cho SharePoint views
├── docs/                       # Documentation & guides
├── prompts/                    # AI prompts cho Spec-Driven Development
├── constitution.md             # Quy tắc phát triển
├── copilot-instructions.md     # Hướng dẫn cho GitHub Copilot
└── README.md                   # Documentation chính
```

## Các thành phần đã loại bỏ

- **Runtime data**: `.serena/` (793MB), `.serena-copilot-context/`, `.serena-copilot-context-extension/`
- **Development artifacts**: `serena/` (119MB), `serena-mcp-injector/` (67MB)
- **Virtual environments**: `.venv*/` (235MB+)
- **Reports**: Tất cả file `*_REPORT.md`, `PHASE*.md`, `*_SUCCESS_REPORT.md`
- **Temporary data**: `.specify/`, `scripts/`
- **Deployment logs**: `deployment_*.log`

**Kết quả**: Giảm từ 1.3GB+ xuống còn 7.5MB (giảm 99%+)

## Cách sử dụng Scaffold

### 1. Khởi tạo repo mới

```bash
# Clone scaffold
git clone <scaffold-repo-url> new-ccba-project
cd new-ccba-project

# Khởi tạo git repo mới
rm -rf .git
git init
git add .
git commit -m "Initial scaffold from IDOP-CCBA-WAY"
```

### 2. Cấu hình môi trường

```bash
# Cài đặt dependencies cho validation
npm install -g ajv-cli markdownlint-cli

# Hoặc sử dụng PowerShell scripts có sẵn
.\tools\scripts\validate-sp-schemas.ps1
```

### 3. Triển khai datamodel

```powershell
# Validate JSON schemas
.\tools\scripts\validate-sp-schemas.ps1

# Import taxonomy (dry-run first)
.\tools\scripts\termstore-import.ps1 -DryRun

# Apply SharePoint Lists (dry-run first)
.\tools\scripts\apply-sp-lists.ps1 -DryRun
```

### 4. Phát triển theo spec-driven workflow

```bash
# Sử dụng prompts có sẵn cho AI-assisted development
# /specify → Tạo spec.md từ yêu cầu
# /plan → Tạo plan.md từ spec
# /tasks → Tạo tasks.md từ plan
```

## Validation & Testing

### JSON Schema Validation
```bash
# Validate tất cả list definitions
node tools/scripts/validate-sp-schemas.js
# Expected: ✅ Schema validation PASSED for all lists
```

### Taxonomy Import (Dry-run)
```powershell
.\tools\scripts\termstore-import.ps1 -DryRun
# Expected: ✅ All ManagedMetadata bindings found in term store
```

### SharePoint Lists Deployment (Dry-run)
```powershell
.\tools\scripts\apply-sp-lists.ps1 -DryRun
# Expected: Success với detailed diff
```

## Spec Modules Overview

### 1. strategy_crm (CRM & Sales)
- **Opportunities**: Quản lý vòng đời cơ hội kinh doanh
- **Customers**: Thông tin khách hàng
- **Contacts**: Liên hệ & stakeholders
- **Service Catalog**: Danh mục dịch vụ BIM

### 2. process_execution (Project Management)
- **Projects**: Quản lý dự án BIM
- **Contracts**: Hợp đồng & thỏa thuận
- **Activities**: Theo dõi công việc
- **Work Packages**: Phân chia nhiệm vụ

### 3. cash_data (Financial Management)
- **Expenses**: Quản lý chi phí
- **Invoices**: Hóa đơn vào/ra
- **Financial Plans**: Kế hoạch tài chính
- **Allocations**: Phân bổ ngân sách

### 4. people_assets (HR & Assets)
- **Employees**: Thông tin nhân viên
- **Assets**: Quản lý tài sản
- **Timesheets**: Chấm công
- **Certifications**: Chứng chỉ & đào tạo

### 5. performance_okrs (Performance Tracking)
- **OKRs**: Objectives & Key Results
- **Measurables**: Chỉ số KPI
- **Scorecard Data**: Báo cáo hiệu suất

### 6. system_governance (Approvals & Compliance)
- **Approval Workflows**: Quy trình phê duyệt
- **Submissions**: Tờ trình & đề xuất
- **Integration Points**: Tích hợp hệ thống

## Customization Guide

### Thêm List mới
1. Tạo JSON definition trong `datamodel/sharepoint/lists/`
2. Validate schema: `node tools/scripts/validate-sp-schemas.js`
3. Test deployment: `.\tools\scripts\apply-sp-lists.ps1 -DryRun`

### Thêm Taxonomy mới
1. Tạo JSON file trong `datamodel/sharepoint/taxonomy/`
2. Test import: `.\tools\scripts\termstore-import.ps1 -DryRun`

### Mở rộng Spec Module
1. Tạo thư mục mới trong `specs/modules/`
2. Follow pattern: `spec.md` → `plan.md` → `tasks.md`
3. Update `README.md` với module mới

## Deployment Checklist

- [ ] Validate tất cả JSON schemas
- [ ] Test taxonomy import (dry-run)
- [ ] Test SharePoint lists deployment (dry-run)
- [ ] Backup production environment
- [ ] Deploy taxonomy trước
- [ ] Deploy SharePoint lists
- [ ] Configure Power Automate flows
- [ ] Setup Power BI datasets
- [ ] Test end-to-end workflows

## Troubleshooting

### Schema Validation Fails
```bash
# Check specific file
ajv validate -s datamodel/sharepoint/schemas/sp-list.schema.json -d datamodel/sharepoint/lists/<module>/<list>.json
```

### Taxonomy Import Issues
```powershell
# Check permissions
.\tools\scripts\check-pnp-auth-capability.ps1
```

### SharePoint Deployment Issues
```powershell
# Enable verbose logging
$VerbosePreference = "Continue"
.\tools\scripts\apply-sp-lists.ps1 -DryRun
```

## Optional: Serena MCP Integration

Nếu cần AI-assisted development nâng cao với Model Context Protocol:

### 1. Clone và cài đặt Serena
```bash
# Clone Serena repo
git clone https://github.com/oraios/serena.git temp-serena
cp -r temp-serena/serena ./serena
cp temp-serena/serena-mcp-injector/serena-mcp-injector-0.0.1.vsix ./
rm -rf temp-serena
```

### 2. Setup virtual environment
```bash
cd serena
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Install VS Code extension
```bash
code --install-extension serena-mcp-injector-0.0.1.vsix
```

### 4. Start MCP server
```powershell
# Sử dụng script có sẵn
.\tools\scripts\start-serena-mcp.ps1 -Context "agent" -Mode "editing" -Transport "sse" -Port 9121

# Hoặc chạy trực tiếp
cd serena
.venv\Scripts\python.exe scripts/mcp_server.py --context "agent" --mode "editing" \
  --transport "sse" --host "127.0.0.1" --port 9121
```

### 5. Verify installation
```bash
# Test import module
.venv\Scripts\python.exe -c "import serena; print('Serena module found')"

# Test MCP server
curl http://127.0.0.1:9121/health
```

**Lưu ý:** Serena MCP là optional component cho AI-assisted development.  
Scaffold core vẫn hoạt động bình thường mà không cần nó.

## Contributing

1.  Follow Spec-Driven Development workflow
2.  Validate changes before commit
3.  Update documentation
4.  Test deployment scripts

## License & Attribution

Based on IDOP-CCBA-WAY framework - Internal use for IBST CCBA division.