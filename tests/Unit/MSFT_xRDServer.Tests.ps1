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
    $script:dscResourceName = 'MSFT_xRDServer'

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

Describe 'MSFT_xRDServer\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the resource is present' {
        BeforeAll {
            Mock -CommandName Get-RDServer -MockWith {
                @{
                    Server = 'connectionbroker.lan'
                    Roles  = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
            }
        }

        Context 'When the role is not ''RDS-Gateway''' {
            Context 'When the ''ConnectionBroker'' is specified' {
                It 'Should return the correct result' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker = 'connectionbroker.lan'
                            Server           = 'connectionbroker.lan'
                            Role             = 'RDS-Connection-Broker'
                        }

                        $result = Get-TargetResource @testParams

                        $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                        $result.Server | Should -Be $testParams.Server
                        $result.Role | Should -Be $testParams.Role
                        $result.GatewayExternalFqdn | Should -BeNullOrEmpty
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                }
            }

            Context 'When the ''ConnectionBroker'' is not specified' {
                It 'Should return the correct result' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            Server = 'connectionbroker.lan'
                            Role   = 'RDS-Connection-Broker'
                        }

                        $result = Get-TargetResource @testParams

                        $result.ConnectionBroker | Should -Be $(Get-ComputerName -FullyQualifiedDomainName)
                        $result.Server | Should -Be $testParams.Server
                        $result.Role | Should -Be $testParams.Role
                        $result.GatewayExternalFqdn | Should -BeNullOrEmpty
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When the role is ''RDS-Gateway''' {
            BeforeAll {
                Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                    @{
                        GatewayExternalFqdn = 'testgateway.external.fqdn'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker    = 'connectionbroker.lan'
                        Server              = 'connectionbroker.lan'
                        Role                = 'RDS-Gateway'
                        GatewayExternalFqdn = 'testgateway.external.fqdn'
                    }

                    $result = Get-TargetResource @testParams

                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.Server | Should -Be $testParams.Server
                    $result.Role | Should -Be $testParams.Role
                    $result.GatewayExternalFqdn | Should -Be $testParams.GatewayExternalFqdn
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDDeploymentGatewayConfiguration -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the resource is absent' {
        Context 'When no RD Servers are configured' {
            BeforeAll {
                Mock -CommandName Get-RDServer
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        Server           = 'nonexistentserver.lan'
                        Role             = 'RDS-Connection-Broker'
                    }

                    $result = Get-TargetResource @testParams
                    $result.ConnectionBroker | Should -BeNullOrEmpty
                    $result.Server | Should -BeNullOrEmpty
                    $result.Role | Should -BeNullOrEmpty
                    $result.GatewayExternalFqdn | Should -BeNullOrEmpty
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the Server is not in the configured RD Servers' {
            BeforeAll {
                Mock -CommandName Get-RDServer -MockWith {
                    @{
                        Server = 'connectionbroker.lan'
                        Roles  = @(
                            'RDS-CONNECTION-BROKER'
                        )
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        Server           = 'nonexistentserver.lan'
                        Role             = 'RDS-Connection-Broker'
                    }

                    $result = Get-TargetResource @testParams
                    $result.ConnectionBroker | Should -BeNullOrEmpty
                    $result.Server | Should -BeNullOrEmpty
                    $result.Role | Should -BeNullOrEmpty
                    $result.GatewayExternalFqdn | Should -BeNullOrEmpty
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'MSFT_xRDServer\Test-TargetResource' -Tag 'Test' {
    Context 'When the system is in the desired state' {
        Context 'When Role is ''RDS-GATEWAY''' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker    = 'connectionbroker.lan'
                        Server              = 'connectionbroker.lan'
                        Role                = 'RDS-Gateway'
                        GatewayExternalFqdn = 'testgateway.external.fqdn'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker    = 'connectionbroker.lan'
                        Server              = 'connectionbroker.lan'
                        Role                = 'RDS-Gateway'
                        GatewayExternalFqdn = 'testgateway.external.fqdn'
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            }
        }

        Context 'When Role is not ''RDS-GATEWAY''' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                        Server           = 'connectionbroker.lan'
                        Role             = 'RDS-Virtualization'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker = 'connectionbroker.lan'
                        Server           = 'connectionbroker.lan'
                        Role             = 'RDS-Virtualization'
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the system not is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    ConnectionBroker    = 'connectionbroker.lan'
                    Server              = 'connectionbroker.lan'
                    Role                = 'RDS-Gateway'
                    GatewayExternalFqdn = 'testgateway.external.fqdn'
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker    = 'newconnectionbroker.lan'
                    Server              = 'connectionbroker.lan'
                    Role                = 'RDS-Gateway'
                    GatewayExternalFqdn = 'testgateway.external.fqdn'
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'MSFT_xRDServer\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When adding a resource' {
        Context 'When Role is ''RDS-Licensing'' or ''RDS-Gateway''' {
            BeforeAll {
                Mock -CommandName Assert-BoundParameter -RemoveParameterType @('RequiredBehavior')
            }

            Context 'When ''Add-RDGateway'' completes successfully' {
                BeforeAll {
                    Mock -CommandName Add-RDServer
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker    = 'connectionbroker.lan'
                            Server              = 'rdsgateway.lan'
                            Role                = 'RDS-Gateway'
                            GatewayExternalFqdn = 'gateway.external.fqdn'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }

            Context 'When ''Add-RDGateway'' completes with 2 errors' {
                BeforeAll {
                    InModuleScope -ScriptBlock {
                        Mock -CommandName Add-RDServer -MockWith {
                            $list = [System.Collections.ArrayList]::new()
                            $list.Add((New-ErrorRecord -Exception [System.Management.Automation.CommandNotFoundException] -ErrorCategory 'ObjectNotFound' -ErrorId 'CommandNotFoundException'))
                            $list.Add((New-ErrorRecord -Exception [System.Management.Automation.CommandNotFoundException] -ErrorCategory 'ObjectNotFound' -ErrorId 'CommandNotFoundException'))

                            Set-Variable -Name $PesterBoundParameters.ErrorVariable -Scope 3 -Value $list
                        }
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker    = 'connectionbroker.lan'
                            Server              = 'rdsgateway.lan'
                            Role                = 'RDS-Gateway'
                            GatewayExternalFqdn = 'gateway.external.fqdn'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }

            Context 'When ''Add-RDGateway'' completes with 1 error' {
                BeforeAll {
                    InModuleScope -ScriptBlock {
                        Mock -CommandName Add-RDServer -MockWith {
                            $list = [System.Collections.ArrayList]::new()
                            $list.Add((New-ErrorRecord -Exception [System.Management.Automation.CommandNotFoundException] -ErrorCategory 'ObjectNotFound' -ErrorId 'CommandNotFoundException'))

                            Set-Variable -Name $PesterBoundParameters.ErrorVariable -Scope 3 -Value $list
                        }
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            ConnectionBroker    = 'connectionbroker.lan'
                            Server              = 'rdsgateway.lan'
                            Role                = 'RDS-Gateway'
                            GatewayExternalFqdn = 'gateway.external.fqdn'
                        }

                        { Set-TargetResource @testParams } | Should -Throw
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Assert-BoundParameter -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When Role is not ''RDS-Licensing'' or ''RDS-Gateway''' {
            BeforeAll {
                Mock -CommandName Add-RDServer
            }

            Context 'When ''ConnectionBroker'' is not specified' {
                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            Server = 'rdshost.lan'
                            Role   = 'RDS-RD-Server'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }

            Context 'When ''GatewayExternalFqdn'' is not specified' {
                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            Server              = 'rdshost.lan'
                            Role                = 'RDS-RD-Server'
                            GatewayExternalFqdn = 'should.be.ignored.lan'
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
