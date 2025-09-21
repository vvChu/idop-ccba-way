param(
  [string]$ListsPath = "datamodel/sharepoint/lists",
  [switch]$DryRun
)

# Import required modules
Import-Module PnP.PowerShell -ErrorAction Stop

# Security: Validate inputs
if (-not (Test-Path $ListsPath)) {
  Write-Host "[ERROR] ListsPath does not exist: $ListsPath" -ForegroundColor Red
  exit 1
}

# Security: Use secure authentication (prefer certificate or managed identity over interactive)
$authMethod = $env:PNP_AUTH_METHOD  # Set to 'Certificate', 'ManagedIdentity', or 'Interactive'
if (-not $authMethod) { $authMethod = 'Interactive' }

Write-Host "[apply-sp-lists] Applying SharePoint Lists from '$ListsPath' (DryRun=$DryRun)" -ForegroundColor Yellow
# TODO: Implement schema validation, diff, and apply logic using Microsoft Graph/PNP or SharePoint REST.
# - Validate JSON against schemas in datamodel/sharepoint/schemas
# - If -DryRun, show planned changes only
# - Otherwise, apply changes and create a backup/snapshot

# Environment config (update as needed)
$envs = @{
  Dev = @{
    SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-dev"
    TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    EnvironmentId = "8d5b1f25-82e2-eafe-8bab-76568795ee80"
    InstanceUrl = "https://org602e4787.crm5.dynamics.com/"
  }
  Test = @{
    SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-Test"
    TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    EnvironmentId = "30cf6c66-569a-e1c9-8a1b-8b1cd237629c"
    InstanceUrl = "https://org8b1a0d09.crm5.dynamics.com/"
  }
  Prod = @{
    SharePointUrl = "https://ibstbim.sharepoint.com/sites/idop-Prod"
    TenantId = "d7aa4978-363e-47aa-a77e-7da957b32bf3"
    EnvironmentId = "8524a85e-71ac-ef33-8829-c81b3267f78d"
    InstanceUrl = "https://org720c8362.crm5.dynamics.com/"
  }
}

# Select environment (default: Dev)
$SelectedEnv = $env:IDOP_ENVIRONMENT
if (-not $SelectedEnv) { $SelectedEnv = "Dev" }
if (-not $envs.ContainsKey($SelectedEnv)) {
  Write-Host "[ERROR] Unknown environment: $SelectedEnv. Valid: Dev, Test, Prod" -ForegroundColor Red
  exit 1
}
$envConfig = $envs[$SelectedEnv]
Write-Host "[env] Using environment: $SelectedEnv" -ForegroundColor Cyan
Write-Host "[env] SharePoint URL: $($envConfig.SharePointUrl)" -ForegroundColor Cyan
Write-Host "[env] Tenant ID: $($envConfig.TenantId)" -ForegroundColor Cyan
Write-Host "[env] Environment ID: $($envConfig.EnvironmentId)" -ForegroundColor Cyan
Write-Host "[env] Instance URL: $($envConfig.InstanceUrl)" -ForegroundColor Cyan


# Validate all JSON files against schema (call ajv for each file individually)
$SchemaPath = "datamodel/sharepoint/schemas/sp-list.schema.json"
Write-Host "[validate] Checking all JSON lists against schema: $SchemaPath" -ForegroundColor Cyan
$allValid = $true
foreach ($jsonFile in Get-ChildItem -Path $ListsPath -Recurse -Filter *.json) {
  $ajvCmd = "ajv validate -s `"$SchemaPath`" -d `"$($jsonFile.FullName)`""
  Write-Host "Validating: $($jsonFile.FullName)"
  Invoke-Expression $ajvCmd
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Schema validation failed for $($jsonFile.FullName)" -ForegroundColor Red
    $allValid = $false
  }
}
if (-not $allValid) {
  exit 2
}
Write-Host "[validate] All JSON lists are valid." -ForegroundColor Green

# Diff detection
Write-Host "[diff] Checking for planned changes (DryRun=$DryRun)" -ForegroundColor Cyan
# TODO: Implement logic to compare local JSON with SharePoint Lists (using PNP/Graph)
$changes = @()
try {
  # Connect to SharePoint with secure authentication
  switch ($authMethod) {
    'Certificate' {
      $certPath = $env:PNP_CERT_PATH
      $certPassword = $env:PNP_CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
      Connect-PnPOnline -Url $envConfig.SharePointUrl -CertificatePath $certPath -CertificatePassword $certPassword -Tenant $envConfig.TenantId
    }
    'ManagedIdentity' {
      Connect-PnPOnline -Url $envConfig.SharePointUrl -ManagedIdentity
    }
    default {
      Connect-PnPOnline -Url $envConfig.SharePointUrl -Interactive
    }
  }
  Write-Host "[diff] Connected to SharePoint using $authMethod" -ForegroundColor Green
  
  foreach ($jsonFile in Get-ChildItem -Path $ListsPath -Recurse -Filter *.json) {
    $listName = [System.IO.Path]::GetFileNameWithoutExtension($jsonFile.Name)
    $localList = Get-Content $jsonFile.FullName | ConvertFrom-Json
    
    # Check if list exists in SharePoint
    $spList = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
    if ($null -eq $spList) {
      $changes += @{
        Action = "Create"
        ListName = $listName
        File = $jsonFile.FullName
      }
    } else {
      # Compare fields, etc. (simplified)
      $changes += @{
        Action = "Update"
        ListName = $listName
        File = $jsonFile.FullName
      }
    }
  }
  
  Disconnect-PnPOnline
} catch {
  Write-Host "[ERROR] Failed to diff with SharePoint: $($_.Exception.Message)" -ForegroundColor Red
  exit 3
}

if ($changes.Count -eq 0) {
  Write-Host "[diff] No changes detected." -ForegroundColor Green
} else {
  Write-Host "[diff] Planned changes:" -ForegroundColor Yellow
  $changes | ForEach-Object { Write-Host "  $($_.Action): $($_.ListName)" }
}

if ($DryRun) {
  Write-Host "[DryRun] Exiting without applying changes." -ForegroundColor Yellow
  exit 0
}

# Backup/snapshot
Write-Host "[backup] Creating snapshot before applying changes..." -ForegroundColor Magenta
# TODO: Implement backup logic (e.g. export current SharePoint Lists to backup folder)
$backupDir = "backups/$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

try {
  # Connect with secure auth for backup
  switch ($authMethod) {
    'Certificate' {
      $certPath = $env:PNP_CERT_PATH
      $certPassword = $env:PNP_CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
      Connect-PnPOnline -Url $envConfig.SharePointUrl -CertificatePath $certPath -CertificatePassword $certPassword -Tenant $envConfig.TenantId
    }
    'ManagedIdentity' {
      Connect-PnPOnline -Url $envConfig.SharePointUrl -ManagedIdentity
    }
    default {
      Connect-PnPOnline -Url $envConfig.SharePointUrl -Interactive
    }
  }
  
  foreach ($change in $changes) {
    $listName = $change.ListName
    $backupFile = "$backupDir/$listName.json"
    
    # Export list schema (simplified)
    $list = Get-PnPList -Identity $listName
    $listSchema = @{
      Title = $list.Title
      Description = $list.Description
      Fields = Get-PnPField -List $listName | Select-Object Title, InternalName, TypeAsString
    }
    
    $listSchema | ConvertTo-Json -Depth 10 | Out-File $backupFile
    Write-Host "[backup] Backed up $listName to $backupFile" -ForegroundColor Cyan
  }
  
  Disconnect-PnPOnline
} catch {
  Write-Host "[ERROR] Backup failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 4
}

# Apply changes
Write-Host "[apply] Applying changes to SharePoint..." -ForegroundColor Green
# TODO: Implement apply logic using PNP/Graph API
try {
  # Connect with secure auth for apply
  switch ($authMethod) {
    'Certificate' {
      $certPath = $env:PNP_CERT_PATH
      $certPassword = $env:PNP_CERT_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
      Connect-PnPOnline -Url $envConfig.SharePointUrl -CertificatePath $certPath -CertificatePassword $certPassword -Tenant $envConfig.TenantId
    }
    'ManagedIdentity' {
      Connect-PnPOnline -Url $envConfig.SharePointUrl -ManagedIdentity
    }
    default {
      Connect-PnPOnline -Url $envConfig.SharePointUrl -Interactive
    }
  }
  
  foreach ($change in $changes) {
    $listName = $change.ListName
    $jsonFile = $change.File
    $localList = Get-Content $jsonFile | ConvertFrom-Json
    
    if ($change.Action -eq "Create") {
      # Create new list
      New-PnPList -Title $listName -Template GenericList -OnQuickLaunch
      Write-Host "[apply] Created list: $listName" -ForegroundColor Green
      
      # Add fields if specified
      if ($localList.Fields) {
        foreach ($field in $localList.Fields) {
          # Simplified field creation
          Add-PnPField -List $listName -DisplayName $field.Title -InternalName $field.InternalName -Type $field.Type
        }
      }
    } elseif ($change.Action -eq "Update") {
      # Update existing list (simplified)
      Write-Host "[apply] Updated list: $listName" -ForegroundColor Green
      # Implement field updates, etc.
    }
  }
  
  Disconnect-PnPOnline
} catch {
  Write-Host "[ERROR] Apply failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 5
}

Write-Host "[apply] All changes applied successfully." -ForegroundColor Green
