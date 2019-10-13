# xRemoteDesktopSessionHost

[![Build Status](https://dev.azure.com/dsccommunity/xRemoteDesktopSessionHost/_apis/build/status/dsccommunity.xRemoteDesktopSessionHost?branchName=master)](https://dev.azure.com/dsccommunity/xRemoteDesktopSessionHost/_build/latest?definitionId=10&branchName=master)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/xRemoteDesktopSessionHost/10/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/xRemoteDesktopSessionHost/10/master)](https://dsccommunity.visualstudio.com/xRemoteDesktopSessionHost/_test/analytics?definitionId=10&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/xRemoteDesktopSessionHost?label=xRemoteDesktopSessionHost%20Preview)](https://www.powershellgallery.com/packages/xRemoteDesktopSessionHost/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/xRemoteDesktopSessionHost?label=xRemoteDesktopSessionHost)](https://www.powershellgallery.com/packages/xRemoteDesktopSessionHost/)

The **xRemoteDesktopSessionHost** module contains the **xRDSessionDeployment**, **xRDSessionCollection**, **xRDSessionCollectionConfiguration**, and **xRDRemoteApp** resources, allowing creation and configuration of a Remote Desktop Session Host (RDSH) instance.

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Resources

* **xRDSessionDeployment** creates and configures a deployment in RDSH.
* **xRDSessionCollection** creates an RDSH collection.
* **xRDSessionCollectionConfiguration** configures an RDSH collection.
* **xRDRemoteApp** publishes applications for your RDSH collection.
* **xRDServer** adds RD Server features to your RDSH deployment.
* **xRDGatewayConfiguration** creates and configures RD Gateway.
* **xRDLicenseConfiguration** creates and configures RD Licensing server.

### xRDSessionDeployment

* **SessionHost**: Specifies the FQDN of a servers to host the RD Session Host role service.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.
* **WebAccessServer**: The FQDN of a server to host the RD Web Access role service.

### xRDSessionCollection

* **CollectionName**: Specifies a name for the session collection (Max length is 256 characters)
* **SessionHost**: Specifies a RD Session Host server to include in the session collection.
* **CollectionDescription**: A description for the collection.
* **ConnectionBroker**: The Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.

### xRDSessionCollectionConfiguration

* **CollectionName**: Specifies the name for the session collection. (Max length is 256 characters)
* **ActiveSessionLimitMin**: Specifies the maximum time, in minutes, an active session runs.  After this period, the RD Session Host server ends the session.
* **AuthenticateUsingNLA**: Indicates whether to use Network Level Authentication (NLA).  If this value is $True, Remote Desktop uses NLA to authenticate a user before the user sees a logon screen.
* **AutomaticReconnectionEnabled**: Indicates whether the Remote Desktop client attempts to reconnect after a connection interruption.
* **BrokenConnectionAction**: Specifies an action for an RD Session Host server to take after a connection interruption.
* **ClientDeviceRedirectionOptions**: Specifies a type of client device to be redirected to an RD Session Host server in this session collection.
* **ClientPrinterAsDefault**: Indicates whether to use the client printer or server printer as the default printer.  If this value is $True, use the client printer as default.  If this value is $False, use the server as default.
* **ClientPrinterRedirected**: Indicates whether to use client printer redirection, which routes print jobs from the Remote Desktop session to a printer attached to the client computer.
* **CollectionDescription**: Specifies a description of the session collection.
* **ConnectionBroker**: Specifies the Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.
* **CustomRdpProperty**: Specifies Remote Desktop Protocol (RDP) settings to include in the .rdp files for all Windows Server 2012 RemoteApp programs and remote desktops published in this collection.
* **DisconnectedSessionLimitMin**: Specifies a length of time, in minutes.  After client disconnection from a session for this period, the RD Session Host ends the session.
* **EncryptionLevel**: Specifies the level of data encryption used for a Remote Desktop session.
* **IdleSessionLimitMin**: Specifies the length of time, in minutes, to wait before an RD Session Host logs off or disconnects an idle session.
* **MaxRedirectedMonitors**: Specifies the maximum number of client monitors that an RD Session Host server can redirect to a remote session.  The maximum value for this parameter is 16.
* **RDEasyPrintDriverEnabled**: Specifies whether to enable the Remote Desktop Easy Print driver.
* **SecurityLayer**: Specifies which security protocol to use.
* **TemporaryFoldersDeletedOnExit**: Whether to delete temporary folders from the RD Session Host server for a disconnected session.
* **UserGroup**: Specifies a domain group authorized to connect to the RD Session Host servers in a session collection.
* **DiskPath**: Specifies the target path to store the User Profile Disks
* **EnableUserProfileDisk**: Specifies if this collection uses UserProfileDisks
* **ExcludeFilePath**: Specifies a list of strings for files to exclude from the user profile disk
* **ExcludeFolderPath**: Specifies a list of strings for folders to exclude from the user profile disk
* **IncludeFilePath**: Specifies a list of strings for files to include in the user profile disk
* **IncludeFolderPath**: Specifies a list of strings for folders to include in the user profile disk
* **MaxUserProfileDiskSizeGB**: Specifies the maximum size in GB for a User Profile Disk

### xRDRemoteApp

* **Alias**: Specifies an alias for the RemoteApp program.
* **CollectionName**: Specifies the name of the personal virtual desktop collection or session collection.  The cmdlet publishes the RemoteApp program to this collection. (Max length is 256 characters)
* **Ensure**: Specifies if the RemoteApp needs to be Present (default) or Absent.
* **DisplayName**: Specifies a name to display to users for the RemoteApp program.
* **FilePath**: Specifies a path for the executable file for the application.  Note: Do not include any environment variables.
* **FileVirtualPath**: Specifies a path for the application executable file.  This path resolves to the same location as the value of the FilePath parameter, but it can include environment variables.
* **FolderName**: Specifies the name of the folder that the RemoteApp program appears in on the Remote Desktop Web Access (RD Web Access) webpage and in the Start menu for subscribed RemoteApp and Desktop Connections.
* **CommandLineSetting**: Specifies whether the RemoteApp program accepts command-line arguments from the client at connection time. Parameters accepts Allow, DoNotAllow or Require as values.
* **RequiredCommandLine**: Specifies a string that contains command-line arguments that the client can use at connection time with the RemoteApp program.
* **IconIndex**: Specifies the index within the icon file (specified by the IconPath parameter) where the RemoteApp program's icon can be found.
* **IconPath**: Specifies the path to a file containing the icon to display for the RemoteApp program identified by the Alias parameter.
* **UserGroups**: Specifies a domain group that can view the RemoteApp in RD Web Access, and in RemoteApp and Desktop Connections.  To allow all users to see a RemoteApp program, provide a value of Null.
* **ShowInWebAccess**: Specifies whether to show the RemoteApp program in the RD Web Access server, and in RemoteApp and Desktop Connections that the user subscribes to.

### xRDServer

* **ConnectionBroker**: Specifies the Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.
* **Server**: The FQDN of a server to configure a role on.
* **Role**: The name of the Windows RDS feature to add to the server.
* **GatewayExternalFqdn**: The external FQDN for the RD Gateway server. Only needed for the RDS-Gateway feature.

### xRDGatewayConfiguration

* **ConnectionBroker**: Specifies the Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.
* **GatewayServer**: The server to configure as an RD Gateway.
* **ExternalFqdn**: The external FQDN for the RD Gateway server. Only needed for the RDS-Gateway feature.
* **GatewayMode**: Set to DoNotUse, Automatic, or Custom
* **LogonMethod**: When GatewayMode is custom, sets the logon method for the Gateway.
* **UseCachedCredentials** When GatewayMode is custom, configures the use of cached credentials.
* **BypassLocal**: When GatewayMode is custom, configues bypassing for local network addresses.

### xRDLicenseConfiguration

* **ConnectionBroker**: Specifies the Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.
* **LicenseServers**: An array of servers to use for RD licensing
* **LicenseMode**: The RD licensing mode to use. PerUser, PerDevice, or NotConfigured.

## Versions

### Unreleased

* Changes to xRDSessionDeployment
  * Fixing Get-TargetResource to target the connection broker, instead of assuming localhost

### 1.9.0.0

* Changes to xRDRemoteApp
  * Fixing typo in parameter name when calling the function ValidateCustomModeParameters (issue #50).
* Changes to xRDSessionDeployment
  * When RDMS service does not exist the Get-TargetResource will no longer throw an error (issue #47).
* Rename Tests/Unit folder to use upper case on first letter.
* Update appveyor.yml to use the default template.
* Added default template files .codecov.yml, .gitattributes, and .gitignore, and
  .vscode folder.
* xRDSessionCollectionConfiguration:
  * Changed CollectionName variable validation max length to 256
* xRDSessionCollection
  * Changed CollectionName variable validation max length to 256
* xRDRemoteApp
  * Changed CollectionName variable validation max length to 256

### 1.8.0.0

* Changes to xRDSessionDeployment
  * Fixed issue where an initial deployment failed due to a convert to lowercase (issue #39).
  * Added unit tests to test Get, Test and Set results in this resource.
* Change to xRDRemoteApp
  * Fixed issue where this resource ignored the CollectionName provided in the parameters (issue #41).
  * Changed key values in schema.mof to only Alias and CollectionName, DisplayName and FilePath are not key values.
  * Added Ensure property (Absent or Present) to enable removal of RemoteApps.
  * Added unit tests to test Get, Test and Set results in this resource.

### 1.7.0.0

* Added additional resources, copied from the [Azure RDS quickstart templates](https://github.com/Azure/RDS-Templates).
* xRDSessionCollection:
  * Fixed call to Add-RDSessionHost in Set-TargetResource by properly removing CollectionDescription from PSBoundParameters (issue #28)
  * Fixed bug on Get-TargetResource that did return any collection instead of the one collection the user asked for (issue #27)
  * Added unit tests to test Get, Test and Set results in this resource

### 1.6.0.0

* xRDSessionCollectionConfiguration: Add support to configure UserProfileDisks on Windows Server 2016

### 1.5.0.0

* Fix issue where DSC configuration gets into a reboot loop because sessionhost does not match (casing) and RDMS service is not started in time

### 1.4.0.0

* Updated CollectionName parameter to validate length between 1 and 15 characters, and added tests to verify.

### 1.3.0.0

* Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.

### 1.2.0.0

* Fixed an issue with version checks where OS version greater than 9 would fail (Windows 10/Server 2016)

### 1.1.0.0

* Fixed encoding

### 1.0.1

### 1.0.0.0

* Initial release with the following resources
  * **xRDSessionDeployment**
  * **xRDSessionCollection**
  * **xRDSessionCollectionConfiguration**
  * **xRDRemoteApp**

## Examples

### End to End

```powershell
param (
[string]$brokerFQDN,
[string]$webFQDN,
[string]$collectionName,
[string]$collectionDescription
)

$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

if (!$collectionName) {$collectionName = "Tenant Jump Box"}
if (!$collectionDescription) {$collectionDescription = "Remote Desktop instance for accessing an isolated network environment."}

Configuration RemoteDesktopSessionHost
{
    param
    (

        # Connection Broker Name
        [Parameter(Mandatory)]
        [String]$collectionName,

        # Connection Broker Description
        [Parameter(Mandatory)]
        [String]$collectionDescription,

        # Connection Broker Node Name
        [String]$connectionBroker,

        # Web Access Node Name
        [String]$webAccessServer
    )
    Import-DscResource -Module xRemoteDesktopSessionHost
    if (!$connectionBroker) {$connectionBroker = $localhost}
    if (!$connectionWebAccessServer) {$webAccessServer = $localhost}

    Node "localhost"
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature Remote-Desktop-Services
        {
            Ensure = "Present"
            Name = "Remote-Desktop-Services"
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }

        WindowsFeature Desktop-Experience
        {
            Ensure = "Present"
            Name = "Desktop-Experience"
        }

        WindowsFeature RSAT-RDS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Tools"
            IncludeAllSubFeature = $true
        }

        if ($localhost -eq $connectionBroker) {
            WindowsFeature RDS-Connection-Broker
            {
                Ensure = "Present"
                Name = "RDS-Connection-Broker"
            }
        }

        if ($localhost -eq $webAccessServer) {
            WindowsFeature RDS-Web-Access
            {
                Ensure = "Present"
                Name = "RDS-Web-Access"
            }
        }

        WindowsFeature RDS-Licensing
        {
            Ensure = "Present"
            Name = "RDS-Licensing"
        }

        xRDSessionDeployment Deployment
        {
            SessionHost = $localhost
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            WebAccessServer = if ($WebAccessServer) {$WebAccessServer} else {$localhost}
            DependsOn = "[WindowsFeature]Remote-Desktop-Services", "[WindowsFeature]RDS-RD-Server"
        }

        xRDSessionCollection Collection
        {
            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            SessionHost = $localhost
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            DependsOn = "[xRDSessionDeployment]Deployment"
        }
        xRDSessionCollectionConfiguration CollectionConfiguration
        {
        CollectionName = $collectionName
        CollectionDescription = $collectionDescription
        ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
        TemporaryFoldersDeletedOnExit = $false
        SecurityLayer = "SSL"
        DependsOn = "[xRDSessionCollection]Collection"
        }
        xRDRemoteApp Calc
        {
        CollectionName = $collectionName
        DisplayName = "Calculator"
        FilePath = "C:\Windows\System32\calc.exe"
        Alias = "calc"
        DependsOn = "[xRDSessionCollection]Collection"
        }
        xRDRemoteApp Mstsc
        {
        CollectionName = $collectionName
        DisplayName = "Remote Desktop"
        FilePath = "C:\Windows\System32\mstsc.exe"
        Alias = "mstsc"
        DependsOn = "[xRDSessionCollection]Collection"
        }
    }
}

write-verbose "Creating configuration with parameter values:"
write-verbose "Collection Name: $collectionName"
write-verbose "Collection Description: $collectionDescription"
write-verbose "Connection Broker: $brokerFQDN"
write-verbose "Web Access Server: $webFQDN"

RemoteDesktopSessionHost -collectionName $collectionName -collectionDescription $collectionDescription -connectionBroker $brokerFQDN -webAccessServer $webFQDN -OutputPath .\RDSDSC\

Set-DscLocalConfigurationManager -verbose -path .\RDSDSC\

Start-DscConfiguration -wait -force -verbose -path .\RDSDSC\
```
