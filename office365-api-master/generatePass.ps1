# Função para gerar os caracteres 
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

# Função para embaralhar os caracteres
function Scramble-String([string]$inputString){
    $characterArray = $inputString.ToCharArray()
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length
    $outputString = -join $scrambledStringArray
    return $outputString
}

# Variável para receber os caracteres gerados na função Get-RandomCharacters
$Global:UserPassword = Get-RandomCharacters -length 2 -characters 'abcdefghikmnprstuvwxyz'
$Global:UserPassword += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNPRSTUVWXYZ'
$Global:UserPassword += Get-RandomCharacters -length 2 -characters '23456789'
$Global:UserPassword += Get-RandomCharacters -length 2 -characters '!@#$&'

# Variável para embaralhar na função Scramble-String
$Global:UserPassword = Scramble-String $Global:UserPassword
# Senha em formato seguro para changePass.ps1
$Global:UserPasswordS = ConvertTo-SecureString -String $Global:UserPassword -AsPlainText -Force

$Global:PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$Global:PasswordProfile.Password = $Global:UserPassword