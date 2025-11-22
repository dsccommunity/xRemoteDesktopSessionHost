# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
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
    $script:dscModuleName = 'xRemoteDesktopSessionHost'
    $script:dscResourceName = 'MSFT_xRDLicenseConfiguration'

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

Describe 'MSFT_xRDLicenseConfiguration\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource exists' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDLicenseConfiguration -MockWith {
                [PSCustomObject] @{
                    LicenseServer = [System.String[]] @('LicenseServer1', 'LicenseServer2')
                    Mode          = [Microsoft.RemoteDesktopServices.Management.LicensingMode]::PerUser
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker = 'connectionbroker.lan'
                    LicenseServer    = @('LicenseServer1', 'LicenseServer2')
                    LicenseMode      = 'PerUser'
                }

                $result = Get-TargetResource @testParams

                $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                $result.LicenseServer | Should -Be $testParams.LicenseServer
                $result.LicenseMode | Should -Be $testParams.LicenseMode
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDLicenseConfiguration -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource does not exist' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDLicenseConfiguration
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker = 'connectionbroker.lan'
                    LicenseServer    = @('LicenseServer1', 'LicenseServer2')
                    LicenseMode      = 'PerUser'
                }

                $result = Get-TargetResource @testParams

                $result.ConnectionBroker | Should -BeNullOrEmpty
                $result.LicenseServer | Should -BeNullOrEmpty
                $result.LicenseMode | Should -BeNullOrEmpty
            }
        }
    }
}

Describe 'MSFT_xRDLicenseConfiguration\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    ConnectionBroker = 'connectionbroker.lan'
                    LicenseServer    = [System.String[]] @('LicenseServer1', 'LicenseServer2')
                    LicenseMode      = 'PerUser'
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker = 'connectionbroker.lan'
                    LicenseServer    = @('LicenseServer1', 'LicenseServer2')
                    LicenseMode      = 'PerUser'
                }

                Test-TargetResource @testParams | Should -BeTrue
            }
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    ConnectionBroker = 'connectionbroker.lan'
                    LicenseServer    = [System.String[]] @('LicenseServer1')
                    LicenseMode      = 'PerDevice'
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker = 'connectionbroker.lan'
                    LicenseServer    = @('LicenseServer1', 'LicenseServer2')
                    LicenseMode      = 'PerUser'
                }

                Test-TargetResource @testParams | Should -BeFalse
            }
        }
    }
}

Describe 'MSFT_xRDLicenseConfiguration\Set-TargetResource' -Tag 'Set' {
    Context 'When the resource is updated' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Set-RDLicenseConfiguration
        }

        Context 'When parameter ''LicenseServer'' is specified' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        LicenseServer    = @('LicenseServer1', 'LicenseServer2')
                        LicenseMode      = 'PerUser'
                    }

                    Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-RDLicenseConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                    $null -ne $LicenseServer
                }
            }
        }

        Context 'When parameter ''LicenseServer'' is not specified' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        LicenseMode      = 'PerUser'
                    }

                    Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-RDLicenseConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                    $null -eq $LicenseServer
                }
            }
        }
    }
}
