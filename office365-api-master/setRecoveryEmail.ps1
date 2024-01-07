$logFile = "C:\o365\Log\historyAccount-ms.txt"

. "$PSScriptRoot\connectO365.ps1"

Clear-Host
Write-Host "---------------------------- SETAR EMAIL DE RECUPERACAO -----------------------------" -ForegroundColor Cyan

$MailNickName = $args[0]
$OtherMails = $args[1]

if ($MailNickName.Length -lt 2 -or ($OtherMails -notmatch "@" ) )  {
    # Write-Warning "Usuario invalido";
    Write-Warning "Usage .\setRecoveryEmail.ps1 <iniciais> <email_secundario>";
    break}

# Consulta se o usuario existe
$UMNN = (Get-AzureADUser -Filter "MailNickName eq '$MailNickName'")
$UObjID = $UMNN.ObjectID
$CurrentOtherMails = $UUPN.OtherMails

if ($UObjID.Length -lt 30) {                    
    Write-Host "Usuario $MailNickName nao existe" -ForegroundColor Yellow ;
    break} 

if ($CurrentOtherMails -match "@") {
    Write-host "Usuario $UserPrincipalName ignorado, ja possui email de recuperacao $CurrentOtherMails " -ForegroundColor Yellow            
} else {
    Write-host "Setando email recuperacao $OtherMails para usuario $MailNickName" -ForegroundColor Green
    Set-AzureADUser -ObjectId $UObjID -OtherMails $OtherMails

    $GetInfo = Get-AzureADUser -ObjectId $UObjID
    # Adiciona a data corrente no arquivo de log
    Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss ") -NoNewline
    # Consulta o usuario criado pelo ObjectID e armazena resultado
    $GetInfo | Format-Table UserPrincipalName, DisplayName, OtherMails, ObjectId, @{L='AE';E={$_.AccountEnabled}} -HideTableHeaders | Out-File -FilePath $logFile -Append -Encoding utf8 -NoNewline
    # Adiciona um espaco na ultima linha por questao de formatacao                    
    Add-Content -Path $logFile -Value " "
}
    
Write-Host ('-' * 70)

Disconnect-AzureAD