#Checks the BIOS of all computers in an Active Directory group remotely.
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

Function checkBios
{
	param($computerList)
	
	foreach ($computer in $computerList)
	{
		if (Test-Connection -Count 1 -ComputerName "$computer" -Quiet)
		{
			Get-WmiObject -ComputerName "$computer" -Class Win32_Bios | Format-List -Property PSComputerName, Name, BIOSVersion, SMBIOSBIOSVersion, SMBIOSMajorVersion, SystemBiosMinorVersion, Version, ReleaseDate
		}
		else
		{
			Write-Host "$computer is off or could not be contacted."
		}
	}
}

#main
while($true)
{
	Write-Host ""
	#Group names redacted for privacy.
	Write-Host "0=group0 1=group1 2=group2 3=group3"
	Write-Host ""
	
	$groupList = "group0 group1 group2 group3".Split(" ")
	$choice = Read-Host 'Group Number'
	$choice = [int]$choice
	
	$CheckOU = $false
	
	foreach($group in $groupList)
	{
		if ($groupList.IndexOf($group) -eq $choice)
		{
			$CheckOU = $group
		}
	}
	
	if ($CheckOU)
	{
		$computerList = getComputerList($CheckOU)
		checkBios($computerList)
	}
	else
	{
		"ERROR: Must input a number from 0-9"
	}
}