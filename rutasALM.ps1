"Rutas NETAPP"
foreach ($ruta in (echo "\\axdessmb4\eaivardes,\\axpresmb4\eaivartest,\\axinnasctx\fslogix01$,\\axinnasappv11\LOISSGECORE,\\axinnaseai\eaivar15,\\axinnasappv14\B2BSftp,\\axinnasapp\EccStgPB").split(",")) {Write-Host "$ruta : "$(test-path $ruta)}
"RUTAS ISILON"
foreach ($ruta in (echo "\\axinfsfotos.central.inditex.grp\zcom$,\\axinnasappv7.central.inditex.grp\axstgzara1,\\axinnasappv8\DMDistribucion,\\axinnasappv1.central.inditex.grp\appv,\\axinnasappv6\BackupAD,\\axinnasev1\EVSMTP1P1").split(",")) {Write-Host "$ruta : "$(test-path $ruta)}
"RUTAS  VNX-file / eNAS (Celerra)"
Write-Host "$ruta : "$(test-path \\axinnascava1\OTAS01)