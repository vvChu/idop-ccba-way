# Script triển khai Lead Capture module
# Triển khai: Leads list, Email Templates library, và Lead Activities tracking

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

Write-Host "🚀 Deploying Lead Capture module for environment: $Environment" -ForegroundColor Green
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

# Function to deploy Leads list
function Deploy-LeadsList {
    param([switch]$DryRun)

    Write-Host "📋 Deploying Leads list..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create Leads list with lead capture fields" -ForegroundColor Magenta
        return
    }

    try {
        # Check if Leads list exists
        $leadsList = Get-PnPList -Identity "Leads" -ErrorAction SilentlyContinue
        
        if (-not $leadsList) {
            Write-Host "Creating Leads list..." -ForegroundColor Cyan
            $leadsList = New-PnPList -Title "Leads" -Template GenericList -Description "Khách hàng tiềm năng từ Microsoft Forms và các nguồn khác"
        }

        # Add custom fields for lead capture
        $fields = @(
            @{ Name = "LeadName"; Type = "Text"; DisplayName = "Tên Lead"; Required = $true }
            @{ Name = "Email"; Type = "Text"; DisplayName = "Email"; Required = $true }
            @{ Name = "Phone"; Type = "Text"; DisplayName = "Điện thoại" }
            @{ Name = "Company"; Type = "Text"; DisplayName = "Công ty" }
            @{ Name = "Position"; Type = "Text"; DisplayName = "Chức vụ" }
            @{ Name = "ProjectDescription"; Type = "Note"; DisplayName = "Mô tả dự án" }
            @{ Name = "Budget"; Type = "Text"; DisplayName = "Ngân sách dự kiến" }
            @{ Name = "Timeline"; Type = "Text"; DisplayName = "Thời gian triển khai" }
            @{ Name = "LeadScore"; Type = "Number"; DisplayName = "Điểm Lead (1-100)" }
            @{ Name = "FormSubmissionId"; Type = "Text"; DisplayName = "ID Form Submission" }
            @{ Name = "FormResponseDate"; Type = "DateTime"; DisplayName = "Ngày nộp form" }
            @{ Name = "LastContactDate"; Type = "DateTime"; DisplayName = "Lần liên hệ cuối" }
            @{ Name = "NextFollowUpDate"; Type = "DateTime"; DisplayName = "Ngày hẹn liên hệ tiếp theo" }
            @{ Name = "EmailsSent"; Type = "Number"; DisplayName = "Số email đã gửi" }
            @{ Name = "LastEmailSent"; Type = "DateTime"; DisplayName = "Email cuối gửi lúc" }
        )

        foreach ($field in $fields) {
            $existingField = Get-PnPField -List $leadsList -Identity $field.Name -ErrorAction SilentlyContinue
            if (-not $existingField) {
                Write-Host "  Adding field: $($field.DisplayName)" -ForegroundColor White
                if ($field.Type -eq "Text") {
                    Add-PnPField -List $leadsList -Type Text -InternalName $field.Name -DisplayName $field.DisplayName -Required:$field.Required | Out-Null
                }
                elseif ($field.Type -eq "Note") {
                    Add-PnPField -List $leadsList -Type Note -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
                elseif ($field.Type -eq "Number") {
                    Add-PnPField -List $leadsList -Type Number -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
                elseif ($field.Type -eq "DateTime") {
                    Add-PnPField -List $leadsList -Type DateTime -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
            }
        }

        # Add Choice fields
        $statusField = Get-PnPField -List $leadsList -Identity "Status" -ErrorAction SilentlyContinue
        if (-not $statusField) {
            Write-Host "  Adding Status choice field" -ForegroundColor White
            Add-PnPField -List $leadsList -Type Choice -InternalName "Status" -DisplayName "Trạng thái" -Choices @("New","Contacted","Qualified","Converted","Lost") | Out-Null
        }

        $priorityField = Get-PnPField -List $leadsList -Identity "Priority" -ErrorAction SilentlyContinue
        if (-not $priorityField) {
            Write-Host "  Adding Priority choice field" -ForegroundColor White
            Add-PnPField -List $leadsList -Type Choice -InternalName "Priority" -DisplayName "Ưu tiên" -Choices @("Low","Medium","High","Critical") | Out-Null
        }

        $sequenceField = Get-PnPField -List $leadsList -Identity "FollowUpSequenceStage" -ErrorAction SilentlyContinue
        if (-not $sequenceField) {
            Write-Host "  Adding Follow-up Sequence Stage field" -ForegroundColor White
            Add-PnPField -List $leadsList -Type Choice -InternalName "FollowUpSequenceStage" -DisplayName "Giai đoạn Follow-up" -Choices @("Initial","FirstFollow","SecondFollow","ThirdFollow","Completed") | Out-Null
        }

        Write-Host "✅ Leads list deployed successfully!" -ForegroundColor Green

    }
    catch {
        Write-Host "❌ Failed to deploy Leads list: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Function to deploy Email Templates library
function Deploy-EmailTemplatesLibrary {
    param([switch]$DryRun)

    Write-Host "📧 Deploying Email Templates library..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create Email Templates document library" -ForegroundColor Magenta
        return
    }

    try {
        # Check if Email Templates library exists
        $templatesLib = Get-PnPList -Identity "EmailTemplates" -ErrorAction SilentlyContinue
        
        if (-not $templatesLib) {
            Write-Host "Creating Email Templates library..." -ForegroundColor Cyan
            $templatesLib = New-PnPList -Title "EmailTemplates" -Template DocumentLibrary -Description "Email templates cho lead nurturing"
        }

        # Add custom fields for template metadata
        $templateTypeField = Get-PnPField -List $templatesLib -Identity "TemplateType" -ErrorAction SilentlyContinue
        if (-not $templateTypeField) {
            Write-Host "  Adding TemplateType field" -ForegroundColor White
            Add-PnPField -List $templatesLib -Type Choice -InternalName "TemplateType" -DisplayName "Loại Template" -Choices @("Welcome","FirstFollow","SecondFollow","ThirdFollow","Conversion","Manual") | Out-Null
        }

        $templateLanguageField = Get-PnPField -List $templatesLib -Identity "TemplateLanguage" -ErrorAction SilentlyContinue
        if (-not $templateLanguageField) {
            Write-Host "  Adding TemplateLanguage field" -ForegroundColor White
            Add-PnPField -List $templatesLib -Type Choice -InternalName "TemplateLanguage" -DisplayName = "Ngôn ngữ" -Choices @("Vietnamese","English") | Out-Null
        }

        Write-Host "✅ Email Templates library deployed successfully!" -ForegroundColor Green

    }
    catch {
        Write-Host "❌ Failed to deploy Email Templates library: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Function to deploy Lead Activities list
function Deploy-LeadActivitiesList {
    param([switch]$DryRun)

    Write-Host "📊 Deploying Lead Activities list..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create Lead Activities tracking list" -ForegroundColor Magenta
        return
    }

    try {
        # Check if Lead Activities list exists
        $activitiesList = Get-PnPList -Identity "LeadActivities" -ErrorAction SilentlyContinue
        
        if (-not $activitiesList) {
            Write-Host "Creating Lead Activities list..." -ForegroundColor Cyan
            $activitiesList = New-PnPList -Title "LeadActivities" -Template GenericList -Description "Tracking hoạt động và tương tác với leads"
        }

        # Add tracking fields
        $fields = @(
            @{ Name = "ActivityType"; Type = "Choice"; DisplayName = "Loại hoạt động"; Choices = @("EmailSent","EmailOpened","EmailClicked","FormSubmitted","PhoneCall","Meeting","Converted") }
            @{ Name = "ActivityDate"; Type = "DateTime"; DisplayName = "Thời gian" }
            @{ Name = "ActivityDetails"; Type = "Note"; DisplayName = "Chi tiết" }
            @{ Name = "EmailSubject"; Type = "Text"; DisplayName = "Tiêu đề email" }
            @{ Name = "EngagementScore"; Type = "Number"; DisplayName = "Điểm tương tác" }
        )

        foreach ($field in $fields) {
            $existingField = Get-PnPField -List $activitiesList -Identity $field.Name -ErrorAction SilentlyContinue
            if (-not $existingField) {
                Write-Host "  Adding field: $($field.DisplayName)" -ForegroundColor White
                if ($field.Type -eq "Choice") {
                    Add-PnPField -List $activitiesList -Type Choice -InternalName $field.Name -DisplayName $field.DisplayName -Choices $field.Choices | Out-Null
                }
                elseif ($field.Type -eq "Text") {
                    Add-PnPField -List $activitiesList -Type Text -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
                elseif ($field.Type -eq "Note") {
                    Add-PnPField -List $activitiesList -Type Note -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
                elseif ($field.Type -eq "Number") {
                    Add-PnPField -List $activitiesList -Type Number -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
                elseif ($field.Type -eq "DateTime") {
                    Add-PnPField -List $activitiesList -Type DateTime -InternalName $field.Name -DisplayName $field.DisplayName | Out-Null
                }
            }
        }

        Write-Host "✅ Lead Activities list deployed successfully!" -ForegroundColor Green

    }
    catch {
        Write-Host "❌ Failed to deploy Lead Activities list: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Function to create sample email templates
function Create-SampleEmailTemplates {
    param([switch]$DryRun)

    Write-Host "📝 Creating sample email templates..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create sample email templates" -ForegroundColor Magenta
        return
    }

    try {
        # Welcome email template
        $welcomeTemplate = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Chào mừng bạn đến với CCBA BIM</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #0066cc;">Cảm ơn bạn đã quan tâm đến dịch vụ BIM của CCBA!</h2>
        
        <p>Xin chào {{LeadName}},</p>
        
        <p>Cảm ơn bạn đã liên hệ với chúng tôi qua website. Chúng tôi đã nhận được thông tin về dự án {{ProjectDescription}} của bạn.</p>
        
        <p>Nhân viên tư vấn của chúng tôi sẽ liên hệ với bạn trong vòng 24 giờ tới để trao đổi chi tiết về nhu cầu của bạn.</p>
        
        <p>Trong thời gian chờ đợi, bạn có thể tham khảo thêm về dịch vụ BIM của chúng tôi tại <a href="https://ccba.vn">website</a>.</p>
        
        <p>Trân trọng,<br>
        Đội ngũ CCBA BIM</p>
        
        <hr style="margin: 30px 0;">
        <p style="font-size: 12px; color: #666;">
            Nếu bạn không muốn nhận email từ chúng tôi, vui lòng <a href="{{UnsubscribeLink}}">bỏ đăng ký</a>.
        </p>
    </div>
</body>
</html>
"@

        # Upload welcome template
        $welcomeFileName = "welcome-template.html"
        Add-PnPFile -Path $welcomeFileName -Folder "EmailTemplates" -Content ([System.Text.Encoding]::UTF8.GetBytes($welcomeTemplate)) -ErrorAction SilentlyContinue

        Write-Host "✅ Sample email templates created successfully!" -ForegroundColor Green

    }
    catch {
        Write-Host "❌ Failed to create sample email templates: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# Main execution
try {
    Deploy-LeadsList -DryRun:$DryRun
    Deploy-EmailTemplatesLibrary -DryRun:$DryRun
    Deploy-LeadActivitiesList -DryRun:$DryRun
    Create-SampleEmailTemplates -DryRun:$DryRun

    Write-Host "`n🎉 Lead Capture Module Deployment Complete!" -ForegroundColor Green
    Write-Host "📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Setup Microsoft Forms and connect to Power Automate" -ForegroundColor White
    Write-Host "  2. Configure lead assignment rules" -ForegroundColor White
    Write-Host "  3. Create email follow-up workflows" -ForegroundColor White
    Write-Host "  4. Test end-to-end lead capture flow" -ForegroundColor White
    Write-Host "  5. Setup Power BI dashboard for lead analytics" -ForegroundColor White

}
catch {
    Write-Host "❌ Script execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Disconnect from SharePoint
    Disconnect-PnPOnline
}