# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
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
    $script:dscResourceName = 'MSFT_xRDCertificateConfiguration'

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

Describe 'MSFT_xRDCertificateConfiguration\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        Mock -CommandName Assert-Module
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Get-RDCertificate -MockWith {
                @{
                    Thumbprint       = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'testdrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }
            }
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'testdrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                $result = Get-TargetResource @testParams

                $result.Role | Should -Be $testParams.Role
                $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                $result.ImportPath | Should -Be $testParams.ImportPath
                $result.Credential.UserName | Should -Be $testParams.Credential.UserName
            }
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Get-RDCertificate
        }

        It 'Should return the correct result' {
            InModuleScope -ScriptBlock {
                Set-StrictMode -Version 1.0

                $testParams = @{
                    Role             = 'RDRedirector'
                    ConnectionBroker = 'connectionbroker.lan'
                    ImportPath       = 'testdrive:\RDRedirector.pfx'
                    Credential       = [pscredential]::new('Test', (ConvertTo-SecureString -AsPlainText -String 'pester' -Force))
                }

                $result = Get-TargetResource @testParams

                # Key properties should still be returned when the resource is not present...
                # $result.Role | Should -Be $testParams.Role
                # $result.ConnectionBroker | Should -Be $testParams.ConnectionBroker
                $result.Role | Should -BeNullOrEmpty
                $result.ConnectionBroker | Should -BeNullOrEmpty
                $result.ImportPath | Should -BeNullOrEmpty
                $result.Credential.UserName | Should -BeNullOrEmpty
            }
        }
    }
}

# Describe 'Testing MSFT_xRDCertificateConfiguration' {

#     Mock -CommandName Set-RDCertificate

#     Context 'When a certificate is not configured' {

#         Mock -CommandName Get-RDCertificate -MockWith {
#             [pscustomobject]@{
#                 Thumbprint = $null
#                 Role       = 'RDPublishing'
#             }
#         } -ParameterFilter { $Role -eq 'RDPublishing' }

#         Mock -CommandName Get-PfxData -MockWith {
#             [pscustomobject]@{
#                 EndEntityCertificates = [pscustomobject]@{
#                     Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8B'
#                 }
#             }
#         } -ParameterFilter { $ImportPath -eq 'testdrive:\RDPublishing.pfx' }

#         $resourceNotConfiguredSplat = @{
#             Role             = 'RDPublishing'
#             ConnectionBroker = 'connectionbroker.lan'
#             ImportPath       = 'testdrive:\RDPublishing.pfx'
#             Credential       = [pscredential]::new(
#                 'Test',
#                 (ConvertTo-SecureString -AsPlainText -String 'pester' -Force)
#             )
#         }

#         It 'Get-TargetResource returns no thumbprint' {
#             (Get-TargetResource @resourceNotConfiguredSplat).Thumbprint | Should -BeNullOrEmpty
#         }

#         It 'Test-TargetResource returns false' {
#             Test-TargetResource @resourceNotConfiguredSplat | Should -BeFalse
#         }

#         It 'Set-TargetResource runs Set-RDCertificate' {
#             Set-TargetResource @resourceNotConfiguredSplat
#             Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly -ParameterFilter {
#                 $Role -eq $resourceNotConfiguredSplat.Role -and
#                 $ConnectionBroker -eq $resourceNotConfiguredSplat.ConnectionBroker -and
#                 $ImportPath -eq $resourceNotConfiguredSplat.ImportPath -and
#                 $Password -eq $resourceNotConfiguredSplat.Credential.Password -and
#                 $Force -eq $true
#             }
#         }
#     }

#     Context 'When the proper certificate is configured' {

#         Mock -CommandName Get-RDCertificate -MockWith {
#             [pscustomobject]@{
#                 Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
#                 Role       = 'RDRedirector'
#             }
#         } -ParameterFilter { $Role -eq 'RDRedirector' }

#         Mock -CommandName Get-PfxData -MockWith {
#             [pscustomobject]@{
#                 EndEntityCertificates = [pscustomobject]@{
#                     Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
#                 }
#             }
#         } -ParameterFilter { $ImportPath -eq 'testdrive:\RDRedirector.pfx' }

#         $resourceConfiguredSplat = @{
#             Role             = 'RDRedirector'
#             ConnectionBroker = 'connectionbroker.lan'
#             ImportPath       = 'testdrive:\RDRedirector.pfx'
#             Credential       = [pscredential]::new(
#                 'Test',
#                 (ConvertTo-SecureString -AsPlainText -String 'pester' -Force)
#             )
#         }

#         It 'Get-TargetResource returns the correct thumbprint' {
#             (Get-TargetResource @resourceConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8A'
#         }

#         It 'Test-TargetResource returns true' {
#             Test-TargetResource @resourceConfiguredSplat | Should -BeTrue
#         }
#     }

#     Context 'When a wrong certificate is configured' {

#         Mock -CommandName Get-RDCertificate -MockWith {
#             [pscustomobject]@{
#                 Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
#                 Role       = 'RDGateway'
#             }
#         } -ParameterFilter { $Role -eq 'RDGateway' }

#         Mock -CommandName Get-PfxData -MockWith {
#             [pscustomobject]@{
#                 EndEntityCertificates = [pscustomobject]@{
#                     Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8B'
#                 }
#             }
#         } -ParameterFilter { $ImportPath -eq 'testdrive:\RDGateway.pfx' }

#         $resourceWrongConfiguredSplat = @{
#             Role             = 'RDGateway'
#             ConnectionBroker = 'connectionbroker.lan'
#             ImportPath       = 'testdrive:\RDGateway.pfx'
#             Credential       = [pscredential]::new(
#                 'Test',
#                 (ConvertTo-SecureString -AsPlainText -String 'pester' -Force)
#             )
#         }

#         It 'Get-TargetResource returns the thumbprint of the currently configured certificate' {
#             (Get-TargetResource @resourceWrongConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
#         }

#         It 'Test-TargetResource returns false' {
#             Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
#         }

#         It 'Set-TargetResource runs Set-RDCertificate' {
#             Set-TargetResource @resourceWrongConfiguredSplat
#             Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly -ParameterFilter {
#                 $Role -eq $resourceWrongConfiguredSplat.Role -and
#                 $ConnectionBroker -eq $resourceWrongConfiguredSplat.ConnectionBroker -and
#                 $ImportPath -eq $resourceWrongConfiguredSplat.ImportPath -and
#                 $Password -eq $resourceWrongConfiguredSplat.Credential.Password -and
#                 $Force -eq $true
#             }
#         }
#     }

#     Context 'When a wrong certificate is configured and the PFX file is protected based on group membership (ProtectTo)' {
#         Mock -CommandName Get-RDCertificate -MockWith {
#             [pscustomobject]@{
#                 Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
#                 Role       = 'RDGateway'
#             }
#         } -ParameterFilter { $Role -eq 'RDGateway' }

#         Mock -CommandName Get-PfxData -MockWith {
#             [pscustomobject]@{
#                 EndEntityCertificates = [pscustomobject]@{
#                     Thumbprint = '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8B'
#                 }
#             }
#         } -ParameterFilter { $ImportPath -eq 'testdrive:\RDGateway.pfx' }

#         $resourceWrongConfiguredSplat = @{
#             Role             = 'RDGateway'
#             ConnectionBroker = 'connectionbroker.lan'
#             ImportPath       = 'testdrive:\RDGateway.pfx'
#         }

#         It 'Get-TargetResource returns the thumbprint of the currently configured certificate' {
#             (Get-TargetResource @resourceWrongConfiguredSplat).Thumbprint | Should -Be '53086BBC44A3AB668A3B02CE0B258FEAEC1AFA8C'
#         }

#         It 'Test-TargetResource returns false' {
#             Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
#         }

#         It 'Set-TargetResource runs Set-RDCertificate without password' {
#             Set-TargetResource @resourceWrongConfiguredSplat
#             Assert-MockCalled -CommandName Set-RDCertificate -Times 1 -Exactly -ParameterFilter {
#                 $Role -eq $resourceWrongConfiguredSplat.Role -and
#                 $ConnectionBroker -eq $resourceWrongConfiguredSplat.ConnectionBroker -and
#                 $ImportPath -eq $resourceWrongConfiguredSplat.ImportPath -and
#                 $Force -eq $true
#             }
#         }
#     }

#     Context 'When a certificate fails to test' {
#         Mock Get-RDCertificate
#         Mock Get-PfxData -MockWith {
#             throw 'Cannot import PFX file'
#         }

#         $resourceWrongConfiguredSplat = @{
#             Role             = 'RDGateway'
#             ConnectionBroker = 'connectionbroker.lan'
#             ImportPath       = 'testdrive:\RDGateway.pfx'
#         }

#         It 'Test-TargetResource displays a warning when a certificate fails to test' {
#             $message = Test-TargetResource @resourceWrongConfiguredSplat 3>&1
#             $message | Should -Not -BeNullOrEmpty
#         }

#         It 'Test-TargetResource returns false' {
#             Test-TargetResource @resourceWrongConfiguredSplat | Should -BeFalse
#         }
#     }

#     Context 'When a certificate fails to set' {

#         Mock Set-RDCertificate -MockWith {
#             throw 'Failed to apply certificate'
#         }

#         $resourceWrongConfiguredSplat = @{
#             Role             = 'RDGateway'
#             ConnectionBroker = 'connectionbroker.lan'
#             ImportPath       = 'testdrive:\RDGateway.pfx'
#         }

#         It 'Set-TargetResource returns an error when the certificate could not be applied' {
#             { Set-TargetResource @resourceWrongConfiguredSplat -ErrorAction Stop } |
#                 Should -Throw 'Failed to apply certificate'
#         }
#     }
# }
