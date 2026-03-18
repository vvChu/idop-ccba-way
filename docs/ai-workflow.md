# Quy trình cộng tác với AI Agent

Tài liệu này mô tả cách làm việc tiêu chuẩn giữa nhóm dự án và AI Agent trong VS Code, dựa trên Constitution và pipeline IDOP‑CCBA‑WAY.

## 1) Chuẩn bị scaffold

- Validate datamodel: `.\idop.ps1 validate datamodel`
- Đảm bảo datamodel JSON, taxonomy, schemas đã đúng chỗ theo Constitution.

## 2) Viết đặc tả với Spec‑Driven Development

- Sử dụng prompts trong `prompts/spec.md`, `prompts/plan.md`, `prompts/tasks.md` để dẫn hướng AI.
- Sinh/ cập nhật:
  - `specs/modules/<group>/<module>/spec.md`
  - `specs/modules/<group>/<module>/plan.md`
  - `specs/modules/<group>/<module>/tasks.md`

- Áp dụng checklist trong Constitution (Section 5) trước khi tạo PR.

## 3) Review & Merge qua Pull Request

- Commit thay đổi, mở PR; Integrator/Lead review theo checklist.
- Bảo đảm datamodel/taxonomy thay đổi có lý do, có diff rõ ràng và kế hoạch rollback.

## 4) Triển khai kỹ thuật

- Validate schemas và chạy diff (dry‑run).
- Áp dụng Lists/Taxonomy:
  - `.\idop.ps1 deploy lists -Environment Dev`
  - `.\idop.ps1 taxonomy import -Environment Dev`

## 5) Kiểm thử & chấp nhận

- Seed data, chạy flows, xem dashboards.
- Ghi kết quả kiểm thử vào `tasks.md` (done/pending) theo từng hạng mục.

## 6) Vận hành & cải tiến

- Theo dõi SLA/RAG, khi có thay đổi quay lại vòng `spec → plan → tasks → PR → deploy`.

## Lệnh nhanh

```powershell
.\idop.ps1 validate datamodel
.\idop.ps1 deploy lists -Environment Dev -DryRun
.\idop.ps1 taxonomy import -Environment Dev -DryRun
```

Tham chiếu: xem thêm `constitution.md` để biết nguyên tắc, vai trò, quy ước đặt tên và checklist bắt buộc.
