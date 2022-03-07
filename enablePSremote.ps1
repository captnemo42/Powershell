$ArgList = @(
    "powershell"
    "Start-Process powershell"
    "-Verb runAs"
    "-ArgumentList 'Enable-PSRemoting -force;"
    "Set-Item WSMan:localhost\client\trustedhosts -value *'"
    ) -join ' '

$TargetMachine = Read-Host -Prompt 'Input the computer name'
 	write-host "Enabling PS on $TargetMachine"
$IWM_Params = @{
    ComputerName = $TargetMachine
    Namespace = 'root\cimv2'
    Class = 'Win32_Process'
    Name = 'Create'
    Credential = $Cred
    # the next value may need to be quoted if it needs to be [string] instead of [int]
    Impersonation = 3
    EnableAllPrivileges = $True
    ArgumentList = $ArgList
    }
Invoke-WmiMethod @IWM_Params

#}
sleep 2
#enable rdp
enter-pssession -Computername $targetMachine
sleep 2
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

exit
