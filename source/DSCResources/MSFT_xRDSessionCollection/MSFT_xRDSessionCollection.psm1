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
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,256)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker
    )
    Write-Verbose "Getting information about RDSH collection."
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection.count -gt 1)
    {
        $Collection = $Collection | Where-Object CollectionName -eq $CollectionName
    }

    @{
        "CollectionName" = $Collection.CollectionName
        "CollectionDescription" = $Collection.CollectionDescription
        "SessionHost" = [System.String[]] (Get-RDSessionHost -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue).SessionHost
        "ConnectionBroker" = $ConnectionBroker
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
        [Parameter(Mandatory = $true)]
        [ValidateLength(1,256)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker
    )
    Write-Verbose "Creating a new RDSH collection."
    if ($localhost -eq $ConnectionBroker)
    {
        New-RDSessionCollection @PSBoundParameters
    }
    else
    {
        $PSBoundParameters.Remove('CollectionDescription')
        Add-RDSessionHost @PSBoundParameters
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
        [ValidateLength(1,256)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker
    )

    Write-Verbose "Checking for existence of RDSH collection."
    $currentStatus = Get-TargetResource @PSBoundParameters

    if ($null -eq $currentStatus.CollectionName)
    {
        Write-Verbose -Message "No collection $CollectionName found"
        return $false
    }

    $diff = if ($null -eq $currentStatus.SessionHost) { @() } else { $currentStatus.SessionHost }
    $compare = Compare-Object -ReferenceObject $SessionHost -DifferenceObject $diff
    if ($null -ne $compare)
    {
        Write-Verbose -Message "Desired list of session hosts not equal`r`n$($compare | Out-String)"
        return $false
    }

    $true
}


Export-ModuleMember -Function *-TargetResource
