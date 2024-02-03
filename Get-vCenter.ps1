$nombreVM = Read-Host "Escribe el nombre de la máquina virtual:"
Write-Output $nombreVM
$credenciales = Get-Credential
$servidores = @("axinesxvc.central.inditex.grp", "axinesxemeavc.central.inditex.grp","axinesxoravc.central.inditex.grp", "axinesxeolvc.central.inditex.grp", "apsgesxvc.sedes.inditex.grp", "ax1vcfmgtesxvc.central.inditex.grp", "ax1vcfproesxvc.central.inditex.grp","ax2vcfmgtesxvc.central.inditex.grp", "ax2vcfproesxvc.central.inditex.grp", "vc.f41a0b75dc6f4d408c2101.eastus.avs.azure.com", "vc.030d21b5f19546bcad25e.southcentralus.avs.azure.com", "vc.afaa95e029214c998a7bbc.southeastasia.avs.azure.com", "vc.8237cf57123044169b9d4f.eastasia.avs.azure.com", "axinesxctxvc.central.inditex.grp","axinesxlabvc.central.inditex.grp", "axinesxvc01.central.inditex.grp", "axec1esxvc.ecommerce.inditex.grp", "axec2esxvc.ecommerce.inditex.grp", "axinesxecomvc.central.inditex.grp", "axieec1esxvc.ecommerce.inditex.grp", "axieec2esxvc.ecommerce.inditex.grp", "apsgesxecomvc.central.inditex.grp", "axpreesxecomvc.ecommerce.inditex.grp" ) 

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false

foreach ($servidor in $servidores) {
	$notOnScreen1 = Connect-VIServer $servidor -Credential $credenciales
	$vm = Get-VM -Name $nombreVM -ErrorAction SilentlyContinue -WarningAction 0
	
	if ($vm) {
        Write-Host "La máquina virtual $nombreVM se encuentra en el servidor $servidor"
        break
    } else {
        Write-Host "La máquina virtual $nombreVM no se encuentra en el servidor $servidor"
    }

Disconnect-VIServer -Server $servidor -Confirm:$false
}