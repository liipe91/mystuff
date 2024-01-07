[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$AESKeyFilePath = "C:\o365\office365-api\.o365.AES"
$credFile = "C:\o365\office365-api\.o365-cred"
$SecureKey = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
$adminAccount = "accounts@local.com"

#Check if Administrator#
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Você nao esta executando como administrador. "
    break }

#Verify cred file And Connect Office 365
$Error.Clear()

if (-NOT (Test-Path $credFile -PathType Leaf)) {
    Write-Warning "Credenciais nao encontradas. Entre com a conta Office 365 $adminAccount"
    # Habilita get-credential pelo terminal, sem GUI
    $key = “HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds”
    Set-ItemProperty $key ConsolePrompting True

    # Generate a random AES Encryption Key.
    $AESKey = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
    $AESKey | out-file $AESKeyFilePath    
    $cred = Get-Credential -Credential $adminAccount
    
    $cred.Password | ConvertFrom-SecureString -key (get-content $AESKeyFilePath) | Set-Content $credFile

    $Error.Clear() 
    }

$ErrorActionPreference = "silentlycontinue"
$Error.Clear()
$password = Get-Content $credFile | ConvertTo-SecureString -Key (Get-Content $AESKeyFilePath)
$credential = New-Object System.Management.Automation.PsCredential($adminAccount,$password)
Connect-AzureAD -Credential $credential | Out-Null