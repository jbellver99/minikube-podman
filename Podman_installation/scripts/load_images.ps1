######################################################################################################
# Creation: 29/09/2021 Timothé Paty
# Description: 	Script that start minikube (if asked) and load images that had been saved previously with the save_images.ps1 script
#			   	As a "minikube stop" delete all images existing, this couple of script exist to replace the use of minikube stop/start
#				It also deletes the tar file after a sucessful load
#
# Arguments: 	-s: If you want to start the VM (if the VM is n ot started the script will not work)
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							29/09/2021	adding something because of a reason
#
######################################################################################################
if ($args -contains '-h' -or $args -contains '--help')
{
	echo "Script that start minikube (if asked) and load images that had been saved previously with the save_images.ps1 script"
	echo "As a "minikube stop" delete all images existing, this couple of script exist to replace the use of minikube stop/start"
	echo "It also deletes the tar file after a sucessful load"
	echo "--"
	echo "arguments: -s: If you want to start the VM (if the VM is n ot started the script will not work)"
	exit
}

if ( $args -contains '-s')
{
	echo "-s flag detected, starting minikube ..."
	minikube start
	& minikube -p minikube podman-env | Invoke-Expression
	$ret=$?
	if (-not $ret)
	{
		Write-Host "minikube start has failed, please check the reason" -ForegroundColor Red
		exit 1
	}
}else{
	& minikube -p minikube podman-env | Invoke-Expression
	$ret=$?
	if (-not $ret)
	{
		Write-Host "minikube seems to be shut down, please check the status of the VM" -ForegroundColor Red
		Write-Host "You can us the '-s' to start the VM" -ForegroundColor Yellow
		exit 1
	}
}
	


$tar_list=$(ls C:\Users\$($env:USERNAME)\tmp_images | Select-Object -ExpandProperty Name)
$old_path=$(pwd | Select-Object -ExpandProperty Path)
cd C:\Users\$($env:USERNAME)\tmp_images
foreach ($i in $tar_list)
{
	podman image load -i .\$i
	if ($?)
	{
		Write-Host "the loading of the image $i has succeeded, deleting tar file" -ForegroundColor Green
		rm $i
	}else{
		Write-Host "the loading of the image $i has failed, you need to check manually what happened" -ForegroundColor Red
		Write-Host "The command used was: 'podman image load -i .\$i' (played from this directory: C:\Users\$($env:USERNAME)\tmp_images) " -ForegroundColor Red
	}
	echo "---------"
}

cd $old_path