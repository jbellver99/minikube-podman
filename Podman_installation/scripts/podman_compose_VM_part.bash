######################################################################################################
# Creation: 20/09/2021 Timothé Paty
# Description: 	temporary solution to use podman-compose with a windows podman configured with minikube,
#			   	waiting for podman3 included in minikube.
#				It creates a unix container with podman and podman-compose installed, generated the commands in the container,
#				and execute them in the VM
#				this script is part of 3 scripts, one in powershell which is the master script,
#				2 in bash, one of them is for the command for the VM (this one) and the other for the container
#
# Arguments:	$1:	name of the folder the powershell has been executed from
#				$2: IP of the VM
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason
#
######################################################################################################

yellow='\e[1;33m'
white='\e[1;37m'
red='\e[0;31m'
green='\e[1;32m'
violetfonce='\e[0;35m'

function MSG_ERROR {
 if [ $2 -eq 0 ]
then 
	echo -e "${green}step: $1 has succeed"
	echo -e "${white}--"
	echo ""
 else
	echo -e "${red}a problem occured in the step: $1"
	echo "stopping the script and deleting tmp files..."
	rm -rf /tmp_bis
	podman rm podman_compose_tmp -f
	echo "the script has failed"
	echo -e "${white}"
	exit 1
fi
}
echo -e "${yellow} Begining of the script executed on the VM"
echo -e "${white}"
echo -e "Starting the podman-compose container"
podman run --name=podman_compose_tmp -v /tmp_shared_VM:/tmp_shared_VM -itd ultimatom/test_python:V6
MSG_ERROR "Starting the podman-compose container" $?
echo "Inside the VM: cd to the copy of the app folder in the shared folder" 
cd /tmp_shared_VM/$1
echo "changing the format from windows to unix"
dos2unix docker-compose.yml
MSG_ERROR "changing the format from windows to unix" $?
echo "connection into the container to execute the podman-compose command"
podman exec podman_compose_tmp bash "/tmp_shared_VM/podman_compose_container_part.bash" "$1" "$2"
MSG_ERROR "connection into the container to execute the podman-compose command" $?
echo "stopping and deleting the temporary container for podman_compose"
podman rm podman_compose_tmp -f
MSG_ERROR "stopping and deleting the temporary container for podman_compose" $?
echo "deleting folder /tmp_bis from the VM"
rm -rf /tmp_bis
MSG_ERROR "deleting folder /tmp_bis from the VM" $?
echo -e "${yellow} End of the script executed on the VM"
echo -e "${white}"