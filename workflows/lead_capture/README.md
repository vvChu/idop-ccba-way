# Lead Capture Workflow Implementation

## Tổng quan

Hệ thống Lead Capture tự động hóa việc thu thập và nuôi dưỡng khách hàng tiềm năng từ Microsoft Forms, tích hợp liền mạch với hệ thống CRM của CCBA.

## Kiến trúc hệ thống

```
Microsoft Forms → Power Automate → SharePoint Lists → Email Automation → CRM Integration
```

### Các thành phần chính:

1. **Microsoft Forms**: Thu thập thông tin leads từ website
2. **SharePoint Lists**: 
   - `Leads`: Lưu trữ thông tin leads
   - `LeadActivities`: Tracking mọi tương tác
   - `EmailTemplates`: Templates cho email automation
3. **Power Automate Workflows**:
   - Forms to SharePoint integration
   - Automated email follow-up sequence
   - Lead conversion workflow
4. **CRM Integration**: Tích hợp với `Customers` và `Opportunities`

## Cài đặt và triển khai

### Bước 1: Triển khai SharePoint Lists

```powershell
# Triển khai lists và cấu hình cơ bản
.\tools\scripts\deploy-lead-capture.ps1 -Environment Dev

# Kiểm tra dry run trước
.\tools\scripts\deploy-lead-capture.ps1 -Environment Dev -DryRun
```

### Bước 2: Cập nhật Taxonomy

Script sẽ tự động cập nhật `CCBA_NguonGocCoHoi` để thêm "Microsoft Forms" làm nguồn lead mới.

### Bước 3: Import Power Automate Workflows

1. **Forms to SharePoint Workflow**:
   - File: `workflows/lead_capture/forms-to-sharepoint-workflow.json`
   - Trigger: Microsoft Forms submission
   - Actions: Tạo lead, gửi notifications, welcome email

2. **Lead Follow-up Automation**:
   - File: `workflows/lead_capture/lead-followup-automation.json`
   - Trigger: Recurring (mỗi 6 giờ)
   - Actions: Gửi chuỗi email follow-up tự động

3. **Lead Conversion Workflow**:
   - File: `workflows/lead_capture/lead-conversion-workflow.json`
   - Trigger: Manual HTTP request
   - Actions: Convert lead thành customer/opportunity

### Bước 4: Cấu hình Microsoft Forms

1. Tạo form thu thập lead với các fields:
   - Họ tên (required)
   - Email (required)
   - Số điện thoại
   - Công ty
   - Chức vụ
   - Mô tả dự án
   - Ngân sách dự kiến
   - Thời gian triển khai
   - Loại dịch vụ quan tâm

2. Connect form với Power Automate workflow

## Quy trình hoạt động

### 1. Lead Capture Flow

```
Form Submission → Parse Data → Calculate Score → Assign Sales Rep → Create Lead → Send Notifications → Welcome Email
```

#### Lead Scoring Algorithm:
- Company information: +20 điểm
- Budget information: +15 điểm  
- Timeline information: +10 điểm
- Project description: +25 điểm
- Contact details completeness: +30 điểm

### 2. Follow-up Email Sequence

| Stage | Timing | Content Focus |
|-------|--------|---------------|
| Welcome | Immediately | Xác nhận nhận form, cam kết liên hệ 24h |
| First Follow | Day 1 | Giới thiệu giải pháp BIM, lợi ích tổng quát |
| Second Follow | Day 3 | Case study, kết quả cụ thể cho ngành |
| Third Follow | Day 7 | Tư vấn miễn phí, call-to-action mạnh |
| Final Follow | Day 14 | Lời chào cuối, để ngỏ contact tương lai |

### 3. Lead Conversion Process

Khi sales rep qualify lead:

1. **Manual trigger** conversion workflow với leadId
2. **Check existing customer** trong hệ thống
3. **Create/update customer** record
4. **Create opportunity** (optional)
5. **Update lead status** = "Converted"
6. **Log activity** và send notifications
7. **Stop follow-up sequence**

## Cấu hình môi trường

### Environment Variables

```json
{
  "FORMS_WEBHOOK_URL": "https://prod-xx.westus.logic.azure.com:443/workflows/...",
  "LEAD_ASSIGNMENT_RULES": {
    "BIM_Modeling": "bim-specialist@ccba.vn",
    "BIM_Coordination": "coordination-specialist@ccba.vn", 
    "default": "sales@ccba.vn"
  },
  "EMAIL_TEMPLATES_FOLDER": "EmailTemplates",
  "LEAD_SCORING_WEIGHTS": {
    "company": 20,
    "budget": 15,
    "timeline": 10,
    "description": 25,
    "contact_completeness": 30
  }
}
```

### Connection References

- **Microsoft Forms**: Form submissions trigger
- **SharePoint Online**: CRUD operations trên lists
- **Office 365 Outlook**: Email sending
- **HTTP**: Manual conversion triggers

## Monitoring và Analytics

### Key Metrics

1. **Lead Volume**: Số leads mới mỗi ngày/tuần/tháng
2. **Lead Quality**: Average lead score, distribution
3. **Email Performance**: Open rates, click rates, unsubscribe
4. **Conversion Rates**: Lead → Customer, Lead → Opportunity
5. **Sales Pipeline**: Value của converted opportunities

### Power BI Dashboard

Kết nối trực tiếp đến SharePoint lists để tracking:

- Lead funnel analysis
- Source effectiveness (Forms vs other channels)
- Email sequence performance
- Sales rep performance
- Conversion timeline analysis

## Bảo mật và Compliance

### GDPR/PDPA Compliance

1. **Consent tracking**: Lưu consent timestamp trong lead record
2. **Data retention**: Auto-archive leads sau 6 tháng không hoạt động
3. **Right to erasure**: Workflow để delete lead data theo yêu cầu
4. **Data portability**: Export lead data functionality

### Security Best Practices

1. **Email throttling**: Max 2 emails/week per lead
2. **Unsubscribe links**: Trong mọi marketing emails
3. **Access control**: Role-based permissions cho lead data
4. **Audit logging**: Full activity tracking trong LeadActivities

## Troubleshooting

### Common Issues

1. **Form not triggering workflow**:
   - Check webhook URL configuration
   - Verify Form connection permissions
   - Test with sample submission

2. **Email not sending**:
   - Check Office 365 connection
   - Verify email template syntax
   - Check recipient email validity

3. **Lead assignment not working**:
   - Verify user emails exist in directory
   - Check assignment rule configuration
   - Test with different service types

4. **Conversion workflow fails**:
   - Check customer lookup logic
   - Verify opportunity list permissions
   - Test with sample lead data

### Debug Steps

1. Check Power Automate run history
2. Review SharePoint list permissions
3. Validate taxonomy term GUIDs
4. Test email delivery to known addresses
5. Monitor API rate limits and throttling

## Maintenance

### Regular Tasks

1. **Weekly**: Review email performance metrics
2. **Monthly**: Update email templates based on performance
3. **Quarterly**: Review and adjust lead scoring weights
4. **Annually**: GDPR compliance audit và data cleanup

### Updates và Improvements

1. **A/B test email templates** để optimize conversion
2. **Lead scoring refinement** dựa trên historical data
3. **Assignment rule optimization** theo workload balancing
4. **Integration expansion** với other marketing channels

## Support

Để được hỗ trợ hoặc báo cáo issues:

1. Tạo issue trong repository với label `lead-capture`
2. Provide log details từ Power Automate run history
3. Include sample data (anonymized) nếu cần thiết
4. Tag relevant team members cho urgent issues