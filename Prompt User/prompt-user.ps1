#Script that gives the user or computer a message prompt remotely.
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


Function getUsersToPrompt
{
	param($computers)
	
	foreach ($computer in $computers)
	{
		if (Test-Connection -Count 1 -ComputerName "$computer" -Quiet)
		{
			$currUser = Get-WMIObject -ComputerName "$computer" -class Win32_ComputerSystem | select username
			if ($currUser.username)
			{
				$currUser = $currUser.username.Split("\")[1]
				if ($currUser -eq $usertoBoot)
				{
					$computersToPrompt += $computer
				}
			}
		}
	}
	return $computersToPrompt
}

while ($true)
{
	$option = Read-Host "Would you like to prompt a user or computer? (0=computer 1=user)"

	if ($option -eq 0)
	{
		$computers = chooseGroup
		$i = 1	
		$options = @()
		
		foreach ($computer in $computers)
		{
			$options += $computer
			Write-Host $i = $computer
			$i += 1
		}
		$choice = Read-Host 'Choose a computer by number'
		$computersToPrompt += $computers[$choice-1]
	}

	if ($option -eq 1)
	{
		$usertoBoot = Read-Host 'Username to prompt'
		$computers = chooseGroup
		$computersToPrompt = getUsersToPrompt($computers)	
	}

	if($computersToPrompt)
	{
		$msg = Read-Host 'Please type message for user'
		foreach ($computer in $computersToPrompt)
		{
			Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $computer
		}
	}
	else
	{
		"ERROR: No computers chosen."
	}
}