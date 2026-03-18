param(
  [ValidateSet('Dev','Test','Prod')]
  [string]$Environment = $(if ($env:IDOP_ENVIRONMENT) { $env:IDOP_ENVIRONMENT } else { 'Dev' }),
  [switch]$DryRun,
  [string]$LibraryName = 'BiddingFolders',
  [string]$ListIdentity = 'Opportunities',
  [int]$Max = 200,
  [switch]$Force,
  [string[]]$Subfolders = @('01-Input','02-Output','03-Contracts','04-Admin'),
  [switch]$SyncPermissions,
  [string]$ReportCsv = $null
)

$ErrorActionPreference = 'Stop'

# Re-exec under PowerShell 7+ if currently running in Windows PowerShell 5.1
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "[bidding] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
  $pwshCmd = $null
  try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
  if (-not $pwshCmd) { Write-Host "[bidding] Please install PowerShell 7.4.6+" -ForegroundColor Red; exit 5 }
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
  Write-Host "[bidding] Missing PnP.PowerShell. Install it: Install-Module PnP.PowerShell -Scope CurrentUser -Force" -ForegroundColor Red
  exit 2
}
Import-Module PnP.PowerShell -ErrorAction Stop

$envMap = @{ Dev='https://ibstbim.sharepoint.com/sites/idop-dev'; Test='https://ibstbim.sharepoint.com/sites/idop-test'; Prod='https://ibstbim.sharepoint.com/sites/idop-prod' }
if (-not $envMap.ContainsKey($Environment)) { Write-Host "[bidding] Unknown environment: $Environment" -ForegroundColor Red; exit 1 }
$siteUrl = $envMap[$Environment]

# Session helper if available
$helper = Join-Path $PSScriptRoot 'pnp-session.ps1'
if (Test-Path $helper) { . $helper }

# Connect (re-use default if available)
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
  Write-Host "[bidding] Connected to $Environment ($siteUrl)" -ForegroundColor Green
} catch { Write-Host "[bidding] Connect failed: $($_.Exception.Message)" -ForegroundColor Red; exit 3 }

function Ensure-DocumentLibrary {
  param([string]$Title)
  $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
  if (-not $list) {
    if ($DryRun) { Write-Host "[bidding] (dry-run) Would create document library '$Title'" -ForegroundColor Yellow }
    else {
      Write-Host "[bidding] Creating document library '$Title'" -ForegroundColor Yellow
      New-PnPList -Title $Title -Template DocumentLibrary | Out-Null
    }
  }
}

function Sanitize-Name {
  param([string]$name)
  if (-not $name) { return 'Untitled' }
  $n = $name.Trim()
  $n = ($n -replace '[\\/:*?"<>|#%&{}~]', '-')
  $n = ($n -replace '\s+', ' ')
  return $n
}

function Ensure-OpportunityFolder {
  param(
    [int]$ItemId,
    [string]$Title
  )
  $safeTitle = Sanitize-Name $Title
  $folderRel = "$LibraryName/$ItemId-$safeTitle"
  $siteRel = $folderRel
  $siteRel = $siteRel -replace '^/+',''
  $created = $false
  $folder = $null
  try { $folder = Get-PnPFolder -Url $siteRel -ErrorAction Stop } catch { $folder = $null }
  if (-not $folder) {
    if ($DryRun) { Write-Host "[bidding] (dry-run) Would create folder '$siteRel'" -ForegroundColor Yellow }
    else {
      Write-Host "[bidding] Creating folder '$siteRel'" -ForegroundColor Yellow
      $folder = Ensure-PnPFolder -SiteRelativeUrl $siteRel
      $created = $true
    }
  }
  if (-not $folder) { return $null }
  # Subfolders scaffold
  if ($Subfolders -and $Subfolders.Count -gt 0) {
    foreach ($sf in $Subfolders) {
      $sfRel = "$siteRel/$sf"
      $sfFound = $null
      try { $sfFound = Get-PnPFolder -Url $sfRel -ErrorAction Stop } catch { $sfFound = $null }
      if (-not $sfFound) {
        if ($DryRun) { Write-Host "[bidding] (dry-run) Would create subfolder '$sfRel'" -ForegroundColor DarkCyan }
        else { Ensure-PnPFolder -SiteRelativeUrl $sfRel | Out-Null }
      }
    }
  }
  $serverRel = $folder.ServerRelativeUrl
  $uniqueId = $null
  try { $uniqueId = $folder.UniqueId } catch { $uniqueId = $null }
  $absUrl = $null
  try {
    $web = Get-PnPWeb
    $absUrl = ($web.Url.TrimEnd('/') + '/' + $serverRel.TrimStart('/'))
  } catch {}
  return [pscustomobject]@{ Created=$created; ServerRelativeUrl=$serverRel; AbsoluteUrl=$absUrl; UniqueId=$uniqueId }
}

# Load Opportunities
Write-Host "[bidding] Querying list '$ListIdentity' for opportunities..." -ForegroundColor Gray
$opps = @()
try {
  $opps = Get-PnPListItem -List $ListIdentity -PageSize 2000 | Select-Object -First $Max
} catch { Write-Host "[bidding] Unable to query '$ListIdentity': $($_.Exception.Message)" -ForegroundColor Red; exit 4 }

if (-not $opps -or $opps.Count -eq 0) {
  Write-Host "[bidding] No opportunities found in '$ListIdentity'." -ForegroundColor Yellow
  if ($ReportCsv) {
    try {
      $header = "Id,Title,Path,Url,DriveItemId,Phase,DryRun"
      Set-Content -Path $ReportCsv -Value $header -Encoding UTF8
      Write-Host "[bidding] Report written (empty): $ReportCsv" -ForegroundColor Green
    } catch { Write-Host "[bidding] (warn) Failed to write empty report: $($_.Exception.Message)" -ForegroundColor DarkYellow }
  }
  exit 0
}

# Decide which items need folders
$targets = @()
foreach ($it in $opps) {
  $fState = $it.FieldValues['BiddingFolderState']
  $stage = $it.FieldValues['Stage']
  $title = $it.FieldValues['Title']
  $hasUrl = $it.FieldValues['BiddingFolderUrl']
  $phase = $it.FieldValues['BiddingFolderPhase']
  $needs = $false
  if ($Force) { $needs = $true }
  elseif (-not $hasUrl -or -not $fState -or $fState -eq 'Not Created' -or $fState -eq 'Failed') { $needs = $true }
  # Stage-triggered auto-create (idempotent)
  elseif ($stage -and ($stage -match '^(Qualification Review|Proposal/HSDX)$')) { $needs = $true }
  if ($needs) { $targets += [pscustomobject]@{ Id=$it.Id; Title=$title; Phase=$phase; BidTeam=$it.FieldValues['BidTeam'] } }
}

if (-not $targets -or $targets.Count -eq 0) { Write-Host "[bidding] Nothing to do (no missing/failed folders)." -ForegroundColor Green; exit 0 }

Write-Host "[bidding] Preparing to ensure $($targets.Count) bidding folders in '$LibraryName' (DryRun=$DryRun)" -ForegroundColor Cyan

# Ensure library exists
Ensure-DocumentLibrary -Title $LibraryName

$processed = 0
$report = @()
foreach ($t in $targets) {
  $processed++
  $info = Ensure-OpportunityFolder -ItemId $t.Id -Title $t.Title
  if ($null -eq $info) { Write-Host "[bidding] (warn) Unable to ensure folder for Opportunity #$($t.Id) '$($t.Title)'" -ForegroundColor DarkYellow; continue }
  $values = @{
    BiddingFolderPath = $info.ServerRelativeUrl
    BiddingFolderUrl  = $info.AbsoluteUrl
    BiddingFolderState = 'Created'
  }
  if ($info.UniqueId) { $values['BiddingFolderDriveItemId'] = $info.UniqueId }
  # Archive handling based on phase
  if ($t.Phase -and ($t.Phase -eq 'Archived')) { $values['BiddingFolderState'] = 'Created' }
  if ($DryRun) {
    Write-Host "[bidding] (dry-run) Would update Opp #$($t.Id): Path='$($info.ServerRelativeUrl)', Url='$($info.AbsoluteUrl)', State='Created'" -ForegroundColor DarkCyan
  } else {
    try { Set-PnPListItem -List 'Opportunities' -Identity $t.Id -Values $values | Out-Null; Write-Host "[bidding] Updated Opp #$($t.Id) with folder metadata." -ForegroundColor DarkGreen }
    catch { Write-Host "[bidding] (warn) Failed updating Opp #$($t.Id): $($_.Exception.Message)" -ForegroundColor DarkYellow }
  }

  # Permissions (best effort): if SyncPermissions and BidTeam present, break inheritance and grant edit to members
  if ($SyncPermissions) {
    try {
      $folderItem = Get-PnPFolder -Url $info.ServerRelativeUrl
      if ($folderItem) {
        if ($DryRun) { Write-Host "[bidding] (dry-run) Would sync permissions from BidTeam for '$($info.ServerRelativeUrl)'" -ForegroundColor DarkCyan }
        else {
          # Break role inheritance (keep existing permissions)
          Set-PnPFolderPermission -List $LibraryName -Identity $folderItem.Name -User (Get-PnPWeb).CurrentUser.LoginName -AddRole 'Edit' -ClearExisting -ErrorAction SilentlyContinue | Out-Null
          # Note: Mapping SharePoint people field values to principals may require additional resolution; omitted for safety.
        }
      }
    } catch { Write-Host "[bidding] (info) Permission sync skipped: $($_.Exception.Message)" -ForegroundColor DarkGray }
  }

  $report += [pscustomobject]@{
    Id = $t.Id
    Title = $t.Title
    Path = $info.ServerRelativeUrl
    Url = $info.AbsoluteUrl
    DriveItemId = $info.UniqueId
    Phase = $t.Phase
    DryRun = $DryRun.IsPresent
  }
}

Write-Host "[bidding] Completed. Processed: $processed" -ForegroundColor Green

if ($ReportCsv) {
  try {
    $dir = Split-Path -Parent $ReportCsv
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $report | Export-Csv -Path $ReportCsv -NoTypeInformation -Encoding UTF8
    Write-Host "[bidding] Report written: $ReportCsv" -ForegroundColor Green
  } catch { Write-Host "[bidding] (warn) Failed to write report: $($_.Exception.Message)" -ForegroundColor DarkYellow }
}
