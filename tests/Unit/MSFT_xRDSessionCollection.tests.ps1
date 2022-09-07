$script:DSCModuleName      = 'xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDSessionCollection'

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
        $script:DSCResourceName    = 'MSFT_xRDSessionCollection'

        $testInvalidCollectionName = 'InvalidCollectionNameLongerThan256-12345678910111213141516171819202122232425262728142124124124awffjwifhw28qfhw27[q9aqfj2wai9fua29fua2fna29fja2fj29f2u192u4-[12fj2390fau2-9fu-9fu1-2ur1-2u149u2mfaweifjwifjw19wu-u2394u12-f2u1223fu-1f1239fy193413403mgjefas902311'

        $testCollection = @(
            @{
                Name        = 'TestCollection1'
                Description = 'Test Collection 1'
            }
            @{
                Name        = 'TestCollection2'
                Description = 'Test Collection 2'
            }
        )

        $testSessionHost = 'localhost'
        $testConnectionBroker = 'localhost.fqdn'

        $validTargetResourceCall = @{
            CollectionName =  $testCollection[0].Name
            SessionHost = $testSessionHost
            ConnectionBroker = $testConnectionBroker
        }

        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Mock -ParameterFilter { $CollectionName -and ($CollectionName -eq $testCollection[0].Name) } `
                -CommandName Get-RDSessionCollection {
                    $result = @()

                    foreach ($sessionCollection in $testCollection){
                        $result += @{
                            CollectionName = $sessionCollection.Name
                            CollectionDescription = $sessionCollection.Description
                            SessionHost = $testSessionHost
                            ConnectionBroker = $testConnectionBroker
                        }
                    }

                    return $result
                }

                Mock -ParameterFilter { $CollectionName -and ($CollectionName -eq 'TestCollection4') } `
                -CommandName Get-RDSessionCollection {
                    return @(
                        @{
                            CollectionName = 'TestCollection3'
                            CollectionDescription = 'Test Collection 3'
                            SessionHost = $testSessionHost
                            ConnectionBroker = $testConnectionBroker
                        }
                    )
                }

                Mock -ParameterFilter { $CollectionName -and ($CollectionName -eq 'TestCollection5') } `
                -CommandName Get-RDSessionCollection {
                    return $null
                }

            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    {Get-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }

                It 'Calls Get-RDSessionCollection with CollectionName and ConnectionBroker parameters' {
                    Get-TargetResource @validTargetResourceCall
                    Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope It -ParameterFilter {
                        $CollectionName -eq $testCollection[0].Name -and
                        $ConnectionBroker -eq $testConnectionBroker
                    }
                }
            }

            Context "None-existent Session Collection requested" {

                It "Should return empty result set when requested CollectionName does not match single existing Session Collection" {
                    $validTargetResourceCall.CollectionName = 'TestCollection4'
                    Get-TargetResource @validTargetResourceCall | Should BeNullOrEmpty
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    {Set-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }
            }

            Context 'Validate Set-TargetResource actions' {
                Mock -CommandName New-RDSessionCollection
                Mock -CommandName Add-RDSessionHost

                It 'Given the configuration is executed on the Connection Broker, New-RDSessionCollection is called' {
                    Set-TargetResource -CollectionName $testcollectionName -ConnectionBroker ([System.Net.Dns]::GetHostByName((hostname)).HostName) -SessionHost $testSessionHost
                    Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope It
                }

                It 'Given the configuration is not executed on the Connection Broker, Add-RDSessionHost is called' {
                    Set-TargetResource @validTargetResourceCall
                    Assert-MockCalled -CommandName Add-RDSessionHost -Times 1 -Scope It
                }

                It 'Given the configuration is not executed on the Connection Broker, and a description is passed, Add-RDSessionHost is called without the collection description' {
                    Set-TargetResource @validTargetResourceCall -CollectionDescription 'Pester Test Collection Output'
                    Assert-MockCalled -CommandName Add-RDSessionHost -Times 1 -Scope It
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    {Test-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }
            }

            Context 'Validating Test-TargetResource output' {
                Mock -CommandName Get-RDSessionCollection

                It 'Given Get-RDSessionCollection not returning a collection, test returns false' {
                    Test-TargetResource @validTargetResourceCall | Should Be $false
                }

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    [pscustomobject]@{
                        AutoAssignPersonalDesktop = $false
                        CollectionAlias = $testcollectionName
                        CollectionDescription = 'Pester Test Collection Output'
                        CollectionName = $testcollectionName
                        CollectionType = 'PooledUnmanaged'
                        GrantAdministrativePrivilege = $false
                        ResourceType = 'Remote Desktop'
                        Size = 1
                    }
                }

                It 'Given Get-RDSessionCollection returning a collection, test returns true' {
                    Test-TargetResource @validTargetResourceCall | Should Be $true
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
