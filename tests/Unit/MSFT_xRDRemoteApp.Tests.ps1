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
    $script:dscResourceName = 'MSFT_xRDRemoteApp'

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

Describe 'MSFT_xRDRemoteApp\Get-TargetResource' -Tag 'Get' {
    Context 'When the resource exists' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-RDRemoteApp -MockWith {
                @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = [System.UInt32] 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = [System.String[]] @('DOMAIN\MyAppGroup_DLG')
                    ShowInWebAccess     = $true
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                $result = Get-TargetResource @testParams

                $result.CollectionName | Should -Be $testParams.CollectionName
                $result.DisplayName | Should -Be $testParams.DisplayName
                $result.FilePath | Should -Be $testParams.FilePath
                $result.Alias | Should -Be $testParams.Alias
                $result.Ensure | Should -Be 'Present'
                $result.FileVirtualPath | Should -Be $testParams.FileVirtualPath
                $result.FolderName | Should -Be $testParams.FolderName
                $result.CommandLineSetting | Should -Be $testParams.CommandLineSetting
                $result.RequiredCommandLine | Should -Be $testParams.RequiredCommandLine
                $result.IconIndex | Should -Be 0
                $result.IconPath | Should -Be $testParams.IconPath
                $result.UserGroups | Should -Be $testParams.UserGroups
                $result.ShowInWebAccess | Should -Be $testParams.ShowInWebAccess
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDRemoteApp -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource does not exist' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-RDRemoteApp
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                $result = Get-TargetResource @testParams

                $result.CollectionName | Should -Be $testParams.CollectionName
                $result.DisplayName | Should -BeNullOrEmpty
                $result.FilePath | Should -BeNullOrEmpty
                $result.Alias | Should -Be $testParams.Alias
                $result.Ensure | Should -Be 'Absent'
                $result.FileVirtualPath | Should -BeNullOrEmpty
                $result.FolderName | Should -BeNullOrEmpty
                $result.CommandLineSetting | Should -BeNullOrEmpty
                $result.RequiredCommandLine | Should -BeNullOrEmpty
                $result.IconIndex | Should -Be 0
                $result.IconPath | Should -BeNullOrEmpty
                $result.UserGroups | Should -BeNullOrEmpty
                $result.ShowInWebAccess | Should -BeNullOrEmpty
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDRemoteApp -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the collection does not exist' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection -MockWith {
                throw 'Mock Error'
            }

            Mock -CommandName Get-RDRemoteApp
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                { Get-TargetResource @testParams } | Should -Throw -ExpectedMessage "Failed to lookup RD Session Collection $($testParams.CollectionName). Error: Mock Error"
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'MSFT_xRDRemoteApp\Set-TargetResource' -Tag 'Set' {
    Context 'When the resource should be created' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-RDRemoteApp
            Mock -CommandName New-RDRemoteApp
            Mock -CommandName Remove-RDRemoteApp
            Mock -CommandName Set-RDRemoteApp
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDRemoteApp -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-RDRemoteApp -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Remove-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName Set-RDRemoteApp -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the resource should be removed' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-RDRemoteApp -MockWith {
                @{
                    Name = 'SomeValue'
                }
            }

            Mock -CommandName New-RDRemoteApp
            Mock -CommandName Remove-RDRemoteApp
            Mock -CommandName Set-RDRemoteApp
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Ensure              = 'Absent'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDRemoteApp -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName Remove-RDRemoteApp -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Set-RDRemoteApp -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the resource should be updated' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-RDRemoteApp -MockWith {
                @{
                    Name = 'SomeValue'
                }
            }

            Mock -CommandName New-RDRemoteApp
            Mock -CommandName Remove-RDRemoteApp
            Mock -CommandName Set-RDRemoteApp
        }

        It 'Should call the correct mocks' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                $null = Set-TargetResource @testParams
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDRemoteApp -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName New-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName Remove-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName Set-RDRemoteApp -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the collection does not exist' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection -MockWith {
                throw 'Mock Error'
            }

            Mock -CommandName Get-RDRemoteApp
            Mock -CommandName New-RDRemoteApp
            Mock -CommandName Remove-RDRemoteApp
            Mock -CommandName Set-RDRemoteApp
        }

        It 'Should generate an error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                { Set-TargetResource @testParams } | Should -Throw -ExpectedMessage 'Failed to lookup RD Session Collection TestCollection. Error: Mock Error'
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName New-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName Remove-RDRemoteApp -Exactly -Times 0 -Scope It
            Should -Invoke -CommandName Set-RDRemoteApp -Exactly -Times 0 -Scope It
        }
    }
}

Describe 'MSFT_xRDRemoteApp\Test-TargetResource' -Tag 'Test' {
    Context 'When the resource is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = [System.UInt32] 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = [System.String[]] @('DOMAIN\MyAppGroup_DLG')
                    ShowInWebAccess     = $true
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = @('DOMAIN\MyAppGroup_DLG')
                    ShowInWebAccess     = $true
                }

                Test-TargetResource @testParams | Should -BeTrue
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the resource is not in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection
            Mock -CommandName Get-TargetResource -MockWith {
                @{
                    CollectionName      = 'TestCollection'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = [System.UInt32] 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = [System.String[]] @('DOMAIN\MyAppGroup_DLG')
                    ShowInWebAccess     = $true
                }
            }
        }

        BeforeDiscovery {
            $testCases = @(
                @{
                    Parameter = 'DisplayName'
                    Value     = 'MyCalc (1.1.0)'
                }
                @{
                    Parameter = 'FilePath'
                    Value     = 'c:\windows\system32\calc.ex'
                }
                @{
                    Parameter = 'FileVirtualPath'
                    Value     = 'c:\windows\system32\calc.ex'
                }
                @{
                    Parameter = 'FolderName'
                    Value     = 'Test_Different'
                }
                @{
                    Parameter = 'CommandLineSetting'
                    Value     = 'Allow'
                }
                @{
                    Parameter = 'RequiredCommandLine'
                    Value     = 'my-cmd-other'
                }
                @{
                    Parameter = 'IconIndex'
                    Value     = 1
                }
                @{
                    Parameter = 'IconPath'
                    Value     = 'c:\windows\system32\calc.ex'
                }
                @{
                    Parameter = 'UserGroups'
                    Value     = @('DOMAIN\MyAppGroup_DLG', 'DOMAIN\AnotherGroup_DLG')
                }
                @{
                    Parameter = 'ShowInWebAccess'
                    Value     = $false
                }
            )
        }

        Context 'When the Parameter <Parameter> is different' -ForEach $testCases {
            It 'Should return the correct result' {
                InModuleScope -Parameters $_ -ScriptBlock {
                    Set-StrictMode -Version 1.0

                    $testParams = @{
                        CollectionName      = 'TestCollection'
                        Alias               = 'Test-MyCalc-(1.0.0)'
                        DisplayName         = 'MyCalc (1.0.0)'
                        FilePath            = 'c:\windows\system32\calc.exe'
                        Ensure              = 'Present'
                        FileVirtualPath     = 'c:\windows\system32\calc.exe'
                        FolderName          = 'Test'
                        CommandLineSetting  = 'DoNotAllow'
                        RequiredCommandLine = 'my-cmd'
                        IconIndex           = 0
                        IconPath            = 'c:\windows\system32\calc.exe'
                        UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                        ShowInWebAccess     = $true
                    }

                    $testParams[$Parameter] = $Value

                    Test-TargetResource @testParams | Should -BeFalse
                }

                Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
                Should -Invoke -CommandName Get-TargetResource -Exactly -Times 1 -Scope It
            }
        }
    }

    Context 'When the collection does not exist' {
        BeforeAll {
            Mock -CommandName Assert-Module
            Mock -CommandName Get-RDSessionCollection -MockWith {
                throw 'Mock Error'
            }

            Mock -CommandName Get-TargetResource
        }

        It 'Should generate an error' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    CollectionName      = 'TestCollection'
                    Alias               = 'Test-MyCalc-(1.0.0)'
                    DisplayName         = 'MyCalc (1.0.0)'
                    FilePath            = 'c:\windows\system32\calc.exe'
                    Ensure              = 'Present'
                    FileVirtualPath     = 'c:\windows\system32\calc.exe'
                    FolderName          = 'Test'
                    CommandLineSetting  = 'DoNotAllow'
                    RequiredCommandLine = 'my-cmd'
                    IconIndex           = 0
                    IconPath            = 'c:\windows\system32\calc.exe'
                    UserGroups          = 'DOMAIN\MyAppGroup_DLG'
                    ShowInWebAccess     = $true
                }

                { Test-TargetResource @testParams } | Should -Throw -ExpectedMessage 'Failed to lookup RD Session Collection TestCollection. Error: Mock Error'
            }

            Should -Invoke -CommandName Assert-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-RDSessionCollection -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Get-TargetResource -Exactly -Times 0 -Scope It
        }
    }
}
