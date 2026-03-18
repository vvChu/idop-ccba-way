param(
  [ValidateSet('Dev','Test','Prod')]
  [string]$Environment = $(if ($env:IDOP_ENVIRONMENT) { $env:IDOP_ENVIRONMENT } else { 'Dev' }),
  [string]$ConfigPath = "datamodel/sharepoint/navigation/global-navigation.json",
  [ValidateSet('Top','QuickLaunch')]
  [string]$Location = 'Top',
  [switch]$Prune,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ConfigPath)) { Write-Host "[nav] Config not found: $ConfigPath" -ForegroundColor Red; exit 1 }

# Re-exec under PowerShell 7+ if currently running in Windows PowerShell 5.1
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "[nav] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
  $pwshCmd = $null
  try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
  if (-not $pwshCmd) { Write-Host "[nav] Please install PowerShell 7.4.6+" -ForegroundColor Red; exit 5 }
  $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSCommandPath")
  foreach ($k in $PSBoundParameters.Keys) {
    $v = $PSBoundParameters[$k]
    $argList += "-$k"
    if ($null -ne $v -and $v -ne $true) { $argList += "$v" }
  }
  & $pwshCmd @argList
  exit $LASTEXITCODE
}

if (-not (Get-Module -ListAvailable -Name 'PnP.PowerShell')) {
  Write-Host "[nav] Missing PnP.PowerShell. Install it: Install-Module PnP.PowerShell -Scope CurrentUser -Force" -ForegroundColor Red
  exit 2
}
Import-Module PnP.PowerShell -ErrorAction Stop

$envMap = @{ Dev='https://ibstbim.sharepoint.com/sites/idop-dev'; Test='https://ibstbim.sharepoint.com/sites/idop-test'; Prod='https://ibstbim.sharepoint.com/sites/idop-prod' }
if (-not $envMap.ContainsKey($Environment)) { Write-Host "[nav] Unknown environment: $Environment" -ForegroundColor Red; exit 1 }
$siteUrl = $envMap[$Environment]

$helper = Join-Path $PSScriptRoot 'pnp-session.ps1'
if (Test-Path $helper) { . $helper }

try {
  $connected = $false
  try { $null = Get-PnPWeb -ErrorAction Stop; $connected = $true } catch {}
  if (-not $connected) {
    if (Get-Command -Name Get-IdopPnPConnection -ErrorAction SilentlyContinue) {
      $mode = if ($env:IDOP_SP_AUTH_MODE) { $env:IDOP_SP_AUTH_MODE } else { 'Delegated' }
      $null = Get-IdopPnPConnection -Url $siteUrl -Auth $mode -SetDefault
    } else {
      Connect-PnPOnline -Url $siteUrl -Interactive -ClientId '90ded6f0-b787-4b3c-acea-8baf6403fd63'
    }
  }
  Write-Host "[nav] Connected to $Environment ($siteUrl)" -ForegroundColor Green
} catch { Write-Host "[nav] Connect failed: $($_.Exception.Message)" -ForegroundColor Red; exit 3 }

function ConvertTo-NodeArray {
  param($nodes)
  $arr = @()
  if ($nodes -is [System.Collections.IEnumerable] -and -not ($nodes -is [string])) { $arr = @($nodes) }
  return $arr
}

$config = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
$groups = ConvertTo-NodeArray $config.Groups

function Resolve-UrlToken {
  param([string]$u)
  if ([string]::IsNullOrWhiteSpace($u)) { return $u }
  $out = $u
  # Replace tokens
  $out = $out.Replace('{env}', $Environment.ToLower())
  $out = $out.Replace('{site}', $siteUrl.TrimEnd('/'))
  return $out
}

function Get-NavLocationConst {
  if ($Location -eq 'QuickLaunch') { return 'QuickLaunch' } else { return 'TopNavigationBar' }
}

Write-Host "[nav] Syncing navigation from '$ConfigPath' (DryRun=$DryRun, Location=$Location, Prune=$Prune)" -ForegroundColor Cyan

foreach ($g in $groups) {
  $groupTitle = $g.Title
  $nodes = ConvertTo-NodeArray $g.Nodes
  Write-Host "[nav] Group: $groupTitle" -ForegroundColor Yellow

  # Find existing node or create group container (as a heading link to site root)
  $navLoc = Get-NavLocationConst
  $rootNodes = Get-PnPNavigationNode -Location $navLoc -Tree
  $groupNode = $rootNodes | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1
  if (-not $groupNode) {
    if ($DryRun) { Write-Host "[nav] (dry-run) Would add group '$groupTitle'" -ForegroundColor DarkCyan }
    else { $groupNode = Add-PnPNavigationNode -Title $groupTitle -Location $navLoc -Url $siteUrl -ErrorAction Stop }
  }

  foreach ($n in $nodes) {
    $title = $n.Title; $url = Resolve-UrlToken $n.Url
    $child = $null
    if ($groupNode -and $groupNode.Children) {
      $child = $groupNode.Children | Where-Object { $_.Title -eq $title } | Select-Object -First 1
    } else {
      # refetch children when group node was just created
      $rootNodes = Get-PnPNavigationNode -Location $navLoc -Tree
      $groupNode = $rootNodes | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1
      if ($groupNode) { $child = $groupNode.Children | Where-Object { $_.Title -eq $title } | Select-Object -First 1 }
    }

    if (-not $child) {
      if ($DryRun) { Write-Host "[nav] (dry-run) Would add link '$title' -> $url under '$groupTitle'" -ForegroundColor DarkCyan }
      else { Add-PnPNavigationNode -Title $title -Location $navLoc -Url $url -Parent $groupNode -ErrorAction Stop | Out-Null }
    } else {
      # Update if URL changed
      $currentUrl = $child.Url
      if ($currentUrl -ne $url) {
        if ($DryRun) { Write-Host "[nav] (dry-run) Would update link '$title' URL: $currentUrl -> $url" -ForegroundColor DarkCyan }
        else {
          try { Remove-PnPNavigationNode -Identity $child.Id -Force -Location $navLoc } catch {}
          Add-PnPNavigationNode -Title $title -Location $navLoc -Url $url -Parent $groupNode -ErrorAction Stop | Out-Null
        }
      }
    }
  }

  if ($Prune -and $groupNode) {
    # Remove existing child nodes not present in config
    $desiredTitles = @($nodes | ForEach-Object { $_.Title })
    $currentChildren = @()
    try { $currentChildren = ($groupNode.Children | ForEach-Object { $_ }) } catch { $currentChildren = @() }
    foreach ($c in $currentChildren) {
      if ($desiredTitles -notcontains $c.Title) {
        if ($DryRun) { Write-Host "[nav] (dry-run) Would remove unmanaged link '$($c.Title)' under '$groupTitle'" -ForegroundColor DarkCyan }
        else { try { Remove-PnPNavigationNode -Identity $c.Id -Force -Location $navLoc } catch { Write-Host "[nav] (warn) Failed to remove '$($c.Title)': $($_.Exception.Message)" -ForegroundColor DarkYellow } }
      }
    }
  }
}

Write-Host "[nav] Navigation sync completed." -ForegroundColor Green
