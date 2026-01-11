# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'RemoteDesktopServicesDsc'
    $script:dscResourceName = 'DSC_RDCertificateConfiguration'

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    # Load stub cmdlets and classes.
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\RemoteDesktop.stubs.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscResourceName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscResourceName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Restore-TestEnvironment -TestEnvironment $script:testEnvironment

    # Unload stub module
    Remove-Module -Name RemoteDesktop.stubs -Force

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscResourceName -All | Remove-Module -Force
}

Describe 'DSC_RDCertificateConfiguration\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-RDCertificate -MockWith {
                @{
                    Thumbprint       = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                $result = Get-TargetResource @testParams

                $result.Role | Should -Be $testParams.Role
                $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                $result.ImportPath | Should -Be $testParams.ImportPath
                $result.Credential.UserName | Should -Be $testParams.Credential.UserName
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDCertificate -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-RDCertificate
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                $result = Get-TargetResource @testParams

                # Key properties should still be returned when the resource is not present...
                # $result.Role | Should -Be $testParams.Role
                # $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                $result.Role | Should -BeNullOrEmpty
                $result.ConnectionBroker | Should -BeNullOrEmpty
                $result.ImportPath | Should -BeNullOrEmpty
                $result.Credential.UserName | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDCertificate -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_RDCertificateConfiguration\Test-TargetResource' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    Thumbprint       = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }
            }

            Mock -CommandName Get-PfxData -MockWith {
                @{
                    EndEntityCertificates = @(
                        @{
                            Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                        }
                    )
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                Test-TargetResource @testParams | Should -BeTrue
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-PfxData -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    Thumbprint       = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }
            }

            Mock -CommandName Get-PfxData -MockWith {
                @{
                    EndEntityCertificates = @(
                        @{
                            Thumbprint = '00006BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                        }
                    )
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-PfxData -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the pfx does not exist or cannot be opened' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    Thumbprint       = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }
            }

            Mock -CommandName Get-PfxData -MockWith { throw }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-PfxData -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DSC_RDCertificateConfiguration\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When setting the resource' {
        BeforeAll {
            Mock -CommandName Set-RDCertificate
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-RDCertificate -Exactly -Times 1 -Scope It
        }
    }

    Context 'When setting the resource throws an error' {
        BeforeAll {
            Mock -CommandName Set-RDCertificate -MockWith { throw }
            Mock -CommandName Write-Error
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'TestDrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-RDCertificate -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Write-Error -Exactly -Times 1 -Scope It
        }
    }
}
