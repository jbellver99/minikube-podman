if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
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
	Write-Host "the script has failed" -ForegroundColor Red
	Write-Host "Press any key to close window..."
	($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
	exit
 }
}

echo "enabling hyper-V feature"
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Microsoft-Hyper-V -All
MSG_ERROR -step "enabling hyper-V feature" -return_code $?
([adsi]"WinNT://./Hyper-V Administrators,group").Add("WinNT://$env:UserDomain/$env:Username,user")
$RET = $?
echo "-----------------------------------------------------"
if ($RET)
{
  echo "All changes were made sucessfully, you need to restart your computer to apply them"
  $user_input = Read-Host -Prompt "Would you like to restart now ? (Type 'Y' for 'Yes' or 'N' for no)"
  if ($user_input -eq 'Y')
  {
    Restart-Computer
  }else {
    Write-Host "Press any key to close window..."
  }
}else{
  write-Host "the command to add user in the Hyper Administrators group has failed, if the error shown above tells you that the group does not exist, it may be because of the language of your computer, in this case execute this command:" -ForegroundColor Yellow
  echo "    ([adsi]`"WinNT://./<Hyper-V Administrators>,group`").Add(`"WinNT://$env:UserDomain/$env:Username,user`")"
  echo "But replace '<Hyper-V Administrators>' with a translation in the language of your computer. "
  echo "ex: in French the command will be: "
  echo "    ([adsi]`"WinNT://./Administrateurs Hyper-V,group`").Add(`"WinNT://$env:UserDomain/$env:Username,user`")"
  write-Host "Then restart your computer to apply all changes made" -ForegroundColor Yellow
  Write-Host "Press any key to close window..."
}
($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) > $null
