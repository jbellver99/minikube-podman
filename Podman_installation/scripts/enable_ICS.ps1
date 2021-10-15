#Requires -Version 3.0
function Get-MrInternetConnectionSharing {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]$InternetInterfaceName
    )
    BEGIN {
        regsvr32.exe /s hnetcfg.dll
        $netShare = New-Object -ComObject HNetCfg.HNetShare
    }
    PROCESS {
        foreach ($Interface in $InternetInterfaceName){
            $publicConnection = $netShare.EnumEveryConnection |
            Where-Object {
                $netShare.NetConnectionProps.Invoke($_).Name -eq $Interface
            }
            try {
                $Results = $netShare.INetSharingConfigurationForINetConnection.Invoke($publicConnection)
            }
            catch {
                Write-Warning -Message "An unexpected error has occurred for network adapter: '$Interface'"
                Continue
            }
            [pscustomobject]@{
                Name = $Interface
                SharingEnabled = $Results.SharingEnabled
                SharingConnectionType = $Results.SharingConnectionType
                InternetFirewallEnabled = $Results.InternetFirewallEnabled
            }
        }
    }
}

#Requires -Version 3.0 -Modules NetAdapter
function Set-MrInternetConnectionSharing {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateScript({
            If ((Get-NetAdapter -Name $_ -ErrorAction SilentlyContinue -OutVariable INetNIC) -and (($INetNIC).Status -ne 'Disabled' -or ($INetNIC).Status -ne 'Not Present')) {
                $True
            }
            else {
                Throw "$_ is either not a valid network adapter of it's currently disabled."
            }
        })]
        [Alias('Name')]
        [string]$InternetInterfaceName,
        [ValidateScript({
            If ((Get-NetAdapter -Name $_ -ErrorAction SilentlyContinue -OutVariable LocalNIC) -and (($LocalNIC).Status -ne 'Disabled' -or ($INetNIC).Status -ne 'Not Present')) {
                $True
            }
            else {
                Throw "$_ is either not a valid network adapter of it's currently disabled."
            }
        })]
        [string]$LocalInterfaceName,
        [Parameter(Mandatory)]
        [bool]$Enabled
    )
    BEGIN {
        if ((Get-NetAdapter | Get-MrInternetConnectionSharing).SharingEnabled -contains $true -and $Enabled) {
            Write-Warning -Message 'Unable to continue due to Internet connection sharing already being enabled for one or more network adapters.'
            Break
        }
        regsvr32.exe /s hnetcfg.dll
        $netShare = New-Object -ComObject HNetCfg.HNetShare
    }
    PROCESS {
        $publicConnection = $netShare.EnumEveryConnection |
        Where-Object {
            $netShare.NetConnectionProps.Invoke($_).Name -eq $InternetInterfaceName
        }
        $publicConfig = $netShare.INetSharingConfigurationForINetConnection.Invoke($publicConnection)
        if ($PSBoundParameters.LocalInterfaceName) {
            $privateConnection = $netShare.EnumEveryConnection |
            Where-Object {
                $netShare.NetConnectionProps.Invoke($_).Name -eq $LocalInterfaceName
            }
            $privateConfig = $netShare.INetSharingConfigurationForINetConnection.Invoke($privateConnection)
        }
        if ($Enabled) {
            $publicConfig.EnableSharing(0)
            if ($PSBoundParameters.LocalInterfaceName) {
                $privateConfig.EnableSharing(1)
            }
        }
        else {
            $publicConfig.DisableSharing()
            if ($PSBoundParameters.LocalInterfaceName) {
                $privateConfig.DisableSharing()
            }
        }
    }
}

Set-MrInternetConnectionSharing -InternetInterfaceName "Wi-Fi" -LocalInterfaceName "vEthernet (Minikube)" -Enabled $true
