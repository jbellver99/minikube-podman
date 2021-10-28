######################################################################################################
# Creation: 29/09/2021 Timothé Paty
# Description: 	Script that save images that exist inside the minikube VM, and stop the VM if asked
#			   	As a "minikube stop" delete all images existing, this couple of script exist to replace the use of minikube stop/start
#
# Arguments: 	-s: If you want to stop the VM
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							29/09/2021	adding something because of a reason
#
######################################################################################################

if ($args -contains '-h' -or $args -contains '--help')
{
	echo "Script that save images that exist inside the minikube VM, and stop the VM if asked"
	echo "As a 'minikube stop' delete all images existing, this couple of script exist to replace the use of minikube stop/start"
	echo "--"
	echo "Arguments: -s: If you want to stop the VM"
	exit
}

& minikube -p minikube podman-env | Invoke-Expression
$ret=$?
if (-not $ret)
{
	Write-Host "Minikube seems to be shut down, please check the status of the VM" -ForegroundColor Red
	exit 1
}

$old_path=$(pwd | Select-Object -ExpandProperty Path)
$image_list=$(minikube ssh "sudo podman image ls -n --format 'table {{.Repository}}:{{.Tag}}'")
if (Test-Path C:\Users\$($env:USERNAME)\tmp_images)
{
	echo "The directory C:\Users\$($env:USERNAME)\tmp_images already exists, its creation is skipped"
}else{
	New-Item -Type directory "C:\Users\$($env:USERNAME)\tmp_images"
}

cd C:\Users\$($env:USERNAME)\tmp_images
echo "All tar file generated will be located in this directory: C:\Users\$($env:USERNAME)\tmp_images"
foreach ($i in $image_list)
{
	$sin_slash= $i -replace '/', '_'
	$sin_slash_hyphen= $sin_slash -replace ':', '_'
	podman image save -o .\${sin_slash_hyphen}.tar $i
	if ($?)
	{
		Write-Host "The saving of the image $i under the name ${sin_slash_hyphen}.tar has succeded" -ForegroundColor Green
		echo "--"
	}else{
		Write-Host "The saving of the image $i has failed, you need to check manually what happened" -ForegroundColor Red
		Write-Host "The command used was: 'podman image save -o .\${sin_slash_hyphen}.tar $i' (played from this directory: C:\Users\$($env:USERNAME)\tmp_images) " -ForegroundColor Red
		rm $sin_slash_hyphen
		echo "--"
	}
}

cd $old_path


if ( $args -contains '-s')
{
	echo "-s flag detected, shutting down minikube ..."
	minikube stop
}
