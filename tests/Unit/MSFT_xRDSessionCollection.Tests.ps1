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
    $script:dscResourceName = 'MSFT_xRDSessionCollection'

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

Describe 'MSFT_xRDSessionCollection\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the resource is present' {
        BeforeAll {
            Mock -CommandName Get-RDSessionCollection -MockWith {
                return @(
                    [PSCustomObject] @{
                        CollectionName        = 'TestCollection1'
                        CollectionDescription = 'Test Collection 1'
                    }
                    [PSCustomObject] @{
                        CollectionName        = 'TestCollection2'
                        CollectionDescription = 'Test Collection 2'
                    }
                    [PSCustomObject] @{
                        CollectionName        = 'TestCollection2'
                        CollectionDescription = 'Test Collection 2'
                    }
                )
            }
        }

        Context 'When more than one match is returned' {
            It 'Should throw the correct exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection2'
                        SessionHost           = 'localhost'
                        CollectionDescription = 'Test Collection 2'
                        ConnectionBroker      = 'localhost.fqdn'
                    }

                    $errorRecord = Get-InvalidResultRecord -Message 'Non-singular RDSessionCollection in result set'

                    { Get-TargetResource @testParams } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            }
        }

        Context 'When only one match is returned' {
            BeforeAll {
                Mock -CommandName Get-RDSessionHost -MockWith {
                    return @(
                        @{
                            SessionHost = 'localhost'
                        }
                    )
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = 'localhost'
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $false
                    }

                    $result = Get-TargetResource @testParams

                    $result.CollectionName | Should -Be $testParams.CollectionName
                    $result.CollectionDescription | Should -Be $testParams.CollectionDescription
                    $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                    $result.SessionHost | Should -Be $testParams.SessionHost
                    $result.Force | Should -Be $testParams.Force
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionHost -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the resource is present' {
        Context 'When no matches are returned (default behavior)' {
            BeforeAll {
                Mock -CommandName Get-RDSessionCollection
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = 'localhost'
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $false
                    }

                    $result = Get-TargetResource @testParams

                    $result.CollectionName | Should -BeNullOrEmpty
                    $result.CollectionDescription | Should -BeNullOrEmpty
                    $result.ConnectionBroker | Should -BeNullOrEmpty
                    $result.SessionHost | Should -Be $testParams.SessionHost
                    $result.Force | Should -Be $testParams.Force
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            }
        }

        Context 'When non matching collections are returned (2019 behavior)' {
            BeforeAll {
                Mock -CommandName Get-RDSessionCollection -MockWith {
                    return @(
                        [PSCustomObject] @{
                            CollectionName        = 'TestCollection2'
                            CollectionDescription = 'Test Collection 2'
                        }
                        [PSCustomObject] @{
                            CollectionName        = 'TestCollection3'
                            CollectionDescription = 'Test Collection 3'
                        }
                    )
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = 'localhost'
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $false
                    }

                    $result = Get-TargetResource @testParams

                    $result.CollectionName | Should -BeNullOrEmpty
                    $result.CollectionDescription | Should -BeNullOrEmpty
                    $result.ConnectionBroker | Should -BeNullOrEmpty
                    $result.SessionHost | Should -Be $testParams.SessionHost
                    $result.Force | Should -Be $testParams.Force
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'MSFT_xRDSessionCollection\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the resource is present' {
        BeforeAll {
            Mock -CommandName Add-RDSessionHost
            Mock -CommandName Remove-RDSessionHost
        }

        Context 'When a session host should be added' {
            Context 'When the session host is not ''$null''' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            CollectionName        = 'TestCollection1'
                            SessionHost           = [System.String[]] @('rdsh1', 'rdsh2')
                            CollectionDescription = 'Test Collection 1'
                            ConnectionBroker      = 'localhost.fqdn'
                            Force                 = $false
                        }
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName        = 'TestCollection1'
                            SessionHost           = @('rdsh1', 'rdsh2', 'rdsh3')
                            CollectionDescription = 'Test Collection 1'
                            ConnectionBroker      = 'localhost.fqdn'
                            Force                 = $true
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDSessionHost -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Remove-RDSessionHost -Exactly -Times 0 -Scope It
                }
            }

            Context 'When the session host is ''$null''' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            CollectionName        = 'TestCollection1'
                            SessionHost           = $null
                            CollectionDescription = 'Test Collection 1'
                            ConnectionBroker      = 'localhost.fqdn'
                            Force                 = $false
                        }
                    }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName        = 'TestCollection1'
                            SessionHost           = @('rdsh1', 'rdsh2', 'rdsh3')
                            CollectionDescription = 'Test Collection 1'
                            ConnectionBroker      = 'localhost.fqdn'
                            Force                 = $true
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Add-RDSessionHost -Exactly -Times 3 -Scope It
                    Should -Invoke -CommandName Remove-RDSessionHost -Exactly -Times 0 -Scope It
                }
            }
        }

        Context 'When a session host should be removed' {
            BeforeAll {
                Mock -CommandName Get-TargetResource -MockWith {
                    return @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = [System.String[]] @('rdsh1', 'rdsh2')
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $false
                    }
                }
            }

            It 'Should return the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = @('rdsh2')
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $true
                    }

                    $null = Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Add-RDSessionHost -Exactly -Times 0 -Scope It
                Should -Invoke -CommandName Remove-RDSessionHost -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the resource is absent' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    CollectionName        = $null
                    ConnectionBroker      = $null
                    CollectionDescription = $null
                    SessionHost           = [System.String[]] @('rdsh1', 'rdsh2')
                    Force                 = $false
                }
            }
        }

        Context 'When creating the session collection succeeds' {
            BeforeAll {
                Mock -CommandName New-RDSessionCollection
            }

            Context 'When the resource is in the desired state' {
                BeforeAll {
                    Mock -CommandName Test-TargetResource -MockWith { return $true }
                }

                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName        = 'TestCollection1'
                            SessionHost           = @('rdsh1', 'rdsh2')
                            CollectionDescription = 'Test Collection 1'
                            ConnectionBroker      = 'localhost.fqdn'
                            Force                 = $false
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName New-RDSessionCollection -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                }
            }

            Context 'When the resource is not in the desired state' {
                BeforeAll {
                    Mock -CommandName Test-TargetResource -MockWith { return $false }
                }

                It 'Should throw the correct exception' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName        = 'TestCollection1'
                            SessionHost           = @('rdsh1', 'rdsh2')
                            CollectionDescription = 'Test Collection 1'
                            ConnectionBroker      = 'localhost.fqdn'
                            Force                 = $false
                        }

                        $errorString = ("'Test-TargetResource' returns false after call to 'New-RDSessionCollection'; CollectionName: {0}; ConnectionBroker {1}." -f $testParams.CollectionName, $testParams.ConnectionBroker)

                        { Set-TargetResource @testParams } | Should -Throw -ExpectedMessage $errorString
                    }

                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName New-RDSessionCollection -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When creating the session collection fails' {
            BeforeAll {
                Mock -CommandName New-RDSessionCollection -MockWith { throw 'Mock error' }
                Mock -CommandName Test-TargetResource -MockWith { return $false }
            }

            It 'Should throw the correct exception' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = @('rdsh1', 'rdsh2')
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $false
                    }

                    $errorString = ("'Test-TargetResource' returns false after call to 'New-RDSessionCollection'; CollectionName: {0}; ConnectionBroker {1}." -f $testParams.CollectionName, $testParams.ConnectionBroker)

                    { Set-TargetResource @testParams } | Should -Throw -ExpectedMessage $errorString
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName New-RDSessionCollection -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
            }
        }
    }
}

Describe 'MSFT_xRDSessionCollection\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    CollectionName        = 'TestCollection1'
                    SessionHost           = [System.String[]] 'localhost'
                    CollectionDescription = 'Test Collection 1'
                    ConnectionBroker      = 'localhost.fqdn'
                    Force                 = $false
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName        = 'TestCollection1'
                    SessionHost           = 'localhost'
                    CollectionDescription = 'Test Collection 1'
                    ConnectionBroker      = 'localhost.fqdn'
                    Force                 = $false
                }

                Test-TargetResource @testParams | Should -BeTrue
            }

            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeDiscovery {
            $testCases = @(
                @{
                    ParameterName = 'CollectionName'
                    DesiredValue  = 'TestCollection2'
                }
                @{
                    ParameterName = 'SessionHost'
                    DesiredValue  = [System.String[]] @('rdsh1', 'rdsh2')
                }
                @{
                    ParameterName = 'CollectionDescription'
                    DesiredValue  = 'Test Collection 1 Updated'
                }
            )
        }

        BeforeAll {
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    CollectionName        = 'TestCollection1'
                    SessionHost           = [System.String[]] 'localhost'
                    CollectionDescription = 'Test Collection 1'
                    ConnectionBroker      = 'localhost.fqdn'
                    Force                 = $false
                }
            }
        }

        Context 'When the parameter ''<ParameterName>'' does not match' -ForEach $testCases {
            It 'Should return the correct result' {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName        = 'TestCollection1'
                        SessionHost           = 'localhost'
                        CollectionDescription = 'Test Collection 1'
                        ConnectionBroker      = 'localhost.fqdn'
                        Force                 = $false
                    }

                    # Override the parameter under test to the desired value
                    $testParams[$ParameterName] = $DesiredValue

                    Test-TargetResource @testParams | Should -BeFalse
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            }
        }
    }
}
