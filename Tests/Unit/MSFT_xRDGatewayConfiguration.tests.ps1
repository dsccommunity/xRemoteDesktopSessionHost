$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDGatewayConfiguration'

#region HEADER

# Unit Test Template Version: 1.2.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Write-Output @('clone','https://github.com/PowerShell/DscResource.Tests.git',"'"+(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests')+"'")

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'),'--verbose')
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup {

}

function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment

}

# Begin Testing

try
{
    Invoke-TestSetup

    InModuleScope $script:DSCResourceName {
        $script:DSCResourceName    = 'MSFT_xRDGatewayConfiguration'
        
        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            
            Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                [pscustomobject]@{
                    ConnectionBroker = 'testbroker.fqdn'
                    Gatewaymode = 'DoNotUse' 
                }
            }

            It 'Given Gatway Configuration is DoNotUse Get-TargetResource returns GatewayMode DoNotUse' {
                (Get-TargetResource -ConnectionBroker testbroker.fqdn).GatewayMode | Should Be 'DoNotUse'
            }

            Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                [pscustomobject]@{
                    Gatewaymode = 'Custom' 
                    GatewayExternalFqdn = 'testgateway.external.fqdn'
                    BypassLocal = $true
                    ConnectionBroker = 'testbroker.fqdn'
                    LogonMethod = 'Password' 
                    UseCachedCredentials = $true
                }
            }

            $getResult = Get-TargetResource -ConnectionBroker testbroker.fqdn
            It 'Given a configured gateway, Get-TargetResource outputs property <property>' {
                param(
                    [string]$Property
                )

                $getResult.$property | Should Not BeNullOrEmpty
            } -TestCases @(
                @{
                    Property = 'GatewayExternalFqdn'
                }
                @{
                    Property = 'BypassLocal'
                }
                @{
                    Property = 'LogonMethod'
                }
                @{
                    Property = 'UseCachedCredentials'
                }
            )
        }
        
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            
            Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                [pscustomobject]@{
                    ConnectionBroker = 'testbroker.fqdn'
                    Gatewaymode = 'DoNotUse' 
                }
            }
            
            $testSplat = @{
                ConnectionBroker = 'testbroker.fqdn'
                GatewayMode = 'DoNotUse'
                ExternalFqdn = 'testgateway.external.fqdn'
                BypassLocal = $true
                LogonMethod = 'Password' 
                UseCachedCredentials = $true
            }
            
            It 'Given configured GateWayMode DoNotUse and desired GateWayMode DoNotUse test returns true' {
                Test-TargetResource @testSplat | Should be $true
            }
            
            $testSplat.GatewayMode = 'Custom'
            It 'Given configured GateWayMode DoNotUse and desired GateWayMode Custom test returns false' {
                Test-TargetResource @testSplat | Should be $false
            }
            
            Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                [pscustomobject]@{
                    Gatewaymode = 'Custom' 
                    GatewayExternalFqdn = 'testgateway.external.fqdn'
                    BypassLocal = $true
                    ConnectionBroker = 'testbroker.fqdn'
                    LogonMethod = 'Password' 
                    UseCachedCredentials = $true
                }
            }
            
            $testSplat.LogonMethod = 'AllowUserToSelectDuringConnection'
            It 'Given configured GateWayMode Custom and desired GateWayMode Custom, with desired LogonMethod AllowUserToSelectDuringConnection and current LogonMethod Password, test returns false' {
                Test-TargetResource @testSplat | Should be $false
            }
            
            $testSplat.LogonMethod = 'Password'
            $testSplat.ExternalFqdn = 'testgateway.new.external.fqdn'
            It 'Given configured GateWayMode Custom and desired GateWayMode Custom, with different GatewayExternalFqdn, test returns false' {
                Test-TargetResource @testSplat | Should be $false
            }
            
            $testSplat.ExternalFqdn = 'testgateway.external.fqdn'
            $testSplat.BypassLocal = $false
            It 'Given configured GateWayMode Custom and desired GateWayMode Custom, with desired BypassLocal false and current BypassLocal true, test returns false' {
                Test-TargetResource @testSplat | Should be $false
            }
            
            $testSplat.BypassLocal = $true
            $testSplat.UseCachedCredentials = $false
            It 'Given configured GateWayMode Custom and desired GateWayMode Custom, with desired UseCachedCredentials false and current UseCachedCredentials true, test returns false' {
                Test-TargetResource @testSplat | Should be $false
            }
            
            $testSplat.UseCachedCredentials = $true
            It 'Given configured GateWayMode Custom and desired GateWayMode Custom, with all properties validated, test returns true' {
                Test-TargetResource @testSplat | Should be $true
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when if GatewayMode is Custom and a parameter is missing." {
                    {Set-TargetResource -ConnectionBroker "connectionbroker.lan" -GatewayMode "Custom"} | should throw
                }
            }
            
            $setSplat = @{
                ConnectionBroker = 'testbroker.fqdn'
                GatewayServer = 'my.gateway.fqdn'
                GatewayMode = 'Custom'
                ExternalFqdn = 'testgateway.external.fqdn'
                BypassLocal = $true
                LogonMethod = 'Password' 
                UseCachedCredentials = $true
            }
            
            Context "Configuration changes performed by Set" {
            
                Mock -CommandName Get-RDServer -MockWith {
                    [pscustomobject]@{
                        Server = 'my.gateway.fqdn'
                        Roles = @(
                            'RDS-WEB-ACCESS', 
                            'RDS-GATEWAY'
                        )
                    }
                }
                Mock -CommandName Add-RDServer
                Mock -CommandName Set-RdDeploymentGatewayConfiguration
                
                It 'Given the role RDS-GATEWAY is already installed, Add-RDServer is not called' {
                    Set-TargetResource @setSplat
                    Assert-MockCalled -CommandName Add-RDServer -Times 0 -Scope It
                }
                
                Mock -CommandName Get-RDServer -MockWith {
                    [pscustomobject]@{
                        Server = 'testbroker.fqdn'
                        Roles = @(
                            'RDS-WEB-ACCESS'
                        )
                    }
                }
                It 'Given the role RDS-GATEWAY is missing, Add-RDServer is called' {
                    Set-TargetResource @setSplat
                    Assert-MockCalled -CommandName Add-RDServer -Times 1 -Scope It
                }
                
                It 'Given GateWayMode Custom, Set-RdDeploymentGatewayConfiguration is called with all required parameters' {
                    Set-TargetResource @setSplat
                    Assert-MockCalled -CommandName Set-RdDeploymentGatewayConfiguration -Times 1 -Scope It -ParameterFilter {
                        $ConnectionBroker -eq 'testbroker.fqdn' -and
                        $GatewayMode -eq 'Custom' -and
                        $GatewayExternalFqdn -eq 'testgateway.external.fqdn' -and
                        $LogonMethod -eq 'Password' -and
                        $UseCachedCredentials -eq $true -and
                        $BypassLocal -eq $true -and
                        $Force -eq $true                  
                    }
                }
                
                $setSplat.GatewayMode = 'DoNotUse'
                It 'Given GateWayMode DoNotUse, Set-RdDeploymentGatewayConfiguration is called with only ConnectionBroker, Gatewaymode and Force parameters' {
                    Set-TargetResource @setSplat
                    Assert-MockCalled -CommandName Set-RdDeploymentGatewayConfiguration -Times 1 -Scope It -ParameterFilter {
                        $ConnectionBroker -eq 'testbroker.fqdn' -and
                        $GatewayMode -eq 'DoNotUse' -and
                        $Force -eq $true                      
                    }
                }
            }
        }
        #endregion

    }
}
finally
{
    #region FOOTER
    Invoke-TestCleanup
    #endregion
}
