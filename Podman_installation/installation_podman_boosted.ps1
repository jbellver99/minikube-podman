######################################################################################################
# Creation: XX/09/2021 Timothé Paty
# Description: 	Script to install podman on windows.
#			   	It will also get the solution to make podman-compose work
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason

####################################################################################################

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
	Write-Host "the installation has failed" -ForegroundColor Red
	Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
 }	
}



echo "creating C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1"
if (Test-Path C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1)
{
	echo "directory already exists, step skipped"
}
else
{
	New-Item -Type directory "C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1"
	MSG_ERROR -step "creating C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1" -return_code $?
}
# ---------------------------------	
echo "downloading the Podman archive"
Invoke-WebRequest -Uri https://github.com/containers/podman/releases/download/v2.2.1/podman-remote-release-windows.zip -OutFile C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip
MSG_ERROR -step "downloading the Podman archive" -return_code $?
# ---------------------------------------------------------
echo "extracting podman archive"
Expand-Archive "C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip" -DestinationPath "C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1"
MSG_ERROR -step "extracting podman archive" -return_code $?
# -----------------------------------------------------
echo "copy the podman-compose and uninstallation scripts in the podman folder"
cp ./scripts/* C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1
MSG_ERROR -step "copy the podman-compose scripts in the podman folder" -return_code $?
# ---------------------------------	
echo "starting minikube.."

minikube start --driver=hyperv --container-runtime=cri-o --cpus 4 --memory 3500 --disk-size '40000mb'

MSG_ERROR -step "starting minikube" -return_code $?	
# ---------------------------------	
echo "creating powershell profile"
New-Item -Type File -Force $PROFILE
MSG_ERROR -step "creating powershell profile" -return_code $?	
# ---------------------------------	
echo "writing in the profile file: " $profile
echo "& minikube -p minikube podman-env | Invoke-Expression" | out-file C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "`$env:Path += `";C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1;;C:\Users\$($env:USERNAME)\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\Scripts`""  >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias docker podman"  >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias podman-compose C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\podman_compose_Windows_part.ps1"  >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias minikube_save_images C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\save_images.ps1" >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias minikube_load_images C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\load_images.ps1" >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias copy_registry_conf C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\copy_registry_conf.ps1" >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo "Set-Alias podman C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\podman_arg_check.ps1" >> C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
MSG_ERROR -step "writing in the profile file: " -return_code $?	
# ---------------------------------	
echo "loading the profile"
$PROFILE
MSG_ERROR -step "loading the profile" -return_code $?	
Write-Host "installation succeed" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
