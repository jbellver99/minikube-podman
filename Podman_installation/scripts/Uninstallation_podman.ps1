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
$ShortcutLocation = "C:\Users\$($env:USERNAME)\Desktop\Podman_Client.lnk"

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
MSG_ERROR -step "Deleting profile" -return_code $?
}else{
  Write-Host "the profile $profile_podman was not found, its removal has been skipped" -ForegroundColor Yellow
}

#-----------------------------------------------
echo "Deleting shortcut"
if (Test-Path $ShortcutLocation)
{
rm $ShortcutLocation
MSG_ERROR -step "Deleting shortcut" -return_code $?
}else{
  Write-Host "the shortcut $ShortcutLocation was not found, its removal has been skipped" -ForegroundColor Yellow
}
# #------------------------------------------------
echo "Stopping and removing the minikube VM"
minikube delete
MSG_ERROR -step "Removing the minikube VM" -return_code $?
#------------------------------------------------
echo "Removing podman folder"
if (Test-Path $podman_folder_bin)
{
  rm -r $podman_folder_bin
  MSG_ERROR -step "removing podman" -return_code $?
}else{
  Write-Host "the folder $podman_folder_bin was not found, its removal has been skipped" -ForegroundColor Yellow
}

#------------------------------------------------
echo "Removing podman-remote-release-windows.zip"
if (Test-Path C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip)
{
  rm -r C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip
  MSG_ERROR -step "Removing podman-remote-release-windows.zip" -return_code $?
}else{
  Write-Host "The archive 'podman-remote-release-windows.zip' was not found in 'C:\Users\$($env:USERNAME)\Downloads', its removal is skipped" -ForegroundColor Yellow
}

#------------------------------------------------
echo "Removing ICS"
Start-Process -wait powershell "${podman_folder_bin}\disable_ICS.ps1" -Verb runAs
MSG_ERROR -step "Removing ICS" -return_code $?

#------------------------------------------------
echo "Removing the virtual switch"
Remove-VMSwitch -Name "Minikube_VM" 
MSG_ERROR -step "Removing the virtual switch" -return_code $?

#------------------------------------------------
echo "Removing the key in the registry to remove the option 'open podman here'"
start-process -wait powershell "rm HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman -R" -verb runAs
MSG_ERROR -step "removing the key in the registry to remove the option 'open podman here'" -return_code $?
Write-Host "Uninstallation succeded" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
