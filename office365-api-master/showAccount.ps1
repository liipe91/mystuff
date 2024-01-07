. "$PSScriptRoot\connectO365.ps1"

Clear-Host
Write-Host "---------------------------- INFORMACOES CONTA -----------------------------" -ForegroundColor Cyan

$MailNickName = $args[0]
if ($MailNickName.Length -lt 2) {
    Write-Warning "Usuario invalido";
    break }

# Consulta se o usuario existe
$UMNN = (Get-AzureADUser -Filter "MailNickName eq '$MailNickName'")
$UObjID = $UMNN.ObjectID

if ($UObjID.Length -lt 30) {                    
    Write-Host "Usuario $MailNickName nao existe" -ForegroundColor Yellow ;
    break}

$GetInfo = Get-AzureADUser -ObjectId $UObjID
$CreatedTime = @{Name = 'CreatedTime'; Expression = {$GetInfo.ExtensionProperty.createdDateTime}}
$EnabledLicenses = @{Name = 'EnabledLicenses'; Expression = {(Get-AzureADUserLicenseDetail -ObjectId $UObjID).skuPartNumber}}      

$GetInfo | Select-Object -Property UserPrincipalName, DisplayName, OtherMails, ObjectId, AccountEnabled, $CreatedTime, $EnabledLicenses

Disconnect-AzureAD