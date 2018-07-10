$script:DSCModuleName      = '.\xRemoteDesktopSessionHost'
$script:DSCResourceName    = 'MSFT_xRDRemoteApp'

#region HEADER

# Unit Test Template Version: 1.2.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Write-Output @('clone','https://github.com/PowerShell/DscResource.Tests.git',"'"+(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests')+"'")

if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or
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
        $script:DSCResourceName    = 'MSFT_xRDRemoteApp'

        $testInvalidCollectionName = 'InvalidCollectionNameLongerThan15'
        $testInvalidCollectionSplat = @{
            CollectionName = $testInvalidCollectionName
            DisplayName = 'name'
            FilePath = 'path'
            Alias = 'alias'
        }

        $xRDRemoteAppSplat = @{
            CollectionName = 'TestCollection'
            DisplayName = 'MyCalc (1.0.0)'
            FilePath = 'c:\windows\system32\calc.exe'
            Alias = 'Test-MyCalc-(1.0.0)'
            Ensure = 'Present'
            FileVirtualPath = 'c:\windows\system32\calc.exe'
            FolderName = 'Test'
            CommandLineSetting = 'DoNotAllow'
            RequiredCommandLine = 'my-cmd'
            IconIndex = 0
            IconPath = 'c:\windows\system32\calc.exe'
            UserGroups = 'DOMAIN\MyAppGroup_DLG'
            ShowInWebAccess = $true
        }

        Import-Module RemoteDesktop -Force
        
        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    { Get-TargetResource @testInvalidCollectionSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'Invalid'
                It 'Does only accept valid values for CommandLineSetting' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'DoNotAllow'
            }

            Context "Get output validation" {
                
                Mock -CommandName Get-RDRemoteApp
                Mock -CommandName Get-RDSessionCollection

                It 'Given the RemoteApp is not created yet, get returns Absent' {
                    (Get-TargetResource @xRDRemoteAppSplat).Ensure | Should Be 'Absent'
                }

                Mock -CommandName Get-RDRemoteApp -MockWith {
                    @{
                        CollectionName = 'TestCollection'
                        DisplayName = 'MyCalc (1.0.0)'
                        FilePath = 'c:\windows\system32\calc.exe'
                        Alias = 'Test-MyCalc-(1.0.0)'
                        FileVirtualPath = 'c:\windows\system32\calc.exe'
                        FolderName = 'Test'
                        CommandLineSetting = 'DoNotAllow'
                        RequiredCommandLine = 'my-cmd'
                        IconIndex = 0
                        IconPath = 'c:\windows\system32\calc.exe'
                        UserGroups = 'DOMAIN\MyAppGroup_DLG'
                        ShowInWebAccess = $true
                    }
                }

                It 'Given the RemoteApp is created, get returns Present' {
                    (Get-TargetResource @xRDRemoteAppSplat).Ensure | Should Be 'Present'
                }

                $excludeParameters = @(
                    'Verbose'
                    'Debug'
                    'ErrorAction'
                    'WarningAction'
                    'InformationAction'
                    'ErrorVariable'
                    'WarningVariable'
                    'InformationVariable'
                    'OutVariable'
                    'OutBuffer'
                    'PipelineVariable'
                )

                $allParameters = (Get-Command Get-TargetResource).Parameters.Keys | Where-Object{$_ -notin $excludeParameters} | ForEach-Object {
                    @{
                        Property = $_
                        Value = $xRDRemoteAppSplat[$_]
                    }
                }

                $get = Get-TargetResource @xRDRemoteAppSplat
                It 'Get returns property <Property> with value <Value>' {
                    Param(
                        $Property,
                        $Value
                    )

                    $get.$Property | Should Be $Value
                } -TestCases $allParameters

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    Write-Error 'Collection not found!'
                }

                It 'Given that the CollectionName is not found in the SessionDeployment, an error is generated' {
                    try
                    {
                        Get-TargetResource @xRDRemoteAppSplat -ErrorVariable collectionError
                    }
                    catch
                    {
                        $collectionError[-1].Exception.Message | Should Be 'Failed to lookup RD Session Collection TestCollection. Error: Collection not found!' 
                    }
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    { Set-TargetResource @testInvalidCollectionSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'Invalid'
                It 'Does only accept valid values for CommandLineSetting' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'DoNotAllow'
            }

            Context 'Validate Set Actions' {

                Mock -CommandName Get-RDSessionCollection
                Mock -CommandName Get-RDRemoteApp
                Mock -CommandName New-RDRemoteApp
                Mock -CommandName Remove-RDRemoteApp
                Mock -CommandName Set-RDRemoteApp

                It 'Given that the RemoteApp does not exist yet and Ensure is set to Present, New-RDRemoteApp is called' {
                    Set-TargetResource @xRDRemoteAppSplat
                    Assert-MockCalled -CommandName New-RDRemoteApp -Times 1 -Scope It
                }

                Mock -CommandName Get-RDRemoteApp -MockWith { $true }

                It 'Given that the RemoteApp does exist and Ensure is set to Present, Set-RDRemoteApp is called' {
                    Set-TargetResource @xRDRemoteAppSplat
                    Assert-MockCalled -CommandName Set-RDRemoteApp -Times 1 -Scope It
                }

                $xRDRemoteAppSplat.Ensure = 'Absent'
                It 'Given that the RemoteApp exists and Ensure is set to Absent, Remove-RDRemoteApp is called' {
                    Set-TargetResource @xRDRemoteAppSplat
                    Assert-MockCalled -CommandName Remove-RDRemoteApp -Times 1 -Scope It
                }
                $xRDRemoteAppSplat.Ensure = 'Present'

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    Write-Error 'Collection not found!'
                }

                It 'Given that the CollectionName is not found in the SessionDeployment, an error is generated' {
                    try
                    {
                        Set-TargetResource @xRDRemoteAppSplat -ErrorVariable collectionError
                    }
                    catch
                    {
                        $collectionError[-1].Exception.Message | Should Be 'Failed to lookup RD Session Collection TestCollection. Error: Collection not found!' 
                    }
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            Context "Parameter Values,Validations and Errors" {

                It "Should error when CollectionName length is greater than 15" {
                    { Test-TargetResource @testInvalidCollectionSplat } | Should Throw
                }
                
                $xRDRemoteAppSplat.CommandLineSetting = 'Invalid'
                It 'Does only accept valid values for CommandLineSetting' {
                    { Get-TargetResource @xRDRemoteAppSplat } | Should Throw
                }

                $xRDRemoteAppSplat.CommandLineSetting = 'DoNotAllow'
            }

            Context 'Test output validation' {
                Mock -CommandName Get-RDSessionCollection
                Mock -CommandName Get-RDRemoteApp

                It 'Given that the RemoteApp does not exist yet and Ensure is set to Present, test returns false' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }

                Mock -CommandName Get-RDRemoteApp -MockWith { 
                    @{
                        CollectionName = 'TestCollection'
                        DisplayName = 'MyCalc (1.0.0)'
                        FilePath = 'c:\windows\system32\calc.exe'
                        Alias = 'Test-MyCalc-(1.0.0)'
                        FileVirtualPath = 'c:\windows\system32\calc.exe'
                        FolderName = 'Test'
                        CommandLineSetting = 'DoNotAllow'
                        RequiredCommandLine = 'my-cmd'
                        IconIndex = 0
                        IconPath = 'c:\windows\system32\calc.exe'
                        UserGroups = 'DOMAIN\MyAppGroup_DLG'
                        ShowInWebAccess = $true
                    }
                }

                It 'Given that the RemoteApp does exist and Ensure is set to Present, test returns true' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $true
                }

                $xRDRemoteAppSplat.Ensure = 'Absent'
                It 'Given that the RemoteApp exists and Ensure is set to Absent, test returns false' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }
                $xRDRemoteAppSplat.Ensure = 'Present'

                Mock -CommandName Get-RDRemoteApp -MockWith { 
                    @{
                        CollectionName = 'TestCollection'
                        DisplayName = 'MyCalc (1.0.0)'
                        FilePath = 'c:\windows\system32\calc.exe'
                        Alias = 'Test-MyCalc-(1.0.0)'
                        FileVirtualPath = 'c:\windows\system32\calc.exe'
                        FolderName = 'Test'
                        CommandLineSetting = 'Allow'
                        RequiredCommandLine = 'my-cmd'
                        IconIndex = 0
                        IconPath = 'c:\windows\system32\calc.exe'
                        UserGroups = 'DOMAIN\MyAppGroup_DLG'
                        ShowInWebAccess = $true
                    }
                }

                It 'Given that the RemoteApp exists and Ensure is set to Present and a single setting is misconfigured, test returns false' {
                    Test-TargetResource @xRDRemoteAppSplat | Should Be $false
                }

                Mock -CommandName Get-RDSessionCollection -MockWith {
                    Write-Error 'Collection not found!'
                }

                It 'Given that the CollectionName is not found in the SessionDeployment, an error is generated' {
                    try
                    {
                        Test-TargetResource @xRDRemoteAppSplat -ErrorVariable collectionError
                    }
                    catch
                    {
                        $collectionError[-1].Exception.Message | Should Be 'Failed to lookup RD Session Collection TestCollection. Error: Collection not found!' 
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
