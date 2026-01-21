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
    $script:dscModuleName = 'RemoteDesktopServicesDsc'
    $script:dscResourceName = 'DSC_RDSessionDeployment'

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

Describe 'DSC_RDSessionDeployment\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the resource is not present' {
        BeforeAll {
            Mock -CommandName Get-Service
            Mock -CommandName Start-Service -MockWith {
                throw 'Cannot find any service with service name ''RDMS''.'
            }

            Mock -CommandName Get-RDServer
        }

        Context 'When the RDMS service is not present' {
            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        SessionHost      = 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = 'webaccess.lan'
                    }

                    $result = Get-TargetResource @testParams -WarningVariable serviceWarning -WarningAction SilentlyContinue

                    $result.SessionHost | Should -BeNullOrEmpty
                    $result.ConnectionBroker | Should -BeNullOrEmpty
                    $result.WebAccessServer | Should -BeNullOrEmpty

                    $serviceWarning | Should -BeLike "Failed to start RDMS service. Error: 'Cannot find any service with service name 'RDMS'.'."
                }

                Should -Invoke -CommandName Get-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Start-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the resource is present' {
        BeforeAll {
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

            Mock -CommandName Start-Service
            Mock -CommandName Get-Service -MockWith {
                [PSCustomObject] @{
                    Status = 'Stopped'
                }
            }
        }

        Context 'When the RDMS service is stopped' {
            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        SessionHost      = [System.String[]] 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = [System.String[]] 'webaccess.lan'
                    }

                    $result = Get-TargetResource @testParams

                    $result.SessionHost | Should -Be $testParams.SessionHost
                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.WebAccessServer | Should -Be $testParams.WebAccessServer
                }

                Should -Invoke -CommandName Get-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Start-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the RDMS service fails to start' {
            BeforeAll {
                Mock -CommandName Start-Service -MockWith {
                    throw 'Throwing from Start-Service mock'
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        SessionHost      = 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = 'webaccess.lan'
                    }

                    $result = Get-TargetResource @testParams -WarningVariable serviceWarning -WarningAction SilentlyContinue

                    $result.SessionHost | Should -Be $testParams.SessionHost
                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.WebAccessServer | Should -Be $testParams.WebAccessServer

                    $serviceWarning | Should -BeLike "Failed to start RDMS service. Error: 'Throwing from Start-Service mock'."
                }

                Should -Invoke -CommandName Get-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Start-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the RDMS service is already running' {
            BeforeAll {
                Mock -CommandName Get-Service -MockWith {
                    [PSCustomObject]@{
                        Status = 'Running'
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        SessionHost      = 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = 'webaccess.lan'
                    }

                    $result = Get-TargetResource @testParams

                    $result.SessionHost | Should -Be $testParams.SessionHost
                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.WebAccessServer | Should -Be $testParams.WebAccessServer
                }

                Should -Invoke -CommandName Get-Service -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Start-Service -Exactly -Times 0 -Scope It
                Should -Invoke -CommandName Get-RDServer -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'DSC_RDSessionDeployment\Set-TargetResource' -Tag 'Set' {
    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName New-RDSessionDeployment
            Mock -CommandName Add-RDServer
            Mock -CommandName Remove-RDServer
        }

        Context 'When the deployment does not exist' {
            BeforeAll {
                Mock -CommandName Get-TargetResource
            }

            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        SessionHost      = 'sessionhost.lan'
                        ConnectionBroker = 'connectionbroker.lan'
                        WebAccessServer  = 'webaccess.lan'
                    }

                    $null = Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName New-RDSessionDeployment -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Add-RDServer -Exactly -Times 0 -Scope It
            }
        }

        Context 'When the deployment does exist' {
            BeforeDiscovery {
                $addTestCases = @(
                    @{
                        Property     = 'SessionHost'
                        DesiredValue = [System.String[]] ('sessionhost1.lan', 'sessionhost2.lan')
                        CurrentValue = [System.String[]] ('sessionhost1.lan')
                    }
                    @{
                        Property     = 'WebAccessServer'
                        DesiredValue = [System.String[]] ('webaccess1.lan', 'webaccess2.lan')
                        CurrentValue = [System.String[]] ('webaccess1.lan')
                    }
                )

                $removeTestCases = @(
                    @{
                        Property     = 'SessionHost'
                        DesiredValue = [System.String[]] ('sessionhost1.lan')
                        CurrentValue = [System.String[]] ('sessionhost1.lan', 'sessionhost2.lan')
                    }
                    @{
                        Property     = 'WebAccessServer'
                        DesiredValue = [System.String[]] ('webaccess1.lan')
                        CurrentValue = [System.String[]] ('webaccess1.lan', 'webaccess2.lan')
                    }
                )
            }

            Context 'When a ''<Property>'' should be added' -ForEach $addTestCases {
                BeforeEach {
                    Mock -CommandName Get-TargetResource -MockWith {
                        $obj = @{
                            SessionHost      = [System.String[]] ('sessionhost1.lan')
                            ConnectionBroker = 'connectionbroker.lan'
                            WebAccessServer  = [System.String[]] ('webaccess1.lan')
                        }

                        $obj[$Property] = $CurrentValue
                        return $obj
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -Parameters $_ -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            SessionHost      = 'sessionhost1.lan'
                            ConnectionBroker = 'connectionbroker.lan'
                            WebAccessServer  = 'webaccess1.lan'
                        }

                        $testParams[$Property] = $DesiredValue

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName New-RDSessionDeployment -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Remove-RDServer -Exactly -Times 0 -Scope It
                }
            }

            Context 'When a ''<Property>'' should be removed' -ForEach $removeTestCases {
                BeforeEach {
                    Mock -CommandName Get-TargetResource -MockWith {
                        $obj = @{
                            SessionHost      = [System.String[]] ('sessionhost1.lan')
                            ConnectionBroker = 'connectionbroker.lan'
                            WebAccessServer  = [System.String[]] ('webaccess1.lan')
                        }

                        $obj[$Property] = $CurrentValue
                        return $obj
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -Parameters $_ -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            SessionHost      = 'sessionhost1.lan'
                            ConnectionBroker = 'connectionbroker.lan'
                            WebAccessServer  = 'webaccess1.lan'
                        }

                        $testParams[$Property] = $DesiredValue

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName New-RDSessionDeployment -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Add-RDServer -Exactly -Times 0 -Scope It
                    Should -Invoke -CommandName Remove-RDServer -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}

Describe 'DSC_RDSessionDeployment\Test-TargetResource' -Tag 'Test' {
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
                Desired  = [System.String[]] 'sessionhost1.lan', 'sessionhost3.lan'
            },
            @{
                Property = 'WebAccessServer'
                Current  = $null
                Desired  = [System.String[]] 'webaccess1.lan', 'webaccess3.lan'
            }
            @{
                Property = 'WebAccessServer'
                Current  = 'webaccess.lan'
                Desired  = [System.String[]] 'webaccess1.lan', 'webaccess3.lan'
            }
        )
    }

    Context 'When the property ''<Property>'' is not correct' -ForEach $testCases {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                $obj = @{
                    SessionHost      = [System.String[]] 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = [System.String[]]'webaccess.lan'
                }

                $obj[$Property] = $Current
                return $obj
            }
        }

        It 'Should return the correct result' {
            InModuleScope -Parameters $_ -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    SessionHost      = 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = 'webaccess.lan'
                }

                $testParams[$Property] = $Desired

                Test-TargetResource @testParams | Should -BeFalse
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    SessionHost      = [System.String[]] 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = [System.String[]]'webaccess.lan'
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    SessionHost      = 'sessionhost.lan'
                    ConnectionBroker = 'connectionbroker.lan'
                    WebAccessServer  = 'webaccess.lan'
                }

                Test-TargetResource @testParams | Should -BeTrue
            }
        }
    }
}
