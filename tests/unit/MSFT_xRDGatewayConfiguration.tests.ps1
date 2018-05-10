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

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when if GatewayMode is Custom and a parameter is missing." {
                    {Set-TargetResource -ConnectionBroker "connectionbroker.lan" -GatewayMode "Custom"} `
                        | should throw
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
