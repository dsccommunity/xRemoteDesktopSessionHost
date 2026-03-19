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

    # Derive the repository root from $PSScriptRoot so the test always loads the
    # built module from the build output rather than a version on PSModulePath.
    $script:repoRoot = Join-Path -Path $PSScriptRoot -ChildPath '../../../../' -Resolve
    $script:builtModuleRoot = Join-Path -Path $script:repoRoot -ChildPath 'output/builtModule' -Resolve
    $script:parentModuleBase = Get-ChildItem -Path (Join-Path -Path $script:builtModuleRoot -ChildPath $script:dscModuleName) -Directory |
        Select-Object -First 1 |
        Select-Object -ExpandProperty FullName
    $script:subModulesFolder = Join-Path -Path $script:parentModuleBase -ChildPath 'Modules'

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

Describe 'Test-RemoteDesktopServicesDscOsRequirement' {
    Context 'Windows 10' {
        BeforeAll {
            Mock Get-RemoteDesktopServicesDscOsVersion -MockWith { return (New-Object 'Version' 10, 1, 1, 1) }
        }

        It 'Should return true' {
            Test-RemoteDesktopServicesDscOsRequirement | Should -BeTrue
        }
    }

    Context 'Windows 8.1' {
        BeforeAll {
            Mock Get-RemoteDesktopServicesDscOsVersion -MockWith { return (New-Object 'Version' 6, 3, 1, 1) }
        }

        It 'Should return true' {
            Test-RemoteDesktopServicesDscOsRequirement | Should -BeTrue
        }
    }

    Context 'Windows 8' {
        BeforeAll {
            Mock Get-RemoteDesktopServicesDscOsVersion -MockWith { return (New-Object 'Version' 6, 2, 9200, 0) }
        }

        It 'Should return true' {
            Test-RemoteDesktopServicesDscOsRequirement | Should -BeTrue
        }
    }

    Context 'Windows 7' {
        BeforeAll {
            Mock Get-RemoteDesktopServicesDscOsVersion -MockWith { return (New-Object 'Version' 6, 1, 1, 0) }
        }

        It 'Should return false' {
            Test-RemoteDesktopServicesDscOsRequirement | Should -BeFalse
        }
    }
}
