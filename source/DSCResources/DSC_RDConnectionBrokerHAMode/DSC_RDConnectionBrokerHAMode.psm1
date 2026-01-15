$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Common Modules
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'RemoteDesktopServicesDsc.Common')
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

if (-not (Test-RemoteDesktopServicesDscOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$localhost = Get-ComputerName -FullyQualifiedDomainName

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
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseConnectionString,

        [Parameter()]
        [System.String]
        $DatabaseSecondaryConnectionString,

        [Parameter()]
        [System.String]
        $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [System.String]
        $ClientAccessName
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose -Message ($script:localizedData.VerboseGetHAMode -f $ConnectionBroker, $ClientAccessName)

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
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseConnectionString,

        [Parameter()]
        [System.String]
        $DatabaseSecondaryConnectionString,

        [Parameter()]
        [System.String]
        $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [System.String]
        $ClientAccessName
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose -Message ($script:localizedData.VerboseConfigureHAMode -f $ConnectionBroker, $ClientAccessName)

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
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseConnectionString,

        [Parameter()]
        [System.String]
        $DatabaseSecondaryConnectionString,

        [Parameter()]
        [System.String]
        $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [System.String]
        $ClientAccessName
    )

    Write-Verbose ($script:localizedData.VerboseTestHAMode -f $ConnectionBroker, $ClientAccessName)

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $PSBoundParameters['ConnectionBroker'] = $localhost
    }

    -not [string]::IsNullOrWhiteSpace((Get-TargetResource @PSBoundParameters).ActiveManagementServer)
}

Export-ModuleMember -Function *-TargetResource
