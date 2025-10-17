$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Common Modules
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'xRemoteDesktopSessionHost.Common')
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

if (-not (Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}

Assert-Module -ModuleName 'RemoteDesktop'

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
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter()]
        [bool] $Force
    )
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
            ConnectionBroker      = $null
            CollectionDescription = $null
            CollectionName        = $null
            SessionHost           = $SessionHost
            Force                 = $Force
        }
    }

    if ($Collection.Count -gt 1)
    {
        throw 'Non-singular RDSessionCollection in result set'
    }

    return @{
        ConnectionBroker      = $ConnectionBroker
        CollectionDescription = $Collection.CollectionDescription
        CollectionName        = $Collection.CollectionName
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
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter()]
        [bool] $Force
    )

    $currentStatus = Get-TargetResource @PSBoundParameters
    if ($null -ne $currentStatus.CollectionName -and $Force)
    {
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

    try
    {
        Write-Verbose -Message 'Creating a new RDSH collection.'
        New-RDSessionCollection @PSBoundParameters -ErrorAction Stop
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
        throw [System.Management.Automation.ErrorRecord]::new($exception, 'Failure to coerce resource into the desired state', [System.Management.Automation.ErrorCategory]::InvalidResult, $CollectionName)
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
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string[]] $SessionHost,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,
        [Parameter()]
        [bool] $Force
    )

    Write-Verbose 'Checking for existence of RDSH collection.'
    $currentStatus = Get-TargetResource @PSBoundParameters

    if ($null -eq $currentStatus.CollectionName)
    {
        Write-Verbose -Message "No collection $CollectionName found"
        return $false
    }

    if ($null -eq $currentStatus.SessionHost)
    {
        Write-Verbose -Message "No session host(s) found in collection $CollectionName"
        return (-not $Force)
    }

    $compare = Compare-Object -ReferenceObject $SessionHost -DifferenceObject $currentStatus.SessionHost
    if ($null -ne $compare -and $Force)
    {
        Write-Verbose -Message "Desired list of session hosts not equal`r`n$($compare | Out-String) and Force is true"
        return $false
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
