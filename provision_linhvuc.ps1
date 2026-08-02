
Get-Content 'd:\idop-ccba-way\.env' | ForEach-Object {
    if ($_ -match '^([^#=]+)=(.*)$') {
        Set-Item "Env:$($Matches[1].Trim())" $Matches[2].Trim()
    }
}
$tenant = $env:IDOP_SP_TENANT
$clientId = $env:IDOP_SP_CLIENT_ID
$certPath = $env:IDOP_SP_CERT_PATH
$certPwd  = $env:IDOP_SP_CERT_PASSWORD
$secPwd = ConvertTo-SecureString $certPwd -AsPlainText -Force

Import-Module PnP.PowerShell -Force
$conn = Connect-PnPOnline -Url "https://ibstbim-admin.sharepoint.com" -ClientId $clientId -Tenant $tenant -CertificatePath $certPath -CertificatePassword $secPwd -ReturnConnection

$group = Get-PnPTermGroup -Connection $conn | Where-Object { $_.Name -eq "CCBA Taxonomy" } | Select-Object -First 1
$ts = Get-PnPTermSet -TermGroup $group -Connection $conn | Where-Object { $_.Name -eq "CCBA_LinhVucChuyenMon" -or $_.Id.Guid -eq [guid]"475c9e75-3153-479a-8cfb-c7fb5037d46e" }

if (-not $ts) {
    Write-Host "Creating TermSet CCBA_LinhVucChuyenMon..."
    $ts = New-PnPTermSet -Name "CCBA_LinhVucChuyenMon" -TermGroup $group -Id "475c9e75-3153-479a-8cfb-c7fb5037d46e" -Lcid 1033 -Connection $conn
}

$data = Get-Content "d:\idop-ccba-way\datamodel\sharepoint\taxonomy\CCBA_LinhVucChuyenMon.json" -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "Creating 8 Root Terms and Child Terms into CCBA_LinhVucChuyenMon via CSOM..." -ForegroundColor Cyan

function Create-TermsRecursively($termsData, $parentObj) {
    foreach ($t in $termsData) {
        $tName = $t.Name
        $tId = [guid]$t.Id
        Write-Host "  Creating term: $tName ($tId)..." -ForegroundColor Yellow
        $termObj = $null
        if ($parentObj -eq $null) {
            $termObj = $ts.CreateTerm($tName, 1033, $tId)
        } else {
            $termObj = $parentObj.CreateTerm($tName, 1033, $tId)
        }
        
        if ($t.CustomProperties) {
            foreach ($p in $t.CustomProperties.PSObject.Properties) {
                $termObj.SetCustomProperty($p.Name, [string]$p.Value)
            }
        }
        
        if ($t.Children) {
            Create-TermsRecursively $t.Children $termObj
        }
    }
}

Create-TermsRecursively $data.Terms $null

$conn.Context.ExecuteQuery()

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " SUCCESS: PROVISIONED ALL 8 ROOT GROUPS AND CHILDREN!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
