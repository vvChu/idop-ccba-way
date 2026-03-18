param(
  [string]$SchemaDir = "datamodel/sharepoint/schemas",
  [string]$ListsPath = "datamodel/sharepoint/lists"
)

Write-Host "[validate-sp-schemas] Validating lists in '$ListsPath' against schemas in '$SchemaDir'" -ForegroundColor Yellow

# Find schema files
$schemaFiles = Get-ChildItem -Path $SchemaDir -Filter *.json
if ($schemaFiles.Count -eq 0) {
  Write-Host "[ERROR] No schema files found in $SchemaDir" -ForegroundColor Red
  exit 1
}

$allValid = $true
foreach ($schemaFile in $schemaFiles) {
  $schemaPath = $schemaFile.FullName
  Write-Host "[validate] Using schema: $schemaPath" -ForegroundColor Cyan

  # Validate all JSON files in ListsPath against this schema
  foreach ($jsonFile in Get-ChildItem -Path $ListsPath -Recurse -Filter *.json) {
    Write-Host "  Validating: $($jsonFile.FullName)" -ForegroundColor Gray
    
    # Use ajv if available, otherwise basic JSON validation
    if (Get-Command ajv -ErrorAction SilentlyContinue) {
      $ajvCmd = "ajv validate -s `"$schemaPath`" -d `"$($jsonFile.FullName)`""
      Invoke-Expression $ajvCmd 2>$null
      if ($LASTEXITCODE -ne 0) {
        Write-Host "    [ERROR] Validation failed" -ForegroundColor Red
        $allValid = $false
      } else {
        Write-Host "    [OK] Valid" -ForegroundColor Green
      }
    } else {
      # Fallback: basic JSON parsing
      try {
        $json = Get-Content $jsonFile.FullName | ConvertFrom-Json
        Write-Host "    [OK] JSON parsed successfully" -ForegroundColor Green
      } catch {
        Write-Host "    [ERROR] Invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
        $allValid = $false
      }
    }
  }
}

if ($allValid) {
  Write-Host "[validate] All validations passed." -ForegroundColor Green
  exit 0
} else {
  Write-Host "[ERROR] Some validations failed." -ForegroundColor Red
  exit 1
}
