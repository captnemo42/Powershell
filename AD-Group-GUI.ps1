Add-Type -AssemblyName System.Windows.Forms 
Import-Module ActiveDirectory 
 
##function to populate the current group list box with the users current security group membership 
function cgroups { process { 
      $group10 = Get-ADPrincipalGroupMembership -Identity $id2 
      foreach($groups in $group10){ 
                 $result = $Currentgroups.Items.Add($groups.Name); 
             } 
       } 
} 
 
# function to populate the SecurityGroups listbox with all current security groups located in the domain AD 
function SecurityGroups { process{  
     $groups = Get-ADGroup -Filter {GroupCategory -eq 'security'} 
     foreach($group in $groups){ 
              $result = $SecurityGroups.Items.Add($group.Name); 
            } 
      } 
} 
 
#function to populate the DistributionGroups with all current distribution groups 
function DistributionGroups { process { 
    $groups = Get-ADGroup -Filter {GroupCategory -eq 'distribution'} 
     foreach($group in $groups){ 
              $result = $DistributionGroups.Items.Add($group.Name); 
            }  
     } 
 } 
 
 
function clear {  process{ 
           $Currentgroups.Items.Clear(); 
           $userid.Text = ""; 
     } 
} 
 
#clears specified fields and selected items 
function cclear { process{ 
		Start-Sleep -Seconds 3 
        $complete1.text = ""; 
         $result = $DistributionGroups.ClearSelected() 
         $result = $SecurityGroups.ClearSelected() 
		} 
} 
 
 
$Form = New-Object system.Windows.Forms.Form 
$Form.Text = "AD Groups" 
$Form.TopMost = $true 
$Form.Width = 900 
$Form.BackColor = "white" 
$Form.Height = 600 
 
$Currentgroups = New-Object system.windows.Forms.ListBox 
$Currentgroups.Text = "listBox" 
$Currentgroups.Width = 249 
$Currentgroups.Height = 221 
$Currentgroups.location = new-object system.drawing.point(17,94) 
 $result = $Form.controls.Add($Currentgroups) 

$groupMembersLabel = New-Object system.windows.Forms.Label 
$groupMembersLabel.Text = "Group Members" 
$groupMembersLabel.AutoSize = $true 
$groupMembersLabel.Width = 25 
$groupMembersLabel.Height = 10 
$groupMembersLabel.location = new-object system.drawing.point(320,320) 
$groupMembersLabel.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($groupMembersLabel) 
$groupMembersBox = New-Object system.windows.Forms.ListBox 
$groupMembersBox.Text = "listBox" 
$groupMembersBox.Width = 400 
$groupMembersBox.Height = 221 
$groupMembersBox.location = new-object system.drawing.point(320,340) 
 $result = $Form.controls.Add($groupMembersBox) 

$complete1 = New-Object system.windows.Forms.Label 
$complete1.AutoSize = $true 
$complete1.Width = 25 
$complete1.Height = 10 
$complete1.location = new-object system.drawing.point(350,7) 
$complete1.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($complete1) 
 
$CurrentLabel = New-Object system.windows.Forms.Label 
$CurrentLabel.Text = "Current Groups" 
$CurrentLabel.AutoSize = $true 
$CurrentLabel.Width = 25 
$CurrentLabel.Height = 10 
$CurrentLabel.location = new-object system.drawing.point(18,74) 
$CurrentLabel.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($CurrentLabel) 
 
$label25 = New-Object system.windows.Forms.Label 
$label25.Text = "Security groups" 
$label25.AutoSize = $true 
$label25.Width = 25 
$label25.Height = 10 
$label25.location = new-object system.drawing.point(340,74) 
$label25.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($label25) 
 
$label27 = New-Object system.windows.Forms.Label 
$label27.Text = "Distribution Groups" 
$label27.AutoSize = $true 
$label27.Width = 25 
$label27.Height = 10 
$label27.location = new-object system.drawing.point(620,74) 
$label27.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($label27) 


 
$SecurityGroups = New-Object system.windows.Forms.ListBox 
$SecurityGroups.Text = "listBox" 
$SecurityGroups.Width = 249 
$SecurityGroups.Height = 221 
$SecurityGroups.location = new-object system.drawing.point(320,94) 
 $result = $Form.controls.Add($SecurityGroups) 
 
$DistributionGroups = New-Object system.windows.Forms.ListBox 
$DistributionGroups.Text = "listBox" 
$DistributionGroups.Width = 249 
$DistributionGroups.Height = 221 
$DistributionGroups.location = new-object system.drawing.point(620,94) 
 $result = $Form.controls.Add($DistributionGroups) 
 
$userID = New-Object system.Windows.Forms.ComboBox  
$userID.Width = 100 
$userID.Height = 20 
$userID.location = new-object system.drawing.point(86,25) 
$userID.Font = "Microsoft Sans Serif,10" 
$Users =  Get-ADUser  -Filter * -Properties Name | Sort-Object -Property Name
Foreach($user in $Users){
 $result = $userID.Items.add($user.SamAccountName)
}
 $result = $Form.controls.Add($userID) 
 
$userLabel = New-Object system.windows.Forms.Label 
$userLabel.Text = "UserID:" 
$userLabel.AutoSize = $true 
$userLabel.Width = 25 
$userLabel.Height = 10 
$userLabel.location = new-object system.drawing.point(16,26) 
$userLabel.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($userLabel) 
 
 #finds user specified in dropdown and returns their group membership to the Currentgroups listbox.  
 $UserID.Add_SelectedIndexChanged({
	$Currentgroups.Items.Clear(); 
	$user = Get-ADUser $UserID.SelectedItem.ToString() -Properties DisplayName
	$username= $user.Name
	$CurrentLabel.Text = "$username Current Groups" 
	$script:id2 = $UserID.SelectedItem.ToString()
	$userGroups = Get-ADPrincipalGroupMembership $UserID.SelectedItem.ToString() | select name   
	Foreach($group in $userGroups){
		 $result = $Currentgroups.Items.add($group.Name)
		}
 })



 
#adds user to group selected in either the distribution groups listbox or the security groups listbox 
$addButton = New-Object system.windows.Forms.Button 
$addButton.Text = "Add" 
$addButton.BackColor = "Green" 
$addButton.Width = 100 
$addButton.Height = 30 
$addButton.Add_MouseClick({ 
 
             $SecurityGroup = $SecurityGroups.SelectedItems; 
             $mgroup = $DistributionGroups.SelectedItems; 
			 if($SecurityGroup){
              Add-ADPrincipalGroupMembership -Identity $id2 -MemberOf $SecurityGroup;
			  $complete1.Text = "Added to group"; 
				}
			if ($mgroup){
              Add-ADPrincipalGroupMembership -Identity $id2 -MemberOf $mgroup; 
			  $complete1.Text = "Added to group"; 
              }
			  #success; 
              
              Start-Sleep -Seconds 1; 
               $result = $Currentgroups.Items.Clear(); 
              cgroups; 
              cclear; 
              
}) 
$addButton.location = new-object system.drawing.point(17,334) 
$addButton.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($addButton) 
 
 
#removes user from selected group in "Current Groups" list box and refreshes the results of that box.  
$removeButton = New-Object system.windows.Forms.Button 
$removeButton.Text = "Remove" 
$removeButton.BackColor = "Red" 
$removeButton.Width = 100 
$removeButton.Height = 30 
$removeButton.Add_MouseClick({ 
           $group = $Currentgroups.SelectedItem; 
			if($group){
           Remove-ADistributionGroupMember -Identity $group -Member $id2 -Confirm: $false; 
           $complete1.Text = "Completed" 
           }else { $complete1.Text="Please select a group"}
            $result = $Currentgroups.Items.Clear(); 
           cgroups; 
           cclear; 
            
}) 
$removeButton.location = new-object system.drawing.point(17,380) 
$removeButton.Font = "Microsoft Sans Serif,10" 
 $result = $Form.controls.Add($removeButton) 
 
$DistributionGroups.Add_click({
	$groupMembersBox.Items.Clear()
	$groupname = $DistributionGroups.SelectedItem.ToString()
	$groupMembersLabel.Text = " $groupname Group Members" 
	$groupMembers = Get-ADistributionGroupMember $DistributionGroups.SelectedItem.ToString() | select name   
	Foreach($member in $groupMembers){
		 $result = $groupMembersBox.Items.add($member.Name)
	}
	$SecurityGroups.ClearSelected() 
})
$SecurityGroups.Add_click({
	$groupMembersBox.Items.Clear()
	$groupname = $SecurityGroups.SelectedItem.ToString()
	$groupMembersLabel.Text = " $groupname Group Members" 
	$groupMembers = Get-ADistributionGroupMember $SecurityGroups.SelectedItem.ToString() | select name   
	Foreach($member in $groupMembers){
		 $result = $groupMembersBox.Items.add($member.Name)
	}
	$DistributionGroups.ClearSelected() 
})
 
SecurityGroups 
DistributionGroups 
 
[void]$Form.ShowDialog() 
$Form.Dispose()