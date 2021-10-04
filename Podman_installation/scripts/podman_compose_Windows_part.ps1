######################################################################################################
# Creation: 20/09/2021 Timothé Paty
# Description: 	temporary solution to use podman-compose with a windows podman configured with minikube,
#			   	waiting for podman3 included in minikube.
#				It creates a unix container with podman and podman-compose installed, generated the commands in the container,
#				and execute them in the VM
#				this script is part of 3 scripts, one in powershell (this one) which is the master script,
#				2 in bash, one of them is for the command for the VM and the other for the container
#
# Arguments: 	-m:	if you need to share a volume between the VM and the windows host (if you launch this script for the first time this is mandatory)
#					It will open another powershell prompt to run the process of sharing the folder that will still run after the script,
#					as long as you don't kill th eprocess or close the prompt, the sharing will keep going
#					if you keep the process running you won't need this flag again and have 30 sec faster script
#
#				-u: it will connect to the VM to unmount the shared folder, this is needed if you have an error as "input/output error"
#					this error can happen when the directory shared between the windows host and the VM is corrupted
#					the process of sharing must be killed (close the prompt that has been open when you executed this script with the -m flag)
#					you can use it with the -m flag but this flag will activate it automatically
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason
#
######################################################################################################

if ($args -contains '-h' -or $args -contains '--help')
{
	echo "temporary solution to use podman-compose with a windows podman configured with minikube, waiting for podman3 included in minikube."
	echo "As a "minikube stop" delete all images existing, this couple of script exist to replace the use of minikube stop/start"
	echo "It creates a unix container with podman and podman-compose installed, generated the commands in the container, and execute them in the VM"
	echo "this script is part of 3 scripts, one in powershell (this one) which is the master script,"
	echo "2 in bash, one of them is for the command for the VM and the other for the container"
	echo "--"
	echo "arguments:"
	echo "			-m:	if you need to share a volume between the VM and the windows host (if you launch this script for the first time this is mandatory)"
	echo "				It will open another powershell prompt to run the process of sharing the folder that will still run after the script,"
	echo "				as long as you don't kill th eprocess or close the prompt, the sharing will keep going"
	echo "				if you keep the process running you won't need this flag again and have 30 sec faster script"
	echo "			-u: it will connect to the VM to unmount the shared folder, this is needed if you have an error as 'input/output error'"
	echo "				this error can happen when the directory shared between the windows host and the VM is corrupted,"
	echo "				the process of sharing must be killed (close the prompt that has been open when you executed this script with the -m flag)"
	echo "				you can use it with the -m flag but this flag will activate it automatically"
	exit
}

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
	Write-Host "the script has failed" -ForegroundColor Red
	exit 1
 }	
}


echo "Start of the podman-copose temporary script"

if ( $args -contains '-u')
{
	echo "the '-u' flag has been detected:"
	echo "unmounting and deleting the shared folder inside the VM"
	minikube ssh "sudo umount /tmp_shared_VM; sudo rm -rf /tmp_shared_VM"
	MSG_ERROR -step "unmounting and deleting the shared folder inside the VM" -return_code $?
	echo "deleting tmp folder: C:\Users\$($env:USERNAME)\tmp_share_windows"
	rm -r C:\Users\$($env:USERNAME)\tmp_share_windows
	MSG_ERROR -step "deleting tmp folder: C:\Users\$($env:USERNAME)\tmp_share_windows" -return_code $?
}

if (Test-Path C:\Users\$($env:USERNAME)\tmp_share_windows)
{
	echo "temporary directory already exists"
}
else
{
	echo "creating a temporary folder to share it with the VM: C:\Users\$($env:USERNAME)\tmp_share_windows"
	mkdir C:\Users\$($env:USERNAME)\tmp_share_windows
	MSG_ERROR -step "creating a temporary folder to share it with the VM: C:\Users\$($env:USERNAME)\tmp_share_windows" -return_code $?
}
$relative_path=$(get-item . | Select-Object -ExpandProperty Name)
echo "copying current directory into the tmp folder"
cp -r -Force . C:\Users\$($env:USERNAME)\tmp_share_windows
MSG_ERROR -step "copying current directory into the tmp folder" -return_code $?
echo "copying bash scripts in the same folder"
cp C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\*.bash C:\Users\$($env:USERNAME)\tmp_share_windows
MSG_ERROR -step "copying bash scripts in the same folder" -return_code $?
echo "copying the key to connect to the VM from the container"
$path=$(minikube ssh-key)
echo "cp $path /tmp_share_windows"
cp $path C:\Users\$($env:USERNAME)\tmp_share_windows
MSG_ERROR -step "copying the key to connect to the VM from the container" -return_code $?

if ( $args -contains '-m' -Or $args -contains '-u' )
{
	echo "the '-m' or '-u' flag has been detected:"
	echo "starting the sharing of directory between the host and the VM in another powershell prompt"
	Start-Process "powershell.exe" "-c minikube mount C:\Users\$($env:USERNAME)\tmp_share_windows:/tmp_shared_VM"
	MSG_ERROR -step "starting the sharing of directory between the host and the VM in another powershell prompt" -return_code $?
	echo "even if this is shown has succesfully, please check the new powershell prompt that has been opened"
	echo "after the end of this script you can decide to stop sharing the directory, for that, ctrl+c on the prompt of the sharing process"
	echo "you can also keep it open, so you don't need to use the -c flag next use"
	echo "waiting 30 sec for the sharing to be done..."
	sleep 30
}
echo "executing the bash script on the VM"
minikube ssh "[ -d /tmp_bis ] && sudo rm -rf /tmp_bis; sudo mkdir /tmp_bis;sudo cp /tmp_shared_VM/podman_compose_VM_part.bash /tmp_bis/podman_compose_VM_part.bash ;sudo chmod 777 /tmp_bis/podman_compose_VM_part.bash ;sudo su - root -c '/tmp_bis/podman_compose_VM_part.bash $relative_path $(minikube ip)'"
$RET=$?
echo $RET
MSG_ERROR -step "executing the bash script on the VM" -return_code $RET

Write-Host "the script has terminated succesfully" -ForegroundColor Green