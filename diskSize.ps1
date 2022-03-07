$disk = Get-WmiObject Win32_LogicalDisk -ComputerName MYCOMPUTER -Filter "DeviceID='c:'" |
Select-Object Size,FreeSpace

[math]::Round($disk.Size/1GB,2) 
$disk.FreeSpace