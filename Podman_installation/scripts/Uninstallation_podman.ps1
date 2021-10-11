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
$profile_podman="C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile_podman.ps1"
$ShortcutLocation = "C:\Users\$($env:USERNAME)\Desktop\podman_client.lnk"

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
echo "Deleting profile $profile_podman"
if (Test-Path $profile_podman)
{
rm $profile_podman
MSG_ERROR -step "deleting profile" -return_code $?
}else{
  Write-Host "the profile $profile_podman was not found, its removal has been skipped" -ForegroundColor Yellow
}

#-----------------------------------------------
echo "deleting shortcut"
if (Test-Path $ShortcutLocation)
{
rm $ShortcutLocation
MSG_ERROR -step "deleting shortcut" -return_code $?
}else{
  Write-Host "the shortcut $ShortcutLocation was not found, its removal has been skipped" -ForegroundColor Yellow
}
# #------------------------------------------------
echo "stopping and removing the minikube VM"
minikube delete
MSG_ERROR -step "removing the minikube VM" -return_code $?
#------------------------------------------------
echo "removing podman folder"
if (Test-Path $podman_folder_bin)
{
  rm -r $podman_folder_bin
  MSG_ERROR -step "removing podman" -return_code $?
}else{
  Write-Host "the folder $podman_folder_bin was not found, its removal has been skipped" -ForegroundColor Yellow
}

#------------------------------------------------
echo "removing podman-remote-release-windows.zip"
if (Test-Path C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip)
{
  rm -r C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip
  MSG_ERROR -step "removing podman-remote-release-windows.zip" -return_code $?
}else{
  Write-Host "The archive 'podman-remote-release-windows.zip' was not found in 'C:\Users\$($env:USERNAME)\Downloads', its removal is skipped" -ForegroundColor Yellow
}
Write-Host "Uninstallation succeded" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
