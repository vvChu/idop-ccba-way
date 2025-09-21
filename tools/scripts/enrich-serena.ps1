# Script enrich kiểm thử tự động cho Serena MCP
# Sử dụng: ./enrich-serena.ps1
param(
    [string]$ServerUrl = "http://localhost:5001"
)

try {
    $response = Invoke-WebRequest -Uri "$ServerUrl/enrich" -Method POST -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
    if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
        Write-Host "[OK] Enrich kiểm thử thành công: $($response.Content)"
        exit 0
    } else {
        Write-Host "[FAIL] Enrich trả về lỗi: $($response.StatusCode)"
        exit 2
    }
} catch {
    Write-Host "[ERROR] Không thể kết nối Serena MCP enrich endpoint: $ServerUrl"
    exit 1
}
