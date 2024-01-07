$logFile = "C:\o365\Log\historyAccount-ms.txt"

. "$PSScriptRoot\connectO365.ps1"

Write-Host "--------------------------- DELETAR CONTAS ---------------------------" -ForegroundColor Cyan

$MailNickName = $args[0]
if ($MailNickName.Length -lt 2) {
    Write-Warning "Usuario invalido";
    Write-Warning "Usage .\deleteAccount.ps1 <login_user>";
    break }

# Consulta se o usuario existe
$UMNN = (Get-AzureADUser -Filter "MailNickName eq '$MailNickName'")
$UObjID = $UMNN.ObjectID

if ($UObjID.Length -lt 30) {                    
    Write-Host "Usuario $MailNickName nao existe" -ForegroundColor Yellow ;
    break}

# Remover todas as licenças antes de remover a conta               
$licensePlanList = Get-AzureADSubscribedSku
$userList = Get-AzureADUser -ObjectID $UObjID | Select -ExpandProperty AssignedLicenses | Select SkuID
if($userList.Count -ne 0) {
    if($userList -is [array]) {
        for ($i=0; $i -lt $userList.Count; $i++) {
        $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $license.SkuId = $userList[$i].SkuId
        $licenses.AddLicenses = $license
        Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses
        $Licenses.AddLicenses = @()
        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $userList[$i].SkuId -EQ).SkuID
        Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses
        }
    } else {
        $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $license.SkuId = $userList.SkuId
        $licenses.AddLicenses = $license
        Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses
        $Licenses.AddLicenses = @()
        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $userList.SkuId -EQ).SkuID

        Write-Host "Removendo Licencas" -ForegroundColor Green
        Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses
        }
}

Write-Host "Removendo conta usuario $MailNickName" -ForegroundColor Green
Remove-AzureADUser -ObjectId $UObjID

# Adicionar logs
# Adiciona a data corrente no arquivo de log
Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss ") -NoNewline
Add-Content -Value "$MailNickName deleted " -Path $logFile -NoNewline
Add-Content -Value "Licenses removed" -Path $logFile
                
Write-Host ('-' * 70)

Disconnect-AzureAD