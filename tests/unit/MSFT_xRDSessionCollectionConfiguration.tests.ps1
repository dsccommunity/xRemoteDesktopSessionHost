$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDSessionCollectionConfiguration'

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
        $script:DSCResourceName    = 'MSFT_xRDSessionCollectionConfiguration'

        $testInvalidCollectionName = 'InvalidCollectionNameLongerThan15'
        $collectionName = 'TestCollection'
        
        Import-Module RemoteDesktop -Force

        
        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Mock -CommandName Set-RDSessionCollectionConfiguration -MockWith {
                $null
            }

            Mock -CommandName Get-RDSessionCollection -MockWith {
                [pscustomobject]@{
                    CollectionName = 'TestCollection'
                }
            }

            Mock -CommandName Get-RDSessionHost -MockWith {
                [pscustomobject]@{
                    SessionHost = [System.Net.Dns]::GetHostByName((hostname)).HostName
                    CollectionName = 'TestCollection'
                }
            }
            
            Mock -CommandName Get-RDSessionCollectionConfiguration
            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                [pscustomobject]@{
                    CollectionName           = 'TestCollection'
                    IncludeFolderPath        = $null
                    ExcludeFolderPath        = $null
                    IncludeFilePath          = $null
                    ExcludeFilePath          = $null
                    DiskPath                 = 'c:\temp'
                    EnableUserProfileDisk    = $true
                    MaxUserProfileDiskSizeGB = 5
                }
            } -ParameterFilter {$UserProfileDisk -eq $true}

            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Get-TargetResource -CollectionName $testInvalidCollectionName} `
                        | should throw
                }
            }

            Context "Get properties on Windows Server 2012 (R2)" {
                Mock -CommandName Get-CimInstance -MockWith {
                    [pscustomobject]@{
                        Version = '6.3.9600'
                    }
                }

                It "Should not call Get-RDSessionCollectionConfiguration with parameter UserProfileDisk" {
                    Get-TargetResource -CollectionName $collectionName
                    Assert-MockCalled -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter {$UserProfileDisk -eq $true} -Times 0 -Exactly
                }
                It "Should not call Set-RDSessionCollectionConfiguration" {
                    Assert-MockCalled -CommandName Set-RDSessionCollectionConfiguration -Times 0 -Exactly -Scope Context
                }
            }

            Context "Get properties on Windows Server 2016+" {
                Mock -CommandName Get-CimInstance -MockWith {
                    [pscustomobject]@{
                        Version = '10.0.14393'
                    }
                }

                $getTargetResourceResult = Get-TargetResource -CollectionName $collectionName
                It "Should call Get-RDSessionCollectionConfiguration with parameter UserProfileDisk" {
                    Assert-MockCalled -CommandName Get-RDSessionCollectionConfiguration -ParameterFilter {$UserProfileDisk -eq $true} -Times 1 -Exactly
                }
                It "Get-TargetResource result should list UserProfileDisk property <Property>" {
                    Param (
                        [string]$Property
                    )
                    $getTargetResourceResult.GetEnumerator().Name | Where-Object{$_ -eq $Property} | Should Be $Property
                } -TestCases @(
                    @{
                        Property = 'DiskPath'
                    }
                    @{
                        Property = 'EnableUserProfileDisk'
                    }
                    @{
                        Property = 'ExcludeFilePath'
                    }
                    @{
                        Property = 'ExcludeFolderPath'
                    }
                    @{
                        Property = 'IncludeFilePath'
                    }
                    @{
                        Property = 'IncludeFolderPath'
                    }
                    @{
                        Property = 'MaxUserProfileDiskSizeGB'
                    }
                )
                It "Should not call Set-RDSessionCollectionConfiguration" {
                    Assert-MockCalled -CommandName Set-RDSessionCollectionConfiguration -Times 0 -Exactly -Scope Context
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Set-TargetResource -CollectionName $testInvalidCollectionName} `
                        | should throw
                }
            }

        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Mock -CommandName Set-RDSessionCollectionConfiguration -MockWith {
                $null
            }

            Mock -CommandName Get-RDSessionCollection -MockWith {
                [pscustomobject]@{
                    CollectionName = 'TestCollection'
                }
            }

            Mock -CommandName Get-RDSessionHost -MockWith {
                [pscustomobject]@{
                    SessionHost = [System.Net.Dns]::GetHostByName((hostname)).HostName
                    CollectionName = 'TestCollection'
                }
            }

            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                [pscustomobject]@{
                    CollectionName = 'TestCollection'
                }
            }
            Mock -CommandName Get-RDSessionCollectionConfiguration -MockWith {
                [pscustomobject]@{
                    CollectionName           = 'TestCollection'
                    IncludeFolderPath        = $null
                    ExcludeFolderPath        = $null
                    IncludeFilePath          = $null
                    ExcludeFilePath          = $null
                    DiskPath                 = 'c:\temp'
                    EnableUserProfileDisk    = $false
                    MaxUserProfileDiskSizeGB = 5
                }
            } -ParameterFilter {$UserProfileDisk -eq $true}

            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    {Test-TargetResource -CollectionName $testInvalidCollectionName} `
                        | should throw
                }
            }

            Context "Running on test on Windows Server 2012 (R2)" {
                Mock -CommandName Get-CimInstance -MockWith {
                    [pscustomobject]@{
                        Version = '6.3.9600'
                    }
                }

                It "Running on Windows Server 2012 (R2) with EnableUserProfile disk set to True should ignore the EnableUserProfile property (Test returns True - In Desired State)" {
                    Test-TargetResource -CollectionName $collectionName -EnableUserProfileDisk $true | Should be $True
                }
            }

            Context "Running on test on Windows Server 2016 (or higher)" {
                Mock -CommandName Get-CimInstance -MockWith {
                    [pscustomobject]@{
                        Version = '10.0.14393'
                    }
                }

                It "Running on Windows Server 2016+ with EnableUserProfile disk set to True and current setting set to false should return Test result False - Not In Desired State" {
                    Test-TargetResource -CollectionName $collectionName -EnableUserProfileDisk $true | Should be $false
                }

                It "Running on Windows Server 2016+ with EnableUserProfile disk set to False and current setting set to false should return Test result True - In Desired State" {
                    Test-TargetResource -CollectionName $collectionName -EnableUserProfileDisk $false | Should be $True
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
