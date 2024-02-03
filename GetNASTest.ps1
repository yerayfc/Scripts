$variable = Read-Host "Please enter the path to the item you want to get ACL information for:"
Get-Item -Path "$variable" | Get-ACL | Format-List -Property Path,AccessToString