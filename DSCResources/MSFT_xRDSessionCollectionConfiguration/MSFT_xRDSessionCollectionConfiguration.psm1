Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}
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
        [ValidateLength(1,15)]
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
        [int] $MaxUserProfileDiskSizeGB,
        [Parameter()]
        [string[]] $IncludeFolderPath,
        [Parameter()]
        [string[]] $ExcludeFolderPath,
        [Parameter()]
        [string[]] $IncludeFilePath,
        [Parameter()]
        [string[]] $ExcludeFilePath
    )
        Write-Verbose "Getting currently configured RDSH Collection properties"
        $collectionName = Get-RDSessionCollection | 
            ForEach-Object {Get-RDSessionHost $_.CollectionName} | 
            Where-Object {$_.SessionHost -ieq $localhost} | 
            ForEach-Object {$_.CollectionName}

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
            CustomRdpProperty = $collectionGeneral.CustomRdpProperty
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
        if(([version](Get-CimInstance -ClassName win32_operatingsystem -Property Version).Version).Major -ge 10) {
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
        [ValidateLength(1,15)]
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
        [int] $MaxUserProfileDiskSizeGB,
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

    $discoveredCollectionName = Get-RDSessionCollection | 
        ForEach-Object {Get-RDSessionHost $_.CollectionName} | 
        Where-Object {$_.SessionHost -ieq $localhost} | 
        ForEach-Object {$_.CollectionName}

    if ($collectionName -ne $discoveredCollectionName) {
        $PSBoundParameters.collectionName = $discoveredCollectionName
    }

    if(([version](Get-CimInstance -ClassName win32_operatingsystem -Property Version).Version).Major -ge 10) {
        Write-Verbose 'Running on W2016 or higher, testing UserProfileDisk'

        $null = $PSBoundParameters.Remove('DiskPath')  
        $null = $PSBoundParameters.Remove('EnableUserProfileDisk')
        $null = $PSBoundParameters.Remove('ExcludeFilePath')       
        $null = $PSBoundParameters.Remove('ExcludeFolderPath')
        $null = $PSBoundParameters.Remove('IncludeFilePath')     
        $null = $PSBoundParameters.Remove('IncludeFolderPath')   
        $null = $PSBoundParameters.Remove('MaxUserProfileDiskSizeGB')

        # First set the initial configuration before trying to modify the UserProfileDisk Configuration
        Set-RDSessionCollectionConfiguration @PSBoundParameters

        if($EnableUserProfileDisk) {
            Write-Verbose 'EnableUserProfileDisk is True - a DiskPath and MaxUserProfileDiskSizeGB are now mandatory'
            $validateDiskPath = Test-Path -Path $DiskPath -ErrorAction SilentlyContinue
            if(-not($validateDiskPath)) {
                Throw "To enable UserProfileDisk we need a valid DiskPath. Path $DiskPath not found"
            }
            else {
                Write-Verbose "EnableUserProfileDisk: Validated diskPath: $DiskPath"
            }

            if(-not($MaxUserProfileDiskSizeGB -gt 0)) {
                Throw "To enable UserProfileDisk we need a setting for MaxUserProfileDiskSizeGB that is greater than 0. Current value $MaxUserProfileDiskSizeGB is not valid"
            }
            else {
                Write-Verbose "EnableUserProfileDisk: Validated MaxUserProfileDiskSizeGB size: $MaxUserProfileDiskSizeGB"
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

            $errorMsg = Set-RDSessionCollectionConfiguration @enableUserProfileDiskSplat 2>&1

            # This is a workaround for the buggy RemoteDesktop module spamming errors because the functions are imported without prefix.
            $expectedErrorMessages = @(
                "The term 'Get-RDSessionCollection' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again."
                "The term 'Get-RDVirtualDesktopCollection' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again."
            )

            foreach($msg in $errorMsg) {
                if($msg -in $expectedErrorMessages) {
                    Write-Verbose $msg
                }
                else {
                    Write-Error $msg
                }
            }
        }
        else {
            Set-RDSessionCollectionConfiguration -CollectionName $CollectionName -DisableUserProfileDisk
        }
    }
    else {
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
        [ValidateLength(1,15)]
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
        [int] $MaxUserProfileDiskSizeGB,
        [Parameter()]
        [string[]] $IncludeFolderPath,
        [Parameter()]
        [string[]] $ExcludeFolderPath,
        [Parameter()]
        [string[]] $IncludeFilePath,
        [Parameter()]
        [string[]] $ExcludeFilePath
    )
    
    Write-Verbose "Testing DSC collection properties"
    $collectionName = Get-RDSessionCollection | 
        ForEach-Object {Get-RDSessionHost $_.CollectionName} | 
        Where-Object {$_.SessionHost -ieq $localhost} | 
        ForEach-Object {$_.CollectionName}

    $null = $PSBoundParameters.Remove('Verbose')
    $null = $PSBoundParameters.Remove('Debug')
    $null = $PSBoundParameters.Remove('ConnectionBroker')
    $isInDesiredState = $true

    if(([version](Get-CimInstance -ClassName win32_operatingsystem -Property Version).Version).Major -lt 10) {
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

    if(-not($EnableUserProfileDisk)) {
        Write-Verbose 'Running on W2016+ and UserProfileDisk is disabled. Removing properties from compare'

        $null = $PSBoundParameters.Remove('DiskPath')  
        $null = $PSBoundParameters.Remove('ExcludeFilePath')       
        $null = $PSBoundParameters.Remove('ExcludeFolderPath')
        $null = $PSBoundParameters.Remove('IncludeFilePath')     
        $null = $PSBoundParameters.Remove('IncludeFolderPath')   
        $null = $PSBoundParameters.Remove('MaxUserProfileDiskSizeGB')
    }

    $get = Get-TargetResource -CollectionName $CollectionName

    foreach($name in $PSBoundParameters.Keys) {
        if ($PSBoundParameters[$name] -ne $get[$name]) {
            Write-Verbose ('Property: {0} with value {1} does not match value {2}' -f $name, $PSBoundParameters[$name], $get[$name])
            $isInDesiredState = $false
        }
        else {
            Write-Verbose "Property: $name - InDesiredState: True"
        }
    }

    $isInDesiredState
}

Export-ModuleMember -Function *-TargetResource

