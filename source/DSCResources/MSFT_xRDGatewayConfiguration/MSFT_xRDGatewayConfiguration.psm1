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
        [System.String]
        $GatewayServer,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ExternalFqdn,

        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [System.String]
        $GatewayMode,

        [Parameter()]
        [ValidateSet('Password', 'Smartcard', 'AllowUserToSelectDuringConnection')]
        [System.String]
        $LogonMethod,

        [Parameter()]
        [System.Boolean]
        $UseCachedCredentials,

        [Parameter()]
        [System.Boolean]
        $BypassLocal
    )

    Write-Verbose "Getting RD Gateway configuration from broker '$ConnectionBroker'..."

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    $result = $null

    $config = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -ea SilentlyContinue

    if ($config)
    {
        Write-Verbose 'Configuration retrieved successfully:'

        Write-Verbose ">> RD Gateway mode:       $($config.GatewayMode)"

        $result = @{
            ConnectionBroker = $ConnectionBroker
            GatewayMode      = $config.GatewayMode.ToString()   # Microsoft.RemoteDesktopServices.Management.GatewayUsage  .ToString()
        }

        if ($config.GatewayMode -eq 'Custom')
        {
            $result.GatewayExternalFqdn = $config.GatewayExternalFqdn
            $result.LogonMethod = $config.LogonMethod
            $result.UseCachedCredentials = $config.UseCachedCredentials
            $result.BypassLocal = $config.BypassLocal

            Write-Verbose ">> GatewayExternalFqdn:   $($result.GatewayExternalFqdn)"
            Write-Verbose ">> LogonMethod:           $($result.LogonMethod)"
            Write-Verbose ">> UseCachedCredentials:  $($result.UseCachedCredentials)"
            Write-Verbose ">> BypassLocal:           $($result.BypassLocal)"
        }
    }
    else
    {
        Write-Verbose "Failed to retrieve RD Gateway configuration from broker '$ConnectionBroker'."
    }

    $result
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
        [System.String]
        $GatewayServer,

        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [System.String]
        $GatewayMode,

        [Parameter()]
        [System.String]
        $ExternalFqdn,

        [Parameter()]
        [ValidateSet('Password', 'Smartcard', 'AllowUserToSelectDuringConnection')]
        [System.String]
        $LogonMethod,

        [Parameter()]
        [System.Boolean]
        $UseCachedCredentials,

        [Parameter()]
        [System.Boolean]
        $BypassLocal
    )

    Write-Verbose "Starting RD Gateway configuration for the RD deployment at broker '$ConnectionBroker'..."

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    $customModeParams = @(
        'ExternalFqdn',
        'LogonMethod',
        'UseCachedCredentials',
        'BypassLocal'
    )

    # validate parameters
    if ($GatewayMode -eq 'Custom')
    {
        Assert-BoundParameter -BoundParameterList $PSBoundParameters -RequiredParameter $customModeParams
    }
    elseif ($PSBoundParameters.Keys.Where({ $_ -in $customModeParams }))
    {
        Write-Warning ('[WARNING]: Requested gateway mode is ''{0}'', the following parameters can only be used with Gateway mode ''Custom'': ''{1}''. These parameters will be ignored in the call to Set-RdDeploymentGatewayConfiguration to avoid error!' -f @(
                $GatewayMode,
                ($customModeParams -join ', ')
            )
        )
    }

    if ($GatewayServer)
    {
        Write-Verbose ">> RD Gateway server (parameter):  $($GatewayServer.ToLower())"

        Write-Verbose 'checking if the server is part of the deployment, getting list of servers...'

        $servers = Get-RDServer -ConnectionBroker $ConnectionBroker | Where-Object Roles -EQ RDS-Gateway

        if ($servers)
        {
            Write-Verbose "there is $($servers.Count) RD Gateway server(s) in the deployment:"
            Write-Verbose ">> RD Gateway servers list:  $($servers.Server.ToLower() -join '; ')"

            if ($GatewayServer -in $servers.Server)
            {
                Write-Verbose "RD Gateways server '$GatewayServer' is already part of the deployment."
                $bAddGatewayServer = $false
            }
            else
            {
                Write-Verbose "RD Gateways server '$GatewayServer' is not yet in the deployment."
                $bAddGatewayServer = $true
            }
        }
        else
        {
            Write-Verbose 'no RD Gateway servers in the deployment...'

            $bAddGatewayServer = $true
        }

        if ($bAddGatewayServer)
        {
            Write-Verbose "Adding RD Gateway server '$GatewayServer' to the deployment..."

            Add-RDServer -Server $GatewayServer -Role RDS-Gateway -GatewayExternalFqdn $ExternalFqdn -ConnectionBroker $connectionBroker

            Write-Verbose 'Add-RDServer done.'
        }
    }

    Write-Verbose 'Calling Set-RDDeploymentGatewayConfiguration cmdlet...'

    Write-Verbose ">> requested GatewayMode:  $GatewayMode"

    $setRdDeploymentGatewayConfigurationParams = @{
        ConnectionBroker = $ConnectionBroker
        GatewayMode      = $GatewayMode
        Force            = $true
    }

    if ($GatewayMode -eq 'Custom')
    {
        Write-Verbose ">> GatewayExternalFqdn:   '$ExternalFqdn'"
        Write-Verbose ">> LogonMethod:           '$LogonMethod'"
        Write-Verbose ">> UseCachedCredentials:  $UseCachedCredentials"
        Write-Verbose ">> BypassLocal:           $BypassLocal"

        $setRdDeploymentGatewayConfigurationParams.GatewayExternalFqdn = $ExternalFqdn
        $setRdDeploymentGatewayConfigurationParams.LogonMethod = $LogonMethod
        $setRdDeploymentGatewayConfigurationParams.UseCachedCredentials = $UseCachedCredentials
        $setRdDeploymentGatewayConfigurationParams.BypassLocal = $BypassLocal
        $setRdDeploymentGatewayConfigurationParams.ErrorAction = 'Stop'
    }

    Set-RDDeploymentGatewayConfiguration @setRdDeploymentGatewayConfigurationParams

    Write-Verbose 'Set-RDDeploymentGatewayConfiguration done.'
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
        [System.String]
        $GatewayServer,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ExternalFqdn,

        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [System.String]
        $GatewayMode,

        [Parameter()]
        [ValidateSet('Password', 'Smartcard', 'AllowUserToSelectDuringConnection')]
        [System.String]
        $LogonMethod,

        [Parameter()]
        [System.Boolean]
        $UseCachedCredentials,

        [Parameter()]
        [System.Boolean]
        $BypassLocal
    )

    Write-Verbose 'Testing RD Gateway usage name'

    $excludeProperties = @()

    if ($GatewayMode -ne 'Custom')
    {
        $excludeProperties = @(
            'ExternalFqdn',
            'LogonMethod',
            'UseCachedCredentials',
            'BypassLocal'
        )
    }

    $testDscParameterStateSplat = @{
        CurrentValues       = Get-TargetResource @PSBoundParameters
        DesiredValues       = $PSBoundParameters
        TurnOffTypeChecking = $false
        SortArrayValues     = $true
        ExcludeProperties   = $excludeProperties
        Verbose             = $VerbosePreference
    }

    return Test-DscParameterState @testDscParameterStateSplat
}

Export-ModuleMember -Function *-TargetResource
