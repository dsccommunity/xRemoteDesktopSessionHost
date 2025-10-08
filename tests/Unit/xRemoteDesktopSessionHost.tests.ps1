function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }
}

function Invoke-TestCleanup
{

}

Invoke-TestSetup

try
{
    InModuleScope xRemoteDesktopSessionHostCommon {

        #region Function Test-xRemoteDesktopSessionHostOsRequirement
        Describe 'Test-xRemoteDesktopSessionHostOsRequirement' {
            Context 'Windows 10' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith { return (New-Object 'Version' 10, 1, 1, 1) }
                It 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | Should be $true
                }
            }
            Context 'Windows 8.1' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith { return (New-Object 'Version' 6, 3, 1, 1) }
                It 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | Should be $true
                }
            }
            Context 'Windows 8' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith { return (New-Object 'Version' 6, 2, 9200, 0) }
                It 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | Should be $true
                }
            }
            Context 'Windows 7' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith { return (New-Object 'Version' 6, 1, 1, 0) }
                It 'Should return false' {
                    Test-xRemoteDesktopSessionHostOsRequirement | Should be $false
                }
            }
        }
        #endregion

    }
}
finally
{
    Invoke-TestCleanup
}
