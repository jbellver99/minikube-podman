#Requires -RunAsAdministrator
New-Item -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman -value "Open Podman Here"
New-Item -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman\command -value "`"powershell.exe`""
