# Microsoft Forms Setup Guide

## Form Structure cho Lead Capture

### Form Title: "Liên hệ tư vấn dịch vụ BIM - CCBA"

### Form Description:
"Chia sẻ thông tin dự án của bạn để nhận được tư vấn BIM chuyên nghiệp từ đội ngũ CCBA. Chúng tôi sẽ liên hệ trong vòng 24 giờ."

### Form Fields:

#### 1. Thông tin liên hệ (Required Section)

**Họ và tên** (Text - Required)
- Question: "Họ và tên của bạn"
- Description: "Tên đầy đủ để chúng tôi có thể xưng hô"

**Email** (Text - Required)
- Question: "Địa chỉ email"
- Description: "Email chính để chúng tôi liên hệ và gửi thông tin"
- Validation: Email format

**Số điện thoại** (Text - Optional)
- Question: "Số điện thoại liên hệ"
- Description: "Số điện thoại để liên hệ nhanh khi cần thiết"

#### 2. Thông tin công ty (Optional Section)

**Tên công ty/tổ chức** (Text - Optional)
- Question: "Tên công ty hoặc tổ chức"
- Description: "Nếu bạn đại diện cho một công ty"

**Chức vụ** (Text - Optional)
- Question: "Chức vụ của bạn"
- Description: "Vị trí công việc hiện tại"

**Ngành nghề** (Choice - Optional)
- Question: "Ngành nghề của công ty"
- Options:
  - Xây dựng dân dụng
  - Xây dựng công nghiệp
  - Hạ tầng giao thông
  - Kiến trúc và thiết kế
  - Tư vấn kỹ thuật
  - Khác

#### 3. Thông tin dự án (Project Details)

**Mô tả dự án** (Long text - Required)
- Question: "Mô tả chi tiết về dự án"
- Description: "Chia sẻ thông tin về dự án bạn đang có để chúng tôi hiểu rõ nhu cầu"

**Loại dịch vụ BIM quan tâm** (Choice - Multiple selection)
- Question: "Dịch vụ BIM nào bạn quan tâm?"
- Options:
  - BIM Modeling (3D Model)
  - BIM Coordination (Clash Detection)
  - 4D Planning (Schedule Integration) 
  - 5D Cost Management
  - 6D Facility Management
  - BIM Training & Consulting
  - Khác

**Ngân sách dự kiến** (Choice - Optional)
- Question: "Ngân sách dự kiến cho dịch vụ BIM"
- Options:
  - Dưới 100 triệu VND
  - 100-500 triệu VND
  - 500 triệu - 1 tỷ VND
  - Trên 1 tỷ VND
  - Chưa xác định

**Thời gian triển khai** (Choice - Optional)
- Question: "Thời gian mong muốn bắt đầu dự án"
- Options:
  - Ngay lập tức (trong 1 tháng)
  - 1-3 tháng tới
  - 3-6 tháng tới
  - Sau 6 tháng
  - Chưa xác định

#### 4. Thêm thông tin (Optional)

**Ghi chú thêm** (Long text - Optional)
- Question: "Có điều gì khác bạn muốn chia sẻ?"
- Description: "Yêu cầu đặc biệt, câu hỏi, hoặc thông tin khác"

**Đã từng sử dụng BIM?** (Choice - Optional)
- Question: "Công ty bạn đã có kinh nghiệm với BIM chưa?"
- Options:
  - Chưa từng sử dụng
  - Đã sử dụng cơ bản
  - Có kinh nghiệm nhưng cần hỗ trợ
  - Có team BIM riêng

### Form Settings

#### Privacy & Response Options:
- ✅ Anyone can respond
- ✅ Record name (để tracking)
- ✅ One response per person
- ✅ Show progress bar

#### Notifications:
- ✅ Get email notification of each response
- Email: sales@ccba.vn

#### Customization:
- Theme: Corporate Blue (#0066cc)
- Logo: CCBA company logo
- Header image: BIM visualization sample

## Power Automate Connection Setup

### Step 1: Create Connection

1. Go to Power Automate > Connections
2. Create new Microsoft Forms connection
3. Authorize with Forms access permissions

### Step 2: Get Form ID

1. Open your form in Microsoft Forms
2. Click "Share" > "Get a link to collaborate"
3. Copy the form ID from URL: `https://forms.office.com/Pages/DesignPage.aspx?FormId={FORM_ID}`

### Step 3: Configure Workflow

1. Import `forms-to-sharepoint-workflow.json`
2. Replace `{your-form-id}` với actual form ID
3. Update connection references:
   - Microsoft Forms connection
   - SharePoint Online connection  
   - Office 365 Outlook connection
4. Set environment parameters:
   - SiteUrl: Your SharePoint site URL

### Step 4: Field Mapping

Update workflow để map form fields với SharePoint columns:

```json
{
  "LeadName": "@variables('FormData')?['answers']?['fullName']",
  "Email": "@variables('FormData')?['answers']?['email']",
  "Phone": "@variables('FormData')?['answers']?['phone']",
  "Company": "@variables('FormData')?['answers']?['company']",
  "Position": "@variables('FormData')?['answers']?['position']",
  "ProjectDescription": "@variables('FormData')?['answers']?['description']",
  "Budget": "@variables('FormData')?['answers']?['budget']",
  "Timeline": "@variables('FormData')?['answers']?['timeline']"
}
```

## Testing Checklist

### Form Testing:
- [ ] Form loads correctly on desktop và mobile
- [ ] All required fields validation works
- [ ] Optional fields can be skipped
- [ ] Submit button works
- [ ] Thank you message displays

### Integration Testing:
- [ ] Form submission triggers Power Automate
- [ ] Lead record created trong SharePoint
- [ ] Welcome email sent to submitter
- [ ] Notification email sent to sales rep
- [ ] Lead scoring calculated correctly
- [ ] Assignment rules work properly

### Email Testing:
- [ ] Welcome email template renders correctly
- [ ] Follow-up sequence triggers on schedule
- [ ] Email content personalizes with lead data
- [ ] Unsubscribe links work
- [ ] Email delivery tracking works

## Production Deployment

### Pre-deployment:
1. Test form với sample data
2. Verify all workflows import successfully
3. Check email templates và branding
4. Validate lead assignment rules
5. Test conversion workflow

### Go-live:
1. Update website với form embed code
2. Set up monitoring alerts
3. Train sales team on new lead process
4. Monitor first few submissions closely

### Post-deployment:
1. Weekly performance review
2. A/B test email templates
3. Adjust lead scoring based on conversion data
4. Optimize assignment rules for load balancing