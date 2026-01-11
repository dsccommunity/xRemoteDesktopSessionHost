$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Common Modules
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'RemoteDesktopServicesDsc.Common')
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

if (-not (Test-RemoteDesktopServicesDscOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}

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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateSet('RDS-Connection-Broker', 'RDS-Virtualization', 'RDS-RD-Server', 'RDS-Web-Access', 'RDS-Gateway', 'RDS-Licensing')]
        [System.String]
        $Role,

        [Parameter()]
        [System.String]
        $GatewayExternalFqdn # only for RDS-Gateway
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    $result = @{
        ConnectionBroker    = $null
        Server              = $null
        Role                = $null
        GatewayExternalFqdn = $null
    }

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
                    Write-Verbose 'RDS Gateway configuration retrieved successfully...'
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
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateSet('RDS-Connection-Broker', 'RDS-Virtualization', 'RDS-RD-Server', 'RDS-Web-Access', 'RDS-Gateway', 'RDS-Licensing')]
        [System.String]
        $Role,

        [Parameter()]
        [System.String]
        $GatewayExternalFqdn # only for RDS-Gateway
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    if ($Role -eq 'RDS-Gateway')
    {
        Assert-BoundParameter -BoundParameterList $PSBoundParameters -RequiredParameter @('GatewayExternalFqdn')
    }
    elseif ($PSBoundParameters.ContainsKey('GatewayExternalFqdn'))
    {
        Write-Warning ('[WARNING]: Requested server role is ''{0}'', the following parameter can only be used with server role ''RDS-Gateway'': ''GatewayExternalFqdn''. The parameter will be ignored in the call to Add-RDServer to avoid error!' -f $Role)
    }

    if (-not $ConnectionBroker)
    {
        $ConnectionBroker = $localhost
    }

    Write-Verbose "Adding server '$($Server.ToLower())' as $Role to the deployment on '$($ConnectionBroker.ToLower())'..."

    if ($Role -eq 'RDS-Gateway')
    {
        Write-Verbose ">> GatewayExternalFqdn:  '$GatewayExternalFqdn'"
    }
    else
    {
        $PSBoundParameters.Remove('GatewayExternalFqdn')
    }

    Write-Verbose 'Calling Add-RDServer cmdlet...'

    if ($Role -eq 'RDS-Licensing' -or $Role -eq 'RDS-Gateway')
    {
        # workaround bug #3299246
        Add-RDServer @PSBoundParameters -ErrorAction SilentlyContinue -ErrorVariable rdsErrors

        if ($rdsErrors.count -eq 0)
        {
            Write-Verbose 'Add-RDServer completed without errors...'
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
                New-InvalidOperationException -Message 'Add-RDServer errored' -ErrorRecord $rdsError
            }
            return
        }
    }
    else
    {
        Add-RDServer @PSBoundParameters
    }

    Write-Verbose 'Add-RDServer done.'
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
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateSet('RDS-Connection-Broker', 'RDS-Virtualization', 'RDS-RD-Server', 'RDS-Web-Access', 'RDS-Gateway', 'RDS-Licensing')]
        [System.String]
        $Role,

        [Parameter()]
        [System.String]
        $GatewayExternalFqdn # only for RDS-Gateway
    )

    Write-Verbose 'Checking for existence of RDS Server.'

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
