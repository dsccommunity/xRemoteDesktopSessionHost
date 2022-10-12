Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw "The minimum OS requirement was not met."
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
        [string] $WebAccessServer
    )

    Write-Verbose "Getting list of RD Server roles."

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
            Write-Warning "Failed to start RDMS service. Error: $_"
        }
    }

    $deployed = Get-RDServer -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue

    @{
        SessionHost = [System.String[]] ($deployed | Where-Object Roles -contains "RDS-RD-SERVER" | ForEach-Object Server)
        ConnectionBroker = $deployed | Where-Object Roles -contains "RDS-CONNECTION-BROKER" | ForEach-Object Server
        WebAccessServer = $deployed | Where-Object Roles -contains "RDS-WEB-ACCESS" | ForEach-Object Server
    }
}


########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource

{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "global:DSCMachineStatus")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter(Mandatory = $true)]
        [string] $WebAccessServer
    )

    Write-Verbose "Initiating new RDSH deployment."
    New-RDSessionDeployment @PSBoundParameters
    $global:DSCMachineStatus = 1
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
        [string] $WebAccessServer
    )

    Write-Verbose "Checking RDSH role is deployed on this node."
    $currentStatus = Get-TargetResource @PSBoundParameters

    if ($currentStatus.ConnectionBroker -ne $ConnectionBroker)
    {
        Write-Verbose -Message "Found connection broker '$($currentStatus.ConnectionBroker)', expected '$ConnectionBroker'"
        return $false
    }

    if ($currentStatus.WebAccessServer -ne $WebAccessServer)
    {
        Write-Verbose -Message "Found web access '$($currentStatus.WebAccessServer)', expected '$WebAccessServer'"
        return $false
    }

    if ($SessionHost.Count -gt 0 -and $null -eq $currentStatus.SessionHost)
    {
        Write-Verbose -Message "Desired list of session hosts is empty, while $($SessionHost.Count) session hosts should have been configured."
        return $false
    }

    $compare = Compare-Object -ReferenceObject $SessionHost -DifferenceObject $currentStatus.SessionHost
    if ($null -ne $compare)
    {
        Write-Verbose -Message "Desired list of session hosts not equal`r`n$($compare | Out-String)"
        return $false
    }

    $true
}

Export-ModuleMember -Function *-TargetResource
