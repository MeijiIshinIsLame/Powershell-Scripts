#Checks through all users of a certain group, and makes sure they are both in the group and a member of the group.
#If not, proper permissions are added as a group member.
#Written by Zachary Silva

$users = Get-ADUser -Properties memberof -Filter * | select SamAccountName, DistinguishedName, MemberOf

foreach($user in $users)
{
	if($user.DistinguishedName -like '*Redacted*')
	{
		if(!$user.MemberOf)
		{
			Write-Host $user.SamAccountName $user.DistinguishedName $user.MemberOf
			$username = $user.SamAccountName.ToString()
			Add-ADGroupMember -Identity "redacted" -Members "$username"
		}
	}
}