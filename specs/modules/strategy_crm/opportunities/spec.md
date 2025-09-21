
# Module: Opportunities (Quản lý Cơ hội Kinh doanh)

## Mục tiêu
- Quản lý toàn bộ vòng đời cơ hội kinh doanh (opportunity) của CCBA từ khi tiếp nhận đến khi chuyển đổi thành hợp đồng/dự án.
- Hỗ trợ pipeline bán hàng, theo dõi trạng thái, giá trị, xác suất thành công của từng cơ hội.
- Tích hợp quy trình phê duyệt (trình ký) cho các cơ hội lớn hoặc đặc biệt.
- Là cầu nối giữa CRM, hợp đồng, dự án và tài chính.

## Phạm vi
- Quản lý danh sách cơ hội kinh doanh (opportunities) theo từng khách hàng.
- Theo dõi pipeline, trạng thái, giá trị, xác suất, ngày dự kiến chốt.
- Gắn nhãn, phân loại cơ hội theo taxonomy (loại hình dịch vụ, lĩnh vực, nguồn gốc...)
- Liên kết với khách hàng, liên hệ, giao dịch, hợp đồng.
- Tích hợp flows tự động nhắc nhở, trình ký, báo cáo.

## User stories
- Là nhân viên kinh doanh, tôi muốn tạo mới và cập nhật cơ hội để theo dõi pipeline bán hàng.
- Là quản lý, tôi muốn xem báo cáo tổng hợp về số lượng, giá trị, tỷ lệ chuyển đổi của các cơ hội.
- Là trưởng phòng, tôi muốn phê duyệt các cơ hội lớn qua quy trình trình ký.
- Là ban giám đốc, tôi muốn truy xuất nhanh các hợp đồng/dự án phát sinh từ từng cơ hội.
- Là nhân viên, tôi muốn nhận được nhắc nhở khi cơ hội sắp đến hạn chốt hoặc bị quá hạn.

## Acceptance criteria
- Có thể tạo/sửa/xóa cơ hội, gắn với khách hàng và liên hệ liên quan.
- Có thể cập nhật trạng thái, giá trị, xác suất, ngày dự kiến chốt.
- Có thể phân loại cơ hội theo taxonomy chuẩn.
- Có flows tự động nhắc nhở, trình ký phê duyệt cho cơ hội lớn.
- Dữ liệu opportunities liên thông với CRM, hợp đồng, dự án, tài chính.
- Có báo cáo tổng hợp, dashboard pipeline.

## Quy trình & BPMN
- Chu trình tổng quát: Tiếp nhận cơ hội → Sàng lọc (Qualification) → Định hình phạm vi & dịch vụ → Đánh giá Stakeholders → Đề xuất/Proposal → Đàm phán/Negotiation → Trình ký (nếu vượt ngưỡng) → Kết quả (Won/Lost/NoGo) → Chuyển đổi (Hợp đồng/Dự án) → Cross‑sell.
- Multi‑service: Một cơ hội tổng (Opportunity) có thể chứa nhiều dòng dịch vụ (OpportunityServices) với giá trị & xác suất riêng.
- Stakeholder mapping: Tại các mốc Proposal & Negotiation phải có ≥1 Decision Maker & ≥1 Finance Gatekeeper ở trạng thái Supportive trở lên.
- Influence checkpoints:
	- Gate 1 (Qualification): ≥1 Contact mapped.
	- Gate 2 (Proposal): InfluenceScore ≥ 30% target.
	- Gate 3 (Negotiation): InfluenceScore ≥ 60% target, không có Opposed có InfluenceWeight ≥4.
	- Gate 4 (Pre‑Win): All critical roles covered (Decision Maker, Finance, Technical).
- BPMN: diagrams/Opportunities-pipeline.bpmn, diagrams/Opportunities-approval.bpmn, diagrams/Opportunities-stakeholder-review.bpmn

## Ràng buộc & chỉ dẫn đặc thù
- Phân quyền: Nhân viên chỉ xem/sửa cơ hội mình phụ trách; quản lý xem toàn bộ; trình ký theo ma trận vai trò.
- Tích hợp: Lookup liên kết với lists khách hàng, hợp đồng, dự án, tài chính.
- Taxonomy: Chuẩn hóa các trường loại hình dịch vụ, lĩnh vực, nguồn gốc theo termstore.
- Trigger: Tự động nhắc nhở khi cơ hội sắp đến hạn hoặc pipeline bị quá hạn.
- Lưu vết: Ghi log mọi thay đổi, phục vụ kiểm toán nội bộ.
 - InfluenceScore = Σ(InfluenceWeight × SupportFactor × EngagementFactor) dùng để cảnh báo rủi ro.
 - Auto cross‑sell: Khi một OpportunityService Won với loại hình dịch vụ A, hệ thống gợi ý (draft) dịch vụ B/C theo bảng mapping nội bộ.
 - Escalation: Nếu sau 7 ngày ở Negotiation mà thiếu Decision Maker → gắn cờ RISK và gửi email quản lý.
 - Data completeness rule: Opportunity không được chuyển sang Negotiation nếu Probability > 40% nhưng thiếu Finance Gatekeeper.
