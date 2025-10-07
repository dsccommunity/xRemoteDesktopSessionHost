Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw "The minimum OS requirement was not met."
}
Import-Module RemoteDesktop
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
        [ValidateNotNullOrEmpty()]
        [string]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateSet("RDS-Connection-Broker", "RDS-Virtualization", "RDS-RD-Server", "RDS-Web-Access", "RDS-Gateway", "RDS-Licensing")]
        [string]
        $Role,

        [Parameter()]
        [string]
        $GatewayExternalFqdn   # only for RDS-Gateway
    )

    $result = $null

    if (-not $ConnectionBroker)
    {
        $ConnectionBroker = $localhost
    }

    Write-Verbose "Getting list of servers of type '$Role' from '$ConnectionBroker'..."
    $servers = Get-RDServer -ConnectionBroker $ConnectionBroker -Role $Role -ea SilentlyContinue

    if ($servers)
    {
        Write-Verbose "Found $($servers.Count) '$Role' servers in the deployment, now looking for server named '$Server'..."

        if ($Server -in $servers.Server)
        {
            Write-Verbose "The server '$Server' is in the RD deployment."

            $result = @{
                ConnectionBroker    = $ConnectionBroker
                Server              = $Server
                Role                = $Role
                GatewayExternalFqdn = $null
            }

            if ($Role -eq 'RDS-Gateway')
            {
                Write-Verbose "the role is '$Role', querying RDS Gateway configuration..."

                $config = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker

                if ($config)
                {
                    Write-Verbose "RDS Gateway configuration retrieved successfully..."
                    $result.GatewayExternalFqdn = $config.GatewayExternalFqdn
                    Write-Verbose ">> GatewayExternalFqdn: '$($result.GatewayExternalFqdn)'"
                }
            }
        }
        else
        {
            Write-Verbose "The server '$Server' is not in the deployment as '$Role' yet."
        }

    }
    else
    {
        Write-Verbose "No '$Role' servers found in the deployment on '$ConnectionBroker'."
        # or, possibly, Remote Desktop Deployment doesn't exist/Remote Desktop Management Service not running
    }

    $result
}


########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function ValidateCustomModeParameters
{
    param
    (
        [Parameter()]
        [ValidateSet("RDS-Connection-Broker", "RDS-Virtualization", "RDS-RD-Server", "RDS-Web-Access", "RDS-Gateway", "RDS-Licensing")]
        [string]
        $Role,

        [Parameter()]
        [string]
        $GatewayExternalFqdn
    )

    Write-Verbose "validating parameters..."

    $customParams = @{
        GatewayExternalFqdn = $GatewayExternalFqdn
    }

    if ($Role -eq 'RDS-Gateway')
    {
        # ensure GatewayExternalFqdn was passed in, otherwise Add-RDServer will fail
        $emptyBoundParameters = $null
        $emptyBoundParameters = $customParams.getenumerator() | Where-Object { $_.value -eq [string]::Empty }

        if ($emptyBoundParameters)
        {
            $emptyBoundParameters | ForEach-Object { Write-Verbose ">> '$($_.Key)' parameter is empty" }

            Write-Warning "[PARAMETER VALIDATION FAILURE] i'm gonna throw, right now..."

            throw ("Requested server role 'RDS-Gateway', you must pass in the 'GatewayExternalFqdn' parameter.")
        }
    }
    else
    {
        # give warning about incorrect usage of the resource (do not fail)

        $parametersWithValues = $customParams.getenumerator() | Where-Object { $_.value }

        if ($parametersWithValues.count -gt 0)
        {
            $parametersWithValues | ForEach-Object { Write-Verbose ">> '$($_.Key)' was specified, the value is: '$($_.Value)'" }

            Write-Warning ("[WARNING]: Requested server role is '$Role', the following parameter can only be used with server role 'RDS-Gateway': " +
                "$($parametersWithValues.Key -join ', '). The parameter will be ignored in the call to Add-RDServer to avoid error!")
        }
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateSet("RDS-Connection-Broker", "RDS-Virtualization", "RDS-RD-Server", "RDS-Web-Access", "RDS-Gateway", "RDS-Licensing")]
        [string]
        $Role,

        [Parameter()]
        [string]
        $GatewayExternalFqdn   # only for RDS-Gateway
    )

    if (-not $ConnectionBroker)
    {
        $ConnectionBroker = $localhost
    }

    Write-Verbose "Adding server '$($Server.ToLower())' as $Role to the deployment on '$($ConnectionBroker.ToLower())'..."

    # validate parameters
    ValidateCustomModeParameters -Role $Role -GatewayExternalFqdn $GatewayExternalFqdn

    if ($Role -eq 'RDS-Gateway')
    {
        Write-Verbose ">> GatewayExternalFqdn:  '$GatewayExternalFqdn'"
    }
    else
    {
        $PSBoundParameters.Remove("GatewayExternalFqdn")
    }


    Write-Verbose "calling Add-RDServer cmdlet..."
    #{
    if ($Role -eq 'RDS-Licensing' -or $Role -eq 'RDS-Gateway')
    {
        # workaround bug #3299246

        Add-RDServer @PSBoundParameters -ErrorAction silentlycontinue -ErrorVariable rdsErrors

        if ($rdsErrors.count -eq 0)
        {
            Write-Verbose "Add-RDServer completed without errors..."
            # continue
        }
        elseif ($rdsErrors.count -eq 2 -and $rdsErrors[0].FullyQualifiedErrorId -eq 'CommandNotFoundException')
        {
            Write-Verbose "Add-RDServer: trapped 2 errors, that's ok, continuing..."
            # ignore & continue
        }
        else
        {
            Write-Verbose "'Add-RDServer' threw $($rdsErrors.Count) errors."
            foreach ($rdsError in $rdsErrors)
            {
                Write-Error -ErrorRecord $rdsError
            }
            return
        }
    }
    else
    {
        Add-RDServer @PSBoundParameters
    }
    #}
    Write-Verbose "Add-RDServer done."

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
        [ValidateNotNullOrEmpty()]
        [string]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateSet("RDS-Connection-Broker", "RDS-Virtualization", "RDS-RD-Server", "RDS-Web-Access", "RDS-Gateway", "RDS-Licensing")]
        [string]
        $Role,

        [Parameter()]
        [string]
        $GatewayExternalFqdn   # only for RDS-Gateway
    )


    $target = Get-TargetResource @PSBoundParameters

    $result = $null -ne $target

    Write-Verbose "Test-TargetResource returning:  $result"
    return $result
}


Export-ModuleMember -Function *-TargetResource
