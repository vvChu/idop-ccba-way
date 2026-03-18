# Script kiểm thử end-to-end Lead Capture workflow
# Triển khai: Test all components của lead capture system

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

Write-Host "🧪 Testing Lead Capture workflow for environment: $Environment" -ForegroundColor Green
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

# Test functions
function Test-LeadsListExists {
    Write-Host "`n📋 Testing Leads list existence..." -ForegroundColor Yellow
    
    try {
        $leadsList = Get-PnPList -Identity "Leads" -ErrorAction Stop
        Write-Host "✅ Leads list exists with ID: $($leadsList.Id)" -ForegroundColor Green
        
        # Check key fields
        $fields = Get-PnPField -List $leadsList
        $requiredFields = @("LeadName", "Email", "Status", "LeadScore", "FollowUpSequenceStage")
        
        foreach ($fieldName in $requiredFields) {
            $field = $fields | Where-Object { $_.InternalName -eq $fieldName }
            if ($field) {
                Write-Host "  ✅ Field '$fieldName' exists" -ForegroundColor White
            } else {
                Write-Host "  ❌ Field '$fieldName' missing" -ForegroundColor Red
                return $false
            }
        }
        return $true
    }
    catch {
        Write-Host "❌ Leads list not found: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-EmailTemplatesLibrary {
    Write-Host "`n📧 Testing Email Templates library..." -ForegroundColor Yellow
    
    try {
        $templatesLib = Get-PnPList -Identity "EmailTemplates" -ErrorAction Stop
        Write-Host "✅ Email Templates library exists" -ForegroundColor Green
        
        # Check template type field
        $fields = Get-PnPField -List $templatesLib
        $templateTypeField = $fields | Where-Object { $_.InternalName -eq "TemplateType" }
        if ($templateTypeField) {
            Write-Host "  ✅ TemplateType field exists" -ForegroundColor White
        } else {
            Write-Host "  ❌ TemplateType field missing" -ForegroundColor Red
            return $false
        }
        return $true
    }
    catch {
        Write-Host "❌ Email Templates library not found: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-LeadActivitiesList {
    Write-Host "`n📊 Testing Lead Activities list..." -ForegroundColor Yellow
    
    try {
        $activitiesList = Get-PnPList -Identity "LeadActivities" -ErrorAction Stop
        Write-Host "✅ Lead Activities list exists" -ForegroundColor Green
        
        # Check key fields
        $fields = Get-PnPField -List $activitiesList
        $requiredFields = @("ActivityType", "ActivityDate", "ActivityDetails")
        
        foreach ($fieldName in $requiredFields) {
            $field = $fields | Where-Object { $_.InternalName -eq $fieldName }
            if ($field) {
                Write-Host "  ✅ Field '$fieldName' exists" -ForegroundColor White
            } else {
                Write-Host "  ❌ Field '$fieldName' missing" -ForegroundColor Red
                return $false
            }
        }
        return $true
    }
    catch {
        Write-Host "❌ Lead Activities list not found: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-TaxonomyIntegration {
    Write-Host "`n🏷️ Testing Taxonomy integration..." -ForegroundColor Yellow
    
    try {
        # Check if Microsoft Forms term exists in CCBA_NguonGocCoHoi
        $termStore = Get-PnPTermStore
        $termGroup = Get-PnPTermGroup -Identity "CCBA Taxonomy"
        $termSet = Get-PnPTermSet -TermGroup $termGroup -Identity "CCBA_NguonGocCoHoi"
        $terms = Get-PnPTerm -TermSet $termSet
        
        $microsoftFormsTerm = $terms | Where-Object { $_.Name -eq "Microsoft Forms" }
        if ($microsoftFormsTerm) {
            Write-Host "✅ 'Microsoft Forms' term exists in CCBA_NguonGocCoHoi" -ForegroundColor Green
        } else {
            Write-Host "❌ 'Microsoft Forms' term not found in taxonomy" -ForegroundColor Red
            return $false
        }
        
        return $true
    }
    catch {
        Write-Host "❌ Taxonomy test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-CreateSampleLead {
    param([switch]$DryRun)
    
    Write-Host "`n👤 Testing sample lead creation..." -ForegroundColor Yellow
    
    if ($DryRun) {
        Write-Host "[DRY RUN] Would create sample lead record" -ForegroundColor Magenta
        return $true
    }
    
    try {
        $leadsList = Get-PnPList -Identity "Leads"
        
        $sampleLead = @{
            LeadName = "Test User $(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Email = "test.user@example.com"
            Phone = "0123456789"
            Company = "Test Company Ltd"
            Position = "Project Manager"
            ProjectDescription = "Test BIM project for residential building"
            Budget = "100-500 triệu VND"
            Timeline = "1-3 tháng tới"
            Status = "New"
            Priority = "Medium"
            LeadScore = 75
            FormSubmissionId = "test-form-$(Get-Date -Format 'yyyyMMddHHmmss')"
            FormResponseDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            FollowUpSequenceStage = "Initial"
            EmailsSent = 0
        }
        
        $newLead = Add-PnPListItem -List $leadsList -Values $sampleLead
        Write-Host "✅ Sample lead created with ID: $($newLead.Id)" -ForegroundColor Green
        
        # Clean up test data
        Write-Host "🧹 Cleaning up test lead..." -ForegroundColor Cyan
        Remove-PnPListItem -List $leadsList -Identity $newLead.Id -Force
        Write-Host "✅ Test lead cleaned up" -ForegroundColor Green
        
        return $true
    }
    catch {
        Write-Host "❌ Sample lead creation failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-CRMIntegration {
    Write-Host "`n🔗 Testing CRM integration..." -ForegroundColor Yellow
    
    try {
        # Check if Customers and Opportunities lists exist for integration
        $customersList = Get-PnPList -Identity "Customers" -ErrorAction SilentlyContinue
        $opportunitiesList = Get-PnPList -Identity "Opportunities" -ErrorAction SilentlyContinue
        
        if ($customersList) {
            Write-Host "✅ Customers list exists for integration" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Customers list not found - conversion may not work" -ForegroundColor Yellow
        }
        
        if ($opportunitiesList) {
            Write-Host "✅ Opportunities list exists for integration" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Opportunities list not found - conversion may not work" -ForegroundColor Yellow
        }
        
        return $true
    }
    catch {
        Write-Host "❌ CRM integration test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-WorkflowFiles {
    Write-Host "`n📄 Testing workflow files..." -ForegroundColor Yellow
    
    $workflowFiles = @(
        "workflows/lead_capture/forms-to-sharepoint-workflow.json"
        "workflows/lead_capture/lead-followup-automation.json"
        "workflows/lead_capture/lead-conversion-workflow.json"
    )
    
    $allFilesExist = $true
    
    foreach ($file in $workflowFiles) {
        $fullPath = Join-Path (Get-Location) $file
        if (Test-Path $fullPath) {
            Write-Host "✅ Workflow file exists: $file" -ForegroundColor Green
        } else {
            Write-Host "❌ Workflow file missing: $file" -ForegroundColor Red
            $allFilesExist = $false
        }
    }
    
    return $allFilesExist
}

# Main test execution
try {
    Write-Host "`n🚀 Starting Lead Capture System Tests" -ForegroundColor Green
    Write-Host "=" * 50 -ForegroundColor Gray
    
    $testResults = @{}
    
    # Run all tests
    $testResults["LeadsList"] = Test-LeadsListExists
    $testResults["EmailTemplates"] = Test-EmailTemplatesLibrary  
    $testResults["LeadActivities"] = Test-LeadActivitiesList
    $testResults["Taxonomy"] = Test-TaxonomyIntegration
    $testResults["SampleLead"] = Test-CreateSampleLead -DryRun:$DryRun
    $testResults["CRMIntegration"] = Test-CRMIntegration
    $testResults["WorkflowFiles"] = Test-WorkflowFiles
    
    # Summary
    Write-Host "`n📋 Test Results Summary" -ForegroundColor Cyan
    Write-Host "=" * 30 -ForegroundColor Gray
    
    $passedTests = 0
    $totalTests = $testResults.Count
    
    foreach ($test in $testResults.GetEnumerator()) {
        $status = if ($test.Value) { "✅ PASS" } else { "❌ FAIL" }
        $color = if ($test.Value) { "Green" } else { "Red" }
        Write-Host "$($test.Key): $status" -ForegroundColor $color
        if ($test.Value) { $passedTests++ }
    }
    
    Write-Host "`nOverall Result: $passedTests/$totalTests tests passed" -ForegroundColor Cyan
    
    if ($passedTests -eq $totalTests) {
        Write-Host "`n🎉 All tests passed! Lead Capture system is ready for deployment." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ Some tests failed. Please fix issues before deployment." -ForegroundColor Yellow
    }
    
    # Next steps
    Write-Host "`n📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Fix any failed tests above" -ForegroundColor White
    Write-Host "  2. Import Power Automate workflows" -ForegroundColor White
    Write-Host "  3. Configure Microsoft Forms with proper field mapping" -ForegroundColor White
    Write-Host "  4. Test end-to-end form submission" -ForegroundColor White
    Write-Host "  5. Train sales team on new lead process" -ForegroundColor White

}
catch {
    Write-Host "❌ Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Disconnect from SharePoint
    Disconnect-PnPOnline
}