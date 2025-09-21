# Hướng dẫn sử dụng script deploy-sp-lists-enhanced.ps1

## Mục đích

Tự động tạo/cập nhật các SharePoint Lists và cột theo chuẩn nghiệp vụ từ file JSON, hỗ trợ đầy đủ các loại trường (Text, Number, DateTime, User, Lookup, Choice, YesNo, ManagedMetadata).

## Yêu cầu

- Quyền quản trị SharePoint site (Dev/Test/Prod)
- Đã cài đặt module PnP.PowerShell
- Đã cấu hình TermStore/TermSet nếu dùng ManagedMetadata

## Cách sử dụng

### 1. Kết nối và chạy script

```powershell
# Chạy trên PowerShell 7+ (khuyến nghị)
cd d:\idop-ccba-way
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -UpdateExisting
```

- Tham số `-Environment`: Dev, Test, Prod (mặc định Dev)
- Tham số `-UpdateExisting`: Cho phép cập nhật thêm cột vào list đã tồn tại
- Tham số `-DryRun`: Chạy thử, không tạo/cập nhật thật
- Tham số `-SingleList <tên>`: Chỉ xử lý 1 list

### 2. Lưu ý khi sử dụng

- Lookup fields: Target list phải tồn tại trước
- ManagedMetadata: Đảm bảo TermStore/TermSet đã được cấu hình đúng
- Script sẽ log chi tiết từng bước, cảnh báo nếu có lỗi

### 3. Kiểm thử nhanh

- Có thể chạy với `-DryRun` để kiểm tra schema trước khi deploy thật

### 4. Troubleshooting

- Nếu gặp lỗi kết nối, kiểm tra quyền truy cập và ClientId
- Nếu lỗi TermStore/TermSet, kiểm tra lại cấu hình trên SharePoint

---

## Tích hợp kiểm thử tự động

- Sử dụng script `validate-sp-schemas.js` để kiểm tra schema JSON trước khi deploy
- Có thể tích hợp vào CI/CD (xem mẫu workflow trong README.md)

---

## Liên hệ hỗ trợ

- Đội phát triển IDOP-CCBA-WAY
# Hướng dẫn sử dụng script deploy-sp-lists-enhanced.ps1

## Mục đích
Tự động tạo/cập nhật các SharePoint Lists và cột theo chuẩn nghiệp vụ từ file JSON, hỗ trợ đầy đủ các loại trường (Text, Number, DateTime, User, Lookup, Choice, YesNo, ManagedMetadata).

## Yêu cầu
- Quyền quản trị SharePoint site (Dev/Test/Prod)
- Đã cài đặt module PnP.PowerShell
- Đã cấu hình TermStore/TermSet nếu dùng ManagedMetadata

## Cách sử dụng

### 1. Kết nối và chạy script
```powershell
# Chạy trên PowerShell 7+ (khuyến nghị)
cd d:\idop-ccba-way
./tools/scripts/deploy-sp-lists-enhanced.ps1 -Environment Dev -UpdateExisting
```
- Tham số `-Environment`: Dev, Test, Prod (mặc định Dev)
- Tham số `-UpdateExisting`: Cho phép cập nhật thêm cột vào list đã tồn tại
- Tham số `-DryRun`: Chạy thử, không tạo/cập nhật thật
- Tham số `-SingleList <tên>`: Chỉ xử lý 1 list

### 2. Lưu ý khi sử dụng
- Lookup fields: Target list phải tồn tại trước
- ManagedMetadata: Đảm bảo TermStore/TermSet đã được cấu hình đúng
- Script sẽ log chi tiết từng bước, cảnh báo nếu có lỗi

### 3. Kiểm thử nhanh
- Có thể chạy với `-DryRun` để kiểm tra schema trước khi deploy thật

### 4. Troubleshooting
- Nếu gặp lỗi kết nối, kiểm tra quyền truy cập và ClientId
- Nếu lỗi TermStore/TermSet, kiểm tra lại cấu hình trên SharePoint

---

## Tích hợp kiểm thử tự động
- Sử dụng script `validate-sp-schemas.js` để kiểm tra schema JSON trước khi deploy
- Có thể tích hợp vào CI/CD (xem mẫu workflow trong README.md)

---

## Liên hệ hỗ trợ
- Đội phát triển IDOP-CCBA-WAY
