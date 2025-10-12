# Kế hoạch kỹ thuật — Lead Capture

## Kiến trúc
- Microsoft Forms làm front-end thu thập dữ liệu từ website/landing pages
- Power Automate trigger từ Forms submissions để xử lý và route data
- SharePoint Lists làm backend lưu trữ leads và tracking data
- Power Automate flows cho email automation và lead nurturing
- Tích hợp với existing CRM module (Opportunities, Customers, Contacts)
- Power BI dashboard cho analytics và conversion reporting

## Data model
- **Leads list**: Lưu trữ thông tin leads từ forms với scoring và tracking fields
- **Lead Activities**: Log mọi interaction (emails sent, opens, clicks, calls)
- **Email Templates**: Chuẩn hóa nội dung emails cho follow-up sequence
- **Lead Assignment Rules**: Quy tắc phân công leads dựa trên criteria
- Liên kết lookup với Opportunities, Customers khi conversion xảy ra
- Reference đúng taxonomy terms từ `CCBA_NguonGocCoHoi`, `CCBA_LoaiHinhDichVu`, `CCBA_NganhLinhVuc`

## Flows
### 1. Form to Lead Flow (Primary)
- **Trigger**: Microsoft Forms submission
- **Actions**: 
  - Parse form data và map to Leads list columns
  - Set Source = "Microsoft Forms" từ taxonomy
  - Calculate initial lead score based on form completeness
  - Assign lead to sales rep based on industry/service type
  - Send notification to assigned rep
  - Send welcome email to lead
  - Schedule follow-up sequence

### 2. Lead Nurturing Flow (Recurring)
- **Trigger**: Scheduled/recurrence based on FollowUpSequenceStage
- **Actions**:
  - Check lead status (không gửi nếu đã converted/lost)
  - Send appropriate email template based on stage
  - Update FollowUpSequenceStage và EmailsSent counter
  - Track email delivery status
  - Schedule next email in sequence
  - Update lead score based on engagement

### 3. Lead Conversion Flow (Manual trigger)
- **Trigger**: Manual action từ sales rep khi qualify lead
- **Actions**:
  - Create Opportunity record từ lead data
  - Optionally create Customer record nếu chưa exist
  - Update lead status to "Converted"
  - Link lead to created opportunity/customer
  - Stop follow-up email sequence
  - Send notification về conversion

### 4. Lead Scoring & Assignment Flow
- **Trigger**: Lead creation hoặc activity update
- **Actions**:
  - Calculate/recalculate lead score dựa trên weighted criteria
  - Reassign nếu score thay đổi significantly
  - Update priority level trong taxonomy
  - Trigger additional actions cho high-score leads

## Env & security
- **Environment variables**: 
  - `FORMS_WEBHOOK_URL`: URL để nhận Forms submissions
  - `LEAD_ASSIGNMENT_RULES`: JSON config cho assignment logic
  - `EMAIL_TEMPLATES_FOLDER`: Location của email templates
  - `LEAD_SCORING_WEIGHTS`: Weights cho scoring algorithm
- **Connection references**:
  - SharePoint connection cho CRUD operations
  - Office 365 Outlook cho email sending
  - Microsoft Forms connector
- **Permissions**:
  - Forms: Public access cho submissions
  - SharePoint: Sales team có Edit cho Leads list
  - Email: Service account có Send As permission
  - Power Automate: Run với elevated permissions cho automation

## Tích hợp & cấu hình đặc thù
- **Forms integration**: Setup webhook/connector từ Forms to Power Automate
- **Email templates**: HTML templates stored trong SharePoint document library
- **Lead scoring**: Configurable weights via environment variables
- **Assignment rules**: JSON-based rules engine cho lead distribution
- **CRM integration**: Lookup fields linking to existing CRM lists
- **Analytics**: Power BI connected to Leads và Lead Activities lists
- **GDPR compliance**: Consent tracking và data retention policies
- **Error handling**: Comprehensive error logging và retry mechanisms

## Triển khai & kiểm thử
### Scripts
- `deploy-lead-capture-lists.ps1`: Tạo Leads list và related lists
- `setup-lead-capture-flows.ps1`: Import và configure Power Automate flows
- `test-lead-capture-workflow.ps1`: End-to-end testing với sample data

### Validation steps
1. **Schema validation**: Validate Leads list definition against schema
2. **Taxonomy validation**: Ensure all ManagedMetadata terms exist trong term store
3. **Flow validation**: Test Forms submission end-to-end
4. **Email validation**: Test email templates và delivery
5. **Integration validation**: Test conversion từ Lead to Opportunity
6. **Performance validation**: Test với volume submissions

### Test scenarios
- Single form submission với complete data
- Bulk form submissions để test assignment distribution
- Email sequence testing với different engagement scenarios
- Lead conversion testing cho different score ranges
- Error scenarios (invalid data, email failures, assignment failures)
- GDPR scenarios (consent withdrawal, data deletion requests)

### Success criteria
- Form submissions tạo lead records trong <2 minutes
- Welcome emails delivered trong <5 minutes
- Lead assignment balanced theo configured rules
- Email sequence delivers theo schedule ±10%
- Lead scoring calculation accurate và consistent
- Conversion workflow creates proper Opportunity/Customer records
- No data loss during error scenarios
- Performance acceptable với >100 submissions/day