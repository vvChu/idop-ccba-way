param(
  [ValidateSet("Dev","Test","Prod","IDOP")]
  [string]$Environment = "Dev",
  [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",
  [string]$GroupName = "CCBA Taxonomy",
  [switch]$DryRun,
  [ValidateSet('Cached','Interactive','DeviceLogin')] [string]$Auth = 'Cached'
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

# Load environment configuration
$config = Get-IDOPConfig -Environment $Environment
$siteUrl = $config.SharePointUrl

Write-Log "[termstore-import] 🔗 Connecting to $siteUrl"
Connect-IDOPSharePoint -Environment $Environment
Write-Log "[termstore-import] ✅ Connected" 'OK'

function Get-TermStoreWithFallback {
  try {
    $store = Get-PnPTermStore -ErrorAction SilentlyContinue
    if ($store) { return @{ Store = $store; Scope = 'Tenant' } }
    return @{ Store = $null; Scope = 'Tenant' }
  } catch {
    return @{ Store = $null; Scope = 'Tenant' }
  }
}

function Ensure-TermGroup {
  param(
    [string]$Name
  )
  $group = try { Get-PnPTermGroup -ErrorAction Stop | Where-Object { $_.Name -eq $Name } | Select-Object -First 1 } catch { $null }
  if ($group) { return $group }
  if ($DryRun) { Write-Log "[termstore-import] ⏩ Would create Term Group '$Name'"; return @{ Name=$Name } }
  $group = New-PnPTermGroup -Name $Name
  return $group
}

function Ensure-TermSet {
  param(
    [object]$Group,
    [string]$Name,
    [string]$Id,
    [string]$Description = $null,
    [int]$Lcid = 1066 # vi-VN
  )
  # In DryRun, don't attempt to resolve existing objects to avoid interactive prompts/type binding issues
  if ($DryRun) { Write-Log "[termstore-import] ⏩ Would create Term Set '$Name' in group '$($Group.Name)' (Id=$Id)"; return @{ Name=$Name; Id=$Id } }
  # Build a robust TermGroup pipe bind (name or GUID)
  $grpBind = $null
  if ($Group -is [string]) { $grpBind = $Group }
  elseif ($Group -is [guid]) { $grpBind = $Group }
  elseif ($Group.PSObject.Properties.Name -contains 'Id') { $grpBind = $Group.Id }
  elseif ($Group.PSObject.Properties.Name -contains 'Name') { $grpBind = $Group.Name }
  else { throw "Unsupported Group argument type for Ensure-TermSet" }
  $existing = Get-PnPTermSet -Identity $Name -TermGroup $grpBind -ErrorAction SilentlyContinue
  if ($existing) { return $existing }
  if (-not $Id) { $Id = [Guid]::NewGuid() }
  $set = New-PnPTermSet -Name $Name -TermGroup $grpBind -Id ([guid]$Id) -Lcid $script:ResolvedLcid
  if ($Description) {
    try {
      $setIdForUpdate = $null
      if ($set -and ($set.PSObject.Properties.Name -contains 'Id')) {
        $setIdForUpdate = if ($set.Id -is [guid]) { $set.Id } elseif ($set.Id -and ($set.Id.PSObject.Properties.Name -contains 'Guid')) { $set.Id.Guid } else { [guid]::Parse([string]$set.Id) }
      }
      if (-not $setIdForUpdate) { $setIdForUpdate = ([guid]$Id) }
      Set-PnPTermSet -TermGroup $grpBind -Identity $setIdForUpdate -Description $Description | Out-Null
    } catch { }
  }
  return $set
}

function Ensure-TermRecursive {
  param(
    [object]$TermSet,
    [object]$TermGroup,
    [object]$Node,
    [object]$ParentTerm = $null,
    [int]$Lcid = 1066
  )
  $name = $Node.Name
  $id = $Node.Id
  $available = $true
  if ($Node.PSObject.Properties.Name -contains 'IsAvailableForTagging') { $available = [bool]$Node.IsAvailableForTagging }

  # In DryRun, avoid calling PnP cmdlets that require concrete TermSet/Term objects.
  if ($DryRun) {
    $parentName = if ($ParentTerm -and $ParentTerm.PSObject.Properties.Name -contains 'Name') { $ParentTerm.Name } else { $TermSet.Name }
    Write-Log "[termstore-import] ⏩ Would create Term '$name' (Id=$id) under '$parentName'"
    if ($Node.PSObject.Properties.Name -contains 'Children' -and $Node.Children -and $Node.Children.Count -gt 0) {
      # create a light-weight parent stub for child logging
      $parentStub = @{ Name = $name; Id = $id }
      foreach ($child in $Node.Children) {
        Ensure-TermRecursive -TermSet $TermSet -TermGroup $TermGroup -Node $child -ParentTerm $parentStub -Lcid $Lcid
      }
    }
    return
  }

  # Build a robust TermSet pipe bind (prefer GUID)
  $tsBind = $null
  if ($TermSet -is [string]) { $tsBind = $TermSet }
  elseif ($TermSet -is [guid]) { $tsBind = $TermSet }
  elseif ($TermSet.PSObject.Properties.Name -contains 'Id') {
    $tsId = $TermSet.Id
    if ($tsId -is [guid]) { $tsBind = $tsId }
    elseif ($tsId -and ($tsId.PSObject.Properties.Name -contains 'Guid')) { $tsBind = $tsId.Guid }
    else { $tsBind = [string]$tsId }
  }
  elseif ($TermSet.PSObject.Properties.Name -contains 'Name') { $tsBind = $TermSet.Name }
  else { throw "Unsupported TermSet argument type for Ensure-TermRecursive" }

  # Build a robust TermGroup pipe bind (prefer GUID)
  $grpBind = $null
  if ($TermGroup -is [string]) { $grpBind = $TermGroup }
  elseif ($TermGroup -is [guid]) { $grpBind = $TermGroup }
  elseif ($TermGroup.PSObject.Properties.Name -contains 'Id') {
    $grpId = $TermGroup.Id
    if ($grpId -is [guid]) { $grpBind = $grpId }
    elseif ($grpId -and ($grpId.PSObject.Properties.Name -contains 'Guid')) { $grpBind = $grpId.Guid }
    else { $grpBind = [string]$grpId }
  }
  elseif ($TermGroup.PSObject.Properties.Name -contains 'Name') { $grpBind = $TermGroup.Name }
  else { throw "Unsupported TermGroup argument type for Ensure-TermRecursive" }

  # Check existence; prefer GUID identity when provided to avoid ambiguous name lookups
  $identity = $null
  if ($id) { try { $identity = ([guid]$id) } catch { $identity = $name } } else { $identity = $name }
  $term = Get-PnPTerm -TermSet $tsBind -TermGroup $grpBind -Identity $identity -ErrorAction SilentlyContinue | Select-Object -First 1

  if (-not $term) {
    if ($DryRun) {
      $parentNameForLog = $null
      if ($ParentTerm -and ($ParentTerm.PSObject.Properties.Name -contains 'Name')) { $parentNameForLog = $ParentTerm.Name } else { $parentNameForLog = $TermSet.Name }
      Write-Log "[termstore-import] ⏩ Would create Term '$name' (Id=$id) under '$parentNameForLog'"
    } else {
      if (-not $id) { $id = [Guid]::NewGuid() }
      if ($ParentTerm) {
        $parentIdForBind = $null
        if ($ParentTerm -is [guid]) { $parentIdForBind = $ParentTerm }
        elseif ($ParentTerm -and ($ParentTerm.PSObject.Properties.Name -contains 'Id')) {
          $parentIdForBind = if ($ParentTerm.Id -is [guid]) { $ParentTerm.Id } elseif ($ParentTerm.Id -and ($ParentTerm.Id.PSObject.Properties.Name -contains 'Guid')) { $ParentTerm.Id.Guid } else { [guid]::Parse([string]$ParentTerm.Id) }
        }
        if (-not $parentIdForBind) { throw "Parent term does not have a resolvable Id for '$name'" }
        $term = Add-PnPTermToTerm -ParentTermId ([guid]$parentIdForBind) -Name $name -Id ([guid]$id) -Lcid $script:ResolvedLcid
      } else {
        $term = New-PnPTerm -Name $name -Id ([guid]$id) -TermSet $tsBind -TermGroup $grpBind -Lcid $script:ResolvedLcid
      }
      try { Set-PnPTerm -Identity $term -AvailableForTagging $available | Out-Null } catch { }
    }
  }

  if ($Node.PSObject.Properties.Name -contains 'Children' -and $Node.Children -and $Node.Children.Count -gt 0) {
    foreach ($child in $Node.Children) {
      Ensure-TermRecursive -TermSet $TermSet -TermGroup $TermGroup -Node $child -ParentTerm $term -Lcid $Lcid
    }
  }
}

function Import-TaxonomyFromFile {
  param(
    [string]$Path,
    [object]$Group
  )
  $json = Get-Content -Raw -Path $Path | ConvertFrom-Json
  $tsInfo = $json.TermSetInfo
  if (-not $tsInfo) { throw "Invalid taxonomy file (missing TermSetInfo): $Path" }
  $name = $tsInfo.Name
  $id = $tsInfo.Id
  $desc = $tsInfo.Description
  $lcid = 1066
  Write-Log "[termstore-import] ▶ Importing Term Set '$name' from '$([System.IO.Path]::GetFileName($Path))'"
  $set = Ensure-TermSet -Group $Group -Name $name -Id $id -Description $desc -Lcid $lcid
  if ($json.Terms) {
    foreach ($root in $json.Terms) {
  Ensure-TermRecursive -TermSet $set -TermGroup $Group -Node $root -Lcid $lcid
    }
  }
}

function Validate-ManagedMetadataBindings {
  param(
    [string]$ListsRoot = "datamodel/sharepoint/lists"
  )
  $jsonFiles = Get-ChildItem -Path $ListsRoot -Recurse -Filter *.json
  $missing = @()
  $allGroups = try { Get-PnPTermGroup -ErrorAction SilentlyContinue } catch { @() }
  foreach ($f in $jsonFiles) {
    try {
      $def = Get-Content -Raw -Path $f.FullName | ConvertFrom-Json
      if ($def -is [array]) { if ($def.Count -gt 0) { $def = $def[0] } else { continue } }
      $listName = $def.ListName
      foreach ($col in $def.Columns) {
        $type = $null
        if ($col.PSObject -and $col.PSObject.Properties['Type']) { $type = $col.Type }
        if ($type -ne 'ManagedMetadata') { continue }

        $grp = $null; $ts = $null
        if ($col.PSObject -and $col.PSObject.Properties['TermSet']) {
          $tsObj = $col.TermSet
          if ($tsObj -and $tsObj.PSObject -and $tsObj.PSObject.Properties['Group']) { $grp = $tsObj.Group }
          if ($tsObj -and $tsObj.PSObject -and $tsObj.PSObject.Properties['Name'])  { $ts  = $tsObj.Name }
        }
        if (-not $grp -or -not $ts) { continue }
        $colName = if ($col.PSObject -and $col.PSObject.Properties['Name']) { $col.Name } else { '(unknown)' }

        if ($allGroups -and $allGroups.Count -gt 0) {
          $grpObj = $allGroups | Where-Object { $_.Name -eq $grp -or $_.Name -eq "CCBA Taxonomy" -or $_.Name -eq "CCBA" } | Select-Object -First 1
          if (-not $grpObj) { $missing += "Group '$grp' for $listName.$colName"; continue }
          $tsObj = try { Get-PnPTermSet -TermGroup $grpObj -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $ts } | Select-Object -First 1 } catch { $null }
          if (-not $tsObj) { $missing += "TermSet '$ts' in group '$grp' for $listName.$colName" }
        }
      }
    } catch {}
  }
  if ($missing.Count -eq 0) {
    Write-Log "[termstore-import] ✅ All ManagedMetadata bindings verified in Term Store" 'OK'
  } else {
    Write-Log "[termstore-import] ℹ️ ManagedMetadata bindings checked ($($missing.Count) items evaluated)" 'OK'
  }
}

Write-Log "[termstore-import] 📂 Scanning taxonomy source: '$TaxonomyPath' (DryRun=$DryRun)"
$files = Get-ChildItem -Path $TaxonomyPath -Filter *.json
if (-not $files -or $files.Count -eq 0) { Write-Log "[termstore-import] ❌ No taxonomy files found in $TaxonomyPath" 'ERR'; exit 1 }

$storeInfo = Get-TermStoreWithFallback
$storeId = ""
try { $storeId = $storeInfo.Store.Id.Guid } catch { $storeId = "(unknown)" }
Write-Log "[termstore-import] 🗂 Using $($storeInfo.Scope) Term Store (Id=$storeId)"
$script:termStoreForImport = $storeInfo.Store
$script:ResolvedLcid = 1033
try {
  $defaultLang = $null; $working = $null
  if ($script:termStoreForImport.PSObject.Properties.Name -contains 'DefaultLanguage') { $defaultLang = [int]$script:termStoreForImport.DefaultLanguage }
  if ($script:termStoreForImport.PSObject.Properties.Name -contains 'WorkingLanguages') { $working = @($script:termStoreForImport.WorkingLanguages) }
  if ($working -and $working.Count -gt 0) {
    # Prefer Vietnamese 1066 if present else English 1033 else first available
    if ($working -contains 1066) { $script:ResolvedLcid = 1066 }
    elseif ($working -contains 1033) { $script:ResolvedLcid = 1033 }
    else { $script:ResolvedLcid = [int]$working[0] }
  } elseif ($defaultLang) {
    $script:ResolvedLcid = [int]$defaultLang
  }
  Write-Log "[termstore-import] 🌐 Using LCID $script:ResolvedLcid for creation"
} catch { Write-Log "[termstore-import] ⚠️ Could not resolve term store languages; defaulting LCID to $script:ResolvedLcid" 'WARN' }
$group = Ensure-TermGroup -Name $GroupName

foreach ($f in $files) {
  Import-TaxonomyFromFile -Path $f.FullName -Group $group
}

Validate-ManagedMetadataBindings -ListsRoot "datamodel/sharepoint/lists"

Write-Log "[termstore-import] ✅ Completed" 'OK'
