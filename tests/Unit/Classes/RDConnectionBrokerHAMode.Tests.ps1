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
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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

    Import-Module -Name $script:dscModuleName -ErrorAction Stop

    # Load stub cmdlets and classes.
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..\Stubs\RemoteDesktop.stubs.psm1')

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload stub module
    Remove-Module -Name RemoteDesktop.stubs -Force

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'RDConnectionBrokerHAMode' {
    Context 'When class is instantiated' {
        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [RDConnectionBrokerHAMode]::new() } | Should -Not -Throw
            }
        }

        It 'Should have a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [RDConnectionBrokerHAMode]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should be the correct type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [RDConnectionBrokerHAMode]::new()
                $instance.GetType().Name | Should -Be 'RDConnectionBrokerHAMode'
            }
        }
    }
}

Describe 'RDConnectionBrokerHAMode\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDConnectionBrokerHAMode] @{
                    ConnectionBroker                  = 'connectionbroker.lan'
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }

                <#
                        This mocks the method GetCurrentState().
                        This mocks the method Assert().
                        This mocks the method Normalize().

                        Method Get() will call the base method Get() which will
                        call back to the derived class methods.
                    #>
                $script:mockInstance |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                        return @{
                            DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                            DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                            DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                            ActiveManagementServer            = 'connectionbroker.lan'
                        }
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                        return
                    } -PassThru |
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                        return
                    } -PassThru
            }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.Get()

                $currentState.ClientAccessName | Should -Be 'rdsfarm.contoso.com'

                $currentState.DatabaseConnectionString | Should -Be 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                $currentState.DatabaseSecondaryConnectionString | Should -Be 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                $currentState.DatabaseFilePath | Should -Be 'C:\RDFiles\RemoteDesktopDeployment.mdf'

                $currentState.ActiveManagementServer | Should -Be 'connectionbroker.lan'

                $currentState.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property ''DatabaseFilePath'' has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [RDConnectionBrokerHAMode] @{
                        ConnectionBroker                  = 'connectionbroker.lan'
                        ClientAccessName                  = 'rdsfarm.contoso.com'
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }

                    <#
                        This mocks the method GetCurrentState().
                        This mocks the method Assert().
                        This mocks the method Normalize().

                        Method Get() will call the base method Get() which will
                        call back to the derived class methods.
                    #>
                    $script:mockInstance |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'GetCurrentState' -Value {
                            return @{
                                DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                                DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                                DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment1.mdf'
                                ActiveManagementServer            = 'connectionbroker.lan'
                            }
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Assert' -Value {
                            return
                        } -PassThru |
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Normalize' -Value {
                            return
                        } -PassThru
                }
            }

            It 'Should return the correct values' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $currentState = $script:mockInstance.Get()

                    $currentState.ClientAccessName | Should -Be 'rdsfarm.contoso.com'

                    $currentState.DatabaseConnectionString | Should -Be 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    $currentState.DatabaseSecondaryConnectionString | Should -Be 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    $currentState.DatabaseFilePath | Should -Be 'C:\RDFiles\RemoteDesktopDeployment1.mdf'

                    $currentState.ActiveManagementServer | Should -Be 'connectionbroker.lan'

                    $currentState.Reasons | Should -HaveCount 0 # Resource cannot 'update' it's either configured or not.
                }
            }
        }
    }
}

Describe 'RDConnectionBrokerHAMode\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [RDConnectionBrokerHAMode] @{
                ConnectionBroker                  = 'connectionbroker.lan'
                ClientAccessName                  = 'rdsfarm.contoso.com'
                DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
            } |
                # Mock method Modify which is called by the case method Set().
                Add-Member -Force -MemberType 'ScriptMethod' -Name 'Modify' -Value {
                    $script:methodModifyCallCount += 1
                } -PassThru
        }
    }

    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:methodTestCallCount = 0
            $script:methodModifyCallCount = 0
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:methodTestCallCount += 1
                        return $true
                    }
            }
        }

        It 'Should not call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodTestCallCount | Should -Be 1
                $script:methodModifyCallCount | Should -Be 0
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance |
                    # Mock method Test() which is called by the base method Set()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Test' -Value {
                        $script:methodTestCallCount += 1
                        return $false
                    }

                $script:mockInstance.PropertiesNotInDesiredState = @(
                    @{
                        Property      = 'DatabaseFilePath'
                        ExpectedValue = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                        ActualValue   = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }
                )
            }
        }

        It 'Should call method Modify()' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Set()

                $script:methodTestCallCount | Should -Be 1
                $script:methodModifyCallCount | Should -Be 1
            }
        }
    }
}

Describe 'RDConnectionBrokerHAMode\Test()' -Tag 'Test' {
    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:getMethodCallCount = 0
        }
    }

    BeforeDiscovery {
        $testCases = @(
            @{
                Property = 'DatabaseConnectionString'
                Current  = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                Desired  = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1A;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
            },
            @{
                Property = 'DatabaseSecondaryConnectionString'
                Current  = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                Desired  = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2A;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
            },
            @{
                Property = 'DatabaseFilePath'
                Current  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                Desired  = 'C:\RDFiles\RemoteDesktopDeployment1.mdf'
            }
        )
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDConnectionBrokerHAMode] @{
                    ConnectionBroker                  = 'connectionbroker.lan'
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }

                $script:mockInstance |
                    # Mock method Get() which is called by the base method Test()
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                        $script:getMethodCallCount += 1
                    }
            }
        }

        It 'Should return $true' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance.Test() | Should -BeTrue

                $script:getMethodCallCount | Should -Be 1
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When the property ''<Property>'' is not correct' -ForEach $testCases {
            BeforeAll {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [RDConnectionBrokerHAMode] @{
                        ConnectionBroker                  = 'connectionbroker.lan'
                        ClientAccessName                  = 'rdsfarm.contoso.com'
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }

                    $script:mockInstance |
                        # Mock method Get() which is called by the base method Test()
                        Add-Member -Force -MemberType 'ScriptMethod' -Name 'Get' -Value {
                            $script:getMethodCallCount += 1
                        }

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = $Property
                            ExpectedValue = $Desired
                            ActualValue   = $Current
                        }
                    )
                }
            }

            It 'Should return $false' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance.Test() | Should -BeFalse

                    $script:getMethodCallCount | Should -Be 1
                }
            }
        }
    }
}

Describe 'RDConnectionBrokerHAMode\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When the resource is not present' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDConnectionBrokerHAMode] @{
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }
            }

            Mock -CommandName Get-RDConnectionBrokerHighAvailability
            Mock -CommandName Get-ComputerName -MockWith { 'connectionbroker.lan' }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        ClientAccessName = 'rdsfarm.contoso.com'
                    }
                )

                $currentState.DatabaseConnectionString | Should -BeNullOrEmpty
                $currentState.DatabaseSecondaryConnectionString | Should -BeNullOrEmpty
                $currentState.DatabaseFilePath | Should -BeNullOrEmpty
                $currentState.ActiveManagementServer | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-ComputerName -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is present' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDConnectionBrokerHAMode] @{
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }
            }

            Mock -CommandName Get-RDConnectionBrokerHighAvailability -MockWith {
                [PSCustomObject] @{
                    ConnectionBroker                  = 'connectionbroker.lan', 'connectionbroker1.lan'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    ActiveManagementServer            = 'connectionbroker.lan'
                }
            }

            Mock -CommandName Get-ComputerName -MockWith { 'connectionbroker.lan' }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        ClientAccessName = 'rdsfarm.contoso.com'
                    }
                )

                $currentState.DatabaseConnectionString | Should -Be 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                $currentState.DatabaseSecondaryConnectionString | Should -Be 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                $currentState.DatabaseFilePath | Should -Be 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                $currentState.ActiveManagementServer | Should -Be 'connectionbroker.lan'
            }

            Should -Invoke -CommandName Get-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-ComputerName -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'RDConnectionBrokerHAMode\Modify()' -Tag 'HiddenMember' {
    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDConnectionBrokerHAMode] @{
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                }
            }
        }

        Context 'When the configuration should be updated' {
            BeforeAll {
                Mock -CommandName Set-RDConnectionBrokerHighAvailability
                Mock -CommandName Get-ComputerName -MockWith { 'connectionbroker.lan' }
            }

            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }

                    $null = $script:mockInstance.Modify($mockProperties)
                }

                Should -Invoke -CommandName Set-RDConnectionBrokerHighAvailability -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-ComputerName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the configuration is already set' {
            It 'Should throw the correct exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance.ActiveManagementServer = 'connectionbroker.lan'

                    $mockProperties = @{
                        DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB2;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                        DatabaseFilePath                  = 'C:\RDFiles\RemoteDesktopDeployment.mdf'
                    }

                    $errorRecord = Get-InvalidOperationRecord -Message $script:mockInstance.localizedData.RDConnectionBrokerHAMode_ConfigurationCannotBeModified

                    { $script:mockInstance.Modify($mockProperties) } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
                }
            }
        }
    }
}

Describe 'RDConnectionBrokerHAMode\AssertProperties()' -Tag 'AssertProperties' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [RDConnectionBrokerHAMode] @{}
        }
    }

    Context 'When the OS Requirement is not met' {
        BeforeAll {
            Mock -CommandName Test-RemoteDesktopServicesDscOsRequirement -MockWith {
                return $false
            }
        }

        It 'Should throw the correct exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $errorRecord = Get-InvalidOperationRecord -Message $script:mockInstance.localizedData.RDConnectionBrokerHAMode_OSRequirementNotMet

                { $script:mockInstance.AssertProperties(@{}) } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
            }

            Should -Invoke -CommandName Test-RemoteDesktopServicesDscOsRequirement -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the OS Requirement is met' {
        BeforeAll {
            Mock -CommandName Test-RemoteDesktopServicesDscOsRequirement -MockWith {
                return $true
            }

            Mock -CommandName Import-RemoteDesktopModule
        }

        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.AssertProperties(@{})
            }

            Should -Invoke -CommandName Test-RemoteDesktopServicesDscOsRequirement -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Import-RemoteDesktopModule -Exactly -Times 1 -Scope It
        }
    }
}
