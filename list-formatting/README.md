# Thư viện List Formatting cho IDOP-CCBA-WAY

Thư mục này lưu các mẫu JSON format cho SharePoint Lists, áp dụng cho các trường nghiệp vụ phổ biến của CCBA.

## Mẫu format đã có
- `status-format.json`: Định dạng trạng thái (Approved, Pending, Rejected, ...)
- `progress-format.json`: Định dạng tiến độ, % hoàn thành (progress bar)
- `deadline-format.json`: Định dạng ngày hạn, cảnh báo quá hạn/sắp đến hạn
- `yesno-format.json`: Định dạng trường Yes/No (icon, màu)
- `choice-format.json`: Định dạng trường Choice (badge màu)
- `user-format.json`: Hiển thị avatar, tên người dùng cho trường User

## Cách sử dụng
1. Vào SharePoint List, chọn cột cần format → Column settings → Format this column → Advanced mode → Dán nội dung file JSON tương ứng.
2. Có thể tự động hóa áp dụng format qua script hoặc PowerShell/PnP nếu cần.

## Quy trình bảo trì
- Khi thêm trường mới hoặc thay đổi nghiệp vụ, bổ sung/điều chỉnh file format tương ứng.
- Kiểm thử format trên môi trường dev trước khi áp dụng rộng rãi.
- Có thể mở rộng thêm các mẫu cho view formatting, action button, conditional logic nâng cao.

## Đề xuất tích hợp
- Kết hợp với Power Automate/Power Apps để tăng tính tự động hóa và trải nghiệm người dùng.
