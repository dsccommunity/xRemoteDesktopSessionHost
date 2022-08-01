<#
    .DESCRIPTION
        This example shows how to ensure deploy PowerShell as a RemoteApp.
#>

Configuration Example
{

    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    Node localhost {

        xRDRemoteApp 'Notepad' {
            Alias = 'PowerShell without Profile'
            CollectionName = 'BD_Python_Apps'
            CommandLineSetting = 'Require'
            DisplayName = 'PowerShell'
            FilePath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
            FolderName = ''
            IconPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
            RequiredCommandLine = '-noprofile'
            ShowInWebAccess = $True
            UserGroups = ''
            FileVirtualPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
        }
    }
}
