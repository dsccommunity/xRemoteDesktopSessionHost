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

Describe 'RDSessionDeployment' {
    Context 'When class is instantiated' {
        It 'Should not throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                { [RDSessionDeployment]::new() } | Should -Not -Throw
            }
        }

        It 'Should have a default or empty constructor' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [RDSessionDeployment]::new()
                $instance | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should be the correct type' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $instance = [RDSessionDeployment]::new()
                $instance.GetType().Name | Should -Be 'RDSessionDeployment'
            }
        }
    }
}

Describe 'RDSessionDeployment\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    SessionHost      = 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = 'webaccess.lan'
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
                            SessionHost      = [System.String[]] 'sessionhost.lan'
                            ConnectionBroker = 'connectionbroker.lan'
                            WebAccessServer  = [System.String[]]'webaccess.lan'
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

                $currentState.ConnectionBroker | Should -Be 'connectionbroker.lan'
                $currentState.SessionHost | Should -Be 'sessionhost.lan'
                $currentState.WebAccessServer | Should -Be 'webaccess.lan'

                $currentState.Reasons | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When the system is not in the desired state' {
        Context 'When property ''WebAccessServer'' has the wrong value' {
            BeforeAll {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:mockInstance = [RDSessionDeployment] @{
                        SessionHost      = 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = 'webaccess.lan'
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
                                SessionHost      = [System.String[]] 'sessionhost.lan'
                                ConnectionBroker = 'connectionbroker.lan'
                                WebAccessServer  = [System.String[]]@('webaccess.lan', 'webaccess2.lan')
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

                    $currentState.ConnectionBroker | Should -Be 'connectionbroker.lan'
                    $currentState.SessionHost | Should -Be 'sessionhost.lan'
                    $currentState.WebAccessServer | Should -Be @('webaccess.lan', 'webaccess2.lan')

                    $currentState.Reasons | Should -HaveCount 1
                    $currentState.Reasons[0].Code | Should -Be 'RDSessionDeployment:RDSessionDeployment:WebAccessServer'
                    $currentState.Reasons[0].Phrase | Should -Be 'The property WebAccessServer should be "webaccess.lan", but was ["webaccess.lan","webaccess2.lan"]'
                }
            }
        }
    }
}

Describe 'RDSessionDeployment\Set()' -Tag 'Set' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [RDSessionDeployment] @{
                SessionHost      = 'sessionhost.lan'
                ConnectionBroker = 'connectionbroker.lan'
                WebAccessServer  = 'webaccess.lan'
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
                        Property      = 'SessionHost'
                        ExpectedValue = 'sessionhost.lan'
                        ActualValue   = 'sessionhost2.lan'
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

Describe 'RDSessionDeployment\Test()' -Tag 'Test' {
    BeforeEach {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:getMethodCallCount = 0
        }
    }

    BeforeDiscovery {
        $testCases = @(
            @{
                Property = 'ConnectionBroker'
                Current  = 'connectionbroker.lan'
                Desired  = 'connectionbroker2.lan'
            },
            @{
                Property = 'SessionHost'
                Current  = $null
                Desired  = [System.String[]] 'sessionhost1.lan', 'sessionhost3.lan'
            },
            @{
                Property = 'SessionHost'
                Current  = 'sessionhost.lan'
                Desired  = [System.String[]] @('sessionhost1.lan', 'sessionhost3.lan')
            },
            @{
                Property = 'WebAccessServer'
                Current  = $null
                Desired  = [System.String[]] @('webaccess1.lan', 'webaccess3.lan')
            },
            @{
                Property = 'WebAccessServer'
                Current  = 'webaccess.lan'
                Desired  = [System.String[]] @('webaccess1.lan', 'webaccess3.lan')
            }
        )
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    SessionHost      = [System.String[]] 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = [System.String[]]'webaccess.lan'
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

                    $script:mockInstance = [RDSessionDeployment] @{
                        SessionHost      = [System.String[]] 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = [System.String[]]'webaccess.lan'
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

Describe 'RDSessionDeployment\GetCurrentState()' -Tag 'HiddenMember' {
    Context 'When the resource is not present' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    ConnectionBroker = 'connectionbroker.lan'
                    SessionHost      = 'sessionhost.lan'
                    WebAccessServer  = 'webaccess.lan'
                }
            }

            Mock -CommandName Get-RDServer
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                    }
                )

                $currentState.ConnectionBroker | Should -BeNullOrEmpty
                $currentState.SessionHost | Should -BeNullOrEmpty
                $currentState.WebAccessServer | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is present' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    ConnectionBroker = 'connectionbroker.lan'
                    SessionHost      = 'sessionhost.lan'
                    WebAccessServer  = 'webaccess.lan'
                }
            }

            Mock -CommandName Get-RDServer -MockWith {
                [PSCustomObject] @{
                    Server = 'sessionhost.lan'
                    Roles  = @(
                        'RDS-RD-SERVER'
                    )
                }
                [PSCustomObject] @{
                    Server = 'connectionbroker.lan'
                    Roles  = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
                [PSCustomObject] @{
                    Server = 'webaccess.lan'
                    Roles  = @(
                        'RDS-WEB-ACCESS'
                    )
                }
            }
        }

        It 'Should return the correct values' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $currentState = $script:mockInstance.GetCurrentState(
                    @{
                        ConnectionBroker = 'connectionbroker.lan'
                    }
                )

                $currentState.SessionHost | Should -Be 'sessionhost.lan'
                $currentState.WebAccessServer | Should -Be 'webaccess.lan'
            }

            Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'RDSessionDeployment\Modify()' -Tag 'HiddenMember' {
    Context 'When the system is not in the desired state' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    SessionHost      = 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = 'webaccess.lan'
                } |
                    # Mock method AddRole which is called by the case method Modify().
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'AddRole' -Value {
                        $script:methodAddRoleCallCount += 1
                    } -PassThru |
                    # Mock method RemoveRole which is called by the case method Modify().
                    Add-Member -Force -MemberType 'ScriptMethod' -Name 'RemoveRole' -Value {
                        $script:methodRemoveRoleCallCount += 1
                    } -PassThru
            }
        }

        BeforeEach {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:methodAddRoleCallCount = 0
                $script:methodRemoveRoleCallCount = 0
            }
        }

        Context 'When the deployment should be created' {
            BeforeAll {
                Mock -CommandName New-RDSessionDeployment
                Mock -CommandName Set-DscMachineRebootRequired
            }

            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $mockProperties = @{
                        SessionHost      = 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = 'webaccess.lan'
                    }

                    $null = $script:mockInstance.Modify($mockProperties)

                    $script:methodAddRoleCallCount | Should -Be 0
                    $script:methodRemoveRoleCallCount | Should -Be 0
                }

                Should -Invoke -CommandName New-RDSessionDeployment -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-DscMachineRebootRequired -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the session host is missing' {
            It 'Should call method AddRole()' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $expected = @('sessionhost.lan', 'sessionhost2.lan')

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'SessionHost'
                            ExpectedValue = $expected
                            ActualValue   = 'sessionhost.lan'
                        }
                    )

                    $mockProperties = @{
                        SessionHost = $expected
                    }

                    $null = $script:mockInstance.Modify($mockProperties)

                    $script:methodAddRoleCallCount | Should -Be 1
                    $script:methodRemoveRoleCallCount | Should -Be 0
                }
            }
        }

        Context 'When there are too many session hosts' {
            It 'Should call method RemoveRole()' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $expected = 'sessionhost.lan'

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'SessionHost'
                            ExpectedValue = $expected
                            ActualValue   = @('sessionhost.lan', 'sessionhost2.lan')
                        }
                    )

                    $mockProperties = @{
                        SessionHost = $expected
                    }

                    $null = $script:mockInstance.Modify($mockProperties)

                    $script:methodAddRoleCallCount | Should -Be 0
                    $script:methodRemoveRoleCallCount | Should -Be 1
                }
            }
        }

        Context 'When the web access server is missing' {
            It 'Should call method AddRole()' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $expected = @('webaccess.lan', 'webaccess2.lan')

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'WebAccessServer'
                            ExpectedValue = $expected
                            ActualValue   = 'webaccess.lan'
                        }
                    )

                    $mockProperties = @{
                        WebAccessServer = $expected
                    }

                    $null = $script:mockInstance.Modify($mockProperties)

                    $script:methodAddRoleCallCount | Should -Be 1
                    $script:methodRemoveRoleCallCount | Should -Be 0
                }
            }
        }

        Context 'When there are too many web access servers' {
            It 'Should call method RemoveRole()' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $expected = 'webaccess.lan'

                    $script:mockInstance.PropertiesNotInDesiredState = @(
                        @{
                            Property      = 'WebAccessServer'
                            ExpectedValue = $expected
                            ActualValue   = @('webaccess.lan', 'webaccess2.lan')
                        }
                    )

                    $mockProperties = @{
                        WebAccessServer = @('webaccess.lan')
                    }

                    $null = $script:mockInstance.Modify($mockProperties)

                    $script:methodAddRoleCallCount | Should -Be 0
                    $script:methodRemoveRoleCallCount | Should -Be 1
                }
            }
        }
    }
}

Describe 'RDSessionDeployment\AssertProperties()' -Tag 'AssertProperties' {
    BeforeAll {
        InModuleScope -ScriptBlock {
            Set-StrictMode -Version 1.0

            $script:mockInstance = [RDSessionDeployment] @{}
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

                $errorRecord = Get-InvalidOperationRecord -Message $script:mockInstance.localizedData.RDSessionDeployment_OSRequirementNotMet

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

Describe 'RDSessionDeployment\AddRole()' -Tag 'HiddenMember' {
    BeforeAll {
        Mock -CommandName Add-RDServer
    }

    Context 'When adding a role' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    ConnectionBroker = 'connectionbroker.lan'
                    SessionHost      = @('sessionhost.lan', 'sessionhost2.lan')
                    WebAccessServer  = 'webaccess.lan'
                }
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.AddRole('sessionhost2.lan', 'RDS-RD-SERVER')
            }

            Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'RDSessionDeployment\RemoveRole()' -Tag 'HiddenMember' {
    BeforeAll {
        Mock -CommandName Remove-RDServer
    }

    Context 'When removing a role' {
        BeforeAll {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $script:mockInstance = [RDSessionDeployment] @{
                    ConnectionBroker = 'connectionbroker.lan'
                    SessionHost      = @('sessionhost.lan', 'sessionhost2.lan')
                    WebAccessServer  = 'webaccess.lan'
                }
            }
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $null = $script:mockInstance.RemoveRole('sessionhost2.lan', 'RDS-RD-SERVER')
            }

            Should -Invoke -CommandName Remove-RDServer -Exactly -Times 1 -Scope It
        }
    }
}
