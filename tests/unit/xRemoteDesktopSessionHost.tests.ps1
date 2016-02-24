<#
.Synopsis
   Tests for common module for xRemoteDesktopSessionHost
.DESCRIPTION
   Tests for common module for xRemoteDesktopSessionHost

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>



#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}

Import-module "$moduleRoot\xRemoteDesktopSessionHostCommon.psm1" -force
Write-Verbose -Message "$moduleRoot\DscResources\*.psm1" -Verbose
$global:resourceModules = Get-ChildItem -Path "$moduleRoot\DscResources\*.psm1" -Recurse
Write-Verbose -Message "$($resourceModules.Count)" -Verbose 
#endregion

# TODO: Other Optional Init Code Goes Here...

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope xRemoteDesktopSessionHostCommon {

        #region Pester Test Initialization
            
        #endregion


        #region Function Test-xRemoteDesktopSessionHostOsRequirement
        Describe "Test-xRemoteDesktopSessionHostOsRequirement" {
            Context 'Windows 10' {
                Mock Get-OsVersion -MockWith {return (new-object 'Version' 10,1,1,1)}
                it 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $true
                }
            }
            Context 'Windows 8.1' {
                Mock Get-OsVersion -MockWith {return (new-object 'Version' 6,3,1,1)}
                it 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $true
                }
            }
            Context 'Windows 8' {
                Mock Get-OsVersion -MockWith {return (new-object 'Version' 6,2,9200,0)}
                it 'Should return true' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $true
                }
            }
            Context 'Windows 7' {
                Mock Get-OsVersion -MockWith {return (new-object 'Version' 6,1,1,0)}
                it 'Should return false' {
                    Test-xRemoteDesktopSessionHostOsRequirement | should be $false
                }
            }
        }
        #endregion


        # TODO: Pester Tests for any Helper Cmdlets

    }
    Describe "Test-xRemoteDesktopSessionHostOsRequirement use in modules" {
            Import-module "$moduleRoot\xRemoteDesktopSessionHost.psd1" -force
            Context 'Loading resource modules on Windows 10' {
                Mock Get-OsVersion -MockWith {return (new-object 'Version' 10,1,1,1)} -ModuleName xRemoteDesktopSessionHost
                foreach($resourceModule in $global:resourceModules)
                {
                    # The resource does not check if the remote desktop module existis before it loads it 
                    # so this always fails.  Pending this test for this issue
                    # https://github.com/PowerShell/xRemoteDesktopSessionHost/issues/6
                    it "$($resourceModule.Name) should not throw when imported" -Pending {
                        try {
                            $Error.Clear()
                            import-module $resourceModule.FullName -force -ErrorAction stop -ErrorVariable ImportVariable
                        }
                        catch {
                            Write-Verbose -Message 'in catch' -Verbose
                            $_ | should be $null
                        }
                        $Error.Count | should be 0
                    }
                }
            }            
    }
    #endregion
}
finally
{
    #region FOOTER
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
