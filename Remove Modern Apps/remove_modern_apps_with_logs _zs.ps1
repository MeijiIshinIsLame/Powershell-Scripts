#Script that removes a list of modern apps and logs the results.
#Written by Zachary Silva

PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""C:\New_AppRemoval_ZS\remove_modern_apps_with_logs _zs.ps1""' -Verb RunAs}";

Write-Host "Started..."

New-Item .\logs.txt
New-Item .\apps_before.txt
New-Item .\apps_after.txt
New-Item .\check_apps.txt


#empty array for app list
$app_list = @()

#fill app_list from app_list.txt
foreach($line in Get-Content .\app_list.txt) {
    $app_list += $line
}

#wite to packages log before we uninstall
Get-AppxPackage -AllUsers | Select Name, PackageFullName >> .\apps_before.txt
"------------------------------------------------------------------------------" >> .\apps_before.txt

#delete packages
foreach($app in $app_list){
    Get-AppxPackage -AllUsers *$app* | Remove-AppxPackage -AllUsers
    Write-Host "Removing: $app"
    Get-AppxLog >> .\logs.txt
    Write-Host "$app - Operation Finished! (see logs for more info)"
    Write-Host "   "
}

#write to packages log after uninstall to compare
Get-AppxPackage -AllUsers | Select Name, PackageFullName >> .\apps_after.txt
"------------------------------------------------------------------------------" >> .\apps_after.txt

#check if apps are still on the system, write to check_apps.txt
foreach($app in $app_list){
    $app >> .\check_apps.txt
    Get-AppxPackage -Name *$app* | select Name, version, PackageFamilyName >> .\check_apps.txt
}

"------------------------------------------------------------------------------" >> .\check_apps.txt
"------------------------------------------------------------------------------" >> .\logs.txt

Write-Host "Finished!"
Set-ExecutionPolicy Restricted
Write-Host "Execution Policy set to restricted"