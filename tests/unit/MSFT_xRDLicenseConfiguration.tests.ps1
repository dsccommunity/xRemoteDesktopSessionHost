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
                    {Get-TargetResource -ConnectionBroker "connectionbroker.lan" } `
                        | should throw
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {
                Mock -CommandName Get-TargetResource -MockWith {return @{"ConnectionBroker"="connectionbroker.lan";"LicenseServers"=@("One","Two");"LicenseMode"="PerUser"}} -ModuleName MSFT_xRDLicenseConfiguration
                It "Should return false if there's a change in license servers." {
                    Test-TargetResource -ConnectionBroker "connectionbroker.lan" -LicenseMode "PerUser" -LicenseServers "One" `
                        | should -Be $false
                }

                Mock Get-TargetResource -MockWith {return @{"ConnectionBroker"="connectionbroker.lan";"LicenseServers"=@("One","Two");"LicenseMode"="PerUser"}}
                It "Should return false if there's a change in license mode." {
                    Test-TargetResource -ConnectionBroker "connectionbroker.lan" -LicenseMode "PerDevice" -LicenseServers @("One","Two") `
                        | should -Be $false
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
