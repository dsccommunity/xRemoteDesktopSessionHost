$resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$modulesFolderPath = Join-Path -Path $resourceModulePath -ChildPath 'Modules'

$rdCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'xRemoteDesktopSessionHostCommon.psm1'
Import-Module -Name $rdCommonModulePath

$dscResourceCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name $dscResourceCommonModulePath

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
        [ValidateLength(1, 256)]
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string] $DisplayName,
        [Parameter(Mandatory = $true)]
        [string] $FilePath,
        [Parameter(Mandatory = $true)]
        [string] $Alias,
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present',
        [Parameter()]
        [string] $FileVirtualPath,
        [Parameter()]
        [string] $FolderName,
        [Parameter()]
        [ValidateSet('Allow', 'DoNotAllow', 'Require')]
        [string] $CommandLineSetting,
        [Parameter()]
        [string] $RequiredCommandLine,
        [Parameter()]
        [uint32] $IconIndex,
        [Parameter()]
        [string] $IconPath,
        [Parameter()]
        [string[]] $UserGroups,
        [Parameter()]
        [boolean] $ShowInWebAccess
    )

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
        CollectionName      = $remoteApp.CollectionName
        DisplayName         = $remoteApp.DisplayName
        FilePath            = $remoteApp.FilePath
        Alias               = $remoteApp.Alias
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
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string] $DisplayName,
        [Parameter(Mandatory = $true)]
        [string] $FilePath,
        [Parameter(Mandatory = $true)]
        [string] $Alias,
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present',
        [Parameter()]
        [string] $FileVirtualPath,
        [Parameter()]
        [string] $FolderName,
        [Parameter()]
        [ValidateSet('Allow', 'DoNotAllow', 'Require')]
        [string] $CommandLineSetting,
        [Parameter()]
        [string] $RequiredCommandLine,
        [Parameter()]
        [uint32] $IconIndex,
        [Parameter()]
        [string] $IconPath,
        [Parameter()]
        [string[]] $UserGroups,
        [Parameter()]
        [boolean] $ShowInWebAccess
    )

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
        [string] $CollectionName,
        [Parameter(Mandatory = $true)]
        [string] $DisplayName,
        [Parameter(Mandatory = $true)]
        [string] $FilePath,
        [Parameter(Mandatory = $true)]
        [string] $Alias,
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]$Ensure = 'Present',
        [Parameter()]
        [string] $FileVirtualPath,
        [Parameter()]
        [string] $FolderName,
        [Parameter()]
        [ValidateSet('Allow', 'DoNotAllow', 'Require')]
        [string] $CommandLineSetting,
        [Parameter()]
        [string] $RequiredCommandLine,
        [Parameter()]
        [uint32] $IconIndex,
        [Parameter()]
        [string] $IconPath,
        [Parameter()]
        [string[]] $UserGroups,
        [Parameter()]
        [boolean] $ShowInWebAccess
    )

    Write-Verbose 'Testing if RemoteApp is published.'

    try
    {
        $null = Get-RDSessionCollection -CollectionName $CollectionName -ErrorAction Stop
    }
    catch
    {
        throw "Failed to lookup RD Session Collection $CollectionName. Error: $_"
    }

    $getTargetResourceResult = Get-TargetResource @PSBoundParameters
    [System.Management.Automation.PSCmdlet]::CommonParameters | ForEach-Object -Process {
        $null = $PSBoundParameters.Remove($_)
    }

    $testDscParameterStateSplat = @{
        CurrentValues       = $getTargetResourceResult
        DesiredValues       = $PSBoundParameters
        TurnOffTypeChecking = $true
        SortArrayValues     = $true
    }

    Test-DscParameterState @testDscParameterStateSplat
}

Export-ModuleMember -Function *-TargetResource
