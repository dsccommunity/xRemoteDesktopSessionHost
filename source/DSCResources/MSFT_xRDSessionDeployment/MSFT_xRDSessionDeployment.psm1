Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"

if (-not (Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}
Import-Module RemoteDesktop

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
        [string[]] $SessionHost,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string[]] $WebAccessServer
    )

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
        WebAccessServer  = $deployed | Where-Object Roles -Contains 'RDS-WEB-ACCESS' | ForEach-Object Server
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
        [string[]] $SessionHost,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string[]] $WebAccessServer
    )

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

    foreach ($server in ($WebAccessServer | Select-Object -Skip 1 | Where-Object { $_ -notin $currentStatus.WebAccessServer }))
    {
        Write-Verbose "Adding server '$server' to deployment."
        Add-RDServer -Server $server -Role 'RDS-WEB-ACCESS' -ConnectionBroker $ConnectionBroker
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
        [string[]] $SessionHost,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string[]] $WebAccessServer
    )

    Write-Verbose 'Checking RDSH role is deployed on this node.'

    $desiredState = $PSBoundParameters
    $currentState = Get-TargetResource @PSBoundParameters

    $result = Test-DscParameterState `
        -CurrentValues $currentState `
        -DesiredValues $desiredState `
        -SortArrayValues `
        -Verbose:$VerbosePreference

    return $result
}

Export-ModuleMember -Function *-TargetResource

Export-ModuleMember -Function *-TargetResource
