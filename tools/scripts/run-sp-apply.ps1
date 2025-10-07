param(
  [ValidateSet('Dev','Test','Prod')]
  [string]$Environment = 'Test',
  [switch]$DryRun,
  [string]$ListsPath = 'datamodel/sharepoint/lists',
  [string]$OnlyLists,
  [switch]$Fast,
  [switch]$Full
)

$ErrorActionPreference = 'Stop'

# Reuse same-process PnP context to avoid prompts
& (Join-Path $PSScriptRoot 'connect-sp.ps1') -Environment $Environment -Auth Interactive

# Ensure environment variable is set for apply script's env selection logic
$env:IDOP_ENVIRONMENT = $Environment

$applyScript = Join-Path $PSScriptRoot 'apply-sp-lists.ps1'
$invokeArgs = @{ ListsPath = $ListsPath }
# Default to DryRun if caller didn't specify
if (-not $PSBoundParameters.ContainsKey('DryRun')) { $invokeArgs['DryRun'] = $true }
elseif ($DryRun) { $invokeArgs['DryRun'] = $true }
if ($OnlyLists) { $invokeArgs['OnlyLists'] = $OnlyLists }
if ($Fast) { $invokeArgs['Fast'] = $true }
if ($Full) { $invokeArgs['Full'] = $true }
& $applyScript @invokeArgs
