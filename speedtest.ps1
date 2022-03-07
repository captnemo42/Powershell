
Send-MailMessage -From 'admin@domain.com' -To 'admin@domain.com' -Subject 'Testing connections started' -Body "See attached log" -Attachments .\speedtest.csv -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'glue.lazbeer.com'

function get-site(){
	Param(
		[string]$site 
	)
$url = $site

# track execution time:
$timeTaken = Measure-Command -Expression {
  $downloadedSite = Invoke-WebRequest -Uri $url
}
$milliseconds = $timeTaken.TotalMilliseconds
$milliseconds = [Math]::Round($milliseconds, 1)
if($milliseconds -gt 1000){
Send-MailMessage -From 'admin@domain.com' -To 'outage@domain.com' -Subject 'Slow connection detected' -Body "Site slow see attached log" -Attachments .\speedtest.csv -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'glue.lazbeer.com'
}
return "$(get-date) , $site , $milliseconds "
}
$continue = $true
do{

$result = get-site 'http://google.com'
add-Content -Path 'speedtest.csv' -Value $result -PassThru

$result = get-site 'http://192.168.0.1'
add-Content -Path 'speedtest.csv' -Value $result -PassThru
 
$result = get-site 'bing.com'
add-Content -Path 'speedtest.csv' -Value $result -PassThru

if ([console]::KeyAvailable)
{
	$x = [System.Console]::ReadKey()
	switch ($x.key)
	{
		"q" {
			$continue = $false
			break
		}
	}
}
start-sleep -Seconds 900
}while($continue -eq $true)
