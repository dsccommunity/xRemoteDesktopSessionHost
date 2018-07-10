$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDSessionDeployment'

#region HEADER

# Unit Test Template Version: 1.2.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Write-Output @('clone','https://github.com/PowerShell/DscResource.Tests.git',"'"+(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests')+"'")

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or
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
        $script:DSCResourceName    = 'MSFT_xRDSessionDeployment'

        Import-Module RemoteDesktop -Force

        $sessionDeploymentSplat = @{
            SessionHost      = 'sessionhost.lan'
            ConnectionBroker = 'connectionbroker.lan'
            WebAccessServer  = 'webaccess.lan'
        }
        
        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Mock -CommandName Get-RDServer -MockWith {
                [pscustomobject]@{
                    Server = 'sessionhost.lan'
                    Roles = @(
                        'RDS-RD-SERVER'
                    )
                }
                [pscustomobject]@{
                    Server = 'connectionbroker.lan'
                    Roles = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
                [pscustomobject]@{
                    Server = 'webaccess.lan'
                    Roles = @(
                        'RDS-WEB-ACCESS'
                    )
                }
            }

            Mock -CommandName Start-Service -MockWith {
                Throw "Throwing from Start-Service mock"
            }
            
            Mock -CommandName Get-Service -MockWith {
                [pscustomobject]@{
                    Status = 'Stopped'
                }
            }

            It 'Given the RDMS service is stopped, Get attempts to start the service' {
                Get-TargetResource @sessionDeploymentSplat -WarningAction SilentlyContinue
                Assert-MockCalled -CommandName Start-Service -Times 1 -Scope It
            }

            It 'Given RDMS service is stopped and start fails a warning is displayed' {
                Get-TargetResource @sessionDeploymentSplat -WarningVariable serviceWarning -WarningAction SilentlyContinue
                $serviceWarning | Should Be 'Failed to start RDMS service. Error: Throwing from Start-Service mock'
            }

            Mock -CommandName Get-Service -MockWith {
                [pscustomobject]@{
                    Status = 'Running'
                }
            }

            It 'Given the RDMS service is running, Get does not attempt to start the service' {
                Get-TargetResource @sessionDeploymentSplat
                Assert-MockCalled -CommandName Start-Service -Times 0 -Scope It
            }

            $get = Get-TargetResource @sessionDeploymentSplat
            It 'Get returns property <property>' {
                Param(
                    $Property
                )

                $get.$Property | Should Not BeNullOrEmpty
            } -TestCases @(
                @{
                    Property = 'SessionHost'
                }
                @{
                    Property = 'ConnectionBroker'
                }
                @{
                    Property = 'WebAccessServer'
                }
            )

        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            
            Mock -CommandName New-RDSessionDeployment

            Set-TargetResource @sessionDeploymentSplat
            It 'Set calls New-RDSessionDeployment with all required parameters' {
                Assert-MockCalled -CommandName New-RDSessionDeployment -Times 1 -ParameterFilter {
                    $SessionHost -eq 'sessionhost.lan' -and
                    $ConnectionBroker -eq 'connectionbroker.lan' -and 
                    $WebAccessServer -eq 'webaccess.lan'
                }
            }

        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            
            Mock -CommandName Get-Service -MockWith {
                [pscustomobject]@{
                    Status = 'Running'
                }
            }
            Mock -CommandName Get-RDServer -MockWith {
                [pscustomobject]@{
                    Server = 'sessionhost.lan'
                    Roles = @(
                        'RDS-RD-SERVER'
                    )
                }
                [pscustomobject]@{
                    Server = 'connectionbrokernew.lan'
                    Roles = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
                [pscustomobject]@{
                    Server = 'webaccess.lan'
                    Roles = @(
                        'RDS-WEB-ACCESS'
                    )
                }
            }

            It 'Given the ConnectionBroker is not targetted in this deployment, test returns false' {
                Test-TargetResource @sessionDeploymentSplat | Should Be $false
            }

            Mock -CommandName Get-RDServer -MockWith {
                [pscustomobject]@{
                    Server = 'sessionhost.lan'
                    Roles = @(
                        'RDS-RD-SERVER'
                    )
                }
                [pscustomobject]@{
                    Server = 'connectionbroker.lan'
                    Roles = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
                [pscustomobject]@{
                    Server = 'webaccess.lan'
                    Roles = @(
                        'RDS-WEB-ACCESS'
                    )
                }
            }

            It 'Given the SessionDeployment is completed, test returns true' {
                Test-TargetResource @sessionDeploymentSplat | Should Be $true
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
