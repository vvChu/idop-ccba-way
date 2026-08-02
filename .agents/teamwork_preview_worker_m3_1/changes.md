# Báo Cáo Thay Đổi Spec (Changes Report) - Revision R2

> **Tác giả**: Worker 2 (`teamwork_preview_worker_m3_1`)  
> **Dự án**: Integrated Digital Operation Platform (IDOP) — CCBA / IBST  
> **Target File**: `specs/modules/process_execution/pmo/spec.md`  
> **Thời gian**: 2026-08-02  

---

## 1. Tóm tắt Thay đổi (Summary of Changes)

Đã cập nhật toàn bộ file đặc tả kỹ thuật `specs/modules/process_execution/pmo/spec.md` lên **Phiên bản R2 (Revision 2)** dựa trên thiết kế nâng cấp chi tiết tại Section 8 của plan `d:\idop-ccba-way\.agents\teamwork_preview_explorer_m1_2\spec_update_plan.md`.

---

## 2. Chi tiết các Phần Cập nhật trong `spec.md`

1. **Header & Căn cứ Pháp lý**:
   - Thêm dẫn chiếu chi tiết đến QCTK 2815 (Điều 7), QCCTNB 3209 (Điều 8, Phụ lục 7 & 8), Quy chế CCBA 2026 (Điều 9, 11), Luật 135/2025/QH15, và Nghị định 217/2026/NĐ-CP (Khoản 4 & Khoản 5 Điều 26).
   - Thêm liên kết kiến trúc tới `05_ccba_ibst_boundary_map.md` (Bước 3) và `06_ccba_org_role_matrix.md`.

2. **Mục tiêu & Phạm vi (Goal & Scope)**:
   - Mở rộng mục tiêu số hóa quy trình 5 bước nhập liệu PGV, hỗ trợ Multi-Scope và Multi-Department.
   - Tích hợp 4 vai trò quản lý kỹ thuật & tài chính và tuân thủ Luật 135/2025 & NĐ 217/2026.
   - Bổ sung phạm vi Offloading file PDF PGV sang 5TB Master OneDrive (`05_Projects`).

3. **Ma trận Ngôn ngữ Thống nhất & Hệ thống Vai trò (Ubiquitous Language & 3-Tier Hierarchy)**:
   - Thêm bảng **Ubiquitous Language Matrix** ánh xạ thuật ngữ nghiệp vụ (PGV, Contract Lead, Design Chief, Financial Officer, Assigned Tech Chief, Contract Scope, Phân bổ 3 Tầng, Hợp đồng Điện tử & Chữ ký Số) với SharePoint List, Entra ID Group, và Quy chế dẫn chiếu.
   - Thêm sơ đồ **3-Tier Role Hierarchy** phân tầng chiến lược, vận hành & kế toán, và thực thi sản xuất nội bộ.

4. **User Stories & Ma trận Vai trò (Role Matrix)**:
   - Chuẩn hóa 8 User Stories (US-PMO-01 đến US-PMO-08) theo chuẩn 15 `ROLE_ID` SSOT.
   - Chuẩn hóa Bảng Role Matrix chi tiết quyền hạn C/R/U/A cho 10 nhóm vai trò.

5. **Phân định Rõ ràng 4 Vai trò Kỹ thuật & Quản lý PGV**:
   - `ContractLeadUser`: Chủ trì Hợp đồng (`ROLE_PROJECT_MANAGER`), chịu trách nhiệm toàn diện P&L và tiến độ.
   - `DesignChiefUser`: Chủ nhiệm Thiết kế (`ROLE_HEAD_BIM_DESIGN`), chịu trách nhiệm giải pháp kỹ thuật, tiêu chuẩn và QA/QC thiết kế.
   - `FinancialOfficerUser`: Phụ trách Kế toán (`ROLE_ACCOUNTANT`), chịu trách nhiệm thẩm định định mức trích nộp 3 tầng và hạn mức giao khoán.
   - `AssignedTechnicalChiefUser`: Chủ trì Kỹ thuật Phụ trách (`ROLE_STAFF` / `ROLE_HEAD_BIM_PROJECT`), cá nhân có Chứng chỉ hành nghề trực tiếp điều hành kỹ thuật gói việc.

6. **Trình tự 5 Bước Nhập liệu PGV (5-Step PGV Data Entry Sequence)**:
   - Bổ sung sơ đồ Mermaid **Sequence Diagram** minh họa tương tác giữa 5 vai trò qua 5 bước.
   - Chi tiết kỹ thuật 5 bước: (1) Khởi tạo PGV & Ràng buộc Hợp đồng, (2) Phân bổ Tài chính 3 Tầng, (3) Phân công Nhân sự Kỹ thuật & Kiểm tra CCHN, (4) Thẩm tra Tuân thủ & Gateway, (5) Phê duyệt Giám đốc & Offloading 5TB OneDrive.

7. **Quy tắc Nghiệp vụ Phân bổ Multi-Scope & Multi-Department**:
   - Multi-Scope: Bắt buộc phân rã `ContractScopes`, trích nộp Viện riêng theo Phụ lục 7 QCCTNB 3209, tính tổng retention theo công thức $\sum \text{AmountBeforeVAT}_i \times (\text{TyLeVienCPQL}_i + \text{TyLeVienKHTS}_i)$, khống chế khung nhân công Phụ lục 8.
   - Multi-Department: Chỉ định 01 đơn vị chủ trì, thỏa thuận tỷ lệ sản lượng, qua Gateway `ROLE_HEAD_ADMIN` (`Pending_InterDept_Agreement` $\rightarrow$ `InterDept_Approved`), hạch toán kinh phí quản lý phối hợp.

8. **Tuân thủ Pháp lý: Luật 135/2025/QH15 & NĐ 217/2026/NĐ-CP**:
   - Luật 135/2025: Giá trị pháp lý hợp đồng điện tử / chữ ký số tương đương văn bản giấy; ghi nhận SHA-256 Digest và ISO 8601 Timestamp để đảm bảo tính không thể chối bỏ.
   - NĐ 217/2026 Khoản 4: Trách nhiệm giải trình tài chính liên đới và đảm bảo độc lập kiểm soát nội bộ (`ROLE_LEGAL_QA`).
   - NĐ 217/2026 Khoản 5: Minh bạch dữ liệu (`Immutable PGV Status`), lập PGV điều chỉnh nếu thay đổi, áp dụng Metadata-First & 5TB Master OneDrive Offloading.

9. **Luồng Phê duyệt Verification Luật 135/2025**:
   - Bổ sung sơ đồ Mermaid **Audit Flowchart** minh họa 4-Phase Automated Integrity Audit.
   - Chi tiết Phase A (Pre-Check), Phase B (Financial Bound Audit), Phase C (Gateway Verification), Phase D (Executive Sign-Off & Offloading).

10. **Acceptance Criteria & List Mapping**:
    - Bảng Mapping 1-1 liên kết `JobAssignments`, `AssignmentDetails`, `ContractScopes`, và `SharedCostAllocations`.
    - Thêm 4 tiêu chí chấp nhận cụ thể (AC-PMO-01 đến AC-PMO-04).

---

## 3. Kết quả Kiểm tra & Xác minh (Verification Results)

- **File**: `specs/modules/process_execution/pmo/spec.md`
- **Tổng số dòng**: 286 lines
- **Kích thước**: ~26.5 KB
- **Đánh giá**: Hoàn thành 100% các mục tiêu R2 trong yêu cầu của Milestone 3.
