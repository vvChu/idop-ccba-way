param(
  [ValidateSet('Dev','Test','Prod','IDOP')]
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

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Get environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

try {
  $connected = $false
  try { $null = Get-PnPWeb -ErrorAction Stop; $connected = $true } catch {}
  if (-not $connected) {
    $mode = if ($env:IDOP_SP_AUTH_MODE) { $env:IDOP_SP_AUTH_MODE } else { 'Delegated' }
    Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $mode -ClientId $config.ClientId
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
  if ($Environment -eq 'IDOP' -or $Environment -eq 'Prod') {
    $out = $out.Replace('/sites/idop-{env}', '/sites/idop')
    $out = $out.Replace('{env}', 'idop')
  } else {
    $out = $out.Replace('{env}', $Environment.ToLower())
  }
  $out = $out.Replace('{site}', $siteUrl.TrimEnd('/'))
  return $out
}

function Get-NavLocationConst {
  if ($Location -eq 'QuickLaunch') { return 'QuickLaunch' } else { return 'TopNavigationBar' }
}

$navLoc = Get-NavLocationConst
Write-Host "[nav] Syncing navigation from '$ConfigPath' (DryRun=$DryRun, Location=$Location, Prune=$Prune)" -ForegroundColor Cyan

foreach ($g in $groups) {
  $groupTitle = $g.Title
  $nodes = ConvertTo-NodeArray $g.Nodes
  Write-Host "[nav] Group: $groupTitle" -ForegroundColor Yellow

  # Find existing group node or create group container
  $rootNodes = Get-PnPNavigationNode -Location $navLoc
  $groupNode = $rootNodes | Where-Object { $_.Title -eq $groupTitle } | Select-Object -First 1

  # Clean up duplicate group nodes if more than one exists
  $duplicateGroups = $rootNodes | Where-Object { $_.Title -eq $groupTitle }
  if ($duplicateGroups.Count -gt 1) {
    Write-Host "[nav] Cleaning up duplicate group nodes for '$groupTitle'..." -ForegroundColor DarkYellow
    for ($i = 1; $i -lt $duplicateGroups.Count; $i++) {
      try { Remove-PnPNavigationNode -Identity $duplicateGroups[$i].Id -Force } catch {}
    }
  }

  if (-not $groupNode) {
    if ($DryRun) {
      Write-Host "[nav] (dry-run) Would add group '$groupTitle'" -ForegroundColor DarkCyan
      continue
    } else {
      Write-Host "[nav] Adding group node '$groupTitle'..." -ForegroundColor Gray
      $groupNode = Add-PnPNavigationNode -Title $groupTitle -Location $navLoc -Url $siteUrl -ErrorAction Stop
    }
  }

  if (-not $groupNode) {
    Write-Host "[nav] (warn) Could not resolve or create group node '$groupTitle'" -ForegroundColor Red
    continue
  }

  # Fetch current child nodes SPECIFICALLY under this group node
  $groupDetail = Get-PnPNavigationNode -Id $groupNode.Id
  $existingChildren = @($groupDetail.Children)

  foreach ($n in $nodes) {
    $title = $n.Title
    $url = Resolve-UrlToken $n.Url

    # Check if child node already exists under this specific group
    $child = $existingChildren | Where-Object { $_.Title -eq $title } | Select-Object -First 1

    if (-not $child) {
      if ($DryRun) {
        Write-Host "[nav] (dry-run) Would add link '$title' -> $url under '$groupTitle'" -ForegroundColor DarkCyan
      } else {
        Write-Host "[nav] Adding link '$title' ($url) under '$groupTitle'..." -ForegroundColor Gray
        try {
          Add-PnPNavigationNode -Title $title -Location $navLoc -Url $url -Parent $groupNode.Id -ErrorAction Stop | Out-Null
        } catch {
          Write-Host "[nav] (fallback external) Adding link '$title' with -External..." -ForegroundColor DarkGray
          Add-PnPNavigationNode -Title $title -Location $navLoc -Url $url -Parent $groupNode.Id -External -ErrorAction Stop | Out-Null
        }
      }
    } else {
      # Update if URL changed
      $currentUrl = $child.Url
      if ($currentUrl -ne $url) {
        if ($DryRun) {
          Write-Host "[nav] (dry-run) Would update link '$title' URL: $currentUrl -> $url" -ForegroundColor DarkCyan
        } else {
          Write-Host "[nav] Updating link '$title' URL..." -ForegroundColor Gray
          try { Remove-PnPNavigationNode -Identity $child.Id -Force } catch {}
          try {
            Add-PnPNavigationNode -Title $title -Location $navLoc -Url $url -Parent $groupNode.Id -ErrorAction Stop | Out-Null
          } catch {
            Add-PnPNavigationNode -Title $title -Location $navLoc -Url $url -Parent $groupNode.Id -External -ErrorAction Stop | Out-Null
          }
        }
      } else {
        Write-Host "[nav] Link '$title' already up to date" -ForegroundColor DarkGray
      }
    }
  }
}

Write-Host "[nav] Navigation sync completed successfully." -ForegroundColor Green
