<#
.SYNOPSIS
    PnP PowerShell helper functions for IDOP platform
.DESCRIPTION
    Provides common functions for PnP connection management, session handling,
    and SharePoint operations across all IDOP scripts.
#>

#Requires -Modules PnP.PowerShell

# Import configuration
$script:Config = Import-PowerShellDataFile -Path "$PSScriptRoot/../../config/environments.psd1"

<#
.SYNOPSIS
    Gets configuration for a specific environment
.PARAMETER Environment
    Environment name (Dev, Test, Prod)
#>
function Get-IDOPConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Dev', 'Test', 'Prod')]
        [string]$Environment = 'Dev'
    )

    $envConfig = $script:Config[$Environment]
    $commonConfig = $script:Config.Common
    $pathsConfig = $script:Config.Paths

    return @{
        Environment = $Environment
        SharePointUrl = $envConfig.SharePointUrl
        SiteAlias = $envConfig.SiteAlias
        ClientId = $commonConfig.ClientId
        TenantId = $commonConfig.TenantId
        TermStoreGroup = $commonConfig.TermStoreGroup
        AllowDestructiveOperations = $envConfig.AllowDestructiveOperations
        EnableDryRun = $envConfig.EnableDryRun
        Paths = $pathsConfig
    }
}

<#
.SYNOPSIS
    Ensures a PnP connection exists for the specified environment
.PARAMETER Environment
    Environment name (Dev, Test, Prod)
.PARAMETER Force
    Force reconnection even if already connected
#>
function Connect-IDOPSharePoint {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Dev', 'Test', 'Prod')]
        [string]$Environment = 'Dev',

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    $config = Get-IDOPConfig -Environment $Environment

    try {
        # Check if already connected
        $existingConnection = Get-PnPConnection -ErrorAction SilentlyContinue

        if ($existingConnection -and -not $Force) {
            $currentUrl = $existingConnection.Url
            if ($currentUrl -eq $config.SharePointUrl) {
                Write-Host "✓ Already connected to $Environment environment ($currentUrl)" -ForegroundColor Green
                return $existingConnection
            }
            else {
                Write-Warning "Currently connected to different site: $currentUrl"
                Write-Host "Disconnecting and reconnecting to $($config.SharePointUrl)..."
                Disconnect-PnPOnline
            }
        }

        Write-Host "Connecting to $Environment environment..." -ForegroundColor Cyan
        Write-Host "  URL: $($config.SharePointUrl)" -ForegroundColor Gray

        $connection = Connect-PnPOnline `
            -Url $config.SharePointUrl `
            -Interactive `
            -ClientId $config.ClientId `
            -ReturnConnection `
            -ErrorAction Stop

        Write-Host "✓ Successfully connected to $Environment" -ForegroundColor Green
        return $connection
    }
    catch {
        Write-Error "Failed to connect to SharePoint: $_"
        throw
    }
}

<#
.SYNOPSIS
    Tests if a PnP connection is active and valid
#>
function Test-IDOPConnection {
    [CmdletBinding()]
    param()

    try {
        $connection = Get-PnPConnection -ErrorAction SilentlyContinue
        if ($null -eq $connection) {
            return $false
        }

        # Test the connection by getting web properties
        $null = Get-PnPWeb -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

<#
.SYNOPSIS
    Ensures PowerShell 7+ is being used
#>
function Assert-PowerShell7 {
    [CmdletBinding()]
    param()

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "This script requires PowerShell 7+. Current version: $($PSVersionTable.PSVersion)"
        Write-Host "Please upgrade to PowerShell 7: https://aka.ms/powershell" -ForegroundColor Yellow

        # Try to find pwsh
        $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
        if ($pwsh) {
            Write-Host "Found PowerShell 7 at: $($pwsh.Source)" -ForegroundColor Green
            Write-Host "Restarting script in PowerShell 7..."

            $scriptPath = $MyInvocation.PSCommandPath
            $arguments = $MyInvocation.BoundParameters

            & $pwsh.Source -NoProfile -File $scriptPath @arguments
            exit
        }
        else {
            throw "PowerShell 7+ not found. Please install from https://aka.ms/powershell"
        }
    }
}

<#
.SYNOPSIS
    Gets a SharePoint list with error handling
.PARAMETER ListName
    Internal name of the list
.PARAMETER ThrowOnError
    Throw exception if list not found (default: false)
#>
function Get-IDOPList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListName,

        [Parameter(Mandatory = $false)]
        [switch]$ThrowOnError
    )

    try {
        $list = Get-PnPList -Identity $ListName -ErrorAction Stop
        return $list
    }
    catch {
        if ($ThrowOnError) {
            throw "List '$ListName' not found: $_"
        }
        else {
            Write-Verbose "List '$ListName' not found"
            return $null
        }
    }
}

<#
.SYNOPSIS
    Safely invokes a script block with retry logic
.PARAMETER ScriptBlock
    The script block to execute
.PARAMETER MaxRetries
    Maximum number of retries (default: 3)
.PARAMETER RetryDelaySeconds
    Delay between retries in seconds (default: 2)
.PARAMETER ErrorMessage
    Custom error message prefix
#>
function Invoke-IDOPWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3,

        [Parameter(Mandatory = $false)]
        [int]$RetryDelaySeconds = 2,

        [Parameter(Mandatory = $false)]
        [string]$ErrorMessage = "Operation failed"
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -lt $MaxRetries) {
        $attempt++
        try {
            return & $ScriptBlock
        }
        catch {
            $lastError = $_
            if ($attempt -lt $MaxRetries) {
                Write-Warning "$ErrorMessage (attempt $attempt/$MaxRetries). Retrying in $RetryDelaySeconds seconds..."
                Start-Sleep -Seconds $RetryDelaySeconds
            }
        }
    }

    throw "$ErrorMessage after $MaxRetries attempts: $lastError"
}

<#
.SYNOPSIS
    Connects to SharePoint with multiple auth modes (Interactive, Cached, DeviceLogin, AppOnly).
    Merged from SpAuth.psm1 — used by scripts that call Connect-IdopOnline dynamically.
.PARAMETER SiteUrl
    SharePoint site URL
.PARAMETER AuthMode
    Authentication mode
#>
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

    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell not installed"
    }
    Import-Module PnP.PowerShell -ErrorAction Stop

    # Reuse existing connection if same site
    try {
        $current = Get-PnPConnection -ErrorAction SilentlyContinue
        if ($current -and $current.SiteUrl -and ($current.SiteUrl.TrimEnd('/') -ieq $SiteUrl.TrimEnd('/'))) {
            Write-Host "[auth] Reusing existing PnP connection: $SiteUrl" -ForegroundColor Cyan
            return
        }
    } catch {}

    if ($AuthMode -eq 'AppOnly') {
        $effTenant   = if ($Tenant) { $Tenant } elseif ($env:IDOP_PNP_TENANT_ID) { $env:IDOP_PNP_TENANT_ID } elseif ($env:IDOP_PNP_TENANT) { $env:IDOP_PNP_TENANT } else { $null }
        $effClientId = if ($ClientId) { $ClientId } elseif ($env:IDOP_PNP_CLIENT_ID) { $env:IDOP_PNP_CLIENT_ID } else { $null }
        $effCertPath = if ($CertificatePath) { $CertificatePath } elseif ($env:IDOP_PNP_CERT_PATH) { $env:IDOP_PNP_CERT_PATH } else { $null }
        $effThumb    = if ($CertificateThumbprint) { $CertificateThumbprint } elseif ($env:IDOP_PNP_CERT_THUMBPRINT) { $env:IDOP_PNP_CERT_THUMBPRINT } else { $null }
        $effCertPwd  = $CertificatePassword
        if (-not $effCertPwd -and $env:IDOP_PNP_CERT_PASSWORD) {
            $effCertPwd = ConvertTo-SecureString -String $env:IDOP_PNP_CERT_PASSWORD -AsPlainText -Force
        }
        if (-not $effTenant -or -not $effClientId) { throw "AppOnly requires Tenant and ClientId" }
        if (-not $effThumb -and -not $effCertPath) { throw "AppOnly requires CertificateThumbprint or CertificatePath" }

        $connectParams = @{ Url = $SiteUrl; Tenant = $effTenant; ClientId = $effClientId }
        if ($effThumb) { $connectParams['CertificateThumbprint'] = $effThumb }
        else {
            $connectParams['CertificatePath'] = $effCertPath
            if ($effCertPwd) { $connectParams['CertificatePassword'] = $effCertPwd }
        }
        Connect-PnPOnline @connectParams
        Write-Host "[auth] Connected using App-Only (certificate)" -ForegroundColor Green
        return
    }

    if ($AuthMode -eq 'Cached') {
        try {
            $cmd = Get-Command -Name Connect-PnPOnline -ErrorAction Stop
            if ($cmd.Parameters.ContainsKey('PnPManagementShell')) {
                if ($Tenant) { Connect-PnPOnline -Url $SiteUrl -PnPManagementShell -Tenant $Tenant -ErrorAction Stop }
                else { Connect-PnPOnline -Url $SiteUrl -PnPManagementShell -ErrorAction Stop }
                Write-Host "[auth] Connected using cached token" -ForegroundColor Green
                return
            }
        } catch {}
    }

    if ($AuthMode -eq 'DeviceLogin') {
        if ($Tenant -and $ClientId) { Connect-PnPOnline -Url $SiteUrl -DeviceLogin -ClientId $ClientId -Tenant $Tenant }
        elseif ($ClientId) { Connect-PnPOnline -Url $SiteUrl -DeviceLogin -ClientId $ClientId }
        else { Connect-PnPOnline -Url $SiteUrl -DeviceLogin }
        Write-Host "[auth] Connected using Device Login" -ForegroundColor Green
        return
    }

    # Default: Interactive
    if ($Tenant -and $ClientId) { Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId $ClientId -Tenant $Tenant }
    elseif ($ClientId) { Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId $ClientId }
    else { Connect-PnPOnline -Url $SiteUrl -Interactive }
    Write-Host "[auth] Connected using Interactive" -ForegroundColor Green
}

# Export module members
Export-ModuleMember -Function @(
    'Get-IDOPConfig',
    'Connect-IDOPSharePoint',
    'Connect-IdopOnline',
    'Test-IDOPConnection',
    'Assert-PowerShell7',
    'Get-IDOPList',
    'Invoke-IDOPWithRetry'
)
