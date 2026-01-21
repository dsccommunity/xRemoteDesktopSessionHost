function Get-RemoteDesktopServicesDscOsVersion
{
    [CmdletBinding()]
    [OutputType([System.Version])]
    param ()

    return [Environment]::OSVersion.Version
}
