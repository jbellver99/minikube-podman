######################################################################################################
# Creation: XX/09/2021 Timothé Paty
# Description: 	Script to install podman on windows.
#			   	It will also get the solution to make podman-compose work
#
######################################################################################################
# Modification:		Name									date		Description
# ex : 				Timothé Paty							20/09/2021	adding something because of a reason

####################################################################################################

param( [int]$memory=0, [int]${storage}=0)


#intialazing variables
$podman_folder="${ENV:APPDATA}\podman-2.2.1"
$podman_folder_bin="${podman_folder}\bin"
$folder_of_installation_script = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$memory_used_dynamic=0



if ($storage -eq 0)
{
  echo "No disk size given, the VM will be created with the default value: 20000 MB"
  $storage_used=20000
}else{
  echo "The disk size will be $storage MB"
  $storage_used=$storage
}
if ($args -contains "-d" -and $memory -ne 0)
{
  echo "The '-d' flag has been detected, the VM will be created with dynamic memory, the minimum value will be 1800, and the maximum will be the value you defined with the 'memory' flag"
  $memory_used_dynamic=$memory
  $memory_used=1800
}elseif ($args -contains "-d" -and $memory -eq 0) {
  echo "The '-d' flag has been detected, the VM will be created with dynamic memory, the minimum value will be 1800, as the 'memory' flag has not beed given,"
  echo "the max value will be calculated depending of the available memory you have (Note: you need to have more than 8Gb on your computer for that, if not, 1800 will be chosen)"
  $memory_used_dynamic=$(((((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum - 8gb) /1mb), 1800 | Measure -Max).Maximum)
  $memory_used=1800
}elseif ($memory -eq 0 -and -not ($args -contains "-d"))
{
  $memory_used=$(((((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum - 8gb) /1mb), 1800 | Measure -Max).Maximum)
  echo "No memory has been given, the default memory will be used, in your case it is: $memory_used MB (static memory)"
}else{
  $memory_used=$memory
  echo "A value of $memory_used MB has been indicated for the memory of the VM (static memory)"
}

if ($memory_used -lt 1800)
{
  Write-Host "The minimum memory allowed to run the minikube VM is 1800" -ForegroundColor Red
  Write-Host "Press any key to close window..."
  ($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
  exit
}


if ($args -contains "-d" -and $memory_used -ge $memory_used_dynamic)
{
  Write-Host "You tried to setup the dynamic memory with a maximum value lower or equal the the minimum" -ForegroundColor Red
  echo "minimum value: $memory_used , maximum value: $memory_used_dynamic   (in MB)"
  Write-Host "If you did not set yourself the max value, that means you do not have more than 8GB of RAM, and we advise you to use the static memory" -ForegroundColor Yellow
  Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
}

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

echo "creating $podman_folder and $podman_folder_bin"
if (Test-Path $podman_folder_bin)
{
	echo "directory already exists, step skipped"
}
else
{
	New-Item -Type directory "$podman_folder_bin"
	MSG_ERROR -step "creating $podman_folder and $podman_folder_bin" -return_code $?
}
# ---------------------------------
if (Test-Path ${podman_folder_bin}\podman.exe)
{
  echo "The podman.exe file already exists, skipping the donwload of the archive"
}else{
  echo "downloading the Podman archive"
  Invoke-WebRequest -Uri https://github.com/containers/podman/releases/download/v2.2.1/podman-remote-release-windows.zip -OutFile C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip
  MSG_ERROR -step "downloading the Podman archive" -return_code $?
  # ---------------------------------------------------------
  echo "extracting podman archive"
  Expand-Archive "C:\Users\$($env:USERNAME)\Downloads\podman-remote-release-windows.zip" -DestinationPath "$podman_folder_bin"
  MSG_ERROR -step "extracting podman archive" -return_code $?
}
# -----------------------------------------------------
echo "copy the podman-compose and uninstallation scripts in the podman folder"
cp ${folder_of_installation_script}\scripts\* $podman_folder_bin ; if ($?) {mv -Force ${podman_folder_bin}\Uninstallation_podman.ps1 $podman_folder}
MSG_ERROR -step "copy the podman-compose scripts in the podman folder" -return_code $?
# ---------------------------------
echo "Creating the internal virtual switch"
Get-NetAdapter -Name "vEthernet (Minikube)" > $null -ErrorAction 'silentlycontinue'
$v = $?
if ($v)
{
    echo "The internal virtual switch already exists, step skipped"
}
else
{
    New-VMSwitch -Name "Minikube" -SwitchType Internal
    Start-Process -wait powershell "${podman_folder_bin}\enable_ICS.ps1" -Verb runAs
    MSG_ERROR -step "Creating the internal virtual switch" -return_code $?
}
# ---------------------------------
echo "starting minikube.."

minikube start --driver=hyperv --container-runtime=cri-o --cpus 4 --memory $memory_used --disk-size $storage_used --hyperv-virtual-switch "Minikube"

MSG_ERROR -step "starting minikube" -return_code $?

if ($memory_used_dynamic -ne 0)
{
  echo "We stop the VM to activate dynamic memory"
  minikube stop
  Set-VMMemory minikube -DynamicMemoryEnabled $true -MinimumBytes $(${memory_used}*1mb) -StartupBytes $(${memory_used}*1mb) -MaximumBytes $(${memory_used_dynamic}*1mb) -Priority 50 -Buffer 20
  MSG_ERROR -step "Activating dynamic memory" -return_code $?
  echo "Then we start again th VM"
  minikube start
  MSG_ERROR -step "starting again the VM" -return_code $?
}
# ---------------------------------
echo "creating powershell profile"
New-Item -Type File -Force $PROFILE
MSG_ERROR -step "creating powershell profile" -return_code $?
# ---------------------------------
echo "writing in the profile file: " $PROFILE
echo "& ${podman_folder_bin}\profile_check.ps1" >> $PROFILE
echo "`$env:Path += `";${podman_folder_bin};;C:\Users\$($env:USERNAME)\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\Scripts`""  >> $PROFILE
echo "Set-Alias docker podman"  >> $PROFILE
echo "Set-Alias podman-compose ${podman_folder_bin}\podman_compose_Windows_part.ps1"  >> $PROFILE
echo "Set-Alias minikube_save_images ${podman_folder_bin}\save_images.ps1" >> $PROFILE
echo "Set-Alias minikube_load_images ${podman_folder_bin}\load_images.ps1" >> $PROFILE
echo "Set-Alias copy_registry_conf ${podman_folder_bin}\copy_registry_conf.ps1" >> $PROFILE
echo "Set-Alias podman ${podman_folder_bin}\podman_arg_check.ps1" >> $PROFILE
MSG_ERROR -step "writing in the profile file: " -return_code $?
# ---------------------------------
echo "loading the profile"
& $PROFILE
MSG_ERROR -step "loading the profile" -return_code $?
Write-Host "installation succeed" -ForegroundColor Green
Write-Host "Press any key to close window..."
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
