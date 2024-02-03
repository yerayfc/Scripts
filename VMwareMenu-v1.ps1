$MainMenu = {
    Write-Host " **************************************************"
    Write-Host " *           Menu de Utilidades de VMWare         *"
    Write-Host " **************************************************"
    Write-Host
    Write-Host " 1.) Buscador VM"
    Write-Host " 2.) Listar Snapshot de VM"
    Write-Host " 3.) Listado de discos de VM"
    Write-Host " 4.) Buscador de Hosts físicos"
    Write-Host " 5.) HA Failover"
    Write-Host " 6.) Buscador de Clusters"
    Write-Host " 0.) Quit"
    Write-Host
    Write-Host " Select an option and press Enter: "  -nonewline
    }
# Control de errores a la hora de meter el usuario del Dominio
while ($domain.name -eq $null) {
    $cred = $null
    $cred = Get-Credential
    $username = $cred.username
    $password = $cred.GetNetworkCredential().password
    $CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
    $domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)
    if ($domain.name -eq $null){
    Write-Host "Login fallido - por favor, vuelve a reintentarlo." 
        }
    else{
        Write-Host "Dominio: $domain.name"
        
    }
}

function general {
    param (
        [Parameter(Mandatory = $true)] [string] $a,
        [Parameter(Mandatory = $true)] $b,
        [Parameter(Mandatory = $true)] $c,
        [Parameter(Mandatory = $false)] $d,
        [Parameter(Mandatory = $false)] $e
    )
    while ( ($nombreVM -eq $null) -or ($nombreVM -eq "" ) ) {
        $nombreVM = Read-Host "Escribe el nombre de $a"
        $nombreVM = $nombreVM -replace(" ","")
    }
    $servidores = @("axinesxvc.central.inditex.grp", "axinesxemeavc.central.inditex.grp","axinesxoravc.central.inditex.grp", "axinesxeolvc.central.inditex.grp", "apsgesxvc.sedes.inditex.grp", "ax1vcfmgtesxvc.central.inditex.grp", "ax1vcfproesxvc.central.inditex.grp","ax2vcfmgtesxvc.central.inditex.grp", "ax2vcfproesxvc.central.inditex.grp", "axinesxctxvc.central.inditex.grp","axinesxlabvc.central.inditex.grp", "axinesxvc01.central.inditex.grp", "axec1esxvc.ecommerce.inditex.grp", "axec2esxvc.ecommerce.inditex.grp", "axinesxecomvc.central.inditex.grp", "axieec1esxvc.ecommerce.inditex.grp", "axieec2esxvc.ecommerce.inditex.grp", "apsgesxecomvc.central.inditex.grp", "axpreesxecomvc.ecommerce.inditex.grp", "vc.f41a0b75dc6f4d408c2101.eastus.avs.azure.com", "vc.030d21b5f19546bcad25e.southcentralus.avs.azure.com", "vc.afaa95e029214c998a7bbc.southeastasia.avs.azure.com", "vc.8237cf57123044169b9d4f.eastasia.avs.azure.com" ) 
    foreach ($servidor in $servidores) {
        $notOnScreen1 = Connect-VIServer $servidor -Credential $cred
        $vm = & $b 
        if ($vm) {
            & $c
            & $d      
            Read-Host -Prompt "Presiona intro para volver al menú" 
            break
        }
        else {
            & $e
        }
    }
    & Clear-Variable -Name DefaultVIServers, nombreVM
    & Disconnect-VIServer -Server $servidor -Confirm:$false -Force   
}
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false

do {
    cls
    Invoke-Command $MainMenu
    $MenuOption = Read-Host
    switch ($MenuOption) {
        1 {
            $a = "la VM"
            $b = {Get-VM -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0}
            $c = {Write-Host "La máquina  $nombreVM se encuentra en el servidor $servidor"}
            $d = {Start-Process chrome.exe -ArgumentList @("https://$servidor/ui/app/search?query=$nombreVM&searchType=simple")}
            $e = {Write-Host "La máquina  $nombreVM NO se encuentra en el servidor $servidor"}
            general $a $b $c $d $e
        }
        2 {
            $a = "la VM"
            $b = {Get-VM -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0}
            $c = {Write-Host "La máquina  $nombreVM se encuentra en el servidor $servidor"}
            $d = {Get-VM $nombreVM | Get-Snapshot | Select-Object vm ,name, description, created}
            $e = {Write-Host "La máquina  $nombreVM NO se encuentra en el servidor $servidor"}
            general $a $b $c $d $e
        }
        3 {
            $a = "la VM"
            $b = {Get-VM -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0}
            $c = {Get-VM $nombreVM -PipelineVariable vm | ForEach-Object -Process {
                $vm.ExtensionData.Guest.Disk | Select-Object -Property @{N='VM';E={$vm.Name}},DiskPath, @{N="Espacio Total(GB)";E={[math]::Round($_.Capacity/ 1GB)}}, @{N="Espacio Libre(GB)";E={[math]::Round($_.FreeSpace / 1GB)}}, @{N="Espacio Libre(%";E={[math]::Round(((100* ($_.FreeSpace))/ ($_.Capacity)),0)}}} 
            }
            $d = {$VmView = Get-View -ViewType VirtualMachine -Filter @{"Name" = $nombreVM}
                foreach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | where {$_.DeviceInfo.Label -match "SCSI Controller"})) {
                    foreach ($VirtualDiskDevice in ($VMView.Config.Hardware.Device | where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
                        Get-VM $nombreVM | Select Name, @{N="DiskName";E={$VirtualDiskDevice.DeviceInfo.Label}}, @{N="CanonicalName";E={(Get-VM $nombreVM | Get-Harddisk -Name ($VirtualDiskDevice.DeviceInfo.Label)).ScsiCanonicalName}}, @{N="SCSI_Id";E={"$($VirtualSCSIController.BusNumber) : $($VirtualDiskDevice.UnitNumber)"}}, @{N="DiskFile";E={$VirtualDiskDevice.Backing.FileName}}, @{N="DiskSize(GB)";E={$VirtualDiskDevice.CapacityInKB * 1KB / 1GB}}
                    }
                }
            }
            $e = {Write-Host "La máquina  $nombreVM NO se encuentra en el servidor $servidor"}
            general $a $b $c $d $e
        }
        4{   
            $a = "el Host (Ponel el FQDN)"
            $b = {Get-VMHost -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0}
            $c = {Write-Host "El host físico $nombreVM se encuentra en el servidor $servidor"}
            $d = {Start-Process chrome.exe -ArgumentList @("https://$servidor/ui/app/search?query=$nombreVM&searchType=simple")}
            $e = {Write-Host "El host físico  $nombreVM NO se encuentra en el servidor $servidor"}
            general $a $b $c $d $e
        }
        5{
            $a = "la VM"
            $b = {Get-VM -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0}
            $c = {Write-Host "El clúster  $nombreVM se encuentra en el servidor $servidor"}
            $d = {Get-Cluster $Cluster | Get-VIEvent -Start (Get-Date).AddDays(-0.5) | where {$_.FullFormattedMessage -match "vSphere HA restarted virtual machine"} | select ObjectName,@{N="IP addr";E={(Get-view -Id $_.Vm.Vm).Guest.IpAddress}},CreatedTime,FullFormattedMessage | sort CreatedTime -Descending}
            $e = {Write-Host "El clúster  $nombreVM NO se encuentra en el servidor $servidor"}
            general $a $b $c $d $e
        }
        6{
            $a = "el Clúster"
            $b = {Get-Cluster -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0}
            $c = {Write-Host "El clúster $nombreVM se encuentra en el servidor $servidor"}
            $d = {Start-Process chrome.exe -ArgumentList @("https://$servidor/ui/app/search?query=$nombreVM&searchType=simple")}
            $e = {Write-Host "El clúster  $nombreVM NO se encuentra en el servidor $servidor"}
            general $a $b $c $d $e 
        }
        Default {
        }
    }
        
} while ( $MenuOption -ne 0 )
if ( $MenuOption -eq 0 ) {
    $cred = $null
    Write-Host "Adios :)"
}