#Checks an Active Directory group to see what computers are on, and who is using them.
#Written by Zachary Silva

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

Function checkIfOnline
{
	param($computers)
	
	Write-Host ""
	
	foreach ($computer in $computers)
	{
		if (Test-Connection -Count 1 -ComputerName "$computer" -Quiet)
		{
			Write-Host "$computer is on!"
			$currUser = Get-WMIObject -ComputerName "$computer" -class Win32_ComputerSystem | select username
			if ($currUser.username)
			{
				$currUser = $currUser.username.Split("\")[1]
				Write-Host "$currUser is logged on."
			}
			else
			{
				Write-Host "No one is logged on."
			}
		}
		else
		{
			Write-Host "$computer is off!"
		}
		Write-Host ""
	}
}

#main
while($true)
{
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
		checkIfOnline($computerList)
	}
	else
	{
		"ERROR: Must input a number from 0-9"
	}
}