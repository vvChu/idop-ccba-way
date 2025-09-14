# AGENTS.md — Hướng dẫn cho AI Agent

## Nguyên tắc cập nhật liên tục
- Mỗi module trong `specs/modules/<hợp phần>/<module>/` đều có:
  - `spec.md`: mô tả nghiệp vụ, quy trình, acceptance criteria, **ràng buộc & chỉ dẫn đặc thù**.
  - `plan.md`: chi tiết kỹ thuật, tích hợp, cấu hình, **tích hợp & cấu hình đặc thù**.
  - `tasks.md`: backlog và kiểm thử.
- Trước khi thiết kế hoặc chỉnh sửa, **luôn đọc kỹ** `spec.md` và `plan.md` của module để nắm:
  - Trigger nghiệp vụ quan trọng.
  - Quy tắc đặt tên, phân quyền, tích hợp hệ thống ngoài.
  - Lookup/Managed Metadata và taxonomy liên quan.
- Khi phát hiện ràng buộc mới hoặc cần cải tiến:
  1. Bổ sung vào `spec.md` và/hoặc `plan.md` của module.
  2. Commit qua PR, review và “Trình ký” trước khi triển khai.
- Định kỳ rà soát để tinh chỉnh, đảm bảo hệ thống vận hành **Smarter – Faster – Better**.
