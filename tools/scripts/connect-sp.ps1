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

$envMap = @{ Dev='https://ibstbim.sharepoint.com/sites/idop-dev'; Test='https://ibstbim.sharepoint.com/sites/idop-test'; Prod='https://ibstbim.sharepoint.com/sites/idop-prod' }
if (-not $envMap.ContainsKey($Environment)) { Write-Log "Unknown environment: $Environment" Red; exit 1 }
$siteUrl = $envMap[$Environment]

# Load PnP module
if (-not (Get-Module -ListAvailable -Name 'PnP.PowerShell')) {
  Write-Log "Missing PnP.PowerShell. Install it: Install-Module PnP.PowerShell -Scope CurrentUser -Force" Yellow
  exit 2
}
Import-Module PnP.PowerShell -ErrorAction Stop

# Optionally import session helper to set default context
$helper = Join-Path $PSScriptRoot 'pnp-session.ps1'
if (Test-Path $helper) { . $helper }

Write-Log "[connect-sp] Connecting to $Environment ($siteUrl) using $Auth..." Cyan
try {
  if ($Auth -eq 'DeviceLogin') {
    Connect-PnPOnline -Url $siteUrl -DeviceLogin
  } else {
    # Interactive browser login
    try {
      # Try with default client id first
      Connect-PnPOnline -Url $siteUrl -Interactive -ClientId '90ded6f0-b787-4b3c-acea-8baf6403fd63'
    } catch {
      # Fallback: without client id for older/newer module behaviors
      Connect-PnPOnline -Url $siteUrl -Interactive
    }
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
