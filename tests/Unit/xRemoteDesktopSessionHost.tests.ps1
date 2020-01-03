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
        Describe "Test-xRemoteDesktopSessionHostOsRequirement" {
            Context 'Windows 10' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith {return (new-object 'Version' 10,1,1,1)}
                it 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $true
                }
            }
            Context 'Windows 8.1' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith {return (new-object 'Version' 6,3,1,1)}
                it 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $true
                }
            }
            Context 'Windows 8' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith {return (new-object 'Version' 6,2,9200,0)}
                it 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $true
                }
            }
            Context 'Windows 7' {
                Mock Get-xRemoteDesktopSessionHostOsVersion -MockWith {return (new-object 'Version' 6,1,1,0)}
                it 'Should return false' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $false
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
