# Script tùy chỉnh form Projects trong SharePoint
# Triển khai: Customize Projects list form với validation và UX cải tiến

param(
    [string]$Environment = "Dev",
    [switch]$DryRun,
    [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

# Configuration
$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$envConfigs = @{
    Dev = "https://ibstbim.sharepoint.com/sites/idop-dev"
    Test = "https://ibstbim.sharepoint.com/sites/idop-test"
    Prod = "https://ibstbim.sharepoint.com/sites/idop-prod"
}

$siteUrl = $envConfigs[$Environment]
$listName = "Projects"

Write-Host "🚀 Customizing Projects form for environment: $Environment" -ForegroundColor Green
Write-Host "🌐 SharePoint Site: $siteUrl" -ForegroundColor Cyan

# Connect to SharePoint
try {
    Write-Host "🔗 Connecting to SharePoint..." -ForegroundColor Cyan
    # Auth helper
    $authModule = Join-Path $PSScriptRoot 'modules/SpAuth.psm1'
    if (Test-Path $authModule) { Import-Module $authModule -Force }
    if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
        Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
    } else {
        Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
    }
    Write-Host "✅ Connected successfully!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Function to customize list form
function Set-ProjectsListForm {
    param([switch]$DryRun)

    Write-Host "📝 Customizing Projects list form..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would customize Projects list form" -ForegroundColor Magenta
        return
    }

    try {
        # Set form customization settings
        Set-PnPList -Identity $listName -EnableVersioning $true
        # Note: Minor versioning not supported for this list type
        # Set-PnPList -Identity $listName -EnableMinorVersions $true

        # Configure list settings
        $list = Get-PnPList -Identity $listName
        $list.EnableAttachments = $true
        $list.Update()

        # Set field properties for better UX
        $fields = Get-PnPField -List $listName

        # Configure ProjectCode field
        $projectCodeField = $fields | Where-Object { $_.InternalName -eq "ProjectCode" }
        if ($projectCodeField) {
            $projectCodeField.Title = "Mã Dự Án"
            $projectCodeField.Description = "Mã định danh duy nhất của dự án (ví dụ: PROJ-2025-001)"
            $projectCodeField.Update()
        }

        # Configure ProjectName field
        $projectNameField = $fields | Where-Object { $_.InternalName -eq "ProjectName" }
        if ($projectNameField) {
            $projectNameField.Title = "Tên Dự Án"
            $projectNameField.Description = "Tên đầy đủ của dự án"
            $projectNameField.Update()
        }

        # Configure Budget field
        $budgetField = $fields | Where-Object { $_.InternalName -eq "Budget" }
        if ($budgetField) {
            $budgetField.Title = "Ngân Sách (VNĐ)"
            $budgetField.Description = "Tổng ngân sách dự án"
            $budgetField.Update()
        }

        # Configure date fields
        $startDateField = $fields | Where-Object { $_.InternalName -eq "StartDate" }
        if ($startDateField) {
            $startDateField.Title = "Ngày Bắt Đầu"
            $startDateField.Update()
        }

        $endDateField = $fields | Where-Object { $_.InternalName -eq "EndDate" }
        if ($endDateField) {
            $endDateField.Title = "Ngày Kết Thúc"
            $endDateField.Update()
        }

        Write-Host "✅ Projects list form customized successfully!" -ForegroundColor Green

        # Display form configuration summary
        Write-Host "`n📋 Form Configuration Summary:" -ForegroundColor Cyan
        Write-Host "- Versioning: Enabled" -ForegroundColor White
        Write-Host "- Attachments: Enabled" -ForegroundColor White
        Write-Host "- Field labels: Vietnamese" -ForegroundColor White
        Write-Host "- Field descriptions: Added" -ForegroundColor White

    }
    catch {
        Write-Host "❌ Failed to customize form: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Function to create sample data for testing
function New-ProjectsSampleData {
    param([switch]$DryRun)

    Write-Host "📊 Creating sample project data..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create sample project data" -ForegroundColor Magenta
        return
    }

    try {
        # Sample project data - using correct field names
        $sampleProjects = @(
            @{
                Title = "SAMPLE-001"
                ProjectCode = "PROJ-2025-001"
                ProjectName = "Dự Án Tư Vấn BIM Tòa Nhà Văn Phòng"
            },
            @{
                Title = "SAMPLE-002"
                ProjectCode = "PROJ-2025-002"
                ProjectName = "Dự Án Thiết Kế BIM Trung Tâm Thương Mại"
            }
        )

        foreach ($project in $sampleProjects) {
            Write-Host "  ➕ Creating project: $($project.ProjectName)" -ForegroundColor White

            # Note: In a real implementation, you would need to handle lookup fields
            # and taxonomy fields properly. This is a simplified example.
            Add-PnPListItem -List $listName -Values $project | Out-Null
        }

        Write-Host "✅ Sample data created successfully!" -ForegroundColor Green

    }
    catch {
        Write-Host "❌ Failed to create sample data: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Main execution
try {
    Set-ProjectsListForm -DryRun:$DryRun
    New-ProjectsSampleData -DryRun:$DryRun

    Write-Host "`n🎉 Projects Module MVP - Form Customization Complete!" -ForegroundColor Green
    Write-Host "📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Test the customized form in SharePoint" -ForegroundColor White
    Write-Host "  2. Configure Power Automate workflows" -ForegroundColor White
    Write-Host "  3. Set up Power BI dashboards" -ForegroundColor White
    Write-Host "  4. Implement role-based permissions" -ForegroundColor White

}
catch {
    Write-Host "❌ Script execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Disconnect from SharePoint
    Disconnect-PnPOnline
}