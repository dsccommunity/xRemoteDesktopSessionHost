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
        ConnectionBroker = $ConnectionBroker
        CollectionName   = $CollectionName
        ErrorAction      = 'SilentlyContinue'
    }

    $Collection = Get-RDSessionCollection @params  | `
        Where-Object  CollectionName -eq $CollectionName


    if ($Collection.Count -eq 0)
    {
        return @{
            "ConnectionBroker"      = $null
            "CollectionDescription" = $null
            "CollectionName"        = $null
            "SessionHost"           = $SessionHost
        }
    }

    if ($Collection.Count -gt 1)
    {
        throw 'non-singular RDSessionCollection in result set'
    }

    return @{
        "ConnectionBroker"      = $ConnectionBroker
        "CollectionDescription" = $Collection.CollectionDescription
        "CollectionName"        = $Collection.CollectionName
        "SessionHost"           = $SessionHost
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

    try
    {
        Write-Verbose "Creating a new RDSH collection."
        New-RDSessionCollection @PSBoundParameters -ErrorAction Stop
    }
    catch
    {
        $exception = $_
    }

    if (-not (Test-TargetResource @PSBoundParameters))
    {
        Write-Verbose ('Session Collection ''{0}'' does not exist following attempted creation' -f $CollectionName)
        if ($exception)
        {
            throw $exception
        }
        throw ('''Test-TargetResource returns false after call to ''New-RDSessionCollection''; CollectionName: {0}, ConnectionBroker {1}' -f $CollectionName,$ConnectionBroker)
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
