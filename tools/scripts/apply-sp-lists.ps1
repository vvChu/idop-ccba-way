param(
  [string]$ListsPath = "datamodel/sharepoint/lists",
  [switch]$DryRun
)

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

# Diff detection (stub)
Write-Host "[diff] Checking for planned changes (DryRun=$DryRun)" -ForegroundColor Cyan
# TODO: Implement logic to compare local JSON with SharePoint Lists (using PNP/Graph)
if ($DryRun) {
  Write-Host "[DryRun] Planned changes would be shown here (not yet implemented)." -ForegroundColor Yellow
  exit 0
}

# Backup/snapshot (stub)
Write-Host "[backup] Creating snapshot before applying changes..." -ForegroundColor Magenta
# TODO: Implement backup logic (e.g. export current SharePoint Lists to backup folder)

# Apply changes (stub)
Write-Host "[apply] Applying changes to SharePoint..." -ForegroundColor Green
# TODO: Implement apply logic using PNP/Graph API
