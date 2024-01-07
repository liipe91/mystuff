###########################Define Variables##################################

$credFile = "${env:\userprofile}\o365.cred"

##########################Check if Administrator#############################

if (-NOT ([Security.Principal.WindowsPrincipal] `
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You are not running this as local administrator. Run it again in an elevated prompt."
    break }

#########################Input array And Vaidate it##########################

$ORIGINALUSERS = $args[0]
[System.Collections.ArrayList]$USERS = @()

if ($args[0] -eq $null) {
    Write-Warning "Missing parameter '$$ <user>'" }

ForEach ($user in $ORIGINALUSERS) {       
    $USERS.Add($user) | Out-Null
    if ($user.Length -le 2) { Write-Warning "Invalid user $user"
    $USERS.Remove($user) | Out-Null }}

###########################Verify Module AzureAD#############################

If ((Get-InstalledModule -Name AzureAD) -eq $null) {
    Write-Warning "Installing module AzureAD..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Register-PSRepository -Default | Out-Null
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted | Out-Null
    Install-Module AzureAD
    }
    
##################Verify cred file And Connect Office 365####################

$Error.Clear()

if (-NOT (Test-Path $credFile -PathType Leaf)) {
    Write-Warning "Credentials not found. Enter Office 365 credentials"
    $cred = Get-Credential
    $cred | Export-Clixml -Path $credFile
    $Error.Clear() }

$ErrorActionPreference = "silentlycontinue"
Write-Information "Importing credentials at" $credFile
$cred = Import-Clixml -Path $credFile
Connect-AzureAD -Credential $cred | Out-Null

If ($Error -ne $null) {
    Write-Warning "Invalid Credentials, Access denied or Network Problems"
    Remove-Item $credFile
    $Error.Clear()
    break }