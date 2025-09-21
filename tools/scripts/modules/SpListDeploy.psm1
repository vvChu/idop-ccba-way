
<#!
Module: SpListDeploy
Purpose: Encapsulate SharePoint list deployment & diff/sync logic.
Status: First extraction pass (2025-09-18). ToDo (next passes):
    - Introduce structured diff codes (DIFF_NEW, DIFF_REQUIRED, DIFF_LOOKUP, DIFF_TERMSET, DIFF_CHOICES)
    - Centralize logging & warnings
    - Add validation harness helpers
#>

function Test-ListDependency {
    param([string]$ListName)
    try { return (Get-PnPList -Identity $ListName -ErrorAction SilentlyContinue) -ne $null } catch { return $false }
}

function Add-SharePointField {
    param(
        [string]$ListName,
        [object]$FieldDef,
        [switch]$DryRun,
        [switch]$Diff,
        [switch]$SyncChoices
    )
    $fieldName = $FieldDef.Name
    $fieldType = $FieldDef.Type
    $isRequired = $FieldDef.Required -eq $true

    if ($DryRun) { Write-Host "    📋 [DRY-RUN] Sẽ tạo field: $fieldName ($fieldType)" -ForegroundColor Yellow; return $true }

    try {
        $existingField = Get-PnPField -List $ListName -Identity $fieldName -ErrorAction SilentlyContinue
        if ($existingField) {
            if ($Diff) {
                $diffs = @()
                $statusCodes = @()
                # New field detection (if field does not exist, handled outside)
                # Required flag
                if ($FieldDef.PSObject.Properties.Name -contains 'Required') {
                    $currentRequired = $existingField.Required
                    if (([bool]$FieldDef.Required) -ne $currentRequired) {
                        $diffs += "DIFF_REQUIRED: $currentRequired -> $($FieldDef.Required)"
                        $statusCodes += 'DIFF_REQUIRED'
                    }
                }
                # Lookup target
                if ($fieldType -eq 'Lookup' -and $FieldDef.Lookup) {
                    try {
                        $xml = [xml]$existingField.SchemaXml
                        $existingListId = $xml.Field.List
                        $targetList = $FieldDef.Lookup.List
                        if (Test-ListDependency -ListName $targetList) {
                            $targetListObj = Get-PnPList -Identity $targetList
                            if ($existingListId -and $existingListId -notmatch $targetListObj.Id.Guid) {
                                $diffs += "DIFF_LOOKUP: $existingListId -> {$($targetListObj.Id.Guid)}"
                                $statusCodes += 'DIFF_LOOKUP'
                            }
                        }
                    } catch { $diffs += "DIFF_LOOKUP: (schema error)"; $statusCodes += 'DIFF_LOOKUP' }
                }
                # Managed Metadata TermSet
                if ($fieldType -eq 'ManagedMetadata' -and $FieldDef.TermSet) {
                    try {
                        $xml = [xml]$existingField.SchemaXml
                        $existingTermSetId = ($xml.Field.Customization.ArrayOfProperty.Property | Where-Object { $_.Name -eq 'TermSetId' }).Value.'#text'
                        # Only attempt deep termset diff when taxonomy cmdlets are available
                        if (Get-Command -Name Get-PnPTermStore -ErrorAction SilentlyContinue) {
                            $termStore = Get-PnPTermStore
                            $termGroupObj = Get-PnPTermGroup -TermStore $termStore.Id | Where-Object { $_.Name -eq $FieldDef.TermSet.Group }
                            if ($termGroupObj) {
                                $termSetObj = Get-PnPTermSet -TermGroup $termGroupObj.Id | Where-Object { $_.Name -eq $FieldDef.TermSet.Name }
                                if ($termSetObj -and $existingTermSetId -and $existingTermSetId -notmatch $termSetObj.Id.Guid) {
                                    $diffs += "DIFF_TERMSET: $existingTermSetId -> {$($termSetObj.Id.Guid)}"
                                    $statusCodes += 'DIFF_TERMSET'
                                }
                            }
                        } else {
                            Write-Host "    ℹ️ TermStore cmdlets unavailable — skip termset diff for '$fieldName'" -ForegroundColor Gray
                        }
                    } catch { $diffs += "DIFF_TERMSET: (schema error)"; $statusCodes += 'DIFF_TERMSET' }
                }
                # Choice deltas
                if ($fieldType -in @('Choice','MultiChoice') -and $FieldDef.Choices) {
                    try {
                        $xml = [xml]$existingField.SchemaXml
                        $existingChoices = @($xml.Field.CHOICES.CHOICE | ForEach-Object { $_.InnerText })
                        $added = $FieldDef.Choices | Where-Object { $_ -notin $existingChoices }
                        $removed = $existingChoices | Where-Object { $_ -notin $FieldDef.Choices }
                        if ($added.Count -gt 0) { $diffs += "DIFF_CHOICES: +" + ($added -join ', ') ; $statusCodes += 'DIFF_CHOICES' }
                        if ($removed.Count -gt 0) { $diffs += "DIFF_CHOICES: -" + ($removed -join ', ') ; $statusCodes += 'DIFF_CHOICES' }
                    } catch { $diffs += "DIFF_CHOICES: (schema error)"; $statusCodes += 'DIFF_CHOICES' }
                }
                if ($diffs.Count -gt 0) {
                    Write-Host ("    🔍 " + ($statusCodes | Sort-Object -Unique | ForEach-Object { $_ }) -join ' ' + " Field '$fieldName': $($diffs -join ' | ')" ) -ForegroundColor Yellow
                } else {
                    Write-Host "    ✅ Field '$fieldName' không khác biệt" -ForegroundColor DarkGray
                }
            }
            if ($SyncChoices -and $fieldType -in @('Choice','MultiChoice') -and $FieldDef.Choices) {
                try {
                    $xml = [xml]$existingField.SchemaXml
                    $existingChoices = @($xml.Field.CHOICES.CHOICE | ForEach-Object { $_.InnerText })
                    $needUpdate = $false
                    if ($existingChoices.Count -ne $FieldDef.Choices.Count -or (@($existingChoices | Where-Object { $_ -notin $FieldDef.Choices }).Count -gt 0) -or (@($FieldDef.Choices | Where-Object { $_ -notin $existingChoices }).Count -gt 0)) { $needUpdate = $true }
                    if ($needUpdate) {
                        $choicesXml = ($FieldDef.Choices | ForEach-Object { "<CHOICE>$_</CHOICE>" }) -join ''
                        $multi = if ($fieldType -eq 'MultiChoice') { 'MultiChoice' } else { 'Choice' }
                        $fieldXml = @"
<Field Type="$multi" Name="$fieldName" DisplayName="$fieldName" Required="$($isRequired.ToString().ToUpper())">
    <CHOICES>$choicesXml</CHOICES>
</Field>
"@
                        Set-PnPField -Identity $fieldName -List $ListName -Values @{ SchemaXml = $fieldXml } 2>$null
                        Write-Host "    ♻️ Đã đồng bộ Choices cho field '$fieldName'" -ForegroundColor Magenta
                    } else { Write-Host "    ℹ️ Choices field '$fieldName' đã khớp — không cần sync" -ForegroundColor Gray }
                } catch { Write-Host "    ⚠️ Không thể sync choices cho '$fieldName': $($_.Exception.Message)" -ForegroundColor Yellow }
            }
            if (-not $Diff -and -not $SyncChoices) { Write-Host "    ℹ️ Field '$fieldName' đã tồn tại. Bỏ qua (idempotent)." -ForegroundColor Gray }
            return $true
        }

        Write-Host "    ➕ Tạo field: $fieldName ($fieldType)" -ForegroundColor DarkGreen
        switch ($fieldType) {
            'Text' { Add-PnPField -List $ListName -Type Text -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'Note' { Add-PnPField -List $ListName -Type Note -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'Number' { Add-PnPField -List $ListName -Type Number -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'DateTime' { Add-PnPField -List $ListName -Type DateTime -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'Choice' {
                if ($FieldDef.Choices -and $FieldDef.Choices.Count -gt 0) {
                    $choicesXml = ($FieldDef.Choices | ForEach-Object { "<CHOICE>$_</CHOICE>" }) -join ''
                    $defaultChoice = if ($FieldDef.Choices[0]) { $FieldDef.Choices[0] } else { '' }
                    $fieldXml = @"
<Field Type="Choice" Name="$fieldName" DisplayName="$fieldName" Required="$($isRequired.ToString().ToUpper())">
  <CHOICES>$choicesXml</CHOICES>
  <Default>$defaultChoice</Default>
</Field>
"@
                    Add-PnPFieldFromXml -List $ListName -FieldXml $fieldXml
                } else { Write-Host "      ⚠️ Choice field '$fieldName' không có Choices - bỏ qua" -ForegroundColor Yellow; return $false }
            }
            'MultiChoice' {
                if ($FieldDef.Choices -and $FieldDef.Choices.Count -gt 0) {
                    $choicesXml = ($FieldDef.Choices | ForEach-Object { "<CHOICE>$_</CHOICE>" }) -join ''
                    $fieldXml = @"
<Field Type="MultiChoice" Name="$fieldName" DisplayName="$fieldName" Required="$($isRequired.ToString().ToUpper())">
  <CHOICES>$choicesXml</CHOICES>
</Field>
"@
                    Add-PnPFieldFromXml -List $ListName -FieldXml $fieldXml
                } else { Write-Host "      ⚠️ MultiChoice field '$fieldName' không có Choices - bỏ qua" -ForegroundColor Yellow; return $false }
            }
            'User' { Add-PnPField -List $ListName -Type User -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'URL' { Add-PnPField -List $ListName -Type URL -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'Currency' { Add-PnPField -List $ListName -Type Currency -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'YesNo' { Add-PnPField -List $ListName -Type Boolean -InternalName $fieldName -DisplayName $fieldName -Required:$isRequired }
            'Lookup' {
                if ($FieldDef.Lookup) {
                    $targetList = $FieldDef.Lookup.List
                    $targetField = if ($FieldDef.Lookup.Field) { $FieldDef.Lookup.Field } else { 'Title' }
                    if (Test-ListDependency -ListName $targetList) {
                        $targetListObj = Get-PnPList -Identity $targetList
                        $targetListId = $targetListObj.Id.Guid
                        $fieldXml = @"
<Field Type="Lookup" Name="$fieldName" DisplayName="$fieldName" Required="$($isRequired.ToString().ToUpper())" List="{$targetListId}" ShowField="$targetField" />
"@
                        Add-PnPFieldFromXml -List $ListName -FieldXml $fieldXml
                        Write-Host "      ✅ Lookup field '$fieldName' -> $targetList.$targetField" -ForegroundColor Green
                    } else { Write-Host "      ⚠️ Target list '$targetList' chưa tồn tại - sẽ tạo sau" -ForegroundColor Yellow; return $false }
                } else { Write-Host "      ⚠️ Lookup field '$fieldName' thiếu thông tin Lookup - bỏ qua" -ForegroundColor Yellow; return $false }
            }
            'ManagedMetadata' {
                if ($FieldDef.TermSet) {
                    $termGroup = $FieldDef.TermSet.Group; $termSet = $FieldDef.TermSet.Name
                    $termPath = "$termGroup|$termSet"
                    try {
                        if (Get-Command -Name Add-PnPTaxonomyField -ErrorAction SilentlyContinue) {
                            $isMulti = $false
                            if ($FieldDef.PSObject.Properties.Name -contains 'Multi') { $isMulti = [bool]$FieldDef.Multi }
                            Add-PnPTaxonomyField -List $ListName -DisplayName $fieldName -InternalName $fieldName -TermSetPath $termPath -MultiValue:$isMulti | Out-Null
                            if ($isRequired) {
                                try { Set-PnPField -List $ListName -Identity $fieldName -Values @{ Required = $true } | Out-Null } catch { }
                            }
                            Write-Host "      ✅ ManagedMetadata '$fieldName' liên kết TermSet '$termSet'" -ForegroundColor Green
                        } else {
                            Write-Host "      ❌ Cmdlet 'Add-PnPTaxonomyField' không có trong session - không thể tạo field MM" -ForegroundColor Red
                            return $false
                        }
                    } catch {
                        Write-Host "      ❌ Lỗi tạo field '$fieldName' (MM): $($_.Exception.Message)" -ForegroundColor Red
                        return $false
                    }
                } else { Write-Host "      ⚠️ ManagedMetadata field '$fieldName' thiếu TermSet info" -ForegroundColor Yellow; return $false }
            }
            default { Write-Host "      ❌ Field type '$fieldType' chưa được hỗ trợ" -ForegroundColor Red; return $false }
        }
        Write-Host "      ✅ Field '$fieldName' tạo thành công" -ForegroundColor Green
        return $true
    } catch { Write-Host "      ❌ Lỗi tạo field '$fieldName': $($_.Exception.Message)" -ForegroundColor Red; return $false }
}

function New-EnhancedSharePointList {
    param(
        [string]$JsonPath,
        [switch]$DryRun,
        [switch]$UpdateExisting,
        [switch]$Diff,
        [switch]$SyncChoices
    )
    try {
        $listDef = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $listName = $listDef.ListName; $listTitle = $listDef.ListName
        if ($DryRun) {
            Write-Host "  📋 [DRY-RUN] Sẽ xử lý list: $listTitle với $($listDef.Columns.Count) fields" -ForegroundColor Yellow
            foreach ($field in $listDef.Columns) { Add-SharePointField -ListName $listName -FieldDef $field -DryRun -Diff:$Diff -SyncChoices:$SyncChoices }
            return @{Success=$true; Created=$false; Updated=$false}
        }
        $existingList = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
        $listCreated = $false; $listUpdated = $false
        if (-not $existingList) { Write-Host "  🔨 Tạo list mới: $listTitle..." -ForegroundColor Yellow; New-PnPList -Title $listTitle -Template GenericList -Url "Lists/$listName"; $listCreated = $true }
        elseif ($UpdateExisting) { Write-Host "  🔄 Update list hiện có: $listTitle..." -ForegroundColor Cyan; $listUpdated = $true }
        else { Write-Host "  ℹ️ List '$listTitle' đã tồn tại. Sử dụng -UpdateExisting để update fields." -ForegroundColor Gray; return @{Success=$true; Created=$false; Updated=$false} }
        $fieldSuccessCount = 0; $fieldFailCount = 0
        if ($listDef.Columns) {
            foreach ($field in $listDef.Columns) {
                if ($field.Name -eq 'Title') { continue }
                $success = Add-SharePointField -ListName $listName -FieldDef $field -Diff:$Diff -SyncChoices:$SyncChoices
                if ($success) { $fieldSuccessCount++ } else { $fieldFailCount++ }
            }
        }
        $statusMsg = if ($listCreated) { 'tạo mới' } elseif ($listUpdated) { 'cập nhật' } else { 'xử lý' }
        Write-Host "  ✅ Hoàn thành $statusMsg list '$listTitle': $fieldSuccessCount fields OK, $fieldFailCount fields lỗi" -ForegroundColor Green
        try {
            $defaultView = Get-PnPView -List $listName -Identity 'All Items' -ErrorAction Stop
            $businessColumns = @(); if ($listDef.Columns) { foreach ($col in $listDef.Columns) { if ($col.Name -ne 'Title') { $businessColumns += $col.Name } } }
            $viewFields = @('Title') + $businessColumns
            Set-PnPView -List $listName -Identity $defaultView.Id -Fields $viewFields
            Write-Host "  ✅ Đã setup default view (All Items) cho list '$listTitle'" -ForegroundColor Cyan
        } catch { Write-Host "  ⚠️ Không thể setup default view cho list '$listTitle': $($_.Exception.Message)" -ForegroundColor Yellow }
        $formatMap = @{ Status='status-format.json'; ApprovalStatus='status-format.json'; Progress='progress-format.json'; Deadline='deadline-format.json'; DueDate='deadline-format.json'; IsActive='yesno-format.json'; IsCompleted='yesno-format.json'; Priority='choice-format.json'; Level='choice-format.json'; AssignedTo='user-format.json'; Owner='user-format.json' }
        $formatDir = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'list-formatting'
        foreach ($col in $listDef.Columns) {
            $colName = $col.Name
            if ($formatMap.ContainsKey($colName)) {
                $formatFile = Join-Path $formatDir $formatMap[$colName]
                if (Test-Path $formatFile) {
                    $jsonFormat = Get-Content $formatFile -Raw
                    try { Set-PnPColumnFormatting -List $listName -Identity $colName -Json $jsonFormat; Write-Host "  🎨 Format áp dụng: $colName" -ForegroundColor Magenta } catch { Write-Host "  ⚠️ Lỗi format ${colName}: $($_.Exception.Message)" -ForegroundColor Yellow }
                }
            }
        }
        return @{ Success=$true; Created=$listCreated; Updated=$listUpdated; FieldsSuccess=$fieldSuccessCount; FieldsFailed=$fieldFailCount }
    } catch { Write-Host "  ❌ Lỗi xử lý list từ $JsonPath`: $($_.Exception.Message)" -ForegroundColor Red; return @{Success=$false; Created=$false; Updated=$false} }
}

Export-ModuleMember -Function Test-ListDependency,Add-SharePointField,New-EnhancedSharePointList
