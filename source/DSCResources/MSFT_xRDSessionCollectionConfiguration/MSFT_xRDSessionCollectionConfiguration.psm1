$resourceModulePath = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$modulesFolderPath = Join-Path -Path $resourceModulePath -ChildPath 'Modules'

$rdCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'xRemoteDesktopSessionHostCommon.psm1'
Import-Module -Name $rdCommonModulePath

$dscResourceCommonModulePath = Join-Path -Path $modulesFolderPath -ChildPath 'DscResource.Common'
Import-Module -Name $dscResourceCommonModulePath

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
        [Parameter()]
        [uint32] $ActiveSessionLimitMin,
        [Parameter()]
        [boolean] $AuthenticateUsingNLA,
        [Parameter()]
        [boolean] $AutomaticReconnectionEnabled,
        [Parameter()]
        [string] $BrokenConnectionAction,
        [Parameter()]
        [string] $ClientDeviceRedirectionOptions,
        [Parameter()]
        [boolean] $ClientPrinterAsDefault,
        [Parameter()]
        [boolean] $ClientPrinterRedirected,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker,
        [Parameter()]
        [string] $CustomRdpProperty,
        [Parameter()]
        [uint32] $DisconnectedSessionLimitMin,
        [Parameter()]
        [string] $EncryptionLevel,
        [Parameter()]
        [uint32] $IdleSessionLimitMin,
        [Parameter()]
        [uint32] $MaxRedirectedMonitors,
        [Parameter()]
        [boolean] $RDEasyPrintDriverEnabled,
        [Parameter()]
        [string] $SecurityLayer,
        [Parameter()]
        [boolean] $TemporaryFoldersDeletedOnExit,
        [Parameter()]
        [string] $UserGroup,
        [Parameter()]
        [string] $DiskPath,
        [Parameter()]
        [bool] $EnableUserProfileDisk,
        [Parameter()]
        [uint32] $MaxUserProfileDiskSizeGB,
        [Parameter()]
        [string[]] $IncludeFolderPath,
        [Parameter()]
        [string[]] $ExcludeFolderPath,
        [Parameter()]
        [string[]] $IncludeFilePath,
        [Parameter()]
        [string[]] $ExcludeFilePath
    )
        Write-Verbose "Getting currently configured RDSH Collection properties for collection $CollectionName"

        $collectionGeneral = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName
        $collectionClient = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -Client
        $collectionConnection = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -Connection
        $collectionSecurity = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -Security
        $collectionUserGroup = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -UserGroup

        $result = @{
            CollectionName = $collectionGeneral.CollectionName
            ActiveSessionLimitMin = $collectionConnection.ActiveSessionLimitMin
            AuthenticateUsingNLA = $collectionSecurity.AuthenticateUsingNLA
            AutomaticReconnectionEnabled = $collectionConnection.AutomaticReconnectionEnabled
            BrokenConnectionAction = $collectionConnection.BrokenConnectionAction
            ClientDeviceRedirectionOptions = $collectionClient.ClientDeviceRedirectionOptions
            ClientPrinterAsDefault = $collectionClient.ClientPrinterAsDefault
            ClientPrinterRedirected = $collectionClient.ClientPrinterRedirected
            CollectionDescription = $collectionGeneral.CollectionDescription
            # For whatever reason this value gets returned with a trailing carriage return
            CustomRdpProperty = ([string]$collectionGeneral.CustomRdpProperty).Trim()
            DisconnectedSessionLimitMin = $collectionConnection.DisconnectedSessionLimitMin
            EncryptionLevel = $collectionSecurity.EncryptionLevel
            IdleSessionLimitMin = $collectionConnection.IdleSessionLimitMin
            MaxRedirectedMonitors = $collectionClient.MaxRedirectedMonitors
            RDEasyPrintDriverEnabled = $collectionClient.RDEasyPrintDriverEnabled
            SecurityLayer = $collectionSecurity.SecurityLayer
            TemporaryFoldersDeletedOnExit = $collectionConnection.TemporaryFoldersDeletedOnExit
            UserGroup = $collectionUserGroup.UserGroup
        }

        # This part of the configuration only applies to Win 2016+
        if ((Get-xRemoteDesktopSessionHostOsVersion).Major -ge 10)
        {
            Write-Verbose 'Running on W2016+, get UserProfileDisk configuration'
            $collectionUserProfileDisk = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -UserProfileDisk

            $null = $result.Add('DiskPath', $collectionUserProfileDisk.DiskPath)
            $null = $result.Add('EnableUserProfileDisk', $collectionUserProfileDisk.EnableUserProfileDisk)
            $null = $result.Add('MaxUserProfileDiskSizeGB', $collectionUserProfileDisk.MaxUserProfileDiskSizeGB)
            $null = $result.Add('IncludeFolderPath', $collectionUserProfileDisk.IncludeFolderPath)
            $null = $result.Add('ExcludeFolderPath', $collectionUserProfileDisk.ExcludeFolderPath)
            $null = $result.Add('IncludeFilePath', $collectionUserProfileDisk.IncludeFilePath)
            $null = $result.Add('ExcludeFilePath', $collectionUserProfileDisk.ExcludeFilePath)
        }

        $result
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
        [Parameter()]
        [uint32] $ActiveSessionLimitMin,
        [Parameter()]
        [boolean] $AuthenticateUsingNLA,
        [Parameter()]
        [boolean] $AutomaticReconnectionEnabled,
        [Parameter()]
        [string] $BrokenConnectionAction,
        [Parameter()]
        [string] $ClientDeviceRedirectionOptions,
        [Parameter()]
        [boolean] $ClientPrinterAsDefault,
        [Parameter()]
        [boolean] $ClientPrinterRedirected,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker,
        [Parameter()]
        [string] $CustomRdpProperty,
        [Parameter()]
        [uint32] $DisconnectedSessionLimitMin,
        [Parameter()]
        [string] $EncryptionLevel,
        [Parameter()]
        [uint32] $IdleSessionLimitMin,
        [Parameter()]
        [uint32] $MaxRedirectedMonitors,
        [Parameter()]
        [boolean] $RDEasyPrintDriverEnabled,
        [Parameter()]
        [string] $SecurityLayer,
        [Parameter()]
        [boolean] $TemporaryFoldersDeletedOnExit,
        [Parameter()]
        [string] $UserGroup,
        [Parameter()]
        [string] $DiskPath,
        [Parameter()]
        [bool] $EnableUserProfileDisk,
        [Parameter()]
        [uint32] $MaxUserProfileDiskSizeGB,
        [Parameter()]
        [string[]] $IncludeFolderPath,
        [Parameter()]
        [string[]] $ExcludeFolderPath,
        [Parameter()]
        [string[]] $IncludeFilePath,
        [Parameter()]
        [string[]] $ExcludeFilePath
    )
    Write-Verbose "Setting DSC collection properties"

    try
    {
        $null = Get-RDSessionCollection -CollectionName $CollectionName -ErrorAction Stop
    }
    catch
    {
        throw "Failed to lookup RD Session Collection $CollectionName. Error: $_"
    }

    # By default we do not configure the UserProfileDisk (this is in a different parameter set and we could be running on W2012 R2)
    $null = $PSBoundParameters.Remove('DiskPath')
    $null = $PSBoundParameters.Remove('EnableUserProfileDisk')
    $null = $PSBoundParameters.Remove('ExcludeFilePath')
    $null = $PSBoundParameters.Remove('ExcludeFolderPath')
    $null = $PSBoundParameters.Remove('IncludeFilePath')
    $null = $PSBoundParameters.Remove('IncludeFolderPath')
    $null = $PSBoundParameters.Remove('MaxUserProfileDiskSizeGB')

    if ((Get-xRemoteDesktopSessionHostOsVersion).Major -ge 10)
    {
        Write-Verbose 'Running on W2016 or higher, prepare to set UserProfileDisk configuration'

        # First set the initial configuration before trying to modify the UserProfileDisk Configuration
        Set-RDSessionCollectionConfiguration @PSBoundParameters

        if ($EnableUserProfileDisk)
        {
            Write-Verbose 'EnableUserProfileDisk is True - a DiskPath and MaxUserProfileDiskSizeGB are now mandatory'

            if ($DiskPath)
            {
                $validateDiskPath = Test-Path -Path $DiskPath -ErrorAction SilentlyContinue
                if (-not($validateDiskPath))
                {
                    throw "To enable UserProfileDisk we need a valid DiskPath. Path $DiskPath not found"
                }
                else
                {
                    Write-Verbose "EnableUserProfileDisk: Validated diskPath: $DiskPath"
                }
            }
            else
            {
                throw "No value found for parameter DiskPath. This is a mandatory parameter if EnableUserProfileDisk is set to True"
            }

            if ($MaxUserProfileDiskSizeGB -gt 0)
            {
                Write-Verbose "EnableUserProfileDisk: Validated MaxUserProfileDiskSizeGB size: $MaxUserProfileDiskSizeGB"
            }
            else
            {
                throw "To enable UserProfileDisk we need a setting for MaxUserProfileDiskSizeGB that is greater than 0. Current value $MaxUserProfileDiskSizeGB is not valid"
            }

            $enableUserProfileDiskSplat = @{
                CollectionName = $CollectionName
                DiskPath = $DiskPath
                EnableUserProfileDisk = $EnableUserProfileDisk
                ExcludeFilePath = $ExcludeFilePath
                ExcludeFolderPath = $ExcludeFolderPath
                IncludeFilePath = $IncludeFilePath
                IncludeFolderPath = $IncludeFolderPath
                MaxUserProfileDiskSizeGB = $MaxUserProfileDiskSizeGB
            }

            # 2>&1 redirects the error stream to output stream. This for us to be able to ignore certain errors that popup in Set-RDSessionCollectionConfiguration.
            $null = Set-RDSessionCollectionConfiguration @enableUserProfileDiskSplat -ErrorAction SilentlyContinue -ErrorVariable setRDSessionCollectionErrors 2>&1

            # This is a workaround for the buggy Set-RDSessionCollectionConfiguration. This command starts the functions in the Microsoft.windows.servermanagerworkflows configuration.
            # In this configuration, the C:\Windows\system32\WindowsPowerShell\v1.0\Modules\RemoteDesktop\Utility.psm1 module cannot call the RemoteDesktop module functions as they seem to load without the -RD prefix.
            # Here, we work around the errors thrown by Test-UserVhdPathInUse (the function in the Utility.psm1 module which calls the RemoteDesktop module functions)

            foreach ($setRDSessionCollectionError in $setRDSessionCollectionErrors)
            {
                if ($SetRDSessionCollectionError.FullyQualifiedErrorId -eq 'CommandNotFoundException')
                {
                    Write-Verbose "Set-RDSessionCollectionConfiguration: trapped erroneous CommandNotFoundException errors, that's ok, continuing..."
                    # ignore & continue
                }
                else
                {
                    Write-Error "Set-RDSessionCollectionConfiguration error: $setRDSessionCollectionError"
                }
            }
        }
        else
        {
            Set-RDSessionCollectionConfiguration -CollectionName $CollectionName -DisableUserProfileDisk
        }
    }
    else
    {
        Set-RDSessionCollectionConfiguration @PSBoundParameters
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
        [Parameter()]
        [uint32] $ActiveSessionLimitMin,
        [Parameter()]
        [boolean] $AuthenticateUsingNLA,
        [Parameter()]
        [boolean] $AutomaticReconnectionEnabled,
        [Parameter()]
        [string] $BrokenConnectionAction,
        [Parameter()]
        [string] $ClientDeviceRedirectionOptions,
        [Parameter()]
        [boolean] $ClientPrinterAsDefault,
        [Parameter()]
        [boolean] $ClientPrinterRedirected,
        [Parameter()]
        [string] $CollectionDescription,
        [Parameter()]
        [string] $ConnectionBroker,
        [Parameter()]
        [string] $CustomRdpProperty,
        [Parameter()]
        [uint32] $DisconnectedSessionLimitMin,
        [Parameter()]
        [string] $EncryptionLevel,
        [Parameter()]
        [uint32] $IdleSessionLimitMin,
        [Parameter()]
        [uint32] $MaxRedirectedMonitors,
        [Parameter()]
        [boolean] $RDEasyPrintDriverEnabled,
        [Parameter()]
        [string] $SecurityLayer,
        [Parameter()]
        [boolean] $TemporaryFoldersDeletedOnExit,
        [Parameter()]
        [string] $UserGroup,
        [Parameter()]
        [string] $DiskPath,
        [Parameter()]
        [bool] $EnableUserProfileDisk,
        [Parameter()]
        [uint32] $MaxUserProfileDiskSizeGB,
        [Parameter()]
        [string[]] $IncludeFolderPath,
        [Parameter()]
        [string[]] $ExcludeFolderPath,
        [Parameter()]
        [string[]] $IncludeFilePath,
        [Parameter()]
        [string[]] $ExcludeFilePath
    )

    $verbose = $PSBoundParameters.Verbose -eq $true

    Write-Verbose "Testing DSC collection properties"

    $null = $PSBoundParameters.Remove('Verbose')
    $null = $PSBoundParameters.Remove('Debug')
    $null = $PSBoundParameters.Remove('ConnectionBroker')

    if ((Get-xRemoteDesktopSessionHostOsVersion).Major -lt 10)
    {
        Write-Verbose 'Running on W2012R2 or lower, removing properties that are not compatible'

        $null = $PSBoundParameters.Remove('CollectionName')
        $null = $PSBoundParameters.Remove('DiskPath')
        $null = $PSBoundParameters.Remove('EnableUserProfileDisk')
        $null = $PSBoundParameters.Remove('ExcludeFilePath')
        $null = $PSBoundParameters.Remove('ExcludeFolderPath')
        $null = $PSBoundParameters.Remove('IncludeFilePath')
        $null = $PSBoundParameters.Remove('IncludeFolderPath')
        $null = $PSBoundParameters.Remove('MaxUserProfileDiskSizeGB')
    }

    if (-not($EnableUserProfileDisk))
    {
        Write-Verbose 'Running on W2016+ and UserProfileDisk is disabled. Removing properties from compare'

        $null = $PSBoundParameters.Remove('DiskPath')
        $null = $PSBoundParameters.Remove('ExcludeFilePath')
        $null = $PSBoundParameters.Remove('ExcludeFolderPath')
        $null = $PSBoundParameters.Remove('IncludeFilePath')
        $null = $PSBoundParameters.Remove('IncludeFolderPath')
        $null = $PSBoundParameters.Remove('MaxUserProfileDiskSizeGB')
    }

    $testDscParameterStateSplat = @{
        CurrentValues = Get-TargetResource -CollectionName $CollectionName
        DesiredValues = $PSBoundParameters
        TurnOffTypeChecking = $true
        SortArrayValues = $true
        Verbose = $verbose
    }

    Test-DscParameterState @testDscParameterStateSplat
}

Export-ModuleMember -Function *-TargetResource
