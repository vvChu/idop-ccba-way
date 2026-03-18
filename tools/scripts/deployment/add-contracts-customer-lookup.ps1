param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Interactive'
)

$ErrorActionPreference = 'Stop'

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Host "[add-lookup] 🔗 Connecting to $siteUrl" -ForegroundColor Cyan
try {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $config.ClientId
  Write-Host "[add-lookup] ✅ Connected" -ForegroundColor Green
}
catch {
  Write-Host "[add-lookup] ❌ Connect failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 2
}

try {
  $contracts = Get-PnPList -Identity "Contracts" -ErrorAction Stop
} catch {
  Write-Host "[add-lookup] ❌ List 'Contracts' not found" -ForegroundColor Red
  exit 3
}

try {
  $customers = Get-PnPList -Identity "Customers" -ErrorAction Stop
} catch {
  Write-Host "[add-lookup] ❌ List 'Customers' not found (ensure CRM lists exist)" -ForegroundColor Red
  exit 4
}

# If field already exists, exit gracefully
$existing = Get-PnPField -List $contracts -Identity "CustomerId" -ErrorAction SilentlyContinue
if ($existing) {
  Write-Host "[add-lookup] ℹ️ Field 'CustomerId' already exists on 'Contracts'. Nothing to do." -ForegroundColor Gray
  exit 0
}

Write-Host "[add-lookup] ➕ Creating lookup field 'CustomerId' on 'Contracts' → Customers(ID)" -ForegroundColor Yellow
try {
  $custShowField = "Title"
  $custNameField = Get-PnPField -List $customers -Identity "CustomerName" -ErrorAction SilentlyContinue
  if ($custNameField) { $custShowField = "CustomerName" }

  $customersId = $customers.Id.Guid
  $fieldId = [Guid]::NewGuid().ToString()
  $fieldXml = @"
<Field Type="Lookup" DisplayName="Customer" StaticName="CustomerId" Name="CustomerId" Required="FALSE" ShowField="$custShowField" List="{$customersId}" ID="{$fieldId}" />
"@
  Add-PnPFieldFromXml -FieldXml $fieldXml -List $contracts | Out-Null
}
catch {
  Write-Host "[add-lookup] ❌ Failed to add lookup: $($_.Exception.Message)" -ForegroundColor Red
  exit 5
}

# Index the field, then set relationship behavior to Restrict
try { Set-PnPField -List $contracts -Identity "CustomerId" -Values @{ Indexed = $true } | Out-Null } catch { }
try { Set-PnPField -List $contracts -Identity "CustomerId" -Values @{ RelationshipDeleteBehavior = "Restrict" } | Out-Null } catch { }

Write-Host "[add-lookup] ✅ Created 'CustomerId' lookup on 'Contracts'" -ForegroundColor Green
exit 0
