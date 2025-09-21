# Hướng dẫn bảo trì & mở rộng List Formatting cho CCBA

## 1. Thêm/sửa format
- Thêm file JSON mới vào thư mục `list-formatting/` theo tên trường/nghiệp vụ.
- Ghi chú rõ chức năng, ví dụ sử dụng trong file hoặc README.

## 2. Kiểm thử format
- Áp dụng thử trên list dev/test trước khi triển khai diện rộng.
- Kiểm tra hiển thị trên nhiều trình duyệt, vai trò người dùng.

## 3. Quy trình cập nhật
- Khi thay đổi nghiệp vụ, cập nhật lại file format tương ứng.
- Định kỳ review, loại bỏ format không còn dùng, bổ sung mẫu mới.

## 4. Tích hợp tự động
- Có thể tích hợp vào script deploy để tự động apply format khi tạo/cập nhật list.
- Tham khảo PnP PowerShell: `Set-PnPColumnFormatting -List <ListName> -Identity <FieldName> -Json <JsonString>`

## 5. Chia sẻ & học hỏi
- Tham khảo thêm mẫu từ [pnp/List-Formatting](https://github.com/pnp/List-Formatting) và [vvChu/List-Formatting](https://github.com/vvChu/List-Formatting).
- Đóng góp mẫu mới, chia sẻ kinh nghiệm trong nội bộ CCBA.

---

> Việc bảo trì tốt List Formatting giúp hệ thống luôn trực quan, phù hợp nghiệp vụ và dễ mở rộng.