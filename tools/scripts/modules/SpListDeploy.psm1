<#
.SYNOPSIS
    SharePoint list and field provisioning functions for IDOP platform
.DESCRIPTION
    Unified module combining field provisioning (from apply-sp-lists.ps1) and
    enhanced list deployment (from the original SpListDeploy.psm1).
    Provides Ensure-* functions for idempotent field creation, diff detection,
    choice syncing, and full list provisioning from JSON definitions.
    Requires an active PnP connection.
#>

#Requires -Modules PnP.PowerShell

# ═══════════════════════════════════════════════════════════════════════
# List provisioning
# ═══════════════════════════════════════════════════════════════════════

function Ensure-IDOPList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [string]$Template = 'GenericList'
    )

    $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if (-not $list) {
        Write-Host "[deploy] Creating list: $Title" -ForegroundColor Yellow
        New-PnPList -Title $Title -Template $Template | Out-Null
        $list = Get-PnPList -Identity $Title
        if ($list) {
            Write-Host "[deploy] Created '$($list.Title)'" -ForegroundColor DarkGray
        }
    }
    return $list
}

function Test-IDOPListExists {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ListName)
    try { return (Get-PnPList -Identity $ListName -ErrorAction SilentlyContinue) -ne $null } catch { return $false }
}

# ═══════════════════════════════════════════════════════════════════════
# Field existence check
# ═══════════════════════════════════════════════════════════════════════

function Test-IDOPFieldExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$FieldName
    )
    $f = Get-PnPField -List $ListName -Identity $FieldName -ErrorAction SilentlyContinue
    return [bool]$f
}

# ═══════════════════════════════════════════════════════════════════════
# Raw XML field add (with verification)
# ═══════════════════════════════════════════════════════════════════════

function Add-IDOPFieldXml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$FieldXml
    )

    Write-Host "[deploy] + Field on ${ListName}: ${FieldXml}" -ForegroundColor Yellow
    Add-PnPFieldFromXml -List $ListName -FieldXml $FieldXml -ErrorAction Stop | Out-Null

    try {
        $intName = if ($FieldXml -match "Name='([^']+)'") { $Matches[1] } else { $null }
        $field = $null
        if ($intName) { $field = Get-PnPField -List $ListName -Identity $intName -ErrorAction SilentlyContinue }
        if (-not $field) {
            $displayName = if ($FieldXml -match "DisplayName='([^']+)'") { $Matches[1] } else { $null }
            if ($displayName) {
                $field = Get-PnPField -List $ListName -ErrorAction SilentlyContinue |
                    Where-Object { $_.Title -eq $displayName } | Select-Object -First 1
            }
        }
        if ($field -and $intName -and $field.InternalName -ne $intName) {
            Write-Host "[deploy] (note) Field created as '$($field.InternalName)' (requested '$intName')" -ForegroundColor DarkYellow
        }
    }
    catch {
        Write-Host "[deploy] (warn) Post-add verification failed: $_" -ForegroundColor DarkYellow
    }
}

# ═══════════════════════════════════════════════════════════════════════
# Typed Ensure-* functions (idempotent field creation)
# ═══════════════════════════════════════════════════════════════════════

function Ensure-IDOPTextField {
    param([Parameter(Mandatory)][string]$ListName, [Parameter(Mandatory)][string]$Name, [string]$InternalName)
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Text | Out-Null
    }
}

function Ensure-IDOPNoteField {
    param([Parameter(Mandatory)][string]$ListName, [Parameter(Mandatory)][string]$Name, [string]$InternalName)
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Note | Out-Null
    }
}

function Ensure-IDOPNumberField {
    param([Parameter(Mandatory)][string]$ListName, [Parameter(Mandatory)][string]$Name, [string]$InternalName)
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Number | Out-Null
    }
}

function Ensure-IDOPDateTimeField {
    param([Parameter(Mandatory)][string]$ListName, [Parameter(Mandatory)][string]$Name, [string]$InternalName)
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type DateTime | Out-Null
    }
}

function Ensure-IDOPUrlField {
    param([Parameter(Mandatory)][string]$ListName, [Parameter(Mandatory)][string]$Name, [string]$InternalName)
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type URL | Out-Null
    }
}

function Ensure-IDOPYesNoField {
    param([Parameter(Mandatory)][string]$ListName, [Parameter(Mandatory)][string]$Name, [string]$InternalName)
    if (-not $InternalName) { $InternalName = $Name }
    $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
    if (-not $existing) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Boolean | Out-Null
    }
    elseif ($existing.TypeAsString -ne 'Boolean') {
        Write-Host "[deploy] Recreating ${ListName}/${Name} as Yes/No (was $($existing.TypeAsString))" -ForegroundColor Yellow
        try { Remove-PnPField -List $ListName -Identity $InternalName -Force } catch {}
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Boolean | Out-Null
    }
}

function Ensure-IDOPUserField {
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$Name,
        [switch]$Multi,
        [string]$SelectionMode = 'PeopleAndGroups',
        [string]$InternalName
    )
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        if (-not $SelectionMode -or [string]::IsNullOrWhiteSpace($SelectionMode)) { $SelectionMode = 'PeopleAndGroups' }
        $t = if ($Multi) { 'UserMulti' } else { 'User' }
        $xml = "<Field Type='${t}' DisplayName='${Name}' Name='${InternalName}' StaticName='${InternalName}' UserSelectionMode='${SelectionMode}' />"
        Add-IDOPFieldXml -ListName $ListName -FieldXml $xml
    }
}

function Ensure-IDOPChoiceField {
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$Name,
        [string[]]$Choices,
        [string]$InternalName
    )
    if (-not $InternalName) { $InternalName = $Name }
    $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
    if (-not $existing) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Choice | Out-Null
    }
    elseif ($existing.TypeAsString -ne 'Choice') {
        Write-Host "[deploy] Recreating ${ListName}/${Name} as Choice (was $($existing.TypeAsString))" -ForegroundColor Yellow
        try { Remove-PnPField -List $ListName -Identity $InternalName -Force } catch {}
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type Choice | Out-Null
    }
    if ($Choices) {
        try { Set-PnPField -List $ListName -Identity $InternalName -Values @{ Choices = $Choices } } catch {
            Write-Host "[deploy] (warn) Failed to update choices on ${ListName}/${Name}: $_" -ForegroundColor DarkYellow
        }
    }
}

function Ensure-IDOPMultiChoiceField {
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$Name,
        [string[]]$Choices,
        [string]$InternalName
    )
    if (-not $InternalName) { $InternalName = $Name }
    $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
    if (-not $existing) {
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type MultiChoice | Out-Null
    }
    elseif ($existing.TypeAsString -ne 'MultiChoice') {
        Write-Host "[deploy] Recreating ${ListName}/${Name} as MultiChoice (was $($existing.TypeAsString))" -ForegroundColor Yellow
        try { Remove-PnPField -List $ListName -Identity $InternalName -Force } catch {}
        Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName -Type MultiChoice | Out-Null
    }
    if ($Choices) {
        try { Set-PnPField -List $ListName -Identity $InternalName -Values @{ Choices = $Choices } } catch {
            Write-Host "[deploy] (warn) Failed to update multichoices on ${ListName}/${Name}: $_" -ForegroundColor DarkYellow
        }
    }
}

function Ensure-IDOPLookupField {
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$TargetList,
        [string]$ShowField = 'ID',
        [string]$InternalName
    )
    if (-not $InternalName) { $InternalName = $Name }
    if (-not (Test-IDOPFieldExists $ListName $InternalName)) {
        $tList = Get-PnPList -Identity $TargetList
        if (-not $tList) { throw "Target lookup list not found: $TargetList" }
        try {
            Add-PnPField -List $ListName -DisplayName $Name -InternalName $InternalName `
                -Type Lookup -LookupList $TargetList -LookupField $ShowField -ErrorAction Stop | Out-Null
        }
        catch {
            $targetId = $tList.Id
            $xml = "<Field Type='Lookup' DisplayName='${Name}' Name='${InternalName}' StaticName='${InternalName}' List='{$targetId}' ShowField='${ShowField}' />"
            Add-IDOPFieldXml -ListName $ListName -FieldXml $xml
        }
    }
}

function Ensure-IDOPTaxonomyField {
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$TermGroup,
        [Parameter(Mandatory)][string]$TermSet,
        [switch]$Multi
    )
    if (-not (Test-IDOPFieldExists $ListName $Name)) {
        $path = "$TermGroup|$TermSet"
        try {
            Add-PnPTaxonomyField -List $ListName -DisplayName $Name -InternalName $Name `
                -TermSetPath $path -MultiValue:$($Multi.IsPresent) | Out-Null
        }
        catch {
            try {
                Add-PnPTaxonomyField -List $ListName -DisplayName $Name -InternalName $Name `
                    -Group $TermGroup -TermSet $TermSet -MultiValue:$($Multi.IsPresent) | Out-Null
            }
            catch {
                Write-Host "[deploy] (warn) Failed to add taxonomy field ${ListName}/${Name}: $_" -ForegroundColor DarkYellow
            }
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════
# Generic field dispatcher (reads column definition from JSON)
# ═══════════════════════════════════════════════════════════════════════

function _SafeGet($obj, $prop) {
    if ($obj -is [System.Collections.IDictionary]) {
        if ($obj.Contains($prop)) { return $obj[$prop] }
    }
    else {
        if ($obj.PSObject.Properties[$prop]) { return $obj.$prop }
    }
    return $null
}

<#
.SYNOPSIS
    Provisions a single field on a SharePoint list based on a column definition object
.PARAMETER ListName
    Target list internal name
.PARAMETER Column
    PSCustomObject or hashtable with Name, Type, InternalName, Choices, Lookup, TermSet, AllowMultiple, UserSelectionMode
.PARAMETER DryRun
    If true, only prints what would happen
#>
function Invoke-IDOPEnsureField {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ListName,
        [Parameter(Mandatory)]$Column,
        [switch]$DryRun
    )

    $name     = _SafeGet $Column 'Name'
    $type     = _SafeGet $Column 'Type'
    $internal = _SafeGet $Column 'InternalName'
    $choices  = _SafeGet $Column 'Choices'
    $lookup   = _SafeGet $Column 'Lookup'
    $termset  = _SafeGet $Column 'TermSet'
    $multi    = [bool](_SafeGet $Column 'AllowMultiple')
    $userMode = (_SafeGet $Column 'UserSelectionMode')
    if (-not $userMode) { $userMode = 'PeopleAndGroups' }

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($type)) { return }

    $it = $type.ToString()

    if ($DryRun) {
        $detail = switch -Regex ($it) {
            '^Lookup$'                    { $tl = _SafeGet $lookup 'List'; "-> $tl" }
            '^(ManagedMetadata|Taxonomy)$' { $g = _SafeGet $termset 'Group'; $n = _SafeGet $termset 'Name'; "-> $g|$n" }
            '^(Choice|MultiChoice)$'      { "($($choices -join ', '))" }
            '^User$'                      { if ($multi) { "(Multi)" } else { "" } }
            default                       { "" }
        }
        Write-Host "  [plan] $it ${ListName}/${name} $detail" -ForegroundColor DarkCyan
        return
    }

    switch -Regex ($it) {
        '^(Text|SingleLine)$'          { Ensure-IDOPTextField       -ListName $ListName -Name $name -InternalName $internal }
        '^Note$'                       { Ensure-IDOPNoteField       -ListName $ListName -Name $name -InternalName $internal }
        '^Number$'                     { Ensure-IDOPNumberField     -ListName $ListName -Name $name -InternalName $internal }
        '^(Date|DateTime)$'            { Ensure-IDOPDateTimeField   -ListName $ListName -Name $name -InternalName $internal }
        '^(URL|Hyperlink)$'            { Ensure-IDOPUrlField        -ListName $ListName -Name $name -InternalName $internal }
        '^(YesNo|Boolean)$'            { Ensure-IDOPYesNoField      -ListName $ListName -Name $name -InternalName $internal }
        '^User$' {
            if ($multi) { Ensure-IDOPUserField -ListName $ListName -Name $name -Multi -SelectionMode $userMode -InternalName $internal }
            else        { Ensure-IDOPUserField -ListName $ListName -Name $name -SelectionMode $userMode -InternalName $internal }
        }
        '^Choice$'      { Ensure-IDOPChoiceField      -ListName $ListName -Name $name -Choices $choices -InternalName $internal }
        '^MultiChoice$' { Ensure-IDOPMultiChoiceField  -ListName $ListName -Name $name -Choices $choices -InternalName $internal }
        '^Lookup$' {
            $tlist  = _SafeGet $lookup 'List'
            $sfield = _SafeGet $lookup 'Field'
            if (-not $sfield) { $sfield = 'ID' }
            if ($tlist) {
                try { Ensure-IDOPLookupField -ListName $ListName -Name $name -TargetList $tlist -ShowField $sfield -InternalName $internal }
                catch { Write-Host "[deploy] (warn) Lookup failed ${ListName}/${name}: $_" -ForegroundColor DarkYellow }
            }
        }
        '^(ManagedMetadata|Taxonomy)$' {
            $grp = _SafeGet $termset 'Group'
            $ts  = _SafeGet $termset 'Name'
            if ($grp -and $ts) {
                Ensure-IDOPTaxonomyField -ListName $ListName -Name $name -TermGroup $grp -TermSet $ts -Multi:$multi
            }
        }
        '^Currency$' {
            if (-not $internal) { $internal = $name }
            if (-not (Test-IDOPFieldExists $ListName $internal)) {
                Add-PnPField -List $ListName -DisplayName $name -InternalName $internal -Type Currency | Out-Null
            }
        }
        default { Write-Host "[deploy] (info) Unsupported type '$it' for ${ListName}/${name}; skipping." -ForegroundColor DarkGray }
    }
}

# ═══════════════════════════════════════════════════════════════════════
# Full list provisioning from JSON definition
# ═══════════════════════════════════════════════════════════════════════

<#
.SYNOPSIS
    Provisions a complete SharePoint list from a JSON definition file
.PARAMETER JsonPath
    Path to the list JSON definition
.PARAMETER DryRun
    Preview only
.PARAMETER UpdateExisting
    Update fields on existing lists
#>
function Deploy-IDOPListFromJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$JsonPath,
        [switch]$DryRun,
        [switch]$UpdateExisting
    )

    try {
        $listDef = Get-Content $JsonPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "[deploy] (error) Invalid JSON: $JsonPath — $_" -ForegroundColor Red
        return @{ Success = $false }
    }

    $listName = _SafeGet $listDef 'ListName'
    if (-not $listName) { return @{ Success = $false } }

    if ($DryRun) {
        Write-Host "  [plan] Would ensure list: $listName" -ForegroundColor DarkCyan
    }
    else {
        $existing = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
        if (-not $existing) {
            Ensure-IDOPList -Title $listName | Out-Null
        }
        elseif (-not $UpdateExisting) {
            Write-Host "  [deploy] List '$listName' exists. Use -UpdateExisting to update fields." -ForegroundColor Gray
        }
    }

    # Process columns
    $cols = @()
    $colsProp = _SafeGet $listDef 'Columns'
    if ($null -ne $colsProp -and $colsProp -is [System.Collections.IEnumerable] -and -not ($colsProp -is [string])) {
        $cols = @($colsProp)
    }

    $fieldOk = 0; $fieldFail = 0
    foreach ($col in $cols) {
        $colName = _SafeGet $col 'Name'
        if ($colName -eq 'Title') { continue }

        try {
            Invoke-IDOPEnsureField -ListName $listName -Column $col -DryRun:$DryRun
            $fieldOk++
        }
        catch {
            Write-Host "[deploy] (warn) Field failed ${listName}/${colName}: $_" -ForegroundColor DarkYellow
            $fieldFail++
        }
    }

    return @{
        Success      = $true
        ListName     = $listName
        FieldsOk     = $fieldOk
        FieldsFailed = $fieldFail
    }
}

# ═══════════════════════════════════════════════════════════════════════
# Display name updater
# ═══════════════════════════════════════════════════════════════════════

function Update-IDOPDisplayNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ListsPath,
        [hashtable]$OnlySet
    )

    $jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
    foreach ($jf in $jsonFiles) {
        try { $obj = Get-Content -Raw -Path $jf.FullName | ConvertFrom-Json } catch { continue }

        $ln = _SafeGet $obj 'ListName'
        if (-not $ln) { continue }
        if ($OnlySet -and -not $OnlySet.ContainsKey($ln)) { continue }

        $list = Get-PnPList -Identity $ln -ErrorAction SilentlyContinue
        if (-not $list) { continue }

        $cols = @()
        $colsProp = _SafeGet $obj 'Columns'
        if ($null -ne $colsProp -and $colsProp -is [System.Collections.IEnumerable] -and -not ($colsProp -is [string])) {
            $cols = @($colsProp)
        }

        foreach ($col in $cols) {
            $dn = _SafeGet $col 'DisplayName'
            $internal = _SafeGet $col 'Name'
            if ([string]::IsNullOrWhiteSpace($dn) -or [string]::IsNullOrWhiteSpace($internal)) { continue }

            try {
                Set-PnPField -List $ln -Identity $internal -Values @{ Title = $dn } | Out-Null
                Write-Host "[deploy] Display name ${ln}/${internal} -> '${dn}'" -ForegroundColor DarkGreen
            }
            catch {
                Write-Host "[deploy] (warn) Display name failed ${ln}/${internal}: $_" -ForegroundColor DarkYellow
            }
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════
# Exports
# ═══════════════════════════════════════════════════════════════════════

Export-ModuleMember -Function @(
    # List operations
    'Ensure-IDOPList',
    'Test-IDOPListExists',
    'Deploy-IDOPListFromJson',
    # Field checks
    'Test-IDOPFieldExists',
    'Add-IDOPFieldXml',
    # Typed field provisioning
    'Ensure-IDOPTextField',
    'Ensure-IDOPNoteField',
    'Ensure-IDOPNumberField',
    'Ensure-IDOPDateTimeField',
    'Ensure-IDOPUrlField',
    'Ensure-IDOPYesNoField',
    'Ensure-IDOPUserField',
    'Ensure-IDOPChoiceField',
    'Ensure-IDOPMultiChoiceField',
    'Ensure-IDOPLookupField',
    'Ensure-IDOPTaxonomyField',
    # Generic dispatcher
    'Invoke-IDOPEnsureField',
    # Display names
    'Update-IDOPDisplayNames'
)
