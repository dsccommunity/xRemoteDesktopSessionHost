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
        [ValidateLength(1, 256)]
        [System.String]
        $CollectionName,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $SessionHost,

        [Parameter()]
        [System.String]
        $CollectionDescription,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.Boolean]
        $Force
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose -Message 'Getting information about RDSH collection.'

    $params = @{
        ConnectionBroker = $ConnectionBroker
        CollectionName   = $CollectionName
        ErrorAction      = 'SilentlyContinue'
    }

    $Collection = Get-RDSessionCollection @params | `
            Where-Object CollectionName -EQ $CollectionName


    if ($Collection.Count -eq 0)
    {
        return @{
            CollectionName        = $null
            ConnectionBroker      = $null
            CollectionDescription = $null
            SessionHost           = [System.String[]] $SessionHost
            Force                 = $Force
        }
    }

    if ($Collection.Count -gt 1)
    {
        New-InvalidResultException -Message 'Non-singular RDSessionCollection in result set'
    }

    return @{
        CollectionName        = $Collection.CollectionName
        ConnectionBroker      = $ConnectionBroker
        CollectionDescription = $Collection.CollectionDescription
        SessionHost           = [System.String[]] (Get-RDSessionHost -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue).SessionHost
        Force                 = $Force
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
        [ValidateLength(1, 256)]
        [System.String]
        $CollectionName,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $SessionHost,

        [Parameter()]
        [System.String]
        $CollectionDescription,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.Boolean]
        $Force
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    $currentStatus = Get-TargetResource @PSBoundParameters

    if ($null -ne $currentStatus.CollectionName -and $Force)
    {
        $missing, $surplus = @()
        Write-Verbose -Message "Session collection $CollectionName already exists. Updating Session Hosts."
        if ($null -ne $currentStatus.SessionHost)
        {
            $compare = Compare-Object -ReferenceObject $SessionHost -DifferenceObject $currentStatus.SessionHost -PassThru
            $surplus, $missing = $compare.Where({ $_.SideIndicator -eq '=>' }, 'Split')
        }
        else
        {
            $missing = $SessionHost
        }

        foreach ($server in $missing)
        {
            Add-RDSessionHost -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -SessionHost $server
        }

        foreach ($server in $surplus)
        {
            Remove-RDSessionHost -ConnectionBroker $ConnectionBroker -SessionHost $server
        }

        return
    }

    $newCollectionParams = @{
        CollectionName        = $CollectionName
        CollectionDescription = $CollectionDescription
        ConnectionBroker      = $ConnectionBroker
        SessionHost           = $SessionHost
    }

    $exception = $null

    try
    {
        Write-Verbose -Message 'Creating a new RDSH collection.'
        New-RDSessionCollection @newCollectionParams -ErrorAction Stop
    }
    catch
    {
        $exception = $_.Exception
    }

    if (-not (Test-TargetResource @PSBoundParameters))
    {
        $exceptionString = ("'Test-TargetResource' returns false after call to 'New-RDSessionCollection'; CollectionName: {0}; ConnectionBroker {1}." -f $CollectionName, $ConnectionBroker)
        Write-Verbose -Message $exceptionString

        if ($exception)
        {
            $exception = [System.Management.Automation.RuntimeException]::new($exceptionString, $exception)
        }
        else
        {
            $exception = [System.Management.Automation.RuntimeException]::new($exceptionString)
        }

        $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new($exception, 'Failure to coerce resource into the desired state', [System.Management.Automation.ErrorCategory]::InvalidResult, $CollectionName))
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
        [ValidateLength(1, 256)]
        [System.String]
        $CollectionName,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $SessionHost,

        [Parameter()]
        [System.String]
        $CollectionDescription,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.Boolean]
        $Force
    )

    Write-Verbose 'Checking for existence of RDSH collection.'

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
