<#
    .SYNOPSIS
        Ensures the RDMS service is running and imports the RemoteDesktop CDXML module globally.

    .DESCRIPTION
        The RemoteDesktop module is a CDXML module whose proxy commands are generated at
        import time. When DSC runs inside wmiprvse.exe, Import-Module defaults to function
        scope, so the proxy commands are not visible to the calling DSC resource.

        This function starts the RDMS service (required for the WMI namespace the CDXML
        module connects to) and imports the module with -Global so the commands are
        available in all scopes.

    .INPUTS
        None

    .OUTPUTS
        None

    .EXAMPLE
        Import-RemoteDesktopModule

        Starts the RDMS service if it is not running and imports the RemoteDesktop
        module into the global scope so that its commands are available to DSC resources.
#>

function Import-RemoteDesktopModule
{
    [CmdletBinding()]
    [OutputType()]
    param ()

    $rdmsService = Get-Service -Name RDMS -ErrorAction SilentlyContinue

    if ($null -ne $rdmsService -and $rdmsService.Status -ne 'Running')
    {
        Start-Service -Name RDMS -ErrorAction Stop
        $rdmsService.WaitForStatus('Running', [TimeSpan]::FromSeconds(30))
    }

    if (-not (Get-Module -Name RemoteDesktop))
    {
        Import-Module -Name RemoteDesktop -Global -Force -ErrorAction Stop
    }
}
