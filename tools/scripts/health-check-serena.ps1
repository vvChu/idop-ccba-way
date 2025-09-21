# Health check script for Serena server
# Usage: ./health-check-serena.ps1 -Url "http://localhost:8000/healthz" [-TimeoutSec 5]
param(
    [string]$Url = "http://localhost:8000/healthz",
    [int]$TimeoutSec = 5
)

try {
    $response = Invoke-WebRequest -Uri $Url -TimeoutSec $TimeoutSec -UseBasicParsing -ErrorAction Stop
    if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
        Write-Host "[OK] Serena server is healthy: $Url (Status $($response.StatusCode))"
        exit 0
    } else {
        Write-Host "[FAIL] Serena server unhealthy: $Url (Status $($response.StatusCode))"
        exit 2
    }
} catch {
    Write-Host "[ERROR] Cannot reach Serena server: $Url"
    exit 1
}
