# IDOP — CCBA WAY (Tài liệu sống)

Trang này là cổng vào hệ thống tài liệu nội bộ cho nền tảng IDOP theo quy trình CCBA WAY.

## Nội dung chính

- **Lộ trình Triển khai IDOP PROD-First**: xem [`./prod-first-deployment-roadmap.md`](./prod-first-deployment-roadmap.md).
- **Quy trình cộng tác với AI Agent**: xem [`./ai-workflow.md`](./ai-workflow.md).
- **SharePoint Navigation Governance**: xem [`./navigation-governance.md`](./navigation-governance.md).
- **Datamodel & Taxonomy**: xem thư mục `../datamodel/sharepoint/**`.
- **Modules Specs**: xem `../specs/modules/**` gồm `spec.md`, `plan.md`, `tasks.md` và `diagrams/`.
- **Checklist bảo trì & đồng bộ**: xem [`./maintenance-checklist.md`](./maintenance-checklist.md).

## Cách bắt đầu nhanh (CLI PROD-First)

```powershell
# 1. Validate Datamodel (59 Lists, 21 Taxonomy)
.\idop.ps1 validate datamodel

# 2. Kết nối Môi trường PROD IDOP
.\idop.ps1 connect -Environment IDOP

# 3. DryRun kiểm tra triển khai
.\idop.ps1 deploy lists -Environment IDOP -DryRun
```

Tài liệu được cập nhật liên tục qua Pull Request và review/approval theo Constitution.
