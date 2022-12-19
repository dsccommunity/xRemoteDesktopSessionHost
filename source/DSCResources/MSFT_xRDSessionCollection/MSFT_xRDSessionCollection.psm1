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
    Write-Verbose -Message "Getting information about RDSH collection."
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
        Write-Verbose -Message "Creating a new RDSH collection."
        New-RDSessionCollection @PSBoundParameters -ErrorAction Stop
    }
    catch
    {
        $exception = $_.Exception
    }

    if (-not (Test-TargetResource @PSBoundParameters))
    {
        $exceptionString = ('''Test-TargetResource'' returns false after call to ''New-RDSessionCollection''; CollectionName: {0}: ConnectionBroker {1}.'  -f $CollectionName,$ConnectionBroker)
        Write-Verbose -Message $exceptionString

        if ($exception)
        {
            $exception = [System.Management.Automation.RuntimeException]::new($exceptionString, $exception)
        } else {
            $exception = [System.Management.Automation.RuntimeException]::new($exceptionString)
        }
        throw [System.Management.Automation.ErrorRecord]::new($exception, 'Failure to coerce resource into the desired state', [System.Management.Automation.ErrorCategory]::InvalidResult,$CollectionName)
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
    Write-Verbose -Message "Checking for existence of RDSH collection."
    $null -ne (Get-TargetResource @PSBoundParameters).CollectionName
}


Export-ModuleMember -Function *-TargetResource
