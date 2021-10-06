######################################################################################################
# Creation: XX/09/2021
# Description: 	Script to uninstall podman on windows.
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason
#
######################################################################################################

$podman_folder="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder}\bin"

function MSG_ERROR {
 param( [string]$step, $return_code)
 if ($return_code)
 {
	Write-Host "step: $step has succeed" -ForegroundColor Green
	echo "--"
	echo ""
 }
 else
 {
	Write-Host "a problem occured in the step: $step" -ForegroundColor Red
	Write-Host "stopping the script..." -ForegroundColor Red
	Write-Host "the uninstallation has failed" -ForegroundColor Red
	Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
 }
}

$date_save=$(Get-Date -Format "yyyyMMdd.HHmm")
echo "Uninstallation of podman"
echo "Deleting profile C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1, (there is a save under the name C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile.$($date_save) (if it still exists)"
if (Test-Path C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1)
{
mv C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile.$date_save
}
MSG_ERROR -step "deleting profile" -return_code $?
#------------------------------------------------
echo "stopping and removing the minikube VM"
minikube delete
MSG_ERROR -step "removing the minikube VM" -return_code $?
#------------------------------------------------
echo "removing podman"
rm -r $podman_folder_bin
MSG_ERROR -step "removing podman" -return_code $?
#------------------------------------------------
echo "removing podman-remote-release-windows.zip"
rm -r C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip
MSG_ERROR -step "removing podman-remote-release-windows.zip" -return_code $?
Write-Host "Uninstallation succeded" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
