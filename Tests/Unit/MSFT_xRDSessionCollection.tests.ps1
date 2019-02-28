$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDSessionCollection'

#region HEADER

# Unit Test Template Version: 1.2.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Write-Output @('clone','https://github.com/PowerShell/DscResource.Tests.git',"'"+(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests')+"'")

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'),'--verbose')
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup {

}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment

}

# Begin Testing

try
{
    Invoke-TestSetup

    InModuleScope $script:DSCResourceName {
        $script:DSCResourceName    = 'MSFT_xRDSessionCollection'

        $testInvalidCollectionName = 'InvalidCollectionNameLongerThan15'
        $testcollectionName = 'TestCollection'
        
        $testSessionHost = 'localhost'
        $testConnectionBroker = 'localhost.fqdn'
        
        $validTargetResourceCall = @{
            CollectionName = $testCollectionName
            SessionHost = $testSessionHost
            ConnectionBroker = $testConnectionBroker
        }
        
        Import-Module RemoteDesktop -Force
        
        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Mock -CommandName Get-RDSessionCollection

            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Get-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }

                It 'Calls Get-RDSessionCollection with CollectionName and ConnectionBroker parameters' {
                    Get-TargetResource @validTargetResourceCall
                    Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope It -ParameterFilter {
                        $CollectionName -eq $testCollectionName -and
                        $ConnectionBroker -eq $testConnectionBroker
                    }
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Set-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }
            }
            
            Context 'Validate Set-TargetResource actions' {
                Mock -CommandName New-RDSessionCollection
                Mock -CommandName Add-RDSessionHost
                
                It 'Given the configuration is executed on the Connection Broker, New-RDSessionCollection is called' {
                    Set-TargetResource -CollectionName $testcollectionName -ConnectionBroker ([System.Net.Dns]::GetHostByName((hostname)).HostName) -SessionHost $testSessionHost
                    Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope It 
                }
                
                It 'Given the configuration is not executed on the Connection Broker, Add-RDSessionHost is called' {
                    Set-TargetResource @validTargetResourceCall
                    Assert-MockCalled -CommandName Add-RDSessionHost -Times 1 -Scope It 
                }
                
                It 'Given the configuration is not executed on the Connection Broker, and a description is passed, Add-RDSessionHost is called without the collection description' {
                    Set-TargetResource @validTargetResourceCall -CollectionDescription 'Pester Test Collection Output'
                    Assert-MockCalled -CommandName Add-RDSessionHost -Times 1 -Scope It 
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Test-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }
            }
            
            Context 'Validating Test-TargetResource output' {
                Mock -CommandName Get-RDSessionCollection
                
                It 'Given Get-RDSessionCollection not returning a collection, test returns false' {
                    Test-TargetResource @validTargetResourceCall | Should Be $false
                }
                
                Mock -CommandName Get-RDSessionCollection -MockWith {
                    [pscustomobject]@{
                        AutoAssignPersonalDesktop = $false
                        CollectionAlias = $testcollectionName
                        CollectionDescription = 'Pester Test Collection Output'
                        CollectionName = $testcollectionName
                        CollectionType = 'PooledUnmanaged'
                        GrantAdministrativePrivilege = $false
                        ResourceType = 'Remote Desktop'
                        Size = 1
                    }
                }
                
                It 'Given Get-RDSessionCollection returning a collection, test returns true' {
                    Test-TargetResource @validTargetResourceCall | Should Be $true
                }
            }
        }
        #endregion
    }
}
finally
{
    #region FOOTER
    Invoke-TestCleanup
    #endregion
}
