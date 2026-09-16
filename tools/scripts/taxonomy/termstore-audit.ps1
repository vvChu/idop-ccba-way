param(
  [ValidateSet("Dev","Test","Prod","IDOP")]
  [string]$Environment = "Dev",
  [string]$ListsRoot = "datamodel/sharepoint/lists",
  [string]$TaxonomyPath = "datamodel/sharepoint/taxonomy",
  [string]$Output = "tools/output/logs/termstore-audit-$Environment.json"
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

Write-Log "[ts-audit] 🔗 Connecting to $siteUrl"
Connect-IDOPSharePoint -Environment $Environment
Write-Log "[ts-audit] ✅ Connected" 'OK'

function Get-TermStoreSafe {
  try { return Get-PnPTermStore -ErrorAction Stop } catch {
    Write-Log "[ts-audit] ℹ️ Falling back to Site Collection Term Store"; return Get-PnPSiteCollectionTermStore -ErrorAction Stop
  }
}

function Get-TaxonomyIndex {
  param([string]$TaxonomyPath)
  $index = @{}
  if (-not (Test-Path $TaxonomyPath)) { return $index }
  Get-ChildItem -Path $TaxonomyPath -Filter *.json | ForEach-Object {
    try {
      $j = Get-Content -Raw -Path $_.FullName | ConvertFrom-Json
      $group = $j.Group; $setName = $j.Name
      if ($group -and $setName) {
        if (-not $index.ContainsKey($group)) { $index[$group] = @{} }
        $index[$group][$setName] = $j
      }
    } catch { Write-Log "[ts-audit] ⚠️ Failed to parse taxonomy file: $($_.FullName): $($_.Exception.Message)" 'WARN' }
  }
  return $index
}

function Get-ExpectedMMUsage {
  param([string]$ListsRoot)
  $expected = @()
  $jsonFiles = Get-ChildItem -Path $ListsRoot -Recurse -Filter *.json
  foreach ($f in $jsonFiles) {
    try {
      $def = Get-Content -Raw -Path $f.FullName | ConvertFrom-Json
      $listName = $def.ListName
      foreach ($c in $def.Columns) {
        if ($c.Type -eq 'ManagedMetadata') {
          $expected += [pscustomobject]@{
            ListName     = $listName
            ColumnName   = $c.Name
            TermGroup    = $c.TermSet.Group
            TermSet      = $c.TermSet.Name
            SourceFile   = $f.FullName
          }
        }
      }
    } catch { Write-Log "[ts-audit] ⚠️ Failed to parse list file: $($f.FullName): $($_.Exception.Message)" 'WARN' }
  }
  return $expected
}

function Get-FieldTermBinding {
  param([string]$ListName, [string]$FieldInternalName)
  $field = Get-PnPField -List $ListName -Identity $FieldInternalName -Includes SchemaXml -ErrorAction SilentlyContinue
  if (-not $field) { return $null }
  $binding = @{}
  $binding.FieldType = $field.TypeAsString
  try {
    [xml]$xml = $field.SchemaXml
    $props = $xml.Field.Customization.ArrayOfProperty.Property
    if ($props) {
      foreach ($p in $props) {
        $name = $p.Name
        $val = $p.Value.'#text'
        if ($name -eq 'SspId') { $binding.SspId = $val }
        if ($name -eq 'TermSetId') { $binding.TermSetId = $val }
        if ($name -eq 'AnchorId') { $binding.AnchorId = $val }
      }
    }
  } catch {}
  return $binding
}

# Build live term store index
$liveGroups = @{}
Get-PnPTermGroup | ForEach-Object {
  $gName = $_.Name
  if (-not $liveGroups.ContainsKey($gName)) { $liveGroups[$gName] = @{} }
  Get-PnPTermSet -TermGroup $_ | ForEach-Object {
    $liveGroups[$gName][$_.Name] = $_.Id.Guid
  }
}

# Build expected from datamodel and local taxonomy JSONs
$expectedUsage = Get-ExpectedMMUsage -ListsRoot $ListsRoot
# Optional: local taxonomy definitions index (currently not used in summary)
# $localTaxIndex = Get-TaxonomyIndex -TaxonomyPath $TaxonomyPath

$report = [ordered]@{
  siteUrl = $siteUrl
  generatedAt = (Get-Date).ToString('s')
  summary = [ordered]@{
    expectedFields = $expectedUsage.Count
    missingTermGroups = 0
    missingTermSets = 0
    missingFields = 0
    wrongBindings = 0
    textInsteadOfMM = 0
    parallelMMPresent = 0
  }
  items = @()
  termGroups = $liveGroups
}

foreach ($item in $expectedUsage) {
  $groupExists = $liveGroups.ContainsKey($item.TermGroup)
  $setExists = $false
  $setId = $null
  if ($groupExists) {
    $setExists = $liveGroups[$item.TermGroup].ContainsKey($item.TermSet)
    if ($setExists) { $setId = $liveGroups[$item.TermGroup][$item.TermSet] }
  }

  if (-not $groupExists) { $report.summary.missingTermGroups++ }
  if ($groupExists -and -not $setExists) { $report.summary.missingTermSets++ }

  $fieldBinding = Get-FieldTermBinding -ListName $item.ListName -FieldInternalName $item.ColumnName
  $existsAsMM = $false
  $bindingOk = $false
  $hasParallelMM = $false
  $existsAsText = $false

  if ($fieldBinding) {
    $existsAsMM = ($fieldBinding.FieldType -like 'Taxonomy*')
    if ($existsAsMM -and $setId) {
      $bindingOk = ($fieldBinding.TermSetId -eq $setId)
    }
  } else {
    # No taxonomy field with exact name; check if Text exists and if parallel _MM exists
    $textField = Get-PnPField -List $item.ListName -Identity $item.ColumnName -ErrorAction SilentlyContinue
    if ($textField) {
      $existsAsText = ($textField.TypeAsString -in @('Text','Note','Choice','MultiChoice'))
    }
    $parallel = Get-FieldTermBinding -ListName $item.ListName -FieldInternalName ("{0}_MM" -f $item.ColumnName)
    if ($parallel) { $hasParallelMM = $true }
  }

  if (-not $fieldBinding -and -not $hasParallelMM) { $report.summary.missingFields++ }
  if ($existsAsText -and $hasParallelMM) { $report.summary.parallelMMPresent++ }
  if ($existsAsText -and -not $hasParallelMM) { $report.summary.textInsteadOfMM++ }
  if ($existsAsMM -and $setId -and -not $bindingOk) { $report.summary.wrongBindings++ }

  $report.items += [pscustomobject]@{
    list = $item.ListName
    column = $item.ColumnName
    expectedGroup = $item.TermGroup
    expectedSet = $item.TermSet
    expectedSetId = $setId
    groupExists = $groupExists
    setExists = $setExists
    fieldType = if ($fieldBinding) { $fieldBinding.FieldType } else { $null }
    boundTermSetId = if ($fieldBinding) { $fieldBinding.TermSetId } else { $null }
    bindingOk = $bindingOk
    existsAsText = $existsAsText
    hasParallelMM = $hasParallelMM
    source = $item.SourceFile
  }
}

# Ensure output directory
$outDir = Split-Path -Parent $Output
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$json = $report | ConvertTo-Json -Depth 6
Set-Content -Path $Output -Value $json -Encoding UTF8
Write-Log "[ts-audit] ✅ Audit saved: $Output" 'OK'

exit 0
