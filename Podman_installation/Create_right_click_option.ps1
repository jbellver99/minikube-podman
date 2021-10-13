#Requires -RunAsAdministrator
New-Item -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman -value "Open podman here"
New-Item -Path HKCU:\SOFTWARE\Classes\Directory\Background\shell\podman\command -value "`"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`"  -noexit -file C:\Users\$($env:USERNAME)\Documents\WindowsPowerShell\profile_podman.ps1"
