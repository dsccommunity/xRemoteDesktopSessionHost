function Get-xRemoteDesktopSessionHostOsVersion
{
    [CmdletBinding()]
    [OutputType([System.Version])]
    param ()

    return [Environment]::OSVersion.Version
}
