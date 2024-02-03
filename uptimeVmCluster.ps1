# Connect to vCenter Server
$vcServer = Read-Host "Vcenter: "
Connect-ViServer $vcServer -credential $credential

# Cluster details
$clusterName = Read-Host "Cluter: "

# Get VMs in the specified cluster
$cluster = Get-Cluster -Name $clusterName
$vms = Get-VM -Location $cluster

# Define function to calculate uptime
function Get-Uptime {
    param([Nullable[DateTime]]$startTime)

    if ($startTime -eq $null) {
        return New-TimeSpan
    }

    $currentTime = Get-Date
    $uptime = $currentTime - $startTime
    return $uptime
}

# Create an array to store VM objects with uptime
$vmList = @()

# Populate the array with VMs and their uptime
foreach ($vm in $vms) {
    $vmUptime = Get-Uptime -startTime $vm.ExtensionData.Runtime.BootTime
    $vmObject = New-Object PSObject -Property @{
        VMName = $vm.Name
        Uptime = $vmUptime
    }
    $vmList += $vmObject
}

# Sort VMs by uptime in ascending order
$sortedVMs = $vmList | Sort-Object Uptime

# Display sorted VMs and uptime
foreach ($sortedVM in $sortedVMs) {
    $uptimeFormatted = "{0:D2} days, {1:D2}:{2:D2}:{3:D2}" -f $sortedVM.Uptime.Days, $sortedVM.Uptime.Hours, $sortedVM.Uptime.Minutes, $sortedVM.Uptime.Seconds
    Write-Host "VM: $($sortedVM.VMName) | Uptime: $uptimeFormatted"
}

# Disconnect from vCenter Server
Disconnect-VIServer -Server $vcServer -Confirm:$false