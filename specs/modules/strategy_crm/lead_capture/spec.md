# Module: Lead Capture (Thu thập Khách hàng Tiềm năng)

## Mục tiêu
- Tự động thu thập và xử lý leads từ Microsoft Forms và các nguồn khác
- Tích hợp liền mạch với hệ thống CRM hiện tại của CCBA
- Thiết lập chuỗi email follow-up tự động để nuôi dưỡng leads
- Cung cấp tracking và báo cáo hiệu quả về lead conversion

## Phạm vi
- Thu thập thông tin leads từ Microsoft Forms
- Tự động tạo records trong SharePoint list "Leads"
- Phân công leads cho nhân viên kinh doanh phù hợp
- Thực hiện chuỗi email follow-up tự động theo lịch trình
- Theo dõi engagement và chuyển đổi từ lead sang opportunity
- Tích hợp với module CRM để chuyển đổi leads thành customers/opportunities

## User stories
- Là khách hàng tiềm năng, tôi muốn điền form liên hệ trên website và nhận được phản hồi nhanh chóng
- Là nhân viên marketing, tôi muốn tự động thu thập leads từ forms và phân loại chúng theo tiêu chí định sẵn
- Là nhân viên kinh doanh, tôi muốn nhận được thông báo về leads mới và có thông tin đầy đủ để liên hệ
- Là quản lý bán hàng, tôi muốn theo dõi hiệu quả của chuỗi email follow-up và tỷ lệ chuyển đổi
- Là lead, tôi muốn nhận được thông tin hữu ích về dịch vụ BIM qua email mà không bị spam

## Acceptance criteria
- Forms submission tự động tạo lead record trong SharePoint với đầy đủ thông tin
- Leads được phân loại và gắn tag taxonomy phù hợp (nguồn, ngành nghề, dịch vụ quan tâm)
- Nhân viên được assign tự động dựa trên tiêu chí (ngành nghề, địa lý, workload)
- Email welcome gửi trong vòng 5 phút sau khi submit form
- Chuỗi follow-up emails gửi theo lịch trình: Day 1, Day 3, Day 7, Day 14
- Lead scoring tự động dựa trên engagement (email opens, clicks, form completeness)
- Conversion tracking từ lead sang opportunity/customer với metrics báo cáo
- Integration với existing CRM workflow mà không gây gián đoạn

## Quy trình & BPMN
- **Form Submission Flow**: Điền form → Validate → Tạo lead → Assign → Notify → Welcome email
- **Follow-up Flow**: Email Day 1 → Track engagement → Email Day 3 → ... → Manual handoff
- **Conversion Flow**: Qualify lead → Create opportunity → Convert to customer → Update tracking
- BPMN: Xem diagrams/LeadCapture-workflow.bpmn, diagrams/LeadCapture-followup.bpmn

## Ràng buộc & chỉ dẫn đặc thù
- **Privacy compliance**: Tuân thủ GDPR/PDPA cho việc thu thập và xử lý thông tin cá nhân
- **Lead assignment**: Round-robin hoặc dựa trên expertise matching (ngành/dịch vụ)
- **Email throttling**: Không quá 2 emails/tuần cho mỗi lead để tránh spam
- **Data retention**: Leads không có hoạt động trong 6 tháng sẽ được archive
- **Integration points**: Phải sync với Opportunities, Customers lists trong CRM
- **Scoring algorithm**: Weighted scoring dựa trên form completeness, engagement, company size
- **Audit trail**: Log đầy đủ mọi action cho compliance và analytics