$script:DSCModuleName      = 'xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDRemoteApp'

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
        $script:DSCResourceName    = 'MSFT_xRDRemoteApp'

        $testInvalidCollectionName = 'InvalidCollectionNameLongerThan256-12345678910111213141516171819202122232425262728142124124124awffjwifhw28qfhw27[q9aqfj2wai9fua29fua2fna29fja2fj29f2u192u4-[12fj2390fau2-9fu-9fu1-2ur1-2u149u2mfaweifjwifjw19wu-u2394u12-f2u1223fu-1f1239fy193413403mgjefas902311'
        $testInvalidCollectionSplat = @{
            CollectionName = $testInvalidCollectionName
            DisplayName = 'name'
            FilePath = 'path'
            Alias = 'alias'
        }

        $sourceRemoteAppValues = @{
            CollectionName      = 'TestCollection'
            DisplayName         = 'MyCalc (1.0.0)'
            FilePath            = 'c:\windows\system32\calc.exe'
            Alias               = 'Test-MyCalc-(1.0.0)'
            Ensure              = 'Present'
            FileVirtualPath     = 'c:\windows\system32\calc.exe'
            FolderName          = 'Test'
            CommandLineSetting  = 'DoNotAllow'
            RequiredCommandLine = 'my-cmd'
            IconIndex           = 0
            IconPath            = 'c:\windows\system32\calc.exe'
            UserGroups          = 'DOMAIN\MyAppGroup_DLG'
            ShowInWebAccess     = $true
        }

        $xRDRemoteAppSplat = $sourceRemoteAppValues.Clone()

        $getRDRemoteApp = $xRDRemoteAppSplat.Clone()
        $null = $getRDRemoteApp.Remove('Ensure')

        Import-Module RemoteDesktop -Force

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    { Get-TargetResource @testInvalidCollectionSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'Invalid'
                It 'Should only accept valid values for CommandLineSetting' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = $sourceRemoteAppValues.CommandLineSetting
            }

            Context "When Get-TargetResource is called" {

                Mock -CommandName Get-RDRemoteApp
                Mock -CommandName Get-RDSessionCollection

                It 'Should return Ensure Absent, given the RemoteApp is not created yet' {
                    (Get-TargetResource @xRDRemoteAppSplat).Ensure | Should Be 'Absent'
                }

                Mock -CommandName Get-RDRemoteApp -MockWith {
                    $getRDRemoteApp
                }

                It 'Should return Ensure Present, given the RemoteApp is created' {
                    (Get-TargetResource @xRDRemoteAppSplat).Ensure | Should Be 'Present'
                }

                $userGroups = @('DOMAIN\RemoteApp_UserGroup1', 'DOMAIN\RemoteApp_UserGroup2')
                $xRDRemoteAppSplat.UserGroups = $userGroups
                It 'Should not generate an error, given that an array of UserGroups was specified' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should -Not -Throw
                }
                $xRDRemoteAppSplat.UserGroups = $sourceRemoteAppValues.UserGroups

                [System.Array] $commonParameters = [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
                $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

                $allParameters = (Get-Command Get-TargetResource).Parameters.Keys |
                    Where-Object -FilterScript { $_ -notin $commonParameters} |
                    ForEach-Object -Process {
                        @{
                            Property = $_
                            Value = $xRDRemoteAppSplat[$_]
                        }
                    }

                $getTargetResourceResult = Get-TargetResource @xRDRemoteAppSplat
                It 'Should return property <Property> with value <Value> in Get-TargetResource' {
                    Param(
                        $Property,
                        $Value
                    )

                    $getTargetResourceResult.$Property | Should Be $Value
                } -TestCases $allParameters

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    Write-Error 'Collection not found!'
                }

                It 'Should generate an error, given that the CollectionName is not found in the SessionDeployment' {
                    { Get-TargetResource @xRDRemoteAppSplat -ErrorAction Stop } |
                        Should -Throw 'Failed to lookup RD Session Collection TestCollection. Error: Collection not found!'
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    { Set-TargetResource @testInvalidCollectionSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'Invalid'
                It 'Should only accept valid values for CommandLineSetting' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = $sourceRemoteAppValues.CommandLineSetting
            }

            Context 'When Set-TargetResource actions are performed' {

                Mock -CommandName Get-RDSessionCollection
                Mock -CommandName Get-RDRemoteApp
                Mock -CommandName New-RDRemoteApp
                Mock -CommandName Remove-RDRemoteApp
                Mock -CommandName Set-RDRemoteApp

                It 'Should call New-RDRemoteApp, given that the RemoteApp does not exist yet and Ensure is set to Present' {
                    Set-TargetResource @xRDRemoteAppSplat
                    Assert-MockCalled -CommandName New-RDRemoteApp -Times 1 -Scope It
                }

                Mock -CommandName Get-RDRemoteApp -MockWith { $getRDRemoteApp }

                It 'Should call Set-RDRemoteApp, given that the RemoteApp does exist and Ensure is set to Present' {
                    Set-TargetResource @xRDRemoteAppSplat
                    Assert-MockCalled -CommandName Set-RDRemoteApp -Times 1 -Scope It
                }

                $userGroups = @('DOMAIN\RemoteApp_UserGroup1', 'DOMAIN\RemoteApp_UserGroup2')
                $xRDRemoteAppSplat.UserGroups = $userGroups
                It 'Should not generate an error, given that an array of UserGroups was specified' {
                    { Set-TargetResource @xRDRemoteAppSplat } | Should -Not -Throw
                }
                $xRDRemoteAppSplat.UserGroups = $sourceRemoteAppValues.UserGroups

                $xRDRemoteAppSplat.Ensure = 'Absent'
                It 'Should call Remove-RDRemoteApp, given that the RemoteApp exists and Ensure is set to Absent' {
                    Set-TargetResource @xRDRemoteAppSplat
                    Assert-MockCalled -CommandName Remove-RDRemoteApp -Times 1 -Scope It
                }
                $xRDRemoteAppSplat.Ensure = $sourceRemoteAppValues.Ensure

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    Write-Error 'Collection not found!'
                }

                It 'Should generate an error, given that the CollectionName is not found in the SessionDeployment' {
                    { Set-TargetResource @xRDRemoteAppSplat -ErrorAction Stop } |
                        Should -Throw 'Failed to lookup RD Session Collection TestCollection. Error: Collection not found!'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 256" {
                    { Test-TargetResource @testInvalidCollectionSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'Invalid'
                It 'Should only accept valid values for CommandLineSetting' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = $sourceRemoteAppValues.CommandLineSetting
            }

            Context 'Test output validation' {
                Mock -CommandName Get-RDSessionCollection
                Mock -CommandName Get-RDRemoteApp

                It 'Should return false, given that the RemoteApp does not exist yet and Ensure is set to Present' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }

                Mock -CommandName Get-RDRemoteApp -MockWith {
                    $getRDRemoteApp
                }

                It 'Should return true, given that the RemoteApp does exist and Ensure is set to Present' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $true
                }

                $xRDRemoteAppSplat.Ensure = 'Absent'
                It 'Should return false, given that the RemoteApp exists and Ensure is set to Absent' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }
                $xRDRemoteAppSplat.Ensure = $sourceRemoteAppValues.Ensure

                $userGroups = @('DOMAIN\RemoteApp_UserGroup1', 'DOMAIN\RemoteApp_UserGroup2')
                $xRDRemoteAppSplat.UserGroups = $userGroups
                It 'Should not generate an error, given that an array of UserGroups was specified' {
                    { Test-TargetResource @xRDRemoteAppSplat } | Should -Not -Throw
                }

                It 'Should return false, due to a mismatch in UserGroups' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }

                $getRDRemoteApp.UserGroups = $userGroups
                Mock -CommandName Get-RDRemoteApp -MockWith {
                    $getRDRemoteApp
                }

                It 'Should return true, given that the comparison of UserGroups arrays succeeds' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $true
                }
                $xRDRemoteAppSplat.UserGroups = $sourceRemoteAppValues.UserGroups
                $getRDRemoteApp.UserGroups = $sourceRemoteAppValues.UserGroups

                $getRDRemoteApp.CommandLineSetting = 'Allow'
                Mock -CommandName Get-RDRemoteApp -MockWith {
                    $getRDRemoteApp
                }

                It 'Should return false, given that the RemoteApp exists and Ensure is set to Present and a single setting is misconfigured' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    Write-Error 'Collection not found!'
                }

                It 'Should generate an error, given that the CollectionName is not found in the SessionDeployment' {
                    { Test-TargetResource @xRDRemoteAppSplat -ErrorAction Stop } |
                        Should -Throw 'Failed to lookup RD Session Collection TestCollection. Error: Collection not found!'
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
