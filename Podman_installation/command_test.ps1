$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
echo $PSScriptRoot
echo $MyInvocation.MyCommand.Definition
