<#
    .SYNOPSIS
        Verifies that the operating system meets the Remote Desktop Session Host requirement.

    .DESCRIPTION
        Returns $true when Get-RemoteDesktopServicesDscOsVersion reports at least Windows Server 2012 (6.2.9200.0); otherwise returns $false.

    .OUTPUTS
        System.Boolean

        Indicates whether the OS version is supported.

    .EXAMPLE
        Test-RemoteDesktopServicesDscOsRequirement

        Returns $true if the OS is Windows Server 2012 or later, otherwise $false.
#>

function Test-RemoteDesktopServicesDscOsRequirement
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    return (Get-RemoteDesktopServicesDscOsVersion) -ge ([System.Version]::new(6, 2, 9200, 0))
}
