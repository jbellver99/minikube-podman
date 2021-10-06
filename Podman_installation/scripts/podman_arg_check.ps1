$podman_folder="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder}\bin"
if ($args -contains "build")
{
	invoke-expression -Command "${podman_folder_bin}\podman_build.ps1 $args"
}else{
	invoke-expression -Command "${podman_folder_bin}\podman.exe $args"
}
