# Example: Data Lineage & Automation Flow (Mermaid)

Below is a Mermaid diagram showing the lineage and automation links between core business objects.

```mermaid

# Ví dụ: Luồng dữ liệu & tự động hóa (Mermaid)

Sơ đồ dưới đây mô tả luồng nghiệp vụ, mối liên kết và các điểm tự động hóa giữa các đối tượng chính trong hệ thống.

```mermaid
graph TD
    A[Khách hàng<br/>+ Liên hệ] -->|1-nhiều: có| B[Cơ hội<br/>+ Vai trò liên hệ]
    B -->|N-nhiều: tạo| C[Hợp đồng<br/>+ Kế hoạch tài chính]
    C -->|1-nhiều: thực hiện bởi| D[Dự án<br/>+ Gói công việc]
    D -->|1-nhiều: gồm| E[Rủi ro/Vấn đề/Bài học]
    B -.->|Tự động hóa: Power Automate| C
    C -.->|Tự động tạo: Thư mục CDE| D
    D -->|Tổng hợp: Chỉ số| F[Dữ liệu EOS Scorecard<br/>+ OKRs]
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#fff3e0
```

> Mẹo: Để xem sơ đồ, mở file này bằng VS Code và nhấn Ctrl+Shift+V (Preview) hoặc dùng trang https://mermaid.live để xem trực tiếp.