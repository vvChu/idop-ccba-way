# Populate Vietnamese DisplayName fields for SharePoint list JSONs
param(
  [string]$ListsRoot = "datamodel/sharepoint/lists",
  [string]$Module,                    # e.g., strategy_crm | process_execution | people_assets | cash_data | performance_okrs | system_governance
  [string]$OnlyLists                  # comma-separated list names to limit updates
)

$ErrorActionPreference = 'Stop'

# Re-exec in PowerShell 7 for UTF-8 correctness
if (-not $PSVersionTable.PSEdition -or $PSVersionTable.PSEdition -ne 'Core' -or $PSVersionTable.PSVersion.Major -lt 7) {
  Write-Host "[vn-display] Detected Windows PowerShell $($PSVersionTable.PSVersion). Re-running under PowerShell 7..." -ForegroundColor Yellow
  $pwshCmd = $null
  try { $pwshCmd = (Get-Command pwsh -ErrorAction Stop).Source } catch {}
  if (-not $pwshCmd) { Write-Host "[vn-display] Please install PowerShell 7.4.6+" -ForegroundColor Red; exit 5 }
  $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSCommandPath")
  foreach ($k in $PSBoundParameters.Keys) { $v = $PSBoundParameters[$k]; $argList += "-$k"; if ($null -ne $v -and $v -ne $true) { $argList += "$v" } }
  & $pwshCmd @argList; exit $LASTEXITCODE
}

# Resolve repo root and input path
try { $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path } catch { $repoRoot = (Get-Location).Path }
if (-not (Test-Path -LiteralPath $ListsRoot)) { $candidate = Join-Path $repoRoot $ListsRoot; if (Test-Path -LiteralPath $candidate) { $ListsRoot = $candidate } }
Write-Host "[vn-display] ListsRoot: $ListsRoot" -ForegroundColor Cyan

# Translation dictionary for common internal column names
$dict = @{
  # Generic
  'Title' = 'Tiêu đề'
  'Customer' = 'Khách hàng'
  'Contact' = 'Liên hệ'
  'Owner' = 'Người phụ trách'
  'Status' = 'Trạng thái'
  'Value' = 'Giá trị'
  'Probability' = 'Xác suất'
  'AdjustedProbability' = 'Xác suất điều chỉnh'
  'InfluenceScore' = 'Điểm ảnh hưởng'
  'RiskFlags' = 'Cờ rủi ro'
  'ServiceType' = 'Loại hình dịch vụ'
  'Industry' = 'Ngành/Lĩnh vực'
  'Source' = 'Nguồn'
  'RelatedContracts' = 'Hợp đồng liên quan'
  'RelatedProjects' = 'Dự án liên quan'
  'ExpectedCloseDate' = 'Ngày dự kiến chốt'
  'ServiceMixSummary' = 'Tổng hợp dịch vụ'
  'Stage' = 'Giai đoạn'
  'DecisionDate' = 'Ngày quyết định'
  'DecisionNote' = 'Ghi chú quyết định'
  'DecisionEmailLink' = 'Liên kết email quyết định'
  # Opportunities / bidding
  'OpportunityName' = 'Tên cơ hội'
  'BiddingFolderDriveItemId' = 'ID mục thư mục Hồ sơ thầu'
  'BiddingFolderUrl' = 'URL thư mục Hồ sơ thầu'
  'BiddingFolderPath' = 'Đường dẫn thư mục Hồ sơ thầu'
  'BiddingFolderState' = 'Trạng thái thư mục Hồ sơ thầu'
  'BiddingFolderPhase' = 'Pha thư mục Hồ sơ thầu'
  'BiddingCode' = 'Mã hồ sơ thầu'
  'BidTeam' = 'Nhóm dự thầu'
  'ParticipationDecision' = 'Quyết định tham gia'
  'PotentialProject' = 'Tiềm năng dự án'
  # PotentialProjects
  'ExpectedContractValue' = 'Giá trị HĐ dự kiến'
  'ProjectType' = 'Loại công trình'
  'Priority' = 'Mức độ ưu tiên'
  'EstimatedStart' = 'Ngày bắt đầu dự kiến'
  'EstimatedEnd' = 'Ngày kết thúc dự kiến'
  'PMOOwner' = 'Quản trị PMO'
  # CDEDocuments
  'Project' = 'Dự án'
  'ProjectCode' = 'Mã dự án'
  'DocumentCode' = 'Mã tài liệu'
  'DocumentType' = 'Loại tài liệu'
  'Discipline' = 'Chuyên ngành'
  'Version' = 'Phiên bản'
  'FileUrl' = 'Liên kết tệp'
  'Submission' = 'Hồ sơ nộp'
  'RetentionUntil' = 'Lưu đến ngày'
}

function Add-DisplayNames {
  param([string]$FilePath,[hashtable]$OnlySet)
  try { $json = Get-Content -Raw -Path $FilePath -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop } catch { Write-Host "[vn-display] (skip) JSON parse error: $FilePath" -ForegroundColor DarkYellow; return }
  if (-not $json.ListName) { return }
  if ($OnlySet -and -not $OnlySet.ContainsKey($json.ListName)) { return }
  $changed = $false
  foreach ($col in $json.Columns) {
    if ($null -eq $col.DisplayName -or [string]::IsNullOrWhiteSpace([string]$col.DisplayName)) {
      $name = [string]$col.Name
      if ($dict.ContainsKey($name)) {
        $col | Add-Member -NotePropertyName DisplayName -NotePropertyValue $dict[$name] -Force
        $changed = $true
        Write-Host "[vn-display] ${json.ListName}/${name} -> '${($dict[$name])}'" -ForegroundColor DarkGreen
      }
    }
  }
  if ($changed) {
    # Persist with 2-space indentation for readability
    $json | ConvertTo-Json -Depth 8 -Compress:$false | Set-Content -LiteralPath $FilePath -Encoding UTF8
  }
}

# Build OnlySet if provided
$onlySet = $null
if ($OnlyLists -and $OnlyLists.Trim()) {
  $onlySet = @{}
  foreach ($n in ($OnlyLists -split ',' | ForEach-Object { $_.Trim() })) { if ($n) { $onlySet[$n] = $true } }
}

# Pick directories
$targets = @()
if ($Module) {
  $mPath = Join-Path $ListsRoot $Module
  if (Test-Path -LiteralPath $mPath) { $targets += (Resolve-Path $mPath).Path } else { Write-Host "[vn-display] Module path not found: $mPath" -ForegroundColor Yellow }
} else {
  $targets = (Get-ChildItem -Directory -Path $ListsRoot | ForEach-Object { $_.FullName })
}

$files = 0
foreach ($dir in $targets) {
  $jsonFiles = Get-ChildItem -Path $dir -Filter *.json -File
  foreach ($f in $jsonFiles) { Add-DisplayNames -FilePath $f.FullName -OnlySet $onlySet; $files++ }
}
Write-Host "[vn-display] Processed $files file(s)." -ForegroundColor Cyan
