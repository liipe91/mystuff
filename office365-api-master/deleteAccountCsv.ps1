###########################Define Variables##################################

# Pensar numa estratégia para não ter conflito de nome
$PathCsv = 'C:\o365\Csv\usersToCreate.csv'
$ImportCSV = Import-Csv $PathCsv

##############################Display Action#############################

Write-Host "--------------------------- DELETAR CONTAS ---------------------------" -ForegroundColor Cyan
            
##############################Connect Office 365#############################

. .\connectO365.ps1

######################Create account by file CSV############################

$ImportCSV | ForEach-Object {
ForEach ($user in $_.MailNickName) {         
    # CRIAR UMA CONFIRMAÇÃO ANTES DE DELETAR!!!!!

    if ((Get-AzureADUser -Filter "MailNickName eq '$user'" | Select-Object -ExpandProperty ObjectId )) {    
                
        $UMNN = (Get-AzureADUser -Filter "MailNickName eq '$user'")
        #$UMNN = (Get-AzureADUser -Filter "MailNickName eq 'lab5'")
        $UUPN = $UMNN.UserPrincipalName
        $UDN = $UMNN.DisplayName
        $UGN = $UMNN.GivenName        
        $UMail = $UMNN.Mail # O e-mail estará disponível após setar a licença
        #Write-Host "Apos criar: $UMail"
        $UObjID = $UMNN.ObjectID

            if ($UObjID -ne $null) {    

############################Remove user##############################    
                
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

                        Write-Host "Removendo Licenças usuário $user" -ForegroundColor Green
                        Set-AzureADUserLicense -ObjectId $UObjID -AssignedLicenses $licenses
                        }
                }

                Write-Host "Removendo conta usuário $user" -ForegroundColor Green
                Remove-AzureADUser -ObjectId $UObjID 
                
                Write-Host ('-' * 70)             
                
            } else {       
                Write-Host "Usuario $user não encontrado" -ForegroundColor Yellow }
    } else {       
        Write-Host "Usuário $user não existe" -ForegroundColor Yellow 
        Write-Host ('-' * 70) }
}
}

Disconnect-AzureAD