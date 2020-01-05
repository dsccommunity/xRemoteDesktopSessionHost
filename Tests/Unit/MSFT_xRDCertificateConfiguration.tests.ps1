$script:DSCModuleName      = 'xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDCertificateConfiguration'

#region HEADER

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

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
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

                It 'Get-TargetResource returns no thumbprint' {
                    (Get-TargetResource @resourceNotConfiguredSplat).Thumbprint | Should -BeNullOrEmpty
                }

                It 'Test-TargetResource returns false' {
                    Test-TargetResource @resourceNotConfiguredSplat | Should -BeFalse
                }

                It 'Set-TargetResource runs Set-RDCertificate' {
                    Set-TargetResource @resourceNotConfiguredSplat
                    Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly -ParameterFilter {
                        $Role -eq $resourceNotConfiguredSplat.Role -and
                        $ConnectionBroker -eq $resourceNotConfiguredSplat.ConnectionBroker -and
                        $ImportPath -eq $resourceNotConfiguredSplat.ImportPath -and
                        $Password -eq $resourceNotConfiguredSplat.Credential.Password -and
                        $Force -eq $true
                    }
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

                It 'Get-TargetResource returns the correct thumbprint' {
                    (Get-TargetResource @resourceConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                }

                It 'Test-TargetResource returns true' {
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

                It 'Get-TargetResource returns the thumbprint of the currently configured certificate' {
                    (Get-TargetResource @resourceWrongConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
                }

                It 'Test-TargetResource returns false' {
                    Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
                }

                It 'Set-TargetResource runs Set-RDCertificate' {
                    Set-TargetResource @resourceWrongConfiguredSplat
                    Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly -ParameterFilter {
                        $Role -eq $resourceWrongConfiguredSplat.Role -and
                        $ConnectionBroker -eq $resourceWrongConfiguredSplat.ConnectionBroker -and
                        $ImportPath -eq $resourceWrongConfiguredSplat.ImportPath -and
                        $Password -eq $resourceWrongConfiguredSplat.Credential.Password -and
                        $Force -eq $true
                    }
                }
            }

            Context 'When a wrong certificate is configured and the PFX file is protected based on group membership (ProtectTo)' {
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
                }

                It 'Get-TargetResource returns the thumbprint of the currently configured certificate' {
                    (Get-TargetResource @resourceWrongConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
                }

                It 'Test-TargetResource returns false' {
                    Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
                }

                It 'Set-TargetResource runs Set-RDCertificate without password' {
                    Set-TargetResource @resourceWrongConfiguredSplat
                    Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly -ParameterFilter {
                        $Role -eq $resourceWrongConfiguredSplat.Role -and
                        $ConnectionBroker -eq $resourceWrongConfiguredSplat.ConnectionBroker -and
                        $ImportPath -eq $resourceWrongConfiguredSplat.ImportPath -and
                        $Force -eq $true
                    }
                }
            }

            Context 'When a certificate fails to test' {
                Mock Get-RDCertificate
                Mock Get-PfxData -MockWith {
                    throw "Cannot import PFX file"
                }

                $resourceWrongConfiguredSplat = @{
                    Role = 'RDGateway'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath = 'testdrive:\RDGateway.pfx'
                }

                It 'Test-TargetResource displays a warning when a certificate fails to test' {
                    $message = Test-TargetResource @resourceWrongConfiguredSplat 3>&1
                    $message | Should -Not -BeNullOrEmpty
                }

                It 'Test-TargetResource returns false' {
                    Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
                }
            }

            Context 'When a certificate fails to set' {

                Mock Set-RDCertificate -MockWith {
                    throw 'Failed to apply certificate'
                }

                $resourceWrongConfiguredSplat = @{
                    Role = 'RDGateway'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath = 'testdrive:\RDGateway.pfx'
                }

                It 'Set-TargetResource returns an error when the certificate could not be applied' {
                    $errorMessage = Set-TargetResource @resourceWrongConfiguredSplat 2>&1
                    $errorMessage | Should -Not -BeNullOrEmpty
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
