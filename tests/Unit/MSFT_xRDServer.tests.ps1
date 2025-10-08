$script:DSCModuleName = 'xRemoteDesktopSessionHost'
$script:DSCResourceName = 'MSFT_xRDServer'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        $script:DSCResourceName = 'MSFT_xRDServer'

        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Mock -CommandName Get-RDServer -MockWith {
                [pscustomobject]@{
                    Server = 'connectionbroker.lan'
                    Roles  = @(
                        'RDS-CONNECTION-BROKER'
                    )
                }
            }

            Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                [pscustomobject]@{
                    GatewayExternalFqdn = 'testgateway.external.fqdn'
                }
            }

            It 'Given a server that does not exist in the deployment, Get returns nothing' {
                Get-TargetResource -Server does.not.exist -ConnectionBroker connectionbroker.lan -Role RDS-Connection-Broker | Should BeNullOrEmpty
            }

            $getResult = Get-TargetResource -Server connectionbroker.lan -ConnectionBroker connectionbroker.lan -Role RDS-Connection-Broker
            It 'Given a server connectionbroker.lan with the role RDS-CONNECTION-BROKER in the deployment, get returns property <Property> for this server' {
                param (
                    [string]$Property
                )

                $getResult.$Property | Should Not BeNullOrEmpty
            } -TestCases @(
                @{
                    Property = 'ConnectionBroker'
                }
                @{
                    Property = 'Server'
                }
                @{
                    Property = 'Role'
                }
            )

            Mock -CommandName Get-RDServer -MockWith {
                [pscustomobject]@{
                    Server = 'connectionbroker.lan'
                    Roles  = @(
                        'RDS-CONNECTION-BROKER'
                        'RDS-GATEWAY'
                    )
                }
            }

            $getResult = Get-TargetResource -ConnectionBroker connectionbroker.lan -Server connectionbroker.lan -Role RDS-Gateway
            It 'Given a server with gateway role, the External Gateway FQDN is returned by Get' {
                $getResult.GatewayExternalFqdn | Should Be 'testgateway.external.fqdn'
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Mock -CommandName Get-RDServer -MockWith {

                if ($Role -eq 'RDS-Connection-Broker')
                {
                    [pscustomobject]@{
                        Server = 'connectionbroker.lan'
                        Roles  = @(
                            'RDS-CONNECTION-BROKER'
                        )
                    }
                }
            }

            Mock -CommandName Get-RDDeploymentGatewayConfiguration -MockWith {
                [pscustomobject]@{
                    GatewayExternalFqdn = 'testgateway.external.fqdn'
                }
            }

            It 'Given a new server in the deployment, test returns false' {
                Test-TargetResource -Server does.not.exist -ConnectionBroker connectionbroker.lan -Role RDS-Connection-Broker | Should be $false
            }

            It 'Given an existing server in the deployment, but with an unassigned role, test returns false' {
                Test-TargetResource -Server connectionbroker.lan -ConnectionBroker connectionbroker.lan -Role RDS-Gateway | Should be $false
            }

            It 'Given an existing server in the deployment, with an existing role, test returns true' {
                Test-TargetResource -Server connectionbroker.lan -ConnectionBroker connectionbroker.lan -Role RDS-Connection-Broker | Should be $true
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context 'Parameter Values,Validations and Errors' {

                It 'Should error when if role is RDS-Gateway and GatewayExternalFqdn is missing.' {
                    { Set-TargetResource -ConnectionBroker 'connectionbroker.lan' -Server 'server1' -Role 'RDS-Gateway' } `
                    | Should throw
                }
            }
        }
        #endregion

    }
}
finally
{
    Invoke-TestCleanup
}
