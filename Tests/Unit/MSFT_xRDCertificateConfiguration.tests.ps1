$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDCertificateConfiguration'

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
        $script:DSCResourceName    = 'MSFT_xRDCertificateConfiguration'

        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "Testing $($script:DSCResourceName)" {

            Mock -CommandName Set-RDCertificate

            Context 'When a certificate is not configured' {

                Mock -CommandName Get-RDCertificate -MockWith {
                    [pscustomobject]@{
                        Thumbprint = $null
                        Role = 'RDPublishing'
                    }
                } -ParameterFilter {$Role -eq 'RDPublishing'}

                Mock -CommandName Get-PfxData -MockWith {
                    [pscustomobject]@{
                        EndEntityCertificates = [pscustomobject]@{
                            Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8B'
                        }
                    }
                } -ParameterFilter {$ImportPath -eq 'testdrive:\RDPublishing.pfx'}

                $resourceNotConfiguredSplat = @{
                    Role = 'RDPublishing'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath = 'testdrive:\RDPublishing.pfx'
                    Credential = [pscredential]::new(
                        'Test',
                        (ConvertTo-SecureString -AsPlainText -String 'pester' -Force)
                    )
                }

                It 'Given the certificate is not configured, no thumbprint is returned' {
                    (Get-TargetResource @resourceNotConfiguredSplat).Thumbprint | Should -BeNullOrEmpty
                }

                It 'Given the certificate is not configured, Test-TargetResource returns false' {
                    Test-TargetResource @resourceNotConfiguredSplat | Should -BeFalse
                }

                It 'Given the certificate is not configured, Set-TargetResource runs Set-RDCertificate' {
                    Set-TargetResource @resourceNotConfiguredSplat
                    Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly
                }
            }

            Context 'When the proper certificate is configured' {

                Mock -CommandName Get-RDCertificate -MockWith {
                    [pscustomobject]@{
                        Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                        Role = 'RDRedirector'
                    }
                } -ParameterFilter {$Role -eq 'RDRedirector'}

                Mock -CommandName Get-PfxData -MockWith {
                    [pscustomobject]@{
                        EndEntityCertificates = [pscustomobject]@{
                            Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                        }
                    }
                } -ParameterFilter {$ImportPath -eq 'testdrive:\RDRedirector.pfx'}

                $resourceConfiguredSplat = @{
                    Role = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath = 'testdrive:\RDRedirector.pfx'
                    Credential = [pscredential]::new(
                        'Test',
                        (ConvertTo-SecureString -AsPlainText -String 'pester' -Force)
                    )
                }

                It 'Given the certificate is configured properly, the correct thumbprint is returned' {
                    (Get-TargetResource @resourceConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                }

                It 'Given the certificate is configured properly, Test-TargetResource returns true' {
                    Test-TargetResource @resourceConfiguredSplat | Should -BeTrue
                }
            }

            Context 'When a wrong certificate is configured' {

                Mock -CommandName Get-RDCertificate -MockWith {
                    [pscustomobject]@{
                        Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
                        Role = 'RDGateway'
                    }
                } -ParameterFilter {$Role -eq 'RDGateway'}

                Mock -CommandName Get-PfxData -MockWith {
                    [pscustomobject]@{
                        EndEntityCertificates = [pscustomobject]@{
                            Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8B'
                        }
                    }
                } -ParameterFilter {$ImportPath -eq 'testdrive:\RDGateway.pfx'}

                $resourceWrongConfiguredSplat = @{
                    Role = 'RDGateway'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath = 'testdrive:\RDGateway.pfx'
                    Credential = [pscredential]::new(
                        'Test',
                        (ConvertTo-SecureString -AsPlainText -String 'pester' -Force)
                    )
                }

                It 'Given the wrong certificate is configured, the thumbprint of the currently configured certificate is returned' {
                    (Get-TargetResource @resourceWrongConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
                }

                It 'Given the wrong certificate is configured, Test-TargetResource returns false' {
                    Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
                }

                It 'Given the wrong certificate is configured, Set-TargetResource runs Set-RDCertificate' {
                    Set-TargetResource @resourceWrongConfiguredSplat
                    Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Invoke-TestCleanup
    #endregion
}
