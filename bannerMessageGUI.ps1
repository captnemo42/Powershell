# ==========================================================================================
# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Show-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
# ==================================================================================================
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '1000,80'
$Form.text                       = "MY Banner"
$Icon                            = New-Object system.drawing.icon ("$PWD\icon.ico")
$Form.Icon                       = $Icon
$form.TopMost = $True
# ==============================================================
#USER MESAGES
	$messageLabel = New-Object 'System.Windows.Forms.Label' 
	$messageLabel.Font = "Segoe UI, 13pt" 
    $messageLabel.ForeColor = 'Green' 
    $messageLabel.Location = '20,20' 
    $messageLabel.Name = "messageLabel" 
    $messageLabel.Size = '300, 40' 
    $messageLabel.TabIndex = 0 
    $messageLabel.Text = " Your Message here" 
    $messageLabel.add_Click($messageLabel_Click) 
	$messageLabel_Click={ 
        #TODO: Place custom script here 
         
    } 
	
# ===============================================================

$Form.controls.AddRange(@( $messageLabel))


Hide-Console 
[void]$Form.ShowDialog()

show-Console