# Prompt viết tasks.md

Mục tiêu: Tạo backlog nhiệm vụ thực thi từ `plan.md`, có tiêu chí hoàn thành, và trường ghi nhận kết quả kiểm thử. **Bảo đảm taxonomy compliance với 14 term sets đã đồng bộ.**

Yêu cầu đầu ra:

- Danh sách tasks theo ưu tiên/nhóm (Spec, Datamodel, **Taxonomy Validation**, Flows, BI, Deployment, Testing).
- Mỗi task: mô tả, acceptance criteria, artifacts liên quan (file paths), ước lượng.
- Trường trạng thái: `todo | in-progress | done | pending` và ghi chú kiểm thử.
- **Taxonomy tasks:** Validation term sets existence, mapping fields chính xác, consistency checks.
- Liên kết tới thay đổi trong `datamodel/sharepoint/**` và taxonomy nếu có (ghi rõ mapping, owner, versioning, lý do thay đổi, tuân thủ quy trình phê duyệt).

**Bắt buộc include taxonomy validation tasks nếu module sử dụng Managed Metadata:**
- Verify term set IDs từ JSON files
- Validate terms tồn tại trong SharePoint 
- Test taxonomy field mappings
- Check consistency với business logic

Mẫu khởi tạo nhanh:

```markdown
# Backlog — <Tên module>

## Spec & Design
- [ ] Cập nhật `spec.md` theo Constitution + taxonomy requirements (AC: reference đúng term sets)
- [ ] Cập nhật `plan.md` (AC: taxonomy mapping rõ ràng)

## Datamodel & Taxonomy
- [ ] Điều chỉnh lists/columns ở `datamodel/sharepoint/lists/...` (AC: validate schema, diff OK)
- [ ] **Validate taxonomy dependencies:** Check term sets trong `datamodel/sharepoint/taxonomy/` (AC: IDs match SharePoint)
- [ ] **Map Managed Metadata fields:** (AC: fields reference đúng term set IDs từ JSON)
  - Field `Status` → `CCBA_TrangThaiChung` 
  - Field `Department` → `CCBA_DonViPhongBan`
  - Field `ExpenseType` → `CCBA_LoaiChiPhiPhanBo`

## Taxonomy Validation
- [ ] **Pre-deployment check:** Verify all term sets exist on target environment (AC: script validation passes)
- [ ] **Post-deployment test:** Managed Metadata fields populate correctly (AC: test data saves với correct terms)

## Flows / BI / Apps
- [ ] Xây dựng/cập nhật flow ... (AC: test case pass với taxonomy terms)
- [ ] Cập nhật báo cáo BI ... (AC: taxonomy filtering/grouping works)

## Deployment
- [ ] **Taxonomy sync:** Chạy `termstore-import.ps1` nếu cần (AC: no errors)
- [ ] Validate → diff (dry‑run) → snapshot → apply (AC: không lỗi taxonomy references)

## Testing & Acceptance
- [ ] Seed data với taxonomy terms, test workflows (AC: taxonomy workflow correct)
- [ ] Validate taxonomy consistency end-to-end (AC: checklist đạt, log vào mục này)
```
