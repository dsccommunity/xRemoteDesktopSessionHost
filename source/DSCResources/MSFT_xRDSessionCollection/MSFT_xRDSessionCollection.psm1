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
        [ValidateLength(1,256)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker
    )
    Write-Verbose "Getting information about RDSH collection."
    $params = @{
        CollectionName   = $CollectionName
        ConnectionBroker = $ConnectionBroker
        ErrorAction      = 'SilentlyContinue'
    }

    $Collection = Get-RDSessionCollection @params  | `
        Where-Object  CollectionName -eq $CollectionName


    if ($Collection.Count -eq 0)
    {
        return @{
            "CollectionName" = $null
            "CollectionDescription" = $null
            "SessionHost" = $SessionHost
            "ConnectionBroker" = $null
        }
    }

    if ($Collection.Count -gt 1)
    {
        $CollectionType = $Collection.GetType()

        if ($CollectionType.Name -eq 'Array' -or $CollectionType.BaseType.Name -eq 'Array')
        {
            throw 'non-singular RDSessionCollection in result set'
        }
    }

    return @{
        "CollectionName" = $Collection.CollectionName
        "CollectionDescription" = $Collection.CollectionDescription
        "SessionHost" = $SessionHost
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
        [string] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker
    )

    $PSBoundParameters.Add('ErrorAction','SilentlyContinue')
    Write-Verbose "Creating a new RDSH collection."
    New-RDSessionCollection @PSBoundParameters

    $PSBoundParameters.Remove('ErrorAction')
    if (-not (Test-TargetResource @PSBoundParameters))
    {
        Write-Verbose ('Session Collection ''{0}'' does not exist following attempted creation' -f $CollectionName)
        throw ('''Get-RDSessionCollection -CollectionName {0} -ConnectionBroker {1}'' returns empty result set after call to ''New-RDSessionCollection''' -f $CollectionName,$ConnectionBroker)
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
        [string] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker
    )
    Write-Verbose "Checking for existence of RDSH collection."
    $null -ne (Get-TargetResource @PSBoundParameters).CollectionName
}


Export-ModuleMember -Function *-TargetResource
