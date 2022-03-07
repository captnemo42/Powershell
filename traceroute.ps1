
<# Ping

#>

Function Get-PingStatus
 {
    param(
        [Parameter(ValueFromPipeline=$true)]       
        [string]$device,        
        [validateSet("Online","Offline","ObjectTable")]
        [String]$getObject
    ) 
begin{
    $hash = @()
    }
process{
    $device| foreach {
            if (Test-Connection $_ -Count 1 -Quiet) {             
                if(-not($GetObject)){Write-Output "$_ Online"}
                    $Hash = $Hash += @{Online="$_"}
            }else{
                if(-not($GetObject)){Write-Output "$_ ...No response"}               
                    $Hash = $Hash += @{Offline="$_"}
                }
        }            
    }
end {
    if($GetObject) {
            $Global:Objects = $Hash | foreach { [PSCustomObject]@{                
                DeviceName = $_.Values| foreach { "$_" }
                Online     = $_.Keys| where {$_ -eq "Online"} 
                offline    = $_.Keys| where {$_ -eq "Offline"} 
                }
            }   
    Switch -Exact ($GetObject)
        {
            'Online'      { $Global:Objects| where 'online'| select -ExpandProperty DeviceName }
            'Offline'     { $Global:Objects| where 'offline'| select -ExpandProperty DeviceName }
            'ObjectTable' { return $Global:Objects }       
        }
    }       
  } 
}

# =======================================================================

<#
.SYNOPSIS 
Clone of tracert.exe, which is a clone of the unix utility traceroute
.DESCRIPTION 
Runs a traceroute and returns the result.
.INPUTS 
Pipeline 
    You can pipe -TargetHost from the pipeline
#>
function Invoke-TraceRoute {
    [CmdletBinding()]
    param (
          [int] $Timeout = 1000
        , [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
          [string] $TargetHost
        , [int] $StartingTtl = 1
        , [int] $EndingTtl = $(
			if ($EndingTtl -eq $null) { $EndingTtl = 128 } 
			if ($EndingTtl -lt $StartingTtl) { 
				Throw New-Object System.ArgumentOutOfRangeException("-EndingTtl must be greater than or equal to -StartingTtl ($($EndingTtl) < $($StartingTtl))", '-EndingTtl') 
			} else { $EndingTtl }
		)
        , [switch] $ResolveDns
    )

    # Create Ping and PingOptions objects
    $Ping = New-Object -TypeName System.Net.NetworkInformation.Ping;
    $PingOptions = New-Object -TypeName System.Net.NetworkInformation.PingOptions;
    Write-Debug -Message ('Created Ping and PingOptions instances');

    # Assign initial Time-to-Live (TTL) to the PingOptions instance
    $PingOptions.Ttl = $StartingTtl;

    # Assign starting TTL to the 
    $Ttl = $StartingTtl;

    # Assign a random array of bytes as data to send in the datagram's buffer
    $DataBuffer = [byte[]][char[]]'aa';

    # Loop from StartingTtl to EndingTtl
    while ($Ttl -le $EndingTtl) {

        # Set the TTL to the current
        $PingOptions.Ttl = $Ttl;

        # Ping the target host using this Send() override: http://msdn.microsoft.com/en-us/library/ms144956.aspx
        $PingReply = $Ping.Send($TargetHost, $Timeout, $DataBuffer, $PingOptions);

        # Get results of trace
        $TraceHop = New-Object -TypeName PSObject -Property @{
                TTL           = $PingOptions.Ttl;
                Status        = $PingReply.Status;
                Address       = $PingReply.Address;
                RoundTripTime = $PingReply.RoundtripTime;
                HostName      = '';
            };

        # If DNS resolution is enabled, and $TraceHop.Address is not null, then resolve DNS
        # TraceHop.Address can be $null if 
        if ($ResolveDns -and $TraceHop.Address) {
            Write-Debug -Message ('Resolving host entry for address: {0}' -f $TraceHop.Address); 
            try {
                # Resolve DNS and assign value to HostName property of $TraceHop instance
                $TraceHop.HostName = [System.Net.Dns]::GetHostEntry($TraceHop.Address).HostName;
            }
            catch {
                Write-Debug -Message ('Failed to resolve host entry for address {0}' -f $TraceHop.Address);
                Write-Debug -Message ('Exception: {0}' -f $_.Exception.InnerException.Message);
            }
        }

        # Once we get our first, successful reply, we have hit the target host and 
        # can break out of the while loop.
        if ($PingReply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            Write-Debug -Message ('Successfully pinged target host: {0}' -f $TargetHost);
            Write-Output -InputObject $TraceHop;
			 
            break;
        }
        # If we get a TtlExpired status, then ping the device directly and get response time
        elseif ($PingReply.Status -eq [System.Net.NetworkInformation.IPStatus]::TtlExpired) {
            $PingReply = $Ping.Send($TraceHop.Address, $Timeout, $DataBuffer, $PingOptions);
            $TraceHop.RoundTripTime = $PingReply.RoundtripTime;
            
            Write-Output -InputObject $TraceHop;
			 
        }
        else {
            # $PingReply | select *;
        }

        # Increment the Time-to-Live (TTL) by one (1) 
        $Ttl++;
        Write-Debug -Message ('Incremented TTL to {0}' -f $Ttl);
    }
}
 

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '628,527'
$Form.text                       = "Ping and Traceroute"
$Form.TopMost                    = $false

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.MaxLength = 3
$TextBox1.width                  = 42
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(47,46)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'
$TextBox1.Text 					="192"
$TextBox1.Add_TextChanged({
    $this.Text = $this.Text -replace '\D'
})

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.MaxLength = 3
$TextBox2.width                  = 39
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(100,46)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'
$TextBox2.Text 					="168"
$TextBox2.Add_TextChanged({
    $this.Text = $this.Text -replace '\D'
})

$TextBox3                        = New-Object system.Windows.Forms.TextBox
$TextBox3.multiline              = $false
$TextBox3.MaxLength = 3
$TextBox3.width                  = 39
$TextBox3.height                 = 20
$TextBox3.location               = New-Object System.Drawing.Point(152,46)
$TextBox3.Font                   = 'Microsoft Sans Serif,10'
$TextBox3.Text 					="0"
$TextBox3.Add_TextChanged({
    $this.Text = $this.Text -replace '\D'
})

$TextBox4                        = New-Object system.Windows.Forms.TextBox
$TextBox4.multiline              = $false
$TextBox4.MaxLength = 3
$TextBox4.width                  = 39
$TextBox4.height                 = 20
$TextBox4.location               = New-Object System.Drawing.Point(202,46)
$TextBox4.Font                   = 'Microsoft Sans Serif,10'
$TextBox4.Add_TextChanged({
    $this.Text = $this.Text -replace '\D'
})

$messageLabel                          = New-Object system.Windows.Forms.Label
$messageLabel.text                     = " "
$messageLabel.AutoSize                 = $true
$messageLabel.width                    = 25
$messageLabel.height                   = 10
$messageLabel.location                 = New-Object System.Drawing.Point(30,93)
$messageLabel.Font                     = 'Microsoft Sans Serif,10'

$TextBox5                        = New-Object system.Windows.Forms.TextBox
$TextBox5.multiline              = $false
$TextBox5.MaxLength = 3
$TextBox5.width                  = 39
$TextBox5.height                 = 20
$TextBox5.location               = New-Object System.Drawing.Point(277,46)
$TextBox5.Font                   = 'Microsoft Sans Serif,10'
$TextBox5.Add_TextChanged({
    $this.Text = $this.Text -replace '\D'
})

$PingButton                      = New-Object system.Windows.Forms.Button
$PingButton.text                 = "Ping"
$PingButton.width                = 80
$PingButton.height               = 40
$PingButton.location             = New-Object System.Drawing.Point(371,18)
$PingButton.Font                 = 'Microsoft Sans Serif,10'

$traceButton                     = New-Object system.Windows.Forms.Button
$traceButton.text                = "Trace Route"
$traceButton.width               = 80
$traceButton.height              = 40
$traceButton.location            = New-Object System.Drawing.Point(373,66)
$traceButton.Font                = 'Microsoft Sans Serif,10'

$IP                              = New-Object system.Windows.Forms.Label
$IP.text                         = "IP Address or Range"
$IP.AutoSize                     = $true
$IP.width                        = 25
$IP.height                       = 10
$IP.location                     = New-Object System.Drawing.Point(50,18)
$IP.Font                         = 'Microsoft Sans Serif,10'

$hyphen                          = New-Object system.Windows.Forms.Label
$hyphen.text                     = "_"
$hyphen.AutoSize                 = $true
$hyphen.width                    = 25
$hyphen.height                   = 10
$hyphen.location                 = New-Object System.Drawing.Point(254,48)
$hyphen.Font                     = 'Microsoft Sans Serif,10'

$ResultsTextbox                  = New-Object system.Windows.Forms.TextBox
$ResultsTextbox.multiline        = $true
$ResultsTextbox.Scrollbars		= "Vertical" 
$ResultsTextbox.BackColor        = "#131212"
$ResultsTextbox.width            = 500
$ResultsTextbox.height           = 360
$ResultsTextbox.location         = New-Object System.Drawing.Point(45,140)
$ResultsTextbox.Font             = 'Microsoft Sans Serif,10'
$ResultsTextbox.ForeColor        = "#08e008"

$Form.controls.AddRange(@($TextBox1,$TextBox2,$TextBox3,$TextBox4,$TextBox5,$messageLabel,$PingButton,$traceButton,$IP,$hyphen,$ResultsTextbox))



$range=0

# ==============================================



function incrementIP($ipToincrement,$amountToIncrement ){
 
$ip = $ipToincrement.IPAddressToString
$ip2 = $ip.split('.') 
$ip2[-1] = $x+$($TextBox4.Text)
$ip2 -join '.'
$ipToincrement = $ip2
}


# ==== Get ip's +++++++++++++++++++++++++++++
function get-ip(){
if( ([INT]$($TextBox5.Text) -ge 254) -OR ([INT]$($TextBox4.Text) -ge 254) -OR  ([INT]$($TextBox5.Text) -lt 0) -OR ([INT]$($TextBox4.Text) -le 1) ){
$ResultsTextbox.AppendText("error invalid IP Range $range `r`n")
}
else{
		try{
			$ipaddress1 =  [IPAddress]"$($TextBox1.Text).$($TextBox2.Text).$($TextBox3.Text).$($TextBox4.Text)"
			$messageLabel.Text = $ipaddress1
			$ipaddress1
			}catch{
			$messageLabel.Text = "error invalid IP address"
			}
}
}

function get-range(){
	if([INT]$($TextBox5.Text) -ge [INT]$($TextBox4.Text)) {
		$range = [INT]$($TextBox5.Text) - [INT]$($TextBox4.Text)
	}else {
	$range = 0
	}
	$range
}	
	#write-host $range
Function ping-ip($ipaddress1, $range){
	if($range -lt 0){
	$ResultsTextbox.AppendText("error invalid IP Range $range `r`n")
	}else{
		if($($TextBox5.Text) -ne ""){
			try{
				$ipaddress2 =  [IPAddress]"$($TextBox1.Text).$($TextBox2.Text).$($TextBox3.Text).$($TextBox5.Text)"
				$messageLabel.Text = $ipaddress2		
				}catch{
					$messageLabel.Text = "error invalid IP Range"
					}
				for($x=0;$x -le $range;$x++){
				#$result = Get-PingStatus $($ipaddress1+=$x)
				$result = incrementIP $ipaddress1 $x
				$result = Get-PingStatus $result
					$ResultsTextbox.AppendText("$result `r`n")
				}	
				}else{
				
					$result = Get-PingStatus $ipaddress1
					$ResultsTextbox.AppendText("$result `r`n")
			}
		}
	
}

#write-host $ipaddress1



# ==============================================

$PingButton.Add_click({
$ipaddress = get-ip
$range = get-range
#write-host "result = $ipaddress"
if($ipaddress){
ping-ip $ipaddress $range
}
})

$traceButton.Add_click({
$ipaddress = get-ip
$ping = Test-Connection $ipaddress -Count 1 -Quiet -erroraction 'silentlycontinue'
if( ($ipaddress) -AND ($ping) ){
	$ResultsTextbox.AppendText("Running trace.. Please standby. `r`n") 
	$results = Invoke-TraceRoute -TargetHost $ipaddress -ResolveDns
	foreach ($result in $results){ 
		$ResultsTextbox.AppendText("$($result.RoundTripTime)ms  $($result.Address) $($result.HostName) `r`n") 
	}
}else{
	$ResultsTextbox.AppendText("Error, unable to contact host. `r`n") 
	}

})
 
[void]$Form.ShowDialog()