# IDOP — CCBA WAY (Tài liệu sống)

Trang này là cổng vào hệ thống tài liệu nội bộ cho nền tảng IDOP theo quy trình CCBA WAY.

## Nội dung chính

- Constitution (nguyên tắc & kiểm soát): xem `../constitution.md`.
- Quy trình cộng tác với AI Agent: xem `./ai-workflow.md`.
- Datamodel & Taxonomy: xem thư mục `../datamodel/sharepoint/**`.
- Modules: `../specs/modules/**` gồm `spec.md`, `plan.md`, `tasks.md` và `diagrams/`.
- Checklist bảo trì & đồng bộ: xem `./maintenance-checklist.md`.

## Cách bắt đầu nhanh

```powershell
.\idop.ps1 validate datamodel
.\idop.ps1 connect -Environment Dev
```

Tài liệu được cập nhật liên tục qua Pull Request và review/approval theo Constitution.
