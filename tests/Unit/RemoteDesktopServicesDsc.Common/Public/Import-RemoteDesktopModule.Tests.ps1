[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Required setup block per project template')]
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
                & "$PSScriptRoot/../../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
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
    $script:subModuleName = 'RemoteDesktopServicesDsc.Common'

    $script:parentModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
    $script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'

    $script:subModulePath = Join-Path -Path $script:subModulesFolder -ChildPath $script:subModuleName

    Import-Module -Name $script:subModulePath -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:subModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:subModuleName -All | Remove-Module -Force
}

Describe 'Import-RemoteDesktopModule - Parameter Set Contract' {
    BeforeAll {
        $script:command = Get-Command -Name 'Import-RemoteDesktopModule'
    }

    It 'Should be a function' {
        $script:command.CommandType | Should -Be 'Function'
    }

    It 'Should have exactly one parameter set named __AllParameterSets' {
        $script:command.ParameterSets | Should -HaveCount 1
        $script:command.ParameterSets[0].Name | Should -Be '__AllParameterSets'
    }

    It 'Should have no required parameters' {
        $requiredParams = $script:command.ParameterSets[0].Parameters |
            Where-Object { $_.IsMandatory -and $_.Name -notin [System.Management.Automation.Cmdlet]::CommonParameters }

        $requiredParams | Should -BeNullOrEmpty
    }

    It 'Should have no custom parameters beyond common parameters' {
        $customParams = $script:command.Parameters.Keys |
            Where-Object { $_ -notin [System.Management.Automation.Cmdlet]::CommonParameters }

        $customParams | Should -BeNullOrEmpty
    }
}

Describe 'Import-RemoteDesktopModule' {
    Context 'When the RDMS service is not present' {
        BeforeAll {
            Mock -CommandName Get-Service
            Mock -CommandName Start-Service
            Mock -CommandName Get-Module -MockWith { $false }
            Mock -CommandName Import-Module
        }

        It 'Should not attempt to start the service' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Get-Service -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Start-Service -Exactly -Times 0 -Scope It
        }

        It 'Should import the RemoteDesktop module globally' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Import-Module -ParameterFilter {
                $Name -eq 'RemoteDesktop' -and $Global -eq $true -and $Force -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the RDMS service is stopped' {
        BeforeAll {
            Mock -CommandName Get-Service -MockWith {
                $mockService = [PSCustomObject] @{
                    Status = 'Stopped'
                }

                $mockService | Add-Member -MemberType ScriptMethod -Name 'WaitForStatus' -Value {
                    param ($Status, $Timeout)
                }

                return $mockService
            }

            Mock -CommandName Start-Service
            Mock -CommandName Get-Module -MockWith { $false }
            Mock -CommandName Import-Module
        }

        It 'Should start the RDMS service' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Start-Service -ParameterFilter {
                $Name -eq 'RDMS'
            } -Exactly -Times 1 -Scope It
        }

        It 'Should import the RemoteDesktop module' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Import-Module -ParameterFilter {
                $Name -eq 'RemoteDesktop' -and $Global -eq $true -and $Force -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the RDMS service fails to start' {
        BeforeAll {
            Mock -CommandName Get-Service -MockWith {
                $mockService = [PSCustomObject] @{
                    Status = 'Stopped'
                }

                $mockService | Add-Member -MemberType ScriptMethod -Name 'WaitForStatus' -Value {
                    param ($Status, $Timeout)
                }

                return $mockService
            }

            Mock -CommandName Start-Service -MockWith {
                throw 'Throwing from Start-Service mock'
            }

            Mock -CommandName Get-Module -MockWith { $false }
            Mock -CommandName Import-Module
        }

        It 'Should throw an error' {
            { Import-RemoteDesktopModule } | Should -Throw -ExpectedMessage 'Throwing from Start-Service mock'

            Should -Invoke -CommandName Start-Service -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Import-Module -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the RDMS service is already running' {
        BeforeAll {
            Mock -CommandName Get-Service -MockWith {
                [PSCustomObject] @{
                    Status = 'Running'
                }
            }

            Mock -CommandName Start-Service
            Mock -CommandName Get-Module -MockWith { $false }
            Mock -CommandName Import-Module
        }

        It 'Should not attempt to start the service' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Get-Service -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Start-Service -Exactly -Times 0 -Scope It
        }

        It 'Should import the RemoteDesktop module' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Import-Module -ParameterFilter {
                $Name -eq 'RemoteDesktop' -and $Global -eq $true -and $Force -eq $true
            } -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the RemoteDesktop module is already loaded' {
        BeforeAll {
            Mock -CommandName Get-Service -MockWith {
                [PSCustomObject] @{
                    Status = 'Running'
                }
            }

            Mock -CommandName Start-Service
            Mock -CommandName Get-Module -MockWith { $true }
            Mock -CommandName Import-Module
        }

        It 'Should not import the module again' {
            Import-RemoteDesktopModule

            Should -Invoke -CommandName Get-Module -Exactly -Times 1 -Scope It
            Should -Invoke -CommandName Import-Module -Exactly -Times 0 -Scope It
        }
    }
}
