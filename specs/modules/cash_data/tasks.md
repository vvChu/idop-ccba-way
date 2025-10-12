# Backlog — Cash Data

## Spec & Design

- [ ] **Cập nhật spec.md theo Constitution + taxonomy requirements** (AC: reference đúng term sets)
  - Status: `done` - Group-level spec.md created với comprehensive requirements
  - Notes: Includes all sub-modules (Finance, Expenses, Allocations) và CCBA taxonomy integration

- [ ] **Cập nhật plan.md** (AC: taxonomy mapping rõ ràng)  
  - Status: `done` - Technical plan với detailed architecture và data model
  - Notes: Includes Managed Metadata mapping và security configuration

- [ ] **Review và alignment với sub-modules**
  - Status: `todo` - Ensure consistency với existing Finance, Expenses, Allocations specs
  - Artifacts: `specs/modules/cash_data/*/spec.md`
  - Estimation: 2 hours

## Datamodel & Taxonomy

- [ ] **Điều chỉnh lists/columns ở datamodel/sharepoint/lists/cash_data/** (AC: validate schema, diff OK)
  - Status: `todo` - Review existing JSON definitions
  - Artifacts: `datamodel/sharepoint/lists/cash_data/*.json`
  - Estimation: 4 hours

- [ ] **Validate taxonomy dependencies** (AC: IDs match SharePoint)
  - Status: `todo` - Check term sets trong `datamodel/sharepoint/taxonomy/`
  - Validation script: `tools/scripts/validate-taxonomy.ps1`
  - Estimation: 2 hours

- [ ] **Map Managed Metadata fields** (AC: fields reference đúng term set IDs từ JSON)
  - Status: `todo` - Update field definitions
  - Field mappings:
    - Field `Status` → `CCBA_TrangThaiChung` 
    - Field `Department` → `CCBA_DonViPhongBan`
    - Field `ExpenseType` → `CCBA_LoaiChiPhiPhanBo`
    - Field `Currency` → `CCBA_DongTien`
  - Estimation: 3 hours

## Taxonomy Validation

- [ ] **Pre-deployment check** (AC: script validation passes)
  - Status: `todo` - Verify all term sets exist on target environment
  - Script: Create validation PowerShell script
  - Dependencies: SharePoint admin credentials
  - Estimation: 2 hours

- [ ] **Post-deployment test** (AC: test data saves với correct terms)
  - Status: `todo` - Managed Metadata fields populate correctly
  - Test cases: Create, update, delete operations với taxonomy fields
  - Estimation: 3 hours

## SharePoint Lists Development

- [ ] **Deploy core Cash Data lists**
  - Status: `todo` - BankAccounts, FinancialPlans, InputInvoices, Vendors
  - Script: `tools/scripts/deploy-sp-lists-actual.ps1`
  - Environment: Development first, then Test
  - Estimation: 4 hours

- [ ] **Configure list permissions và content types**
  - Status: `todo` - Role-based access theo security matrix
  - Permissions: CFO, FinanceManager, Accountant, ProjectManager levels
  - Estimation: 3 hours

- [ ] **Setup list relationships và lookups**
  - Status: `todo` - Vendor → InputInvoices, Project → FinancialPlans
  - Validation: Referential integrity checks
  - Estimation: 2 hours

## Flows / Power Automate

- [ ] **Financial Planning Approval Flow**
  - Status: `todo` - End-to-end approval workflow
  - Triggers: New financial plan creation
  - Approvers: CFO, Finance Manager based on amount
  - Estimation: 6 hours

- [ ] **Expense Processing Flow** 
  - Status: `todo` - Expense submission to approval workflow
  - Integration: Invoice validation, budget checking
  - Notifications: Email alerts for approvals và rejections
  - Estimation: 8 hours

- [ ] **Budget Alert Flow**
  - Status: `todo` - Automated alerts when budget thresholds exceeded
  - Triggers: Expense submissions, allocation changes
  - Recipients: Project Managers, Finance team
  - Estimation: 4 hours

## Power BI & Reporting

- [ ] **Cash Flow Dashboard**
  - Status: `todo` - Real-time financial overview
  - Data sources: SharePoint lists, external ERP connections
  - Metrics: Budget vs Actual, Cash position, Expense trends
  - Estimation: 6 hours

- [ ] **Expense Analysis Reports**
  - Status: `todo` - Detailed expense breakdown và analysis
  - Filters: Department, Project, Time period, Expense type
  - Export capabilities: Excel, PDF formats
  - Estimation: 4 hours

- [ ] **Budget Allocation Tracking**
  - Status: `todo` - Budget utilization và allocation effectiveness
  - Visualizations: Allocation vs spend, Department comparisons
  - Estimation: 4 hours

## Security & Compliance

- [ ] **Implement role-based security model**
  - Status: `todo` - Configure SharePoint permissions per role
  - Roles: CFO, FinanceManager, Accountant, ProjectManager, Auditor
  - Validation: Access control testing
  - Estimation: 4 hours

- [ ] **Setup audit trail logging**
  - Status: `todo` - Comprehensive audit logs for compliance
  - Events: Create, Update, Delete, View operations
  - Retention: 7 years per financial regulations
  - Estimation: 3 hours

- [ ] **Data Loss Prevention configuration**
  - Status: `todo` - Protect sensitive financial data
  - Classifications: Financial reports, Budget information, Vendor data
  - Policies: External sharing restrictions, download controls
  - Estimation: 2 hours

## Integration & External Systems

- [ ] **ERP System Integration**
  - Status: `todo` - Bidirectional sync với external ERP
  - API: REST-based integration with error handling
  - Data: Chart of accounts, Vendor master, Financial transactions
  - Estimation: 8 hours

- [ ] **Banking API Integration**
  - Status: `todo` - Automated bank statement reconciliation
  - Security: Encrypted connections, certificate-based auth
  - Frequency: Daily automatic sync
  - Estimation: 6 hours

## Testing & Quality Assurance

- [ ] **Unit Testing**
  - Status: `todo` - Test individual components và data validation
  - Coverage: List operations, field validations, calculations
  - Framework: Pester for PowerShell, Jest for any JavaScript
  - Estimation: 8 hours

- [ ] **Integration Testing**
  - Status: `todo` - End-to-end workflow testing
  - Scenarios: Financial planning cycle, Expense approval, Budget allocation
  - Environment: Dedicated test environment với sample data
  - Estimation: 12 hours

- [ ] **User Acceptance Testing**
  - Status: `todo` - Business user validation
  - Participants: Finance team, Project managers, Accountants
  - Duration: 2 weeks UAT period
  - Estimation: 16 hours (coordination + fixes)

- [ ] **Performance Testing**
  - Status: `todo` - Load testing với large datasets
  - Scenarios: 1000+ transactions, 100 concurrent users
  - Metrics: Response times, throughput, error rates
  - Estimation: 6 hours

## Deployment & Go-Live

- [ ] **Production Deployment**
  - Status: `todo` - Deploy to production environment
  - Timing: Off-hours deployment window
  - Rollback plan: Database backup và configuration restore
  - Estimation: 4 hours

- [ ] **Production Validation**
  - Status: `todo` - Post-deployment smoke testing
  - Checklist: All lists accessible, Flows running, Reports loading
  - Sign-off: Business stakeholder approval
  - Estimation: 2 hours

- [ ] **User Training & Documentation**
  - Status: `todo` - End-user training sessions
  - Materials: User guides, Video tutorials, FAQ
  - Sessions: Role-based training for different user groups
  - Estimation: 8 hours

## Monitoring & Maintenance

- [ ] **Setup monitoring dashboards**
  - Status: `todo` - Operational monitoring cho system health
  - Metrics: System availability, Error rates, Performance KPIs
  - Alerts: Automated notifications for critical issues
  - Estimation: 4 hours

- [ ] **Establish maintenance procedures**
  - Status: `todo` - Regular maintenance schedules
  - Tasks: Data cleanup, Performance optimization, Security updates
  - Documentation: Runbooks for common maintenance tasks
  - Estimation: 3 hours

## Total Estimation
- **Development**: 89 hours
- **Testing**: 42 hours  
- **Deployment**: 17 hours
- **Total**: 148 hours (approximately 19 working days)

## Dependencies
- SharePoint admin access for list creation
- Power Platform premium licenses for advanced flows
- External system API credentials (ERP, Banking)
- Business stakeholder availability for UAT
- Security team approval for external integrations