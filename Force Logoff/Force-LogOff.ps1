#Script that allows an admin to remotely force a user or computer to log off.
#Written by Zachary Silva

Function chooseGroup
{
	Write-Host "Please choose a group to search."
	#Group names redacted for privacy.
	Write-Host "0=group0 1=group1 2=group2 3=group3"
	Write-Host ""	
	$groupList = "group0 group1 group2 group3".Split(" ")
	Write-Host ""
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

Function get-value-array{
	param($objectRow)
	
	$rowNames = @()
	
	$objectRow = $objectRow -replace '  ', '|' -split ""

	for ($i = 0; $i -lt $objectRow.Count; $i++){	

		if($objectRow[$i] -contains "|"){
		
			if($objectRow[$i-1] -contains "|"){
				continue
			}
			
			if($fullString[0] -contains " "){
				$fullString = $fullString.substring(1)
			}
			
			$rowNames += $fullString
			$fullString = ""
		}
		else{
			$fullString += $objectRow[$i]
		}
	}
	return $rowNames
}

Function make-hashtable{
	Param($objects,$values)

	$table = @{}

	for ($i = 0; $i -lt $objects.Count; $i++)
	{
		$table += @{$objects[$i] = $values[$i]}
	}
	return $table
}

Function not-logged-in{
	Param($computerName)
	
	$sessionObject = quser /server:$computerName
	
	try{
		$objectRow = $sessionObject[0]
	}
	catch
	{
		return $true
	}
	return $false
}

#main
while($true)
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
	$computerName += $computers[$choice-1]

	$sessionObject = quser /server:$computerName

	if(not-logged-in $computerName){
		"No user is logged in."
	}
	else{
		$objectRow = $sessionObject[0]
		$valueRow = $sessionObject[1]
		$fullString = ""

		$objects = get-value-array($objectRow)
		$values = get-value-array($valueRow)
		$dict = make-hashtable $objects $values
		$sessionId = $dict.Item("ID")
		$username = $dict.Item("USERNAME")
		
		"Logging off $username..."
		
		$msg = "A remote logoff has been initiated. This computer will log off in 30 seconds! Please save all work..."
		Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $computerName
		Start-Sleep -s 30
		
		logoff $sessionId /server:$computerName
		
		if(not-logged-in $computerName){
			"$username has been logged out."
		}
		else{
			"logout Failed"
		}
	}
}