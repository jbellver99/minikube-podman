$relative_path=$(get-item . | Select-Object -ExpandProperty Name)
$absolute_path=$(pwd | Select-Object -ExpandProperty Path)
Start-Process "powershell.exe" "-c minikube mount '${absolute_path}:/tmp_${relative_path}'"
$test=0
while ($test -eq 0)
{
	echo "Checking if share is done ..."
	minikube ssh "[ -f /tmp_${relative_path}/Dockerfile ] && exit 0 || exit 1 "
	if ($?)
	{
		$test=1
	}else{
		echo "Share is not sucessful yet, checking again in some seconds"
		echo "--"
		sleep 2
	}
}

minikube ssh "cd /tmp_${relative_path}; sudo podman $args"
$RET=$?
Write-Host "The build has terminated, you can close the powershell window used to share folders with the VM"
exit $RET
