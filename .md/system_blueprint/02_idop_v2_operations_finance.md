
# 📘 FILE 2/4 - VẬN HÀNH VÀ TÀI CHÍNH IDOP v2.0

Tài liệu: Mô tả Kiến trúc và Yêu cầu Thiết kế Hệ thống IDOPPhần: IX - XI (Vận hành và Tài chính)Phiên bản: 2.0Ngày: 27/06/2026Đơn vị: CCBA - Trung tâm Tư vấn và Ứng dụng BIM trong Xây dựng



## 🔗 BỘ TÀI LIỆU LIÊN QUAN

File

Tên

Phạm vi

FILE 1/4

Kiến trúc tổng quan

Phần I-VIII

FILE 2/4

Vận hành và Tài chính

Phần IX-XI (file này)

FILE 3/4

Yêu cầu kỹ thuật và Triển khai

Phần XII-XIV

FILE 4/4

Enterprise Architecture

Khung mở rộng cấp Viện



## MỤC LỤC FILE 2

1     PHẦN IX.   QUY TRÌNH VẬN HÀNH 7 BƯỚC

2     PHẦN X.    CƠ CHẾ TÀI CHÍNH 3 TẦNG

3     PHẦN XI.   ĐỊNH MỨC CHI TIÊU TÍCH HỢP

4     PHỤ LỤC.   CROSS-REFERENCE ĐẾN FILE 4



# PHẦN IX. QUY TRÌNH VẬN HÀNH 7 BƯỚC


## 9.1. Tổng quan 7 bước (Theo QCTK 2815)

Toàn bộ vòng đời hợp đồng được vận hành theo 7 bước liên hoàn, tuân thủ Quy chế Triển khai 2815/QĐ-VKH:

STT

Tên bước

Mô tả tóm tắt

Bước 1

Đấu thầu (Điều 5)

Tìm kiếm cơ hội, đăng ký đầu mối, lập hồ sơ dự thầu

Bước 2

Trình ký Hợp đồng (Điều 6)

Soạn, thẩm tra, phê duyệt, đóng dấu, lưu trữ

Bước 3

Phê duyệt PGV (Điều 7)

Lập Phiếu Giao Việc với 4 luồng theo loại HĐ

Bước 4

Quản lý thực hiện (Điều 8-9)

5 luồng song song: SX, QA/QC, TC, ATLD, BC

Bước 5

Kiểm tra nội bộ (Điều 10)

CCBA tự kiểm tra + Viện kiểm tra định kỳ

Bước 6

Nghiệm thu (Điều 11)

Nghiệm thu giai đoạn + thanh lý

Bước 7

Quyết toán (Điều 11-12 + QCCTNB)

Phân phối 3 tầng + thanh quyết toán

💡 Mở rộng FILE 4: Module KHCN_5Steps_Workflow cho nhiệm vụ KH&CN (Đăng ký → HĐ → Giao việc → Thực hiện → Nghiệm thu) - xem FILE 4 Phần 2.2.


## 9.2. Bước 1 - Đấu thầu


### Luồng hoạt động

1     VCNLĐ phát hiện cơ hội

2        ↓

3     Báo cáo GĐ CCBA

4        ↓

5     Đăng ký đầu mối với KHKT Viện

6        ↓

7     KHKT báo cáo Viện trưởng

8        ↓

9     LĐ Viện quyết định tham gia/không

10        ↓

11     KHKT phản hồi CCBA

12        ↓

13     GĐ CCBA chỉ định chủ trì

14        ↓

15     Lập hồ sơ dự thầu


### Phân loại HĐ và đầu mối xây dựng

Loại HĐ

Đầu mối

Yêu cầu

Nhóm 1

CCBA + Phòng KHKT

Báo cáo Viện trưởng trước khi xây dựng

Nhóm 2,3,4 phức tạp

Phòng KHKT phối hợp

HĐ kỹ thuật phức tạp, chính trị

Nhóm 2,3,4 còn lại

CCBA trực tiếp

Đơn vị tự chủ


## 9.3. Bước 2 - Trình ký Hợp đồng


### Phân cấp ký kết theo Điều 6 QCTK

Cấp ký

Phạm vi

Viện trưởng

Nhóm 1, HĐ phức tạp, chính trị, pháp lý, Bộ giao

Phó Viện trưởng

Theo ủy quyền, theo lĩnh vực phụ trách

GĐ CCBA

HĐ còn lại trong phạm vi phân cấp


### HĐ phải báo cáo Viện trưởng

HĐ Nhóm 1

HĐ kỹ thuật phức tạp, chính trị, pháp lý

HĐ Bộ giao

HĐ ≥ 2 tỷ kiểm định, ≥ 5 tỷ tư vấn, ≥ 10 tỷ thi công


### Luồng A: HĐ Viện ký

1     Chủ trì → TP → TH CCBA → GĐ CCBA → KHKT Viện (≤1 ngày)

2     → LĐ Viện → TCHC Viện → Gửi Bên A → Lưu trữ ≤30 ngày


### Luồng B: HĐ CCBA ký

1     Chủ trì → TP → TH CCBA → GĐ CCBA → TH CCBA đóng dấu

2     → Gửi Bên A → Lưu trữ tại CCBA


### Cảnh báo quan trọng

KHKT thẩm tra ≤ 1 ngày làm việc

Phản hồi trong 6h nếu chưa đủ điều kiện

Lưu trữ ≤ 30 ngày (phạt 0.5% N2, 0.1% N3/N4 nếu vi phạm)


## 9.4. Bước 3 - Phê duyệt PGV (4 luồng)

Bước 3 là bước then chốt vì PGV là cơ sở pháp lý nội bộ để triển khai.


### Nguyên tắc cốt lõi

PGV phải trình cùng hồ sơ ký HĐ

Nội dung theo mẫu chung của Viện

Một cá nhân chủ trì duy nhất

Chủ trì phải có chứng chỉ hành nghề phù hợp


### 4 Luồng phê duyệt theo loại HĐ

Luồng

Áp dụng cho

Quy trình

Thời gian

A

HĐ Viện ký thông thường

Chủ trì → TP → TH → GĐ → KHKT → LĐ Viện → TCHC

5-7 ngày

B

HĐ Quản lý tập trung (TVGS, QLDA, Thi công)

GĐ → KHKT → LĐ Viện → Nhân sự đơn vị

3-5 ngày

C

HĐ phức tạp, Bộ giao

KHKT đề xuất → Viện trưởng ký

7-10 ngày

D

HĐ CCBA phân cấp ký

Chủ trì → TP → TH → GĐ CCBA

2-3 ngày


### Nội dung PGV phải xác định

Đơn vị chủ trì

Chủ trì hợp đồng (1 cá nhân duy nhất)

Chủ trì kỹ thuật / chủ nhiệm

Chủ trì bộ môn

Cộng tác viên (CTV)

Đơn vị phối hợp

Tỷ lệ phân chia giá trị HĐ giữa các đơn vị

Kinh phí giao thực hiện (theo Phụ lục 7)

Tiến độ và phạm vi công việc


### Validation bắt buộc

✅ Chủ trì có chứng chỉ hành nghề phù hợp

✅ CTV nội bộ có HĐLĐ

✅ CTV ngoài Viện có HĐ giao khoán

✅ Tổng tỷ lệ phân chia = 100%

✅ Phân bổ tự động theo Phụ lục 7 QCCTNB 3209


## 9.5. Bước 4 - Quản lý thực hiện (5 luồng song song)

Bước 4 là bước có vòng đời dài nhất, gồm 5 luồng song song.


### Luồng 1: Triển khai sản xuất kỹ thuật

Tổ chức công việc theo cấu trúc 4 vai trò:

Chủ trì HĐ → Chủ trì kỹ thuật → Chủ trì bộ môn → CTV/Tác giả

Mọi work item nộp lên CDE-WIP. Timesheet bắt buộc hàng ngày.


### Luồng 2: 5 cấp QA/QC (Trọng tâm)

Mọi sản phẩm đi qua 5 cấp trên IDOP-CDE trước khi phát hành (theo Điều 13 Quy chế CCBA 2026).


### Luồng 3: Quản lý tài chính dự án

Tạm ứng max 90% (cập nhật từ 70%)

Kiểm soát chứng từ

Hoàn thuế GTGT 80%

Thanh toán không TM ≥ 5tr


### Luồng 4: ATLD và hiện trường

Mobile app cho công trường

Briefing ATLD đầu ca

Nhật ký công trường

Audit ATLD định kỳ

Áp dụng cho TVGS, QLDA, Thi công, Kiểm định.


### Luồng 5: Theo dõi tiến độ và báo cáo

Daily standup

Weekly review

Friday 17:00 snapshot KPI

Monthly BGĐ review


### Nguyên tắc bất biến của Bước 4

Mọi thao tác để lại dấu vết số trên IDOP - Digital First

Mọi phê duyệt qua E-Approval - không qua chat cá nhân

5 cấp QA/QC bắt buộc cho mọi sản phẩm kỹ thuật

CDE state machine: WIP → Shared → Published → Archive

Lưu vết trách nhiệm - Audit Trail toàn diện

Trách nhiệm giải trình đơn nhất

Hồ sơ ra ngoài bắt buộc in + ký tươi + dấu đỏ

Tuân thủ ATLD tuyệt đối

Update IDOP chậm nhất Thứ Sáu 16h00


## 9.6. Bước 5 - Kiểm tra nội bộ


### Cơ chế kiểm tra theo Điều 10 QCTK 2815

CCBA tự kiểm tra: Các HĐKT do đơn vị phân cấp ký

Viện kiểm tra định kỳ: Theo kế hoạch hàng năm

Viện kiểm tra đột xuất: Khi có nghi vấn


### Thành phần và nội dung kiểm tra

1     Thành phần:

2     - Lãnh đạo Viện phụ trách

3     - Đại diện TCKT, KHKT, TCHC

4     - Chuyên gia theo lĩnh vực (nếu cần)

5

6     Nội dung:

7     - Pháp lý thực hiện HĐ

8     - Hồ sơ thực hiện

9     - Sản phẩm

10     - Khối lượng công việc

11     - Tiến độ thực hiện

12     - Sử dụng kinh phí

13     - Hồ sơ chứng từ

14

15     Kết quả:

16     - Lập biên bản

17     - Báo cáo Viện trưởng

18     - Thông báo bên liên quan

19     - Kiến nghị phải được thực hiện nghiêm túc


## 9.7. Bước 6 - Nghiệm thu


### Nghiệm thu giai đoạn (HĐ Viện ký)

1     Chủ trì → TP → GĐ CCBA → KH ký BBNT

2     → KT đề nghị xuất HĐ → TCKT Viện xuất hóa đơn → Tiền về


### Nghiệm thu thanh lý cuối cùng

1     Toàn bộ sản phẩm hoàn thành → QA Audit cuối cùng

2     → KT đối chiếu → GĐ phê duyệt → KH ký BBTL

3     → Tiền về đủ → Chuyển Bước 7


### Nguyên tắc Thực thu - Thực chi (Điều 14 CCBA 2026)

Khối lượng đã nghiệm thu hợp lệ trên IDOP

Tiền thanh toán đã chuyển về tài khoản Viện/Trung tâm

Chứng từ hoàn chỉnh tới đâu, thanh toán giai đoạn tới đó

IDOP chỉ hỗ trợ đối chiếu, mọi giao dịch tài chính cần chứng từ giấy


### SLA Bước 6

TCKT Viện xử lý ≤ 3 ngày/việc

Phụ trách KT CCBA xử lý ≤ 24h

Cảnh báo công nợ ≥ 45 ngày

Cảnh báo nợ xấu ≥ 90 ngày


## 9.8. Bước 7 - Phân phối và Thanh quyết toán


### Quy trình quyết toán gồm 7 bước con

Phân phối theo Phụ lục 7 (QCCTNB)

Phân phối nội bộ theo Phụ lục 02 (CCBA)

Tạm ứng 90% / Quyết toán cuối khi đủ điều kiện

Tính P2 (Khối Trực tiếp) / P2_GT (Khối Gián tiếp)

Khấu trừ TNCN tại nguồn theo biểu lũy tiến

Trích lập 5 quỹ theo Điều 19 QCCTNB

Clawback monitoring 12 tháng sau quyết toán


### Cảnh báo tự động

🚨 Auto-block tạm ứng vượt 90%

🚨 Auto-block chi không có hóa đơn

⚠️ Công nợ ≥ 45 ngày: cảnh báo

⚠️ Nợ xấu ≥ 90 ngày: cảnh báo nghiêm trọng


### Ma trận RACI cho Bước 7

Hoạt động

Chủ trì

TP

GĐ CCBA

KT

QA

LĐ Viện

Lập BBNT nội bộ

R/A

C

I

I

-

-

Đề nghị xuất HĐ

R

I

A

C

-

-

Phê duyệt phân phối

C

C

R

C

-

A

Tính P2

I

C

A

R

C

-

Khấu trừ TNCN

I

-

A

R

-

-

Clawback monitoring

-

-

A

R

C

-



# PHẦN X. CƠ CHẾ TÀI CHÍNH 3 TẦNG


## 10.1. Mô hình 3 tầng phân bổ tài chính

Hệ thống IDOP triển khai mô hình phân bổ tài chính 3 tầng, tự động hóa toàn bộ:


### Tầng 1: Phụ lục 7 QCCTNB 3209 (Phân bổ cấp Viện)

Tại Viện (CPQL + KHTSCĐ): theo Cột 6 + Cột 7

Giao đơn vị CCBA: 96-74% tùy nhóm HĐ (Cột 5)


### Tầng 2: Phụ lục 02 Quy chế CCBA 2026 (Phân bổ nội bộ CCBA)

Cột 3 - Giao Chủ trì: 59-92% tùy nhóm HĐ

Cột 4 - Giữ lại CCBA: 4-15% tùy nhóm HĐ


### Tầng 3: Chi tiết khối Trực tiếp và Gián tiếp

Từ Cột 3 (Khối Trực tiếp):

Nhân công NC theo Phụ lục 8: 25-65% tùy nhóm

Vật tư, vật liệu

Thiết bị, máy móc

Chi phí khác

P2 = (Cột 3 - CP hợp lệ) × Tỷ lệ phân chia × Hệ số KPI

Từ Cột 4 (Khối Gián tiếp):

Lương cấp bậc + BHXH, BHYT, BHTN, KPCĐ

Thu nhập dịch vụ: GĐ 4.5 / PGĐ 3.0 / TP-KT 2.6

Hoạt động chung: điện, nước, IDOP, marketing

R&D + Đào tạo

P2_GT = (Chênh lệch khả dụng / Tổng Hệ số CCBA) × Hệ số chức danh × Hệ số KPI


## 10.2. Bảng định mức tổng hợp 3 nguồn

Bảng định mức tổng hợp được cấu hình vào IDOP để auto-calculate:

Nhóm

Loại dịch vụ

Giao ĐV

CPQL

KHTSCĐ

NC tối đa

Tạm ứng

VAT

N1a

Giám định

96%

2%

2%

Quyết toán

90%

10%

N2a

Tư vấn QLDA, BIM

91%

7%

2%

50-65%

90%

10%

N2b

HCHQ

85%

13%

2%

50-65%

90%

5%

N2c

Đào tạo

85%

13%

2%

50-65%

90%

-

N2d

Khảo sát, kiểm định

87%

8%

5%

30-55%

90%

10%

N2e

TN hiện trường

82%

8%

10%

30-55%

90%

10%

N2f

TN trong phòng

74%

16%

10%

25-40%

90%

10%

N2g

TN đặc thù

91%

6%

3%

40-55%

90%

10%

N3

Thi công

95%

4.5%

0.5%

Quyết toán

90%

10%

N4

Cung ứng VT

96%

3.5%

0.5%

10-30%

90%

10%

KHCN 1a

NSNN trực tiếp

95%

5%

-

-

-

-

KHCN 1b

Nguồn khác

97%

3%

-

-

-

-

💡 Mở rộng FILE 4: Bảng định mức bổ sung cho nhiệm vụ KH&CN theo Quy chế 2816/QĐ-VKH (Nhóm 1-4 KHCN, thưởng ISI 50tr, Scopus 30tr) - xem FILE 4 Phần 3.4.


## 10.3. Cơ chế đặc biệt TP.HCM (80/20)

Phòng Tư vấn và Kiểm định Xây dựng TP.HCM hoạt động theo cơ chế tự chủ một phần:

1     HĐ do Phòng TP.HCM thực hiện

2        │

3        ▼ Cột 4 (Giao đơn vị)

4        │

5        ├── 20% về Trụ sở Hà Nội

6        │   - Chia sẻ chi phí quản lý chung

7        │   - Duy trì IDOP

8        │   - Hỗ trợ pháp lý

9        │

10        └── 80% giữ tại TP.HCM

11            + 100% Cột 3 (Giao chủ trì)

12            = Hạn mức kinh phí khả dụng

13

14     Phó GĐ phụ trách lập đề nghị tạm ứng trên IDOP

15     Không chi vượt hạn mức


## 10.4. Công thức tính tự động trên IDOP


### Tầng 1 (Phụ lục 7 QCCTNB)

1     Cho HĐ có:

2     - Giá trị trước thuế: V

3     - Nhóm HĐ: N (1a, 2a, ..., 4)

4

5     Auto-calculate:

6     T1_Vien = V × (Col6[N] + Col7[N])

7     T1_DonVi = V × Col5[N]

8

9     Validation:

10     T1_Vien + T1_DonVi = 100% × V


### Tầng 2 (Phụ lục 02 CCBA)

1     T1_DonVi nhận được:

2     T2_ChuTri = V × Col3[N]

3     T2_DonVi = V × Col4[N]

4

5     GĐ CCBA có quyền giảm Cột 3 trong giới hạn:

6     - N1: max -2%

7     - N2: max -5%

8     - N4: max -2%

9

10     HĐ quản lý tập trung (TVGS, QLDA, Thi công):

11     - Không giao khoán trọn gói cho Chủ trì

12     - Áp dụng Cột 5 trực tiếp


### Tầng 3 - Khối Trực tiếp (P2)

1     P2 = [T2_ChuTri - Chi phí hợp lệ]

2          × Tỷ lệ phân chia nội bộ

3          × Hệ số KPI

4

5     Trong đó:

6     - Chi phí hợp lệ: Có hóa đơn, chứng từ

7     - Tỷ lệ phân chia: PGV duyệt

8     - Hệ số KPI: 0.8 đến 1.2

9

10     Tạm ứng max: 90% × Khối lượng hoàn thành (CẬP NHẬT từ 70%)


### Tầng 3 - Khối Gián tiếp (P2_GT)

1     P2_GT = [Tổng chênh lệch khả dụng / Tổng Hệ số CCBA]

2             × Hệ số chức danh

3             × Hệ số KPI

4

5     Hệ số chức danh tại CCBA (Phụ lục 02):

6     - Giám đốc: 4.5

7     - Phó Giám đốc: 3.0

8     - Trưởng phòng / Kế toán: 2.6

9     - Chuyên viên: 2.0 - 3.0

10     - Khác: 1.0 - 2.0

11

12     Hệ số chức danh tại Viện (Phụ lục 9 QCCTNB):

13     - Viện trưởng: 10

14     - Phó Viện trưởng: 8

15     - TP chức năng / Kế toán trưởng: 6

16     - Phó TP: 4


### Hoàn thuế GTGT

1     Hóa đơn đầu vào:

2     - Hợp lý, hợp pháp

3     - Đã kê khai và nộp thuế

4

5     Chủ trì nhận:

6     - Trước quyết toán: max 80% giá trị thuế hoàn

7     - Sau quyết toán: nhận hết phần còn lại


### Thuế TNCN

1     Tổng thu nhập = Lương ngạch bậc + P2 (hoặc P2_GT)

2     Thuế TNCN = Tính theo biểu lũy tiến NN

3     Khấu trừ tại nguồn

4     Thu nhập thực = Tổng thu nhập - Thuế TNCN

5

6     CTV ngoài Viện:

7     - < 2tr/lần: không khấu trừ

8     - ≥ 2tr/lần không HĐLĐ: khấu trừ 10%

9     - HĐLĐ ≥ 1 tháng: đóng BHXH + thuế lũy tiến



# PHẦN XI. ĐỊNH MỨC CHI TIÊU TÍCH HỢP


## 11.1. Định mức công tác phí (Theo QCCTNB)


### 11.1.1. Phụ cấp lưu trú và phòng nghỉ

Đối tượng

TP TW (khoán)

Tỉnh (khoán)

TP TW (HĐ)

Tỉnh (HĐ)

LĐ Viện

1.000.000đ/ngày

800.000đ/ngày

1.400.000đ/phòng

1.000.000đ/phòng

VCNLĐ

700.000đ/ngày

600.000đ/ngày

1.600.000đ (2 người)

1.300.000đ (2 người)


### Các định mức bổ sung

Phụ cấp lưu trú: tối đa 500.000đ/người/ngày

Khoán công tác phí tháng (>10 ngày): 700.000đ/người/tháng

Trang phục/đồng phục: tối đa 5tr/người/năm

Ăn ca: 1.500.000đ/người/tháng


### 11.1.2. Định mức cho HĐKT

Nội dung

Định mức tối đa

Hội họp, hội thảo

300.000đ/buổi/người

Đi lại trong TP (khoán)

1.500.000đ/người/tháng

Ăn ca, ăn trưa (khoán)

1.500.000đ/người/tháng

Phụ cấp lưu trú

500.000đ/người/ngày

Báo cáo tham luận tiếng Việt

≤ 1.000.000đ/báo cáo

Báo cáo tham luận tiếng Anh

≤ 3.000.000đ/báo cáo

Giảng viên trong Viện

2.000.000đ/buổi (4 tiết)

Hội nghị giao ban

300.000đ/người

💡 Mở rộng FILE 4: Định mức thưởng KH&CN bổ sung từ Quy chế 2816 (bài báo ISI 50tr, Scopus 30tr, sáng chế 50tr) - xem FILE 4 Phần 3.5.


## 11.2. Định mức nhân công (Phụ lục 8 QCCTNB)

Tỷ lệ nhân công tối đa trên giá trị HĐ trước thuế:

Nhóm HĐ

Tỷ lệ NC tối đa

N1a

Theo quyết toán

N2a, N2b, N2c

50-65%

N2d, N2e

30-55%

N2f

25-40%

N2g

40-55%

N3

Theo quyết toán

N4

10-30%


### Cảnh báo IDOP

⚠️ Cảnh báo nếu vượt giới hạn nhưng cho phép với thuyết minh

📝 Auto-log để audit


## 11.3. Hệ số thu nhập dịch vụ khối gián tiếp


### Tại CCBA (Phụ lục 02 Quy chế CCBA 2026)

Chức danh

Hệ số

Giám đốc CCBA

4.5

Phó Giám đốc CCBA

3.0

Trưởng phòng / Phụ trách KT

2.6

Chuyên viên

2.0-3.0

Khác

1.0-2.0


### Tại Viện (Phụ lục 9 QCCTNB)

Chức danh

Hệ số

Viện trưởng

10

Phó Viện trưởng

8

Trưởng phòng chức năng / Kế toán trưởng

6

Phó Trưởng phòng

4


## 11.4. Định mức 5 quỹ (Điều 19 QCCTNB)

Quỹ

Mức trích

Mục đích

Quỹ KH&CN

≤ 20% thu nhập tính thuế

Đầu tư NCKH, đổi mới sáng tạo

Quỹ PT sự nghiệp

≥ 25% chênh lệch

Đầu tư phát triển

Quỹ BSTN

≤ 3 lần lương cơ bản

Bổ sung thu nhập

Quỹ KT + PL

≤ 3 tháng (lương + TNTT)

Khen thưởng, phúc lợi

Quỹ phúc lợi cá nhân

1.000.000đ/lần (max 2 lần/năm)

Trợ cấp khi có giấy ra viện


## 11.5. Thanh toán không tiền mặt (Điều 22.3 QCCTNB)


### Quy định bắt buộc

Mua hàng/dịch vụ ≥ 5tr: BẮT BUỘC chuyển khoản

Khoản 5-20tr: VCNLĐ có thể thanh toán trực tiếp cho nhà cung cấp

Sau đó được hoàn lại bằng chuyển khoản

PHẢI có chứng từ thanh toán không TM


### IDOP auto-block

🚨 Đề nghị thanh toán tiền mặt ≥ 5tr

🚨 Chứng từ không có proof chuyển khoản



# 🔗 PHỤ LỤC - CROSS-REFERENCE ĐẾN FILE 4


## A. Liên kết với Enterprise Architecture

Các quy trình vận hành và cơ chế tài chính trong file này được mở rộng cấp Viện tại FILE 4 - Enterprise Architecture:


### A.1. Mở rộng 7 bước vận hành lên cấp Viện

FILE 4 bổ sung 5 bước KH&CN chuẩn theo Quy chế 2816:

1     1. Đăng ký nhiệm vụ KH&CN

2     2. Ký hợp đồng KH&CN

3     3. Giao nhiệm vụ

4     4. Thực hiện + Báo cáo

5     5. Nghiệm thu + Quyết toán


### A.2. Mở rộng cơ chế tài chính

FILE 4 định nghĩa thêm 4 nhóm KH&CN:

Nhóm 1 KHCN: NSNN cấp trực tiếp (không VAT)

Nhóm 2 KHCN: NSNN gián tiếp / hợp đồng dịch vụ

Nhóm 3 KHCN: Nhiệm vụ theo chức năng Viện

Nhóm 4 KHCN: Nhiệm vụ cấp Viện (tự chủ)


### A.3. Mở rộng định mức thưởng

FILE 4 bổ sung Incentive Engine cho KH&CN:

ISI: 50 triệu/bài

Scopus: 30 triệu/bài

ISSN quốc tế: 10 triệu/bài

Sáng chế độc quyền: 50 triệu/bằng

Giải pháp hữu ích: 30 triệu

Đề tài Xuất sắc: 10% giá trị HĐ (max 100tr)

Quy chuẩn QCVN: 10% (max 60tr)

Tiêu chuẩn TCVN: max 20tr


### A.4. Tích hợp với hệ thống Viện

FILE 4 định nghĩa API Gateway kết nối:

Hệ thống KHKT Viện → đồng bộ hồ sơ HĐ Viện ký

Hệ thống TCKT Viện → đồng bộ phân phối tài chính

Hệ thống TCHC Viện → đồng bộ con dấu, lưu trữ

Cổng thông tin Viện → publish kết quả KH&CN


## B. Nguyên tắc áp dụng

IDOP CCBA là Core Platform

Hệ thống Viện là Satellite Systems

Mọi tích hợp qua API Gateway (xem FILE 4 Phần 5)

Tuân thủ Event-driven Architecture


## C. Roadmap mở rộng vận hành

1     v2.0 → 7 bước vận hành CCBA (file này)

2     v2.1 → + 5 bước KH&CN (xem FILE 4 Phần 2.2)

3     v2.5 → + Tích hợp Viện qua API (xem FILE 4 Phần 5)

4     v3.0 → Enterprise Operations Platform (xem FILE 4)


HẾT FILE 2/4

📎 Xem tiếp:

FILE 1/4 - Kiến trúc tổng quan (Phần I-VIII) ✅

FILE 3/4 - Yêu cầu kỹ thuật và Triển khai (Phần XII-XIV) → tiếp theo

FILE 4/4 - Enterprise Architecture (Khung mở rộng)

