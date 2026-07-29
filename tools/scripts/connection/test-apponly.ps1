param(
    [string]$SiteUrl = $env:IDOP_SP_URL
)

$ErrorActionPreference = 'Stop'
Import-Module PnP.PowerShell -Force

# Read credentials from environment variables (.env) — NEVER hardcode secrets
$tenant   = $env:IDOP_SP_TENANT
$clientId = $env:IDOP_SP_CLIENT_ID
$certPath = $env:IDOP_SP_CERT_PATH
$certPwd  = $env:IDOP_SP_CERT_PASSWORD

# Validate required env vars
$missing = @()
if (-not $SiteUrl)  { $missing += 'IDOP_SP_URL' }
if (-not $tenant)   { $missing += 'IDOP_SP_TENANT' }
if (-not $clientId) { $missing += 'IDOP_SP_CLIENT_ID' }
if (-not $certPath) { $missing += 'IDOP_SP_CERT_PATH' }
if (-not $certPwd)  { $missing += 'IDOP_SP_CERT_PASSWORD' }

if ($missing.Count -gt 0) {
    Write-Host "[ERROR] Missing environment variables: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "[HINT]  Load .env first:  Get-Content .env | ForEach-Object { if ($_ -match '^([^#=]+)=(.*)$') { Set-Item \"Env:$($Matches[1].Trim())\" $Matches[2].Trim() } }" -ForegroundColor Yellow
    exit 1
}

$securePwd = ConvertTo-SecureString $certPwd -AsPlainText -Force

Write-Host "[TEST] Connecting to $SiteUrl via AppOnly Certificate..." -ForegroundColor Yellow
Write-Host "       TenantId : $tenant" -ForegroundColor DarkGray
Write-Host "       ClientId : $clientId" -ForegroundColor DarkGray
Write-Host "       CertPath : $certPath" -ForegroundColor DarkGray
try {
    Connect-PnPOnline -Url $SiteUrl -ClientId $clientId -Tenant $tenant -CertificatePath $certPath -CertificatePassword $securePwd
    $web = Get-PnPWeb
    Write-Host "[SUCCESS] Connected! Site Title: '$($web.Title)', Site URL: '$($web.Url)'" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 2
}
