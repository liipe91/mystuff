$PathCsv = 'C:\o365\Log\resend.txt'

$ImportCSV = Import-Csv $PathCsv

$logFile = "C:\o365\Log\historyAccount-ms.txt"

Clear-Host
Write-Host "---------------------------- REDEFINIR SENHAS ----------------------------" -ForegroundColor Cyan

. "$PSScriptRoot\connectO365.ps1"

$ImportCSV | ForEach-Object {
ForEach ($MailNickName in $_.MailNickName) {
    # Consulta se o usuario ja existe
    if ((Get-AzureADUser -Filter "MailNickName eq '$MailNickName'" | Select-Object -ExpandProperty ObjectId )) {

        $UMNN = (Get-AzureADUser -Filter "MailNickName eq '$MailNickName'")      
        $UObjID = $UMNN.ObjectID
        $DisplayName = $UMNN.DisplayName

        ## Executa script para gerar senha aleatória
        . "$PSScriptRoot\generatePass.ps1"

        Write-host "Redefinindo senha" -ForegroundColor Green
        Set-AzureADUserPassword -ObjectId $UObjID -Password $Global:UserPasswordS -ForceChangePasswordNextLogin $True

        # $LicenseType = $_.LicenseType
        # $DisplayName = $_.DisplayName
        # $GivenName = ($DisplayName.Split()[0] | Out-String).Trim()
        # $SurName = ($DisplayName.Remove(0,$GivenName.Length) | Out-String).Trim()
        # $MailNickName = $UserPrincipalName.Split("@")[0]

        # Write-Host "Criando conta usuario $DisplayName" -ForegroundColor Green
        # New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -UsageLocation "BR" -MailNickName $MailNickName -AccountEnabled $True -PasswordProfile $Global:PasswordProfile | Out-Null        
    
        # $UUPN = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'")      
        # $UObjID = $UUPN.ObjectID

        # # Consulta se ObjectID do usuario criado foi configurado com sucesso
        # if ($UObjID -ne $null) {                    
        #     . "$PSScriptRoot\setLicense.ps1"
        
        . "$PSScriptRoot\sendEmailLogin-errata.ps1"

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

        # } else {       
        #     Write-Host "Usuario $MailNickName nao encontrado" -ForegroundColor Yellow }

    } else {
        Write-Host "Usuario $MailNickName nao existe" -ForegroundColor Yellow }
        
    Write-Host ('-' * 70)
}
}

Disconnect-AzureAD