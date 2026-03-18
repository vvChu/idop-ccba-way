param(
  [ValidateSet('Dev','Test','Prod')][string]$Environment = 'Dev',
  [switch]$DryRun,
  [ValidateSet('Cached','Interactive','DeviceLogin')][string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'

function Step($name){ Write-Host ("\n=== {0} ===" -f $name) -ForegroundColor Yellow }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor DarkYellow }

Step "Auth capability"
& "$PSScriptRoot/check-pnp-auth-capability.ps1" | Out-Null

Step "Pre-diff ($Environment)"
& "$PSScriptRoot/sp-diff.ps1" -Environment $Environment -Auth $Auth | Out-Null

if ($DryRun) { Warn "DRY-RUN: will not perform changes; showing what would run" }

Step "Migrate MM fields (create clean + backfill)"
$mmArgs = @{ Environment=$Environment; Auth=$Auth }
if ($DryRun) { $mmArgs['DryRun'] = $true }
& "$PSScriptRoot/migrate-mm-cleanup.ps1" @mmArgs

Step "Update default views"
$viewArgs = @{ Environment=$Environment; Auth=$Auth; HideLegacy=$true }
if ($DryRun) { $viewArgs['DryRun'] = $true }
& "$PSScriptRoot/update-views-mm.ps1" @viewArgs

Step "Post-diff ($Environment)"
& "$PSScriptRoot/sp-diff.ps1" -Environment $Environment -Auth $Auth | Out-Null

Ok "Sequence complete."
