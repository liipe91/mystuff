$logFile = "C:\o365\Log\historyAccount-ms.txt"

& $PSScriptRoot\connectO365.ps1

Clear-Host
Write-Host "---------------------------- REDEFINIR SENHA -----------------------------" -ForegroundColor Cyan

$MailNickName = $args[0]
if ($MailNickName.Length -lt 2) {
    Write-Warning "Usuario invalido";
    break }

$UUPN = (Get-AzureADUser -Filter "MailNickName eq '$MailNickName'")
$UserPrincipalName = $UUPN.UserPrincipalName
$DisplayName = $UUPN.DisplayName
$GivenName = $UUPN.GivenName        
$UObjID = $UUPN.ObjectID

if ($UObjID.Length -eq 0) {                    
    Write-Host "Usuario $MailNickName nao existe" -ForegroundColor Yellow ;
    break}

. "$PSScriptRoot\generatePass.ps1"
Write-host "Redefinindo senha" -ForegroundColor Green
Set-AzureADUserPassword -ObjectId $UObjID -Password $Global:UserPasswordS -ForceChangePasswordNextLogin $True

. "$PSScriptRoot\sendEmailLogin.ps1"

$GetInfo = Get-AzureADUser -ObjectId $UObjID
Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss ") -NoNewline
# Consulta o usuario criado pelo ObjectID e armazena resultado
$GetInfo | Format-Table UserPrincipalName, DisplayName, ObjectId, @{L='AE';E={$_.AccountEnabled}} -HideTableHeaders | Out-File -FilePath $logFile -Append -NoNewline -Encoding utf8
# Adiciona um espaco na ultima linha por questao de formatacao                    
Add-Content -Path $logFile -Value " " -NoNewline
# Consulta a licenca adicionada ao usuario e armazena o resultado
(Get-AzureADUserLicenseDetail -ObjectId $UObjID) | Select-Object -ExpandProperty SkuPartNumber | Out-File -FilePath $logFile -Append -NoNewline -Encoding utf8
# Adiciona um espaco na ultima linha por questao de formataçao
Add-Content -Path $logFile -Value " " -NoNewline
Add-Content -Path $logFile -Value $Global:UserPassword

Write-Host ('-' * 70)

Disconnect-AzureAD