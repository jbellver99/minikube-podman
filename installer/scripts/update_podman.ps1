#podman_folder_xxx are folders inside the already installed podman
#xxx_folder are folders inside the installer
$podman_folder_root="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder_root}\bin"
$podman_folder_conf="${podman_folder_root}\conf"
$podman_folder_helpers="${podman_folder_root}\helpers"
$podman_folder_bin_regex=$podman_folder_root_bin -replace "\\","\\"
$update_script_folder = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$scripts_folder= "${update_script_folder}\..\scripts"
$bin_folder = "${update_script_folder}\..\bin"
$conf_folder = "${update_script_folder}\..\conf"
$helpers_folder = "${update_script_folder}\..\helpers"
$profile_podman="C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\podman_profile.ps1"

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
	Write-Host "A problem occured in the step: $step" -ForegroundColor Red
	Write-Host "Stopping the script..." -ForegroundColor Red
	Write-Host "The update has failed" -ForegroundColor Red
	Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
 }
}

function Check_copy_file {
 param( [string]$filename, [string]$foldername)
 if ((Test-Path ${podman_folder_root}\${foldername}\${filename}) -and (-not ($filename -match ".conf$")))
 {
   $compare=$(compare-object (get-content ${podman_folder_root}\${foldername}\${filename}) (get-content ${update_script_folder}\..\${foldername}\${filename}))
   if ($compare.length -ne 0)
   {
     echo "Changes detected with the file ${filename}, copying it into the bin directory: ${podman_folder_root}\${foldername}"
     cp -Force ${update_script_folder}\..\${foldername}\${filename} ${podman_folder_root}\${foldername}
     MSG_ERROR -step "Copying ${filename} into the bin directory: ${podman_folder_root}\${foldername}" -return_code $?
   }else{
     echo "No changes detected for the file: ${filename}, skipping its copy"
   }
 }elseif (-not (Test-Path ${podman_folder_root}\${foldername}\${filename})){
   echo "The file $filename does not exist in ${podman_folder_root}\${foldername}, copying it inside the folder"
   cp -Force ${update_script_folder}\..\${foldername}\${filename} ${podman_folder_root}\${foldername}
   MSG_ERROR -step "copying ${filename} into the bin directory: ${podman_folder_root}\${foldername}" -return_code $?
 }elseif ((Test-Path ${podman_folder_root}\${foldername}\${filename}) -and ($filename -match ".conf")){
   Write-host "Note: the file: $filename is skipped because it is a conf file that already exists" -ForegroundColor Yellow
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
  	MSG_ERROR -step "creating $podman_folder_root and $podman_folder_bin" -return_code $?
  }
  cp -Force C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\* $podman_folder_bin; if ($?) {mv -Force ${podman_folder_bin}\Uninstallation_podman.ps1 $podman_folder_root }
  MSG_ERROR -step "Moving the binaries from C:\Users\$($env:USERNAME)\Downloads\podman-2.2.1\* to $podman_folder_bin " -return_code $?
  echo "Replacing the paths in the profile: $PROFILE"
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
echo "Creating conf folder"
if (Test-Path $podman_folder_conf)
{
	echo "Directory already exists, step skipped"
}
else
{
	New-Item -Type directory "$podman_folder_conf"
	MSG_ERROR -step "Creating $podman_folder_conf" -return_code $?
}
echo "Creating conf folder"
if (Test-Path $podman_folder_helpers)
{
	echo "Directory already exists, step skipped"
}
else
{
	New-Item -Type directory "$podman_folder_helpers"
	MSG_ERROR -step "Creating $podman_folder_helpers" -return_code $?
}
Write-Host "Updating every script" -ForegroundColor DarkCyan
$file_list=$(ls $bin_folder | Select-object -ExpandProperty Name)
Foreach ($i in $file_list)
{
  Check_copy_file -filename $i -foldername $($bin_folder|split-path -leaf)
}
Write-Host "All scripts have been updated" -ForegroundColor DarkCyan
Write-Host "Updating every conf file if needed" -ForegroundColor DarkCyan
$file_list=$(ls $conf_folder | Select-object -ExpandProperty Name)
Foreach ($i in $file_list)
{
  Check_copy_file -filename $i -foldername $($conf_folder|split-path -leaf)
}
Write-Host "All conf files have been updated" -ForegroundColor DarkCyan
Write-Host "Updating every helpers if needed" -ForegroundColor DarkCyan
$file_list=$(ls $helpers_folder | Select-object -ExpandProperty Name)
Foreach ($i in $file_list)
{
  Check_copy_file -filename $i -foldername $($helpers_folder|split-path -leaf)
}
Write-Host "All helpers have been updated" -ForegroundColor DarkCyan

foreach ($i in 'containers.conf','registries.conf','enable_ICS.ps1','podman_profile.txt' )
{
  if (Test-Path ${podman_folder_bin}\$i)
  {
    rm -force ${podman_folder_bin}\$i
  }
}
echo "-------------------------------------------------------------"

#update of the profile
if ( -not (Test-Path $profile_podman))
{
  $podman_save="C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile_before_update_podman.$date_save"
  write-host "We can see that the new podman profile has not been created yet, creating it and writting in it" -ForegroundColor DarkCyan
  echo "Modifying profile: all lines about podman are removed from the powershell profile to create a personal profile when using the shortcut for podman (a save of the profile exists here: $podman_save)"
  cat $PROFILE | Select-String "podman" > $profile_podman
  mv -Force $PROFILE $podman_save
  echo "" >> $PROFILE
  cat ${bin_folder}..\profile\podman_profile.txt >> $PROFILE
  cat $podman_save  | Select-String "podman" -NotMatch > $podman_profile
  write-host "NOTE: Now to use podman you need to execute the shortcut: $ShortcutLocation, just opening a powershell prompt will not work"

}
Write-Host "Updating profile: $profile_podman" -ForegroundColor DarkCyan
cp -Force ${update_script_folder}\..\profile\podman_profile.ps1 $profile_podman
$begin_line=(( Select-String -pattern "block podman begin" -path $PROFILE) -split ":")[2]
$end_line=(( Select-String -pattern "block podman end" -path $PROFILE) -split ":")[2]
$a=Get-Content $profile
$podman_save2="C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile_without_podman"
$a[0..($begin_line-1)] > $podman_save2

Get-Content $profile -Tail ($a.Count - ($end_line-1)) >> $podman_save2

Set-Content -Path $podman_save2 -Value (get-content -Path $podman_save2 | Select-String -Pattern 'block podman' -NotMatch)

Set-Content $podman_save2 -value (Get-Content $podman_save2 | ? {$_.trim() -ne "" })

cat $podman_save2 > $PROFILE
cat ${update_script_folder}\..\profile\podman_profile.txt >> $PROFILE
rm -force $podman_save2

Write-Host "The profile has been updated" -ForegroundColor DarkCyan
echo "-------------------------------------------------------------"
cp -Force ${scripts_folder}\uninstall.ps1 $podman_folder_root
if (Test-Path $podman_folder_root\Uninstallation_podman.ps1) {rm -force $podman_folder_root\Uninstallation_podman.ps1}
Write-Host "The update has succeed" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
