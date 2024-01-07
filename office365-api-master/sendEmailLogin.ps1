#$FromAddress = "accounts@local.com"
$FromAddress = "Local-UFPE Accounts <accounts@local.com>"
$MailSubject = "Credencial de Acesso Microsoft Office 365 - Local"
$SmtpServer = 'smtps.local.com'

$MsgBody = "Prezado(a) $DisplayName,<br><br>"
$MsgBody += "Seu acesso à conta Microsoft Office 365 / Azure foi habilitado.<br>"
$MsgBody += "Ao realizar o primeiro login (https://local.com/azure) utilizando a credencial abaixo, <br>"
$MsgBody += "o sistema solicitará a troca da senha, que precisa conter pelo menos 8 caracteres. <br><br>"
$MsgBody += "<b>Login:</b> $UserPrincipalName<br>"
$MsgBody += "<b>Senha:</b> $Global:UserPassword<br><br>"
$MsgBody += "Esta conta permite utilizar softwares educacionais para os alunos e funcionários do Local, <br>"
$MsgBody += "através da plataforma Azure Dev Tools, oferecida pela Microsoft. <br>"
$MsgBody += "Para mais informações acesse https://suporte.local.com/softwares ou helpdesk@local.com<br>"

Write-Host "Enviando senha $Global:UserPassword para $UserPrincipalName" -ForegroundColor Green

Send-MailMessage -From $FromAddress -To $UserPrincipalName -Subject $MailSubject -Body $MsgBody -Priority High `
-SmtpServer $SmtpServer -BodyAsHtml -Encoding UTF8
