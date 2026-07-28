<#
.SYNOPSIS
    Logging and output helpers for IDOP platform
.DESCRIPTION
    Provides consistent logging, formatting, and output functions across all IDOP scripts.
#>

# Color scheme
$script:Colors = @{
    Success = 'Green'
    Info    = 'Cyan'
    Warning = 'Yellow'
    Error   = 'Red'
    Muted   = 'Gray'
    Accent  = 'Magenta'
}

<#
.SYNOPSIS
    Writes a formatted success message
#>
function Write-IDOPSuccess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [switch]$NoNewline
    )

    Write-Host "✓ $Message" -ForegroundColor $script:Colors.Success -NoNewline:$NoNewline
}

<#
.SYNOPSIS
    Writes a formatted info message
#>
function Write-IDOPInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [switch]$NoNewline
    )

    Write-Host "ℹ $Message" -ForegroundColor $script:Colors.Info -NoNewline:$NoNewline
}

<#
.SYNOPSIS
    Writes a formatted warning message
#>
function Write-IDOPWarning {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )

    Write-Host "⚠ $Message" -ForegroundColor $script:Colors.Warning
}

<#
.SYNOPSIS
    Writes a formatted error message
#>
function Write-IDOPError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message
    )

    Write-Host "✗ $Message" -ForegroundColor $script:Colors.Error
}

<#
.SYNOPSIS
    Writes a section header
#>
function Write-IDOPHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [char]$Char = '='
    )

    $line = [string]$Char * $Title.Length
    Write-Host ""
    Write-Host $Title -ForegroundColor $script:Colors.Accent
    Write-Host $line -ForegroundColor $script:Colors.Muted
}

<#
.SYNOPSIS
    Writes a progress indicator
#>
function Write-IDOPProgress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Activity,

        [Parameter(Mandatory = $true)]
        [int]$Current,

        [Parameter(Mandatory = $true)]
        [int]$Total,

        [Parameter(Mandatory = $false)]
        [string]$Status = ""
    )

    $percentComplete = [int](($Current / $Total) * 100)

    Write-Progress `
        -Activity $Activity `
        -Status $Status `
        -PercentComplete $percentComplete `
        -CurrentOperation "Processing $Current of $Total"
}

<#
.SYNOPSIS
    Formats a table with colored output
#>
function Write-IDOPTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]]$Data,

        [Parameter(Mandatory = $false)]
        [string[]]$Properties
    )

    begin {
        $items = @()
    }

    process {
        $items += $Data
    }

    end {
        if ($items.Count -eq 0) {
            Write-IDOPWarning "No data to display"
            return
        }

        if ($Properties) {
            $items | Format-Table -Property $Properties -AutoSize
        }
        else {
            $items | Format-Table -AutoSize
        }
    }
}

<#
.SYNOPSIS
    Starts a timer for performance tracking
#>
function Start-IDOPTimer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Name = "Operation"
    )

    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    return @{
        Name = $Name
        Stopwatch = $timer
        StartTime = Get-Date
    }
}

<#
.SYNOPSIS
    Stops a timer and displays elapsed time
#>
function Stop-IDOPTimer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Timer
    )

    $Timer.Stopwatch.Stop()
    $elapsed = $Timer.Stopwatch.Elapsed

    $formattedTime = if ($elapsed.TotalSeconds -lt 60) {
        "{0:N2} seconds" -f $elapsed.TotalSeconds
    }
    elseif ($elapsed.TotalMinutes -lt 60) {
        "{0:N2} minutes" -f $elapsed.TotalMinutes
    }
    else {
        "{0:N2} hours" -f $elapsed.TotalHours
    }

    Write-Host ""
    Write-IDOPSuccess "$($Timer.Name) completed in $formattedTime"

    return $elapsed
}

<#
.SYNOPSIS
    Creates a summary report
#>
function Write-IDOPSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Stats,

        [Parameter(Mandatory = $false)]
        [string]$Title = "Summary"
    )

    Write-Host ""
    Write-IDOPHeader -Title $Title -Char '-'

    foreach ($key in $Stats.Keys | Sort-Object) {
        $value = $Stats[$key]
        $label = $key.PadRight(25)
        Write-Host "  $label : " -NoNewline -ForegroundColor $script:Colors.Muted
        Write-Host $value -ForegroundColor $script:Colors.Info
    }

    Write-Host ""
}

<#
.SYNOPSIS
    Prompts user for confirmation
#>
function Confirm-IDOPAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [switch]$DefaultYes
    )

    $prompt = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }

    Write-Host "$Message $prompt " -ForegroundColor $script:Colors.Warning -NoNewline
    $response = Read-Host

    if ([string]::IsNullOrWhiteSpace($response)) {
        return $DefaultYes
    }

    return $response -match '^[Yy]'
}

<#
.SYNOPSIS
    Logs to file and console
#>
function Write-IDOPLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info',

        [Parameter(Mandatory = $false)]
        [string]$LogFile
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    # Console output
    switch ($Level) {
        'Success' { Write-IDOPSuccess $Message }
        'Info'    { Write-IDOPInfo $Message }
        'Warning' { Write-IDOPWarning $Message }
        'Error'   { Write-IDOPError $Message }
    }

    # File output
    if ($LogFile) {
        $logDir = Split-Path -Parent $LogFile
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        Add-Content -Path $LogFile -Value $logEntry
    }
}

# Export module members
Export-ModuleMember -Function @(
    'Write-IDOPSuccess',
    'Write-IDOPInfo',
    'Write-IDOPWarning',
    'Write-IDOPError',
    'Write-IDOPHeader',
    'Write-IDOPProgress',
    'Write-IDOPTable',
    'Start-IDOPTimer',
    'Stop-IDOPTimer',
    'Write-IDOPSummary',
    'Confirm-IDOPAction',
    'Write-IDOPLog'
)
