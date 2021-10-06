minikube status > $null
$v = $?
if ($v)
{
& minikube -p minikube podman-env | Invoke-Expression
}
else
{
Write-Host "Minikube has not initialized correctly. Please check if the VM has started. Once it is started execute the following command: '& minikube -p minikube podman-env | Invoke-Expression'" -ForegroundColor Red
}