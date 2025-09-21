# Kiểm thử tự động schema SharePoint Lists

Script `tools/scripts/validate-sp-schemas.js` sẽ kiểm tra tất cả file JSON định nghĩa SharePoint List có tuân thủ schema chuẩn không.

## Cách sử dụng

1. Cài đặt ajv-cli (nếu chưa có):

   ```bash
   npm install -g ajv-cli
   ```

2. Chạy kiểm thử:

   ```bash
   node tools/scripts/validate-sp-schemas.js
   ```

- Nếu hợp lệ: sẽ báo PASSED cho tất cả lists
- Nếu có lỗi: sẽ báo FAILED và chỉ ra file JSON lỗi

## Tích hợp CI/CD
- Có thể thêm bước này vào workflow GitHub Actions để tự động kiểm tra schema khi push/pull request.
- Xem mẫu trong README.md.
