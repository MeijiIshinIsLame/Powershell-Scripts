#Script that returns a text file with what modern apps are installed on the system.
#Written by Zachary Silva

#empty array for app list
$app_list = @()

#fill app_list from app_list.txt
foreach($line in Get-Content .\app_list.txt) {
    $app_list += $line
}

foreach($app in $app_list){
    $app >> .\check_apps2.txt
    Get-AppxPackage -Name *$app* | select Name, version, PackageFamilyName >> .\check_apps2.txt
}

"------------------------------------------------------------------------------" >> .\check_apps2.txt