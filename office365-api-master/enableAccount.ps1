###########################Define Variables##################################

# Pensar numa estrategia para nao ter conflito de nome
# $PathCsv = 'C:\o365\Csv\usersToCreate2020081900.csv'
# $ImportCSV = Import-Csv $PathCsva

# $logFile = "C:\o365\Log\$((Get-Item $PSCommandPath).BaseName).txt"
$logFile = "C:\o365\Log\historyAccount-ms.txt"

##############################Connect Office 365#############################

# . .\connectO365.ps1
& $PSScriptRoot\connectO365.ps1

##############################Display Action#############################

Clear-Host
Write-Host "---------------------------- HABILITAR CONTA -----------------------------" -ForegroundColor Cyan

######################Create account############################

# $user = $args[0]
# if ($user.Length -le 2) {
#     Write-Warning "Usuario invalido";
#     break }
                
# Clear-Host
# Write-Host "---------------------------- DESABILITAR CONTA -----------------------------" -ForegroundColor Cyan

$MailNickName = $args[0]

if ($MailNickName.Length -lt 2 )  {
    Write-Warning "Usuario invalido";
    Write-Warning "Usage .\enableAccount.ps1 <apenas_iniciais>";
    break }

$UMNN = (Get-AzureADUser -Filter "MailNickName eq '$MailNickName'")
$UserPrincipalName = $UMNN.UserPrincipalName
$DisplayName = $UMNN.DisplayName
$GivenName = $UMNN.GivenName
$AccountEnabled = $UMNN.AccountEnabled
$UObjID = $UMNN.ObjectID

# Consulta se usuario ja existe e se ja esta habilitado
if ($UObjID.Length -lt 30) {
    Write-Host "Usuario $MailNickName nao existe" -ForegroundColor Yellow ;
    break
} elseif ($AccountEnabled -match "True") {
    Write-Host "Usuario $MailNickName ja habilitado" -ForegroundColor Yellow ;
    break
}

# Write-Host "CONFIRMA DESABILITAR CONTA USUaRIO $user (S/N): " -ForegroundColor Yellow -NoNewline
# $result = Read-Host 
# If (($result -notmatch '[Ss]')) {
#     Write-Host "OPERAÇaO CANCELADA" -ForegroundColor Yellow ;
#     break }

Write-Host "Habilitando conta usuario $UserPrincipalName" -ForegroundColor Green
Set-AzureADUser -ObjectId $UObjID -AccountEnabled $True

# $GetInfo = Get-AzureADUser -ObjectId $UObjID
# $CreatedTime = @{Name = 'CreatedTime'; Expression = {$GetInfo.ExtensionProperty.createdDateTime}}
# $EnabledLicenses = @{Name = 'EnabledLicenses'; Expression = {(Get-AzureADUserLicenseDetail -ObjectId $UObjID).skuPartNumber}}      

# $GetInfo | Select-Object -Property UserPrincipalName, DisplayName, ObjectId, AccountEnabled, $CreatedTime, $EnabledLicenses

############################Set License##############################   

# Mantem a licensa da criaçao
# . .\setLicenseStudent.ps1       

############################Enviar e-mail de acesso com senha##############################

# Desnecessario enviar e-mail
# . .\sendEmailLogin.ps1

############################Logs##############################

$GetInfo = Get-AzureADUser -ObjectId $UObjID
# $CreatedTime = @{Name = 'CreatedTime'; Expression = {$GetInfo.ExtensionProperty.createdDateTime}}
# Adiciona a data corrente no arquivo de log
Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss ") -NoNewline
# Consulta o usuario criado pelo ObjectID e armazena resultado
# $GetInfo | Select-Object -Property UserPrincipalName, DisplayName, ObjectId, AccountEnabled | `
$GetInfo | Format-Table UserPrincipalName, DisplayName, ObjectId, @{L='AE';E={$_.AccountEnabled}} -HideTableHeaders | Out-File -FilePath $logFile -Append -NoNewline -Encoding utf8
    # Format-Table -HideTableHeaders | `
    # Out-File -FilePath $logFile -Append -NoNewline -Encoding utf8
# Adiciona um espaco na ultima linha por questao de formatacao                    
Add-Content -Path $logFile -Value " " -NoNewline
# Consulta a licenca adicionada ao usuario e armazena o resultado
(Get-AzureADUserLicenseDetail -ObjectId $UObjID) | Select-Object -ExpandProperty SkuPartNumber | Out-File -FilePath $logFile -Append -NoNewline -Encoding utf8
# Adiciona um espaco na ultima linha por questao de formataçao
Add-Content -Path $logFile -Value " " -NoNewline
Add-Content -Path $logFile -Value $Global:UserPassword

Write-Host ('-' * 70)

Disconnect-AzureAD