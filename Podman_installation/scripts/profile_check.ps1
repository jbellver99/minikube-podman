& minikube -p minikube podman-env > $null
$v = $?
if ($v)
{
write-host "Configuration of minikube into podman loaded succesful" -ForegroundColor Green
}
else
{
Write-Host "Minikube has not initialized correctly. Please check if the VM has started. Once it is started execute the following command: '& minikube -p minikube podman-env | Invoke-Expression'" -ForegroundColor Red
}