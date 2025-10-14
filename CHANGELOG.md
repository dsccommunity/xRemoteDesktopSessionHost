# Changelog for xRemoteDesktopSessionHost

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- xRDSessionCollection
  - Ignore errors from New-RDSessionCollection and instead checks the collection is created; resolves [issue #105](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/105)
  - Always filter SessionCollection result; resolves [issue #106](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/106)

### Added

- xRDConnectionBrokerHAMode
  - New resource to configure HA mode on a connection broker

### Changed

- xRDSessionCollection
  - SessionHost supports array
  - Collections are now tested for SessionHosts as well, list of session hosts is amended
- xRDSessionDeployment
  - SessionHost and WebAccessServer supports array
  - Deployments are now tested for WebAccess and SessionHosts as well
  - Resource can extend an existing deployment with more session hosts and web access servers
  - ConnectionBroker is only remaining key since the broker can only broker one deployment
- xRDServer
  - Improve error handling in Set-TargetResource function for Add-RDServer
    cmdlet, fixes issue [issue #111](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/111).
- Fixed formatting in all source files, issue [issue #113](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/113).
- Update repo files to latest versions in Sampler. Fixes [issue #118](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/118).
- Enable DocGenerator and move docs to wiki. Fixes [issue #101](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/101).

## [2.1.0] - 2022-08-07

### Added

- xRemoteDesktopSessionHost
  - New examples for the resources

### Changed

- xRemoteDesktopSessionHost
  - Pipeline deploy task updated to use image `ubuntu-latest`.
  - Update pipeline files to the latest from Sampler's DSC Community template.
- xRDCertificateConfiguration
  - import of RemoteDesktop module is now global; resolves [issue #79](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/79)
- xRDSessionCollection
  - Workaround for bug in Windows Server 2019. Added a conditional match on returned
    Collections from `Get-RDSessionCollection` to workaround bug scenario where multiple
    collections are returned instead of a single collection.

### Fixed

- xRDCertificateConfiguration
  - Verbose messages now uses the correct localized strings.

## [2.0.0] - 2020-09-29

### Changed

- Updated filename for CHANGELOG.MD to CHANGELOG.md
- Changes to xRemoteApp
  - Updating `UserGroups` parameter to allow for an array to be supplied
  - Updating comparison of current properties and supplied parameters by moving
    to the DscResource.Common `Test-DscParameterState` cmdlet. This was necessary
    to allow for the change with the `UserGroups` parameter to allow an array object.
- Change to xRDGatewayConfiguration
  - Updated call to `Set-RDDeploymentGatewayConfiguration` cmdlet to use `ErrorAction` 'Stop'
  - Updated call to `Set-RDDeploymentGatewayConfiguration` cmdlet to use a splat for better formatting
- Changes to tests
  - xRDRemoteApp
    - Fixed tests for error scenarios to behave correctly
  - xRDGatewayConfiguration
    - Fixed tests for error scenarios to behave correctly

## 2.0.0

### Added

- xRemoteDesktopSessionHost
  - Added automatic release with a new CI pipeline.
  - Added DSC HQRM Tests
- xRDCertificateConfiguration
  - New resource to configure the used certificate on a deployment

### Changed

- Changes to xRDSessionCollectionConfiguration
  - Fixing comparison of some RD Session Collection Configuration properties and
    supplied parameters by moving to the DscResource.Common `Test-DscParameterState` cmdlet.
    ([issue #82](https://github.com/dsccommunity/xRemoteDesktopSessionHost/issues/82)).
- Changes to xRDSessionDeployment
  - Fixing Get-TargetResource to target the connection broker, instead of
    assuming localhost
- Changes to xRDServer
  - Changed resouce key from Server alone to Role + Server.
    This allows the resource to be used multiple times for different roles on
    the same server. (Issue #62)
- Changes to xRemoteApp
  - Fix xRDRemoteApp Test-TargetResource to not test PowerShell common parameters
- Changes to tests
  - Pin tests to use Pester v4 instead of latest (v5)

## 1.9.0.0

- Changes to xRDRemoteApp
  - Fixing typo in parameter name when calling the function ValidateCustomModeParameters (issue #50).
- Changes to xRDSessionDeployment
  - When RDMS service does not exist the Get-TargetResource will no longer throw an error (issue #47).
- Rename Tests/Unit folder to use upper case on first letter.
- Update appveyor.yml to use the default template.
- Added default template files .codecov.yml, .gitattributes, and .gitignore, and
  .vscode folder.
- xRDSessionCollectionConfiguration:
  - Changed CollectionName variable validation max length to 256
- xRDSessionCollection
  - Changed CollectionName variable validation max length to 256
- xRDRemoteApp
  - Changed CollectionName variable validation max length to 256

## 1.8.0.0

- Changes to xRDSessionDeployment
  - Fixed issue where an initial deployment failed due to a convert to lowercase (issue #39).
  - Added unit tests to test Get, Test and Set results in this resource.
- Change to xRDRemoteApp
  - Fixed issue where this resource ignored the CollectionName provided in the parameters (issue #41).
  - Changed key values in schema.mof to only Alias and CollectionName, DisplayName and FilePath are not key values.
  - Added Ensure property (Absent or Present) to enable removal of RemoteApps.
  - Added unit tests to test Get, Test and Set results in this resource.

## 1.7.0.0

- Added additional resources, copied from the [Azure RDS quickstart templates](https://github.com/Azure/RDS-Templates).
- xRDSessionCollection:
  - Fixed call to Add-RDSessionHost in Set-TargetResource by properly removing CollectionDescription from PSBoundParameters (issue #28)
  - Fixed bug on Get-TargetResource that did return any collection instead of the one collection the user asked for (issue #27)
  - Added unit tests to test Get, Test and Set results in this resource

## 1.6.0.0

- xRDSessionCollectionConfiguration: Add support to configure UserProfileDisks on Windows Server 2016

## 1.5.0.0

- Fix issue where DSC configuration gets into a reboot loop because sessionhost does not match (casing) and RDMS service is not started in time

## 1.4.0.0

- Updated CollectionName parameter to validate length between 1 and 15 characters, and added tests to verify.

## 1.3.0.0

- Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.

## 1.2.0.0

- Fixed an issue with version checks where OS version greater than 9 would fail (Windows 10/Server 2016)

## 1.1.0.0

- Fixed encoding

## 1.0.1

## 1.0.0.0

- Initial release with the following resources
  - xRDSessionDeployment
  - xRDSessionCollection
  - xRDSessionCollectionConfiguration
  - xRDRemoteApp
