param(
  [ValidateSet('Dev','Test','Prod','IDOP')]
  [string]$Environment = 'Test',
  [ValidateSet('all','issues','changed')]
  [string]$Focus = 'all',
  [string]$OnlyLists,
  [string]$SinceGit
)

$ErrorActionPreference = 'Stop'

& (Join-Path $PSScriptRoot 'connect-sp.ps1') -Environment $Environment -Auth Interactive

$diffScript = Join-Path $PSScriptRoot 'sp-diff.ps1'
$args = @{ Environment = $Environment; Auth = 'Interactive'; Focus = $Focus }
if ($OnlyLists) { $args['OnlyLists'] = $OnlyLists }
if ($SinceGit) { $args['SinceGit'] = $SinceGit }
& $diffScript @args
