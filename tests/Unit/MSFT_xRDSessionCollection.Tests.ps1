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

# $testcollectionNameMulti = 'TestCollectionMulti'

# $testCollection = @(
#     @{
#         Name        = 'TestCollection1'
#         Description = 'Test Collection 1'
#     }
#     @{
#         Name        = 'TestCollection2'
#         Description = 'Test Collection 2'
#     }
# )

# $testSessionHost = 'localhost'
# $testSessionHostMulti = 'rdsh1', 'rdsh2', 'rdsh3'
# $testConnectionBroker = 'localhost.fqdn'

# $validTargetResourceCall = @{
#     CollectionName   = $testCollection[0].Name
#     SessionHost      = $testSessionHost
#     ConnectionBroker = $testConnectionBroker
# }

# $nonExistentTargetResourceCall1 = @{
#     CollectionName   = 'TestCollection4'
#     SessionHost      = $testSessionHost
#     ConnectionBroker = $testConnectionBroker
# }

# $nonExistentTargetResourceCall2 = @{
#     CollectionName   = 'TestCollection5'
#     SessionHost      = $testSessionHost
#     ConnectionBroker = $testConnectionBroker
# }
# $validMultiTargetResourceCall = @{
#     CollectionName   = $testcollectionNameMulti
#     SessionHost      = $testSessionHostMulti
#     ConnectionBroker = $testConnectionBroker
# }
# $invalidMultiTargetResourceCall = @{
#     CollectionName   = $testcollectionNameMulti
#     SessionHost      = $testSessionHostMulti | Select-Object -Skip 1
#     ConnectionBroker = $testConnectionBroker
# }

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
            Mock -CommandName Get-TargetResource -MockWith {
                return @{
                    CollectionName        = 'TestCollection1'
                    SessionHost           = [System.String[]] @('rdsh1', 'rdsh2')
                    CollectionDescription = 'Test Collection 1'
                    ConnectionBroker      = 'localhost.fqdn'
                    Force                 = $false
                }
            }

            Mock -CommandName Add-RDSessionHost
            Mock -CommandName Remove-RDSessionHost
        }

        Context 'When a session host should be added' {
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

        Context 'When a session host should be removed' {
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

            Mock -CommandName New-RDSessionCollection
        }

        Context 'When creating the session collection succeeds' {
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

                    Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName New-RDSessionCollection -Exactly -Times 1 -Scope It # TODO: this is not passing locally
                Should -Invoke -CommandName Test-TargetResource -Exactly -Times 1 -Scope It
            }
        }
    }

    # Mock -CommandName Get-RDSessionCollection
    # Mock -CommandName New-RDSessionCollection
    # Mock -CommandName Compare-Object
    # Mock -CommandName Get-RDSessionHost {
    #     return @{
    #         CollectionName = $testCollection[0].Name
    #         SessionHost    = $testSessionHost
    #     }
    #     return @{
    #         CollectionName = $testCollectionNameMulti
    #         SessionHost    = $testSessionHostMulti
    #     }
    # }

    # Context 'Validate Set-TargetResource actions' {
    #     It 'Given the configuration is applied, New-RDSessionCollection is called' {
    #         Mock -CommandName Test-TargetResource -MockWith { return $true }
    #         Set-TargetResource -CollectionName $testCollection[0].Name -ConnectionBroker $testConnectionBroker -SessionHost $testSessionHost -Verbose
    #         Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope Context
    #     }
    # }
    # Context 'New-RDSessionCollection returns an exception, but creates the desired RDSessionCollection' {
    #     Mock -CommandName Test-TargetResource -MockWith { return $true }
    #     Mock -CommandName Compare-Object
    #     Mock -CommandName New-RDSessionCollection -MockWith {
    #         throw [Microsoft.PowerShell.Commands.WriteErrorException] 'The property EncryptionLevel is configured by using Group Policy settings. Use the Group Policy Management Console to configure this property.'
    #     }

    #     It 'does not return an exception' {
    #         { Set-TargetResource -CollectionName $testCollection[0].Name -ConnectionBroker $testConnectionBroker -SessionHost $testSessionHost } | Should -Not -Throw
    #     }

    #     It 'calls New-RDSessionCollection' {
    #         Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope Context
    #     }
    # }

    # Context 'Get-RDSessionCollection returns an exception, without creating the desired RDSessionCollection' {
    #     Mock -CommandName New-RDSessionCollection -MockWith {
    #         throw [Microsoft.PowerShell.Commands.WriteErrorException] "A Remote Desktop Services deployment does not exist on $testConnectionBroker. This operation can be performed after creating a deployment. For information about creating a deployment, run `"Get-Help New-RDVirtualDesktopDeployment`" or `"Get-Help New-RDSessionDeployment`""
    #     }

    #     Mock -CommandName Get-RDSessionCollection -MockWith {
    #         $null
    #     }

    #     It 'returns an exception' {
    #         { Set-TargetResource -CollectionName $testCollection[0].Name -ConnectionBroker $testConnectionBroker -SessionHost $testSessionHost } | Should -Throw
    #     }

    #     It 'calls New-RDSessionCollection and Get-RDSessionCollection' {
    #         Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope Context
    #         Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope Describe
    #     }
    # }

    # Context 'Session Collection exists, but list of session hosts is different' {
    #     Mock -CommandName Get-TargetResource -MockWith {
    #         @{
    #             'ConnectionBroker'      = 'CB'
    #             'CollectionDescription' = 'Description'
    #             'CollectionName'        = 'ExistingCollection'
    #             'SessionHost'           = 'SurplusHost'
    #         }
    #     }
    #     Mock -CommandName Compare-Object -MockWith {
    #         'SurplusHost' | Add-Member -NotePropertyName SideIndicator -NotePropertyValue '<=' -PassThru
    #         'MissingHost' | Add-Member -NotePropertyName SideIndicator -NotePropertyValue '=>' -PassThru
    #     }
    #     Mock -CommandName Add-RDSessionHost
    #     Mock -CommandName Remove-RDSessionHost

    #     It 'calls Add and Remove-RDSessionHost' {
    #         Set-TargetResource -CollectionName 'ExistingCollection' -ConnectionBroker 'CB' -SessionHost 'MissingHost' -Force $true
    #         Assert-MockCalled -CommandName Add-RDSessionHost -Times 1 -Scope Context
    #         Assert-MockCalled -CommandName Remove-RDSessionHost -Times 1 -Scope Context
    #     }

    #     Mock -CommandName Get-TargetResource -MockWith {
    #         @{
    #             'ConnectionBroker'      = 'CB'
    #             'CollectionDescription' = 'Description'
    #             'CollectionName'        = 'ExistingCollection'
    #             'SessionHost'           = $null
    #         }
    #     }
    #     It 'calls Add-RDSessionHost if no session hosts exist' {
    #         Set-TargetResource -CollectionName 'ExistingCollection' -ConnectionBroker 'CB' -SessionHost 'MissingHost' -Force $true
    #         Assert-MockCalled -CommandName Add-RDSessionHost -Times 1 -Scope Context
    #     }
    # }
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
