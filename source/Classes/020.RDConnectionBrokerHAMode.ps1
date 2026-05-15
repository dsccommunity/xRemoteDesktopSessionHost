<#
    .SYNOPSIS
        The `RDConnectionBrokerHAMode` DSC resource is used to configure the Remote Desktop Connection Broker HA.

    .DESCRIPTION
        This resource is used to configure the Remote Desktop Connection Broker HA.

        ## Requirements

        - Target machine must be running Windows Server 2012 or later.

        ## Known issues

        All issues are not listed here, see [all open issues](https://github.com/dsccommunity/RemoteDesktopServicesDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+RDConnectionBrokerHAMode).

    .PARAMETER ClientAccessName
        Specifies the Client Access Name for the RD Connection Broker HA deployment.

    .PARAMETER DatabaseConnectionString
        Specifies the primary database connection string for the RD Connection Broker HA deployment.

    .PARAMETER DatabaseSecondaryConnectionString
        Specifies the secondary database connection string for the RD Connection Broker HA deployment.

    .PARAMETER DatabaseFilePath
        Specifies the file path for the RD Connection Broker HA database.

    .PARAMETER ConnectionBroker
        Specifies the FQDN of a server to host the RD Connection Broker role service.

    .PARAMETER ActiveManagementServer
        Returns the FQDN of the server that is currently active for management tasks.

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>

[DscResource()]
class RDConnectionBrokerHAMode : ResourceBase
{
    [DscProperty(Key)]
    [ValidateLength(1, 256)]
    [System.String]
    $ClientAccessName

    [DscProperty()]
    [System.String]
    $ConnectionBroker

    [DscProperty(Mandatory)]
    [System.String]
    $DatabaseConnectionString

    [DscProperty()]
    [System.String]
    $DatabaseSecondaryConnectionString

    [DscProperty()]
    [System.String]
    $DatabaseFilePath

    [DscProperty(NotConfigurable)]
    [System.String]
    $ActiveManagementServer

    [DscProperty(NotConfigurable)]
    [RDSReason[]]
    $Reasons

    RDConnectionBrokerHAMode () : base ($PSScriptRoot)
    {
        $this.ExcludeDscProperties = @(
            'ConnectionBroker'
            'DatabaseSecondaryConnectionString'
            'DatabaseFilePath'
        )
    }

    [RDConnectionBrokerHAMode] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $getParameters = @{
            ConnectionBroker = $this.ConnectionBroker
            ErrorAction      = 'SilentlyContinue'
        }

        if ([string]::IsNullOrWhiteSpace($this.ConnectionBroker))
        {
            $getParameters.ConnectionBroker = (Get-ComputerName -FullyQualifiedDomainName)
        }

        $currentStateResult = Get-RDConnectionBrokerHighAvailability @getParameters

        return @{
            DatabaseConnectionString          = $currentStateResult.DatabaseConnectionString
            DatabaseSecondaryConnectionString = $currentStateResult.DatabaseSecondaryConnectionString
            DatabaseFilePath                  = $currentStateResult.DatabaseFilePath
            ActiveManagementServer            = $currentStateResult.ActiveManagementServer
        }
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        # If the ActiveManagementServer property is not empty, then the configuration is currently active and cannot be modified.
        if (-not [string]::IsNullOrEmpty($this.ActiveManagementServer))
        {
            New-InvalidOperationException -Message $this.localizedData.RDConnectionBrokerHAMode_ConfigurationCannotBeModified
        }

        $setParameters = @{
            ClientAccessName = $this.ClientAccessName
            ConnectionBroker = $this.ConnectionBroker
        }

        if ([string]::IsNullOrWhiteSpace($this.ConnectionBroker))
        {
            $setParameters.ConnectionBroker = (Get-ComputerName -FullyQualifiedDomainName)
        }

        Set-RDConnectionBrokerHighAvailability @setParameters @properties
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        if (-not (Test-RemoteDesktopServicesDscOsRequirement))
        {
            New-InvalidOperationException -Message $this.localizedData.RDConnectionBrokerHAMode_OSRequirementNotMet
        }

        # Module Import in verbose mode outputs lots of data, so redirecting to null.
        Import-RemoteDesktopModule 4>&1 > $null
    }
}
