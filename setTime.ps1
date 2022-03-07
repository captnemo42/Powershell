$dateTime = Get-Date;
$password = ConvertTo-SecureString "mypassword" -AsPlainText -Force;
$cred = get-credential
Invoke-Command -ComputerName MYCOMPUTER -Credential $cred -ScriptBlock {
    Set-Date -Date $using:datetime;
	tzutil /s "Pacific Standard Time"
}
# from cmd change time zone: tzutil /s "Pacific Standard Time"
# To list all tzutil /l