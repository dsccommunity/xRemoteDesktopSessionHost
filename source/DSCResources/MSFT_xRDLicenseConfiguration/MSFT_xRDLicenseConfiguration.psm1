$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Common Modules
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'xRemoteDesktopSessionHost.Common')
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

if (-not (Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.String[]]
        $LicenseServer,

        [Parameter(Mandatory = $true)]
        [ValidateSet('PerUser', 'PerDevice', 'NotConfigured')]
        [System.String]
        $LicenseMode
    )

    Write-Verbose "Getting RD License server configuration from broker '$ConnectionBroker'..."

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    $config = Get-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker -ea SilentlyContinue

    if ($config) # Microsoft.RemoteDesktopServices.Management.LicensingSetting
    {
        Write-Verbose 'configuration retrieved successfully:'
        $result = @{
            ConnectionBroker = $ConnectionBroker
            LicenseServer    = [System.String[]] $config.LicenseServer
            LicenseMode      = $config.Mode.ToString()  # Microsoft.RemoteDesktopServices.Management.LicensingMode  .ToString()
        }

        Write-Verbose ">> RD License mode:     $($result.LicenseMode)"
        Write-Verbose ">> RD License servers:  $($result.LicenseServer -join '; ')"
    }
    else
    {
        $result = $null
    }

    return $result
}

########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.String[]]
        $LicenseServer,

        [Parameter(Mandatory = $true)] # required parameter in Set-RDLicenseConfiguration
        [ValidateSet('PerUser', 'PerDevice', 'NotConfigured')]
        [System.String]
        $LicenseMode
    )

    Write-Verbose 'Starting RD License server configuration...'
    
    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose ">> RD Connection Broker:  $($ConnectionBroker.ToLower())"

    $setLicenseConfigParams = @{
        ConnectionBroker = $ConnectionBroker
        Mode             = $LicenseMode
    }

    if ($LicenseServer)
    {
        Write-Verbose ">> RD License servers:    $($LicenseServer -join '; ')"
        $setLicenseConfigParams.LicenseServer = $LicenseServer
    }

    Write-Verbose 'Calling Set-RDLicenseConfiguration cmdlet...'
    Set-RDLicenseConfiguration @setLicenseConfigParams -Force
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
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.String[]]
        $LicenseServer,

        [Parameter(Mandatory = $true)]
        [ValidateSet('PerUser', 'PerDevice', 'NotConfigured')]
        [System.String]
        $LicenseMode
    )

    Write-Verbose 'Testing RD license servers'

    $testDscParameterStateSplat = @{
        CurrentValues       = Get-TargetResource @PSBoundParameters
        DesiredValues       = $PSBoundParameters
        TurnOffTypeChecking = $false
        SortArrayValues     = $true
        Verbose             = $VerbosePreference
    }

    return Test-DscParameterState @testDscParameterStateSplat
}

Export-ModuleMember -Function *-TargetResource
