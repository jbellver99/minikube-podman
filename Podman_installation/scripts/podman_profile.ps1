#block podman begin
$env:Path += ";C:\Users\$($env:USERNAME)\AppData\Roaming\podman-2.2.1\bin;;C:\Users\$($env:USERNAME)\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\Scripts"
Set-Alias docker podman
Set-Alias podman-compose C:\Users\$($env:USERNAME)\AppData\Roaming\podman-2.2.1\bin\podman_compose_Windows_part.ps1
Set-Alias minikube_save_images C:\Users\$($env:USERNAME)\AppData\Roaming\podman-2.2.1\bin\save_images.ps1
Set-Alias minikube_load_images C:\Users\$($env:USERNAME)\AppData\Roaming\podman-2.2.1\bin\load_images.ps1
Set-Alias copy_registry_conf C:\Users\$($env:USERNAME)\AppData\Roaming\podman-2.2.1\bin\copy_registry_conf.ps1
Set-Alias podman C:\Users\$($env:USERNAME)\AppData\Roaming\podman-2.2.1\bin\podman_arg_check.ps1
$background_loading=start-job {minikube -p minikube podman-env}
echo "Loading podman profile"
wait-job $background_loading > $null
$result_background_job= receive-job $background_loading
$result_background_job -match "false"
if($result_background_job -match "false")
{
  Write-Host "Minikube has not initialized correctly. Please check if the VM has started. Once it is started execute the following command: '& minikube -p minikube podman-env | Invoke-Expression'" -ForegroundColor Red
}
else
{
  write-host "Configuration of minikube into podman loaded succesfully" -ForegroundColor Green
  echo $result_background_job | Invoke-expression
}
#block podman end
