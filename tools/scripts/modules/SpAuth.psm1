function Connect-IdopOnline {
    param(
        [Parameter(Mandatory)] [string]$SiteUrl,
        [ValidateSet('Cached','Interactive','DeviceLogin','AppOnly')] [string]$AuthMode = 'Cached',
        [string]$Tenant,
        [string]$ClientId,
        [string]$CertificatePath,
        [SecureString]$CertificatePassword,
        [string]$CertificateThumbprint
    )

    # Ensure PnP module loaded
    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        Write-Host "[auth] ❌ Missing required module 'PnP.PowerShell'" -ForegroundColor Red
        throw "PnP.PowerShell not installed"
    }
    Import-Module PnP.PowerShell -ErrorAction Stop

    # If already connected to the same site, skip reconnect
    try {
        $current = Get-PnPConnection -ErrorAction SilentlyContinue
        if ($current -and $current.SiteUrl -and ($current.SiteUrl.TrimEnd('/') -ieq $SiteUrl.TrimEnd('/'))) {
            Write-Host "[auth] 🔁 Reusing existing PnP connection: $SiteUrl" -ForegroundColor Cyan
            return
        }
    } catch {}

    # App-only (certificate) for fully headless jobs
    if ($AuthMode -eq 'AppOnly') {
        # Gather parameters from explicit args or environment variables
        $effTenant   = if ($Tenant) { $Tenant } elseif ($env:IDOP_PNP_TENANT_ID) { $env:IDOP_PNP_TENANT_ID } elseif ($env:IDOP_PNP_TENANT) { $env:IDOP_PNP_TENANT } else { $null }
        $effClientId = if ($ClientId) { $ClientId } elseif ($env:IDOP_PNP_CLIENT_ID) { $env:IDOP_PNP_CLIENT_ID } else { $null }
        $effCertPath = if ($CertificatePath) { $CertificatePath } elseif ($env:IDOP_PNP_CERT_PATH) { $env:IDOP_PNP_CERT_PATH } else { $null }
        $effThumb    = if ($CertificateThumbprint) { $CertificateThumbprint } elseif ($env:IDOP_PNP_CERT_THUMBPRINT) { $env:IDOP_PNP_CERT_THUMBPRINT } else { $null }
        $effCertPwd  = $CertificatePassword
        if (-not $effCertPwd -and $env:IDOP_PNP_CERT_PASSWORD) {
            $effCertPwd = ConvertTo-SecureString -String $env:IDOP_PNP_CERT_PASSWORD -AsPlainText -Force
        }

        if (-not $effTenant -or -not $effClientId) {
            Write-Host "[auth] ❌ AppOnly requires Tenant and ClientId (set via params or env: IDOP_PNP_TENANT_ID/IDOP_PNP_TENANT, IDOP_PNP_CLIENT_ID)" -ForegroundColor Red
            throw "Missing Tenant/ClientId for AppOnly"
        }
        if (-not $effThumb -and -not $effCertPath) {
            Write-Host "[auth] ❌ AppOnly requires either CertificateThumbprint (env IDOP_PNP_CERT_THUMBPRINT) or CertificatePath (env IDOP_PNP_CERT_PATH)" -ForegroundColor Red
            throw "Missing certificate reference for AppOnly"
        }

        $connectParams = @{ Url = $SiteUrl; Tenant = $effTenant; ClientId = $effClientId }
        if ($effThumb) {
            $connectParams['CertificateThumbprint'] = $effThumb
            Write-Host "[auth] 🔐 Using certificate from CurrentUser store (thumbprint)" -ForegroundColor DarkCyan
        } else {
            $connectParams['CertificatePath'] = $effCertPath
            if ($effCertPwd) { $connectParams['CertificatePassword'] = $effCertPwd }
            Write-Host "[auth] 🔐 Using certificate file: $effCertPath" -ForegroundColor DarkCyan
        }

        Connect-PnPOnline @connectParams
        Write-Host "[auth] ✅ Connected using App-Only (certificate)" -ForegroundColor Green
        return
    }

    # Prefer cached login using PnP Management Shell app if requested
    if ($AuthMode -eq 'Cached') {
        $supportsPnPMS = $false
        try {
            $cmd = Get-Command -Name Connect-PnPOnline -ErrorAction Stop
            if ($cmd -and $cmd.Parameters.ContainsKey('PnPManagementShell')) { $supportsPnPMS = $true }
        } catch {}

        if ($supportsPnPMS) {
            try {
                if ($Tenant) { Connect-PnPOnline -Url $SiteUrl -PnPManagementShell -Tenant $Tenant -ErrorAction Stop }
                else { Connect-PnPOnline -Url $SiteUrl -PnPManagementShell -ErrorAction Stop }
                Write-Host "[auth] ✅ Connected using cached token (PnP Management Shell)" -ForegroundColor Green
                return
            } catch {
                Write-Host "[auth] ⚠️ Cached token connect failed, falling back (tip: run 'Register-PnPManagementShellAccess' once for your tenant). Error: $($_.Exception.Message)" -ForegroundColor DarkYellow
                # fall through to interactive/device
            }
        } else {
            Write-Host "[auth] ℹ️ PnP.PowerShell version doesn't support -PnPManagementShell. Falling back to Interactive (token should still be reused)." -ForegroundColor DarkYellow
        }
    }

    if ($AuthMode -eq 'DeviceLogin') {
        if ($Tenant -and $ClientId) { Connect-PnPOnline -Url $SiteUrl -DeviceLogin -ClientId $ClientId -Tenant $Tenant }
        elseif ($ClientId) { Connect-PnPOnline -Url $SiteUrl -DeviceLogin -ClientId $ClientId }
        else { Connect-PnPOnline -Url $SiteUrl -DeviceLogin }
        Write-Host "[auth] ✅ Connected using Device Login" -ForegroundColor Green
        return
    }

    # Default: Interactive
    if ($Tenant -and $ClientId) { Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId $ClientId -Tenant $Tenant }
    elseif ($ClientId) { Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId $ClientId }
    else { Connect-PnPOnline -Url $SiteUrl -Interactive }
    Write-Host "[auth] ✅ Connected using Interactive" -ForegroundColor Green
}

Export-ModuleMember -Function Connect-IdopOnline
