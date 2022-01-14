######################################################################################################
# Creation: 20/09/2021 Timothé Paty
# Description: 	temporary solution to use podman-compose with a windows podman configured with minikube,
#			   	waiting for podman3 included in minikube.
#				It creates a unix container with podman and podman-compose installed, generated the commands in the container,
#				and execute them in the VM
#				this script is part of 3 scripts, one in powershell which is the master script,
#				2 in bash, one of them is for the command for the VM and the other for the container  (this one)
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
blue='\e[1;34m'
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
	echo "the script has failed"
	echo -e "${white}"
	exit 1
fi
}
args_used=$(echo $@ | sed "s/$1 $2//g")
echo -e "${yellow} Begining of the script executed on the container"
echo -e "${white}"
sed -i 's/mountPoint/Mountpoint/g' /usr/local/lib/python3.9/site-packages/podman_compose.py
sed -i 's/self\.podman_path, \*podman_args/self.podman_path,"--remote", *podman_args/g' /usr/local/lib/python3.9/site-packages/podman_compose.py
echo "Adding the remote connection to podman inside the container so that every command will be executed in the VM and not in the container"
podman system connection add test --socket-path /run/podman/podman.sock --identity /tmp_shared_VM/id_rsa docker@$2
MSG_ERROR "Adding the remote connection to podman inside the container" $?
podman system connection list
echo "Inside the container: cd to the copy of the app folder in the shared folder"
cd /tmp_shared_VM/$1
MSG_ERROR "cd to the copy of the app folder in the shared folder" $?
echo -e "${blue}Executing the podman-compose command"
echo -e "${yellow} Please be careful of logs for podman-compose up -d because the command can contain error but the final output can be succesful, please verify the logs messages"
echo -e "${blue}"
echo
echo
echo
echo "$args_used" | grep "up" >> /dev/null && echo "podman-compose $args_used -d" && podman-compose $args_used -d #> /tmp_shared_VM/command_tmp.sh
echo "$args_used" | grep "down" >> /dev/null && echo "podman-compose $args_used" &&	podman-compose $args_used
echo
echo
echo
echo
echo -e "${yellow}REMINDER: Please be careful of logs for podman-compose up -d because the command can contain error but the final output can be succesful, please verify the logs messages"
MSG_ERROR "Execution of podman-compose up -d" $?
echo -e "${white}-------------------------------------"
echo -e "${yellow} End of the script executed on the container"
echo -e "${white}"
