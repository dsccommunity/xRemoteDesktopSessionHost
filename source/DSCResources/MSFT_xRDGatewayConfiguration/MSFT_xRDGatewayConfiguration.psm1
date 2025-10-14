Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (-not (Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}
Import-Module RemoteDesktop

function ValidateCustomModeParameters
{
    param
    (
        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [string]
        $mode,

        [Parameter()]
        [string]
        $ExternalFqdn,

        [Parameter()]
        [string]
        $LogonMethod,

        [Parameter()]
        [bool]
        $UseCachedCredentials,

        [Parameter()]
        [bool]
        $BypassLocal
    )

    Write-Verbose 'validating parameters...'

    $customModeParams = @{
        ExternalFqdn         = $ExternalFqdn
        LogonMethod          = $LogonMethod
        UseCachedCredentials = $UseCachedCredentials
        BypassLocal          = $BypassLocal
    }

    if ($mode -eq 'Custom')
    {
        # ensure all 4 parameters were passed in, otherwise Set-RdDeploymentGatewayConfiguration will fail

        $nulls = $customModeParams.GetEnumerator() | Where-Object { $null -eq $_.Value }

        if ($nulls.Count -gt 0)
        {
            $nulls | ForEach-Object { Write-Verbose ">> '$($_.Key)' parameter is empty" }

            Write-Warning "[PARAMETER VALIDATION FAILURE] i'm gonna throw, right now..."

            throw ("Requested gateway mode is 'Custom', you must pass in the following parameters: $($nulls.Key -join ', ').")
        }
    }
    else
    {
        # give warning about incorrect usage of the resource (do not fail)

        $parametersWithValues = $customModeParams.GetEnumerator() | Where-Object { $_.Value }

        if ($parametersWithValues.Count -gt 0)
        {
            $parametersWithValues | ForEach-Object { Write-Verbose ">> '$($_.Key)' was specified, the value is: '$($_.Value)'" }

            Write-Warning ("[WARNING]: Requested gateway mode is '$mode', the following parameters can only be used with Gateway mode 'Custom': " +
                "$($parametersWithValues.Key -join ', '). These parameters will be ignored in the call to Set-RdDeploymentGatewayConfiguration to avoid error!")
        }
    }
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
        [string]
        $ConnectionBroker,

        [Parameter()]
        [string]
        $GatewayServer,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExternalFqdn,

        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [string]
        $GatewayMode,

        [Parameter()]
        [ValidateSet('Password', 'Smartcard', 'AllowUserToSelectDuringConnection')]
        [string]
        $LogonMethod,

        [Parameter()]
        [bool]
        $UseCachedCredentials,

        [Parameter()]
        [bool]
        $BypassLocal
    )

    $result = $null

    Write-Verbose "Getting RD Gateway configuration from broker '$ConnectionBroker'..."

    $config = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -ea SilentlyContinue

    if ($config)
    {
        Write-Verbose 'Configuration retrieved successfully:'

        Write-Verbose ">> RD Gateway mode:       $($config.GatewayMode)"

        $result =
        @{
            ConnectionBroker = $ConnectionBroker
            GatewayMode      = $config.Gatewaymode.ToString()   # Microsoft.RemoteDesktopServices.Management.GatewayUsage  .ToString()
        }

        if ($config.GatewayMode -eq 'Custom')
        {
            # assert-expression ($config -is [Microsoft.RemoteDesktopServices.Management.CustomGatewaySettings])

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
        [string]
        $ConnectionBroker,

        [Parameter()]
        [string]
        $GatewayServer,

        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [string]
        $GatewayMode,

        [Parameter()]
        [string]
        $ExternalFqdn,

        [Parameter()]
        [ValidateSet('Password', 'Smartcard', 'AllowUserToSelectDuringConnection')]
        [string]
        $LogonMethod,

        [Parameter()]
        [bool]
        $UseCachedCredentials,

        [Parameter()]
        [bool]
        $BypassLocal
    )

    Write-Verbose "Starting RD Gateway configuration for the RD deployment at broker '$ConnectionBroker'..."

    # validate parameters
    ValidateCustomModeParameters $GatewayMode $ExternalFqdn $LogonMethod $UseCachedCredentials $BypassLocal

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

            Add-RDServer -server $GatewayServer -role RDS-Gateway -gatewayexternalfqdn $ExternalFqdn -connectionbroker $connectionBroker

            Write-Verbose 'Add-RDServer done.'
        }
    }


    Write-Verbose 'Calling Set-RdDeploymentGatewayConfiguration cmdlet...'

    Write-Verbose ">> requested GatewayMode:  $GatewayMode"

    if ($GatewayMode -eq 'Custom')
    {
        Write-Verbose ">> GatewayExternalFqdn:   '$ExternalFqdn'"
        Write-Verbose ">> LogonMethod:           '$LogonMethod'"
        Write-Verbose ">> UseCachedCredentials:  $UseCachedCredentials"
        Write-Verbose ">> BypassLocal:           $BypassLocal"

        $setRdDeploymentGatewayConfigurationParams = @{
            ConnectionBroker     = $ConnectionBroker
            GatewayMode          = $GatewayMode
            GatewayExternalFqdn  = $ExternalFqdn
            LogonMethod          = $LogonMethod
            UseCachedCredentials = $UseCachedCredentials
            BypassLocal          = $BypassLocal
            Force                = $true
            ErrorAction          = 'Stop'
        }
        Set-RDDeploymentGatewayConfiguration @setRdDeploymentGatewayConfigurationParams
    }
    else # 'DoNotUse' or 'Automatic'
    {
        Set-RdDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -GatewayMode $GatewayMode -force
    }

    Write-Verbose 'Set-RdDeploymentGatewayConfiguration done.'
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
        [string]
        $ConnectionBroker,

        [Parameter()]
        [string]
        $GatewayServer,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExternalFqdn,

        [Parameter()]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [string]
        $GatewayMode,

        [Parameter()]
        [ValidateSet('Password', 'Smartcard', 'AllowUserToSelectDuringConnection')]
        [string]
        $LogonMethod,

        [Parameter()]
        [bool]
        $UseCachedCredentials,

        [Parameter()]
        [bool]
        $BypassLocal
    )

    $config = Get-TargetResource @PSBoundParameters

    if ($config)
    {
        Write-Verbose 'Verifying RD Gateway usage name...'

        if ($config.GatewayMode -eq 'Custom' -and $config.GatewayMode -ieq $GatewayMode)
        {
            $result = $config.BypassLocal -eq $BypassLocal -and
            $config.UseCachedCredentials -eq $UseCachedCredentials -and
            $config.LogonMethod -eq $LogonMethod -and
            $config.GatewayExternalFqdn -eq $ExternalFqdn
        }
        else
        {
            $result = ($config.GatewayMode -ieq $GatewayMode)
        }
    }
    else
    {
        Write-Verbose 'Failed to retrieve RD Gateway configuration.'
        $result = $false
    }

    Write-Verbose "Test-TargetResource returning:  $result"
    return $result
}

Export-ModuleMember -Function *-TargetResource
