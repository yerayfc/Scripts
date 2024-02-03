Write-Host "Dont forget to setup your "$"credential=get-credential variable"
$username = Read-host "ADuser"
$domain = Read-host "Domain" -Default "central.inditex.grp"
$adUser = Get-ADUser  -Identity $username
$user = Get-ADUser $username -Properties LockedOut

If ($domain -eq "") {
    $domain = "central.inditex.grp"
}

if ($adUser) {
    if($user.LockedOut){
        Unlock-ADAccount -Identity $username -Server $domain -Credential $credential | Unlock-ADAccount
        Write-Host "Account has been unlocked"
    }
    else{
        Write-Host "Account is not locked"
    }
}
else {
    Write-Host "User $username not found in $domain"
}