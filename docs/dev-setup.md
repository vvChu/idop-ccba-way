# Thiết lập môi trường phát triển

## Đăng nhập SharePoint/PnP.PowerShell nhanh (Cached Auth)

Để tránh phải xác thực lại nhiều lần khi chạy các script
(`sp-diff`, `termstore-import`, `migrate-mm-cleanup`, v.v.), bộ script đã hỗ trợ
chế độ `-Auth Cached` mặc định qua helper `SpAuth.psm1`.

Một lần duy nhất cho mỗi tenant, hãy đăng ký ứng dụng PnP Management Shell để
cấp quyền dùng token cache:

1.  Cài module PnP.PowerShell (nếu chưa có):

	-  Mở PowerShell 7 (`pwsh`).
	-  Chạy các lệnh sau:

	  ```powershell
	  Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -MinimumVersion 2.8.5.201
	  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	  Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force -AllowClobber
	  ```

2.  Đăng ký quyền cho PnP Management Shell (một lần):

   ```powershell
   Register-PnPManagementShellAccess
   ```

Sau bước này, các script khi dùng `-Auth Cached` sẽ cố gắng tái sử dụng token,
giảm thiểu pop-up đăng nhập. Nếu môi trường không hỗ trợ
`-PnPManagementShell`, helper sẽ tự động fallback về `Interactive` nhưng vẫn
tái sử dụng phiên hiện có khi có thể.

Mẹo: Bạn có thể ép chế độ khác khi cần

-  `-Auth Interactive`: bật luồng xác thực tương tác.
-  `-Auth DeviceLogin`: dùng device code (hữu ích khi môi trường hạn chế trình duyệt).
