#Script that monitors group of computers for power and logged in user.
#Used for troubleshooting WoL issues.
#Written by Zachary Silva

Function chooseGroup
{
	Write-Host "Please choose a group to search."
	#Group names redacted for privacy.
	Write-Host "0=group0 1=group1 2=group2 3=group3"
	Write-Host ""
	
	$groupList = "group0 group1 group2 group3".Split(" ")
	$choice = Read-Host 'Group Number'

	$choice = [int]$choice
	$CheckOU = $groupList[$choice]

	if ($CheckOU)
	{
		$computerList = getComputerList($CheckOU)
	}
	else
	{
		"ERROR: Must input a number from 0-9"
	}
	return $computerList
}
	
	
Function getComputerList
{
	param($CheckOU)
	
	$filteredComputers = @()
	
	$computers = Get-ADComputer -Filter * | select Name
	
	foreach ($computerName in $computers)
	{
		$computerName = $computerName.name.ToString()
		
		$user = get-adcomputer "$computerName" -Properties *
		$groups = $user.DistinguishedName
		
		If($groups.Contains($CheckOU))
		{
			$filteredComputers += $computerName
		}
	}
	return $filteredComputers	
}

while($true)
{
	$computers = chooseGroup
	foreach ($computerName in $computers)
	{
		Write-Host "Last Checked: $(Get-Date)"
		
		if (Test-Connection -Count 1 -ComputerName "$computerName" -Quiet)
		{
			Write-Host "$computerName is on!"
			$currUser = Get-WMIObject -ComputerName "$computerName" -class Win32_ComputerSystem | select username
			if ($currUser.username)
			{
				Write-Host "$currUser.username is logged on."
			}
			else
			{
				Write-Host "No one is logged on."
			}
		}
		else
		{
			Write-Host "$computerName is off!"
		}
	}
	Write-Host "--------------------------------------------------------"
	Start-Sleep -s 30
}