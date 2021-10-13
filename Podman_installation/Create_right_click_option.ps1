#Requires -RunAsAdministrator
New-Item -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman -value "Open podman here"
New-Item -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman\command -value "`"powershell.exe`" `"& C:\Users\$($env:USERNAME)\Desktop\podman_client.lnk`""
