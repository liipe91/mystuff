$logFile = "C:\o365\Log\historyAccount-ms.txt"

. "$PSScriptRoot\connectO365.ps1"

Clear-Host
Write-Host "---------------------------- CRIAR CONTA -----------------------------" -ForegroundColor Cyan

$UserPrincipalName = $args[0]
$DisplayName = $args[1]
$LicenseType = $args[2]
$EmailSecundary = $args[3]
$GivenName = ($DisplayName.Split()[0] | Out-String).Trim()
$SurName = ($DisplayName.Remove(0,$GivenName.Length) | Out-String).Trim()
$MailNickName = $UserPrincipalName.Split("@")[0]

if ($UserPrincipalName.Length -lt 2 -or $DisplayName.Length -lt 4 )  {
    Write-Warning "Usuario invalido";
    Write-Warning "Usage .\createAccount.ps1 <email> <Nome_Completo> <student_or_lecturer>";
    break
} elseif ($LicenseType -notmatch '^student$' -and $LicenseType -notmatch '^lecturer$') {
    Write-Warning "Licensa invalida";
    Write-Warning "Usage .\createAccount.ps1 <email> <Nome_Completo> <student_or_lecturer>";
    break
  }

# Consulta se o usuario ja existe
$UUPN = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'")
$UObjID = $UUPN.ObjectID

if ($UObjID.Length -gt 30) {                    
    Write-Host "Conta $UserPrincipalName ja existe" -ForegroundColor Yellow ;
    break}

# Executa script para gerar senha aleatória e adiciona a senha na variável $Global:PasswordProfile
. "$PSScriptRoot\generatePass.ps1"


if ($EmailSecundary -match "@") {
    Write-host "Criando conta usuario: $DisplayName com email recuperacao $EmailSecundary" -ForegroundColor Green
    New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -OtherMails $EmailSecundary -UsageLocation "BR" -MailNickName $MailNickName -AccountEnabled $True -PasswordProfile $Global:PasswordProfile | Out-Null
    } else {
        Write-host "Criando conta usuario: $DisplayName" -ForegroundColor Green
        New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -OtherMails $UserPrincipalName -UsageLocation "BR" -MailNickName $MailNickName -AccountEnabled $True -PasswordProfile $Global:PasswordProfile | Out-Null
    }

$UUPN = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'")
$DisplayName = $UUPN.DisplayName
$GivenName = $UUPN.GivenName
# $Global:UMail = $UUPN.Mail # O e-mail estará disponível após setar a licença
$UObjID = $UUPN.ObjectID

# Consulta se ObjectID do usuario criado foi configurado com sucesso
if ($UObjID.Length -lt 30) {                    
    Write-host "ERRO DURANTE A CRIACAO: OBJECTID INVALIDO" -ForegroundColor Red ;
    break}

# Executa script para setar Licenca Student ou lecturerr
. "$PSScriptRoot\setLicense.ps1"

# Executa script para enviar dados de acesso por email
. "$PSScriptRoot\sendEmailLogin.ps1"

# Adicionar logs
$GetInfo = Get-AzureADUser -ObjectId $UObjID
# Adiciona a data corrente no arquivo de log
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