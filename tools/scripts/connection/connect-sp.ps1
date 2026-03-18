param(
  [ValidateSet('Dev','Test','Prod')]
  [string]$Environment = 'Dev',
  [ValidateSet('Interactive','DeviceLogin')]
  [string]$Auth = 'Interactive'
)

$ErrorActionPreference = 'Stop'

function Write-Log {
  param([string]$Message, [ConsoleColor]$Color = [ConsoleColor]::White)
  Write-Host $Message -ForegroundColor $Color
}

# Load PnP module
if (-not (Get-Module -ListAvailable -Name 'PnP.PowerShell')) {
  Write-Log "Missing PnP.PowerShell. Install it: Install-Module PnP.PowerShell -Scope CurrentUser -Force" Yellow
  exit 2
}
Import-Module PnP.PowerShell -ErrorAction Stop

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Get environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Log "[connect-sp] Connecting to $Environment ($siteUrl) using $Auth..." Cyan
try {
  if ($Auth -eq 'DeviceLogin') {
    Connect-PnPOnline -Url $siteUrl -DeviceLogin
  } else {
    # Interactive browser login using Connect-IdopOnline
    Connect-IdopOnline -SiteUrl $siteUrl -AuthMode Interactive -ClientId $config.ClientId
  }
  # Set default PnP context so subsequent scripts don't need -Connection
  try {
    $ctx = Get-PnPContext
    if ($ctx) { Set-PnPContext -Context $ctx }
  } catch {}
  Write-Log "[connect-sp] Connected and context set." Green
} catch {
  Write-Log "[connect-sp] Connect failed: $($_.Exception.Message)" Red
  exit 3
}
