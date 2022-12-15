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

        $testSessionHost      = 'localhost'
        $testConnectionBroker = 'localhost.fqdn'

        $validTargetResourceCall = @{
            CollectionName   = $testCollection[0].Name
            SessionHost      = $testSessionHost
            ConnectionBroker = $testConnectionBroker
        }

        $nonExistentTargetResourceCall1 = @{
            CollectionName   = 'TestCollection4'
            SessionHost      = $testSessionHost
            ConnectionBroker = $testConnectionBroker
        }

        $nonExistentTargetResourceCall2 = @{
            CollectionName   = 'TestCollection5'
            SessionHost      = $testSessionHost
            ConnectionBroker = $testConnectionBroker
        }

        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    {Get-TargetResource -CollectionName $testInvalidCollectionName -SessionHost $testSessionHost} | Should throw
                }

                Mock -CommandName Get-RDSessionCollection {
                    $result = @()

                    foreach ($sessionCollection in $testCollection)
                    {
                        $result += New-Object -TypeName PSObject -Property @{
                            CollectionName        = $sessionCollection.Name
                            CollectionDescription = $sessionCollection.Description
                            SessionHost           = $testSessionHost
                            ConnectionBroker      = $testConnectionBroker
                        }
                    }

                    return $result
                }

                It 'Calls Get-RDSessionCollection with CollectionName and ConnectionBroker parameters' {
                    Get-TargetResource @validTargetResourceCall
                    Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope It -ParameterFilter {
                        $CollectionName -eq $testCollection[0].Name -and
                        $ConnectionBroker -eq $testConnectionBroker
                    }
                }
            }

            Context "Non-existent Session Collection requested (other session collections returned - Win2019 behaviour)" {

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    [pscustomobject]@{
                        CollectionName        = 'TestCollection3'
                        CollectionDescription = 'Test Collection 3'
                        SessionHost           = $testSessionHost
                        ConnectionBroker      = $testConnectionBroker
                    }
                }

                $result = Get-TargetResource @nonExistentTargetResourceCall1
                It "Should return return a hash table" {
                    $result | Should -BeOfType System.Collections.Hashtable
                }

                It 'Should return supplied session host, with other values being $null' {
                    $result.ConnectionBroker      = $null
                    $result.CollectionName        = $null
                    $result.CollectionDescription = $null
                    $result.SessionHost           = $testSessionHost
                }
            }

            Context "Non-existent Session Collection requested (no session collections returned - normal behaviour)" {

                Mock -CommandName Get-RDSessionCollection {
                    return $null
                }

                $result = Get-TargetResource @nonExistentTargetResourceCall2
                It "Should return return a hash table (Win 2019)" {
                    $result | Should -BeOfType System.Collections.Hashtable
                }

                It 'Should return supplied session host, with other values being $null' {
                    $result.ConnectionBroker      = $null
                    $result.CollectionName        = $null
                    $result.CollectionDescription = $null
                    $result.SessionHost           = $testSessionHost
                }
            }


            Context "Two Session Collections exist with same CollectionName" {
                Mock -CommandName Get-RDSessionCollection {
                    $result = @()

                    foreach ($sessionCollection in $testCollection)
                    {
                        $result += New-Object -TypeName PSObject -Property @{
                            CollectionName        = $testCollection[0].Name
                            CollectionDescription = $sessionCollection.Description
                            SessionHost           = $testSessionHost
                            ConnectionBroker      = $testConnectionBroker
                        }
                    }

                    return $result
                }

                It "should throw exception" {
                    { Get-TargetResource @validTargetResourceCall } | Should throw
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

            Mock -CommandName Get-RDSessionCollection -MockWith {
                [PSCustomObject]@{
                    CollectionName        = $testCollection[0].Name
                    CollectionDescription = 'Test Collection'
                    SessionHost           = $testSessionHost
                    ConnectionBroker      = $testConnectionBroker
                }
            }

            Context 'Validate Set-TargetResource actions' {
                Mock -CommandName New-RDSessionCollection

                It 'Given the configuration is applied, New-RDSessionCollection and Get-RDSessionCollection are called' {
                    Set-TargetResource -CollectionName $testCollection[0].Name -ConnectionBroker $testConnectionBroker -SessionHost $testSessionHost
                    Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope Context
                    Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope Describe
                }
            }

            Context 'Errors thrown by New-RDSessionCollection are ignored' {
                Mock -CommandName New-RDSessionCollection -MockWith {
                    if ($ErrorActionPreference -ne 'SilentlyContinue')
                    {
                        throw 'The property EncryptionLevel is configured by using Group Policy settings. Use the Group Policy Management Console to configure this property.'
                    }
                }

                It 'Given the configuration is applied, New-RDSessionCollection and Get-RDSessionCollection are called' {
                    Set-TargetResource -CollectionName $testCollection[0].Name -ConnectionBroker $testConnectionBroker -SessionHost $testSessionHost
                    Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope Context
                    Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope Describe
                }
            }

            Context 'Get-RDSessionCollection returning empty result set after calling New-RDSessionCollection' {
                Mock -CommandName New-RDSessionCollection
                Mock -CommandName Get-RDSessionCollection {
                    return $null
                }

                $exceptionMessage = ( '''Get-RDSessionCollection -CollectionName {0} -ConnectionBroker {1}'' returns empty result set after call to ''New-RDSessionCollection''' -f $testCollection[0].Name,$testConnectionBroker )

                It 'throws an exception' {
                    {
                        Set-TargetResource -CollectionName $testCollection[0].Name -ConnectionBroker $testConnectionBroker -SessionHost $testSessionHost
                    } | should throw $exceptionMessage

                    Assert-MockCalled -CommandName New-RDSessionCollection -Times 1 -Scope Context
                    Assert-MockCalled -CommandName Get-RDSessionCollection -Times 1 -Scope Describe
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
                        AutoAssignPersonalDesktop    = $false
                        CollectionAlias              = $testCollection[0].Name
                        CollectionDescription        = 'Pester Test Collection Output'
                        CollectionName               = $testCollection[0].Name
                        CollectionType               = 'PooledUnmanaged'
                        GrantAdministrativePrivilege = $false
                        ResourceType                 = 'Remote Desktop'
                        Size                         = 1
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
