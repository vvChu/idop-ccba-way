param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [string]$ListsPath = "datamodel/sharepoint/lists",
  [switch]$DryRun,
  [string]$MigrationPlanPath = "migration-plan.json",
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
)

$ErrorActionPreference = 'Stop'

function Write-Log([string]$msg, [string]$level = 'INFO') {
  switch ($level) {
    'OK'    { Write-Host $msg -ForegroundColor Green }
    'WARN'  { Write-Host $msg -ForegroundColor DarkYellow }
    'ERR'   { Write-Host $msg -ForegroundColor Red }
    default { Write-Host $msg }
  }
}

$clientId = "90ded6f0-b787-4b3c-acea-8baf6403fd63"
$envConfigs = @{
  Dev  = "https://ibstbim.sharepoint.com/sites/idop-dev"
  Test = "https://ibstbim.sharepoint.com/sites/idop-test"
  Prod = "https://ibstbim.sharepoint.com/sites/idop-prod"
}

if (-not $envConfigs.ContainsKey($Environment)) { Write-Log "[mm-apply] ❌ Unknown environment: $Environment" 'ERR'; exit 1 }
$siteUrl = $envConfigs[$Environment]

# Auth helper
$authModule = Join-Path $PSScriptRoot 'modules/SpAuth.psm1'
if (Test-Path $authModule) { Import-Module $authModule -Force }

Write-Log "[mm-apply] 🔗 Connecting to $siteUrl"
if (Get-Command -Name Connect-IdopOnline -ErrorAction SilentlyContinue) {
  Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $clientId
} else {
  Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $clientId
}
Write-Log "[mm-apply] ✅ Connected" 'OK'

function Add-TaxonomyFieldIfMissing {
  param(
    [string]$ListName,
    [string]$InternalName,
    [string]$DisplayName,
    [string]$TermGroupName,
    [string]$TermSetName
  )

  $list = Get-PnPList -Identity $ListName -ErrorAction Stop
  $existing = Get-PnPField -List $list -Identity $InternalName -ErrorAction SilentlyContinue
  if ($existing) { return $false }

  # Get term store: prefer tenant term store; fall back to site collection term store if needed
  $store = $null
  try {
    $store = Get-PnPTermStore -ErrorAction Stop
  } catch {
    try {
      $store = Get-PnPSiteCollectionTermStore -ErrorAction Stop
      Write-Log "[mm-apply] ℹ️ Using Site Collection Term Store for '$ListName' -> '$InternalName'"
    } catch {
      throw "Unable to access Term Store via PnP. Ensure taxonomy is available and you have permissions."
    }
  }
  $group = Get-PnPTermGroup -Identity $TermGroupName -ErrorAction Stop
  $termSet = Get-PnPTermSet -Identity $TermSetName -TermGroup $group -ErrorAction Stop

  $sspId = $store.Id.Guid
  $tsId = $termSet.Id.Guid
  $fieldId = [Guid]::NewGuid().ToString()
  $fieldXml = @"
<Field Type="TaxonomyFieldType" DisplayName="$DisplayName" StaticName="$InternalName" Name="$InternalName" Required="FALSE" ShowField="Term1033" ID="{$fieldId}">
  <Customization>
    <ArrayOfProperty>
      <Property>
        <Name>SspId</Name>
        <Value xmlns:q1="http://www.w3.org/2001/XMLSchema" p4:type="q1:string" xmlns:p4="http://www.w3.org/2001/XMLSchema-instance">{$sspId}</Value>
      </Property>
      <Property>
        <Name>TermSetId</Name>
        <Value xmlns:q2="http://www.w3.org/2001/XMLSchema" p4:type="q2:string" xmlns:p4="http://www.w3.org/2001/XMLSchema-instance">{$tsId}</Value>
      </Property>
      <Property>
        <Name>AnchorId</Name>
        <Value xmlns:q3="http://www.w3.org/2001/XMLSchema" p4:type="q3:string" xmlns:p4="http://www.w3.org/2001/XMLSchema-instance">00000000-0000-0000-0000-000000000000</Value>
      </Property>
    </ArrayOfProperty>
  </Customization>
</Field>
"@

  if ($DryRun) {
    Write-Log "[mm-apply] ⏩ Would add MM field '$InternalName' to '$ListName' bound to '$TermGroupName' -> '$TermSetName'"
  } else {
    Add-PnPFieldFromXml -FieldXml $fieldXml -List $list | Out-Null
  }
  return $true
}

$jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
Write-Log "[mm-apply] 📄 Found $($jsonFiles.Count) definition files"

$migrationPlan = @()
$created = 0; $skipped = 0; $errors = 0

foreach ($jsonFile in $jsonFiles) {
  $def = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json
  $listName = $def.ListName
  Write-Log "[mm-apply] ▶ Processing list '$listName'"
  try { Get-PnPList -Identity $listName -ErrorAction Stop | Out-Null } catch { Write-Log "[mm-apply] ❌ List '$listName' not found" 'ERR'; $errors++; continue }

  foreach ($col in $def.Columns) {
    if ($col.Type -ne 'ManagedMetadata') { continue }
    $name = $col.Name
    $grp = $col.TermSet.Group
    $ts = $col.TermSet.Name

    $existing = Get-PnPField -List $listName -Identity $name -ErrorAction SilentlyContinue
    if ($existing) {
      $existingType = $existing.TypeAsString
      if ($existingType -eq 'TaxonomyFieldType') {
        $skipped++
        continue
      } elseif ($existingType -in @('Text', 'Note', 'Choice', 'MultiChoice')) {
        # Add parallel _MM field
        $parallelInternal = "${name}_MM"
        $parallelExists = Get-PnPField -List $listName -Identity $parallelInternal -ErrorAction SilentlyContinue
        if (-not $parallelExists) {
          $added = Add-TaxonomyFieldIfMissing -ListName $listName -InternalName $parallelInternal -DisplayName $name -TermGroupName $grp -TermSetName $ts
          if ($added) {
            Write-Log "[mm-apply] ➕ Added parallel MM field '$parallelInternal' on '$listName' for existing '$name' ($existingType)"
            $created++
            # Add to migration plan
            $migrationPlan += @{
              List = $listName
              OriginalField = $name
              ParallelField = $parallelInternal
              TermGroup = $grp
              TermSet = $ts
              SourceType = $existingType
              Notes = "Migrate text/choice values to MM terms"
            }
          } else {
            $skipped++
          }
        } else {
          $skipped++
        }
      } else {
        Write-Log "[mm-apply] ⚠️ Field '$name' exists as '$existingType' on '$listName'; skipping"
        $skipped++
      }
    } else {
      # Add the exact MM field
      $added = Add-TaxonomyFieldIfMissing -ListName $listName -InternalName $name -DisplayName $name -TermGroupName $grp -TermSetName $ts
      if ($added) {
        $created++
      } else {
        $skipped++
      }
    }
  }
}

# Save migration plan
if ($migrationPlan.Count -gt 0) {
  $migrationPlan | ConvertTo-Json -Depth 10 | Set-Content -Path $MigrationPlanPath
  Write-Log "[mm-apply] 📋 Migration plan saved to '$MigrationPlanPath'"
} else {
  Write-Log "[mm-apply] 📋 No migration needed"
}

Write-Log "[mm-apply] ✅ Done. Created: $created, Skipped(existing): $skipped, Errors: $errors" 'OK'
exit 0