[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'Suppressing this rule because Script Analyzer does not understand Pester syntax.')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies have been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 3>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies have not been resolved, this will throw an error.
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

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'RDSReason' -Tag 'RDSReason' {
    Context 'When instantiating the class' {
        It 'Should not throw an error' {
            $script:mockRDSReasonInstance = InModuleScope -ScriptBlock {
                [RDSReason]::new()
            }
        }

        It 'Should be of the correct type' {
            $mockRDSReasonInstance | Should -Not -BeNullOrEmpty
            $mockRDSReasonInstance.GetType().Name | Should -Be 'RDSReason'
        }
    }

    Context 'When setting and reading values' {
        It 'Should be able to set value in instance' {
            $script:mockRDSReasonInstance = InModuleScope -ScriptBlock {
                $RDSReasonInstance = [RDSReason]::new()

                $RDSReasonInstance.Code = 'RDSReason:RDSReason:Ensure'
                $RDSReasonInstance.Phrase = 'The property Ensure should be "Present", but was "Absent"'

                return $RDSReasonInstance
            }
        }

        It 'Should be able read the values from instance' {
            $mockRDSReasonInstance.Code | Should -Be 'RDSReason:RDSReason:Ensure'
            $mockRDSReasonInstance.Phrase | Should -Be 'The property Ensure should be "Present", but was "Absent"'
        }
    }
}
