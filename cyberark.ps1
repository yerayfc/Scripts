New-PASSession -Credential $credentialCA -BaseURI https://axinpasweb.central.inditex.grp -Type RADIUS -OTP 1
# Get-PASAccount -SafeName PON_TU_SAFE_AQUI ## Nos saca la ID/info del safe que le indicamos
$ID = "8254_3"
$IDBF = "8254_4"
Invoke-PASCPMOperation -AccountID $ID -ReconcileTask
Write-Host "Haciendo reconcile"

$variableToCheck = Get-PASAccount -id $ID | Get-PASAccountPassword
$comparisonVariable = $variableToCheck  # Set comparison variable initially
$BF = Get-PASAccount -id $IDBF | Get-PASAccountPassword

$maxIterations = 200000  # Define a maximum number of iterations
$iteration = 0

while ($variableToCheck -eq $comparisonVariable -and $iteration -lt $maxIterations) {
    Start-Sleep -Seconds 10
    
    $variableToCheck = Get-PASAccount -id $ID | Get-PASAccountPassword
    $substring = $comparisonVariable -replace ".*Password=([^;]*);.*", '$1'
    $substringBF = $BF -replace ".*Password=([^;]*);.*", '$1'
    
    $iteration++
}

if ($variableToCheck -ne $comparisonVariable) {
    Write-Host "ADM Password: $substring"
    Write-Host "BF Password: $substringBF"
} else {
    Write-Host "Passwords did not change within $maxIterations iterations."
}