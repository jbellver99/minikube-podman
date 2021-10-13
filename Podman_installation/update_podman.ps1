
$podman_folder="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder}\bin"
$podman_folder_bin_regex=$podman_folder_bin -replace "\\","\\"
$folder_of_update_script = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$scripts_folder = "${folder_of_update_script}\scripts"
$profile_podman="C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile_podman.ps1"

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
	Write-Host "the update has failed" -ForegroundColor Red
	Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
 }
}

function Check_copy_file {
 param( [string]$filename)
 if ((Test-Path ${podman_folder_bin}\${filename}) -and (-not ($filename -match ".conf$")))
 {
   $compare=$(compare-object (get-content ${podman_folder_bin}\${filename}) (get-content ${scripts_folder}\${filename}))
   if ($compare.length -ne 0)
   {
     echo "Changes detected with the file ${filename}, copying it into the bin directory: ${podman_folder_bin}"
     cp -Force ${scripts_folder}\${filename} ${podman_folder_bin}
     MSG_ERROR -step "copying ${filename} into the bin directory: ${podman_folder_bin}" -return_code $?
     if ($filename -match "Uninstallation_podman")
     {
       mv -Force ${podman_folder_bin}\${filename} $podman_folder
     }
   }else{
     echo "No changes detected for the file: ${filename}, skipping its copy"
   }
 }elseif (-not (Test-Path ${podman_folder_bin}\${filename})){
   echo "the file $filename does not exist in ${podman_folder_bin}, copying it inside the folder"
   cp -Force ${scripts_folder}\${filename} ${podman_folder_bin}
   MSG_ERROR -step "copying ${filename} into the bin directory: ${podman_folder_bin}" -return_code $?
 }elseif ((Test-Path ${podman_folder_bin}\${filename}) -and ($filename -match ".conf")){
   Write-host "Note: the file: $filename is skipped because it is a conf file that already exists" -ForegroundColor Yellow
 }
}

function check_line_in_profile
{
  param( [string]$test_line, [string]$full_line, $content)
  $test=$(echo $content | Select-string "$test_line")
  if ($test.length -eq 0)
  {
    echo "$full_line" >> $profile_podman
    MSG_ERROR -step "Adding the line about '$test_line' into the profile: $profile_podman" -return_code $?
  }else{
    echo "Line about '$test_line' already exists"
  }


}

echo "Before starting to update, be sure to have close the folder containing the already installed podman, then press any key to continue"
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null

# Update for changing repo from download to app data
if (Test-Path C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\podman.exe)
{
  Write-Host "The folder 'C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1' still exists, copying all binaries to $podman_folder_bin " -ForegroundColor DarkCyan
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
  Write-Host "The repository for podman is now set to : $podman_folder_bin" -ForegroundColor DarkCyan
  echo "-------------------------------------------------------------"
}

#Update of every script
Write-Host "Updating every script" -ForegroundColor DarkCyan
$file_list=$(ls $scripts_folder | Select-object -ExpandProperty Name)
Foreach ($i in $file_list)
{
  Check_copy_file -filename $i
}
Write-Host "All scripts have been updated" -ForegroundColor DarkCyan
echo "-------------------------------------------------------------"

#update of the profile
if ( -not (Test-Path $profile_podman))
{
  write-host "We can see that the new podman profile has not been created yet, after this, to use podman you need to execute the shortcut 'podman_client' on your Desktop " -ForegroundColor DarkCyan
  echo "Modifying profile: all lines about podman are removed from the powershell profile to create a personal profile when using the shortcut for podman (a save of the profile exists here: $podman_save)"
  cat $PROFILE | Select-String "podman" > $profile_podman
  $podman_save="C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile_before_update_podman.$date_save"
  mv -Force $PROFILE $podman_save
  cat $podman_save  | Select-String "podman" -NotMatch > $PROFILE

  $SourceFileLocation = 'C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe'
  $args="-noexit -file $profile_podman"
  $ShortcutLocation = "C:\Users\$($env:USERNAME)\Desktop\podman_client.lnk"
  echo "Creating the shortcut at: $ShortcutLocation"
  $WScriptShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
  $Shortcut.TargetPath = $SourceFileLocation
  $Shortcut.Arguments = $args
  $Shortcut.Save()
  MSG_ERROR -step "Creating shortcut: $ShortcutLocation" -return_code $?
  write-host "NOTE: Now to use podman you need to execute the shortcut: $ShortcutLocation, just opening a powershell prompt will not work"

}
Write-Host "Updating profile: $PROFILE" -ForegroundColor DarkCyan
$profile_content=$(Get-content $profile_podman)
check_line_in_profile -test_line "profile_check.ps1" -full_line "& ${podman_folder_bin}\profile_check.ps1" -content $profile_content
check_line_in_profile -test_line '^[$env:Path]' -full_line "`$env:Path += `";${podman_folder_bin};;C:\Users\$($env:USERNAME)\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\Scripts`"" -content $profile_content
check_line_in_profile -test_line "Set-Alias docker podman" -full_line "Set-Alias docker podman" -content $profile_content
check_line_in_profile -test_line "Set-Alias podman-compose" -full_line "Set-Alias podman-compose ${podman_folder_bin}\podman_compose_Windows_part.ps1" -content $profile_content
check_line_in_profile -test_line "Set-Alias minikube_save_images" -full_line "Set-Alias minikube_save_images ${podman_folder_bin}\save_images.ps1" -content $profile_content
check_line_in_profile -test_line "Set-Alias minikube_load_images" -full_line "Set-Alias minikube_load_images ${podman_folder_bin}\load_images.ps1" -content $profile_content
check_line_in_profile -test_line "Set-Alias copy_registry_conf" -full_line "Set-Alias copy_registry_conf ${podman_folder_bin}\copy_registry_conf.ps1" -content $profile_content
check_line_in_profile -test_line "Set-Alias podman C" -full_line "Set-Alias podman ${podman_folder_bin}\podman_arg_check.ps1" -content $profile_content

Write-Host "The profile has been updated" -ForegroundColor DarkCyan
echo "-------------------------------------------------------------"
Write-Host "the update has succeed" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
