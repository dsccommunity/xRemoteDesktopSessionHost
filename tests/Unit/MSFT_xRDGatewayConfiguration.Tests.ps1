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
    $script:dscResourceName = 'MSFT_xRDGatewayConfiguration'

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

Describe 'MSFT_xRDGatewayConfiguration\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource exists' {
        BeforeAll {
            Mock -CommandName Assert-Module
        }

        Context 'When ''GatewayMode'' is not Custom' {
            BeforeAll {
                Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                    @{
                        GatewayMode = [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Automatic
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'testbroker.lan'
                    }

                    $result = Get-TargetResource @testParams

                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.GatewayMode | Should -Be 'Automatic'
                }
            }
        }

        Context 'When ''GatewayMode'' is Custom' {
            BeforeAll {
                Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                    @{
                        GatewayMode          = [Microsoft.RemoteDesktopServices.Management.GatewayUsage]::Custom
                        GatewayExternalFqdn  = 'gateway.external.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'testbroker.lan'
                    }

                    $result = Get-TargetResource @testParams

                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.GatewayMode | Should -Be 'Custom'
                    $result.GatewayExternalFqdn | Should -Be 'gateway.external.fqdn'
                    $result.LogonMethod | Should -Be 'Password'
                    $result.UseCachedCredentials | Should -BeTrue
                    $result.BypassLocal | Should -BeFalse
                }
            }
        }
    }

    Context 'When the resource does not exist' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDDeploymentGatewayConfiguration
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker = 'testbroker.lan'
                }

                $result = Get-TargetResource @testParams

                $result.ConnectionBroker | Should -BeNullOrEmpty
                $result.GatewayMode | Should -BeNullOrEmpty
                $result.GatewayExternalFqdn | Should -BeNullOrEmpty
                $result.LogonMethod | Should -BeNullOrEmpty
                $result.UseCachedCredentials | Should -BeNullOrEmpty
                $result.BypassLocal | Should -BeNullOrEmpty
            }
        }
    }
}

Describe 'MSFT_xRDGatewayConfiguration\Set-TargetResource' -Tag 'Set' {
    Context 'When ''GatewayMode'' is not Custom' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Assert-BoundParameter -RemoveParameterType @('RequiredBehavior')
            Mock -CommandName Set-RDDeploymentGatewayConfiguration
            Mock -CommandName Get-RDServer
            Mock -CommandName Add-RDServer
        }

        Context 'When there are no Gateway Servers to check' {
            Context 'When there are no RDServers to add' {
                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker = 'testbroker.lan'
                            GatewayMode      = 'DoNotUse'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                        $null -eq $GatewayExternalFqdn
                    }
                    Should -Invoke -CommandName Get-RDServer -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 0 -Scope It
                }
            }

            Context 'When there are RDServers to add' {
                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker = 'testbroker.lan'
                            GatewayMode      = 'DoNotUse'
                            GatewayServer    = 'rdgateway.lan'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                        $null -eq $GatewayExternalFqdn
                    }
                    Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When there are Gateway Servers to check' {
            BeforeAll {
                Mock -CommandName Get-RDServer -MockWith {
                    @(
                        [PSCustomObject] @{
                            Server = 'rdgateway1.lan'
                            Roles  = 'RDS-Gateway'
                        }
                        [PSCustomObject] @{
                            Server = 'rdlic.lan'
                            Roles  = 'RDS-Licensing'
                        }
                        [PSCustomObject] @{
                            Server = 'rdweb.lan'
                            Roles  = 'RDS-Web-Access'
                        }
                    )
                }
            }

            Context 'When there are no RDServers to add' {
                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker     = 'testbroker.lan'
                            GatewayMode          = 'DoNotUse'
                            GatewayServer        = 'rdgateway1.lan'
                            ExternalFqdn         = 'some.fqdn'
                            LogonMethod          = 'Password'
                            UseCachedCredentials = $true
                            BypassLocal          = $false
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                        $null -eq $GatewayExternalFqdn
                    }
                    Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 0 -Scope It
                }
            }

            Context 'When there are RDServers to add' {
                BeforeAll {
                    Mock -CommandName Get-RDServer -MockWith {
                        @(
                            [PSCustomObject] @{
                                Server = 'rdgateway2.lan'
                                Roles  = 'RDS-Gateway'
                            }
                            [PSCustomObject] @{
                                Server = 'rdlic.lan'
                                Roles  = 'RDS-Licensing'
                            }
                            [PSCustomObject] @{
                                Server = 'rdweb.lan'
                                Roles  = 'RDS-Web-Access'
                            }
                        )
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker = 'testbroker.lan'
                            GatewayMode      = 'DoNotUse'
                            GatewayServer    = 'rdgateway1.lan'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                        $null -eq $GatewayExternalFqdn
                    }
                    Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }
        }
    }

    Context 'When ''GatewayMode'' is Custom' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Assert-BoundParameter -RemoveParameterType @('RequiredBehavior')
            Mock -CommandName Set-RDDeploymentGatewayConfiguration
            Mock -CommandName Get-RDServer
            Mock -CommandName Add-RDServer
        }

        Context 'When parameters are missing' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'testbroker.lan'
                        GatewayMode      = 'Custom'
                    }

                    { Set-TargetResource @testParams } | Should -Throw
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 0 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 0 -Scope It
                Should -Invoke -CommandName Add-RDServer -Exactly -Times 0 -Scope It
            }
        }

        Context 'When there are no RDServers to add' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker     = 'testbroker.lan'
                        GatewayMode          = 'Custom'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }

                    $null = Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                    $null -ne $GatewayExternalFqdn
                }
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 0 -Scope It
                Should -Invoke -CommandName Add-RDServer -Exactly -Times 0 -Scope It
            }
        }

        Context 'When there are RDServers to add' {
            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker     = 'testbroker.lan'
                        GatewayMode          = 'Custom'
                        GatewayServer        = 'rdgateway.lan'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }

                    $null = Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It -ParameterFilter {
                    $null -ne $GatewayExternalFqdn
                }
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'MSFT_xRDLicenseConfiguration\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        Context 'When ''GatewayMode'' is not Custom' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                        GatewayMode      = 'Automatic'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        GatewayMode      = 'Automatic'
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }
            }
        }

        Context 'When ''GatewayMode'' is not Custom but unsupported parameters are supplied' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                        GatewayMode      = 'Automatic'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker     = 'connectionbroker.lan'
                        GatewayMode          = 'Automatic'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }
            }
        }

        Context 'When ''GatewayMode'' is Custom' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker     = 'connectionbroker.lan'
                        GatewayMode          = 'Custom'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker     = 'connectionbroker.lan'
                        GatewayMode          = 'Custom'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }
            }
        }
    }

    Context 'When the resource is not in the desired state' {
        Context 'When ''GatewayMode'' is not Custom' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                        GatewayMode      = 'Automatic'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        GatewayMode      = 'DoNotUse'
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }
        }

        Context 'When ''GatewayMode'' is not Custom but unsupported parameters are supplied' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                        GatewayMode      = 'Automatic'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker     = 'connectionbroker.lan'
                        GatewayMode          = 'DoNotUse'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }
        }

        Context 'When ''GatewayMode'' is Custom' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker     = 'connectionbroker.lan'
                        GatewayMode          = 'Custom'
                        ExternalFqdn         = 'some.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $true
                        BypassLocal          = $false
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker     = 'connectionbroker.lan'
                        GatewayMode          = 'Custom'
                        ExternalFqdn         = 'someother.fqdn'
                        LogonMethod          = 'Password'
                        UseCachedCredentials = $false
                        BypassLocal          = $false
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }
            }
        }
    }
}
