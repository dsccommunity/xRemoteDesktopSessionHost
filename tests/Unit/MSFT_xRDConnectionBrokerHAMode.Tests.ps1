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
    $script:dscResourceName = 'MSFT_xRDConnectionBrokerHAMode'

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

Describe 'MSFT_xRDConnectionBrokerHAMode\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource is in the desired state' {
        Context 'When the connection broker is not local' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Get-RDConnectionBrokerHighAvailability -MockWith {
                    @{
                        ConnectionBroker                  = 'RDCB1'
                        ActiveManagementServer            = 'RDCB1'
                        ClientAccessName                  = 'rdsfarm.contoso.com'
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        ConnectionBroker                  = 'RDCB1'
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        ClientAccessName                  = 'rdsfarm.contoso.com'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }

                    $result = Get-TargetResource @testParams

                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.ActiveManagementServer | Should -Be 'RDCB1'
                    $result.ClientAccessName | Should -Be $testParams.ClientAccessName
                    $result.DatabaseConnectionString | Should -Be $testParams.DatabaseConnectionString
                    $result.DatabaseSecondaryConnectionString | Should -Be $testParams.DatabaseSecondaryConnectionString
                    $result.DatabaseFilePath | Should -Be $testParams.DatabaseFilePath
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the connection broker is local' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Get-RDConnectionBrokerHighAvailability -MockWith {
                    @{
                        ConnectionBroker                  = Get-ComputerName
                        ActiveManagementServer            = 'RDCB1'
                        ClientAccessName                  = 'rdsfarm.contoso.com'
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        ClientAccessName                  = 'rdsfarm.contoso.com'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }

                    $result = Get-TargetResource @testParams

                    $result.ConnectionBroker | Should -Be (Get-ComputerName)
                    $result.ActiveManagementServer | Should -Be 'RDCB1'
                    $result.ClientAccessName | Should -Be $testParams.ClientAccessName
                    $result.DatabaseConnectionString | Should -Be $testParams.DatabaseConnectionString
                    $result.DatabaseSecondaryConnectionString | Should -Be $testParams.DatabaseSecondaryConnectionString
                    $result.DatabaseFilePath | Should -Be $testParams.DatabaseFilePath
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDConnectionBrokerHighAvailability
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker                  = 'RDCB1'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }

                $result = Get-TargetResource @testParams

                $result.ConnectionBroker | Should -BeNullOrEmpty
                $result.ActiveManagementServer | Should -BeNullOrEmpty
                $result.ClientAccessName | Should -BeNullOrEmpty
                $result.DatabaseConnectionString | Should -BeNullOrEmpty
                $result.DatabaseSecondaryConnectionString | Should -Be $testParams.DatabaseSecondaryConnectionString
                $result.DatabaseFilePath | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'MSFT_xRDConnectionBrokerHAMode\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    ConnectionBroker                  = 'RDCB1'
                    ActiveManagementServer            = 'RDCB1'
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }
            }
        }

        It 'Should return true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker         = 'RDCB1'
                    DatabaseConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    ClientAccessName         = 'rdsfarm.contoso.com'
                }

                Test-TargetResource @testParams | Should -BeTrue
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    ConnectionBroker                  = 'RDCB1'
                    ActiveManagementServer            = ''
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }
            }
        }

        It 'Should return false' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker         = 'RDCB1'
                    DatabaseConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    ClientAccessName         = 'rdsfarm.contoso.com'
                }

                Test-TargetResource @testParams | Should -BeFalse
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'MSFT_xRDConnectionBrokerHAMode\Set-TargetResource' -Tag 'Set' {
    Context 'When Set-RDConnectionBrokerHighAvailability runs successfully' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Set-RDConnectionBrokerHighAvailability
        }

        It 'Should run Set-RDConnectionBrokerHighAvailability' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    ConnectionBroker                  = ''
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
        }
    }
}
