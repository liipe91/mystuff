$PathCsv = 'C:\o365\Csv\setRecover.csv'

$ImportCSV = Import-Csv $PathCsv

$logFile = "C:\o365\Log\historyAccount-ms.txt"

Clear-Host
Write-Host "---------------------------- SETAR EMAIL DE RECUPERACAO ----------------------------" -ForegroundColor Cyan

. "$PSScriptRoot\connectO365.ps1"

$ImportCSV | ForEach-Object {
ForEach ($UserPrincipalName in $_.UserPrincipalName) {
    # Consulta se o usuario ja existe
    if ((Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'" | Select-Object -ExpandProperty ObjectId )) {

        $UUPN = (Get-AzureADUser -Filter "UserPrincipalName eq '$UserPrincipalName'")      
        $UObjID = $UUPN.ObjectID
        $DisplayName = $UUPN.DisplayName
        $CurrentOtherMails = $UUPN.OtherMails
        $OtherMails = $UserPrincipalName

        if ($CurrentOtherMails -match "@") {
            Write-host "Usuario $UserPrincipalName ignorado, ja possui email de recuperacao $CurrentOtherMails " -ForegroundColor Yellow            
        } else {
            Write-host "Setando email recuperacao $OtherMails para usuario $UserPrincipalName" -ForegroundColor Green
            Set-AzureADUser -ObjectId $UObjID -OtherMails $OtherMails

            $GetInfo = Get-AzureADUser -ObjectId $UObjID
            # Adiciona a data corrente no arquivo de log
            Add-Content -Path $logFile -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss ") -NoNewline
            # Consulta o usuario criado pelo ObjectID e armazena resultado
            $GetInfo | Format-Table UserPrincipalName, DisplayName, OtherMails, ObjectId, @{L='AE';E={$_.AccountEnabled}} -HideTableHeaders | Out-File -FilePath $logFile -Append -Encoding utf8 -NoNewline
            # Adiciona um espaco na ultima linha por questao de formatacao                    
            Add-Content -Path $logFile -Value " "
        }

    } else {
        Write-Host "Usuario $UserPrincipalName nao existe" -ForegroundColor Yellow }
        
    Write-Host ('-' * 70)
}
}

Disconnect-AzureAD