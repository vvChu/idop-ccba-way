<#
.SYNOPSIS
    Validation helper functions for IDOP platform
.DESCRIPTION
    Provides validation functions for SharePoint schemas, naming conventions,
    JSON validation, and data integrity checks.
#>

<#
.SYNOPSIS
    Validates SharePoint list JSON schema
.PARAMETER JsonPath
    Path to JSON file
#>
function Test-IDOPListSchema {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonPath
    )

    if (-not (Test-Path $JsonPath)) {
        throw "JSON file not found: $JsonPath"
    }

    try {
        $json = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json
    }
    catch {
        return @{
            Valid = $false
            Errors = @("Invalid JSON format: $_")
            File = $JsonPath
        }
    }

    $errors = @()

    # Required properties
    $requiredProps = @('ListName', 'Columns')

    foreach ($prop in $requiredProps) {
        if (-not $json.PSObject.Properties.Name.Contains($prop)) {
            $errors += "Missing required property: $prop"
        }
    }

    # Validate ListName format (PascalCase)
    if ($json.ListName -and $json.ListName -notmatch '^[A-Z][a-zA-Z0-9]*$') {
        $errors += "ListName must be PascalCase: $($json.ListName)"
    }

    # Validate Columns array
    if ($json.Columns) {
        foreach ($field in $json.Columns) {
            $fieldName = if ($field.Name) { $field.Name } else { $field.InternalName }
            if (-not $fieldName) {
                $errors += "Column missing Name"
            }

            if (-not $field.Type) {
                $errors += "Column '$fieldName' missing Type"
            }

            # Validate column Name format (PascalCase)
            if ($fieldName -and $fieldName -notmatch '^[A-Z][a-zA-Z0-9]*$') {
                $errors += "Column Name must be PascalCase: $fieldName"
            }
        }
    }

    return @{
        Valid = ($errors.Count -eq 0)
        Errors = $errors
        File = $JsonPath
    }
}

<#
.SYNOPSIS
    Validates SharePoint field naming conventions
.PARAMETER FieldName
    Field internal name to validate
.PARAMETER DisplayName
    Field display name to validate
#>
function Test-IDOPFieldNaming {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FieldName,

        [Parameter(Mandatory = $false)]
        [string]$DisplayName
    )

    $issues = @()

    # InternalName should be PascalCase
    if ($FieldName -notmatch '^[A-Z][a-zA-Z0-9]*$') {
        $issues += "InternalName should be PascalCase (e.g., ProjectCode): $FieldName"
    }

    # Check for reserved SharePoint field names
    $reservedNames = @(
        'ID', 'Title', 'Created', 'Modified', 'Author', 'Editor',
        'ContentType', 'Attachments', 'FileLeafRef', 'FileDirRef'
    )

    if ($FieldName -in $reservedNames) {
        $issues += "InternalName conflicts with reserved SharePoint field: $FieldName"
    }

    # DisplayName validation
    if ($DisplayName) {
        if ($DisplayName.Length -gt 50) {
            $issues += "DisplayName too long (max 50 chars): $DisplayName"
        }
    }

    return @{
        Valid = ($issues.Count -eq 0)
        Issues = $issues
        FieldName = $FieldName
    }
}

<#
.SYNOPSIS
    Validates list naming conventions
.PARAMETER InternalName
    List internal name
.PARAMETER DisplayName
    List display name
#>
function Test-IDOPListNaming {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InternalName,

        [Parameter(Mandatory = $false)]
        [string]$DisplayName
    )

    $issues = @()

    # InternalName should be lowercase with underscores
    if ($InternalName -notmatch '^[a-z_]+$') {
        $issues += "List InternalName should be lowercase with underscores (e.g., expense_checklists): $InternalName"
    }

    # Check for SQL reserved words
    $sqlReserved = @(
        'select', 'insert', 'update', 'delete', 'from', 'where',
        'table', 'index', 'view', 'user', 'order', 'group'
    )

    if ($InternalName -in $sqlReserved) {
        $issues += "List InternalName conflicts with SQL reserved word: $InternalName"
    }

    return @{
        Valid = ($issues.Count -eq 0)
        Issues = $issues
        ListName = $InternalName
    }
}

<#
.SYNOPSIS
    Validates JSON file structure
.PARAMETER JsonPath
    Path to JSON file
.PARAMETER SchemaPath
    Optional JSON schema path for validation
#>
function Test-IDOPJsonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonPath,

        [Parameter(Mandatory = $false)]
        [string]$SchemaPath
    )

    if (-not (Test-Path $JsonPath)) {
        return @{
            Valid = $false
            Error = "File not found: $JsonPath"
        }
    }

    try {
        $content = Get-Content -Path $JsonPath -Raw
        $json = $content | ConvertFrom-Json

        # Basic syntax validation passed
        $result = @{
            Valid = $true
            FilePath = $JsonPath
            Size = (Get-Item $JsonPath).Length
        }

        # If schema provided, validate against it
        if ($SchemaPath -and (Test-Path $SchemaPath)) {
            # TODO: Implement JSON schema validation
            # This would require a JSON schema validation library
        }

        return $result
    }
    catch {
        return @{
            Valid = $false
            Error = "JSON parsing error: $_"
            FilePath = $JsonPath
        }
    }
}

<#
.SYNOPSIS
    Validates taxonomy term set JSON
.PARAMETER JsonPath
    Path to taxonomy JSON file
#>
function Test-IDOPTaxonomyJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonPath
    )

    try {
        $json = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json
    }
    catch {
        return @{
            Valid = $false
            Errors = @("Invalid JSON format: $_")
        }
    }

    $errors = @()

    # Required properties for taxonomy
    if (-not $json.TermSetInfo) {
        $errors += "Missing required property: TermSetInfo"
    } else {
        if (-not $json.TermSetInfo.Name) {
            $errors += "TermSetInfo missing Name property"
        }
        if (-not $json.TermSetInfo.Id) {
            $errors += "TermSetInfo missing Id property"
        } else {
            try {
                [System.Guid]::Parse($json.TermSetInfo.Id) | Out-Null
            }
            catch {
                $errors += "Invalid GUID format for TermSetInfo Id: $($json.TermSetInfo.Id)"
            }
        }
    }

    if (-not $json.PSObject.Properties.Name.Contains('Terms')) {
        $errors += "Missing required property: Terms"
    }

    # Validate Terms structure
    if ($json.Terms) {
        foreach ($term in $json.Terms) {
            if (-not $term.Name) {
                $errors += "Term missing Name property"
            }

            if ($term.Id) {
                try {
                    [System.Guid]::Parse($term.Id) | Out-Null
                }
                catch {
                    $errors += "Invalid GUID format for Term Id: $($term.Id)"
                }
            }
        }
    }

    return @{
        Valid = ($errors.Count -eq 0)
        Errors = $errors
        File = $JsonPath
    }
}

<#
.SYNOPSIS
    Validates lookup field references
.PARAMETER ListsPath
    Path to lists directory
#>
function Test-IDOPLookupReferences {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListsPath
    )

    $issues = @()
    $listFiles = Get-ChildItem -Path $ListsPath -Filter "*.json" -Recurse

    $allLists = @{}
    foreach ($file in $listFiles) {
        $json = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        $listKey = if ($json.ListName) { $json.ListName } else { $json.InternalName }
        if ($listKey) {
            $allLists[$listKey] = $json
        }
    }

    # Check lookup field references
    foreach ($listName in $allLists.Keys) {
        $list = $allLists[$listName]

        foreach ($field in $list.Fields) {
            if ($field.Type -eq 'Lookup' -or $field.Type -eq 'LookupMulti') {
                $lookupList = $field.LookupList

                if ($lookupList -and -not $allLists.ContainsKey($lookupList)) {
                    $issues += @{
                        List = $listName
                        Field = $field.InternalName
                        Issue = "References non-existent list: $lookupList"
                    }
                }
            }
        }
    }

    return @{
        Valid = ($issues.Count -eq 0)
        Issues = $issues
        TotalListsChecked = $allLists.Count
    }
}

<#
.SYNOPSIS
    Validates all datamodel JSON files
.PARAMETER DataModelPath
    Path to datamodel directory
#>
function Test-IDOPDataModel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DataModelPath
    )

    $results = @{
        ListsChecked = 0
        ListsValid = 0
        TaxonomyChecked = 0
        TaxonomyValid = 0
        Errors = @()
    }

    # Validate list schemas
    $listFiles = Get-ChildItem -Path "$DataModelPath/lists" -Filter "*.json" -Recurse -ErrorAction SilentlyContinue

    foreach ($file in $listFiles) {
        $results.ListsChecked++
        $validation = Test-IDOPListSchema -JsonPath $file.FullName

        if ($validation.Valid) {
            $results.ListsValid++
        }
        else {
            $results.Errors += @{
                File = $file.Name
                Type = "List Schema"
                Errors = $validation.Errors
            }
        }
    }

    # Validate taxonomy
    $taxonomyFiles = Get-ChildItem -Path "$DataModelPath/taxonomy" -Filter "*.json" -ErrorAction SilentlyContinue

    foreach ($file in $taxonomyFiles) {
        $results.TaxonomyChecked++
        $validation = Test-IDOPTaxonomyJson -JsonPath $file.FullName

        if ($validation.Valid) {
            $results.TaxonomyValid++
        }
        else {
            $results.Errors += @{
                File = $file.Name
                Type = "Taxonomy"
                Errors = $validation.Errors
            }
        }
    }

    return $results
}

# Export module members
Export-ModuleMember -Function @(
    'Test-IDOPListSchema',
    'Test-IDOPFieldNaming',
    'Test-IDOPListNaming',
    'Test-IDOPJsonFile',
    'Test-IDOPTaxonomyJson',
    'Test-IDOPLookupReferences',
    'Test-IDOPDataModel'
)
