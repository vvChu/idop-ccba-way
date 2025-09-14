#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="idop-ccba-way"

declare -A MODULE_GROUPS
MODULE_GROUPS[strategy_crm]="crm opportunities"
MODULE_GROUPS[process_execution]="pmo projects"
MODULE_GROUPS[cash_data]="finance expenses allocations"
MODULE_GROUPS[people_assets]="hr assets"
MODULE_GROUPS[system_governance]="approvals governance forms"
MODULE_GROUPS[performance_okrs]="performance reports"

# 1) Thư mục cốt lõi
mkdir -p specs/modules
mkdir -p datamodel/sharepoint/{lists,libraries,schemas,taxonomy}
mkdir -p datamodel/sharepoint/lists/{strategy_crm,process_execution,cash_data,people_assets,system_governance,performance_okrs}
mkdir -p power/solutions
mkdir -p tools/{speckit,scripts}
mkdir -p .github/workflows
mkdir -p prompts
mkdir -p docs
mkdir -p .vscode

# 2) File nền tảng
cat > AGENTS.md <<'MD'
# AGENTS.md — Hướng dẫn cho AI Agent

## Nguyên tắc cập nhật liên tục
- Mỗi module trong `specs/modules/<hợp phần>/<module>/` đều có:
  - `spec.md`: mô tả nghiệp vụ, quy trình, acceptance criteria, **ràng buộc & chỉ dẫn đặc thù**.
  - `plan.md`: chi tiết kỹ thuật, tích hợp, cấu hình, **tích hợp & cấu hình đặc thù**.
  - `tasks.md`: backlog và kiểm thử.
- Trước khi thiết kế hoặc chỉnh sửa, **luôn đọc kỹ** `spec.md` và `plan.md` của module để nắm:
  - Trigger nghiệp vụ quan trọng.
  - Quy tắc đặt tên, phân quyền, tích hợp hệ thống ngoài.
  - Lookup/Managed Metadata và taxonomy liên quan.
- Khi phát hiện ràng buộc mới hoặc cần cải tiến:
  1. Bổ sung vào `spec.md` và/hoặc `plan.md` của module.
  2. Commit qua PR, review và “Trình ký” trước khi triển khai.
- Định kỳ rà soát để tinh chỉnh, đảm bảo hệ thống vận hành **Smarter – Faster – Better**.
MD

echo "# Constitution — Nguyên tắc kỹ thuật & kiểm soát chất lượng CCBA" > constitution.md
echo "# Copilot instructions — Hướng dẫn cho AI Agent" > copilot-instructions.md
echo "# Prompt viết spec.md" > prompts/spec.md
echo "# Prompt viết plan.md" > prompts/plan.md
echo "# Prompt viết tasks.md" > prompts/tasks.md
echo "# Thiết lập môi trường phát triển" > docs/dev-setup.md
echo "# Quy trình cộng tác với AI Agent" > docs/ai-workflow.md
echo "# IDOP — CCBA WAY (Tài liệu sống)" > docs/index.md

cat > .speckit.yml <<'YAML'
docs:
  entry: docs/index.md
  output: docs/site
placeholders:
  - file: specs/modules/*/*/spec.md
  - file: specs/modules/*/*/plan.md
  - file: specs/modules/*/*/tasks.md
assets:
  - specs/modules/*/*/diagrams/**
YAML

cat > .vscode/settings.json <<'JSON'
{
  "chat.tools.edits.autoApprove": false,
  "chat.tools.edits.protectedPatterns": [
    ".speckit.yml",
    "datamodel/sharepoint/lists/**/*.json",
    "datamodel/sharepoint/schemas/*.json",
    "constitution.md",
    "AGENTS.md"
  ]
}
JSON

# 3) JSON Schema Lists
cat > datamodel/sharepoint/schemas/sp-list.schema.json <<'JSON'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "SharePoint List Definition",
  "type": "object",
  "properties": {
    "ListName": { "type": "string" },
    "Description": { "type": "string" },
    "Columns": { "type": "array" }
  },
  "required": ["ListName", "Columns"]
}
JSON

# 4) Sinh module theo 6 hợp phần
titlecase() { echo "$1" | sed -E 's/(^|[_-])([a-z])/\U\2/g'; }
for group in "${!MODULE_GROUPS[@]}"; do
  for module in ${MODULE_GROUPS[$group]}; do
    mkdir -p "specs/modules/$group/$module/diagrams"
    MODTITLE=$(titlecase "$module")
    cat > "specs/modules/$group/$module/spec.md" <<MD
# Module: $MODTITLE

## Mục tiêu
...

## Phạm vi
...

## User stories
...

## Acceptance criteria
...

## Quy trình & BPMN
...

## Ràng buộc & chỉ dẫn đặc thù
_(Ghi rõ các quy tắc nghiệp vụ riêng, trigger, phân quyền, tích hợp đặc biệt của module này. Nếu chưa có, để trống và bổ sung khi phát sinh.)_
MD
    cat > "specs/modules/$group/$module/plan.md" <<MD
# Kế hoạch kỹ thuật — $MODTITLE

## Kiến trúc
...

## Data model
...

## Flows
...

## Env & security
...

## Tích hợp & cấu hình đặc thù
_(Mô tả cách hiện thực các ràng buộc đặc thù: API, xử lý lỗi, biến môi trường, connection refs. Nếu chưa có, để trống và bổ sung khi phát sinh.)_

## Triển khai & kiểm thử
...
MD
    echo "# Backlog — $MODTITLE" > "specs/modules/$group/$module/tasks.md"
    echo '{ "openapi":"3.0.3","info":{"title":"'"$MODTITLE"' API","version":"0.1.0"},"paths":{} }' > "specs/modules/$group/$module/api-spec.json"
  done
done

# 5) Scripts rỗng
for s in apply-sp-lists.sh export-sp-lists.sh sp-diff.sh termstore-import.sh termstore-export.sh; do
  echo "#!/usr/bin/env bash" > "tools/scripts/$s"
  chmod +x "tools/scripts/$s"
done
echo "// validate-sp-schemas.js placeholder" > tools/scripts/validate-sp-schemas.js

# 6) Workflows placeholder
for wf in power-alm.yml sp-guard.yml taxonomy-sync.yml; do
  echo "# GitHub Actions Workflow" > ".github/workflows/$wf"
done

# 7) Taxonomy CSV mẫu
# (Thêm các file CSV taxonomy như đã thống nhất)

# 8) Helper write_list
write_list() {
  local path="$1"; shift
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<JSON
{
  "\$schema": "datamodel/sharepoint/schemas/sp-list.schema.json",
  $@
}
JSON
}

# 9) Tạo JSON Lists mẫu
# === Process & Execution ===

write_list datamodel/sharepoint/lists/process_execution/contracts.json '
"ListName": "Contracts",
"Description": "Hợp đồng",
"Columns": [
  { "Name": "ContractCode", "Type": "Text", "Required": true },
  { "Name": "ContractName", "Type": "Text", "Required": true },
  { "Name": "CustomerId", "Type": "Lookup",
    "Lookup": { "List": "Customers", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Currency", "Type": "Choice", "Choices": ["VND","USD","EUR"] },
  { "Name": "VATRate", "Type": "Number" },
  { "Name": "GrossAmount", "Type": "Number" },
  { "Name": "NetAmount", "Type": "Number" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiChung" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/projects.json '
"ListName": "Projects",
"Description": "Dự án thực thi",
"Columns": [
  { "Name": "ProjectCode", "Type": "Text", "Required": true },
  { "Name": "ProjectName", "Type": "Text", "Required": true },
  { "Name": "ContractId", "Type": "Lookup",
    "Lookup": { "List": "Contracts", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Budget", "Type": "Number" },
  { "Name": "ServiceType", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_LoaiHinhDichVu" } },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiChung" } },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/work_packages.json '
"ListName": "WorkPackages",
"Description": "Gói công việc",
"Columns": [
  { "Name": "PackageName", "Type": "Text", "Required": true },
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "AssignedTo", "Type": "User" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiChung" } },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/activities.json '
"ListName": "Activities",
"Description": "Hoạt động CRM/Marketing/R&D/Admin",
"Columns": [
  { "Name": "ActivityName", "Type": "Text", "Required": true },
  { "Name": "ActivityType", "Type": "Choice",
    "Choices": ["CRM","PotentialProject","Marketing","R&D","Admin"] },
  { "Name": "Owner", "Type": "User" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiChung" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/project_risks.json '
"ListName": "ProjectRisks",
"Description": "Rủi ro dự án",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "RiskTitle", "Type": "Text", "Required": true },
  { "Name": "Severity", "Type": "Choice",
    "Choices": ["Low","Medium","High"] },
  { "Name": "MitigationPlan", "Type": "Text" },
  { "Name": "Owner", "Type": "User" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiChung" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/project_issues.json '
"ListName": "ProjectIssues",
"Description": "Vấn đề dự án",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "IssueTitle", "Type": "Text", "Required": true },
  { "Name": "Priority", "Type": "Choice",
    "Choices": ["High","Medium","Low"] },
  { "Name": "Description", "Type": "Text" },
  { "Name": "Owner", "Type": "User" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiChung" } },
  { "Name": "ReportedDate", "Type": "DateTime" },
  { "Name": "ResolvedDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/lessons_learned.json '
"ListName": "LessonsLearned",
"Description": "Bài học kinh nghiệm",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "LessonTitle", "Type": "Text", "Required": true },
  { "Name": "Description", "Type": "Text" },
  { "Name": "Category", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_PhanLoaiBaiHoc" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/job_assignments.json '
"ListName": "JobAssignments",
"Description": "Phân công công việc",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Role", "Type": "Text" },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/assignment_details.json '
"ListName": "AssignmentDetails",
"Description": "Chi tiết phân công",
"Columns": [
  { "Name": "AssignmentId", "Type": "Lookup",
    "Lookup": { "List": "JobAssignments", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "TaskDescription", "Type": "Text" },
  { "Name": "HoursWorked", "Type": "Number" },
  { "Name": "Notes", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/process_execution/project_history.json '
"ListName": "ProjectHistory",
"Description": "Lịch sử dự án",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "ChangeDate", "Type": "DateTime" },
  { "Name": "ChangeDescription", "Type": "Text" },
  { "Name": "IsCurrent", "Type": "YesNo" }
],
"ContentTypes": []
'
# === Cash & Data ===

write_list datamodel/sharepoint/lists/cash_data/bank_accounts.json '
"ListName": "BankAccounts",
"Description": "Tài khoản ngân hàng",
"Columns": [
  { "Name": "BankName", "Type": "Text", "Required": true },
  { "Name": "AccountNumber", "Type": "Text", "Required": true },
  { "Name": "AccountName", "Type": "Text" },
  { "Name": "Currency", "Type": "Choice", "Choices": ["VND","USD","EUR"] }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/financial_plans.json '
"ListName": "FinancialPlans",
"Description": "Kế hoạch tài chính",
"Columns": [
  { "Name": "PlanName", "Type": "Text", "Required": true },
  { "Name": "Year", "Type": "Number" },
  { "Name": "TotalBudget", "Type": "Number" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/invoice_requests.json '
"ListName": "InvoiceRequests",
"Description": "Yêu cầu xuất hóa đơn",
"Columns": [
  { "Name": "ContractId", "Type": "Lookup",
    "Lookup": { "List": "Contracts", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "RequestDate", "Type": "DateTime" },
  { "Name": "Amount", "Type": "Number" },
  { "Name": "Currency", "Type": "Choice", "Choices": ["VND","USD","EUR"] }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/outgoing_invoices.json '
"ListName": "OutgoingInvoices",
"Description": "Hóa đơn đầu ra",
"Columns": [
  { "Name": "ContractId", "Type": "Lookup",
    "Lookup": { "List": "Contracts", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "InvoiceNumber", "Type": "Text", "Required": true },
  { "Name": "Currency", "Type": "Choice", "Choices": ["VND","USD","EUR"] },
  { "Name": "VATRate", "Type": "Number" },
  { "Name": "GrossAmount", "Type": "Number" },
  { "Name": "NetAmount", "Type": "Number" },
  { "Name": "InvoiceDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/vendors.json '
"ListName": "Vendors",
"Description": "Nhà cung cấp",
"Columns": [
  { "Name": "VendorName", "Type": "Text", "Required": true },
  { "Name": "VendorCode", "Type": "Text" },
  { "Name": "ServiceType", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_LoaiHinhDichVu" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/input_invoices.json '
"ListName": "InputInvoices",
"Description": "Hóa đơn đầu vào",
"Columns": [
  { "Name": "VendorId", "Type": "Lookup",
    "Lookup": { "List": "Vendors", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "InvoiceNumber", "Type": "Text", "Required": true },
  { "Name": "Currency", "Type": "Choice", "Choices": ["VND","USD","EUR"] },
  { "Name": "VATRate", "Type": "Number" },
  { "Name": "GrossAmount", "Type": "Number" },
  { "Name": "NetAmount", "Type": "Number" },
  { "Name": "InvoiceDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/expenses.json '
"ListName": "Expenses",
"Description": "Chi phí dự án",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "ExpenseType", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_LoaiChiPhi" } },
  { "Name": "Currency", "Type": "Choice", "Choices": ["VND","USD","EUR"] },
  { "Name": "VATRate", "Type": "Number" },
  { "Name": "GrossAmount", "Type": "Number" },
  { "Name": "NetAmount", "Type": "Number" },
  { "Name": "ExpenseDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/shared_cost_allocations.json '
"ListName": "SharedCostAllocations",
"Description": "Phân bổ chi phí chung",
"Columns": [
  { "Name": "ExpenseId", "Type": "Lookup",
    "Lookup": { "List": "Expenses", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "AllocationRuleId", "Type": "Lookup",
    "Lookup": { "List": "AllocationRules", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Amount", "Type": "Number" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/allocation_rules.json '
"ListName": "AllocationRules",
"Description": "Quy tắc phân bổ chi phí",
"Columns": [
  { "Name": "RuleName", "Type": "Text", "Required": true },
  { "Name": "Description", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/document_requirements.json '
"ListName": "DocumentRequirements",
"Description": "Yêu cầu hồ sơ chứng từ",
"Columns": [
  { "Name": "RequirementName", "Type": "Text", "Required": true },
  { "Name": "Description", "Type": "Text" },
  { "Name": "AppliesTo", "Type": "Choice",
    "Choices": ["Contract","Invoice","Expense"] }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/cash_data/expense_checklists.json '
"ListName": "ExpenseChecklists",
"Description": "Checklist kiểm tra chi phí",
"Columns": [
  { "Name": "ExpenseId", "Type": "Lookup",
    "Lookup": { "List": "Expenses", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "ChecklistItem", "Type": "Text" },
  { "Name": "IsCompleted", "Type": "YesNo" }
],
"ContentTypes": []
'
# === People & Assets ===

write_list datamodel/sharepoint/lists/people_assets/departments.json '
"ListName": "Departments",
"Description": "Phòng ban",
"Columns": [
  { "Name": "DepartmentName", "Type": "Text", "Required": true },
  { "Name": "DepartmentCode", "Type": "Text" },
  { "Name": "Manager", "Type": "User" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/employees.json '
"ListName": "Employees",
"Description": "Nhân viên",
"Columns": [
  { "Name": "FullName", "Type": "Text", "Required": true },
  { "Name": "EmployeeCode", "Type": "Text" },
  { "Name": "DepartmentId", "Type": "Lookup",
    "Lookup": { "List": "Departments", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Position", "Type": "Text" },
  { "Name": "HireDate", "Type": "DateTime" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiNhanSu" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/employee_history.json '
"ListName": "EmployeeHistory",
"Description": "Lịch sử nhân viên",
"Columns": [
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" },
  { "Name": "IsCurrent", "Type": "YesNo" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/employment_contracts.json '
"ListName": "EmploymentContracts",
"Description": "Hợp đồng lao động",
"Columns": [
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "ContractNumber", "Type": "Text", "Required": true },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" },
  { "Name": "ContractType", "Type": "Choice",
    "Choices": ["Full-time","Part-time","Internship","Freelance"] }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/benefit_packages.json '
"ListName": "BenefitPackages",
"Description": "Gói phúc lợi",
"Columns": [
  { "Name": "PackageName", "Type": "Text", "Required": true },
  { "Name": "Description", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/employee_benefits.json '
"ListName": "EmployeeBenefits",
"Description": "Phúc lợi nhân viên",
"Columns": [
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "BenefitPackageId", "Type": "Lookup",
    "Lookup": { "List": "BenefitPackages", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/rewards.json '
"ListName": "Rewards",
"Description": "Khen thưởng",
"Columns": [
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "RewardTitle", "Type": "Text", "Required": true },
  { "Name": "RewardDate", "Type": "DateTime" },
  { "Name": "Description", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/certifications.json '
"ListName": "Certifications",
"Description": "Chứng chỉ",
"Columns": [
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "CertificationName", "Type": "Text", "Required": true },
  { "Name": "IssuedBy", "Type": "Text" },
  { "Name": "IssueDate", "Type": "DateTime" },
  { "Name": "ExpiryDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/project_members.json '
"ListName": "ProjectMembers",
"Description": "Thành viên dự án",
"Columns": [
  { "Name": "ProjectId", "Type": "Lookup",
    "Lookup": { "List": "Projects", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Role", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/timesheets.json '
"ListName": "Timesheets",
"Description": "Bảng chấm công",
"Columns": [
  { "Name": "EmployeeId", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Date", "Type": "DateTime" },
  { "Name": "HoursWorked", "Type": "Number" },
  { "Name": "Notes", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/assets.json '
"ListName": "Assets",
"Description": "Tài sản",
"Columns": [
  { "Name": "AssetName", "Type": "Text", "Required": true },
  { "Name": "AssetCode", "Type": "Text" },
  { "Name": "AssignedTo", "Type": "Lookup",
    "Lookup": { "List": "Employees", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "PurchaseDate", "Type": "DateTime" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiTaiSan" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/people_assets/maintenance_logs.json '
"ListName": "MaintenanceLogs",
"Description": "Nhật ký bảo trì tài sản",
"Columns": [
  { "Name": "AssetId", "Type": "Lookup",
    "Lookup": { "List": "Assets", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "MaintenanceDate", "Type": "DateTime" },
  { "Name": "Description", "Type": "Text" },
  { "Name": "PerformedBy", "Type": "User" }
],
"ContentTypes": []
'
# === System & Governance ===

write_list datamodel/sharepoint/lists/system_governance/submissions.json '
"ListName": "Submissions",
"Description": "Hồ sơ nộp phê duyệt",
"Columns": [
  { "Name": "SubmissionTitle", "Type": "Text", "Required": true },
  { "Name": "RelatedEntity", "Type": "Choice",
    "Choices": ["Contract","Invoice","Expense","Project"] },
  { "Name": "RelatedId", "Type": "Number" },
  { "Name": "SubmittedBy", "Type": "User" },
  { "Name": "SubmissionDate", "Type": "DateTime" },
  { "Name": "Status", "Type": "ManagedMetadata",
    "TermSet": { "Group": "CCBA Taxonomy", "Name": "CCBA_TrangThaiPheDuyet" } }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/system_governance/approval_workflows.json '
"ListName": "ApprovalWorkflows",
"Description": "Quy trình phê duyệt",
"Columns": [
  { "Name": "WorkflowName", "Type": "Text", "Required": true },
  { "Name": "Description", "Type": "Text" },
  { "Name": "Steps", "Type": "Number" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/system_governance/environment_variables.json '
"ListName": "EnvironmentVariables",
"Description": "Biến môi trường hệ thống",
"Columns": [
  { "Name": "VariableName", "Type": "Text", "Required": true },
  { "Name": "Value", "Type": "Text" },
  { "Name": "Description", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/system_governance/integration_points.json '
"ListName": "IntegrationPoints",
"Description": "Điểm tích hợp hệ thống",
"Columns": [
  { "Name": "IntegrationName", "Type": "Text", "Required": true },
  { "Name": "SystemName", "Type": "Text" },
  { "Name": "APIEndpoint", "Type": "Text" },
  { "Name": "AuthMethod", "Type": "Choice",
    "Choices": ["None","Basic","OAuth2","APIKey"] }
],
"ContentTypes": []
'

# === Performance & OKRs ===

write_list datamodel/sharepoint/lists/performance_okrs/quarters.json '
"ListName": "Quarters",
"Description": "Quý",
"Columns": [
  { "Name": "Year", "Type": "Number", "Required": true },
  { "Name": "Quarter", "Type": "Choice", "Choices": ["Q1","Q2","Q3","Q4"] },
  { "Name": "StartDate", "Type": "DateTime" },
  { "Name": "EndDate", "Type": "DateTime" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/performance_okrs/okrs_objectives.json '
"ListName": "OKRS_Objectives",
"Description": "Mục tiêu OKR",
"Columns": [
  { "Name": "ObjectiveTitle", "Type": "Text", "Required": true },
  { "Name": "Owner", "Type": "User" },
  { "Name": "QuarterId", "Type": "Lookup",
    "Lookup": { "List": "Quarters", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "Description", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/performance_okrs/okrs_key_results.json '
"ListName": "OKRS_KeyResults",
"Description": "Kết quả then chốt OKR",
"Columns": [
  { "Name": "ObjectiveId", "Type": "Lookup",
    "Lookup": { "List": "OKRS_Objectives", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "KeyResultTitle", "Type": "Text", "Required": true },
  { "Name": "TargetValue", "Type": "Number" },
  { "Name": "CurrentValue", "Type": "Number" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/performance_okrs/measurables.json '
"ListName": "Measurables",
"Description": "Chỉ số đo lường",
"Columns": [
  { "Name": "MetricName", "Type": "Text", "Required": true },
  { "Name": "Unit", "Type": "Text" },
  { "Name": "Description", "Type": "Text" }
],
"ContentTypes": []
'

write_list datamodel/sharepoint/lists/performance_okrs/scorecard_data.json '
"ListName": "ScorecardData",
"Description": "Dữ liệu scorecard định kỳ",
"Columns": [
  { "Name": "MetricId", "Type": "Lookup",
    "Lookup": { "List": "Measurables", "Field": "ID", "Behavior": "restrict" } },
  { "Name": "PeriodType", "Type": "Choice", "Choices": ["Week","Month","Quarter","Year"] },
  { "Name": "PeriodKey", "Type": "Text" },
  { "Name": "Value", "Type": "Number" }
],
"ContentTypes": []
'

echo "✅ Scaffold hoàn tất cho repo ${REPO_NAME}"
echo "Next:"
echo "  1) git init && git add . && git commit -m 'chore: scaffold CCBA WAY'"
echo "  2) Push lên GitHub, bật Actions"
echo "  3) Hoàn thiện scripts apply/export và workflows ALM"