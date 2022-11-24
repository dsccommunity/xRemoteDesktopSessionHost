Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw "The minimum OS requirement was not met."
}
Import-Module -Name RemoteDesktop
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string] $DatabaseConnectionString,

        [Parameter()]
        [string] $DatabaseSecondaryConnectionString,

        [Parameter()]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName
    )
    Write-Verbose "Getting information about RD Connection Broker High Availability Mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }

    $ConnectionBrokerHighAvailability = Get-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue

    @{
        ConnectionBroker                  = $ConnectionBrokerHighAvailability.ConnectionBroker
        ActiveManagementServer            = $ConnectionBrokerHighAvailability.ActiveManagementServer
        ClientAccessName                  = $ConnectionBrokerHighAvailability.ClientAccessName
        DatabaseConnectionString          = $ConnectionBrokerHighAvailability.DatabaseConnectionString
        DatabaseSecondaryConnectionString = $DatabaseSecondaryConnectionString
        DatabaseFilePath                  = $ConnectionBrokerHighAvailability.DatabaseFilePath
    }

}


########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource

{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string] $DatabaseConnectionString,

        [Parameter()]
        [string] $DatabaseSecondaryConnectionString,

        [Parameter()]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName
    )
    Write-Verbose "Set RD Connection Broker for high availability mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }

    $parameters = @{
        ConnectionBroker         = $ConnectionBroker
        DatabaseConnectionString = $DatabaseConnectionString
        ClientAccessName         = $ClientAccessName
    }

    if (-not [string]::IsNullOrWhiteSpace($DatabaseFilePath))
    {
        $parameters['DatabaseFilePath'] = $DatabaseFilePath
    }

    if (-not [string]::IsNullOrWhiteSpace($DatabaseSecondaryConnectionString))
    {
        $parameters['DatabaseSecondaryConnectionString'] = $DatabaseSecondaryConnectionString
    }

    Set-RDConnectionBrokerHighAvailability @parameters
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string] $DatabaseConnectionString,

        [Parameter()]
        [string] $DatabaseSecondaryConnectionString,

        [Parameter()]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName
    )
    Write-Verbose "Checking for existence of RD Connection Broker for high availability mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $PSBoundParameters['ConnectionBroker'] = $localhost
    }

    -not [string]::IsNullOrWhiteSpace((Get-TargetResource @PSBoundParameters).ActiveManagementServer)
}

Export-ModuleMember -Function *-TargetResource
