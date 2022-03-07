
$registryPath =  'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds' 
$name =  'EnableFeeds' 
$value = '0' 

IF(!(Test-Path $registryPath)){

	New-Item -Path $registryPath -Force | Out-Null

	New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
	
	}
	ELSE {
	
	New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
	
	}