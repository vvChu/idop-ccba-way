# Kế hoạch kỹ thuật — Cash Data

## Kiến trúc

### Tổng quan kiến trúc
- **Layer 1**: SharePoint Lists làm data storage layer
- **Layer 2**: Power Automate flows cho business logic và workflows
- **Layer 3**: Power Apps cho user interface (nếu cần)
- **Layer 4**: Power BI cho reporting và analytics

### Module composition
- **Finance Module**: Core financial management functionality
- **Expenses Module**: Expense tracking và approval workflows  
- **Allocations Module**: Budget allocation và resource distribution

### Integration points
- SharePoint REST API cho data access
- Microsoft Graph API cho user và permission management
- Power Platform Connectors cho external systems
- Managed Metadata Service cho taxonomy consistency

## Data model

### Core SharePoint Lists

#### Cash Data Group Level
- **BankAccounts**: Quản lý thông tin tài khoản ngân hàng
- **FinancialPlans**: Kế hoạch tài chính tổng thể
- **InputInvoices**: Hóa đơn đầu vào và vendor management
- **Vendors**: Thông tin nhà cung cấp

#### Sub-module Data Dependencies
- Finance: FinancialPlans, BankAccounts
- Expenses: InputInvoices, Vendors, ExpenseChecklists  
- Allocations: AllocationRules, BudgetAllocations

### Schema validation
- Sử dụng JSON Schema trong `datamodel/sharepoint/schemas/sp-list.schema.json`
- Validation rules cho data integrity
- Required fields và data types được enforced

### Managed Metadata Integration
```json
{
  "TermSets": [
    "CCBA_LoaiChiPhiPhanBo",
    "CCBA_DonViPhongBan", 
    "CCBA_TrangThaiChung",
    "CCBA_DongTien"
  ],
  "MappedFields": {
    "ExpenseType": "CCBA_LoaiChiPhiPhanBo",
    "Department": "CCBA_DonViPhongBan",
    "Status": "CCBA_TrangThaiChung", 
    "Currency": "CCBA_DongTien"
  }
}
```

## Flows

### Core Business Flows

#### Financial Planning Flow
1. **Trigger**: Tạo mới dự án hoặc fiscal year planning
2. **Process**: 
   - Validate budget parameters
   - Create financial plan record
   - Initialize budget allocations
   - Send for approval workflow
3. **Output**: Approved financial plan với initial allocations

#### Expense Approval Flow
1. **Trigger**: New expense submission hoặc invoice upload
2. **Process**:
   - Validate expense data và supporting documents
   - Check budget availability
   - Route for appropriate approvals
   - Update financial records
3. **Output**: Approved expense với updated budget tracking

#### Budget Allocation Flow
1. **Trigger**: Financial plan approval hoặc budget reallocation request
2. **Process**:
   - Validate allocation parameters
   - Check total allocation constraints
   - Update allocation records
   - Notify stakeholders
3. **Output**: Updated budget allocations với audit trail

### Power Automate Workflows
- **Financial-Planning-Approval**: Approval workflow cho financial plans
- **Expense-Processing**: End-to-end expense processing
- **Budget-Alert**: Notifications khi vượt ngưỡng budget
- **Invoice-Validation**: Automatic validation cho input invoices

## Env & security

### Environment Configuration
```yaml
Development:
  SharePointUrl: ${DEV_SHAREPOINT_URL}
  TenantId: ${DEV_TENANT_ID}
  EnvironmentId: ${DEV_ENVIRONMENT_ID}

Test:
  SharePointUrl: ${TEST_SHAREPOINT_URL}
  TenantId: ${TEST_TENANT_ID}
  EnvironmentId: ${TEST_ENVIRONMENT_ID}

Production:
  SharePointUrl: ${PROD_SHAREPOINT_URL}
  TenantId: ${PROD_TENANT_ID}
  EnvironmentId: ${PROD_ENVIRONMENT_ID}
```

### Security Model
- **Data Loss Prevention**: Sensitive financial data classification
- **Conditional Access**: Multi-factor authentication cho financial operations
- **Information Rights Management**: Document protection cho financial reports
- **Audit Logging**: Full audit trail cho compliance requirements

### Permissions Matrix
```yaml
CFO:
  - FullControl on all financial data
  - Approve high-value expenses
  - Access to all reports

FinanceManager:
  - Edit financial plans và budget allocations
  - Approve medium-value expenses
  - Access to department reports

Accountant:
  - Edit expense records và input invoices
  - View budget allocations
  - Create financial reports

ProjectManager:
  - Submit expense requests
  - View project budget status
  - Read-only access to allocations

Auditor:
  - Read-only access to all financial data
  - Full access to audit trails
  - Export capabilities for compliance
```

## Tích hợp & cấu hình đặc thù

### SharePoint List Deployment
- Lists được deploy qua PowerShell scripts trong `tools/scripts/deploy-sp-lists-actual.ps1`
- Content types và columns được định nghĩa trong JSON files
- Managed Metadata fields require term set IDs từ taxonomy sync

### Power Platform Integration
- **Connection References**: 
  - SharePoint connector với service account credentials
  - Office 365 Users connector cho approval routing
  - Microsoft Dataverse connector (nếu cần advanced logic)

### External System Connections
- **ERP Integration**: REST API calls cho synchronization
- **Banking API**: Secure connection cho bank account reconciliation
- **Document Management**: SharePoint Document Libraries cho supporting documents

### Error Handling & Monitoring
```powershell
# Monitoring script example
$ErrorActionPreference = "Stop"
try {
    # Financial data validation
    Invoke-RestMethod -Uri $SharePointApiUrl -Method GET
    Write-Host "✅ SharePoint connectivity OK"
} catch {
    Write-Host "❌ SharePoint connection failed: $($_.Exception.Message)"
    # Send alert to admin
}
```

### Data Validation Rules
- **Budget Constraints**: Total allocations <= 100% của approved budget
- **Expense Limits**: Individual expenses within department limits
- **Invoice Validation**: Required fields và duplicate detection
- **Currency Consistency**: Same currency within project scope

### Backup & Recovery
- **Data Backup**: Automated SharePoint list backup qua PowerShell
- **Version History**: SharePoint native versioning enabled
- **Audit Trail**: Immutable logs trong dedicated audit list
- **Disaster Recovery**: Cross-region replication cho critical financial data

## Triển khai & kiểm thử

### Deployment Pipeline
1. **Pre-deployment**: Validate JSON schemas và PowerShell syntax
2. **SharePoint Lists**: Deploy lists với proper permissions
3. **Managed Metadata**: Sync taxonomy term sets
4. **Power Automate**: Deploy flows với connection references
5. **Power BI**: Publish reports và setup data refresh
6. **Post-deployment**: Validate data connectivity và permissions

### Testing Strategy
- **Unit Tests**: Individual list operations và data validation
- **Integration Tests**: End-to-end workflows qua Power Automate
- **User Acceptance Testing**: Business scenarios với real data
- **Performance Testing**: Large dataset operations và concurrent users
- **Security Testing**: Permission validation và data access controls

### Monitoring & Maintenance
- **Health Checks**: Daily validation của core functionality
- **Performance Metrics**: Response times và error rates
- **Audit Reviews**: Monthly compliance checks
- **Data Quality**: Regular validation của financial data integrity