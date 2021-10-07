
$podman_folder="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder}\bin"
$podman_folder_bin_regex=$podman_folder_bin -replace "\\","\\"

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
	Write-Host "the installation has failed" -ForegroundColor Red
	Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
 }
}

echo "Before starting to update, be sure to have close the folder containing the already installed podman, then press any key to continue"
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null

# Update for changing repo from download to app data
if (Test-Path C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\podman.exe)
)
{
  echo "The folder 'C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1', copying all binaries to $podman_folder_bin "
  if (Test-Path $podman_folder_bin)
  {
  	echo "New directory already exists, creation skipped"
  }
  else
  {
  	New-Item -Type directory "$podman_folder_bin"
  	MSG_ERROR -step "creating $podman_folder and $podman_folder_bin" -return_code $?
  }
  cp -Force C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\* $podman_folder_bin; if ($?) {mv -Force ${podman_folder_bin}\Uninstallation_podman.ps1 $podman_folder }
  MSG_ERROR -step "Moving the binaries from C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\* to $podman_folder_bin " -return_code $?
  echo "replacing the paths in the profile: $PROFILE"
  $content=$(Get-content $PROFILE)
  $new_content=$content -replace "C:\\Users\\$($env:USERNAME)\\Downloads\\podman-2.2.1" ,"${podman_folder_bin}"
  $check=$(echo $new_content | Select-String -Pattern "$podman_folder_bin_regex")
  MSG_ERROR -step "storing and changing inside a variable the content of $PROFILE, if this step fails, that means it did not manage to replace the occurences of C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1 to $podman_folder_bin" -return_code $(${check}.length -ne 0)
  echo $new_content | Set-Content $PROFILE
  MSG_ERROR -step "Applying changes to the profile: $PROFILE" -return_code $?
  echo "Deleting old folder"
  rm -r C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1
  MSG_ERROR -step "Deleting old folder" -return_code $?
}

#Update of every script
