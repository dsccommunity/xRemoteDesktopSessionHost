# $script:DSCModuleName = 'xRemoteDesktopSessionHost'
# $script:DSCResourceName = 'MSFT_xRDLicenseConfiguration'

# function Invoke-TestSetup
# {
#     try
#     {
#         Import-Module -Name DscResource.Test -Force
#     }
#     catch [System.IO.FileNotFoundException]
#     {
#         throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
#     }

#     $script:testEnvironment = Initialize-TestEnvironment `
#         -DSCModuleName $script:dscModuleName `
#         -DSCResourceName $script:dscResourceName `
#         -ResourceType 'Mof' `
#         -TestType 'Unit'
# }

# function Invoke-TestCleanup
# {
#     Restore-TestEnvironment -TestEnvironment $script:testEnvironment
# }

# Invoke-TestSetup

# try
# {
#     InModuleScope $script:dscResourceName {
#         $script:DSCResourceName = 'MSFT_xRDLicenseConfiguration'

#         Import-Module RemoteDesktop -Force

#         #region Function Get-TargetResource
#         Describe "$($script:DSCResourceName)\Get-TargetResource" {
#             Context 'Parameter Values,Validations and Errors' {
#                 Mock Get-RDLicenseConfiguration -MockWith { return $null }
#                 It 'Should error if unable to get RD License config.' {
#                     { Get-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode 'NotConfigured' } | Should throw
#                 }
#             }
#         }
#         #endregion

#         #region Function Test-TargetResource
#         Describe "$($script:DSCResourceName)\Test-TargetResource" {
#             Context 'Parameter Values,Validations and Errors' {

#                 Mock -CommandName Get-TargetResource -MockWith {
#                     return @{
#                         'ConnectionBroker' = 'connectionbroker.lan'
#                         'LicenseServer'    = @('One', 'Two')
#                         'LicenseMode'      = 'PerUser'
#                     }
#                 } -ModuleName MSFT_xRDLicenseConfiguration

#                 It "Should return false if there's a change in license servers." {
#                     Test-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode 'PerUser' -LicenseServer 'One' | Should Be $false
#                 }

#                 Mock Get-TargetResource -MockWith {
#                     return @{
#                         'ConnectionBroker' = 'connectionbroker.lan'
#                         'LicenseServer'    = @('One', 'Two')
#                         'LicenseMode'      = 'PerUser'
#                     }
#                 }

#                 It "Should return false if there's a change in license mode." {
#                     Test-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode 'PerDevice' -LicenseServer @('One', 'Two') | Should Be $false
#                 }

#                 It 'Should return true if there are no changes in license mode.' {
#                     Test-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode 'PerUser' -LicenseServer @('One', 'Two') | Should Be $true
#                 }
#             }
#         }
#         #endregion

#         #region Function Set-TargetResource
#         Describe "$($script:DSCResourceName)\Set-TargetResource" {

#             Context 'Configuration changes performed by Set' {

#                 Mock -CommandName Set-RDLicenseConfiguration

#                 It 'Given license servers, Set-RDLicenseConfiguration is called with LicenseServer parameter' {
#                     Set-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode PerDevice -LicenseServer 'LicenseServer1'
#                     Assert-MockCalled -CommandName Set-RDLicenseConfiguration -Times 1 -ParameterFilter {
#                         $LicenseServer -eq 'LicenseServer1'
#                     }
#                 }

#                 It 'Given no license servers, Set-RDLicenseConfiguration is called without LicenseServer parameter' {
#                     Set-TargetResource -ConnectionBroker 'connectionbroker.lan' -LicenseMode PerDevice
#                     Assert-MockCalled -CommandName Set-RDLicenseConfiguration -Times 1 -ParameterFilter {
#                         $LicenseServer -eq $null
#                     } -Scope It
#                 }
#             }
#         }
#         #endregion
#     }
# }
# finally
# {
#     Invoke-TestCleanup
# }
