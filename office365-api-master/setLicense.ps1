# $licenseName = "STANDARDWOFFPACK_STUDENT"

if ($LicenseType -match '^student$' ) {
    $LicenseName = "STANDARDWOFFPACK_STUDENT";
    $LicenseDesc = "Office 365 A1 Students"
} elseif ($LicenseType -match '^lecturer$') {
        $LicenseName = "STANDARDWOFFPACK_FACULTY";
        $LicenseDesc = "Office 365 A1 Faculty"
  }

$license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
# Busca o SkuID da licenca
$license.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $LicenseName -EQ).SkuID                
$licenses.AddLicenses = $license

Write-Host "Setando licenca: $LicenseName - $LicenseDesc" -ForegroundColor Green
# Write-Host "Setando licenca: $LicenseName - Office 365 A1 Students" -ForegroundColor Green

Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses