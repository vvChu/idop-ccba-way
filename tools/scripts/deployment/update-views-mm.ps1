param(
    [ValidateSet("Dev","Test","Prod")]
    [string]$Environment = "Dev",
    [string[]]$Lists,
    [switch]$HideLegacy,
    [switch]$DryRun,
    [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = "Stop"

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

# Configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Host "[views-mm] Environment: $Environment" -ForegroundColor Cyan
Write-Host "[views-mm] Site: $siteUrl" -ForegroundColor Cyan

# Mapping: list -> pairs of legacy/MM fields to prefer MM in default views
$viewMappings = @{
    Contracts        = @(@{ Legacy = "Status_MM";       MM = "Status" })
    Projects         = @(@{ Legacy = "ServiceType_MM";  MM = "ServiceType" }, @{ Legacy = "Status_MM"; MM = "Status" })
    Activities       = @(@{ Legacy = "Status_MM";       MM = "Status" })
    ProjectIssues    = @(@{ Legacy = "Status_MM";       MM = "Status" })
    ProjectRisks     = @(@{ Legacy = "Status_MM";       MM = "Status" })
    Vendors          = @(@{ Legacy = "ServiceType_MM";  MM = "ServiceType" })
    WorkPackages     = @(@{ Legacy = "Status_MM";       MM = "Status" })
    Assets           = @(@{ Legacy = "Status_MM";       MM = "Status" })
    Employees        = @(@{ Legacy = "Status_MM";       MM = "Status" })
    LessonsLearned   = @(@{ Legacy = "Category_MM";     MM = "Category" })
    Submissions      = @(@{ Legacy = "Status_MM";       MM = "Status" })
    Expenses         = @(@{ Legacy = "ExpenseType_MM";  MM = "ExpenseType" })
}

if ($Lists -and $Lists.Count -gt 0) {
    $filtered = @{}
    foreach ($ln in $Lists) {
        if ($viewMappings.ContainsKey($ln)) { $filtered[$ln] = $viewMappings[$ln] }
    }
    $viewMappings = $filtered
}

function Connect-IdopSite {
    param([string]$Url)
    try {
        Write-Host "[views-mm] 🔗 Connecting..." -ForegroundColor Yellow
        Connect-IdopOnline -SiteUrl $Url -AuthMode $Auth -ClientId $config.ClientId
        Write-Host "[views-mm] ✅ Connected" -ForegroundColor Green
    }
    catch {
        Write-Host "[views-mm] ❌ Connect failed: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Update-DefaultViewFields {
    param(
        [string]$ListName,
        [array]$Pairs,
        [switch]$HideLegacy,
        [switch]$DryRun
    )

    Write-Host "[views-mm] ▶ $ListName" -ForegroundColor White

    try { Get-PnPList -Identity $ListName -ErrorAction Stop | Out-Null }
    catch {
        Write-Host "[views-mm]   ⚠ List not found, skipping." -ForegroundColor DarkYellow
        return
    }

    $defaultView = (Get-PnPView -List $ListName | Where-Object { $_.DefaultView }) | Select-Object -First 1
    if (-not $defaultView) {
        # Fallback to 'All Items'
        $defaultView = Get-PnPView -List $ListName -Identity "All Items" -ErrorAction SilentlyContinue
    }
    if (-not $defaultView) {
        Write-Host "[views-mm]   ⚠ No default view found, skipping." -ForegroundColor DarkYellow
        return
    }

    $originalFields = @($defaultView.ViewFields)
    $newFields = @($originalFields)

    foreach ($pair in $Pairs) {
        $legacy = $pair.Legacy
        $mm     = $pair.MM

        $hasLegacy = $newFields -contains $legacy
        $hasMM     = $newFields -contains $mm

        if ($hasLegacy -and -not $hasMM) {
            # Insert MM near legacy's position
            $idx = [Array]::IndexOf($newFields, $legacy)
            if ($idx -ge 0) {
                $left  = @()
                $right = @()
                if ($idx -gt 0) { $left  = $newFields[0..($idx-1)] }
                if ($idx -lt ($newFields.Count-1)) { $right = $newFields[($idx+1)..($newFields.Count-1)] }
                $newFields = @($left + @($mm) + @($legacy) + $right)
            } else {
                $newFields += $mm
            }
        }

        # Always ensure the MM field is present in the default view
        if (-not $hasMM) {
            $newFields += $mm
        }

        if ($hasLegacy) {
            # Remove legacy from view
            $newFields = $newFields | Where-Object { $_ -ne $legacy }
        }

        if ($HideLegacy) {
            if ($DryRun) {
                Write-Host "[views-mm]   [DRY] Would hide legacy field '$legacy' on forms" -ForegroundColor Magenta
            } else {
                try {
                    Set-PnPField -List $ListName -Identity $legacy -Values @{ ShowInNewForm=$false; ShowInEditForm=$false; ShowInDisplayForm=$false } -ErrorAction SilentlyContinue | Out-Null
                } catch {}
            }
        }
    }

    # Ensure Title or first field remains; dedupe while preserving order
    $seen = @{}
    $newFields = $newFields | Where-Object { if ($seen.ContainsKey($_)) { $false } else { $seen[$_] = $true; $true } }

    if ($DryRun) {
        Write-Host "[views-mm]   [DRY] View fields from: $(($originalFields -join ', '))" -ForegroundColor Magenta
        Write-Host "[views-mm]   [DRY] View fields to:   $(($newFields -join ', '))" -ForegroundColor Magenta
    } else {
        Write-Host "[views-mm]   ✏ Updating default view fields..." -ForegroundColor Yellow
        $viewIdentity = if ($defaultView.Id) { $defaultView.Id } else { $defaultView.Title }
        Set-PnPView -List $ListName -Identity $viewIdentity -Fields $newFields | Out-Null
        Write-Host "[views-mm]   ✅ Updated" -ForegroundColor Green
    }
}

Connect-IdopSite -Url $siteUrl

foreach ($kvp in $viewMappings.GetEnumerator() | Sort-Object Key) {
    Update-DefaultViewFields -ListName $kvp.Key -Pairs $kvp.Value -HideLegacy:$HideLegacy -DryRun:$DryRun
}

Disconnect-PnPOnline
Write-Host "[views-mm] Done." -ForegroundColor Green
