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
        [System.String[]]
        $SessionHost,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $WebAccessServer
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose 'Getting list of RD Server roles.'

    # Start service RDMS is needed because otherwise a reboot loop could happen due to
    # the RDMS Service being on Delay-Start by default, and DSC kicks in too quickly after a reboot.
    if ((Get-Service -Name RDMS -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Status) -ne 'Running')
    {
        try
        {
            Start-Service -Name RDMS -ErrorAction Stop
        }
        catch
        {
            Write-Warning "Failed to start RDMS service. Error: '$_'."
        }
    }

    $deployed = Get-RDServer -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue

    @{
        SessionHost      = [System.String[]] ($deployed | Where-Object Roles -Contains 'RDS-RD-SERVER' | ForEach-Object Server)
        ConnectionBroker = $deployed | Where-Object Roles -Contains 'RDS-CONNECTION-BROKER' | ForEach-Object Server
        WebAccessServer  = [System.String[]] ($deployed | Where-Object Roles -Contains 'RDS-WEB-ACCESS' | ForEach-Object Server)
    }
}

########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', 'global:DSCMachineStatus')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $SessionHost,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $WebAccessServer
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    $currentStatus = Get-TargetResource @PSBoundParameters

    if ($null -eq $currentStatus)
    {
        Write-Verbose 'Initiating new RDSH deployment.'
        $parameters = @{
            ConnectionBroker = $ConnectionBroker
            SessionHost      = $SessionHost
            WebAccessServer  = $WebAccessServer | Select-Object -First 1
        }

        New-RDSessionDeployment @parameters
        $global:DSCMachineStatus = 1
        return
    }

    foreach ($server in ($SessionHost | Where-Object { $_ -notin $currentStatus.SessionHost }))
    {
        Write-Verbose "Adding server '$server' to deployment."
        Add-RDServer -Server $server -Role 'RDS-RD-SERVER' -ConnectionBroker $ConnectionBroker
    }

    foreach ($server in ($currentStatus.SessionHost | Where-Object { $_ -notin $SessionHost }))
    {
        Write-Verbose "Removing server '$server' from deployment."
        Remove-RDServer -Server $server -Role 'RDS-RD-SERVER' -ConnectionBroker $ConnectionBroker -Force
    }

    foreach ($server in ($WebAccessServer | Select-Object -Skip 1 | Where-Object { $_ -notin $currentStatus.WebAccessServer }))
    {
        Write-Verbose "Adding server '$server' to deployment."
        Add-RDServer -Server $server -Role 'RDS-WEB-ACCESS' -ConnectionBroker $ConnectionBroker
    }

    foreach ($server in ($currentStatus.WebAccessServer | Where-Object { $_ -notin $WebAccessServer }))
    {
        Write-Verbose "Removing Web Server '$server' from deployment."
        Remove-RDServer -Server $server -Role 'RDS-WEB-ACCESS' -ConnectionBroker $ConnectionBroker -Force
    }
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
        [System.String[]]
        $SessionHost,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $WebAccessServer
    )

    Write-Verbose 'Checking RDSH role is deployed on this node.'

    $desiredState = $PSBoundParameters
    $currentState = Get-TargetResource @PSBoundParameters

    return Test-DscParameterState `
        -CurrentValues $currentState `
        -DesiredValues $desiredState `
        -SortArrayValues `
        -Verbose:$VerbosePreference
}

Export-ModuleMember -Function *-TargetResource
