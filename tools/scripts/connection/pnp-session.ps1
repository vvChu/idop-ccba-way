<#
.SYNOPSIS
  Connection/session helper for PnP.PowerShell.

.DESCRIPTION
  Provides lightweight functions to connect to SharePoint Online once per PowerShell session
  and reuse the same PnP connection across scripts to avoid repeated interactive prompts.

  Supports two auth modes:
  - Delegated interactive (recommended for ad-hoc/dev): Connect-PnPOnline -Interactive
  - App-only certificate (recommended for CI and non-interactive runs)

  Connections are cached per Site Url in a global hashtable and can be set as the current
  default context so subsequent PnP cmdlets work without passing -Connection each time.

.USAGE
  # Dot-source this file once in your session or at the top of a script:
  . "$PSScriptRoot/pnp-session.ps1"

  # Get or create a connection and set it as default for the session
  $conn = Get-IdopPnPConnection -Url "https://contoso.sharepoint.com/sites/dev" -Auth Delegated -SetDefault

  # Now use PnP as usual without further prompts in this terminal session
  Get-PnPList | Select-Object Title, RootFolder

  # Or pass the connection explicitly
  Get-PnPList -Connection $conn

.ENVIRONMENT VARIABLES (optional)
  IDOP_SP_AUTH_MODE          : 'Delegated' (default) | 'AppOnly'
  IDOP_SP_TENANT             : '<your-tenant>.onmicrosoft.com' (required for AppOnly)
  IDOP_SP_CLIENT_ID          : App registration (client) ID (required for AppOnly)
  IDOP_SP_CERT_PATH          : Path to PFX (AppOnly), e.g. .\.secrets\sp-app.pfx
  IDOP_SP_CERT_PASSWORD      : Plaintext password for the PFX (use with care) or leave empty to be prompted securely

.NOTES
  - Ensure PowerShell 7+ and PnP.PowerShell module are available.
  - For Delegated: run Register-PnPManagementShellAccess once per tenant to avoid admin consent prompts.
  - For AppOnly: grant Sites.Selected to target sites using Grant-PnPAzureADAppSitePermission.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
  Write-Verbose "PnP.PowerShell not found. Install with: Install-Module PnP.PowerShell -Scope CurrentUser"
}

# Global cache of connections per Site Url (StrictMode-safe)
if (-not (Get-Variable -Name IDOP_PNP_CONNECTIONS -Scope Global -ErrorAction SilentlyContinue)) {
  $global:IDOP_PNP_CONNECTIONS = @{}
}

function Get-IdopPnPConnection {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)][string]$Url,
    [ValidateSet('Delegated','AppOnly')][string]$Auth = 'Delegated',
    [switch]$SetDefault,

    # App-only inputs
    [string]$Tenant = $env:IDOP_SP_TENANT,
    [string]$ClientId = $env:IDOP_SP_CLIENT_ID,
    [string]$CertificatePath = $env:IDOP_SP_CERT_PATH,
    [SecureString]$CertificatePassword
  )

  # Apply environment default for Auth if caller didn't pass it
  if (-not $PSBoundParameters.ContainsKey('Auth')) {
    if ($env:IDOP_SP_AUTH_MODE -and $env:IDOP_SP_AUTH_MODE.Trim()) { $Auth = $env:IDOP_SP_AUTH_MODE }
  }

  # Return cached connection when available
  if ($global:IDOP_PNP_CONNECTIONS.ContainsKey($Url)) {
    $existing = $global:IDOP_PNP_CONNECTIONS[$Url]
    try {
      # If token is valid, this will succeed quickly; PnP handles refresh internally when possible
      $null = Get-PnPWeb -Connection $existing -ErrorAction Stop
      if ($SetDefault) { Set-IdopPnPDefault -Connection $existing }
      return $existing
    } catch {
      Write-Verbose "Cached connection seems expired/invalid. Reconnecting to $Url ..."
      $global:IDOP_PNP_CONNECTIONS.Remove($Url) | Out-Null
    }
  }

  $connection = $null
  if ($Auth -eq 'Delegated') {
    Write-Host "Connecting (delegated) to $Url ..." -ForegroundColor Cyan
    $cId = if ($PSBoundParameters.ContainsKey('ClientId') -and $ClientId) { $ClientId } elseif ($env:IDOP_SP_CLIENT_ID -and $env:IDOP_SP_CLIENT_ID.Trim()) { $env:IDOP_SP_CLIENT_ID } else { '90ded6f0-b787-4b3c-acea-8baf6403fd63' }
    try {
      $connection = Connect-PnPOnline -Url $Url -Interactive -ClientId $cId -ReturnConnection
    } catch {
      # Fallback without ClientId if module version complains
      $connection = Connect-PnPOnline -Url $Url -Interactive -ReturnConnection
    }
  } else {
    if (-not $Tenant)   { throw "AppOnly requires -Tenant (or env IDOP_SP_TENANT)." }
    if (-not $ClientId) { throw "AppOnly requires -ClientId (or env IDOP_SP_CLIENT_ID)." }

    if ($CertificatePath) {
      # Prefer PFX path when provided
      $securePwd = $CertificatePassword
      if (-not $securePwd) {
        # If env var is provided as plain text, convert it, else prompt
        if ($env:IDOP_SP_CERT_PASSWORD) {
          $securePwd = ConvertTo-SecureString -AsPlainText $env:IDOP_SP_CERT_PASSWORD -Force
        } else {
          $securePwd = Read-Host -AsSecureString -Prompt "Enter PFX password for $CertificatePath"
        }
      }
      Write-Host "Connecting (app-only, certificate path) to $Url ..." -ForegroundColor Cyan
      $connection = Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -CertificatePath $CertificatePath -CertificatePassword $securePwd -ReturnConnection
    } else {
      # Try using certificate from CurrentUser store by thumbprint via env IDOP_SP_CERT_THUMBPRINT
      $thumb = $env:IDOP_SP_CERT_THUMBPRINT
      if (-not $thumb) { throw "AppOnly requires either -CertificatePath or env IDOP_SP_CERT_THUMBPRINT." }
      Write-Host "Connecting (app-only, cert store thumbprint) to $Url ..." -ForegroundColor Cyan
      $connection = Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -CertificateThumbprint $thumb -ReturnConnection
    }
  }

  $global:IDOP_PNP_CONNECTIONS[$Url] = $connection
  if ($SetDefault) { Set-IdopPnPDefault -Connection $connection }
  return $connection
}

function Set-IdopPnPDefault {
  [CmdletBinding()]
  param([Parameter(Mandatory=$true)] [object]$Connection)

  # Prefer setting the underlying ClientContext so all PnP cmdlets work without -Connection
  if ($Connection.Context) {
    Set-PnPContext -Context $Connection.Context
  } else {
    # Fallback: remember as the implicit connection variable used by our scripts
    $global:IDOP_PNP_DEFAULT = $Connection
  }
}

function Get-IdopPnPDefaultConnection {
  [CmdletBinding()] param()
  if ((Get-Variable -Name IDOP_PNP_DEFAULT -Scope Global -ErrorAction SilentlyContinue) -and $global:IDOP_PNP_DEFAULT) { return $global:IDOP_PNP_DEFAULT }
  # No default set; attempt to return any cached connection
  if ($global:IDOP_PNP_CONNECTIONS -and $global:IDOP_PNP_CONNECTIONS.Count -gt 0) { return $global:IDOP_PNP_CONNECTIONS.Values | Select-Object -First 1 }
  return $null
}

# When imported as a module, export functions; when dot-sourced, they are already in scope
try {
  if ($ExecutionContext -and $ExecutionContext.SessionState -and $ExecutionContext.SessionState.Module) {
    Export-ModuleMember -Function Get-IdopPnPConnection, Set-IdopPnPDefault, Get-IdopPnPDefaultConnection
  }
} catch { }
