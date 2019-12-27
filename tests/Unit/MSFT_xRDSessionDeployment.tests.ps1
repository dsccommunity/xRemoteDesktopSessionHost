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

            [array]$commonParameters = [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
            $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            $allParameters = (Get-Command Get-TargetResource).Parameters.Keys | Where-Object { $_ -notin $commonParameters } | ForEach-Object -Process {
                @{
                    Property = $_
                    Value = $sessionDeploymentSplat[$_]
                }
            }

            Context "RDSessionDeployment is not present" {
                Mock -CommandName Get-Service -ParameterFilter {$Name -eq 'RDMS' } -MockWith {
                    Write-Error "MOCK Get-Service with parameter RDMS"
                }

                It 'Should attempt to GET the RDMS service but fail given the RDMS service is not present' {
                    Get-TargetResource @sessionDeploymentSplat -WarningVariable serviceWarning -WarningAction SilentlyContinue
                    Assert-MockCalled -CommandName Get-Service -Times 1
                }

                It 'Should attempt to START the RDMS service but fail given the RDMS service is not present' {
                    Get-TargetResource @sessionDeploymentSplat -WarningVariable serviceWarning -WarningAction SilentlyContinue
                    $serviceWarning | Should BeLike "Failed to start RDMS service. Error: Cannot find any service with service name 'RDMS'*"
                }

                It 'Should return $null on property <property> in Get-TargetResource ' {
                    param
                    (
                        $Property,
                        $Value
                    )
                    $get = Get-TargetResource @sessionDeploymentSplat
                    $get.$Property | Should Be $null
                } -TestCases $allParameters
            }

            Context "RDSessionDeployment is present" {
                Mock -CommandName Get-RDServer -MockWith {
                    [pscustomobject]@{
                        Server = $sessionDeploymentSplat.SessionHost
                        Roles = @(
                            'RDS-RD-SERVER'
                        )
                    }
                    [pscustomobject]@{
                        Server = $sessionDeploymentSplat.ConnectionBroker
                        Roles = @(
                            'RDS-CONNECTION-BROKER'
                        )
                    }
                    [pscustomobject]@{
                        Server = $sessionDeploymentSplat.WebAccessServer
                        Roles = @(
                            'RDS-WEB-ACCESS'
                        )
                    }
                }

                Mock -CommandName Start-Service
                Mock -CommandName Get-Service -MockWith {
                    [pscustomobject]@{
                        Status = 'Stopped'
                    }
                }

                It 'Should attempt to start the RDMS service, given the RDMS service is stopped' {
                    Get-TargetResource @sessionDeploymentSplat
                    Assert-MockCalled -CommandName Start-Service -Times 1 -Scope It
                }

                Mock -CommandName Start-Service -MockWith {
                    throw "Throwing from Start-Service mock"
                }

                It 'Should generate a warning, given RDMS service is stopped and start fails' {
                    Get-TargetResource @sessionDeploymentSplat -WarningVariable serviceWarning -WarningAction SilentlyContinue
                    $serviceWarning | Should Be 'Failed to start RDMS service. Error: Throwing from Start-Service mock'
                }

                Mock -CommandName Get-Service -MockWith {
                    [pscustomobject]@{
                        Status = 'Running'
                    }
                }

                It 'Should not attempt to start the RDMS service, given the RDMS service is running' {
                    Get-TargetResource @sessionDeploymentSplat
                    Assert-MockCalled -CommandName Start-Service -Times 0 -Scope It
                }

                It 'Should return property <property> with value <Value> in Get-TargetResource ' {
                    param
                    (
                        $Property,
                        $Value
                    )
                    $get = Get-TargetResource @sessionDeploymentSplat
                    $get.$Property | Should Be $Value
                } -TestCases $allParameters

                It 'Should connect to the right connection broker' {
                    Assert-MockCalled -CommandName Get-RDServer -Scope Context -ParameterFilter {
                        $ConnectionBroker -eq $sessionDeploymentSplat['ConnectionBroker']
                    }
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            Mock -CommandName New-RDSessionDeployment

            Set-TargetResource @sessionDeploymentSplat
            It 'should call New-RDSessionDeployment with all required parameters' {
                Assert-MockCalled -CommandName New-RDSessionDeployment -Times 1 -ParameterFilter {
                    $SessionHost -eq $sessionDeploymentSplat.SessionHost -and
                    $ConnectionBroker -eq $sessionDeploymentSplat.ConnectionBroker -and
                    $WebAccessServer -eq $sessionDeploymentSplat.WebAccessServer
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
                    Server = $sessionDeploymentSplat.SessionHost
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
                    Server = $sessionDeploymentSplat.WebAccessServer
                    Roles = @(
                        'RDS-WEB-ACCESS'
                    )
                }
            }

            It 'Should return false, given the ConnectionBroker is not targeted in this deployment' {
                Test-TargetResource @sessionDeploymentSplat | Should Be $false
            }

            Mock -CommandName Get-RDServer -MockWith {
                [pscustomobject]@{
                    Server = $sessionDeploymentSplat.SessionHost
                    Roles = @(
                        'RDS-RD-SERVER'
                    )
                }
                [pscustomobject]@{
                    Server = $sessionDeploymentSplat.ConnectionBroker
                    Roles = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
                [pscustomobject]@{
                    Server = $sessionDeploymentSplat.WebAccessServer
                    Roles = @(
                        'RDS-WEB-ACCESS'
                    )
                }
            }

            It 'Should return true, given the SessionDeployment is completed' {
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
