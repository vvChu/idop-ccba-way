
# 📘 FILE 4/4 - ENTERPRISE ARCHITECTURE EXTENSION IDOP v2.0+

Tài liệu: Khung Mở rộng IDOP cấp EnterpriseMục đích: Định hướng kiến trúc IDOP từ CCBA-level lên IBST-level và Enterprise-levelPhiên bản: 1.0 (Bổ sung cho IDOP v2.0)Ngày: 27/06/2026Đơn vị: CCBA - Trung tâm Tư vấn và Ứng dụng BIM trong Xây dựng



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

Phần XII-XIV

FILE 4/4

Enterprise Architecture

Khung mở rộng (file này)



## MỤC LỤC FILE 4

1     PHẦN 1.  GIỚI THIỆU & TẦM NHÌN ENTERPRISE

2     PHẦN 2.  KIẾN TRÚC ENTERPRISE 10 LỚP

3     PHẦN 3.  DỮ LIỆU & TAXONOMY MỞ RỘNG

4     PHẦN 4.  MODULE KH&CN MANAGEMENT (CHI TIẾT)

5     PHẦN 5.  TÍCH HỢP HỆ SINH THÁI (INTEGRATION)

6     PHẦN 6.  ROADMAP v2.0 → v4.0

7     PHẦN 7.  MAPPING QUY CHẾ 2816 (KH&CN)

8     PHẦN 8.  GOVERNANCE FRAMEWORK

9     PHẦN 9.  AI & EMERGING TECHNOLOGIES

10     PHẦN 10. KẾT LUẬN & TẦM NHÌN 2030



# PHẦN 1. GIỚI THIỆU & TẦM NHÌN ENTERPRISE


## 1.1. Mục đích FILE 4

FILE 4 là tài liệu chiến lược cấp Enterprise, định hướng nâng cấp IDOP từ:

1     🔵 IDOP v2.0 (CCBA-level)

2        ↓ FILE 4 mở rộng

3     🟢 IDOP v3.0 (IBST-level)

4        ↓ tiếp tục mở rộng

5     🟡 IDOP v4.0 (National-level)


## 1.2. Tầm nhìn IDOP 2030

"IDOP trở thành Digital Operating System của Viện KHCN Xây dựng, kết nối liền mạch CCBA + IBST + Bộ Xây dựng + Bộ KH&CN, tạo nền tảng nghiên cứu khoa học và dịch vụ kỹ thuật số hóa hàng đầu Việt Nam vào năm 2030."


## 1.3. Bốn nguyên tắc Enterprise (bổ sung)


### Nguyên tắc 11 - Regulation-Driven Architecture

Mọi module phải map được tới quy chế (Viện / Bộ / Nhà nước). Không hard-code quy định.


### Nguyên tắc 12 - Modular Expansion

Mỗi domain (KH&CN, Tài chính, Nhân sự...) là 1 module độc lập, có thể plug-in/plug-out.


### Nguyên tắc 13 - Backward Compatibility

Khi thay đổi quy chế, dữ liệu cũ không bị phá vỡ. Versioning bắt buộc.


### Nguyên tắc 14 - Federated Identity

CCBA, IBST, Bộ XD, Bộ KH&CN sử dụng chung hệ thống định danh liên kết (SSO + Identity Federation).


## 1.4. Vai trò chiến lược

Cấp độ

Vai trò IDOP

CCBA

Digital Operating System nội bộ

IBST

Federated Platform liên thông các đơn vị

Bộ XD/KH&CN

Integration Gateway với chính phủ

Quốc gia

Reference Architecture cho ngành xây dựng



# PHẦN 2. KIẾN TRÚC ENTERPRISE 10 LỚP


## 2.1. Nâng cấp từ 8 lớp lên 10 lớp

IDOP v2.0 có 8 lớp. IDOP Enterprise bổ sung 2 lớp mới:

#

Lớp

Trạng thái

1

Experience Layer

✅ v2.0

2

Access Channels

✅ v2.0

3

Business Capability Layer

🆕 Enterprise

4

Application Layer (Site Architecture)

✅ v2.0

5

Data Layer

✅ v2.0

6

Taxonomy Layer

✅ v2.0

7

Process Layer

✅ v2.0

8

Integration Layer (nâng cấp)

🔄 Enhanced

9

Security Layer

✅ v2.0

10

External Ecosystem Layer

🆕 Enterprise


## 2.2. Lớp 3 (MỚI) - Business Capability Layer

Định nghĩa năng lực nghiệp vụ mà IDOP cung cấp, độc lập với công nghệ:


### Core Capabilities (CCBA-level)

Customer Relationship Management

Contract Lifecycle Management

Project Delivery Management

Financial Management (3 tầng)

Quality Assurance (5 cấp)

Human Capital Management

Performance Management (KPI/OKR)


### Extended Capabilities (Enterprise-level)

Science & Technology Management 🆕

Intellectual Property Management 🆕

Standards Development Management 🆕

Research Collaboration Management 🆕

Publication Management 🆕

Inter-Agency Coordination 🆕


## 2.3. Lớp 10 (MỚI) - External Ecosystem Layer

Định nghĩa hệ sinh thái bên ngoài IDOP cần kết nối:


### Government Systems

1     ┌─────────────────────────────────────────┐

2     │   Chính phủ điện tử (eGov)              │

3     ├─────────────────────────────────────────┤

4     │   Bộ Xây dựng (BXD)                     │

5     │   - Cổng dịch vụ công                   │

6     │   - CSDL công trình quốc gia            │

7     ├─────────────────────────────────────────┤

8     │   Bộ Khoa học & Công nghệ (BKHCN)       │

9     │   - Cổng đăng ký nhiệm vụ KH&CN         │

10     │   - CSDL nhiệm vụ KH&CN quốc gia        │

11     │   - Cục Sở hữu trí tuệ                  │

12     ├─────────────────────────────────────────┤

13     │   Bộ Tài chính                          │

14     │   - Hệ thống thuế điện tử (eTax)        │

15     │   - Kho bạc Nhà nước                    │

16     └─────────────────────────────────────────┘


### Industry Systems

1     ┌─────────────────────────────────────────┐

2     │   BIM Ecosystem                         │

3     │   - Autodesk BIM 360                    │

4     │   - Trimble Connect                     │

5     │   - Bentley ProjectWise                 │

6     ├─────────────────────────────────────────┤

7     │   Tạp chí khoa học                      │

8     │   - Tạp chí KHCN Xây dựng (Viện)        │

9     │   - Springer, Elsevier, IEEE            │

10     │   - DOI registry                        │

11     ├─────────────────────────────────────────┤

12     │   Đối tác công nghiệp                   │

13     │   - Nhà thầu lớn                        │

14     │   - Chủ đầu tư                          │

15     │   - Tư vấn nước ngoài                   │

16     └─────────────────────────────────────────┘


## 2.4. Sơ đồ kiến trúc 10 lớp

1     ╔═══════════════════════════════════════════════╗

2     ║  LỚP 1: EXPERIENCE LAYER                      ║

3     ║  (8 nhóm người dùng: + KH&CN Researchers)     ║

4     ╚═══════════════════════════════════════════════╝

5                            ↓

6     ╔═══════════════════════════════════════════════╗

7     ║  LỚP 2: ACCESS CHANNELS                       ║

8     ║  (Teams/SP/Apps/Mobile/Copilot/Web)           ║

9     ╚═══════════════════════════════════════════════╝

10                            ↓

11     ╔═══════════════════════════════════════════════╗

12     ║  LỚP 3: BUSINESS CAPABILITY LAYER 🆕          ║

13     ║  (Core + Extended Capabilities)               ║

14     ╚═══════════════════════════════════════════════╝

15                            ↓

16     ╔═══════════════════════════════════════════════╗

17     ║  LỚP 4: APPLICATION LAYER                     ║

18     ║  (CCBA Sites + IBST Sites + KH&CN Sites)      ║

19     ╚═══════════════════════════════════════════════╝

20                            ↓

21     ╔═══════════════════════════════════════════════╗

22     ║  LỚP 5: DATA LAYER                            ║

23     ║  (33 CCBA Lists + 7 KH&CN Lists + Data Lake)  ║

24     ╚═══════════════════════════════════════════════╝

25                            ↓

26     ╔═══════════════════════════════════════════════╗

27     ║  LỚP 6: TAXONOMY LAYER                        ║

28     ║  (CCBA + IBST + National Standards)           ║

29     ╚═══════════════════════════════════════════════╝

30                            ↓

31     ╔═══════════════════════════════════════════════╗

32     ║  LỚP 7: PROCESS LAYER                         ║

33     ║  (40+ CCBA Flows + 8 KH&CN Flows + AI)        ║

34     ╚═══════════════════════════════════════════════╝

35                            ↓

36     ╔═══════════════════════════════════════════════╗

37     ║  LỚP 8: INTEGRATION LAYER (Enhanced) 🔄        ║

38     ║  (API Gateway + Event Bus + ESB)              ║

39     ╚═══════════════════════════════════════════════╝

40                            ↓

41     ╔═══════════════════════════════════════════════╗

42     ║  LỚP 9: SECURITY LAYER                        ║

43     ║  (Federated Identity + Zero Trust)            ║

44     ╚═══════════════════════════════════════════════╝

45                            ↓

46     ╔═══════════════════════════════════════════════╗

47     ║  LỚP 10: EXTERNAL ECOSYSTEM LAYER 🆕          ║

48     ║  (Government + Industry + Academia)           ║

49     ╚═══════════════════════════════════════════════╝



# PHẦN 3. DỮ LIỆU & TAXONOMY MỞ RỘNG


## 3.1. Bổ sung 7 SharePoint Lists cho KH&CN

#

List

Mục đích

1

LST-KHCN-Tasks

Quản lý nhiệm vụ KH&CN (4 nhóm)

2

LST-KHCN-Proposals

Đề xuất nhiệm vụ (đăng ký)

3

LST-KHCN-Contracts

Hợp đồng KH&CN

4

LST-KHCN-Councils

Hội đồng nghiệm thu

5

LST-KHCN-Acceptance

Biên bản nghiệm thu

6

LST-KHCN-IP

Sở hữu trí tuệ (sáng chế, giải pháp)

7

LST-KHCN-Incentives

Chính sách thưởng


## 3.2. Term Store mở rộng


### CCBA_KHCN_TaskGroup (4 nhóm theo Quy chế 2816)

1     ├── KHCN_Nhom1 - NSNN cấp trực tiếp (không VAT)

2     ├── KHCN_Nhom2 - NSNN gián tiếp + nguồn khác (có VAT)

3     ├── KHCN_Nhom3 - Nghiên cứu theo chức năng

4     └── KHCN_Nhom4 - Nhiệm vụ cấp Viện (tự chủ)


### CCBA_KHCN_TaskType

1     ├── Đề tài KH&CN

2     ├── Dự án KH&CN

3     ├── Đề án KH&CN

4     ├── Chương trình KH&CN

5     ├── Xây dựng TCVN

6     ├── Xây dựng QCVN

7     ├── Xây dựng TCCS

8     ├── Dự án sản xuất thử nghiệm

9     └── Thông tin KH&CN


### CCBA_KHCN_CouncilLevel

1     ├── Hội đồng cấp Cơ sở (Đơn vị)

2     ├── Hội đồng cấp Viện

3     ├── Hội đồng cấp Bộ

4     └── Hội đồng cấp Nhà nước


### CCBA_KHCN_PublicationType

1     ├── ISI Journal

2     ├── Scopus Journal

3     ├── ISSN Quốc tế khác

4     ├── Hội nghị quốc tế (toàn văn)

5     ├── Hội nghị quốc tế (trình bày)

6     ├── Hội nghị quốc tế tại VN

7     ├── Tạp chí trong nước (ISSN)

8     └── Hội nghị trong nước


### CCBA_KHCN_IPType

1     ├── Bằng độc quyền sáng chế

2     ├── Bằng độc quyền giải pháp hữu ích

3     ├── Bằng kiểu dáng công nghiệp

4     ├── Nhãn hiệu

5     ├── Bản quyền tác giả

6     └── Tiêu chuẩn TCVN/QCVN


## 3.3. Data Lake Architecture (Enterprise)

Khi mở rộng lên cấp IBST, IDOP cần Data Lake để tổng hợp dữ liệu:

1     ┌─────────────────────────────────────────┐

2     │  RAW Zone (Bronze)                      │

3     │  - Dữ liệu thô từ CCBA, các đơn vị Viện │

4     │  - Logs, audit trails                   │

5     └─────────────────────────────────────────┘

6                       ↓ ETL

7     ┌─────────────────────────────────────────┐

8     │  CURATED Zone (Silver)                  │

9     │  - Dữ liệu đã làm sạch, chuẩn hóa       │

10     │  - Master data: KH/HĐ/DA/Nhân sự        │

11     └─────────────────────────────────────────┘

12                       ↓ Modeling

13     ┌─────────────────────────────────────────┐

14     │  ANALYTICS Zone (Gold)                  │

15     │  - Data Marts: Financial, Operations    │

16     │  - KPI/Scorecard tổng hợp               │

17     │  - ML Models                            │

18     └─────────────────────────────────────────┘

Technology stack đề xuất:

Microsoft Fabric / Azure Synapse

Power BI Premium

Azure Data Lake Storage Gen2


## 3.4. Bảng định mức KH&CN bổ sung (theo Quy chế 2816)

Nhóm KHCN

Loại

Giao đơn vị

CPQL

Ghi chú

Nhóm 1a

NSNN trực tiếp (không VAT)

95%

5%

Đề tài cấp Nhà nước

Nhóm 1b

NSNN gián tiếp + nguồn khác

97%

3%

Có VAT

Nhóm 2

Hợp đồng dịch vụ KH&CN

Theo HĐ

Theo HĐ

Tính như Nhóm 2 QCTK

Nhóm 3

Nghiên cứu theo chức năng

100%

-

Chi thường xuyên

Nhóm 4

Nhiệm vụ cấp Viện

100%

-

Tự chủ kinh phí Viện


## 3.5. Định mức thưởng KH&CN (theo Điều 16 & 23 QCKHCN 2816)

Loại thành tựu

Mức thưởng

Điều kiện

Bài báo ISI

50 triệu

Có DOI, đăng chính thức

Bài báo Scopus

30 triệu

Có DOI, indexed

Bài báo ISSN quốc tế

10 triệu

Tạp chí có ISSN

Hội nghị quốc tế (toàn văn)

10 triệu

Có ISBN proceedings

Hội nghị quốc tế (trình bày)

20 triệu

Có invitation letter

Hội nghị quốc tế tại VN (toàn văn)

5 triệu

Có ISBN

Hội nghị quốc tế tại VN (trình bày)

10 triệu

Có invitation

Hội nghị trong nước (tạp chí)

3 triệu

Có ISBN

Hội nghị trong nước (toàn văn)

2 triệu

Có proceedings

Sáng chế độc quyền

50 triệu/bằng

Có giấy chứng nhận

Giải pháp hữu ích

30 triệu

Ứng dụng có hiệu quả

Đề tài Xuất sắc

10% giá trị HĐ

Max 100 triệu, đúng tiến độ

Quy chuẩn QCVN (ban hành)

10% giá trị HĐ

Max 60 triệu, mức A

Quy chuẩn QCVN (nghiệm thu Đạt)

5% giá trị HĐ

Max 30 triệu, mức B

Tiêu chuẩn TCVN

Max 20 triệu

Đã công bố



# PHẦN 4. MODULE KH&CN MANAGEMENT (CHI TIẾT)


## 4.1. Workflow 5 bước KH&CN (theo Điều 5 QCKHCN 2816)

1     ┌──────────────────────────────────────────────┐

2     │  BƯỚC 1: ĐĂNG KÝ NHIỆM VỤ                    │

3     ├──────────────────────────────────────────────┤

4     │  - Nhóm 1: Quý I hàng năm                    │

5     │  - Nhóm 4: Quý IV hàng năm                   │

6     │  - Nộp đề cương sơ bộ                        │

7     │  - KHKT thẩm tra trước 7 ngày                │

8     └──────────────────────────────────────────────┘

9                         ↓

10     ┌──────────────────────────────────────────────┐

11     │  BƯỚC 2: KÝ HỢP ĐỒNG KH&CN                   │

12     ├──────────────────────────────────────────────┤

13     │  - Soạn thảo HĐ + đề cương chi tiết          │

14     │  - Trình ký Viện trưởng                      │

15     │  - Lưu trữ 3 bộ (TCHC/KHKT/Đơn vị)           │

16     └──────────────────────────────────────────────┘

17                         ↓

18     ┌──────────────────────────────────────────────┐

19     │  BƯỚC 3: GIAO NHIỆM VỤ                       │

20     ├──────────────────────────────────────────────┤

21     │  - Quyết định giao việc theo mẫu             │

22     │  - Nhóm 1: trong 3 ngày sau ký HĐ            │

23     │  - Chủ nhiệm chịu trách nhiệm                │

24     └──────────────────────────────────────────────┘

25                         ↓

26     ┌──────────────────────────────────────────────┐

27     │  BƯỚC 4: THỰC HIỆN                           │

28     ├──────────────────────────────────────────────┤

29     │  - Bảo vệ đề cương (≤30 ngày sau ký HĐ)      │

30     │  - Triển khai theo kế hoạch                  │

31     │  - Gia hạn: trước 45-60 ngày                 │

32     │  - Báo cáo tiến độ định kỳ                   │

33     └──────────────────────────────────────────────┘

34                         ↓

35     ┌──────────────────────────────────────────────┐

36     │  BƯỚC 5: NGHIỆM THU & QUYẾT TOÁN             │

37     ├──────────────────────────────────────────────┤

38     │  - Nộp hồ sơ trước 45 ngày                   │

39     │  - KHKT kiểm tra (3 ngày)                    │

40     │  - Lập hội đồng (5 ngày)                     │

41     │  - Họp hội đồng (7-11 thành viên, 2/3)       │

42     │  - Chỉnh sửa (5 ngày) + bảo vệ lại (30 ngày) │

43     │  - Quyết toán + chi thưởng                   │

44     └──────────────────────────────────────────────┘


## 4.2. Hội đồng KH&CN (KHCN_Council Module)


### Thành phần hội đồng

1     Hội đồng 7-11 thành viên:

2     ├── Chủ tịch

3     ├── Phó Chủ tịch

4     ├── Thư ký

5     ├── 2 Ủy viên phản biện (min)

6     └── Ủy viên thường trực


### Quy tắc họp

Quorum: ≥ 2/3 thành viên có mặt

Bắt buộc: Chủ tịch hoặc Phó CT + 1 phản biện + Thư ký

Quyết định: > 2/3 nhất trí

Hình thức: Tập trung hoặc trực tuyến

Tài liệu gửi trước: ≥ 7 ngày

Ý kiến phản biện: Trong 10 ngày

Biên bản gửi: Trong 7 ngày


### IDOP Features cho Hội đồng

✅ Auto-check quorum (real-time)

✅ Quản lý thành viên + chứng chỉ

✅ Upload phiếu chấm điểm online

✅ Auto-calc điểm trung bình

✅ Lưu video/audio họp trực tuyến

✅ Audit trail toàn bộ phiên họp


## 4.3. Power Automate Flows mới (8 flows)

1     Flow_KHCN_Proposal_Submission

2        → Nộp đề xuất nhiệm vụ

3     Flow_KHCN_Proposal_Review

4        → Thẩm tra đề cương sơ bộ

5     Flow_KHCN_Contract_Signing

6        → Quy trình ký HĐ KH&CN

7     Flow_KHCN_Assignment

8        → Quyết định giao nhiệm vụ

9     Flow_KHCN_Milestone_Tracking

10        → Theo dõi mốc, cảnh báo gia hạn

11     Flow_KHCN_Acceptance_Council

12        → Tổ chức hội đồng nghiệm thu

13     Flow_KHCN_IP_Registration

14        → Đăng ký sở hữu trí tuệ

15     Flow_KHCN_Incentive_Calculation

16        → Tính thưởng tự động


## 4.4. SLA Engine cho KH&CN

Hoạt động

SLA

Owner

Thẩm tra đề xuất

7 ngày

KHKT

Ký HĐ sau duyệt

10 ngày

TCHC + Lãnh đạo

Giao việc

3 ngày sau ký HĐ

Đơn vị chủ trì

Bảo vệ đề cương

30 ngày sau ký HĐ

Chủ nhiệm

Nộp hồ sơ nghiệm thu

45 ngày trước hạn

Chủ nhiệm

KHKT kiểm tra hồ sơ

3 ngày

KHKT

Lập hội đồng

5 ngày

KHKT

Gửi tài liệu hội đồng

7 ngày trước họp

KHKT

Ý kiến phản biện

10 ngày

Phản biện

Gửi biên bản

7 ngày sau họp

Thư ký

Chỉnh sửa sản phẩm

5 ngày sau họp

Chủ nhiệm

Bảo vệ lại

30 ngày

Chủ nhiệm


## 4.5. IP Management Module

1     LST-KHCN-IP cấu trúc:

2     ├── IP_ID (auto)

3     ├── IP_Type (sáng chế/giải pháp/TCVN/QCVN)

4     ├── Title (tên)

5     ├── Owners (chủ sở hữu - phụ thuộc nhóm)

6     ├── Inventors (tác giả)

7     ├── ApplicationDate (ngày nộp đơn)

8     ├── GrantedDate (ngày cấp bằng)

9     ├── Status (đang xét/đã cấp/hết hạn)

10     ├── Documents (giấy chứng nhận)

11     ├── RelatedTask (lookup KHCN_Tasks)

12     └── CommercializationStatus (chuyển giao)

Quyền sở hữu theo Điều 13 QCKHCN 2816:

Nhóm

Quyền IP

Nhóm 1

Theo cấp giao nhiệm vụ (thường thuộc Nhà nước)

Nhóm 2

Theo HĐ với bên A

Nhóm 3

Thuộc Viện

Nhóm 4

Thuộc Viện (Viện trưởng quyết định chuyển giao)


## 4.6. Incentive Engine

Tự động tính thưởng dựa trên rule:

1     function calc_incentive(achievement_type, value):

2         if achievement_type == "ISI_Paper":

3             return 50_000_000

4         elif achievement_type == "Scopus_Paper":

5             return 30_000_000

6         elif achievement_type == "Patent":

7             return 50_000_000

8         elif achievement_type == "Excellent_Topic":

9             return min(value * 0.1, 100_000_000)

10         elif achievement_type == "QCVN_Issued":

11             return min(value * 0.1, 60_000_000)

12         elif achievement_type == "TCVN":

13             return min(value * 0.05, 20_000_000)

14         # ... etc

Integration với KPI:

Số bài báo → KPI cá nhân

Số sáng chế → KPI phòng ban

Tổng kinh phí KH&CN → KPI Viện



# PHẦN 5. TÍCH HỢP HỆ SINH THÁI (INTEGRATION)


## 5.1. Kiến trúc Integration Layer (Enhanced)

1     ┌────────────────────────────────────────────┐

2     │  CCBA IDOP Core (SharePoint + Power)       │

3     └──────────────────┬─────────────────────────┘

4                        │

5             ┌──────────▼──────────┐

6             │   API GATEWAY        │

7             │   (Azure API Mgmt)   │

8             └──────────┬──────────┘

9                        │

10        ┌───────────────┼───────────────┐

11        │               │               │

12        ▼               ▼               ▼

13     ┌──────┐      ┌────────┐      ┌─────────┐

14     │ IBST │      │ Bộ XD  │      │ Bộ KHCN │

15     │ APIs │      │ APIs   │      │ APIs    │

16     └──────┘      └────────┘      └─────────┘

17        │               │               │

18        ▼               ▼               ▼

19     ┌──────┐      ┌────────┐      ┌─────────┐

20     │ BIM  │      │ Tax    │      │ IP      │

21     │ Tools│      │ System │      │ Office  │

22     └──────┘      └────────┘      └─────────┘


## 5.2. API Catalog (đề xuất)


### Internal APIs (CCBA ↔ IBST)

API

Mục đích

Method

/api/v1/contracts/vien-ky

Đồng bộ HĐ Viện ký

POST/GET

/api/v1/finance/distribution

Phân phối tài chính

POST

/api/v1/khkt/contract-approval

Thẩm tra HĐ

POST

/api/v1/tckt/invoice-request

Xuất hóa đơn

POST

/api/v1/tchc/document-storage

Lưu trữ hồ sơ

POST


### External APIs (CCBA ↔ Bộ)

API

Mục đích

Standard

BXD eGov API

Cổng dịch vụ công

REST/OAuth 2.0

BKHCN Task Registry

Đăng ký nhiệm vụ KH&CN

REST

eTax API

Khai thuế điện tử

SOAP/REST

KBNN API

Kho bạc Nhà nước

Specific

IP Office API

Đăng ký sáng chế

REST


### Industry APIs

API

Mục đích

Autodesk Forge

BIM 360 integration

Springer/Elsevier

Submit bài báo

Scopus Search

Tra cứu indexing

DOI Registry

Đăng ký DOI


## 5.3. Event-Driven Architecture

1     Event Bus (Azure Event Grid / Service Bus)

2             │

3             ├── Event: ContractSigned

4             │     └→ Trigger: KHKT, TCKT, TCHC, Project Site

5             │

6             ├── Event: PaymentReceived

7             │     └→ Trigger: Distribution, P2 Calc, Notification

8             │

9             ├── Event: KHCNTaskAccepted

10             │     └→ Trigger: IP Registration, Publication, Incentive

11             │

12             ├── Event: PublicationApproved

13             │     └→ Trigger: KPI Update, Incentive Engine

14             │

15             └── Event: PatentGranted

16                   └→ Trigger: Asset Registry, Commercialization


## 5.4. Identity Federation

1     ┌─────────────────────────────────────┐

2     │  Microsoft Entra ID (CCBA tenant)   │

3     └──────────────┬──────────────────────┘

4                    │ Federation

5                    ▼

6     ┌─────────────────────────────────────┐

7     │  IBST Identity Provider             │

8     └──────────────┬──────────────────────┘

9                    │ Federation

10                    ▼

11     ┌─────────────────────────────────────┐

12     │  Government SSO (eGov)              │

13     └─────────────────────────────────────┘

Benefits:

1 tài khoản truy cập đa hệ thống

Centralized policy management

Audit trail xuyên hệ thống



# PHẦN 6. ROADMAP v2.0 → v4.0


## 6.1. Tổng quan roadmap

1     v2.0 ────► v2.1 ────► v2.5 ────► v3.0 ────► v4.0

2     Q3/2026   Q4/2026   Q2/2027   Q4/2027   Q2/2028

3     CCBA      + KH&CN   + IBST    Enterprise  AI-driven

4     Digital   Module    Integ.    Platform   Organization

5     Ops


## 6.2. v2.0 - CCBA Digital Operations (Q3/2026) ✅

Trạng thái: Đang triển khai (theo FILE 1, 2, 3)

Outcomes:

8-layer architecture

33 SharePoint Lists

40+ Power Automate Flows

3-tier financial allocation

5-level QA/QC

7-step workflow


## 6.3. v2.1 - KH&CN Module Integration (Q4/2026)

Mục tiêu: Tích hợp module KH&CN theo Quy chế 2816

Deliverables:

7 LST-KHCN-* lists

8 Flow_KHCN_* flows

KH&CN Council Management

IP Management Module

Incentive Engine

Publication tracking

Mapping với QCKHCN 2816

Effort: ~3 tháng, 5 người


## 6.4. v2.5 - IBST Integration (Q2/2027)

Mục tiêu: Liên thông IDOP CCBA với hệ thống Viện

Deliverables:

API Gateway (Azure API Management)

Identity Federation (CCBA ↔ IBST)

Auto-sync HĐ Viện ký với KHKT

Auto-sync tài chính với TCKT

Auto-sync hồ sơ với TCHC

Single dashboard cấp Viện

Effort: ~4 tháng, 8 người


## 6.5. v3.0 - Enterprise Platform (Q4/2027)

Mục tiêu: Nâng cấp IDOP thành nền tảng cấp Viện hoàn chỉnh

Deliverables:

Multi-tenant architecture (CCBA, các Trung tâm khác)

Data Lake + Power BI Premium

Master Data Management

Workflow orchestration cấp Viện

Tích hợp Bộ XD (eGov)

Tích hợp Bộ KH&CN

Tích hợp eTax, KBNN

Mobile apps đầy đủ

Effort: ~6 tháng, 15 người


## 6.6. v4.0 - AI-driven Organization (Q2/2028)

Mục tiêu: Tổ chức vận hành dựa trên AI

Deliverables:

Predictive Analytics (rủi ro dự án, gian lận tài chính)

AI Co-pilot cho từng vai trò

Automated decision support

Knowledge Graph cấp Viện

Natural Language Querying

Computer Vision cho BIM

Generative AI cho báo cáo

Effort: ~6 tháng, 20 người


## 6.7. Investment Summary

Phiên bản

Thời gian

Effort

Budget ước tính

v2.0

9 tháng

12 người

2-3 tỷ

v2.1

3 tháng

5 người

0.8-1 tỷ

v2.5

4 tháng

8 người

1.5-2 tỷ

v3.0

6 tháng

15 người

4-5 tỷ

v4.0

6 tháng

20 người

6-8 tỷ

Tổng

28 tháng

-

15-19 tỷ



# PHẦN 7. MAPPING QUY CHẾ 2816 (KH&CN)


## 7.1. Quy chế tham chiếu

Quy chế Thực hiện nhiệm vụ KH&CN của Viện KHCN Xây dựng

Số: 2816/QĐ-VKH

Ngày ban hành: 01/12/2025

Hiệu lực: 01/01/2026


## 7.2. Cấu trúc Quy chế

1     Chương I.   Quy định chung (Điều 1-4)

2     Chương II.  Thực hiện nhiệm vụ KH&CN (Điều 5-16)

3     Chương III. Họp Hội đồng trực tuyến (Điều 17-19)

4     Chương IV.  Trách nhiệm các bên (Điều 20-22)

5     Chương V.   Thưởng - Phạt (Điều 23+)

6     Phụ lục: Quy trình, biểu mẫu


## 7.3. Mapping IDOP

Điều

Nội dung

Module IDOP

Điều 1

Phạm vi điều chỉnh (4 nhóm nhiệm vụ)

CCBA_KHCN_TaskGroup

Điều 3

Giải thích từ ngữ

Term Store mở rộng

Điều 4

Nguyên tắc thực hiện

Workflow Engine

Điều 5

Trình tự thực hiện (5 bước)

Flow_KHCN_*

Điều 6

Đăng ký nhiệm vụ

Flow_KHCN_Proposal_Submission

Điều 7

Xây dựng HĐ KH&CN

Flow_KHCN_Contract_Signing

Điều 9

Giao nhiệm vụ

Flow_KHCN_Assignment

Điều 10

Thực hiện HĐ

Milestone Tracking

Điều 11-13

Kiểm tra, nghiệm thu

Flow_KHCN_Acceptance_Council

Điều 14

TCVN/QCVN

Standards Module

Điều 15

Hồ sơ tài chính

Financial Module

Điều 16

Cơ chế thúc đẩy KH&CN

Incentive Engine

Điều 17-19

Họp online

Council Online Module

Điều 20

Trách nhiệm Trưởng đơn vị

Permission Matrix

Điều 21

Trách nhiệm Phòng KHKT/TCKT/TCHC

RACI cấp Viện

Điều 22

Trách nhiệm Lãnh đạo Viện

Executive Dashboard

Điều 23

Thưởng

Incentive Engine


## 7.4. Tích hợp 4 Quy chế

Khi hoàn thiện v2.1, IDOP tích hợp 4 hệ thống quy chế:

1     ┌──────────────────────────────────────────┐

2     │  Quy chế CCBA 2026 (cấp Trung tâm)       │

3     └─────────────────┬────────────────────────┘

4                       │

5     ┌─────────────────▼────────────────────────┐

6     │  QCTK 2815/QĐ-VKH (Triển khai)          │

7     │  QCCTNB 3209/QĐ-VKH (Chi tiêu)          │

8     │  QCKHCN 2816/QĐ-VKH (KH&CN) 🆕          │

9     │  (3 Quy chế cấp Viện)                    │

10     └──────────────────────────────────────────┘



# PHẦN 8. GOVERNANCE FRAMEWORK


## 8.1. Data Governance


### Data Ownership

Data Domain

Owner

Steward

Customer Data

GĐ CCBA

TP R&D

Financial Data

GĐ CCBA

Kế toán Đơn vị

Project Data

TP BIM Dự án

PM

BIM Data

TP BIM Thiết kế

BIM Manager

HR Data

TP Tổng hợp

HR Officer

KH&CN Data

TP R&D

Researcher

IP Data

GĐ CCBA

Legal/QA


### Data Lifecycle

1     Creation → Validation → Storage → Usage → Archive → Disposal

2        ↑                                                    │

3        └────────────── Backup & Recovery ──────────────────┘


### Data Quality Standards

Completeness: ≥ 95% các trường bắt buộc

Accuracy: Validation rules tự động

Consistency: Single Source of Truth

Timeliness: Update theo SLA

Uniqueness: No duplicates

Integrity: Referential integrity


## 8.2. Compliance Framework


### Compliance Domains

1     ┌──────────────────────────────────────┐

2     │  Pháp lý                              │

3     │  - Luật Đầu tư công                  │

4     │  - Luật Xây dựng                     │

5     │  - Luật KH&CN                        │

6     │  - Luật Sở hữu trí tuệ               │

7     └──────────────────────────────────────┘

8     ┌──────────────────────────────────────┐

9     │  Tiêu chuẩn                          │

10     │  - ISO 9001:2015                     │

11     │  - ISO 19650 (BIM)                   │

12     │  - ISO 27001 (Security)              │

13     └──────────────────────────────────────┘

14     ┌──────────────────────────────────────┐

15     │  Nội bộ                              │

16     │  - QCTK 2815                         │

17     │  - QCCTNB 3209                       │

18     │  - QCKHCN 2816                       │

19     │  - QCCCBA 2026                       │

20     └──────────────────────────────────────┘


### Audit Schedule

Loại audit

Tần suất

Thực hiện

Internal Audit

Quý

Cố vấn QLCL

ISO 9001 Audit

Năm

External auditor

Financial Audit

Năm

Kiểm toán Nhà nước

Security Audit

6 tháng

Security team

Compliance Audit

Quý

Legal


## 8.3. Change Management


### Change Categories

1     Level 1 - Minor (UI tweaks, content updates)

2        → Approval: IDOP Admin

3

4     Level 2 - Standard (new fields, minor flows)

5        → Approval: IDOP Lead + Department Head

6

7     Level 3 - Major (new modules, schema changes)

8        → Approval: BGĐ CCBA + IDOP Committee

9

10     Level 4 - Strategic (new integrations, v upgrade)

11        → Approval: Lãnh đạo Viện


### Change Workflow

1     1. Change Request →

2     2. Impact Assessment →

3     3. CAB Review →

4     4. Approval →

5     5. DEV →

6     6. UAT →

7     7. PROD →

8     8. Post-implementation Review


## 8.4. Risk Management


### Risk Register

ID

Risk

Probability

Impact

Mitigation

R001

Vi phạm quy chế tài chính

M

H

Auto-block + Audit

R002

Mất dữ liệu

L

H

Daily backup + DR

R003

Tấn công mạng

M

H

MFA + Zero Trust

R004

Phụ thuộc Microsoft

H

M

Open standards + Export

R005

Thiếu nhân lực

M

M

Đào tạo + Tài liệu

R006

Quy chế thay đổi

H

M

Modular config



# PHẦN 9. AI & EMERGING TECHNOLOGIES


## 9.1. AI Roadmap


### Hiện tại (v2.0)

Microsoft Copilot (Chat, Word, Excel, Teams)

OCR danh thiếp

Email parsing


### v2.1 - v2.5

Document classification AI

Smart metadata suggestions

Risk prediction (project delay, financial fraud)

KPI insights & anomaly detection


### v3.0 - v4.0

Custom Copilot per role

Knowledge Graph

Natural Language Querying

Generative AI for reports

Computer Vision cho BIM models

Predictive resource allocation


## 9.2. Emerging Technologies


### Blockchain

1     Use cases tiềm năng:

2     - IP Registry (không thể thay đổi)

3     - Smart contracts cho HĐ

4     - Audit trail bất biến

5     - Chứng nhận chất lượng


### Digital Twin

1     Use cases:

2     - Digital Twin của Tổ chức (DTO)

3     - Digital Twin của dự án BIM

4     - Simulation kịch bản triển khai

5     - "What-if" analysis


### IoT

1     Use cases:

2     - Sensor công trường (TVGS)

3     - Smart Office (CCBA HCM)

4     - Asset tracking (thiết bị)

5     - Environmental monitoring


### Augmented Reality (AR)

1     Use cases:

2     - BIM model visualization on-site

3     - Remote inspection

4     - Training simulations

5     - As-built verification


## 9.3. AI Governance


### Responsible AI Principles

Fairness - Không phân biệt đối xử

Reliability - Hoạt động ổn định, có thể dự đoán

Privacy - Bảo vệ dữ liệu cá nhân

Inclusiveness - Phục vụ mọi đối tượng

Transparency - Giải thích được quyết định

Accountability - Có người chịu trách nhiệm


### AI Ethics Committee

Chủ tịch: Giám đốc CCBA

Thành viên: Phụ trách Nền tảng Số, Cố vấn Pháp lý, đại diện R&D

Họp định kỳ: Quý

Reviews: Mọi AI use case mới



# PHẦN 10. KẾT LUẬN & TẦM NHÌN 2030


## 10.1. Tóm tắt FILE 4

FILE 4 định hướng nâng cấp IDOP từ:

1     🔵 IDOP v2.0 (CCBA - 2026)

2          │

3          ▼

4     🟢 IDOP v2.1 (CCBA + KH&CN - 2027)

5          │

6          ▼

7     🟡 IDOP v3.0 (IBST Enterprise - 2028)

8          │

9          ▼

10     🔴 IDOP v4.0 (AI-driven - 2028+)


## 10.2. Giá trị chiến lược


### Cho CCBA

Số hóa toàn diện

Tăng năng suất 30-50%

Giảm sai sót 70%+

Tuân thủ tuyệt đối quy chế


### Cho Viện IBST

Liên thông các đơn vị

Tổng hợp dữ liệu cấp Viện

Báo cáo Bộ chính xác hơn

Tăng năng lực cạnh tranh


### Cho Bộ Xây dựng

Tích hợp eGov

Tham chiếu best practice

Mô hình mẫu cho ngành


### Cho Quốc gia

Tăng năng lực KH&CN xây dựng

Đóng góp chuyển đổi số quốc gia

Reference architecture


## 10.3. Tầm nhìn 2030

"Đến 2030, IDOP trở thành Digital Operating System hàng đầu của ngành xây dựng Việt Nam, kết nối Viện KHCN Xây dựng với hệ sinh thái Bộ Xây dựng, Bộ KH&CN, các đối tác nghiên cứu quốc tế, và đóng vai trò nền tảng cho chuyển đổi số ngành xây dựng quốc gia."


## 10.4. Cam kết thực hiện

Để hiện thực hóa tầm nhìn:

✅ Lãnh đạo CCBA cam kết:

Phân bổ ngân sách phù hợp

Hỗ trợ change management

Lãnh đạo bằng tấm gương

✅ Đội ngũ kỹ thuật cam kết:

Triển khai đúng tiến độ

Đảm bảo chất lượng

Liên tục học hỏi

✅ Toàn thể VCNLĐ cam kết:

Sử dụng IDOP đúng cách

Cung cấp phản hồi

Tuân thủ quy trình


## 10.5. Lời kết

IDOP không phải là đích đến, mà là hành trình.

Mỗi phiên bản mới là một bước tiến trong hành trình chuyển đổi số bền vững của CCBA và Viện IBST. FILE 4 đặt nền móng cho hành trình từ một hệ thống nội bộ trở thành một nền tảng chiến lược cấp quốc gia.

Hãy cùng nhau xây dựng tương lai số của ngành xây dựng Việt Nam!



## 🔗 CROSS-REFERENCE NGƯỢC

FILE 4 có liên kết ngược với:

FILE 1 - Mở rộng kiến trúc 8 lớp → 10 lớp

FILE 2 - Bổ sung 5 bước KH&CN + bảng định mức KH&CN

FILE 3 - Module KH&CN + 8 Flows mới + lộ trình v2.1-v4.0



# 🖋️ TRANG PHÊ DUYỆT FILE 4

Tài liệu Khung Mở rộng IDOP Enterprise ArchitecturePhiên bản 1.0 (Bổ sung cho IDOP v2.0)

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


--- HẾT FILE 4/4 ---



# 🎉 BỘ TÀI LIỆU IDOP v2.0

File

Tên

Số phần

Trạng thái

✅ FILE 1/4

Kiến trúc tổng quan

I-VIII

Hoàn thành

✅ FILE 2/4

Vận hành và Tài chính

IX-XI

Hoàn thành

✅ FILE 3/4

Yêu cầu kỹ thuật và Triển khai

XII-XIV

Hoàn thành

✅ FILE 4/4

Enterprise Architecture

10 phần

Hoàn thành
