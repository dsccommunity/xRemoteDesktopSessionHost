$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDLicenseConfiguration'

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
        $script:DSCResourceName    = 'MSFT_xRDLicenseConfiguration'
        
        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context "Parameter Values,Validations and Errors" {
                Mock Get-RDLicenseConfiguration -MockWith {return $null}
                It "Should error if unable to get RD License config." {
                    {Get-TargetResource -ConnectionBroker "connectionbroker.lan" -LicenseMode "NotConfigured"} | should throw
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {
            
                Mock -CommandName Get-TargetResource -MockWith {
                    return @{
                        "ConnectionBroker"="connectionbroker.lan"
                        "LicenseServer"=@("One","Two")
                        "LicenseMode"="PerUser"
                    }
                } -ModuleName MSFT_xRDLicenseConfiguration
                
                It "Should return false if there's a change in license servers." {
                    Test-TargetResource -ConnectionBroker "connectionbroker.lan" -LicenseMode "PerUser" -LicenseServer "One" | should Be $false
                }

                Mock Get-TargetResource -MockWith {
                    return @{
                        "ConnectionBroker"="connectionbroker.lan"
                        "LicenseServer"=@("One","Two")
                        "LicenseMode"="PerUser"
                    }
                }
                
                It "Should return false if there's a change in license mode." {
                    Test-TargetResource -ConnectionBroker "connectionbroker.lan" -LicenseMode "PerDevice" -LicenseServer @("One","Two") | should Be $false
                }
                
                It "Should return true if there are no changes in license mode." {
                    Test-TargetResource -ConnectionBroker "connectionbroker.lan" -LicenseMode "PerUser" -LicenseServer @("One","Two") | should Be $true
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
        
            Context "Configuration changes performed by Set" {
                
                Mock -CommandName Set-RDLicenseConfiguration
                
                It 'Given license servers, Set-RDLicenseConfiguration is called with LicenseServer parameter' {
                    Set-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode PerDevice -LicenseServer 'LicenseServer1'
                    Assert-MockCalled -CommandName Set-RDLicenseConfiguration -Times 1 -ParameterFilter {
                        $LicenseServer -eq 'LicenseServer1'
                    }
                }
                
                It 'Given no license servers, Set-RDLicenseConfiguration is called without LicenseServer parameter' {
                    Set-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode PerDevice
                    Assert-MockCalled -CommandName Set-RDLicenseConfiguration -Times 1 -ParameterFilter {
                        $LicenseServer -eq $null
                    } -Scope It
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
