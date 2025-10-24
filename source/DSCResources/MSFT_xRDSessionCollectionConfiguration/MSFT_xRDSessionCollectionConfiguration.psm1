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

        [Parameter()]
        [System.UInt32]
        $ActiveSessionLimitMin,

        [Parameter()]
        [System.Boolean]
        $AuthenticateUsingNLA,

        [Parameter()]
        [System.Boolean]
        $AutomaticReconnectionEnabled,

        [Parameter()]
        [System.String]
        $BrokenConnectionAction,

        [Parameter()]
        [System.String]
        $ClientDeviceRedirectionOptions,

        [Parameter()]
        [System.Boolean]
        $ClientPrinterAsDefault,

        [Parameter()]
        [System.Boolean]
        $ClientPrinterRedirected,

        [Parameter()]
        [System.String]
        $CollectionDescription,

        [Parameter()]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.String]
        $CustomRdpProperty,

        [Parameter()]
        [System.UInt32]
        $DisconnectedSessionLimitMin,

        [Parameter()]
        [System.String]
        $EncryptionLevel,

        [Parameter()]
        [System.UInt32]
        $IdleSessionLimitMin,

        [Parameter()]
        [System.UInt32]
        $MaxRedirectedMonitors,

        [Parameter()]
        [System.Boolean]
        $RDEasyPrintDriverEnabled,

        [Parameter()]
        [System.String]
        $SecurityLayer,

        [Parameter()]
        [System.Boolean]
        $TemporaryFoldersDeletedOnExit,

        [Parameter()]
        [System.String[]]
        $UserGroup,

        [Parameter()]
        [System.String]
        $DiskPath,

        [Parameter()]
        [System.Boolean]
        $EnableUserProfileDisk,

        [Parameter()]
        [System.UInt32]
        $MaxUserProfileDiskSizeGB,

        [Parameter()]
        [System.String[]]
        $IncludeFolderPath,

        [Parameter()]
        [System.String[]]
        $ExcludeFolderPath,

        [Parameter()]
        [System.String[]]
        $IncludeFilePath,

        [Parameter()]
        [System.String[]]
        $ExcludeFilePath
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose "Getting currently configured RDSH Collection properties for collection $CollectionName"

    $collectionGeneral = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName
    $collectionClient = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -Client
    $collectionConnection = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -Connection
    $collectionSecurity = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -Security
    $collectionUserGroup = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -UserGroup

    $result = @{
        CollectionName                 = $collectionGeneral.CollectionName
        CollectionDescription          = $collectionGeneral.CollectionDescription
        # For whatever reason this value gets returned with a trailing carriage return
        CustomRdpProperty              = ([System.String]$collectionGeneral.CustomRdpProperty).Trim()

        ClientDeviceRedirectionOptions = $collectionClient.ClientDeviceRedirectionOptions
        ClientPrinterAsDefault         = $collectionClient.ClientPrinterAsDefault
        ClientPrinterRedirected        = $collectionClient.ClientPrinterRedirected
        MaxRedirectedMonitors          = $collectionClient.MaxRedirectedMonitors
        RDEasyPrintDriverEnabled       = $collectionClient.RDEasyPrintDriverEnabled

        ActiveSessionLimitMin          = $collectionConnection.ActiveSessionLimitMin
        AutomaticReconnectionEnabled   = $collectionConnection.AutomaticReconnectionEnabled
        BrokenConnectionAction         = $collectionConnection.BrokenConnectionAction
        DisconnectedSessionLimitMin    = $collectionConnection.DisconnectedSessionLimitMin
        IdleSessionLimitMin            = $collectionConnection.IdleSessionLimitMin
        TemporaryFoldersDeletedOnExit  = $collectionConnection.TemporaryFoldersDeletedOnExit

        AuthenticateUsingNLA           = $collectionSecurity.AuthenticateUsingNLA
        EncryptionLevel                = $collectionSecurity.EncryptionLevel
        SecurityLayer                  = $collectionSecurity.SecurityLayer

        UserGroup                      = $collectionUserGroup.UserGroup
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
        [ValidateLength(1, 256)]
        [System.String]
        $CollectionName,

        [Parameter()]
        [System.UInt32]
        $ActiveSessionLimitMin,

        [Parameter()]
        [System.Boolean]
        $AuthenticateUsingNLA,

        [Parameter()]
        [System.Boolean]
        $AutomaticReconnectionEnabled,

        [Parameter()]
        [System.String]
        $BrokenConnectionAction,

        [Parameter()]
        [System.String]
        $ClientDeviceRedirectionOptions,

        [Parameter()]
        [System.Boolean]
        $ClientPrinterAsDefault,

        [Parameter()]
        [System.Boolean]
        $ClientPrinterRedirected,

        [Parameter()]
        [System.String]
        $CollectionDescription,

        [Parameter()]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.String]
        $CustomRdpProperty,

        [Parameter()]
        [System.UInt32]
        $DisconnectedSessionLimitMin,

        [Parameter()]
        [System.String]
        $EncryptionLevel,

        [Parameter()]
        [System.UInt32]
        $IdleSessionLimitMin,

        [Parameter()]
        [System.UInt32]
        $MaxRedirectedMonitors,

        [Parameter()]
        [System.Boolean]
        $RDEasyPrintDriverEnabled,

        [Parameter()]
        [System.String]
        $SecurityLayer,

        [Parameter()]
        [System.Boolean]
        $TemporaryFoldersDeletedOnExit,

        [Parameter()]
        [System.String[]]
        $UserGroup,

        [Parameter()]
        [System.String]
        $DiskPath,

        [Parameter()]
        [System.Boolean]
        $EnableUserProfileDisk,

        [Parameter()]
        [System.UInt32]
        $MaxUserProfileDiskSizeGB,

        [Parameter()]
        [System.String[]]
        $IncludeFolderPath,

        [Parameter()]
        [System.String[]]
        $ExcludeFolderPath,

        [Parameter()]
        [System.String[]]
        $IncludeFilePath,

        [Parameter()]
        [System.String[]]
        $ExcludeFilePath
    )

    Assert-Module -ModuleName 'RemoteDesktop' -ImportModule

    Write-Verbose 'Setting DSC collection properties'

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
                if (-not(Test-Path -Path $DiskPath -ErrorAction SilentlyContinue))
                {
                    New-ArgumentException -ArgumentName 'DiskPath' -Message ('To enable UserProfileDisk we need a valid DiskPath. Path {0} not found' -f $DiskPath)
                }
                else
                {
                    Write-Verbose "EnableUserProfileDisk: Validated diskPath: $DiskPath"
                }
            }
            else
            {
                New-ArgumentException -ArgumentName 'DiskPath' -Message 'No value found for parameter DiskPath. This is a mandatory parameter if EnableUserProfileDisk is set to True'
            }

            if ($MaxUserProfileDiskSizeGB -gt 0)
            {
                Write-Verbose "EnableUserProfileDisk: Validated MaxUserProfileDiskSizeGB size: $MaxUserProfileDiskSizeGB"
            }
            else
            {
                New-ArgumentException -ArgumentName 'MaxUserProfileDiskSizeGB' -Message (
                    'To enable UserProfileDisk we need a setting for MaxUserProfileDiskSizeGB that is greater than 0. Current value {0} is not valid' -f $MaxUserProfileDiskSizeGB
                )
            }

            $enableUserProfileDiskSplat = @{
                CollectionName           = $CollectionName
                DiskPath                 = $DiskPath
                EnableUserProfileDisk    = $EnableUserProfileDisk
                ExcludeFilePath          = $ExcludeFilePath
                ExcludeFolderPath        = $ExcludeFolderPath
                IncludeFilePath          = $IncludeFilePath
                IncludeFolderPath        = $IncludeFolderPath
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
        [ValidateLength(1, 256)]
        [System.String]
        $CollectionName,

        [Parameter()]
        [System.UInt32]
        $ActiveSessionLimitMin,

        [Parameter()]
        [System.Boolean]
        $AuthenticateUsingNLA,

        [Parameter()]
        [System.Boolean]
        $AutomaticReconnectionEnabled,

        [Parameter()]
        [System.String]
        $BrokenConnectionAction,

        [Parameter()]
        [System.String]
        $ClientDeviceRedirectionOptions,

        [Parameter()]
        [System.Boolean]
        $ClientPrinterAsDefault,

        [Parameter()]
        [System.Boolean]
        $ClientPrinterRedirected,

        [Parameter()]
        [System.String]
        $CollectionDescription,

        [Parameter()]
        [System.String]
        $ConnectionBroker,

        [Parameter()]
        [System.String]
        $CustomRdpProperty,

        [Parameter()]
        [System.UInt32]
        $DisconnectedSessionLimitMin,

        [Parameter()]
        [System.String]
        $EncryptionLevel,

        [Parameter()]
        [System.UInt32]
        $IdleSessionLimitMin,

        [Parameter()]
        [System.UInt32]
        $MaxRedirectedMonitors,

        [Parameter()]
        [System.Boolean]
        $RDEasyPrintDriverEnabled,

        [Parameter()]
        [System.String]
        $SecurityLayer,

        [Parameter()]
        [System.Boolean]
        $TemporaryFoldersDeletedOnExit,

        [Parameter()]
        [System.String[]]
        $UserGroup,

        [Parameter()]
        [System.String]
        $DiskPath,

        [Parameter()]
        [System.Boolean]
        $EnableUserProfileDisk,

        [Parameter()]
        [System.UInt32]
        $MaxUserProfileDiskSizeGB,

        [Parameter()]
        [System.String[]]
        $IncludeFolderPath,

        [Parameter()]
        [System.String[]]
        $ExcludeFolderPath,

        [Parameter()]
        [System.String[]]
        $IncludeFilePath,

        [Parameter()]
        [System.String[]]
        $ExcludeFilePath
    )

    Write-Verbose 'Testing DSC collection properties'

    $null = $PSBoundParameters.Remove('Verbose')
    $null = $PSBoundParameters.Remove('Debug')
    $null = $PSBoundParameters.Remove('ConnectionBroker')

    if ((Get-xRemoteDesktopSessionHostOsVersion).Major -lt 10)
    {
        Write-Verbose 'Running on W2012R2 or lower, removing properties that are not compatible'

        $null = $PSBoundParameters.Remove('CollectionName')
        $null = $PSBoundParameters.Remove('EnableUserProfileDisk')
        $null = $PSBoundParameters.Remove('DiskPath')
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
        CurrentValues       = Get-TargetResource -CollectionName $CollectionName
        DesiredValues       = $PSBoundParameters
        TurnOffTypeChecking = $true
        SortArrayValues     = $true
        Verbose             = $VerbosePreference
    }

    Test-DscParameterState @testDscParameterStateSplat
}

Export-ModuleMember -Function *-TargetResource
