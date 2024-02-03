$Server = Read-Host "Vcenter: "
$Cluster = Read-Host "Cluter: "
Connect-ViServer $Server -credential $credential

Get-Cluster $Cluster | Get-VM | Get-VIEvent -Start (Get-Date).AddDays(-0.5) | where {$_.FullFormattedMessage -match "vSphere HA restarted virtual machine"} | select ObjectName,@{N="IP addr";E={(Get-view -Id $_.Vm.Vm).Guest.IpAddress}},CreatedTime,FullFormattedMessage | sort CreatedTime -Descending