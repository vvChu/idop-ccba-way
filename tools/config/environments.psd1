# IDOP Environment Configuration
# Centralized configuration for all environments

@{
    # Common configuration
    # App Registration: IDOP-SPO-Deploy (Certificate-based AppOnly)
    # Interactive fallback ClientId: 90ded6f0-b787-4b3c-acea-8baf6403fd63
    Common = @{
        ClientId = "c055c7a4-9150-4bd5-bf01-445c65467feb"
        TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
        TenantDomain = "ibstbim.onmicrosoft.com"
        TermStoreGroup = "CCBA"
        DefaultTimeout = 300
        InteractiveClientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
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

    # IDOP CCBA Environment Architecture (Root Portal + Operations Engine + CDE)
    IDOP = @{
        Name = "IDOP CCBA Operational Architecture"
        PortalSiteUrl = "https://ibstbim.sharepoint.com/"
        SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop"
        CdeSiteUrl = "https://ibstbim.sharepoint.com/sites/iCDE"
        BiddingStorageUrl = "https://ibstbim-my.sharepoint.com/:f:/g/personal/ccba_ibst-bim_vn/IgAtDFNJbUThRLib9LDlUVSvAdqbX7255GPQj4dIjHGnrzE?e=ccDiFK"
        SiteAlias = "idop"
        AllowDestructiveOperations = $true
        EnableDryRun = $false
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
