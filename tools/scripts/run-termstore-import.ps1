param(
  [ValidateSet('Dev','Test','Prod')]
  [string]$Environment = 'Test',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# Reuse same-process PnP context
& (Join-Path $PSScriptRoot 'connect-sp.ps1') -Environment $Environment -Auth Interactive

$importScript = Join-Path $PSScriptRoot 'termstore-import.ps1'
$invokeArgs = @{ Environment = $Environment }
# Default DryRun to true unless explicitly disabled
if (-not $PSBoundParameters.ContainsKey('DryRun')) { $invokeArgs['DryRun'] = $true }
elseif ($DryRun) { $invokeArgs['DryRun'] = $true }
& $importScript @invokeArgs
