$Server = Read-Host "Escribe el nombre del vCenter en el cual buscar la VM:"
$VM = Read-Host "Escribe el nombre de la máquina virtual:"
Connect-ViServer $Server -credential $credential
Get-VM $VM | Get-Snapshot | Select-Object vm ,name, description, created, sizeGB