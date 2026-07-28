
# 📘 FILE 1/4 - KIẾN TRÚC TỔNG QUAN IDOP v2.0

Tài liệu: Mô tả Kiến trúc và Yêu cầu Thiết kế Hệ thống IDOPPhần: I - VIII (Tổng quan và Kiến trúc)Phiên bản: 2.0Ngày: 27/06/2026Đơn vị: CCBA - Trung tâm Tư vấn và Ứng dụng BIM trong Xây dựng



## 🔗 BỘ TÀI LIỆU LIÊN QUAN

File

Tên

Phạm vi

FILE 1/4

Kiến trúc tổng quan

Phần I-VIII (file này)

FILE 2/4

Vận hành và Tài chính

Phần IX-XI

FILE 3/4

Yêu cầu kỹ thuật và Triển khai

Phần XII-XIV

FILE 4/4

Enterprise Architecture

Khung mở rộng cấp Viện



## MỤC LỤC FILE 1

1     PHẦN I.    GIỚI THIỆU TỔNG QUAN

2     PHẦN II.   BỐI CẢNH VẬN HÀNH VÀ CƠ SỞ PHÁP LÝ

3     PHẦN III.  NGUYÊN TẮC THIẾT KẾ KIẾN TRÚC

4     PHẦN IV.   KIẾN TRÚC TỔNG THỂ - 8 LỚP

5     PHẦN V.    KIẾN TRÚC PHÒNG BAN VÀ VỊ TRÍ CHUYÊN TRÁCH

6     PHẦN VI.   KIẾN TRÚC DỮ LIỆU VÀ TAXONOMY

7     PHẦN VII.  KIẾN TRÚC CDE VÀ QUY TRÌNH 5 CẤP QA/QC

8     PHẦN VIII. KIẾN TRÚC BẢO MẬT VÀ PHÂN QUYỀN

9     PHỤ LỤC.   CROSS-REFERENCE ĐẾN FILE 4



# PHẦN I. GIỚI THIỆU TỔNG QUAN


## 1.1. Mục đích tài liệu

Tài liệu phiên bản 2.0 mô tả kiến trúc tổng thể và yêu cầu thiết kế chi tiết hệ thống IDOP cho CCBA, tích hợp đồng thời 3 hệ thống quy chế:

QCTK 2815/QĐ-VKH - Quy chế Triển khai (cấp Viện)

QCCTNB 3209/QĐ-VKH - Quy chế Chi tiêu Nội bộ (cấp Viện)

Quy chế CCBA 2026 - Quy chế Vận hành (cấp CCBA)

💡 Mở rộng tương lai: Phiên bản 2.1+ sẽ tích hợp thêm QCKHCN 2816/QĐ-VKH (Quy chế KH&CN) - xem chi tiết tại FILE 4 - Enterprise Architecture.


## 1.2. Phạm vi áp dụng

Toàn bộ hoạt động quản trị nội bộ CCBA

5 phòng/ban chuyên môn + 3 vị trí chuyên trách

Mọi quy trình nghiệp vụ: CRM, hợp đồng, dự án, tài chính, KPI, QA/QC

Tích hợp với Viện IBST (KHKT, TCKT, TCHC)

Tích hợp với BIM tools, đối tác, khách hàng

7 bước vận hành từ Đấu thầu đến Quyết toán

3 tầng phân bổ tài chính tự động


## 1.3. Đối tượng sử dụng

Đối tượng

Vai trò

Ban Giám đốc CCBA

Định hướng chiến lược, phê duyệt kiến trúc

Phụ trách Nền tảng Số & CN BIM

Thiết kế và triển khai chi tiết

Trưởng phòng 5 phòng

Hiểu vai trò phòng ban trong kiến trúc

Phụ trách Kế toán Đơn vị

Cấu hình tài chính, định mức

Cố vấn Pháp lý, TC & QLCL

Kiểm soát tuân thủ, audit

Chủ trì HĐ / Dự án

Vận hành nghiệp vụ hàng ngày

Đội ngũ kỹ thuật

Triển khai SharePoint, Power Platform

Đối tác tư vấn

Tham chiếu giải pháp


## 1.4. Mục tiêu chiến lược của IDOP

Số hóa và tích hợp toàn bộ quy trình vận hành CCBA

Tự động hóa nghiệp vụ và phê duyệt 5 cấp QA/QC

Trực quan hóa hiệu suất bằng dashboard và scorecard

Quản trị hiệu suất theo OKRs và KPI

Tuân thủ tuyệt đối 3 hệ thống quy chế

Tạo nguồn sự thật duy nhất (Single Source of Truth)

Lưu vết trách nhiệm (Audit Trail) toàn diện

Tự động phân bổ tài chính 3 tầng theo định mức

Cảnh báo và kiểm soát định mức chi tiêu tự động

Hỗ trợ chuyển đổi số bền vững 5-10 năm



# PHẦN II. BỐI CẢNH VẬN HÀNH VÀ CƠ SỞ PHÁP LÝ


## 2.1. Bối cảnh vận hành CCBA

CCBA là đơn vị sự nghiệp có thu, hạch toán phụ thuộc Viện IBST, được thực hiện cơ chế tự chủ hoạt động và tự chủ tài chính trong phạm vi được phân cấp.


### 2.1.1. Cấu trúc tổ chức

Ban Giám đốc (1 GĐ + 1-2 PGĐ)

5 Phòng chuyên môn

3 Vị trí chuyên trách

Lực lượng thực thi dự án


### 2.1.2. Phạm vi địa lý

Trụ sở chính: Hà Nội

Phòng thường trú TP.HCM (cơ chế 80/20)


### 2.1.3. Hoạt động đa lĩnh vực

Tư vấn BIM và chuyển đổi số

Tư vấn đầu tư xây dựng

Tư vấn giám sát (TVGS), Quản lý dự án (QLDA)

Khảo sát, kiểm định, giám định

Nghiên cứu KH&CN

Đào tạo và hợp tác quốc tế


### 2.1.4. Đặc thù vận hành

Mô hình tập trung + giao khoán

Quy trình 5 cấp QA/QC

Tuân thủ song song: số hóa + giấy có dấu

Hệ sinh thái BIM phức tạp

Hai luồng HĐ: Viện ký và CCBA ký


## 2.2. Hệ thống pháp lý tích hợp


### 2.2.1. QCTK 2815/QĐ-VKH (Quy chế Triển khai)

Phân nhóm HĐ (N1, N2, N3, N4, KH&CN)

Phân cấp ký kết và phê duyệt

7 bước vận hành chính

Bảng 1: Định mức phân bổ kinh phí

4 thành phần trách nhiệm


### 2.2.2. QCCTNB 3209/QĐ-VKH (Quy chế Chi tiêu Nội bộ)

Phụ lục 7: Định mức phân bổ

Phụ lục 8: Tỷ lệ nhân công theo nhóm HĐ

Phụ lục 9: Hệ số TND khối gián tiếp Viện

Tạm ứng tối đa 90% (tăng từ 70%)

Thanh toán không tiền mặt ≥ 5 triệu đồng

Hoàn thuế GTGT 80% trước quyết toán

Định mức công tác phí, hội họp, ăn ca

Quy định CTV và thuế TNCN


### 2.2.3. Quy chế CCBA 2026

Phụ lục 01: Sơ đồ trách nhiệm + GWC

Phụ lục 02: Định mức tài chính nội bộ CCBA

Phụ lục 03: SOP IDOP + Phân quyền

Phụ lục 04: Scorecard & KPI


## 2.3. Vai trò IDOP theo Điều 18 Quy chế CCBA 2026

IDOP được sử dụng để:

Theo dõi tiến độ dự án

Giao việc nội bộ

Quản lý dữ liệu thiết kế (CDE nội bộ)

Đo lường hiệu suất KPI/OKRs

Cơ sở đánh giá năng lực, bình xét thi đua

Tính phân phối thu nhập tăng thêm

Auto-phân bổ tài chính 3 tầng

Cảnh báo định mức chi tiêu

Lưu vết audit toàn diện

⚠️ Lưu ý quan trọng:

IDOP là cơ sở quản trị nội bộ

Hồ sơ chính thức ra ngoài/trình Viện vẫn dùng giấy + dấu

Mọi giao dịch tài chính cần chứng từ giấy hợp lệ



# PHẦN III. NGUYÊN TẮC THIẾT KẾ KIẾN TRÚC


## 3.1. Mười nguyên tắc cốt lõi

Hệ thống IDOP được thiết kế dựa trên 10 nguyên tắc cốt lõi, trong đó có 2 nguyên tắc mới (9 và 10) bổ sung trong phiên bản 2.0:

Nguyên tắc 1 - Tuân thủ 3 Quy chếMọi thành phần kiến trúc phải tuân thủ đồng thời QCTK 2815, QCCTNB 3209 và Quy chế CCBA 2026.

Nguyên tắc 2 - Digital First, Paper OfficialGiao dịch nội bộ trên IDOP; Hồ sơ chính thức ra ngoài: giấy + ký tươi + đóng dấu.

Nguyên tắc 3 - Single Source of TruthMột dữ liệu chỉ tồn tại ở một nơi, tham chiếu khi cần.

Nguyên tắc 4 - Trách nhiệm giải trình đơn nhấtMỗi chức năng trọng yếu chỉ có một cá nhân chịu trách nhiệm cuối cùng.

Nguyên tắc 5 - Hub & Spoke ArchitectureKiến trúc site phẳng, kết nối qua Hub Sites, không dùng subsites.

Nguyên tắc 6 - Configuration over CustomizationƯu tiên cấu hình hơn lập trình để giảm chi phí bảo trì.

Nguyên tắc 7 - Audit Trail toàn diệnMọi thao tác có ghi nhận thời gian và định danh người dùng.

Nguyên tắc 8 - Data-Driven Decision MakingQuyết định quản trị dựa trên dữ liệu khách quan từ IDOP.

Nguyên tắc 9 (MỚI) - Auto-ComplianceTự động áp dụng định mức Phụ lục 7, kiểm tra tỷ lệ nhân công Phụ lục 8, cảnh báo vượt định mức, block thanh toán không tuân thủ, phân bổ 3 tầng tự động.

Nguyên tắc 10 (MỚI) - Financial DisciplineTạm ứng tối đa 90%, thanh toán không tiền mặt ≥ 5tr, hoàn thuế GTGT 80/20, khấu trừ TNCN tự động, TK141 real-time tracking.

💡 Mở rộng FILE 4: Hai nguyên tắc Enterprise Architecture mới (Regulation-Driven & Modular Extension) - xem chi tiết tại FILE 4.



# PHẦN IV. KIẾN TRÚC TỔNG THỂ - 8 LỚP


## 4.1. Mô hình kiến trúc 8 lớp

Lớp

Mô tả

Lớp 1: Experience Layer

Trải nghiệm người dùng - 7 nhóm người dùng

Lớp 2: Access Channels

Teams, SharePoint, Apps, Outlook, Power BI, Copilot, Mobile

Lớp 3: Site Architecture

Hub & Spoke với Corporate Hub, IDOP Operations Hub, Project Hub & CDE

Lớp 4: Data Layer

33 SharePoint Lists + Document Libraries + CDE

Lớp 5: Taxonomy Layer

Term Store enterprise

Lớp 6: Process Layer

Power Platform (40+ Flows, Apps, BI, Copilot)

Lớp 7: Integration Layer

Microsoft 365, BIM Tools, Hệ thống Viện IBST, Đối tác

Lớp 8: Security & Governance

Entra ID, Permission, Audit, Lifecycle, Backup

💡 Mở rộng FILE 4: Mô hình kiến trúc nâng cấp lên 10 lớp Enterprise với Business Capability Layer và External Ecosystem Layer - xem FILE 4 Phần 2.


## 4.2. Mô hình Hub & Spoke


### IBST - CCBA Hub Site (Root)

Điểm vào chính của toàn hệ thống

Cung cấp navigation chung, branding nhất quán

Kết nối 3 Hub con


### Corporate Hub (Hub 1)

CCBA Home - Trang chủ

Tin tức và Thông báo

Quy chế, Chính sách, Quy trình

Thư viện tri thức (Knowledge Base)

Đào tạo (Training)

Scorecard & KPI tổng quan


### IDOP Operations Hub (Hub 2 - Lõi vận hành)

5 Department Workspaces (Tổng hợp, R&D, BIM TK, BIM DA, TP.HCM)

3 Specialist Workspaces (Legal/QA, Kế toán, Nền tảng Số)

33 SharePoint Lists (CRM, HĐ, Dự án, Tài chính, HR, KPI, QA)

Operations Libraries (Biểu mẫu, Templates, Hồ sơ)


### Project Hub & CDE (Hub 3)

Project Sites (mỗi dự án 1 site PMO)

CDE Sites (theo chuẩn ISO 19650)

Review & Approval workspace

BIM Models, Drawings, Documents


## 4.3. Ba trụ cột công nghệ

Trụ cột

Vai trò

Công nghệ chính

SharePoint Online

Lõi dữ liệu, lõi site, lõi tài liệu

Sites, Lists, Libraries, Term Store

Power Platform

Quy trình, tự động hóa, ứng dụng nghiệp vụ

Power Apps, Power Automate, Power BI

Microsoft 365 + Copilot

Giao tiếp, cộng tác, trí tuệ nhân tạo

Teams, Outlook, OneDrive, Copilot



# PHẦN V. KIẾN TRÚC PHÒNG BAN VÀ VỊ TRÍ CHUYÊN TRÁCH


## 5.1. Cơ cấu tổ chức theo Quy chế CCBA 2026


### Ban Giám đốc

Giám đốc CCBA (Visionary & Integrator)

Phó Giám đốc (Khối Dịch vụ & Kinh doanh)

Phó Giám đốc thường trú TP.HCM


### 5 Phòng/Ban chuyên môn

Phòng Tổng hợp

Phòng R&D và Hợp tác Quốc tế

Phòng BIM Thiết kế

Phòng BIM Dự án

Phòng Tư vấn và Kiểm định Xây dựng TP.HCM


### 3 Vị trí chuyên trách (KHÔNG phải phòng độc lập)

Cố vấn Pháp lý, Tiêu chuẩn & QLCL

Phụ trách Kế toán Đơn vị (thuộc Phòng Tổng hợp)

Phụ trách Nền tảng Số & Công nghệ BIM


### Lực lượng thực thi dự án

Chủ trì Hợp đồng / Chủ nhiệm Dự án

Cá nhân / Viên chức Người lao động (VCNLĐ)


## 5.2. Department Workspaces (5 workspace)

Phòng

Chức năng

Workspace IDOP

Phòng Tổng hợp

Hậu cần, hành chính, văn thư, nhân sự

HR/Admin Workspace

Phòng R&D và HTQT

Nghiên cứu, NCKH, hợp tác quốc tế, pre-sales

R&D Workspace

Phòng BIM Thiết kế

Tư vấn thiết kế, BIM, thẩm tra, LEED, CFD

Design Workspace

Phòng BIM Dự án

TVGS, QLDA, kiểm định hiện trường

Project Delivery Workspace

Phòng TP.HCM

Phát triển thị trường phía Nam, cơ chế 80/20

HCM Branch Workspace


## 5.3. Specialist Workspaces (3 workspace)

Vị trí

Vai trò

Workspace IDOP

Legal/QA/QLCL

Gác cổng rủi ro, chất lượng, ISO 9001

Legal/QA Workspace

Kế toán Đơn vị

Tài chính, chứng từ, dòng tiền

Finance Workspace

Nền tảng Số & CN BIM

Kiến trúc IDOP, bảo mật, CDE

Platform Governance Workspace


## 5.4. Nguyên tắc thiết kế phòng ban

Department = Workspace + View + Permission + KPI Context

Department ≠ Database riêng biệt

Một lõi dữ liệu thống nhất - Single Source of Truth

Mỗi phòng có "ngôi nhà số" riêng

Phân quyền theo vai trò, không theo cảm tính

Dashboard riêng cho từng phòng

Không nhân bản dữ liệu giữa phòng

Không tạo list trùng nhau theo phòng



# PHẦN VI. KIẾN TRÚC DỮ LIỆU VÀ TAXONOMY


## 6.1. Mô hình dữ liệu cốt lõi

1     Customer (Khách hàng)

2         │

3         ├── Opportunity (Cơ hội)

4         │       │

5         │       └── Contract (Hợp đồng)

6         │               │

7         │               ├── Project (Dự án)

8         │               │       │

9         │               │       ├── WorkItem → Timesheet

10         │               │       └── Deliverable → Approval

11         │               │

12         │               ├── PaymentPlan → Invoice → Payment

13         │               └── Expense

14         │

15         └── Contact


## 6.2. SharePoint Lists (33 lists)


### CRM (5 lists)

LST-Customers

LST-Contacts

LST-Opportunities

LST-Activities

LST-PotentialProjects


### Contracts (4 lists)

LST-Contracts

LST-ContractValues

LST-PaymentPlans

LST-ContractFiles


### Projects & Tasks (6 lists)

LST-Projects

LST-WorkItems

LST-Timesheets

LST-Risks

LST-Issues

LST-Deliverables


### Finance - CẬP NHẬT theo QCCTNB 3209 (10 lists)

LST-Invoices

LST-Payments

LST-AdvanceRequests (max 90% - MỚI)

LST-Expenses

LST-CashflowSnapshots

LST-FinancialAllocationRules (MỚI)

LST-AllowanceRates (MỚI)

LST-VATRefund (MỚI)

LST-PaymentMethod (MỚI)

LST-TK141Tracking (MỚI)


### HR/Admin (5 lists)

LST-Employees

LST-Departments

LST-LeaveRequests

LST-PurchaseRequests

LST-Assets


### Approval (3 lists)

LST-Submissions

LST-ApprovalTransactions

LST-ReviewRegister


### KPI/OKRs (4 lists)

EOS_Scorecard_Data

LST-KPIDefinitions

LST-OKRs

LST-KRUpdates


### QA/QC (3 lists)

LST-QAChecklists

LST-NonConformance

LST-LessonsLearned


### Funds - MỚI (1 list)

LST-FundManagement

💡 Mở rộng FILE 4: Bổ sung 7 lists KH&CN Management cho v2.1 - xem FILE 4 Phần 3:

LST-KHCN-Tasks, LST-KHCN-Proposals, LST-KHCN-Contracts

LST-KHCN-Councils, LST-KHCN-Acceptance

LST-KHCN-IP, LST-KHCN-Incentives


## 6.3. Term Store Enterprise


### CCBA_PhongBanDonVi

1     ├── 100. BAN LÃNH ĐẠO

2     │   └── 101. Ban Giám đốc

3     ├── 200. KHỐI VĂN PHÒNG

4     │   └── 201. Phòng Tổng hợp

5     └── 300. KHỐI CHUYÊN MÔN

6         ├── 301. Phòng BIM Thiết kế

7         ├── 302. Phòng BIM Dự án

8         ├── 303. Phòng R&D và HTQT

9         └── 304. Phòng TVKĐ Xây dựng TP.HCM


### CCBA_ContractGroup (CẬP NHẬT theo Phụ lục 7 QCCTNB)

N1a - Giám định, kiểm định sự cố

N1b - PVQLNN có kinh phí trực tiếp

N2a - Tư vấn QLDA, đầu tư XD, chuyển giao CN

N2b - HCHQ, hiệu chuẩn thiết bị

N2c - Tập huấn, đào tạo

N2d - Khảo sát, kiểm định CLCT

N2e - Thí nghiệm hiện trường

N2f - Thí nghiệm trong phòng

N2g - Thí nghiệm đặc thù

N3 - Thi công xây dựng

N4 - Cung ứng vật tư, thiết bị

KHCN_1a - KH&CN NSNN trực tiếp (MỚI)

KHCN_1b - KH&CN nguồn khác (MỚI)


### Các Term Set khác

CCBA_ExpenseType - Loại chi phí (chi tiết theo QCCTNB)

CCBA_AllowanceCategory - Định mức phụ cấp (MỚI)

CCBA_PaymentMethod - Phương thức thanh toán (MỚI)

CCBA_CDEState - Trạng thái CDE (WIP/Shared/Published/Archive)

CCBA_ApprovalStage - Cấp phê duyệt 1-5

CCBA_FundType - Loại quỹ (MỚI)



# PHẦN VII. KIẾN TRÚC CDE VÀ QUY TRÌNH 5 CẤP QA/QC


## 7.1. Cấu trúc CDE chuẩn ISO 19650

1     CCBA-CDE-<YYYY>-<ClientShort>-<ProjectCode>

2     │

3     ├── LIB-CDE-WIP (Work In Progress)

4     │   ├── 01_Architecture

5     │   ├── 02_Structure

6     │   ├── 03_MEP

7     │   ├── 04_Coordination

8     │   └── 05_QA-QC

9     │

10     ├── LIB-CDE-Shared

11     │   └── (Tài liệu chia sẻ nội bộ)

12     │

13     ├── LIB-CDE-Published

14     │   └── (Tài liệu đã phát hành)

15     │

16     ├── LIB-CDE-Archive

17     │   └── (Lưu trữ)

18     │

19     ├── LIB-CDE-Templates

20     └── LIB-CDE-Contract-Reference


## 7.2. Quy trình 5 cấp QA/QC (Điều 13 Quy chế CCBA 2026)

Cấp 1: Kiểm soát kỹ thuật nội bộ (Technical Check)Gồm 3 sub-levels: (1A) Tác giả tự rà soát theo checklist; (1B) Chủ trì bộ môn kiểm tra chuyên môn sâu; (1C) Chủ trì kỹ thuật rà soát tính đồng bộ liên bộ môn.

Cấp 2: Phê duyệt quản trị dự án (Management Approval)Mô hình cá nhân (HĐ Nhóm 2 trừ TVGS/QLDA, Nhóm 4): Chủ trì HĐ rà soát. Mô hình tập trung (TVGS, QLDA, Thi công): Trưởng phòng chuyên môn quản lý điều hành.

Cấp 3: Kiểm soát Lãnh đạo Phòng (Department Review)Trưởng phòng hoặc Phó Trưởng phòng chuyên môn xác nhận sản phẩm đáp ứng tiêu chuẩn vận hành.

Cấp 4: Thẩm định Tuân thủ & Pháp lý (Compliance & QA)Cố vấn Pháp lý, Tiêu chuẩn & QLCL kiểm tra tuân thủ ISO 9001, quy chuẩn, tiêu chuẩn, pháp luật và quy chế nội bộ Viện.

Cấp 5: Phê duyệt Lãnh đạo và Phát hành (Final Approval)HĐ Trung tâm ký: Giám đốc/Phó Giám đốc CCBA E-Approval, sau đó in + ký tươi + đóng dấu CCBA. HĐ Viện ký: GĐ CCBA xác nhận, chuyển KHKT/TCHC trình Lãnh đạo Viện ký chính thức.

💡 Mở rộng FILE 4: Module KHCN_Council với hội đồng 7-11 thành viên, quorum 2/3, họp online - xem FILE 4 Phần 4.


## 7.3. State Machine CDE

1     WIP → (sau Cấp 1) → Shared → (sau Cấp 2-4) → Review

2     Review → (sau Cấp 5) → Published

3     Published → (sau đóng dự án) → Archive


## 7.4. Audit Trail

Mỗi giao dịch phê duyệt ghi nhận:

Người thao tác (định danh user)

Thời gian thao tác (timestamp)

Hành động (tạo / sửa / duyệt / từ chối)

Lý do (nếu từ chối)

Trạng thái trước và sau

Version snapshot của tài liệu



# PHẦN VIII. KIẾN TRÚC BẢO MẬT VÀ PHÂN QUYỀN


## 8.1. Microsoft Entra ID Groups

CCBA_BanGiamDoc

CCBA_TruongPhong_All

CCBA_PhongTongHop

CCBA_PhongRD_HTQT

CCBA_PhongBIMThietKe

CCBA_PhongBIMDuAn

CCBA_PhongHCM

CCBA_Legal_QA

CCBA_KeToan

CCBA_DigitalPlatform_Admin

CCBA_ChuTri_All

CCBA_VCNLD_All

CCBA_External_Partners

CCBA_External_Clients

CCBA_Finance_Audit (MỚI)

CCBA_Fund_Manager (MỚI)

💡 Mở rộng FILE 4: Bổ sung groups cho IBST integration (IBST_KHKT, IBST_TCKT, IBST_TCHC, KHCN_Council) - xem FILE 4 Phần 5.


## 8.2. Ma trận phân quyền

Phân hệ

BGĐ

TP

Legal/QA

Kế toán

Chủ trì

VCNLĐ

CRM

Admin

Edit

Approve

View

View

No Access

Dự án

Admin

Quản lý phòng

View

View

DA phụ trách

Task cá nhân

CDE

View

Quản lý phòng

Thẩm định

No Access

DA phụ trách

Thư mục được giao

Tài chính

Approve

View

No Access

Admin

Chi phí DA

No Access

Quỹ (MỚI)

Approve

View

View

Edit

View

No Access

Hoàn thuế (MỚI)

View

No Access

View

Admin

View

No Access


## 8.3. Nguyên tắc phân quyền

Quản lý phân quyền tại Site Level, hạn chế Item-level

Sử dụng Entra ID Groups thay vì user trực tiếp

Audience Targeting cho navigation

External Sharing có kiểm soát chặt

MFA bắt buộc với mọi user

Conditional Access cho user đặc quyền

Audit log cho mọi thay đổi quyền


## 8.4. Phân loại độ nhạy dữ liệu

Mức độ

Loại dữ liệu

Quy tắc truy cập

🔴 Restricted

HR, Payroll, Finance details, Fund details

Bảo mật cao nhất

🟠 Confidential

Contracts, Strategic docs, Client lists

Kiểm soát chặt

🟡 Project-Confidential

Project CDE

Trong phạm vi dự án

🟢 Internal-General

Corporate content, Knowledge base

Nội bộ chung

⚪ Public

Marketing, Public info

Chia sẻ ra ngoài



# 🔗 PHỤ LỤC - CROSS-REFERENCE ĐẾN FILE 4


## A. Liên kết với Enterprise Architecture (FILE 4)

Hệ thống IDOP v2.0 được thiết kế với khả năng mở rộng lên cấp độ Enterprise Architecture, được trình bày chi tiết tại FILE 4 - Khung mở rộng IDOP.


### A.1. Vai trò của FILE 4

Là tài liệu kiến trúc tổng thể cấp Viện (IBST-level)

Định nghĩa các lớp kiến trúc mở rộng:

Business Capability Layer

Integration Layer

External Ecosystem Layer


### A.2. Các kết nối được định nghĩa trong FILE 4

Hệ thống nội bộ Viện (KHKT, TCKT, TCHC)

Bộ Xây dựng (BXD)

Bộ KH&CN

Hệ sinh thái BIM

Hệ thống tài chính – kế toán


### A.3. Kiến trúc tích hợp

API Gateway

Event-driven workflow

Data synchronization


## B. Nguyên tắc áp dụng

IDOP là nền tảng lõi (Core Platform)

Các hệ thống khác là Satellite Systems

Mọi tích hợp phải:

Không phá vỡ kiến trúc hiện tại

Tuân thủ "Configuration over Customization"

Có khả năng mở rộng tương lai


## C. Roadmap mở rộng

1     v2.0 → CCBA Digital Ops (file này)

2     v2.1 → + KH&CN module (xem FILE 4)

3     v2.5 → + IBST integration (xem FILE 4)

4     v3.0 → Enterprise Platform (xem FILE 4)

5     v4.0 → AI-driven Organization (xem FILE 4)


HẾT FILE 1/4

📎 Xem tiếp:

FILE 2/4 - Vận hành và Tài chính (Phần IX-XI)

FILE 3/4 - Yêu cầu kỹ thuật và Triển khai (Phần XII-XIV)

FILE 4/4 - Enterprise Architecture (Khung mở rộng)


