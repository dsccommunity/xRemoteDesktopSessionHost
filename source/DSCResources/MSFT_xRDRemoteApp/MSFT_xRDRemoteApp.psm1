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
        [System.String]
        $DisplayName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Alias,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $FileVirtualPath,

        [Parameter()]
        [System.String]
        $FolderName,

        [Parameter()]
        [ValidateSet('Allow', 'DoNotAllow', 'Require')]
        [System.String]
        $CommandLineSetting,

        [Parameter()]
        [System.String]
        $RequiredCommandLine,

        [Parameter()]
        [System.UInt32]
        $IconIndex,

        [Parameter()]
        [System.String]
        $IconPath,

        [Parameter()]
        [System.String[]]
        $UserGroups,

        [Parameter()]
        [System.Boolean]
        $ShowInWebAccess
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    try
    {
        $null = Get-RDSessionCollection -CollectionName $CollectionName -ErrorAction Stop
    }
    catch
    {
        throw "Failed to lookup RD Session Collection $CollectionName. Error: $_"
    }

    Write-Verbose "Getting published RemoteApp program $DisplayName, if one exists."
    $remoteApp = Get-RDRemoteApp -CollectionName $CollectionName -Alias $Alias -ErrorAction SilentlyContinue

    $return = @{
        CollectionName      = $CollectionName
        DisplayName         = $remoteApp.DisplayName
        FilePath            = $remoteApp.FilePath
        Alias               = $Alias
        FileVirtualPath     = $remoteApp.FileVirtualPath
        FolderName          = $remoteApp.FolderName
        CommandLineSetting  = $remoteApp.CommandLineSetting
        RequiredCommandLine = $remoteApp.RequiredCommandLine
        IconIndex           = $remoteApp.IconIndex
        IconPath            = $remoteApp.IconPath
        UserGroups          = $remoteApp.UserGroups
        ShowInWebAccess     = $remoteApp.ShowInWebAccess
    }

    if ($remoteApp)
    {
        $return['Ensure'] = 'Present'
    }
    else
    {
        $return['Ensure'] = 'Absent'
    }

    $return
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
        [System.String]
        $DisplayName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Alias,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $FileVirtualPath,

        [Parameter()]
        [System.String]
        $FolderName,

        [Parameter()]
        [ValidateSet('Allow', 'DoNotAllow', 'Require')]
        [System.String]
        $CommandLineSetting,

        [Parameter()]
        [System.String]
        $RequiredCommandLine,

        [Parameter()]
        [System.UInt32]
        $IconIndex,

        [Parameter()]
        [System.String]
        $IconPath,

        [Parameter()]
        [System.String[]]
        $UserGroups,

        [Parameter()]
        [System.Boolean]
        $ShowInWebAccess

    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    try
    {
        $null = Get-RDSessionCollection -CollectionName $CollectionName -ErrorAction Stop
        $null = $PSBoundParameters.Remove('Ensure')
    }
    catch
    {
        throw "Failed to lookup RD Session Collection $CollectionName. Error: $_"
    }

    Write-Verbose 'Making updates to RemoteApp.'
    $remoteApp = Get-RDRemoteApp -CollectionName $CollectionName -Alias $Alias
    if (!$remoteApp -and $Ensure -eq 'Present')
    {
        New-RDRemoteApp @PSBoundParameters
    }
    elseif ($remoteApp -and $Ensure -eq 'Absent')
    {
        Remove-RDRemoteApp -CollectionName $CollectionName -Alias $Alias -Force
    }
    else
    {
        Set-RDRemoteApp @PSBoundParameters
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
        [System.String]
        $DisplayName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Alias,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $FileVirtualPath,

        [Parameter()]
        [System.String]
        $FolderName,

        [Parameter()]
        [ValidateSet('Allow', 'DoNotAllow', 'Require')]
        [System.String]
        $CommandLineSetting,

        [Parameter()]
        [System.String]
        $RequiredCommandLine,

        [Parameter()]
        [System.UInt32]
        $IconIndex,

        [Parameter()]
        [System.String]
        $IconPath,

        [Parameter()]
        [System.String[]]
        $UserGroups,

        [Parameter()]
        [System.Boolean]
        $ShowInWebAccess
    )

    Write-Verbose 'Testing if RemoteApp is published.'

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    try
    {
        $null = Get-RDSessionCollection -CollectionName $CollectionName -ErrorAction Stop
    }
    catch
    {
        throw "Failed to lookup RD Session Collection $CollectionName. Error: $_"
    }

    $getTargetResourceResult = Get-TargetResource @PSBoundParameters

    $testDscParameterStateSplat = @{
        CurrentValues       = $getTargetResourceResult
        DesiredValues       = $PSBoundParameters
        TurnOffTypeChecking = $true
        SortArrayValues     = $true
        ExcludeProperties   = [System.Management.Automation.PSCmdlet]::CommonParameters
    }

    Test-DscParameterState @testDscParameterStateSplat
}

Export-ModuleMember -Function *-TargetResource
