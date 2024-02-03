# List of vCenter server addresses
$vCenterServers = @(
    "axpreesxecomvc.ecommerce.inditex.grp","ax2vcfmgtesxvc.central.inditex.grp","ax1vcfmgtesxvc.central.inditex.grp","axinesxvc.central.inditex.grp","axinesxemeavc.central.inditex.grp","axinesxoravc.central.inditex.grp","axinesxeolvc.central.inditex.grp","apsgesxvc.sedes.inditex.grp","ax1vcfproesxvc.central.inditex.grp",
    "ax2vcfmgtesxvc.central.inditex.grp","ax2vcfproesxvc.central.inditex.grp","vc.f41a0b75dc6f4d408c2101.eastus.avs.azure.com","vc.030d21b5f19546bcad25e.southcentralus.avs.azure.com","vc.afaa95e029214c998a7bbc.southeastasia.avs.azure.com","vc.8237cf57123044169b9d4f.eastasia.avs.azure.com","axinesxctxvc.central.inditex.grp","axinesxlabvc.central.inditex.grp","axinesxvc01.central.inditex.grp","axec1esxvc.ecommerce.inditex.grp","axec2esxvc.ecommerce.inditex.grp","axinesxecomvc.central.inditex.grp","axieec1esxvc.ecommerce.inditex.grp","axieec2esxvc.ecommerce.inditex.grp","apsgesxecomvc.central.inditex.grp"
)

# VM name to search for
$vmName = Read-Host "Enter VM name to search for"

# Create an array to hold the results
$results = @()

# Define the scriptblock to run in each runspace
$scriptBlock = {
    param($vCenterServer, $vmName, $credential, [ref]$foundVM)
    
    # Suppress the verbose connection output using redirection
    Connect-VIServer -Server $vCenterServer -Credential $credential -WarningAction SilentlyContinue | Out-Null
    
    # Search for the VM by name
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    
    # If VM found, update the flag and output the result
    if ($vm) {
        $foundVM.Value = $true
        Write-Output "The VM '$vmName' was found in the vCenter '$vCenterServer'"
    }
    
    # Disconnect from the vCenter server
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false | Out-Null
}

# Create a flag to indicate if VM was found
$foundVM = [ref] $false

# Create and start runspaces
$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

$runspaces = @()

foreach ($vCenterServer in $vCenterServers) {
    # Skip additional searches if VM has been found
    if (-not $foundVM.Value) {
        $runspace = [powershell]::Create().AddScript($scriptBlock).AddArgument($vCenterServer).AddArgument($vmName).AddArgument($credential).AddArgument($foundVM)
        $runspace.RunspacePool = $runspacePool
        $runspaces += [PSCustomObject]@{
            Pipe = $runspace
            Status = $runspace.BeginInvoke()
        }
    }
}

# Wait for runspaces to complete
foreach ($rs in $runspaces) {
    $rs.Pipe.EndInvoke($rs.Status)
    $rs.Pipe.Dispose()
}

# Clean up runspace pool
$runspacePool.Close()
$runspacePool.Dispose()

# If VM wasn't found, display a message
if (-not $foundVM.Value) {
    Write-Output "The VM '$vmName' was not found in any vCenter."
}