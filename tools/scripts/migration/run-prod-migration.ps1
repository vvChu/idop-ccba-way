#requires -Version 7.0
[CmdletBinding()]
param(
    [ValidateSet('Dev','Test','Prod')]
    [string]$Environment = 'Prod',

    [ValidateSet('Cached','Interactive','DeviceLogin','AppOnly')]
    [string]$Auth = 'Cached',

    [switch]$SkipTermstore,
    [switch]$SkipProvision,
    [switch]$SkipMigration,
    [switch]$SkipDiff
)

$ErrorActionPreference = 'Stop'

function New-LogDir {
    $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..' '..')).Path
    $logDir = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'output' | Join-Path -ChildPath 'logs'
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }
    return @{ RepoRoot = $repoRoot; LogDir = $logDir }
}

$paths = New-LogDir
$repoRoot = $paths.RepoRoot
$logDir = $paths.LogDir
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logFile = Join-Path $logDir "prod_migration_${timestamp}.log"

Write-Host "[RUN] Starting Prod migration run at $(Get-Date) → Environment=$Environment, Auth=$Auth" -ForegroundColor Cyan
Write-Host "[RUN] Logs → $logFile" -ForegroundColor DarkCyan

try {
    Start-Transcript -Path $logFile -Append | Out-Null

    $termstoreScript   = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'scripts' | Join-Path -ChildPath 'termstore-import.ps1'
    $provisionScript   = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'scripts' | Join-Path -ChildPath 'apply-sp-lists.ps1'
    $migrateScript     = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'scripts' | Join-Path -ChildPath 'run-mm-migration-sequence.ps1'
    $diffScript        = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'scripts' | Join-Path -ChildPath 'sp-diff.ps1'

    foreach ($f in @($termstoreScript,$provisionScript,$migrateScript,$diffScript)) {
        if (-not (Test-Path -LiteralPath $f)) { throw "Required script not found: $f" }
    }

    # If AppOnly, establish a single connection upfront and let sub-scripts reuse it
    if ($Auth -eq 'AppOnly') {
        $envConfigs = @{
            Dev  = "https://ibstbim.sharepoint.com/sites/idop-dev"
            Test = "https://ibstbim.sharepoint.com/sites/idop-test"
            Prod = "https://ibstbim.sharepoint.com/sites/idop-prod"
        }
        if (-not $envConfigs.ContainsKey($Environment)) { throw "Unknown environment: $Environment" }
        $siteUrl = $envConfigs[$Environment]

        $authModule = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'scripts' | Join-Path -ChildPath 'modules' | Join-Path -ChildPath 'PnPHelpers.psm1'
        if (-not (Test-Path -LiteralPath $authModule)) { throw "Auth helper not found: $authModule" }
        Import-Module $authModule -Force
        Write-Host "[RUN] Establishing AppOnly connection to $siteUrl" -ForegroundColor Yellow
        Connect-IdopOnline -SiteUrl $siteUrl -AuthMode 'AppOnly'
        Write-Host "[RUN] AppOnly connection established" -ForegroundColor Green
    }

    if (-not $SkipTermstore) {
        Write-Host "[STEP 1/4] Import/ensure Term Store (actual)" -ForegroundColor Yellow
        if ($Auth -eq 'AppOnly') { & $termstoreScript -Environment $Environment }
        else { & $termstoreScript -Environment $Environment -Auth $Auth }
        Write-Host "[DONE] Term Store import/ensure completed" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Term Store step skipped by flag" -ForegroundColor DarkYellow
    }

    if (-not $SkipProvision) {
        Write-Host "[STEP 2/4] Provision SharePoint lists and fields (actual)" -ForegroundColor Yellow
        if ($Auth -eq 'AppOnly') { & $provisionScript -Environment $Environment }
        else { & $provisionScript -Environment $Environment -Auth $Auth }
        Write-Host "[DONE] Provisioning completed" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Provisioning step skipped by flag" -ForegroundColor DarkYellow
    }

    if (-not $SkipMigration) {
        Write-Host "[STEP 3/4] Run MM migration and view normalization (actual)" -ForegroundColor Yellow
        if ($Auth -eq 'AppOnly') { & $migrateScript -Environment $Environment }
        else { & $migrateScript -Environment $Environment -Auth $Auth }
        Write-Host "[DONE] Migration sequence completed" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Migration step skipped by flag" -ForegroundColor DarkYellow
    }

    if (-not $SkipDiff) {
        Write-Host "[STEP 4/4] Validate schema parity with sp-diff (post)" -ForegroundColor Yellow
        if ($Auth -eq 'AppOnly') { & $diffScript -Environment $Environment }
        else { & $diffScript -Environment $Environment -Auth $Auth }
        Write-Host "[DONE] Post-diff validation completed" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] Post-diff validation skipped by flag" -ForegroundColor DarkYellow
    }

    Write-Host "[SUCCESS] Prod migration run finished at $(Get-Date)" -ForegroundColor Cyan
    exit 0
}
catch {
    Write-Error "[FAIL] Prod migration run failed: $($_.Exception.Message)"
    exit 1
}
finally {
    try { Stop-Transcript | Out-Null } catch { }
}
