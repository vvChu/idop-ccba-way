#Requires -Modules Pester

<#
.SYNOPSIS
    Pester tests for IDOP shared PowerShell modules
.DESCRIPTION
    Tests ValidationHelpers, LoggingHelpers, and PnPHelpers (non-PnP functions).
    Run: Invoke-Pester -Path tools/scripts/testing/modules.Tests.ps1
#>

BeforeAll {
    $ModulePath = Join-Path $PSScriptRoot "../modules"
    Import-Module "$ModulePath/ValidationHelpers.psm1" -Force
    Import-Module "$ModulePath/LoggingHelpers.psm1" -Force
    Import-Module "$ModulePath/PnPHelpers.psm1" -Force

    # Test fixtures
    $script:FixturesPath = Join-Path $PSScriptRoot "fixtures"
    if (-not (Test-Path $script:FixturesPath)) {
        New-Item -ItemType Directory -Path $script:FixturesPath -Force | Out-Null
    }

    # Create valid list JSON fixture
    $validList = @{
        ListName = "TestList"
        Description = "Test list"
        Columns = @(
            @{ Name = "ProjectCode"; Type = "Text"; Required = $true }
            @{ Name = "Status"; Type = "Choice"; Choices = @("Active", "Closed") }
        )
    }
    $validList | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $script:FixturesPath "valid-list.json") -Encoding UTF8

    # Create invalid list JSON fixture (missing ListName)
    $invalidList = @{
        Description = "Missing ListName"
        Columns = @(
            @{ Name = "Field1"; Type = "Text" }
        )
    }
    $invalidList | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $script:FixturesPath "invalid-list.json") -Encoding UTF8

    # Create malformed JSON fixture
    Set-Content (Join-Path $script:FixturesPath "malformed.json") -Value "{ not valid json }" -Encoding UTF8

    # Create valid taxonomy JSON fixture
    $validTaxonomy = @{
        Name = "CCBA_TestTermSet"
        Id = "12345678-1234-1234-1234-123456789abc"
        Terms = @(
            @{ Name = "Term1"; Id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" }
        )
    }
    $validTaxonomy | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $script:FixturesPath "valid-taxonomy.json") -Encoding UTF8

    # Create invalid taxonomy JSON fixture (bad GUID)
    $invalidTaxonomy = @{
        Name = "CCBA_BadTermSet"
        Id = "not-a-guid"
        Terms = @(
            @{ Name = "Term1"; Id = "also-not-a-guid" }
        )
    }
    $invalidTaxonomy | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $script:FixturesPath "invalid-taxonomy.json") -Encoding UTF8
}

AfterAll {
    # Cleanup fixtures
    if (Test-Path $script:FixturesPath) {
        Remove-Item -Path $script:FixturesPath -Recurse -Force
    }
}

# ═══════════════════════════════════════════════════════════════════════
# ValidationHelpers Tests
# ═══════════════════════════════════════════════════════════════════════

Describe "Test-IDOPJsonFile" {
    It "validates a well-formed JSON file" {
        $result = Test-IDOPJsonFile -JsonPath (Join-Path $script:FixturesPath "valid-list.json")
        $result.Valid | Should -Be $true
    }

    It "rejects malformed JSON" {
        $result = Test-IDOPJsonFile -JsonPath (Join-Path $script:FixturesPath "malformed.json")
        $result.Valid | Should -Be $false
        $result.Error | Should -Match "JSON parsing error"
    }

    It "rejects non-existent file" {
        $result = Test-IDOPJsonFile -JsonPath "nonexistent.json"
        $result.Valid | Should -Be $false
        $result.Error | Should -Match "File not found"
    }
}

Describe "Test-IDOPListSchema" {
    It "validates a correct list definition" {
        $result = Test-IDOPListSchema -JsonPath (Join-Path $script:FixturesPath "valid-list.json")
        $result.Valid | Should -Be $true
        $result.Errors.Count | Should -Be 0
    }

    It "rejects a list definition missing ListName" {
        $result = Test-IDOPListSchema -JsonPath (Join-Path $script:FixturesPath "invalid-list.json")
        # The schema check looks for 'Title' and 'InternalName' not 'ListName',
        # so it should find missing required properties
        $result.Valid | Should -Be $false
    }

    It "rejects malformed JSON" {
        $result = Test-IDOPListSchema -JsonPath (Join-Path $script:FixturesPath "malformed.json")
        $result.Valid | Should -Be $false
        $result.Errors | Should -Contain "Invalid JSON format*"
    }
}

Describe "Test-IDOPFieldNaming" {
    It "accepts PascalCase field names" {
        $result = Test-IDOPFieldNaming -FieldName "ProjectCode"
        $result.Valid | Should -Be $true
    }

    It "accepts single-word PascalCase" {
        $result = Test-IDOPFieldNaming -FieldName "Status"
        $result.Valid | Should -Be $true
    }

    It "rejects lowercase field names" {
        $result = Test-IDOPFieldNaming -FieldName "projectcode"
        $result.Valid | Should -Be $false
    }

    It "rejects snake_case field names" {
        $result = Test-IDOPFieldNaming -FieldName "project_code"
        $result.Valid | Should -Be $false
    }

    It "warns about reserved SharePoint field names" {
        $result = Test-IDOPFieldNaming -FieldName "Title"
        $result.Valid | Should -Be $false
        $result.Issues | Should -Contain "*reserved*"
    }
}

Describe "Test-IDOPListNaming" {
    It "accepts lowercase_underscore list names" {
        $result = Test-IDOPListNaming -InternalName "expense_checklists"
        $result.Valid | Should -Be $true
    }

    It "accepts single-word lowercase" {
        $result = Test-IDOPListNaming -InternalName "projects"
        $result.Valid | Should -Be $true
    }

    It "rejects PascalCase list names" {
        $result = Test-IDOPListNaming -InternalName "ExpenseChecklists"
        $result.Valid | Should -Be $false
    }

    It "rejects names with hyphens" {
        $result = Test-IDOPListNaming -InternalName "expense-checklists"
        $result.Valid | Should -Be $false
    }
}

Describe "Test-IDOPTaxonomyJson" {
    It "validates correct taxonomy JSON" {
        $result = Test-IDOPTaxonomyJson -JsonPath (Join-Path $script:FixturesPath "valid-taxonomy.json")
        $result.Valid | Should -Be $true
    }

    It "rejects taxonomy with invalid GUIDs" {
        $result = Test-IDOPTaxonomyJson -JsonPath (Join-Path $script:FixturesPath "invalid-taxonomy.json")
        $result.Valid | Should -Be $false
        $result.Errors.Count | Should -BeGreaterThan 0
    }
}

# ═══════════════════════════════════════════════════════════════════════
# LoggingHelpers Tests
# ═══════════════════════════════════════════════════════════════════════

Describe "Start-IDOPTimer / Stop-IDOPTimer" {
    It "creates a timer with correct name" {
        $timer = Start-IDOPTimer -Name "TestOp"
        $timer.Name | Should -Be "TestOp"
        $timer.Stopwatch | Should -Not -BeNullOrEmpty
        $timer.StartTime | Should -Not -BeNullOrEmpty
    }

    It "stops timer and returns elapsed time" {
        $timer = Start-IDOPTimer -Name "QuickOp"
        Start-Sleep -Milliseconds 50
        $elapsed = Stop-IDOPTimer -Timer $timer
        $elapsed.TotalMilliseconds | Should -BeGreaterThan 40
    }
}

# ═══════════════════════════════════════════════════════════════════════
# PnPHelpers Tests (non-connection functions only)
# ═══════════════════════════════════════════════════════════════════════

Describe "Get-IDOPConfig" {
    It "loads Dev configuration" {
        $config = Get-IDOPConfig -Environment Dev
        $config.Environment | Should -Be "Dev"
        $config.SharePointUrl | Should -Match "idop-dev"
        $config.ClientId | Should -Not -BeNullOrEmpty
    }

    It "loads Prod configuration" {
        $config = Get-IDOPConfig -Environment Prod
        $config.Environment | Should -Be "Prod"
        $config.SharePointUrl | Should -Match "idop-prod"
    }

    It "returns consistent ClientId across environments" {
        $dev = Get-IDOPConfig -Environment Dev
        $prod = Get-IDOPConfig -Environment Prod
        $dev.ClientId | Should -Be $prod.ClientId
    }

    It "includes Paths configuration" {
        $config = Get-IDOPConfig -Environment Dev
        $config.Paths | Should -Not -BeNullOrEmpty
        $config.Paths.DataModelLists | Should -Be "datamodel/sharepoint/lists"
    }
}
