# IDOP Environment Configuration
# Centralized configuration for all environments

@{
    # Common configuration
    Common = @{
        ClientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
        TenantId = "ibstbim.onmicrosoft.com"
        TermStoreGroup = "CCBA"
        DefaultTimeout = 300
    }

    # Development environment
    Dev = @{
        Name = "Development"
        SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-dev"
        SiteAlias = "idop-dev"
        AllowDestructiveOperations = $true
        EnableDryRun = $true
    }

    # Test environment
    Test = @{
        Name = "Test"
        SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-test"
        SiteAlias = "idop-test"
        AllowDestructiveOperations = $true
        EnableDryRun = $true
    }

    # Production environment
    Prod = @{
        Name = "Production"
        SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-prod"
        SiteAlias = "idop-prod"
        AllowDestructiveOperations = $false
        EnableDryRun = $false
        RequireApproval = $true
    }

    # Module paths
    Paths = @{
        DataModelLists = "datamodel/sharepoint/lists"
        DataModelTaxonomy = "datamodel/sharepoint/taxonomy"
        Scripts = "tools/scripts"
        Modules = "tools/scripts/modules"
        Config = "tools/config"
        Logs = ".logs"
        State = "tools/output/state"
    }

    # Modules configuration
    Modules = @{
        strategy_crm = @{
            DisplayName = "Strategy & CRM"
            Description = "CRM, opportunities, leads, customers, contacts"
        }
        process_execution = @{
            DisplayName = "Process Execution"
            Description = "Projects, contracts, activities, work packages, PMO"
        }
        cash_data = @{
            DisplayName = "Cash & Data"
            Description = "Financial plans, expenses, invoices, allocations"
        }
        people_assets = @{
            DisplayName = "People & Assets"
            Description = "HR, employees, assets, timesheets"
        }
        performance_okrs = @{
            DisplayName = "Performance & OKRs"
            Description = "OKRs, KPIs, scorecards, measurables"
        }
        system_governance = @{
            DisplayName = "System Governance"
            Description = "Approvals, workflows, forms, environment variables"
        }
    }
}
