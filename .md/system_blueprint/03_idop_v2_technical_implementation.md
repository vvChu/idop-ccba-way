
# 📘 FILE 3/4 - YÊU CẦU KỸ THUẬT VÀ TRIỂN KHAI IDOP v2.0

Tài liệu: Mô tả Kiến trúc và Yêu cầu Thiết kế Hệ thống IDOPPhần: XII - XIV (Yêu cầu kỹ thuật và Triển khai)Phiên bản: 2.0Ngày: 27/06/2026Đơn vị: CCBA - Trung tâm Tư vấn và Ứng dụng BIM trong Xây dựng



## 🔗 BỘ TÀI LIỆU LIÊN QUAN

File

Tên

Phạm vi

FILE 1/4

Kiến trúc tổng quan

Phần I-VIII

FILE 2/4

Vận hành và Tài chính

Phần IX-XI

FILE 3/4

Yêu cầu kỹ thuật và Triển khai

Phần XII-XIV (file này)

FILE 4/4

Enterprise Architecture

Khung mở rộng cấp Viện



## MỤC LỤC FILE 3

1     PHẦN XII.  YÊU CẦU THIẾT KẾ HỆ THỐNG CHI TIẾT

2     PHẦN XIII. LỘ TRÌNH TRIỂN KHAI

3     PHẦN XIV.  PHỤ LỤC

4     PHỤ LỤC.   CROSS-REFERENCE ĐẾN FILE 4

5     TRANG PHÊ DUYỆT BAN HÀNH



# PHẦN XII. YÊU CẦU THIẾT KẾ HỆ THỐNG CHI TIẾT


## 12.1. Yêu cầu nghiệp vụ tích hợp


### 12.1.1. Quản lý CRM

Quản lý khách hàng, đối tác, người liên hệ

Pipeline cơ hội kinh doanh

Báo giá, hồ sơ thầu

Copilot OCR danh thiếp, parse email mời thầu

Cảnh báo cơ hội đến hạn

Báo cáo conversion rate


### 12.1.2. Quản lý hợp đồng

Quản lý HĐ với phân loại theo Nhóm

Auto-phân bổ kinh phí theo Phụ lục 7

Auto-tính tỷ lệ Cột 3, 4, 5, 6, 7

Quản lý kế hoạch tạm ứng, thanh toán

Theo dõi công nợ, dòng tiền

Cảnh báo SLA, deadline 30 ngày


### 12.1.3. Quản lý dự án

PMO + CDE theo ISO 19650

Task management

5 cấp QA/QC trên IDOP

Risk, Issue, Lessons Learned

Integration với BIM tools

Mobile app cho hiện trường


### 12.1.4. Quản lý tài chính (CẬP NHẬT)

3 tầng phân bổ tự động

Tạm ứng tối đa 90% (cập nhật từ 70%)

Hoàn thuế GTGT 80%/100%

Auto-validate định mức Phụ lục 7-8

Định mức phụ cấp tự động

Quản lý 5 quỹ

Khấu trừ TNCN tự động

Thanh toán không TM ≥ 5tr

Clawback 12 tháng

Báo cáo P&L theo định mức


### 12.1.5. Quản lý phê duyệt

5 cấp QA/QC trên CDE

Trình ký E-Approval

4 luồng PGV (A/B/C/D)

7 bước vận hành full

Audit trail toàn diện


### 12.1.6. Quản lý KPI/Scorecard

KPI theo phòng + cá nhân

OKRs Quý + Năm

Real-time update

Friday 17:00 snapshot

Visual xanh/đỏ

Ảnh hưởng TNTT

💡 Mở rộng FILE 4: Module KH&CN Management với 7 sub-modules (Proposal, Contract, Assignment, Execution, Acceptance, IP, Incentive) - xem FILE 4 Phần 4.


## 12.2. Yêu cầu kỹ thuật

Nền tảng: Microsoft 365 + SharePoint Online + Power Platform + Copilot

Phát triển: Configuration over Customization

UI: Responsive, đa thiết bị

Hiệu năng: <2s/page, >99.5% uptime

Bảo mật: MFA, Conditional Access, encryption

Tích hợp: API, webhook, BIM tools, Viện

Backup: Daily, 30 ngày retention


## 12.3. Yêu cầu phi chức năng

Tiêu chí

Yêu cầu

Availability

≥ 99.5%

Performance

< 2s/page

Scalability

>150 users, >100 projects/năm

Security

MFA + encryption

Compliance

ISO 9001, ISO 19650, 3 quy chế

Audit

Mọi thao tác có log, lưu 7 năm

Backup

RPO ≤ 24h, RTO ≤ 4h

Mobile

iOS/Android

Localization

Tiếng Việt

Accessibility

WCAG 2.1 AA


## 12.4. Yêu cầu tích hợp

Microsoft 365 (Teams, Outlook, OneDrive, Planner)

BIM Tools (Revit, Navisworks)

Hệ thống kế toán

Hệ thống Viện IBST (KHKT, TCKT, TCHC) qua API

E-Sign / Chữ ký số

CSDL doanh nghiệp quốc gia

Partner systems

💡 Mở rộng FILE 4: Bổ sung tích hợp với Bộ Xây dựng, Bộ KH&CN, CSDL nhiệm vụ KH&CN quốc gia, hệ thống tạp chí khoa học - xem FILE 4 Phần 5.


## 12.5. Yêu cầu Copilot/AI

OCR danh thiếp → CRM

Parse email mời thầu → Opportunity

Phân loại tài liệu tự động

Gợi ý metadata

Tóm tắt KPI, cảnh báo bất thường

Trợ lý tra cứu quy chế

Hỗ trợ điền form thông minh

Risk prediction


## 12.6. Danh mục Power Automate Flows (40+)


### Core Flows (Bước 1-7)

1     Flow_Lead_Opportunity_Intake

2     Flow_Bidding_Quotation_Approval

3     Flow_Contract_Drafting

4     Flow_Contract_ApprovalRouting (theo loại HĐ)

5     Flow_Contract_SigningTrack

6     Flow_Contract_AutoDistribution

7     Flow_Contract_StorageReminder (30 ngày)

8     Flow_PGV_Route_TypeA/B/C/D

9     Flow_PGV_Validate_Certifications

10     Flow_PGV_Validate_CTV

11     Flow_PGV_AutoAllocate_Bang1

12     Flow_PGV_CreateProjectSite

13     Flow_PGV_CreateCDESite

14     Flow_Task_Assignment_Execution

15     Flow_Timesheet_Progress_Update

16     Flow_QA_Level1A_to_5

17     Flow_Document_State_Transition (WIP→Shared→Published)

18     Flow_Expense_Advance_Request

19     Flow_Invoice_Payment_Process

20     Flow_Cashflow_Debt_Control

21     Flow_KPI_Scorecard_Update

22     Flow_Closure_Archive


### Financial Flows (Tích hợp QCCTNB 3209)

1     Flow_AutoAllocate_PL7_QCCTNB (MỚI)

2     Flow_Validate_NhanCong_PL8 (MỚI)

3     Flow_TamUng_90Percent (MỚI)

4     Flow_PaymentMethod_Validate (≥5tr) (MỚI)

5     Flow_VAT_Refund_Tracking (80%/100%) (MỚI)

6     Flow_Allowance_AutoCheck (MỚI)

7     Flow_Calculate_TaxTNCN (MỚI)

8     Flow_Fund_Allocation (MỚI)

9     Flow_TK141_Tracking (MỚI)

10     Flow_Clawback_Monitoring (12 tháng) (MỚI)

11     Flow_AutoCalc_P2_KhoiTrucTiep (MỚI)

12     Flow_AutoCalc_P2GT_KhoiGianTiep (MỚI)

13     Flow_HCM_8020_Allocation (MỚI)


### AI/Copilot Flows

1     Flow_AI_OCR_Namecard (MỚI)

2     Flow_AI_Email_Tender_Parser (MỚI)

3     Flow_AI_Document_Classification (MỚI)

4     Flow_AI_Risk_Prediction (MỚI)

5     Flow_AI_KPI_Insights (MỚI)

💡 Mở rộng FILE 4: Bổ sung 8 KH&CN Flows (Proposal, Council, IP, Incentive...) - xem FILE 4 Phần 4.3.


## 12.7. Validation Rules quan trọng


### FINANCIAL VALIDATION

Tạm ứng ≤ 90% giao chủ trì/đơn vị

Mua ≥ 5tr → BẮT BUỘC chuyển khoản

Cột 3 + Cột 4 = Cột 5 (theo Phụ lục 7)

Hoàn thuế GTGT ≤ 80% trước quyết toán

Nhân công ≤ giới hạn Phụ lục 8

Định mức công tác phí ≤ Phụ lục 1-2


### COMPLIANCE VALIDATION

Chủ trì có chứng chỉ hành nghề

CTV ngoài có HĐ giao khoán

HĐLĐ ≥ 1 tháng → BHXH

CTV ngoài ≥ 2tr/lần → khấu trừ 10% TNCN

HĐ lưu trữ ≤ 30 ngày

KHKT thẩm tra ≤ 1 ngày


### PROCESS VALIDATION

5 cấp QA/QC trước Published

PGV phê duyệt trước triển khai

Tổng tỷ lệ phân chia = 100%

Nghiệm thu trên IDOP + Tiền về

KPI 0.8-1.2 áp dụng quyết toán



# PHẦN XIII. LỘ TRÌNH TRIỂN KHAI


## 13.1. Phương pháp luận: CCBA Hybrid Workflow

Spec-Driven Planning - Lập kế hoạch theo đặc tả

Coding Modularization - Mô-đun hóa code

AI-Enhanced Collaboration - Cộng tác hỗ trợ bởi AI

Decentralized Deployment - Triển khai phi tập trung

Transparent Logging & Feedback - Log minh bạch và phản hồi


## 13.2. Sáu giai đoạn triển khai


### Giai đoạn 0 - Thiết lập nền tảng (1 tháng)

DEV/UAT/PROD environments

Entra ID Groups

Term Store enterprise

Hub & Spoke

Naming convention


### Giai đoạn 1 - Script hóa & Phiên bản hóa (1 tháng)

Infrastructure as Code (PnP PowerShell)

33 List schemas

Content Types

Permission baseline

Site provisioning templates


### Giai đoạn 2 - Pipeline CI/CD (1 tháng)

DEV → UAT → PROD pipeline

Automated testing

Approval gates

Rollback strategy


### Giai đoạn 3 - Cấu hình Tài chính theo QCCTNB (MỚI - 1 tháng)

Cấu hình Phụ lục 7 (Bảng định mức)

Cấu hình Phụ lục 8 (Tỷ lệ nhân công)

Tạm ứng 90% (cập nhật từ 70%)

Định mức công tác phí, hội họp

Hoàn thuế GTGT 80%/100%

Thanh toán không TM

Quản lý quỹ

Khấu trừ TNCN

Auto-calc P2 + P2_GT

TK141 tracking


### Giai đoạn 4 - Thí điểm (2 tháng)

Pilot: Phòng BIM Dự án + Phòng Tổng hợp

2-3 dự án thí điểm

Vận hành thử nghiệm

Thu thập phản hồi


### Giai đoạn 5 - Triển khai diện rộng (3 tháng)

5 phòng + 3 vị trí chuyên trách

Triển khai TP.HCM (cơ chế 80/20)

Tích hợp Viện IBST

Đào tạo toàn diện

Go-live chính thức


### Giai đoạn 6 - Duy trì và phát triển (liên tục)

Vận hành ổn định

Nâng cấp tính năng

AI/Automation mới

Cải tiến vòng lặp EOS


## 13.3. Roadmap tổng

Tháng

Giai đoạn

Nội dung

1

GĐ 0

Thiết lập nền tảng

2

GĐ 1

Script hóa & Phiên bản hóa

3

GĐ 2

CI/CD Pipeline

4

GĐ 3

Cấu hình Tài chính (MỚI)

5-6

GĐ 4

Thí điểm

7-9

GĐ 5

Triển khai diện rộng

10+

GĐ 6

Vận hành & cải tiến

💡 Mở rộng FILE 4: Roadmap v2.1 → v4.0 với 4 giai đoạn Enterprise (KH&CN, IBST, Enterprise Platform, AI-driven) - xem FILE 4 Phần 6.


## 13.4. Đội ngũ triển khai


### Ban Chỉ đạo IDOP

Sponsor: Giám đốc CCBA

Co-Sponsor: Phó Giám đốc

Cố vấn: Pháp lý, TC & QLCL

Lead: Phụ trách Nền tảng Số

Members: 5 Trưởng phòng


### Đội kỹ thuật

SharePoint Architect

Power Platform Developer

BIM/CDE Specialist

Security Engineer

Data Analyst

Finance Configuration Specialist (MỚI)


### Đội triển khai

Business Analyst

Trainer

Change Manager

Helpdesk


## 13.5. Rủi ro và biện pháp

Rủi ro

Mức độ

Biện pháp

Kháng cự thay đổi

Cao

Change management, training, leadership

Di trú dữ liệu phức tạp

Trung bình

ETL pipeline, testing kỹ

Bảo mật dữ liệu

Cao

MFA, DLP, audit log

Tích hợp BIM phức tạp

Trung bình

POC trước khi triển khai

Thiếu nhân lực

Trung bình

Đào tạo nội bộ + tư vấn ngoài

Sai cấu hình tài chính (MỚI)

Cao

Pilot tài chính, validation 2 tầng

Vi phạm định mức (MỚI)

Cao

Auto-block, dashboard cảnh báo



# PHẦN XIV. PHỤ LỤC


## Phụ lục A. Sơ đồ kiến trúc tổng thể

1     LỚP 1: Experience Layer - 7 nhóm người dùng

2        ↓

3     LỚP 2: Access Channels - Teams/SP/Apps/Outlook/PBI/Copilot/Mobile

4        ↓

5     LỚP 3: Site Architecture - Hub & Spoke

6        ├── IBST - CCBA Hub Site

7        ├── Corporate Hub

8        ├── IDOP Operations Hub

9        └── Project Hub & CDE

10        ↓

11     LỚP 4: Data Layer - 33 Lists + Libraries + CDE

12        ↓

13     LỚP 5: Taxonomy - Term Store enterprise

14        ↓

15     LỚP 6: Process Layer - 40+ Flows + Apps + BI + Copilot

16        ↓

17     LỚP 7: Integration - M365 + BIM + Viện + APIs

18        ↓

19     LỚP 8: Security - Entra + Permission + Audit + Lifecycle


## Phụ lục B. Mapping 3 Quy chế

Quy chế

Phụ lục

Nội dung

Tích hợp IDOP

QCTK 2815

Bảng 1

Phân bổ kinh phí

Tầng 1 - Auto-calc

QCTK 2815

Điều 7

PGV 4 luồng

Flow_PGV_Route

QCTK 2815

Điều 11

Quyết toán

Bước 6-7

QCCTNB 3209

Phụ lục 7

Định mức phân bổ

Tầng 1 - Cấu hình

QCCTNB 3209

Phụ lục 8

Tỷ lệ nhân công

Validation

QCCTNB 3209

Phụ lục 9

Hệ số TND Viện

Tham chiếu

QCCTNB 3209

Phụ lục 1-2

Định mức công tác phí

Auto-validate

QCCTNB 3209

Điều 22

Tạm ứng 90%

Auto-block 90%

QCCTNB 3209

Điều 22.3

Không tiền mặt ≥5tr

Auto-block

QCCTNB 3209

Điều 21

Hoàn thuế GTGT

Module mới

QCCTNB 3209

Điều 19-20

Quỹ

Module quỹ

CCBA 2026

Phụ lục 01

Sơ đồ trách nhiệm

RACI Matrix

CCBA 2026

Phụ lục 02

Định mức nội bộ CCBA

Tầng 2 - Auto-calc

CCBA 2026

Phụ lục 03

SOP IDOP

Workflow

CCBA 2026

Phụ lục 04

KPI Scorecard

Dashboard

CCBA 2026

Điều 13

5 cấp QA/QC

Workflow CDE

CCBA 2026

Điều 17

Tạm ứng → 90%

Phải điều chỉnh

💡 Mở rộng FILE 4: Bổ sung mapping với QCKHCN 2816/QĐ-VKH - xem FILE 4 Phần 7.


## Phụ lục C. Naming Convention


### Sites

1     - CCBA-HUB-CORP / CCBA-HUB-OPS / CCBA-HUB-PRJ

2     - CCBA-OPS-CRM / CCBA-OPS-FIN / CCBA-OPS-LEGAL

3     - CCBA-PRJ-<YYYY>-<ClientShort>-<ProjectCode>

4     - CCBA-CDE-<YYYY>-<ClientShort>-<ProjectCode>


### Libraries

1     - LIB-PMO / LIB-CDE-WIP / LIB-CDE-Shared

2     - LIB-CDE-Published / LIB-CDE-Archive


### Lists

1     - LST-Customers / LST-Contracts / LST-Projects / LST-Tasks

2     - LST-Expenses / LST-AdvanceRequests / LST-VATRefund (MỚI)

3     - LST-KPI-Scorecard / LST-FundManagement (MỚI)


### Flows

1     - Flow_<Domain>_<Action>

2     - VD: Flow_Contract_Approval / Flow_PGV_Route_TypeA


## Phụ lục D. Checklist cập nhật


### D.1. Cấu hình IDOP - Phase 1 (1 tháng)

☐ Cập nhật Bảng định mức theo Phụ lục 7 QCCTNB 3209

☐ Bổ sung tỷ lệ nhân công theo Phụ lục 8

☐ Điều chỉnh tạm ứng từ 70% lên 90%

☐ Thêm validation cho thanh toán không TM ≥ 5tr

☐ Cấu hình định mức công tác phí theo Phụ lục 1-2

☐ Cấu hình định mức nhân công khoán theo Phụ lục 3

☐ Thêm hệ số TND khối gián tiếp theo Phụ lục 9

☐ Auto-calc P2 + P2_GT


### D.2. Cấu hình IDOP - Phase 2 (1 tháng)

☐ Module quản lý hoàn thuế GTGT (80%)

☐ Auto-phân bổ quỹ theo Điều 19

☐ Module quản lý CTV ngoài Viện

☐ Module tính thuế TNCN tự động

☐ Module TK141 tracking

☐ Báo cáo P&L theo định mức

☐ Dashboard cảnh báo định mức

☐ Clawback 12 tháng


### D.3. Cập nhật Quy chế CCBA 2026

☐ Điều chỉnh Điều 17 (Tạm ứng 70% → 90%)

☐ Phụ lục 02 đồng bộ với Phụ lục 7 QCCTNB

☐ Bổ sung quy định tỷ lệ nhân công

☐ Bổ sung quy định thanh toán không TM

☐ Bổ sung quản lý CTV ngoài Viện

☐ Bổ sung định mức công tác phí

☐ Bổ sung cơ chế hoàn thuế GTGT

☐ Cập nhật hệ số TND



# 🔗 PHỤ LỤC - CROSS-REFERENCE ĐẾN FILE 4


## A. Liên kết với Enterprise Architecture

Các yêu cầu kỹ thuật và lộ trình triển khai trong file này được mở rộng cấp Viện tại FILE 4 - Enterprise Architecture:


### A.1. Mở rộng yêu cầu nghiệp vụ

FILE 4 bổ sung Module KH&CN Management với 7 sub-modules:

KHCN_TaskClassification (4 nhóm)

KHCN_Proposal (đăng ký nhiệm vụ)

KHCN_Contract (hợp đồng KH&CN)

KHCN_Assignment (giao việc)

KHCN_Council (hội đồng nghiệm thu)

KHCN_IP (sở hữu trí tuệ)

KHCN_Incentive (chính sách thưởng)


### A.2. Mở rộng yêu cầu kỹ thuật

FILE 4 định nghĩa kiến trúc Enterprise Integration:

API Gateway

Event Bus

Data Lake (cấp Viện)

Master Data Management (MDM)

Identity Federation (CCBA ↔ IBST)


### A.3. Mở rộng tích hợp

FILE 4 bổ sung tích hợp với:

Bộ Xây dựng (BXD) - cổng dịch vụ công

Bộ KH&CN - đăng ký đề tài cấp Bộ

CSDL nhiệm vụ KH&CN quốc gia

Hệ thống tạp chí khoa học - submit bài báo

Cục Sở hữu trí tuệ - đăng ký sáng chế

CSDL doanh nghiệp quốc gia - tra cứu KH/đối tác


### A.4. Mở rộng lộ trình triển khai

FILE 4 định nghĩa roadmap v2.0 → v4.0:

1     v2.0 (Q3/2026) → CCBA Digital Ops (3 file này)

2     v2.1 (Q4/2026) → + KH&CN Module

3     v2.5 (Q2/2027) → + IBST Integration

4     v3.0 (Q4/2027) → Enterprise Platform

5     v4.0 (Q2/2028) → AI-driven Organization


## B. Nguyên tắc liên thông

IDOP CCBA là Core Platform

Hệ thống Viện IBST là Federated Platform

Hệ thống Bộ là External Platform

Mọi tích hợp tuân thủ Enterprise Integration Patterns



# 🖋️ TRANG PHÊ DUYỆT BAN HÀNH


## Kết luận


### Tóm tắt định hướng

IDOP là Digital Operating System của CCBA, được thiết kế trên nền tảng SharePoint Online + Power Platform + Microsoft 365 + Copilot, kiến trúc Hub & Spoke, 8 lớp rõ ràng, tích hợp đồng thời 3 hệ thống quy chế (QCTK 2815, QCCTNB 3209, CCBA 2026), vận hành theo 7 bước từ Đấu thầu đến Quyết toán, với 3 tầng phân bổ tài chính tự động.


### Mười nguyên tắc cốt lõi cần ghi nhớ

Tuân thủ 3 Quy chế tuyệt đối

Digital First, Paper Official

Single Source of Truth

Trách nhiệm giải trình đơn nhất

Configuration over Customization

Audit Trail toàn diện

Data-Driven Decision Making

Continuous Improvement

Auto-Compliance (MỚI)

Financial Discipline (MỚI)


### Thông điệp cuối

IDOP v2.0 không chỉ là một hệ thống phần mềm. Đó là nền tảng vận hành chiến lược tích hợp đồng thời 3 hệ thống quy chế (Triển khai, Chi tiêu, Vận hành), là công cụ để biến mọi quy định cấp Viện và CCBA thành thực tiễn hàng ngày, là cơ sở để CCBA chuyển đổi số bền vững và tuân thủ tuyệt đối trong 5-10 năm tới.

FILE 4 sẽ tiếp tục mở rộng IDOP lên cấp Enterprise, kết nối với Viện IBST, Bộ Xây dựng, Bộ KH&CN, và hệ sinh thái BIM rộng lớn hơn.



## PHÊ DUYỆT BAN HÀNH

Tài liệu Mô tả Kiến trúc và Yêu cầu Thiết kế Hệ thống IDOPPhiên bản 2.0

1                         Hà Nội, ngày 27 tháng 6 năm 2026

2

3

4                                   GIÁM ĐỐC

5                       TRUNG TÂM TƯ VẤN VÀ ỨNG DỤNG BIM

6                               TRONG XÂY DỰNG

7

8

9

10                                 (Đã ký)

11

12

13

14                               VŨ VĂN CHỦ



## NƠI NHẬN

Tài liệu này được phổ biến tới:

Viện trưởng Viện KHCN Xây dựng (báo cáo)

Phó Viện trưởng phụ trách CCBA

Phòng KHKT, TCKT, TCHC Viện

Ban Giám đốc CCBA

Trưởng các phòng/ban CCBA

Cố vấn Pháp lý, TC & QLCL

Phụ trách Kế toán Đơn vị CCBA

Phụ trách Nền tảng Số & Công nghệ BIM

Phòng Tư vấn và Kiểm định Xây dựng TP.HCM

Lưu: VT, CCBA, IDOP



## THÔNG TIN LIÊN HỆ

Đầu mối

Thông tin liên hệ

Ban Chỉ đạo IDOP

Giám đốc CCBA - Vũ Văn Chủ

Phụ trách Nền tảng Số

Đinh Phú Hưởng

Email

chuvv@ibst-bim.vn

Website

www.ibst-bim.vn

Điện thoại

(024) 3754.6422

Địa chỉ trụ sở

81 Trần Cung, Cầu Giấy, Hà Nội


THÔNG ĐIỆP CUỐI

Trân trọng cảm ơn quý vị đã quan tâm đến tài liệu này. Mọi ý kiến đóng góp xin gửi về Ban Chỉ đạo IDOP để cải tiến trong các phiên bản tiếp theo.


--- HẾT FILE 3/4 ---

📎 Xem tiếp:

FILE 1/4 ✅ - Kiến trúc tổng quan

FILE 2/4 ✅ - Vận hành và Tài chính

FILE 4/4 → tiếp theo - Enterprise Architecture (Khung mở rộng cấp Viện)

