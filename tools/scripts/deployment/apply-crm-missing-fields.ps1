param(
  [ValidateSet("Dev","Test","Prod")]
  [string]$Environment = "Dev",
  [string]$ListsPath = "datamodel/sharepoint/lists/strategy_crm",
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Interactive'
)

$ErrorActionPreference = 'Stop'

# Import shared modules
$ModulePath = Join-Path $PSScriptRoot "../modules"
Import-Module "$ModulePath/PnPHelpers.psm1" -Force

function Write-Log([string]$msg, [string]$level = 'INFO') {
  switch ($level) {
    'OK'    { Write-Host $msg -ForegroundColor Green }
    'WARN'  { Write-Host $msg -ForegroundColor DarkYellow }
    'ERR'   { Write-Host $msg -ForegroundColor Red }
    default { Write-Host $msg }
  }
}

$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Log "[crm-apply] 🔗 Connecting to $siteUrl"
Connect-IdopOnline -SiteUrl $siteUrl -AuthMode $Auth -ClientId $config.ClientId
Write-Log "[crm-apply] ✅ Connected" 'OK'

function Add-LookupFieldIfMissing {
  param(
    [string]$ListName,
    [string]$InternalName,
    [string]$DisplayName,
    [string]$TargetListName,
    [string]$TargetFieldInternal = 'ID',
    [string]$ShowField = $null
  )

  $list = Get-PnPList -Identity $ListName -ErrorAction Stop
  $targetList = Get-PnPList -Identity $TargetListName -ErrorAction Stop

  # Already exists?
  $existing = Get-PnPField -List $list -Identity $InternalName -ErrorAction SilentlyContinue
  if ($existing) { return $false }

  if (-not $ShowField) {
    $candidates = @('Name','Title','CustomerName','ServiceName','ContactName','OpportunityName')
    foreach ($c in $candidates) {
      $f = Get-PnPField -List $targetList -Identity $c -ErrorAction SilentlyContinue
      if ($f) { $ShowField = $c; break }
    }
    if (-not $ShowField) { $ShowField = 'Title' }
  }

  $targetListGuid = $targetList.Id.Guid
  $fieldId = [Guid]::NewGuid().ToString()
  $fieldXml = @"
<Field Type="Lookup" DisplayName="$DisplayName" StaticName="$InternalName" Name="$InternalName" Required="FALSE" ShowField="$ShowField" List="{$targetListGuid}" ID="{$fieldId}" />
"@
  Add-PnPFieldFromXml -FieldXml $fieldXml -List $list | Out-Null
  return $true
}

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
      Write-Log "[crm-apply] ℹ️ Using Site Collection Term Store for '$ListName' -> '$InternalName'"
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

  Add-PnPFieldFromXml -FieldXml $fieldXml -List $list | Out-Null
  return $true
}

function Add-PrimitiveFieldIfMissing {
  param(
    [string]$ListName,
    [string]$Type,
    [string]$InternalName,
    [string]$DisplayName,
    [object]$Definition
  )

  $list = Get-PnPList -Identity $ListName -ErrorAction Stop
  $existing = Get-PnPField -List $list -Identity $InternalName -ErrorAction SilentlyContinue
  if ($existing) { return $false }

  switch ($Type) {
    'Text'       { Add-PnPField -List $list -Type Text -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'Note'       { Add-PnPField -List $list -Type Note -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'Number'     { Add-PnPField -List $list -Type Number -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'Currency'   { Add-PnPField -List $list -Type Currency -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'DateTime'   { Add-PnPField -List $list -Type DateTime -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'YesNo'      { Add-PnPField -List $list -Type Boolean -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'Boolean'    { Add-PnPField -List $list -Type Boolean -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'User'       { Add-PnPField -List $list -Type User -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'URL'        { Add-PnPField -List $list -Type URL -InternalName $InternalName -DisplayName $DisplayName | Out-Null }
    'Choice'     { $choices = @(); if ($Definition.Choices) { $choices = $Definition.Choices }; Add-PnPField -List $list -Type Choice -InternalName $InternalName -DisplayName $DisplayName -Choices $choices | Out-Null }
    'MultiChoice'{ $choices = @(); if ($Definition.Choices) { $choices = $Definition.Choices }; Add-PnPField -List $list -Type MultiChoice -InternalName $InternalName -DisplayName $DisplayName -Choices $choices | Out-Null }
    default      { throw "Unsupported primitive type: $Type" }
  }
  return $true
}

$jsonFiles = Get-ChildItem -Path $ListsPath -Recurse -Filter *.json
Write-Log "[crm-apply] 📄 Found $($jsonFiles.Count) CRM definition files"

$created = 0; $skipped = 0; $errors = 0

foreach ($jsonFile in $jsonFiles) {
  $def = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json
  $listName = $def.ListName
  Write-Log "[crm-apply] ▶ Processing list '$listName'"
  try { Get-PnPList -Identity $listName -ErrorAction Stop | Out-Null } catch { Write-Log "[crm-apply] ❌ List '$listName' not found" 'ERR'; $errors++; continue }

  foreach ($col in $def.Columns) {
    $name = $col.Name; $type = $col.Type
    try {
      $exists = Get-PnPField -List $listName -Identity $name -ErrorAction SilentlyContinue
      # Special handling: if expected ManagedMetadata but an existing Text field is present, create a parallel MM field with _MM suffix
      if ($exists -and $type -eq 'ManagedMetadata') {
        $existingType = $exists.TypeAsString
        if ($existingType -eq 'Text' -or $existingType -eq 'Note' -or $existingType -eq 'Choice' -or $existingType -eq 'MultiChoice') {
          $parallelInternal = "${name}_MM"
          $parallelExists = Get-PnPField -List $listName -Identity $parallelInternal -ErrorAction SilentlyContinue
          if (-not $parallelExists) {
            $grp = $col.TermSet.Group; $ts = $col.TermSet.Name
            $added = Add-TaxonomyFieldIfMissing -ListName $listName -InternalName $parallelInternal -DisplayName $name -TermGroupName $grp -TermSetName $ts
            if ($added) { Write-Log "[crm-apply] ➕ Added parallel MM field '$parallelInternal' on '$listName' for existing '$name' ($existingType)"; $created++ } else { $skipped++ }
          } else {
            $skipped++
          }
          continue
        }
      }
      if ($exists) { $skipped++; continue }

      switch ($type) {
        'Lookup' {
          $tList = $col.Lookup.List; $tField = $col.Lookup.Field
          $showField = $null
          # prefer a label field if not ID
          if ($tField -and $tField -ne 'ID') { $showField = $tField }
          $added = Add-LookupFieldIfMissing -ListName $listName -InternalName $name -DisplayName $name -TargetListName $tList -TargetFieldInternal $tField -ShowField $showField
          if ($added) { $created++ } else { $skipped++ }
        }
        'ManagedMetadata' {
          $grp = $col.TermSet.Group; $ts = $col.TermSet.Name
          $added = Add-TaxonomyFieldIfMissing -ListName $listName -InternalName $name -DisplayName $name -TermGroupName $grp -TermSetName $ts
          if ($added) { $created++ } else { $skipped++ }
        }
        default {
          $added = Add-PrimitiveFieldIfMissing -ListName $listName -Type $type -InternalName $name -DisplayName $name -Definition $col
          if ($added) { $created++ } else { $skipped++ }
        }
      }
    } catch {
      Write-Log "[crm-apply] ❌ Failed adding field '$name' on '$listName': $($_.Exception.Message)" 'ERR'
      $errors++
    }
  }
}

Write-Log "[crm-apply] ✅ Done. Created: $created, Skipped(existing): $skipped, Errors: $errors" 'OK'
exit 0
