if ($args -contains "build")
{
	invoke-expression -Command "C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\podman_build.ps1 $args"
}else{
	invoke-expression -Command "C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\podman.exe $args"
}
