$script:DSCModuleName = 'xRemoteDesktopSessionHost'
$script:DSCResourceName = 'MSFT_xRDConnectionBrokerHAMode'

#region HEADER

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
        $script:DSCResourceName = 'MSFT_xRDConnectionBrokerHAMode'

        #region Function Get-TargetResource
        Describe "Testing $($script:DSCResourceName)" {
            Mock -CommandName Import-Module -MockWith {} -ParameterFilter { $Name -eq 'RemoteDesktop' }

            Mock -CommandName Set-RDConnectionBrokerHighAvailability -ParameterFilter { $ClientAccessName -eq 'rdsfarm.contoso.com' }

            Context 'Connection Broker not in HA mode' {

                Mock -CommandName Get-RDConnectionBrokerHighAvailability -MockWith {
                    [pscustomobject]@{
                        ConnectionBroker         = 'RDCB1'
                        ActiveManagementServer   = ''
                        ClientAccessName         = ''
                        DatabaseConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    }
                } -ParameterFilter {
                    $ConnectionBroker -eq 'RDCB1' -and
                    $DatabaseConnectionString -eq 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS' -and
                    $ClientAccessName -eq 'rdsfarm.contoso.com'
                }

                $resourceNotConfiguredSplat = @{
                    ConnectionBroker                  = 'RDCB1'
                    DatabaseConnectionString          = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    DatabaseSecondaryConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1.contoso.com;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    ClientAccessName                  = 'rdsfarm.contoso.com'
                }

                It 'Get-TargetResource returns no active management server' {
                    (Get-TargetResource @resourceNotConfiguredSplat).ActiveManagementServer | Should -BeNullOrEmpty
                }

                It 'Test-TargetResource returns false' {
                    Test-TargetResource @resourceNotConfiguredSplat | Should -BeFalse
                }

                It 'Set-TargetResource runs Set-RDConnectionBrokerHighAvailability' {
                    Set-TargetResource @resourceNotConfiguredSplat
                    Assert-MockCalled -CommandName Set-RDConnectionBrokerHighAvailability -Times 1 -Exactly -ParameterFilter {
                        $ConnectionBroker -eq 'RDCB1' -and
                        $DatabaseConnectionString -eq 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS' -and
                        $ClientAccessName -eq 'rdsfarm.contoso.com'
                    }
                }
            }

            Context 'Connection Broker in HA mode' {

                Mock -CommandName Get-RDConnectionBrokerHighAvailability -MockWith {
                    [pscustomobject]@{
                        ConnectionBroker         = 'RDCB1'
                        ActiveManagementServer   = 'RDCB1'
                        ClientAccessName         = 'rdsfarm.contoso.com'
                        DatabaseConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    }
                } -ParameterFilter { $ConnectionBroker -eq 'RDCB1' }

                $resourceConfiguredSplat = @{
                    ConnectionBroker         = 'RDCB1'
                    DatabaseConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
                    ClientAccessName         = 'rdsfarm.contoso.com'
                }

                It 'Get-TargetResource returns an active management server' {
                    (Get-TargetResource @resourceConfiguredSplat).ActiveManagementServer | Should -Be $resourceConfiguredSplat.ConnectionBroker
                }

                It 'Test-TargetResource returns true' {
                    Test-TargetResource @resourceConfiguredSplat | Should -BeTrue
                }
            }
        }
    }
}
finally
{
    #region FOOTER
    Invoke-TestCleanup
    #endregion
}
