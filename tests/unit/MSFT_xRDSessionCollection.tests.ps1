$Global:DSCModuleName      = '.\xRemoteDesktopSessionHost' # Example xNetworking
$Global:DSCResourceName    = 'MSFT_xRDSessionCollection' # Example MSFT_xFirewall

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
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing

try
{
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        # TODO: Optopnal Load Mock for use in Pester tests here...
        #endregion

        $testCollectionName = 'Name'
        $testInvalidCollectionName = 'InvalidCollectionName longer than 15'
        $testSessionHost = 'computername'
        
        Import-Module RemoteDesktop -Force
        
        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Get-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} `
                        | should throw
                }

                It "Should not error when the CollectionName length is less than 15" {
                    {Get-TargetResource -CollectionName $testCollectionName -SessionHost $testSessionHost} `
                        | should not throw
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Set-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} `
                        | should throw
                }

                It "Should not error when the CollectionName length is less than 15" {
                    {Set-TargetResource -CollectionName $testCollectionName -SessionHost $testSessionHost} `
                        | should not throw
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Test-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} `
                        | should throw
                }

                It "Should not error when the CollectionName length is less than 15" {
                    {Test-TargetResource -CollectionName $testCollectionName -SessionHost $testSessionHost} `
                        | should not throw
                }
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
