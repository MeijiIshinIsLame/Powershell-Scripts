#Simple script that returns all the computers in an Active Directory group.
#Written by Zachary Silva

while ($true)
{
	$OU = @() 
	$CheckOU = Read-Host 'Group Name: '
	$computers = Get-ADComputer -Filter * | select Name

	foreach ($computerName in $computers)
	{
		$computerName = $computerName.name.ToString()
		
		$user = get-adcomputer "$computerName" -Properties *
		$groups = $user.DistinguishedName
		
		If($groups.Contains($CheckOU))
		{
			Write-Host "$computerName"
		}
	}
}