@{
# Version number of this module.
moduleVersion = '1.9.0.0'

# ID used to uniquely identify this module
GUID = 'b42ff085-bd2b-4232-90ba-02b4c780e2d9'

# Author of this module
Author = 'Microsoft Corporation'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) 2014 Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module with DSC Resources for Remote Desktop Session Host'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

RootModule = 'xRemoteDesktopSessionHostCommon.psm1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/xRemoteDesktopSessionHost/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/xRemoteDesktopSessionHost'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '* Changes to xRDRemoteApp
  * Fixing typo in parameter name when calling the function ValidateCustomModeParameters (issue 50).
* Changes to xRDSessionDeployment
  * When RDMS service does not exist the Get-TargetResource will no longer throw an error (issue 47).
* Rename Tests/Unit folder to use upper case on first letter.
* Update appveyor.yml to use the default template.
* Added default template files .codecov.yml, .gitattributes, and .gitignore, and
  .vscode folder.
* xRDSessionCollectionConfiguration:
  * Changed CollectionName variable validation max length to 256
* xRDSessionCollection
  * Changed CollectionName variable validation max length to 256
* xRDRemoteApp
  * Changed CollectionName variable validation max length to 256

'

    } # End of PSData hashtable

} # End of PrivateData hashtable
}







