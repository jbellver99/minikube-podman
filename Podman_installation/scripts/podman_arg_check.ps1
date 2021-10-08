$podman_folder="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder}\bin"
if ($args[0] -contains "build" -or $args[1] -contains "build")
{
	invoke-expression -Command "${podman_folder_bin}\podman_build.ps1 $args"
}elseif ($args[0] -contains "run" -or $args[1] -contains "run"){
	invoke-expression -Command "${podman_folder_bin}\podman_run.ps1 $args"
}else{
	invoke-expression -Command "${podman_folder_bin}\podman.exe $args"
}
