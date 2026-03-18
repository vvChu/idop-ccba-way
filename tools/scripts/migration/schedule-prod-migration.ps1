#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(HelpMessage='Target environment to run')]
    [ValidateSet('Dev','Test','Prod')]
    [string]$Environment = 'Prod',

    [Parameter(HelpMessage='Auth mode passed to inner scripts')]
    [ValidateSet('Cached','Interactive','DeviceLogin','AppOnly')]
    [string]$Auth = 'Cached',

    [Parameter(HelpMessage='Local start time in HH:mm (24h). If omitted, schedules next 02:00.')]
    [string]$StartTime,

    [Parameter(HelpMessage='Task name to register')]
    [string]$TaskName = 'IDOP-CCBA Prod Migration',

    [Parameter(HelpMessage='Run even if user not logged on (requires saved credentials)')]
    [switch]$RunWhetherLoggedOn
)

$ErrorActionPreference = 'Stop'

function Get-RepoRoot { (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..' '..')).Path }
function Test-IsAdmin {
    try {
        $current = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($current)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Get-NextStartDateTime([string]$hhmm) {
    if ([string]::IsNullOrWhiteSpace($hhmm)) { $hhmm = '02:00' }
    if ($hhmm -notmatch '^(\d{2}):(\d{2})$') { throw "Invalid StartTime '$hhmm'. Expected HH:mm (24h)." }
    $now = Get-Date
    $targetToday = [datetime]::ParseExact("$($now.ToString('yyyy-MM-dd')) $hhmm", 'yyyy-MM-dd HH:mm', $null)
    if ($targetToday -le $now) { return $targetToday.AddDays(1) } else { return $targetToday }
}

try {
    $repoRoot = Get-RepoRoot
    $runner = Join-Path $repoRoot 'tools' | Join-Path -ChildPath 'scripts' | Join-Path -ChildPath 'run-prod-migration.ps1'
    if (-not (Test-Path -LiteralPath $runner)) { throw "Runner script not found: $runner" }

    $when = Get-NextStartDateTime $StartTime
    Write-Host "[SCHED] Scheduling at $($when.ToString('yyyy-MM-dd HH:mm')) local → Task: $TaskName" -ForegroundColor Cyan

    # Build action: run pwsh with -File runner and args
    $pwsh = (Get-Command pwsh).Source
    $args = @('-NoLogo','-NoProfile','-ExecutionPolicy','Bypass','-File',"$runner",'-Environment',"$Environment",'-Auth',"$Auth")
    $argStr = $args -join ' '

    $action = New-ScheduledTaskAction -Execute $pwsh -Argument $argStr -WorkingDirectory $repoRoot
    $trigger = New-ScheduledTaskTrigger -Once -At $when
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew

    $isAdmin = Test-IsAdmin
    $runLevel = if ($isAdmin) { 'Highest' } else { 'Limited' }

    try {
        if ($RunWhetherLoggedOn) {
            # Register to run whether user is logged on; will prompt for credentials
            Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -RunLevel $runLevel -User $env:UserName -Password (Read-Host -AsSecureString 'Enter password for scheduled task user') | Out-Null
        } else {
            # Run only when user is logged on (no credentials required)
            Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -RunLevel $runLevel | Out-Null
        }
        Write-Host "[SCHED] Task registered via Scheduled Tasks API (RunLevel=$runLevel)." -ForegroundColor Green
        Write-Host "[SCHED] To list: Get-ScheduledTask -TaskName '$TaskName'" -ForegroundColor DarkCyan
        Write-Host "[SCHED] It will run pwsh with: $argStr" -ForegroundColor DarkCyan
    }
    catch {
        Write-Warning "[SCHED] Register-ScheduledTask failed ('$($_.Exception.Message)'). Falling back to a per-user PowerShell Scheduled Job."

        # Fallback: PowerShell Scheduled Job (per-user, no admin required)
        $triggerJob = New-JobTrigger -Once -At $when
        $sb = [ScriptBlock]::Create("& '$pwsh' -NoLogo -NoProfile -ExecutionPolicy Bypass -File '$runner' -Environment '$Environment' -Auth '$Auth'")
        # Remove existing job if exists
        $existing = Get-ScheduledJob -Name $TaskName -ErrorAction SilentlyContinue
        if ($existing) { Unregister-ScheduledJob -Name $TaskName -Force -ErrorAction SilentlyContinue }
        Register-ScheduledJob -Name $TaskName -ScriptBlock $sb -Trigger $triggerJob -ScheduledJobOption (New-ScheduledJobOption -StartIfOnBatteries -ContinueIfGoingOnBatteries) | Out-Null
        Write-Host "[SCHED] Per-user Scheduled Job registered. To list: Get-ScheduledJob -Name '$TaskName'" -ForegroundColor Green
    }
}
catch {
    Write-Error "[SCHED-FAIL] $_"
    exit 1
}
