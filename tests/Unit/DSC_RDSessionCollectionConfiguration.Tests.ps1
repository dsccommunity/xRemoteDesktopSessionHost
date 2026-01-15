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
    $script:dscResourceName = 'DSC_RDSessionCollectionConfiguration'

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

Describe 'DSC_RDSessionCollectionConfiguration\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the resource is present' {
        BeforeDiscovery {
            $userProfileProperties = @(
                @{
                    Property = 'DiskPath'
                }
                @{
                    Property = 'EnableUserProfileDisk'
                }
                @{
                    Property = 'ExcludeFilePath'
                }
                @{
                    Property = 'ExcludeFolderPath'
                }
                @{
                    Property = 'IncludeFilePath'
                }
                @{
                    Property = 'IncludeFolderPath'
                }
                @{
                    Property = 'MaxUserProfileDiskSizeGB'
                }
            )
        }

        BeforeAll {
            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                @{
                    CollectionName        = 'TestCollection'
                    CollectionDescription = 'Test Description'
                    CustomRdpProperty     = "use redirection server name:i:1`n"
                }
            }

            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                @{
                    CollectionName                 = 'TestCollection'
                    ClientDeviceRedirectionOptions = 'None'
                    ClientPrinterAsDefault         = 0
                    ClientPrinterRedirected        = 0
                    MaxRedirectedMonitors          = 16
                    RDEasyPrintDriverEnabled       = 0
                }
            } -ParameterFilter { $Client -eq $true }

            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                @{
                    CollectionName                = 'TestCollection'
                    ActiveSessionLimitMin         = 0
                    AutomaticReconnectionEnabled  = $true
                    BrokenConnectionAction        = 'Disconnect'
                    DisconnectedSessionLimitMin   = 120
                    IdleSessionLimitMin           = 480
                    TemporaryFoldersDeletedOnExit = $true
                }
            } -ParameterFilter { $Connection -eq $true }

            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                @{
                    CollectionName       = 'TestCollection'
                    AuthenticateUsingNLA = $true
                    EncryptionLevel      = 'High'
                    SecurityLayer        = 'SSL'
                }
            } -ParameterFilter { $Security -eq $true }

            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                @{
                    CollectionName = 'TestCollection'
                    UserGroup      = @('Domain\Group1', 'Domain\Group2')
                }
            } -ParameterFilter { $UserGroup -eq $true }

            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                @{
                    CollectionName           = 'TestCollection'
                    IncludeFolderPath        = $null
                    ExcludeFolderPath        = $null
                    IncludeFilePath          = $null
                    ExcludeFilePath          = $null
                    DiskPath                 = 'c:\temp'
                    EnableUserProfileDisk    = $true
                    MaxUserProfileDiskSizeGB = 5
                }
            } -ParameterFilter { $UserProfileDisk -eq $true }
        }

        Context 'When the server is ''Windows Server 2012 (R2)''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'6.3.9600.0'
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:result = Get-TargetResource -CollectionName 'TestCollection'

                    $result.CollectionName | Should -Be 'TestCollection'
                    $result.CollectionDescription | Should -Be 'Test Description'
                    $result.CustomRdpProperty | Should -Be 'use redirection server name:i:1'

                    $result.ClientDeviceRedirectionOptions | Should -Be 'None'
                    $result.ClientPrinterAsDefault | Should -Be 0
                    $result.ClientPrinterRedirected | Should -Be 0
                    $result.MaxRedirectedMonitors | Should -Be 16
                    $result.RDEasyPrintDriverEnabled | Should -BeFalse

                    $result.ActiveSessionLimitMin | Should -Be 0
                    $result.AutomaticReconnectionEnabled | Should -BeTrue
                    $result.BrokenConnectionAction | Should -Be 'Disconnect'
                    $result.DisconnectedSessionLimitMin | Should -Be 120
                    $result.IdleSessionLimitMin | Should -Be 480
                    $result.TemporaryFoldersDeletedOnExit | Should -BeTrue

                    $result.AuthenticateUsingNLA | Should -BeTrue
                    $result.EncryptionLevel | Should -Be 'High'
                    $result.SecurityLayer | Should -Be 'SSL'

                    $result.UserGroup | Should -Be @('Domain\Group1', 'Domain\Group2')
                }

                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $Client -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $Connection -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $Security -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $UserGroup -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $UserProfileDisk -eq $true } -Exactly -Times 0 -Scope It
            }

            It 'Should not return the UserProfileDisk property ''<Property>''' -ForEach $userProfileProperties {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:result.ContainsKey($Property) | Should -BeFalse
                }
            }
        }

        Context 'When the server is ''Windows Server 2016 or later''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'10.0.14393.0'
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:result = Get-TargetResource -CollectionName 'TestCollection'

                    $result.CollectionName | Should -Be 'TestCollection'
                    $result.CollectionDescription | Should -Be 'Test Description'
                    $result.CustomRdpProperty | Should -Be 'use redirection server name:i:1'

                    $result.ClientDeviceRedirectionOptions | Should -Be 'None'
                    $result.ClientPrinterAsDefault | Should -Be 0
                    $result.ClientPrinterRedirected | Should -Be 0
                    $result.MaxRedirectedMonitors | Should -Be 16
                    $result.RDEasyPrintDriverEnabled | Should -BeFalse

                    $result.ActiveSessionLimitMin | Should -Be 0
                    $result.AutomaticReconnectionEnabled | Should -BeTrue
                    $result.BrokenConnectionAction | Should -Be 'Disconnect'
                    $result.DisconnectedSessionLimitMin | Should -Be 120
                    $result.IdleSessionLimitMin | Should -Be 480
                    $result.TemporaryFoldersDeletedOnExit | Should -BeTrue

                    $result.AuthenticateUsingNLA | Should -BeTrue
                    $result.EncryptionLevel | Should -Be 'High'
                    $result.SecurityLayer | Should -Be 'SSL'

                    $result.UserGroup | Should -Be @('Domain\Group1', 'Domain\Group2')
                }

                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $Client -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $Connection -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $Security -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $UserGroup -eq $true } -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter { $UserProfileDisk -eq $true } -Exactly -Times 1 -Scope It
            }

            It 'Should return the UserProfileDisk property ''<Property>''' -ForEach $userProfileProperties {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $script:result.ContainsKey($Property) | Should -BeTrue
                }
            }
        }
    }
}

Describe 'DSC_RDSessionCollectionConfiguration\Set-TargetResource' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the session collection does not exist' {
        BeforeAll {
            Mock -CommandName Get-RDSessionCollection -MockWith {
                throw 'No session collection was found.'
            }
        }

        It 'Should throw an exception' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName = 'NonExistingCollection'
                }

                { Set-TargetResource @testParams } | Should -Throw
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the session collection exists' {
        BeforeAll {
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Set-RDSessionCollectionConfiguration
        }

        Context 'When the server is ''Windows Server 2012 (R2)''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'6.3.9600.0'
                }
            }

            It 'Should call the correct mocks' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName                 = 'TestCollection'
                        CollectionDescription          = 'Test Description'
                        CustomRdpProperty              = 'use redirection server name:i:0'

                        ClientDeviceRedirectionOptions = 'None'
                        ClientPrinterAsDefault         = $true
                        ClientPrinterRedirected        = $true
                        MaxRedirectedMonitors          = 8
                        RDEasyPrintDriverEnabled       = $true

                        ActiveSessionLimitMin          = 60
                        AutomaticReconnectionEnabled   = $false
                        BrokenConnectionAction         = 'LogOff'
                        DisconnectedSessionLimitMin    = 60
                        IdleSessionLimitMin            = 300
                        TemporaryFoldersDeletedOnExit  = $false

                        AuthenticateUsingNLA           = $false
                        EncryptionLevel                = 'Low'
                        SecurityLayer                  = 'RDP'

                        UserGroup                      = @('Domain\Group1')

                        EnableUserProfileDisk          = $true
                        DiskPath                       = 'C:\UserProfiles'
                        MaxUserProfileDiskSizeGB       = 5
                    }

                    $null = Set-TargetResource @testParams
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $null -eq $DiskPath } -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the server is ''Windows Server 2016 or later''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'10.0.14393.0'
                }
            }

            Context 'When ''UserProfileDisk'' is enabled' {
                Context 'When ''DiskPath'' is invalid' {
                    BeforeAll {
                        Mock -CommandName Test-Path -MockWith {
                            return $false
                        }
                    }

                    It 'Should throw the correct exception' {
                        InModuleScope -ScriptBlock {
                            Set-StrictMode -Version 1.0

                            $testParams = @{
                                CollectionName                 = 'TestCollection'
                                CollectionDescription          = 'Test Description'
                                CustomRdpProperty              = 'use redirection server name:i:0'

                                ClientDeviceRedirectionOptions = 'None'
                                ClientPrinterAsDefault         = $true
                                ClientPrinterRedirected        = $true
                                MaxRedirectedMonitors          = 8
                                RDEasyPrintDriverEnabled       = $true

                                ActiveSessionLimitMin          = 60
                                AutomaticReconnectionEnabled   = $false
                                BrokenConnectionAction         = 'LogOff'
                                DisconnectedSessionLimitMin    = 60
                                IdleSessionLimitMin            = 300
                                TemporaryFoldersDeletedOnExit  = $false

                                AuthenticateUsingNLA           = $false
                                EncryptionLevel                = 'Low'
                                SecurityLayer                  = 'RDP'

                                UserGroup                      = @('Domain\Group1')

                                EnableUserProfileDisk          = $true
                                DiskPath                       = 'C:\UserProfiles'
                                MaxUserProfileDiskSizeGB       = 5
                            }

                            $errorRecord = Get-InvalidArgumentRecord -ArgumentName 'DiskPath' -Message ('To enable UserProfileDisk we need a valid DiskPath. Path {0} not found' -f $testParams.DiskPath)

                            { Set-TargetResource @testParams } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
                        }

                        Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $null -eq $EnableUserProfileDisk } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When ''DiskPath'' is not provided' {
                    BeforeAll {
                        Mock -CommandName Test-Path -MockWith {
                            return $true
                        }
                    }

                    It 'Should throw the correct exception' {
                        InModuleScope -ScriptBlock {
                            Set-StrictMode -Version 1.0

                            $testParams = @{
                                CollectionName                 = 'TestCollection'
                                CollectionDescription          = 'Test Description'
                                CustomRdpProperty              = 'use redirection server name:i:0'

                                ClientDeviceRedirectionOptions = 'None'
                                ClientPrinterAsDefault         = $true
                                ClientPrinterRedirected        = $true
                                MaxRedirectedMonitors          = 8
                                RDEasyPrintDriverEnabled       = $true

                                ActiveSessionLimitMin          = 60
                                AutomaticReconnectionEnabled   = $false
                                BrokenConnectionAction         = 'LogOff'
                                DisconnectedSessionLimitMin    = 60
                                IdleSessionLimitMin            = 300
                                TemporaryFoldersDeletedOnExit  = $false

                                AuthenticateUsingNLA           = $false
                                EncryptionLevel                = 'Low'
                                SecurityLayer                  = 'RDP'

                                UserGroup                      = @('Domain\Group1')

                                EnableUserProfileDisk          = $true
                                MaxUserProfileDiskSizeGB       = 5
                            }

                            $errorRecord = Get-InvalidArgumentRecord -ArgumentName 'DiskPath' -Message 'No value found for parameter DiskPath. This is a mandatory parameter if EnableUserProfileDisk is set to True'

                            { Set-TargetResource @testParams } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
                        }

                        Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $null -eq $EnableUserProfileDisk } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When ''MaxUserProfileDiskSizeGB'' is invalid' {
                    BeforeAll {
                        Mock -CommandName Test-Path -MockWith {
                            return $true
                        }
                    }

                    It 'Should throw the correct exception' {
                        InModuleScope -ScriptBlock {
                            Set-StrictMode -Version 1.0

                            $testParams = @{
                                CollectionName                 = 'TestCollection'
                                CollectionDescription          = 'Test Description'
                                CustomRdpProperty              = 'use redirection server name:i:0'

                                ClientDeviceRedirectionOptions = 'None'
                                ClientPrinterAsDefault         = $true
                                ClientPrinterRedirected        = $true
                                MaxRedirectedMonitors          = 8
                                RDEasyPrintDriverEnabled       = $true

                                ActiveSessionLimitMin          = 60
                                AutomaticReconnectionEnabled   = $false
                                BrokenConnectionAction         = 'LogOff'
                                DisconnectedSessionLimitMin    = 60
                                IdleSessionLimitMin            = 300
                                TemporaryFoldersDeletedOnExit  = $false

                                AuthenticateUsingNLA           = $false
                                EncryptionLevel                = 'Low'
                                SecurityLayer                  = 'RDP'

                                UserGroup                      = @('Domain\Group1')

                                EnableUserProfileDisk          = $true
                                DiskPath                       = 'C:\UserProfiles'
                                MaxUserProfileDiskSizeGB       = 0
                            }

                            $errorRecord = Get-InvalidArgumentRecord -ArgumentName 'MaxUserProfileDiskSizeGB' -Message (
                                'To enable UserProfileDisk we need a setting for MaxUserProfileDiskSizeGB that is greater than 0. Current value {0} is not valid' -f $testParams.MaxUserProfileDiskSizeGB
                            )

                            { Set-TargetResource @testParams } | Should -Throw -ExpectedMessage $errorRecord.Exception.Message
                        }

                        Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $null -eq $EnableUserProfileDisk } -Exactly -Times 1 -Scope It
                    }
                }

                Context 'When ''EnableUserProfileDisk'' configuration is updated' {
                    BeforeAll {
                        Mock -CommandName Test-Path -MockWith {
                            return $true
                        }
                    }

                    It 'Should call the correct mocks' {
                        InModuleScope -ScriptBlock {
                            Set-StrictMode -Version 1.0

                            $testParams = @{
                                CollectionName                 = 'TestCollection'
                                CollectionDescription          = 'Test Description'
                                CustomRdpProperty              = 'use redirection server name:i:0'

                                ClientDeviceRedirectionOptions = 'None'
                                ClientPrinterAsDefault         = $true
                                ClientPrinterRedirected        = $true
                                MaxRedirectedMonitors          = 8
                                RDEasyPrintDriverEnabled       = $true

                                ActiveSessionLimitMin          = 60
                                AutomaticReconnectionEnabled   = $false
                                BrokenConnectionAction         = 'LogOff'
                                DisconnectedSessionLimitMin    = 60
                                IdleSessionLimitMin            = 300
                                TemporaryFoldersDeletedOnExit  = $false

                                AuthenticateUsingNLA           = $false
                                EncryptionLevel                = 'Low'
                                SecurityLayer                  = 'RDP'

                                UserGroup                      = @('Domain\Group1')

                                EnableUserProfileDisk          = $true
                                DiskPath                       = 'C:\UserProfiles'
                                MaxUserProfileDiskSizeGB       = 5
                            }

                            $null = Set-TargetResource @testParams
                        }

                        Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $null -eq $EnableUserProfileDisk } -Exactly -Times 1 -Scope It
                        Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $EnableUserProfileDisk -eq $true } -Exactly -Times 1 -Scope It
                    }
                }
            }

            Context 'When ''UserProfileDisk'' is disabled' {
                It 'Should call the correct mocks' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $false
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $false
                        }

                        $null = Set-TargetResource @testParams
                    }

                    Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $null -eq $DisableUserProfileDisk } -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $DisableUserProfileDisk -eq $true } -Exactly -Times 1 -Scope It
                }
            }
        }
    }

    # Context 'Running on set on Windows Server 2016 (or higher)' {
    #     Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
    #         [version]'10.0.14393.0'
    #     }

    #     Mock -CommandName Get-RDSessionCollection -MockWith {
    #         throw 'No session collection DoesNotExist was found.'
    #     }

    #     It 'Trying to configure a non existing collection should throw' {
    #         $errorMessages = try
    #         {
    #             Set-TargetResource -CollectionName 'DoesNotExist' -ActiveSessionLimitMin 1
    #         }
    #         catch
    #         {
    #             $_ 2>&1
    #         }

    #         $errorMessages.Exception.Message | Should -Be 'Failed to lookup RD Session Collection DoesNotExist. Error: No session collection DoesNotExist was found.'
    #     }

    #     Mock -CommandName Get-RDSessionCollection -MockWith { $true }
    #     It 'Running Set on W2016 with only EnableUserProfileDisk specified should throw on missing DiskPath parameter' {
    #         $errorMessages = try
    #         {
    #             Set-TargetResource -CollectionName 'TestCollection' -EnableUserProfileDisk $true
    #         }
    #         catch
    #         {
    #             $_ 2>&1
    #         }

    #         $errorMessages.Exception.Message | Should -Be 'No value found for parameter DiskPath. This is a mandatory parameter if EnableUserProfileDisk is set to True'
    #     }

    #     It 'Running Set on W2016 with EnableUserProfileDisk and Diskpath specified should throw on invalid MaxUserProfileDiskSizeGB parameter' {
    #         $errorMessages = try
    #         {
    #             Set-TargetResource -CollectionName 'TestCollection' -EnableUserProfileDisk $true -DiskPath TestDrive:\
    #         }
    #         catch
    #         {
    #             $_ 2>&1
    #         }

    #         $errorMessages.Exception.Message | Should -Be 'To enable UserProfileDisk we need a setting for MaxUserProfileDiskSizeGB that is greater than 0. Current value 0 is not valid'
    #     }

    #     It 'Running Set with EnableUserProfileDisk, DiskPath and MaxUserProfileDiskSizeGB, but with an invalid DiskPath, should throw' {
    #         $errorMessages = try
    #         {
    #             Set-TargetResource -CollectionName 'TestCollection' -EnableUserProfileDisk $true -DiskPath TestDrive:\NonExistingPath -MaxUserProfileDiskSizeGB 5
    #         }
    #         catch
    #         {
    #             $_ 2>&1
    #         }

    #         $errorMessages.Exception.Message | Should -Be 'To enable UserProfileDisk we need a valid DiskPath. Path TestDrive:\NonExistingPath not found'
    #     }

    #     It 'Running Set with all valid parameters should call Set-RDSessionCollectionConfiguration with EnableUserProfileDisk' {
    #         Set-TargetResource -CollectionName 'TestCollection' -EnableUserProfileDisk $true -DiskPath TestDrive:\ -MaxUserProfileDiskSizeGB 5
    #         Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $EnableUserProfileDisk -eq $true } -Times 1 -Exactly -Scope It
    #     }

    #     It 'Running Set without EnableUserProfileDisk should not call Set-RDSessionCollectionConfiguration with EnableUserProfileDisk' {
    #         Set-TargetResource -CollectionName 'TestCollection' -ActiveSessionLimitMin 1
    #         Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $EnableUserProfileDisk -eq $true } -Times 0 -Exactly -Scope It
    #     }

    #     It 'Running Set with EnableUserProfileDisk disabled should call Set-RDSessionCollectionConfiguration with DisableUserProfileDisk' {
    #         Set-TargetResource -CollectionName 'TestCollection' -EnableUserProfileDisk $false
    #         Should -Invoke -CommandName Set-RDSessionCollectionConfiguration -ParameterFilter { $DisableUserProfileDisk -eq $true } -Times 1 -Exactly -Scope It
    #     }
    # }
}

Describe 'DSC_RDSessionCollectionConfiguration\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is not in the desired state' {
        Context 'When the server is ''Windows Server 2012 (R2)''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'6.3.9600.0'
                }

                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        CollectionName                 = 'TestCollection'
                        CollectionDescription          = 'Test Description'
                        CustomRdpProperty              = 'use redirection server name:i:0'

                        ClientDeviceRedirectionOptions = 'None'
                        ClientPrinterAsDefault         = $true
                        ClientPrinterRedirected        = $true
                        MaxRedirectedMonitors          = 8
                        RDEasyPrintDriverEnabled       = $true

                        ActiveSessionLimitMin          = 60
                        AutomaticReconnectionEnabled   = $false
                        BrokenConnectionAction         = 'LogOff'
                        DisconnectedSessionLimitMin    = 60
                        IdleSessionLimitMin            = 300
                        TemporaryFoldersDeletedOnExit  = $false

                        AuthenticateUsingNLA           = $false
                        EncryptionLevel                = 'Low'
                        SecurityLayer                  = 'RDP'

                        UserGroup                      = @('Domain\Group1')
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName                 = 'TestCollection'
                        CollectionDescription          = 'Test Description'
                        CustomRdpProperty              = 'use redirection server name:i:0'

                        ClientDeviceRedirectionOptions = 'None'
                        ClientPrinterAsDefault         = $true
                        ClientPrinterRedirected        = $true
                        MaxRedirectedMonitors          = 8
                        RDEasyPrintDriverEnabled       = $true

                        ActiveSessionLimitMin          = 60
                        AutomaticReconnectionEnabled   = $false
                        BrokenConnectionAction         = 'LogOff'
                        DisconnectedSessionLimitMin    = 60
                        IdleSessionLimitMin            = 300
                        TemporaryFoldersDeletedOnExit  = $false

                        AuthenticateUsingNLA           = $true
                        EncryptionLevel                = 'Low'
                        SecurityLayer                  = 'RDP'

                        UserGroup                      = @('Domain\Group1')

                        EnableUserProfileDisk          = $true
                    }

                    Test-TargetResource @testParams | Should -BeFalse
                }

                Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the server is ''Windows Server 2016 or later''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'10.0.14393.0'
                }

                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        CollectionName                 = 'TestCollection'
                        CollectionDescription          = 'Test Description'
                        CustomRdpProperty              = 'use redirection server name:i:0'

                        ClientDeviceRedirectionOptions = 'None'
                        ClientPrinterAsDefault         = $true
                        ClientPrinterRedirected        = $true
                        MaxRedirectedMonitors          = 8
                        RDEasyPrintDriverEnabled       = $true

                        ActiveSessionLimitMin          = 60
                        AutomaticReconnectionEnabled   = $false
                        BrokenConnectionAction         = 'LogOff'
                        DisconnectedSessionLimitMin    = 60
                        IdleSessionLimitMin            = 300
                        TemporaryFoldersDeletedOnExit  = $false

                        AuthenticateUsingNLA           = $false
                        EncryptionLevel                = 'Low'
                        SecurityLayer                  = 'RDP'

                        UserGroup                      = @('Domain\Group1')

                        EnableUserProfileDisk          = $true
                        DiskPath                       = 'C:\UserProfiles'
                        MaxUserProfileDiskSizeGB       = 5
                    }
                }
            }

            Context 'When user profile is enabled' {
                It 'Should return the correct result' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $true
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $true
                        }

                        Test-TargetResource @testParams | Should -BeFalse
                    }

                    Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                }
            }

            Context 'When user profile is disabled' {
                It 'Should return the correct result' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $true
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $false
                        }

                        Test-TargetResource @testParams | Should -BeFalse
                    }

                    Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                }
            }
        }
    }

    Context 'When the resource is in the desired state' {
        Context 'When the server is ''Windows Server 2012 (R2)''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'6.3.9600.0'
                }

                Mock -CommandName Get-TargetResource -MockWith {
                    @{
                        CollectionName                 = 'TestCollection'
                        CollectionDescription          = 'Test Description'
                        CustomRdpProperty              = 'use redirection server name:i:0'

                        ClientDeviceRedirectionOptions = 'None'
                        ClientPrinterAsDefault         = $true
                        ClientPrinterRedirected        = $true
                        MaxRedirectedMonitors          = 8
                        RDEasyPrintDriverEnabled       = $true

                        ActiveSessionLimitMin          = 60
                        AutomaticReconnectionEnabled   = $false
                        BrokenConnectionAction         = 'LogOff'
                        DisconnectedSessionLimitMin    = 60
                        IdleSessionLimitMin            = 300
                        TemporaryFoldersDeletedOnExit  = $false

                        AuthenticateUsingNLA           = $false
                        EncryptionLevel                = 'Low'
                        SecurityLayer                  = 'RDP'

                        UserGroup                      = @('Domain\Group1')
                    }
                }
            }

            It 'Should return the correct result' {
                InModuleScope -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName                 = 'TestCollection'
                        CollectionDescription          = 'Test Description'
                        CustomRdpProperty              = 'use redirection server name:i:0'

                        ClientDeviceRedirectionOptions = 'None'
                        ClientPrinterAsDefault         = $true
                        ClientPrinterRedirected        = $true
                        MaxRedirectedMonitors          = 8
                        RDEasyPrintDriverEnabled       = $true

                        ActiveSessionLimitMin          = 60
                        AutomaticReconnectionEnabled   = $false
                        BrokenConnectionAction         = 'LogOff'
                        DisconnectedSessionLimitMin    = 60
                        IdleSessionLimitMin            = 300
                        TemporaryFoldersDeletedOnExit  = $false

                        AuthenticateUsingNLA           = $false
                        EncryptionLevel                = 'Low'
                        SecurityLayer                  = 'RDP'

                        UserGroup                      = @('Domain\Group1')

                        EnableUserProfileDisk          = $true
                    }

                    Test-TargetResource @testParams | Should -BeTrue
                }

                Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            }
        }

        Context 'When the server is ''Windows Server 2016 or later''' {
            BeforeAll {
                Mock -CommandName Get-RemoteDesktopServicesDscOsVersion -MockWith {
                    [version]'10.0.14393.0'
                }
            }

            Context 'When user profile is enabled' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $false
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $true
                            DiskPath                       = 'C:\UserProfiles'
                            MaxUserProfileDiskSizeGB       = 5
                        }
                    }
                }

                It 'Should return the correct result' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $false
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $true
                        }

                        Test-TargetResource @testParams | Should -BeTrue
                    }

                    Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                }
            }

            Context 'When user profile is disabled' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $false
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $false
                        }
                    }
                }

                It 'Should return the correct result' {
                    InModuleScope -ScriptBlock {
                        Set-StrictMode -Version 1.0

                        $testParams = @{
                            CollectionName                 = 'TestCollection'
                            CollectionDescription          = 'Test Description'
                            CustomRdpProperty              = 'use redirection server name:i:0'

                            ClientDeviceRedirectionOptions = 'None'
                            ClientPrinterAsDefault         = $true
                            ClientPrinterRedirected        = $true
                            MaxRedirectedMonitors          = 8
                            RDEasyPrintDriverEnabled       = $true

                            ActiveSessionLimitMin          = 60
                            AutomaticReconnectionEnabled   = $false
                            BrokenConnectionAction         = 'LogOff'
                            DisconnectedSessionLimitMin    = 60
                            IdleSessionLimitMin            = 300
                            TemporaryFoldersDeletedOnExit  = $false

                            AuthenticateUsingNLA           = $false
                            EncryptionLevel                = 'Low'
                            SecurityLayer                  = 'RDP'

                            UserGroup                      = @('Domain\Group1')

                            EnableUserProfileDisk          = $false
                        }

                        Test-TargetResource @testParams | Should -BeTrue
                    }

                    Should -Invoke -CommandName Get-RemoteDesktopServicesDscOsVersion -Exactly -Times 1 -Scope It
                    Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
