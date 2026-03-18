# Thiết lập môi trường phát triển

## Đăng nhập SharePoint/PnP.PowerShell nhanh (Cached Auth)

Để tránh phải xác thực lại nhiều lần khi chạy các script
(`sp-diff`, `termstore-import`, `migrate-mm-cleanup`, v.v.), bộ script đã hỗ trợ
chế độ `-Auth Cached` mặc định qua helper `PnPHelpers.psm1`.

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

## Kết nối 1 lần cho cả phiên làm việc (pnp-session.ps1)

Để triệt để tránh nhắc đăng nhập lặp lại trong 1 cửa sổ PowerShell, repo cung cấp helper `tools/scripts/pnp-session.ps1`:

1. Nạp helper một lần trong mỗi phiên `pwsh`:

```powershell
. .\tools\scripts\pnp-session.ps1
```

2. Chọn chế độ xác thực:

- Dev nhanh (Delegated):

```powershell
$null = Get-IdopPnPConnection -Url "https://<tenant>.sharepoint.com/sites/IDOP-Dev" -Auth Delegated -SetDefault
```

- Tự động/CI (App-only certificate):

```powershell
$env:IDOP_SP_AUTH_MODE = "AppOnly"
$env:IDOP_SP_TENANT = "<tenant>.onmicrosoft.com"
$env:IDOP_SP_CLIENT_ID = "<app-client-id>"
$env:IDOP_SP_CERT_PATH = ".\.secrets\sp-app.pfx"   # hoặc dùng $env:IDOP_SP_CERT_THUMBPRINT
# tuỳ chọn (nếu muốn nhập tay khi connect thì bỏ qua)
# $env:IDOP_SP_CERT_PASSWORD = "<pfx-password>"

$null = Get-IdopPnPConnection -Url "https://<tenant>.sharepoint.com/sites/IDOP-Test" -Auth AppOnly -SetDefault
```

Sau khi chạy, các script (`SP: diff lists`, `SP: apply lists`, `SP: validate schemas`, v.v.) sẽ tự dùng phiên đã mở
mà không cần đăng nhập lại. Chúng tôi đã tích hợp helper này vào các script chính:
`apply-sp-lists.ps1`, `sp-diff.ps1`, `create-sp-navigation.ps1`, `validate-sp-naming.ps1`.

Lưu ý bảo mật: ưu tiên dùng `IDOP_SP_CERT_THUMBPRINT` (cert trong CurrentUser store) hoặc nhập mật khẩu PFX khi
được nhắc; chỉ dùng `IDOP_SP_CERT_PASSWORD` khi đã quản lý bí mật an toàn và đảm bảo không commit vào repo.
