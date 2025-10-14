# Name: RemoteDesktop
# Version: 2.0.0.0
# CreatedOn: 2025-10-14 17:59:28Z

Add-Type -IgnoreWarnings -WarningAction SilentlyContinue -TypeDefinition @'
namespace Microsoft.RemoteDesktopServices.Common
{
    [System.Flags]
    public enum CertificateRole : int
    {
        None = 0,
        RDGateway = 1,
        RDWebAccess = 2,
        RDRedirector = 4,
        RDPublishing = 8,
    }

    public class RDCBHADetails
    {
        // Constructor
        public RDCBHADetails() { }
        public RDCBHADetails(System.String[] connectionBroker, System.String activeManagementServer, System.String clientAccessName, System.String databaseConnectionString, System.String databaseFilePath) { }

        // Property
        public System.String ActiveManagementServer { get; set; }
        public System.String[] ConnectionBroker { get; set; }
        public System.String ClientAccessName { get; set; }
        public System.String DatabaseConnectionString { get; set; }

    }

    public class VirtualDesktopJobStatus
    {
        public bool IsSecondaryStubType = true;

        public VirtualDesktopJobStatus() { }
    }

}

namespace Microsoft.RemoteDesktopServices.Management
{
    public class Certificate
    {
        // Constructor
        public Certificate(System.String subject, System.String[] subjectAlternateName, System.String issuedBy, System.String issuedTo, System.String notAfter, System.String thumbprint, Microsoft.RemoteDesktopServices.Common.CertificateRole role, System.String level) { }

        // Property
        public System.String Subject { get; set; }
        public System.String[] SubjectAlternateName { get; set; }
        public System.String IssuedBy { get; set; }
        public System.String IssuedTo { get; set; }
        public System.String ExpiresOn { get; set; }
        public System.String Thumbprint { get; set; }
        public Microsoft.RemoteDesktopServices.Common.CertificateRole Role { get; set; }
        public System.String Level { get; set; }

        // Fabricated constructor
        private Certificate() { }
        public static Certificate CreateTypeInstance()
        {
            return new Certificate();
        }
    }

    public enum COLLECTION_TYPE : int
    {
        RD_FARM_RDSH = 0,
        RD_FARM_TEMP_VM = 1,
        RD_FARM_MANUAL_PERSONAL_VM = 2,
        RD_FARM_AUTO_PERSONAL_VM = 3,
        RD_FARM_MANUAL_PERSONAL_SESSION = 4,
        RD_FARM_AUTO_PERSONAL_SESSION = 5,
    }

    public enum CommandLineSettingValue : int
    {
        DoNotAllow = 0,
        Allow = 1,
        Require = 2,
    }

    public class CustomGatewaySettings
    {
        // Constructor
        public CustomGatewaySettings(Microsoft.RemoteDesktopServices.Management.GatewayUsage gatewayMode, System.String serverFQDN, Microsoft.RemoteDesktopServices.Management.GatewayAuthMode logonMethod, System.Boolean useCachedCreds, System.Boolean bypassLocal) { }

        // Property
        public Microsoft.RemoteDesktopServices.Management.GatewayUsage GatewayMode { get; set; }
        public System.String GatewayExternalFqdn { get; set; }
        public Microsoft.RemoteDesktopServices.Management.GatewayAuthMode LogonMethod { get; set; }
        public System.Boolean UseCachedCredentials { get; set; }
        public System.Boolean BypassLocal { get; set; }

        // Fabricated constructor
        private CustomGatewaySettings() { }
        public static CustomGatewaySettings CreateTypeInstance()
        {
            return new CustomGatewaySettings();
        }
    }

    public class FileTypeAssociation
    {
        // Constructor
        public FileTypeAssociation(System.String collectionName, System.String appAlias, System.String fileExtension, System.String description, System.Boolean isPublished, System.Byte[] iconContents, System.Int32 iconIndex, System.String iconPath) { }

        // Property
        public System.String FileExtension { get; set; }
        public System.String CollectionName { get; set; }
        public System.String AppAlias { get; set; }
        public System.String Description { get; set; }
        public System.Boolean IsPublished { get; set; }
        public System.Byte[] IconContents { get; set; }
        public System.Int32 IconIndex { get; set; }
        public System.String IconPath { get; set; }

        // Fabricated constructor
        private FileTypeAssociation() { }
        public static FileTypeAssociation CreateTypeInstance()
        {
            return new FileTypeAssociation();
        }
    }

    public enum GatewayAuthMode : int
    {
        Password = 0,
        Smartcard = 1,
        AllowUserToSelectDuringConnection = 4,
    }

    public class GatewaySettings
    {
        // Constructor
        public GatewaySettings(Microsoft.RemoteDesktopServices.Management.GatewayUsage gatewayMode) { }

        // Property
        public Microsoft.RemoteDesktopServices.Management.GatewayUsage GatewayMode { get; set; }

        // Fabricated constructor
        private GatewaySettings() { }
        public static GatewaySettings CreateTypeInstance()
        {
            return new GatewaySettings();
        }
    }

    public enum GatewayUsage : int
    {
        DoNotUse = 0,
        Custom = 2,
        Automatic = 3,
    }

    public enum LicensingMode : int
    {
        PerDevice = 2,
        PerUser = 4,
        NotConfigured = 5,
    }

    public class LicensingSetting
    {
        // Constructor
        public LicensingSetting(System.Int32 mode, System.String[] licenseServers) { }

        // Property
        public Microsoft.RemoteDesktopServices.Management.LicensingMode Mode { get; set; }
        public System.String[] LicenseServer { get; set; }

        // Fabricated constructor
        private LicensingSetting() { }
        public static LicensingSetting CreateTypeInstance()
        {
            return new LicensingSetting();
        }
    }

    public enum RDBrokenConnectionAction : int
    {
        None = 0,
        Disconnect = 1,
        LogOff = 2,
    }

    public enum RDCertificateRole : int
    {
        RDGateway = 1,
        RDWebAccess = 2,
        RDRedirector = 4,
        RDPublishing = 8,
    }

    [System.Flags]
    public enum RDClientDeviceRedirectionOptions : int
    {
        None = 0,
        AudioVideoPlayBack = 1,
        AudioRecording = 2,
        COMPort = 4,
        PlugAndPlayDevice = 8,
        SmartCard = 16,
        Clipboard = 32,
        LPTPort = 64,
        Drive = 128,
        TimeZone = 256,
    }

    public class RDDeploymentServer
    {
        // Constructor
        public RDDeploymentServer(System.String server, System.String[] roles) { }

        // Property
        public System.String Server { get; set; }
        public System.String[] Roles { get; set; }

        // Fabricated constructor
        private RDDeploymentServer() { }
        public static RDDeploymentServer CreateTypeInstance()
        {
            return new RDDeploymentServer();
        }
    }

    public enum RDEncryptionLevel : int
    {
        None = 0,
        Low = 1,
        ClientCompatible = 2,
        High = 3,
        FipsCompliant = 4,
    }

    public enum RDPatchStatus : int
    {
        Unknown = 0,
        Searching = 1,
        Downloading = 2,
        Applying = 3,
        Rebooting = 4,
        Rebooted = 5,
        Success = 6,
        Failure = 7,
        Timeout = 8,
    }

    public class RDPersonalSessionDesktopAssignment
    {
        // Constructor
        public RDPersonalSessionDesktopAssignment(System.String InCollectionName, System.String InDesktopName, System.String Inuser) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String DesktopName { get; set; }
        public System.String User { get; set; }

        // Fabricated constructor
        private RDPersonalSessionDesktopAssignment() { }
        public static RDPersonalSessionDesktopAssignment CreateTypeInstance()
        {
            return new RDPersonalSessionDesktopAssignment();
        }
    }

    public class RDPersonalVirtualDesktopAssignment
    {
        // Constructor
        public RDPersonalVirtualDesktopAssignment(System.String virtDesktopName, System.String user) { }

        // Property
        public System.String VirtualDesktopName { get; set; }
        public System.String User { get; set; }

        // Fabricated constructor
        private RDPersonalVirtualDesktopAssignment() { }
        public static RDPersonalVirtualDesktopAssignment CreateTypeInstance()
        {
            return new RDPersonalVirtualDesktopAssignment();
        }
    }

    public class RDPersonalVirtualDesktopPatchSchedule
    {
        // Constructor
        public RDPersonalVirtualDesktopPatchSchedule(System.String virtualDesktopName, System.Byte[] context, System.DateTime deadline, System.DateTime startTime, System.DateTime endTime, System.String id, System.String label, System.String plugin, Microsoft.RemoteDesktopServices.Management.RDPatchStatus patchStatus) { }

        // Property
        public System.String VirtualDesktopName { get; set; }
        public System.Byte[] Context { get; set; }
        public System.DateTime Deadline { get; set; }
        public System.DateTime StartTime { get; set; }
        public System.DateTime EndTime { get; set; }
        public System.String ID { get; set; }
        public System.String Label { get; set; }
        public System.String Plugin { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDPatchStatus PatchStatus { get; set; }

        // Fabricated constructor
        private RDPersonalVirtualDesktopPatchSchedule() { }
        public static RDPersonalVirtualDesktopPatchSchedule CreateTypeInstance()
        {
            return new RDPersonalVirtualDesktopPatchSchedule();
        }
    }

    public class RDPublishedRemoteDesktop
    {
        // Constructor
        public RDPublishedRemoteDesktop(System.String collectionName, System.Boolean showInWebAccess) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.Boolean ShowInWebAccess { get; set; }

        // Fabricated constructor
        private RDPublishedRemoteDesktop() { }
        public static RDPublishedRemoteDesktop CreateTypeInstance()
        {
            return new RDPublishedRemoteDesktop();
        }
    }

    public enum RDSecurityLayer : int
    {
        RDP = 0,
        Negotiate = 1,
        SSL = 2,
    }

    public class RDServer
    {
        // Constructor
        public RDServer(System.String collectionName, System.String sessionHost, Microsoft.RemoteDesktopServices.Management.RDServerNewConnectionAllowed newConnectionAllowed) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String SessionHost { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDServerNewConnectionAllowed NewConnectionAllowed { get; set; }

        // Fabricated constructor
        private RDServer() { }
        public static RDServer CreateTypeInstance()
        {
            return new RDServer();
        }
    }

    public enum RDServerNewConnectionAllowed : int
    {
        Yes = 0,
        NotUntilReboot = 1,
        No = 2,
    }

    public class RDSessionCollection
    {
        // Constructor
        public RDSessionCollection(System.String collectionName, System.String collectionAlias, System.String collectionDescription, System.Int32 size, System.String resourceType, Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType collectionType, System.Boolean autoAssignPersonalDesktop, System.Boolean grantAdministrativePrivilege) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String CollectionAlias { get; set; }
        public System.String CollectionDescription { get; set; }
        public System.Int32 Size { get; set; }
        public System.String ResourceType { get; set; }
        public System.Boolean AutoAssignPersonalDesktop { get; set; }
        public System.Boolean GrantAdministrativePrivilege { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDSessionCollectionType CollectionType { get; set; }

        // Fabricated constructor
        private RDSessionCollection() { }
        public static RDSessionCollection CreateTypeInstance()
        {
            return new RDSessionCollection();
        }
    }

    public enum RDSessionCollectionType : int
    {
        Unknown = 0,
        PooledUnmanaged = 1,
        PersonalUnmanaged = 2,
    }

    public class RDSessionHostCollectionClientProperties
    {
        // Constructor
        public RDSessionHostCollectionClientProperties(System.String collectionName, Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions clientDeviceRedirectionOptions, System.Int32 maxRedirectedMonitors, System.Int32 clientPrinterRedirected, System.Int32 rdEasyPrintDriverEnabled, System.Int32 clientPrinterAsDefault) { }

        // Property
        public System.String CollectionName { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions ClientDeviceRedirectionOptions { get; set; }
        public System.Int32 MaxRedirectedMonitors { get; set; }
        public System.Int32 ClientPrinterRedirected { get; set; }
        public System.Int32 RDEasyPrintDriverEnabled { get; set; }
        public System.Int32 ClientPrinterAsDefault { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionClientProperties() { }
        public static RDSessionHostCollectionClientProperties CreateTypeInstance()
        {
            return new RDSessionHostCollectionClientProperties();
        }
    }

    public class RDSessionHostCollectionConnectionProperties
    {
        // Constructor
        public RDSessionHostCollectionConnectionProperties(System.String collectionName, System.Int32 disconnectedSessionLimitMin, Microsoft.RemoteDesktopServices.Management.RDBrokenConnectionAction brokenConnectionAction, System.Boolean temporaryFoldersDeletedOnExit, System.Boolean automaticReconnectionEnabled, System.Int32 activeSessionLimitMin, System.Int32 idleSessionLimitMin) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.Int32 DisconnectedSessionLimitMin { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDBrokenConnectionAction BrokenConnectionAction { get; set; }
        public System.Boolean TemporaryFoldersDeletedOnExit { get; set; }
        public System.Boolean AutomaticReconnectionEnabled { get; set; }
        public System.Int32 ActiveSessionLimitMin { get; set; }
        public System.Int32 IdleSessionLimitMin { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionConnectionProperties() { }
        public static RDSessionHostCollectionConnectionProperties CreateTypeInstance()
        {
            return new RDSessionHostCollectionConnectionProperties();
        }
    }

    public class RDSessionHostCollectionGeneralProperties
    {
        // Constructor
        public RDSessionHostCollectionGeneralProperties(System.String collectionName, System.String collectionDescription, System.String customRdpProperty) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String CollectionDescription { get; set; }
        public System.String CustomRdpProperty { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionGeneralProperties() { }
        public static RDSessionHostCollectionGeneralProperties CreateTypeInstance()
        {
            return new RDSessionHostCollectionGeneralProperties();
        }
    }

    public class RDSessionHostCollectionLoadBalancingInstance
    {
        // Constructor
        public RDSessionHostCollectionLoadBalancingInstance(System.String collectionName, System.Int32 relativeWeight, System.Int32 sessionLimit, System.String sessionHost) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.Int32 RelativeWeight { get; set; }
        public System.Int32 SessionLimit { get; set; }
        public System.String SessionHost { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionLoadBalancingInstance() { }
        public static RDSessionHostCollectionLoadBalancingInstance CreateTypeInstance()
        {
            return new RDSessionHostCollectionLoadBalancingInstance();
        }
    }

    public class RDSessionHostCollectionSecurityProperties
    {
        // Constructor
        public RDSessionHostCollectionSecurityProperties(System.String collectionName, System.Boolean authenticateUsingNLA, Microsoft.RemoteDesktopServices.Management.RDEncryptionLevel encryptionLevel, Microsoft.RemoteDesktopServices.Management.RDSecurityLayer securityLayer) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.Boolean AuthenticateUsingNLA { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDEncryptionLevel EncryptionLevel { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDSecurityLayer SecurityLayer { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionSecurityProperties() { }
        public static RDSessionHostCollectionSecurityProperties CreateTypeInstance()
        {
            return new RDSessionHostCollectionSecurityProperties();
        }
    }

    public class RDSessionHostCollectionUserGroupProperties
    {
        // Constructor
        public RDSessionHostCollectionUserGroupProperties(System.String collectionName, System.String[] userGroup) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String[] UserGroup { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionUserGroupProperties() { }
        public static RDSessionHostCollectionUserGroupProperties CreateTypeInstance()
        {
            return new RDSessionHostCollectionUserGroupProperties();
        }
    }

    public class RDSessionHostCollectionUserProfileDiskProperties
    {
        // Constructor
        public RDSessionHostCollectionUserProfileDiskProperties(System.String collectionName, System.String[] includeFolderPath, System.String[] excludeFolderPath, System.String[] includeFilePath, System.String[] excludeFilePath, System.String diskPath, System.Boolean enableUserProfileDisk, System.Int32 maxUserProfileDiskSizeGB) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String[] IncludeFolderPath { get; set; }
        public System.String[] ExcludeFolderPath { get; set; }
        public System.String[] IncludeFilePath { get; set; }
        public System.String[] ExcludeFilePath { get; set; }
        public System.String DiskPath { get; set; }
        public System.Boolean EnableUserProfileDisk { get; set; }
        public System.Int32 MaxUserProfileDiskSizeGB { get; set; }

        // Fabricated constructor
        private RDSessionHostCollectionUserProfileDiskProperties() { }
        public static RDSessionHostCollectionUserProfileDiskProperties CreateTypeInstance()
        {
            return new RDSessionHostCollectionUserProfileDiskProperties();
        }
    }

    public class RDUserSession
    {
        // Constructor
        public RDUserSession(System.String serverName, System.Nullable<System.UInt32> sessionId, System.String userName, System.String domainName, System.String serverIPAddress, System.Nullable<System.UInt32> tsProtocol, System.String applicationType, System.Nullable<System.UInt32> resolutionWidth, System.Nullable<System.UInt32> resolutionHeight, System.Nullable<System.UInt32> colorDepth, System.String createTime, System.String disconnectTime, System.Nullable<System.UInt32> sessionState, System.String collectionName, System.Nullable<System.UInt32> collectionType, System.Nullable<System.UInt32> unifiedSessionId, System.String hostServer, System.Nullable<System.UInt32> idleTime, System.Nullable<System.Boolean> remoteFxEnabled) { }

        // Property
        public System.String ServerName { get; set; }
        public System.Nullable<System.UInt32> SessionId { get; set; }
        public System.String UserName { get; set; }
        public System.String DomainName { get; set; }
        public System.String ServerIPAddress { get; set; }
        public System.Nullable<System.UInt32> TSProtocol { get; set; }
        public System.String ApplicationType { get; set; }
        public System.Nullable<System.UInt32> ResolutionWidth { get; set; }
        public System.Nullable<System.UInt32> ResolutionHeight { get; set; }
        public System.Nullable<System.UInt32> ColorDepth { get; set; }
        public System.Nullable<System.DateTime> CreateTime { get; set; }
        public System.Nullable<System.DateTime> DisconnectTime { get; set; }
        public System.Nullable<Microsoft.RemoteDesktopServices.Management.SESSION_STATE> SessionState { get; set; }
        public System.String CollectionName { get; set; }
        public System.Nullable<Microsoft.RemoteDesktopServices.Management.COLLECTION_TYPE> CollectionType { get; set; }
        public System.Nullable<System.UInt32> UnifiedSessionId { get; set; }
        public System.String HostServer { get; set; }
        public System.Nullable<System.UInt32> IdleTime { get; set; }
        public System.Nullable<System.Boolean> RemoteFxEnabled { get; set; }

        // Fabricated constructor
        private RDUserSession() { }
        public static RDUserSession CreateTypeInstance()
        {
            return new RDUserSession();
        }
    }

    public class RDVirtualDesktop
    {
        // Constructor
        public RDVirtualDesktop(System.String name, System.String collectionName, System.String hostName, System.UInt32 vmState, System.UInt32 provisioningStatus) { }

        // Property
        public System.String VirtualDesktopName { get; set; }
        public System.String CollectionName { get; set; }
        public System.String HostName { get; set; }
        public Microsoft.RemoteDesktopServices.Management.VirtualDesktopState State { get; set; }
        public Microsoft.RemoteDesktopServices.Management.VirtualDesktopProvisioningStatus ProvisioningStatus { get; set; }

        // Fabricated constructor
        private RDVirtualDesktop() { }
        public static RDVirtualDesktop CreateTypeInstance()
        {
            return new RDVirtualDesktop();
        }
    }

    public class RDVirtualDesktopCollection
    {
        // Constructor
        public RDVirtualDesktopCollection(System.String alias, System.String name, System.String description, Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionType type, System.Boolean showInPortal, System.Boolean autoAssign, System.Boolean userAdmin, System.Boolean rollback, System.String[] users, System.UInt32 size, System.UInt32 percentInUse) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String CollectionAlias { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionType Type { get; set; }
        public System.String Description { get; set; }
        public System.Boolean ShowInWebAccess { get; set; }
        public System.Boolean AutoAssignPersonalDesktop { get; set; }
        public System.Boolean GrantAdministrativePrivilege { get; set; }
        public System.Boolean VirtualDesktopRollback { get; set; }
        public System.String[] Users { get; set; }
        public System.UInt32 Size { get; set; }
        public System.UInt32 PercentInUse { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopCollection() { }
        public static RDVirtualDesktopCollection CreateTypeInstance()
        {
            return new RDVirtualDesktopCollection();
        }
    }

    public class RDVirtualDesktopCollectionClientProperties
    {
        // Constructor
        public RDVirtualDesktopCollectionClientProperties(Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions clientDeviceRedirectionOptions, System.Boolean redirectAllMonitors, System.Boolean redirectClientPrinter) { }

        // Property
        public Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions ClientDeviceRedirectionOptions { get; set; }
        public System.Boolean RedirectAllMonitors { get; set; }
        public System.Boolean RedirectClientPrinter { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopCollectionClientProperties() { }
        public static RDVirtualDesktopCollectionClientProperties CreateTypeInstance()
        {
            return new RDVirtualDesktopCollectionClientProperties();
        }
    }

    public class RDVirtualDesktopCollectionGeneralProperties
    {
        // Constructor
        public RDVirtualDesktopCollectionGeneralProperties(System.String collectionDescription, System.Boolean autoAssignPersonalDesktop, Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionType collectionType, System.Int32 saveDelay, System.String customRdpProperty) { }

        // Property
        public System.String CollectionDescription { get; set; }
        public Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionType CollectionType { get; set; }
        public System.Boolean AutoAssignPersonalDesktop { get; set; }
        public System.Int32 SaveDelayMinutes { get; set; }
        public System.String CustomRdpProperty { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopCollectionGeneralProperties() { }
        public static RDVirtualDesktopCollectionGeneralProperties CreateTypeInstance()
        {
            return new RDVirtualDesktopCollectionGeneralProperties();
        }
    }

    public class RDVirtualDesktopCollectionJobStatus
    {
        // Constructor
        public RDVirtualDesktopCollectionJobStatus(System.String collectionName, Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus status, System.DateTime startTime, System.DateTime lastModTime, System.UInt32 totalDesktop, System.String completed, System.UInt32 failed, Microsoft.RemoteDesktopServices.Common.VirtualDesktopJobStatus[] virtualDesktopStatus) { }

        // Property
        public System.String CollectionName { get; set; }
        public Microsoft.RemoteDesktopServices.Management.VirtualDesktopCollectionJobStatus Status { get; set; }
        public System.DateTime StartTime { get; set; }
        public System.DateTime LastModifiedTime { get; set; }
        public System.UInt32 TotalVirtualDesktop { get; set; }
        public System.String PercentCompleted { get; set; }
        public System.UInt32 FailedVirtualDesktop { get; set; }
        public Microsoft.RemoteDesktopServices.Common.VirtualDesktopJobStatus[] VirtualDesktopStatus { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopCollectionJobStatus() { }
        public static RDVirtualDesktopCollectionJobStatus CreateTypeInstance()
        {
            return new RDVirtualDesktopCollectionJobStatus();
        }
    }

    public enum RDVirtualDesktopCollectionType : int
    {
        Unknown = 0,
        PooledManaged = 1,
        PooledUnmanaged = 2,
        PersonalManaged = 3,
        PersonalUnmanaged = 4,
    }

    public class RDVirtualDesktopCollectionUserProfileDisksProperties
    {
        // Constructor
        public RDVirtualDesktopCollectionUserProfileDisksProperties(System.String[] includeFolderPath, System.String[] excludeFolderPath, System.String[] includeFilePath, System.String[] excludeFilePath, System.String diskLocation, System.Boolean enableUserProfileDisks, System.Int32 maxUserProfileDiskSizeGB) { }

        // Property
        public System.String[] IncludeFolderPath { get; set; }
        public System.String[] ExcludeFolderPath { get; set; }
        public System.String[] IncludeFilePath { get; set; }
        public System.String[] ExcludeFilePath { get; set; }
        public System.String DiskPath { get; set; }
        public System.Boolean EnableUserProfileDisks { get; set; }
        public System.Int32 MaxUserProfileDiskSizeGB { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopCollectionUserProfileDisksProperties() { }
        public static RDVirtualDesktopCollectionUserProfileDisksProperties CreateTypeInstance()
        {
            return new RDVirtualDesktopCollectionUserProfileDisksProperties();
        }
    }

    public class RDVirtualDesktopCollectionVirtualDesktopsProperties
    {
        // Constructor
        public RDVirtualDesktopCollectionVirtualDesktopsProperties(System.String domain, System.String ou, Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType storageType, System.String centralStorageLocation, System.String localVMCreationLocation, System.String virtualDesktopTemplateName, System.String virtualDesktopTemplateHostServer, System.String virtualDesktopTemplateExportLocation, System.String virtualDesktopNamePrefix, System.UInt32 virtualDesktopNamePostfixStartIndex) { }

        // Property
        public System.String Domain { get; set; }
        public System.String OU { get; set; }
        public Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType StorageType { get; set; }
        public System.String CentralStoragePath { get; set; }
        public System.String LocalStoragePath { get; set; }
        public System.String VirtualDesktopTemplateName { get; set; }
        public System.String VirtualDesktopTemplateHostServer { get; set; }
        public System.String VirtualDesktopTemplateExportPath { get; set; }
        public System.String VirtualDesktopNamePrefix { get; set; }
        public System.UInt32 VirtualDesktopNamePostfixStartIndex { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopCollectionVirtualDesktopsProperties() { }
        public static RDVirtualDesktopCollectionVirtualDesktopsProperties CreateTypeInstance()
        {
            return new RDVirtualDesktopCollectionVirtualDesktopsProperties();
        }
    }

    public class RDVirtualDesktopConcurrency
    {
        // Constructor
        public RDVirtualDesktopConcurrency(System.String fqdn, System.Nullable<System.Int32> concurrency) { }

        // Property
        public System.String FQDN { get; set; }
        public System.Nullable<System.Int32> Concurrency { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopConcurrency() { }
        public static RDVirtualDesktopConcurrency CreateTypeInstance()
        {
            return new RDVirtualDesktopConcurrency();
        }
    }

    public class RDVirtualDesktopIdleCount
    {
        // Constructor
        public RDVirtualDesktopIdleCount(System.String fqdn, System.Nullable<System.Int32> count) { }

        // Property
        public System.String FQDN { get; set; }
        public System.Nullable<System.Int32> Count { get; set; }

        // Fabricated constructor
        private RDVirtualDesktopIdleCount() { }
        public static RDVirtualDesktopIdleCount CreateTypeInstance()
        {
            return new RDVirtualDesktopIdleCount();
        }
    }

    public class RemoteApp
    {
        // Constructor
        public RemoteApp(System.String collectionName, System.String alias, System.String displayName, System.String folderName, System.String filePath, System.String fileVirtualPath, Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue commandLineSetting, System.String requiredCommandLine, System.Byte[] iconContents, System.Int32 iconIndex, System.String iconPath, System.String[] userGroups, System.Boolean showInWebAccess) { }

        // Property
        public System.String CollectionName { get; set; }
        public System.String Alias { get; set; }
        public System.String DisplayName { get; set; }
        public System.String FolderName { get; set; }
        public System.String FilePath { get; set; }
        public System.String FileVirtualPath { get; set; }
        public Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue CommandLineSetting { get; set; }
        public System.String RequiredCommandLine { get; set; }
        public System.Byte[] IconContents { get; set; }
        public System.Int32 IconIndex { get; set; }
        public System.String IconPath { get; set; }
        public System.String[] UserGroups { get; set; }
        public System.Boolean ShowInWebAccess { get; set; }

        // Fabricated constructor
        private RemoteApp() { }
        public static RemoteApp CreateTypeInstance()
        {
            return new RemoteApp();
        }
    }

    public enum SESSION_STATE : int
    {
        STATE_ACTIVE = 0,
        STATE_CONNECTED = 1,
        STATE_CONNECTQUERY = 2,
        STATE_SHADOW = 3,
        STATE_DISCONNECTED = 4,
        STATE_IDLE = 5,
        STATE_LISTEN = 6,
        STATE_RESET = 7,
        STATE_DOWN = 8,
        STATE_INIT = 9,
    }

    public enum VirtualDesktopCollectionJobStatus : int
    {
        UNKNOWN = 0,
        POOL_CREATED = 1,
        CREATE_VIRTUAL_DESKTOP_INPROGRESS = 2,
        ADD_VIRTUAL_DESKTOP_INPROGRESS = 3,
        UPDATE_VIRTUAL_DESKTOP_INPROGRESS = 4,
        DELETE_VIRTUAL_DESKTOP_INPROGRESS = 5,
        UPDATE_SCHEDULED = 6,
        UPDATE_FAILED = 7,
        UPDATE_CANCELLED = 8,
        JOB_COMPLETED = 10,
        CANCEL_INPROGRESS = 11,
        JOB_ABORTED = 12,
        EXPORT_INPROGRESS = 13,
    }

    public enum VirtualDesktopProvisioningStatus : uint
    {
        UNKNOWN = 0,
        SUCCESS = 2,
        FAILED = 3,
    }

    public enum VirtualDesktopState : uint
    {
        UNKNOWN = 0,
        RUNNING = 2,
        STOPPED = 3,
        SAVED = 6,
        RESUMING = 32777,
    }

    public enum VirtualDesktopStorageType : int
    {
        LocalStorage = 1,
        CentralSmbShareStorage = 2,
        CentralSanStorage = 3,
    }

    public class WorkspaceClass
    {
        // Constructor
        public WorkspaceClass(System.String wkspID, System.String wkspName) { }

        // Property
        public System.String WorkspaceID { get; set; }
        public System.String WorkspaceName { get; set; }

        // Fabricated constructor
        private WorkspaceClass() { }
        public static WorkspaceClass CreateTypeInstance()
        {
            return new WorkspaceClass();
        }
    }

}

'@

function Add-RDServer
{
    <#
    .SYNOPSIS
        Add-RDServer [-Server] <string> [-Role] <string> [[-ConnectionBroker] <string>] [[-GatewayExternalFqdn] <string>] [-CreateVirtualSwitch] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254051')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDDeploymentServer[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${Server},

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('RDS-CONNECTION-BROKER', 'RDS-VIRTUALIZATION', 'RDS-RD-SERVER', 'RDS-WEB-ACCESS', 'RDS-GATEWAY', 'RDS-LICENSING')]
        [string]
        ${Role},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker},

        [Parameter(Position = 3)]
        [string]
        ${GatewayExternalFqdn},

        [Parameter(Position = 4)]
        [switch]
        ${CreateVirtualSwitch}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Add-RDSessionHost
{
    <#
    .SYNOPSIS
        Add-RDSessionHost [-CollectionName] <string> -SessionHost <string[]> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string[]]
        ${SessionHost},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Add-RDVirtualDesktopToCollection
{
    <#
    .SYNOPSIS
        Add-RDVirtualDesktopToCollection [-CollectionName] <string> -VirtualDesktopAllocation <hashtable> [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [<CommonParameters>]

Add-RDVirtualDesktopToCollection [-CollectionName] <string> -VirtualDesktopName <string[]> [-ConnectionBroker <string>] [<CommonParameters>]

Add-RDVirtualDesktopToCollection [-CollectionName] <string> -VirtualDesktopAllocation <hashtable> [-VirtualDesktopTemplateName <string>] [-VirtualDesktopTemplateHostServer <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'PooledMgd', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254093')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'UnManaged', Mandatory = $true)]
        [string[]]
        ${VirtualDesktopName},

        [Parameter(ParameterSetName = 'PersonalMgd', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PooledMgd', Mandatory = $true)]
        [hashtable]
        ${VirtualDesktopAllocation},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [string]
        ${VirtualDesktopTemplateName},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [string]
        ${VirtualDesktopTemplateHostServer},

        [Parameter(ParameterSetName = 'PooledMgd')]
        [ValidateRange(31, 365)]
        [int]
        ${VirtualDesktopPasswordAge},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Disable-RDVirtualDesktopADMachineAccountReuse
{
    <#
    .SYNOPSIS
        Disable-RDVirtualDesktopADMachineAccountReuse [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254107')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Disconnect-RDUser
{
    <#
    .SYNOPSIS
        Disconnect-RDUser [-HostServer] <string> [-UnifiedSessionID] <int> [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254079')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${HostServer},

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]
        ${UnifiedSessionID},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Enable-RDVirtualDesktopADMachineAccountReuse
{
    <#
    .SYNOPSIS
        Enable-RDVirtualDesktopADMachineAccountReuse [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254106')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Export-RDPersonalSessionDesktopAssignment
{
    <#
    .SYNOPSIS
        Export-RDPersonalSessionDesktopAssignment [-CollectionName] <string> -path <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string]
        ${path},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Export-RDPersonalVirtualDesktopAssignment
{
    <#
    .SYNOPSIS
        Export-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> -Path <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254102')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string]
        ${Path},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDAvailableApp
{
    <#
    .SYNOPSIS
        Get-RDAvailableApp [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDAvailableApp [-CollectionName] <string> -VirtualDesktopName <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Session', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254089')]
    [OutputType('New-Object Microsoft.RemoteDesktopServices.Management.StartMenuApp[]')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'VirtualDesktop', Mandatory = $true)]
        [Alias('VMName')]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDCertificate
{
    <#
    .SYNOPSIS
        Get-RDCertificate [[-Role] <RDCertificateRole>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254046')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.Certificate[]])]
    param (
        [Parameter(Position = 0)]
        [Microsoft.RemoteDesktopServices.Management.RDCertificateRole]
        ${Role},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDConnectionBrokerHighAvailability
{
    <#
    .SYNOPSIS
        Get-RDConnectionBrokerHighAvailability [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254058')]
    [OutputType([Microsoft.RemoteDesktopServices.Common.RDCBHADetails])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDDeploymentGatewayConfiguration
{
    <#
    .SYNOPSIS
        Get-RDDeploymentGatewayConfiguration [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254065')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.CustomGatewaySettings])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.GatewaySettings])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDFileTypeAssociation
{
    <#
    .SYNOPSIS
        Get-RDFileTypeAssociation [[-CollectionName] <string>] [-AppAlias <string>] [-AppDisplayName <string[]>] [-FileExtension <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254072')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.FileTypeAssociation[]])]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${AppAlias},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${AppDisplayName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FileExtension},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDLicenseConfiguration
{
    <#
    .SYNOPSIS
        Get-RDLicenseConfiguration [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254063')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.LicensingSetting[]])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDPersonalSessionDesktopAssignment
{
    <#
    .SYNOPSIS
        Get-RDPersonalSessionDesktopAssignment [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDPersonalSessionDesktopAssignment [-CollectionName] <string> -Name <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDPersonalSessionDesktopAssignment [-CollectionName] <string> -User <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'GetByCollection', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDPersonalSessionDesktopAssignment[]])]
    param (
        [Parameter(ParameterSetName = 'GetByDesktop', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'GetByUser', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'GetByCollection', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'GetByUser', Mandatory = $true)]
        [string]
        ${User},

        [Parameter(ParameterSetName = 'GetByDesktop', Mandatory = $true)]
        [string]
        ${Name},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDPersonalVirtualDesktopAssignment
{
    <#
    .SYNOPSIS
        Get-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> -VirtualDesktopName <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> -User <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'GetByCollection', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254101')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopAssignment[]])]
    param (
        [Parameter(ParameterSetName = 'GetByDesktop', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'GetByUser', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'GetByCollection', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'GetByUser', Mandatory = $true)]
        [string]
        ${User},

        [Parameter(ParameterSetName = 'GetByDesktop', Mandatory = $true)]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDPersonalVirtualDesktopPatchSchedule
{
    <#
    .SYNOPSIS
        Get-RDPersonalVirtualDesktopPatchSchedule [[-VirtualDesktopName] <string>] [[-ID] <string>] [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254113')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopPatchSchedule[]])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${VirtualDesktopName},

        [Parameter(Position = 1)]
        [string]
        ${ID},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDRemoteApp
{
    <#
    .SYNOPSIS
        Get-RDRemoteApp [[-CollectionName] <string>] [[-Alias] <string>] [-DisplayName <string[]>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254068')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RemoteApp[]])]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${Alias},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${DisplayName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDRemoteDesktop
{
    <#
    .SYNOPSIS
        Get-RDRemoteDesktop [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254074')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDPublishedRemoteDesktop[]])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDServer
{
    <#
    .SYNOPSIS
        Get-RDServer [[-ConnectionBroker] <string>] [[-Role] <string[]>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254053')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDDeploymentServer[]])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker},

        [Parameter(Position = 1)]
        [ValidateSet('RDS-VIRTUALIZATION', 'RDS-RD-SERVER', 'RDS-CONNECTION-BROKER', 'RDS-WEB-ACCESS', 'RDS-GATEWAY', 'RDS-LICENSING')]
        [string[]]
        ${Role}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDSessionCollection
{
    <#
    .SYNOPSIS
        Get-RDSessionCollection [[-CollectionName] <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionCollection[]])]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDSessionCollectionConfiguration
{
    <#
    .SYNOPSIS
        Get-RDSessionCollectionConfiguration [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDSessionCollectionConfiguration [-CollectionName] <string> -UserGroup [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDSessionCollectionConfiguration [-CollectionName] <string> -Connection [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDSessionCollectionConfiguration [-CollectionName] <string> -UserProfileDisk [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDSessionCollectionConfiguration [-CollectionName] <string> -Security [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDSessionCollectionConfiguration [-CollectionName] <string> -LoadBalancing [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDSessionCollectionConfiguration [-CollectionName] <string> -Client [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'General', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254080')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionGeneralProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionUserGroupProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionConnectionProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionUserProfileDiskProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionSecurityProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionLoadBalancingInstance[]])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionClientProperties])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'UserGroup', Mandatory = $true)]
        [switch]
        ${UserGroup},

        [Parameter(ParameterSetName = 'Connection', Mandatory = $true)]
        [switch]
        ${Connection},

        [Parameter(ParameterSetName = 'UserProfileDisk', Mandatory = $true)]
        [switch]
        ${UserProfileDisk},

        [Parameter(ParameterSetName = 'Security', Mandatory = $true)]
        [switch]
        ${Security},

        [Parameter(ParameterSetName = 'LoadBalancing', Mandatory = $true)]
        [switch]
        ${LoadBalancing},

        [Parameter(ParameterSetName = 'Client', Mandatory = $true)]
        [switch]
        ${Client},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDSessionHost
{
    <#
    .SYNOPSIS
        Get-RDSessionHost [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDServer[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDUserSession
{
    <#
    .SYNOPSIS
        Get-RDUserSession [[-CollectionName] <string[]>] [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254076')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDUserSession[]])]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${CollectionName},

        [Parameter(Position = 1)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktop
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktop [[-CollectionName] <string[]>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254095')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktop[]])]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${CollectionName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktopCollection
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktopCollection [[-CollectionName] <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254091')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollection[]])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktopCollectionConfiguration
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> -VirtualDesktopConfiguration [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> -UserGroups [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> -Client [-ConnectionBroker <string>] [<CommonParameters>]

Get-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> -UserProfileDisks [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'General', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254111')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionGeneralProperties])]
    [OutputType([System.Security.Principal.SecurityIdentifier])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionUserProfileDisksProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionClientProperties])]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionVirtualDesktopsProperties])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'VirtualDesktopConfiguration', Mandatory = $true)]
        [switch]
        ${VirtualDesktopConfiguration},

        [Parameter(ParameterSetName = 'UserGroups', Mandatory = $true)]
        [switch]
        ${UserGroups},

        [Parameter(ParameterSetName = 'Client', Mandatory = $true)]
        [switch]
        ${Client},

        [Parameter(ParameterSetName = 'UserProfileDisks', Mandatory = $true)]
        [switch]
        ${UserProfileDisks},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktopCollectionJobStatus
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktopCollectionJobStatus [-CollectionName] <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254097')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopCollectionJobStatus])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktopConcurrency
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktopConcurrency [[-HostServer] <string[]>] [-ConnectionBroker <string>] [-BatchSize <int>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254105')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopConcurrency[]])]
    param (
        [Parameter(Position = 0)]
        [string[]]
        ${HostServer},

        [string]
        ${ConnectionBroker},

        [ValidateRange(1, 100)]
        [int]
        ${BatchSize}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktopIdleCount
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktopIdleCount [[-HostServer] <string[]>] [-ConnectionBroker <string>] [-BatchSize <int>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254110')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDVirtualDesktopIdleCount[]])]
    param (
        [Parameter(Position = 0)]
        [string[]]
        ${HostServer},

        [string]
        ${ConnectionBroker},

        [ValidateRange(1, 100)]
        [int]
        ${BatchSize}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDVirtualDesktopTemplateExportPath
{
    <#
    .SYNOPSIS
        Get-RDVirtualDesktopTemplateExportPath [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254059')]
    [OutputType([System.String])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Get-RDWorkspace
{
    <#
    .SYNOPSIS
        Get-RDWorkspace [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254117')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.WorkspaceClass[]])]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Grant-RDOUAccess
{
    <#
    .SYNOPSIS
        Grant-RDOUAccess [[-Domain] <string>] [-OU] <string> [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254062')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${Domain},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${OU},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Import-RDPersonalSessionDesktopAssignment
{
    <#
    .SYNOPSIS
        Import-RDPersonalSessionDesktopAssignment [-CollectionName] <string> -path <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string]
        ${path},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Import-RDPersonalVirtualDesktopAssignment
{
    <#
    .SYNOPSIS
        Import-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> -Path <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254103')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string]
        ${Path},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Invoke-RDUserLogoff
{
    <#
    .SYNOPSIS
        Invoke-RDUserLogoff [-HostServer] <string> [-UnifiedSessionID] <int> [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254078')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${HostServer},

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]
        ${UnifiedSessionID},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Move-RDVirtualDesktop
{
    <#
    .SYNOPSIS
        Move-RDVirtualDesktop [-SourceHost] <string> [-DestinationHost] <string> [-Name] <string> [[-ConnectionBroker] <string>] [[-Credential] <pscredential>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254067')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${SourceHost},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${DestinationHost},

        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        ${Name},

        [Parameter(Position = 3)]
        [string]
        ${ConnectionBroker},

        [Parameter(Position = 4)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDCertificate
{
    <#
    .SYNOPSIS
        New-RDCertificate [-Role] <RDCertificateRole> -DnsName <string> -Password <securestring> [-ExportPath <string>] [-ConnectionBroker <string>] [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254047')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Microsoft.RemoteDesktopServices.Management.RDCertificateRole]
        ${Role},

        [Parameter(Mandatory = $true)]
        [string]
        ${DnsName},

        [string]
        ${ExportPath},

        [Parameter(Mandatory = $true)]
        [securestring]
        ${Password},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDPersonalVirtualDesktopPatchSchedule
{
    <#
    .SYNOPSIS
        New-RDPersonalVirtualDesktopPatchSchedule [-VirtualDesktopName] <string> [[-ID] <string>] [[-Context] <byte[]>] [[-Deadline] <datetime>] [[-StartTime] <datetime>] [[-EndTime] <datetime>] [[-Label] <string>] [[-Plugin] <string>] [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254115')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDPersonalVirtualDesktopPatchSchedule])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${VirtualDesktopName},

        [Parameter(Position = 1)]
        [string]
        ${ID},

        [Parameter(Position = 2)]
        [byte[]]
        ${Context},

        [Parameter(Position = 3)]
        [datetime]
        ${Deadline},

        [Parameter(Position = 4)]
        [datetime]
        ${StartTime},

        [Parameter(Position = 5)]
        [datetime]
        ${EndTime},

        [Parameter(Position = 6)]
        [string]
        ${Label},

        [Parameter(Position = 7)]
        [string]
        ${Plugin},

        [Parameter(Position = 8)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDRemoteApp
{
    <#
    .SYNOPSIS
        New-RDRemoteApp [-CollectionName] <string> -DisplayName <string> -FilePath <string> [-Alias <string>] [-FileVirtualPath <string>] [-ShowInWebAccess <bool>] [-FolderName <string>] [-CommandLineSetting <CommandLineSettingValue>] [-RequiredCommandLine <string>] [-UserGroups <string[]>] [-IconPath <string>] [-IconIndex <string>] [-ConnectionBroker <string>] [<CommonParameters>]

New-RDRemoteApp [-CollectionName] <string> -DisplayName <string> -FilePath <string> -VirtualDesktopName <string> [-Alias <string>] [-FileVirtualPath <string>] [-ShowInWebAccess <bool>] [-FolderName <string>] [-CommandLineSetting <CommandLineSettingValue>] [-RequiredCommandLine <string>] [-UserGroups <string[]>] [-IconPath <string>] [-IconIndex <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Session', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254069')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RemoteApp])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${Alias},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${DisplayName},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FilePath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_.Trim().Length -gt 0 })]
        [string]
        ${FileVirtualPath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${ShowInWebAccess},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FolderName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue]
        ${CommandLineSetting},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${RequiredCommandLine},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${UserGroups},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${IconPath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${IconIndex},

        [Parameter(ParameterSetName = 'VirtualDesktop', Mandatory = $true)]
        [Alias('VMName')]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDSessionCollection
{
    <#
    .SYNOPSIS
        New-RDSessionCollection [-CollectionName] <string> -SessionHost <string[]> -PersonalUnmanaged [-CollectionDescription <string>] [-ConnectionBroker <string>] [-AutoAssignUser] [-GrantAdministrativePrivilege] [<CommonParameters>]

New-RDSessionCollection [-CollectionName] <string> -SessionHost <string[]> [-CollectionDescription <string>] [-ConnectionBroker <string>] [-PooledUnmanaged] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    [OutputType([Microsoft.RemoteDesktopServices.Management.RDSessionCollection])]
    param (
        [Parameter(ParameterSetName = 'PersonalSessionCollection', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'PooledSessionCollection', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${CollectionDescription},

        [Parameter(Mandatory = $true)]
        [string[]]
        ${SessionHost},

        [string]
        ${ConnectionBroker},

        [Parameter(ParameterSetName = 'PooledSessionCollection')]
        [switch]
        ${PooledUnmanaged},

        [Parameter(ParameterSetName = 'PersonalSessionCollection', Mandatory = $true)]
        [switch]
        ${PersonalUnmanaged},

        [Parameter(ParameterSetName = 'PersonalSessionCollection')]
        [switch]
        ${AutoAssignUser},

        [Parameter(ParameterSetName = 'PersonalSessionCollection')]
        [switch]
        ${GrantAdministrativePrivilege}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDSessionDeployment
{
    <#
    .SYNOPSIS
        New-RDSessionDeployment [-ConnectionBroker] <string> [-SessionHost] <string[]> [[-WebAccessServer] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254050')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${ConnectionBroker},

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]
        ${SessionHost},

        [Parameter(Position = 2)]
        [string]
        ${WebAccessServer}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDVirtualDesktopCollection
{
    <#
    .SYNOPSIS
        New-RDVirtualDesktopCollection [-CollectionName] <string> -PooledManaged -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> -VirtualDesktopAllocation <hashtable> -StorageType <VirtualDesktopStorageType> [-Description <string>] [-UserGroups <string[]>] [-ConnectionBroker <string>] [-CentralStoragePath <string>] [-LocalStoragePath <string>] [-VirtualDesktopTemplateStoragePath <string>] [-Domain <string>] [-OU <string>] [-CustomSysprepUnattendFilePath <string>] [-VirtualDesktopNamePrefix <string>] [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-UserProfileDiskPath <string>] [-MaxUserProfileDiskSizeGB <int>] [-Force] [<CommonParameters>]

New-RDVirtualDesktopCollection [-CollectionName] <string> -PersonalManaged -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> -VirtualDesktopAllocation <hashtable> -StorageType <VirtualDesktopStorageType> [-Description <string>] [-UserGroups <string[]>] [-ConnectionBroker <string>] [-CentralStoragePath <string>] [-LocalStoragePath <string>] [-Domain <string>] [-OU <string>] [-CustomSysprepUnattendFilePath <string>] [-VirtualDesktopNamePrefix <string>] [-AutoAssignPersonalVirtualDesktopToUser] [-GrantAdministrativePrivilege] [-Force] [<CommonParameters>]

New-RDVirtualDesktopCollection [-CollectionName] <string> -PooledUnmanaged -VirtualDesktopName <string[]> [-Description <string>] [-UserGroups <string[]>] [-ConnectionBroker <string>] [-UserProfileDiskPath <string>] [-MaxUserProfileDiskSizeGB <int>] [-Force] [<CommonParameters>]

New-RDVirtualDesktopCollection [-CollectionName] <string> -PersonalUnmanaged -VirtualDesktopName <string[]> [-Description <string>] [-UserGroups <string[]>] [-ConnectionBroker <string>] [-AutoAssignPersonalVirtualDesktopToUser] [-GrantAdministrativePrivilege] [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254090')]
    param (
        [Parameter(ParameterSetName = 'PooledMgd', Mandatory = $true)]
        [switch]
        ${PooledManaged},

        [Parameter(ParameterSetName = 'PersonalMgd', Mandatory = $true)]
        [switch]
        ${PersonalManaged},

        [Parameter(ParameterSetName = 'PooledUnmgd', Mandatory = $true)]
        [switch]
        ${PooledUnmanaged},

        [Parameter(ParameterSetName = 'PersonalUnmgd', Mandatory = $true)]
        [switch]
        ${PersonalUnmanaged},

        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${CollectionName},

        [string]
        ${Description},

        [string[]]
        ${UserGroups},

        [string]
        ${ConnectionBroker},

        [Parameter(ParameterSetName = 'PersonalUnmgd', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PooledUnmgd', Mandatory = $true)]
        [string[]]
        ${VirtualDesktopName},

        [Parameter(ParameterSetName = 'PersonalMgd', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PooledMgd', Mandatory = $true)]
        [string]
        ${VirtualDesktopTemplateName},

        [Parameter(ParameterSetName = 'PersonalMgd', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PooledMgd', Mandatory = $true)]
        [string]
        ${VirtualDesktopTemplateHostServer},

        [Parameter(ParameterSetName = 'PersonalMgd', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PooledMgd', Mandatory = $true)]
        [hashtable]
        ${VirtualDesktopAllocation},

        [Parameter(ParameterSetName = 'PersonalMgd', Mandatory = $true)]
        [Parameter(ParameterSetName = 'PooledMgd', Mandatory = $true)]
        [Microsoft.RemoteDesktopServices.Management.VirtualDesktopStorageType]
        ${StorageType},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${CentralStoragePath},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${LocalStoragePath},

        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${VirtualDesktopTemplateStoragePath},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${Domain},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${OU},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${CustomSysprepUnattendFilePath},

        [Parameter(ParameterSetName = 'PersonalMgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${VirtualDesktopNamePrefix},

        [Parameter(ParameterSetName = 'PooledMgd')]
        [switch]
        ${DisableVirtualDesktopRollback},

        [Parameter(ParameterSetName = 'PooledMgd')]
        [ValidateRange(31, 365)]
        [int]
        ${VirtualDesktopPasswordAge},

        [Parameter(ParameterSetName = 'PooledUnmgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [string]
        ${UserProfileDiskPath},

        [Parameter(ParameterSetName = 'PooledUnmgd')]
        [Parameter(ParameterSetName = 'PooledMgd')]
        [ValidateRange(1, 9999)]
        [int]
        ${MaxUserProfileDiskSizeGB},

        [Parameter(ParameterSetName = 'PersonalUnmgd')]
        [Parameter(ParameterSetName = 'PersonalMgd')]
        [switch]
        ${AutoAssignPersonalVirtualDesktopToUser},

        [Parameter(ParameterSetName = 'PersonalUnmgd')]
        [Parameter(ParameterSetName = 'PersonalMgd')]
        [switch]
        ${GrantAdministrativePrivilege},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function New-RDVirtualDesktopDeployment
{
    <#
    .SYNOPSIS
        New-RDVirtualDesktopDeployment [-ConnectionBroker] <string> [-VirtualizationHost] <string[]> [[-WebAccessServer] <string>] [-CreateVirtualSwitch] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254049')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${ConnectionBroker},

        [Parameter(Mandatory = $true, Position = 1)]
        [string[]]
        ${VirtualizationHost},

        [Parameter(Position = 2)]
        [string]
        ${WebAccessServer},

        [Parameter(Position = 3)]
        [switch]
        ${CreateVirtualSwitch}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDDatabaseConnectionString
{
    <#
    .SYNOPSIS
        Remove-RDDatabaseConnectionString [[-ConnectionBroker] <string>] -DatabaseConnectionString [-Force] [<CommonParameters>]

Remove-RDDatabaseConnectionString [[-ConnectionBroker] <string>] -DatabaseSecondaryConnectionString [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254057')]
    param (
        [Parameter(ParameterSetName = 'DatabaseConnectionString', Mandatory = $true)]
        [switch]
        ${DatabaseConnectionString},

        [Parameter(ParameterSetName = 'DatabaseSecondaryConnectionString', Mandatory = $true)]
        [switch]
        ${DatabaseSecondaryConnectionString},

        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDPersonalSessionDesktopAssignment
{
    <#
    .SYNOPSIS
        Remove-RDPersonalSessionDesktopAssignment [-CollectionName] <string> [-User] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-RDPersonalSessionDesktopAssignment [-CollectionName] <string> [-Name] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'RemoveByUser', SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(ParameterSetName = 'RemoveByDesktop', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'RemoveByUser', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'RemoveByUser', Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${User},

        [Parameter(ParameterSetName = 'RemoveByDesktop', Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${Name},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDPersonalVirtualDesktopAssignment
{
    <#
    .SYNOPSIS
        Remove-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> [-User] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> [-VirtualDesktopName] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'RemoveByUser', SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254100')]
    param (
        [Parameter(ParameterSetName = 'RemoveByDesktop', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'RemoveByUser', Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'RemoveByUser', Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${User},

        [Parameter(ParameterSetName = 'RemoveByDesktop', Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDPersonalVirtualDesktopPatchSchedule
{
    <#
    .SYNOPSIS
        Remove-RDPersonalVirtualDesktopPatchSchedule [[-VirtualDesktopName] <string>] [[-ID] <string>] [[-ConnectionBroker] <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254114')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${VirtualDesktopName},

        [Parameter(Position = 1)]
        [string]
        ${ID},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDRemoteApp
{
    <#
    .SYNOPSIS
        Remove-RDRemoteApp [-CollectionName] <string> -Alias <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254071')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${Alias},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDServer
{
    <#
    .SYNOPSIS
        Remove-RDServer [-Server] <string> [-Role] <string> [[-ConnectionBroker] <string>] [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254052')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${Server},

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('RDS-CONNECTION-BROKER', 'RDS-VIRTUALIZATION', 'RDS-RD-SERVER', 'RDS-WEB-ACCESS', 'RDS-GATEWAY', 'RDS-LICENSING')]
        [string]
        ${Role},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDSessionCollection
{
    <#
    .SYNOPSIS
        Remove-RDSessionCollection [-CollectionName] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDSessionHost
{
    <#
    .SYNOPSIS
        Remove-RDSessionHost [-SessionHost] <string[]> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]
        ${SessionHost},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDVirtualDesktopCollection
{
    <#
    .SYNOPSIS
        Remove-RDVirtualDesktopCollection [-CollectionName] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254092')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Remove-RDVirtualDesktopFromCollection
{
    <#
    .SYNOPSIS
        Remove-RDVirtualDesktopFromCollection [-CollectionName] <string> -VirtualDesktopName <string[]> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254096')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string[]]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Send-RDUserMessage
{
    <#
    .SYNOPSIS
        Send-RDUserMessage [-HostServer] <string> [-UnifiedSessionID] <int> [-MessageTitle] <string> [-MessageBody] <string> [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254077')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${HostServer},

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]
        ${UnifiedSessionID},

        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        ${MessageTitle},

        [Parameter(Mandatory = $true, Position = 3)]
        [string]
        ${MessageBody}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDActiveManagementServer
{
    <#
    .SYNOPSIS
        Set-RDActiveManagementServer [-ManagementServer] <string> [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254055')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${ManagementServer}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDCertificate
{
    <#
    .SYNOPSIS
        Set-RDCertificate [-Role] <RDCertificateRole> [-Password <securestring>] [-ConnectionBroker <string>] [-Force] [<CommonParameters>]

Set-RDCertificate [-Role] <RDCertificateRole> [-ImportPath <string>] [-Password <securestring>] [-ConnectionBroker <string>] [-Force] [<CommonParameters>]

Set-RDCertificate [-Role] <RDCertificateRole> [-Thumbprint <string>] [-ConnectionBroker <string>] [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Reapply', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254048')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [Microsoft.RemoteDesktopServices.Management.RDCertificateRole]
        ${Role},

        [Parameter(ParameterSetName = 'Import')]
        [string]
        ${ImportPath},

        [Parameter(ParameterSetName = 'Thumbprint')]
        [string]
        ${Thumbprint},

        [Parameter(ParameterSetName = 'Reapply')]
        [Parameter(ParameterSetName = 'Import')]
        [securestring]
        ${Password},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDClientAccessName
{
    <#
    .SYNOPSIS
        Set-RDClientAccessName [[-ConnectionBroker] <string>] [-ClientAccessName] <string> [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254056')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${ClientAccessName}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDConnectionBrokerHighAvailability
{
    <#
    .SYNOPSIS
        Set-RDConnectionBrokerHighAvailability [[-ConnectionBroker] <string>] [-DatabaseConnectionString] <string> [[-DatabaseSecondaryConnectionString] <string>] [[-DatabaseFilePath] <string>] [-ClientAccessName] <string> [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254054')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${DatabaseConnectionString},

        [Parameter(Position = 2)]
        [string]
        ${DatabaseSecondaryConnectionString},

        [Parameter(Position = 3)]
        [string]
        ${DatabaseFilePath},

        [Parameter(Mandatory = $true, Position = 4)]
        [string]
        ${ClientAccessName}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDDatabaseConnectionString
{
    <#
    .SYNOPSIS
        Set-RDDatabaseConnectionString [[-DatabaseConnectionString] <string>] [[-DatabaseSecondaryConnectionString] <string>] [[-ConnectionBroker] <string>] [-RestoreDatabaseConnection] [-RestoreDBConnectionOnAllBrokers] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254057')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${DatabaseConnectionString},

        [Parameter(Position = 1)]
        [string]
        ${DatabaseSecondaryConnectionString},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker},

        [Parameter(Position = 3)]
        [switch]
        ${RestoreDatabaseConnection},

        [Parameter(Position = 4)]
        [switch]
        ${RestoreDBConnectionOnAllBrokers}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDDeploymentGatewayConfiguration
{
    <#
    .SYNOPSIS
        Set-RDDeploymentGatewayConfiguration [-GatewayMode] <GatewayUsage> [[-GatewayExternalFqdn] <string>] [[-LogonMethod] <GatewayAuthMode>] [[-UseCachedCredentials] <bool>] [[-BypassLocal] <bool>] [[-ConnectionBroker] <string>] [-Force] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254066')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('DoNotUse', 'Custom', 'Automatic')]
        [Microsoft.RemoteDesktopServices.Management.GatewayUsage]
        ${GatewayMode},

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${GatewayExternalFqdn},

        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.GatewayAuthMode]
        ${LogonMethod},

        [Parameter(Position = 3, ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${UseCachedCredentials},

        [Parameter(Position = 4, ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${BypassLocal},

        [Parameter(Position = 5)]
        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDFileTypeAssociation
{
    <#
    .SYNOPSIS
        Set-RDFileTypeAssociation [-CollectionName] <string> -AppAlias <string> -FileExtension <string> -IsPublished <bool> [-IconPath <string>] [-IconIndex <string>] [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDFileTypeAssociation [-CollectionName] <string> -AppAlias <string> -FileExtension <string> -IsPublished <bool> -VirtualDesktopName <string> [-IconPath <string>] [-IconIndex <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Session', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254073')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${AppAlias},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FileExtension},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${IsPublished},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${IconPath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${IconIndex},

        [Parameter(ParameterSetName = 'VirtualDesktop', Mandatory = $true)]
        [Alias('VMName')]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDLicenseConfiguration
{
    <#
    .SYNOPSIS
        Set-RDLicenseConfiguration -Mode <LicensingMode> [-Force] [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDLicenseConfiguration -Mode <LicensingMode> -LicenseServer <string[]> [-Force] [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDLicenseConfiguration -LicenseServer <string[]> [-Force] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'ModePS', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254064')]
    param (
        [Parameter(ParameterSetName = 'BothPS', Mandatory = $true)]
        [Parameter(ParameterSetName = 'ModePS', Mandatory = $true)]
        [Microsoft.RemoteDesktopServices.Management.LicensingMode]
        ${Mode},

        [Parameter(ParameterSetName = 'BothPS', Mandatory = $true)]
        [Parameter(ParameterSetName = 'LicenseServerPS', Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]
        ${LicenseServer},

        [switch]
        ${Force},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDPersonalSessionDesktopAssignment
{
    <#
    .SYNOPSIS
        Set-RDPersonalSessionDesktopAssignment [-CollectionName] <string> -User <string> -Name <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${User},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${Name},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDPersonalVirtualDesktopAssignment
{
    <#
    .SYNOPSIS
        Set-RDPersonalVirtualDesktopAssignment [-CollectionName] <string> -User <string> -VirtualDesktopName <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254099')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${User},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDPersonalVirtualDesktopPatchSchedule
{
    <#
    .SYNOPSIS
        Set-RDPersonalVirtualDesktopPatchSchedule [-VirtualDesktopName] <string> [-ID] <string> [[-Context] <byte[]>] [[-Deadline] <datetime>] [[-StartTime] <datetime>] [[-EndTime] <datetime>] [[-Label] <string>] [[-Plugin] <string>] [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254116')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${VirtualDesktopName},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${ID},

        [Parameter(Position = 2)]
        [byte[]]
        ${Context},

        [Parameter(Position = 3)]
        [datetime]
        ${Deadline},

        [Parameter(Position = 4)]
        [datetime]
        ${StartTime},

        [Parameter(Position = 5)]
        [datetime]
        ${EndTime},

        [Parameter(Position = 6)]
        [string]
        ${Label},

        [Parameter(Position = 7)]
        [string]
        ${Plugin},

        [Parameter(Position = 8)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDRemoteApp
{
    <#
    .SYNOPSIS
        Set-RDRemoteApp [-CollectionName] <string> -Alias <string> [-DisplayName <string>] [-FilePath <string>] [-FileVirtualPath <string>] [-ShowInWebAccess <bool>] [-FolderName <string>] [-CommandLineSetting <CommandLineSettingValue>] [-RequiredCommandLine <string>] [-UserGroups <string[]>] [-IconPath <string>] [-IconIndex <string>] [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDRemoteApp [-CollectionName] <string> -Alias <string> -VirtualDesktopName <string> [-DisplayName <string>] [-FilePath <string>] [-FileVirtualPath <string>] [-ShowInWebAccess <bool>] [-FolderName <string>] [-CommandLineSetting <CommandLineSettingValue>] [-RequiredCommandLine <string>] [-UserGroups <string[]>] [-IconPath <string>] [-IconIndex <string>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Session', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254070')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${Alias},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${DisplayName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FilePath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ $_.Trim().Length -gt 0 })]
        [string]
        ${FileVirtualPath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${ShowInWebAccess},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FolderName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.CommandLineSettingValue]
        ${CommandLineSetting},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${RequiredCommandLine},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${UserGroups},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${IconPath},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]
        ${IconIndex},

        [Parameter(ParameterSetName = 'VirtualDesktop', Mandatory = $true)]
        [Alias('VMName')]
        [string]
        ${VirtualDesktopName},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDRemoteDesktop
{
    <#
    .SYNOPSIS
        Set-RDRemoteDesktop [-CollectionName] <string> [-ShowInWebAccess] <bool> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254075')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${ShowInWebAccess},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDSessionCollectionConfiguration
{
    <#
    .SYNOPSIS
        Set-RDSessionCollectionConfiguration [-CollectionName] <string> [-CollectionDescription <string>] [-UserGroup <string[]>] [-ClientDeviceRedirectionOptions <RDClientDeviceRedirectionOptions>] [-MaxRedirectedMonitors <int>] [-ClientPrinterRedirected <bool>] [-RDEasyPrintDriverEnabled <bool>] [-ClientPrinterAsDefault <bool>] [-TemporaryFoldersPerSession <bool>] [-BrokenConnectionAction <RDBrokenConnectionAction>] [-TemporaryFoldersDeletedOnExit <bool>] [-AutomaticReconnectionEnabled <bool>] [-ActiveSessionLimitMin <int>] [-DisconnectedSessionLimitMin <int>] [-IdleSessionLimitMin <int>] [-AuthenticateUsingNLA <bool>] [-EncryptionLevel <RDEncryptionLevel>] [-SecurityLayer <RDSecurityLayer>] [-LoadBalancing <RDSessionHostCollectionLoadBalancingInstance[]>] [-CustomRdpProperty <string>] [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDSessionCollectionConfiguration [-CollectionName] <string> -DisableUserProfileDisk [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDSessionCollectionConfiguration [-CollectionName] <string> -EnableUserProfileDisk -MaxUserProfileDiskSizeGB <int> -DiskPath <string> [-IncludeFolderPath <string[]>] [-ExcludeFolderPath <string[]>] [-IncludeFilePath <string[]>] [-ExcludeFilePath <string[]>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254081')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionDescription},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${UserGroup},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]
        ${ClientDeviceRedirectionOptions},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 16)]
        [int]
        ${MaxRedirectedMonitors},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${ClientPrinterRedirected},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${RDEasyPrintDriverEnabled},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${ClientPrinterAsDefault},

        [Parameter(ParameterSetName = 'Default')]
        [bool]
        ${TemporaryFoldersPerSession},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.RDBrokenConnectionAction]
        ${BrokenConnectionAction},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${TemporaryFoldersDeletedOnExit},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${AutomaticReconnectionEnabled},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [int]
        ${ActiveSessionLimitMin},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [int]
        ${DisconnectedSessionLimitMin},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [int]
        ${IdleSessionLimitMin},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${AuthenticateUsingNLA},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.RDEncryptionLevel]
        ${EncryptionLevel},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.RDSecurityLayer]
        ${SecurityLayer},

        [Parameter(ParameterSetName = 'DisableUserProfileDisk', Mandatory = $true)]
        [switch]
        ${DisableUserProfileDisk},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', Mandatory = $true)]
        [switch]
        ${EnableUserProfileDisk},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${IncludeFolderPath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${ExcludeFolderPath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${IncludeFilePath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${ExcludeFilePath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 9999)]
        [int]
        ${MaxUserProfileDiskSizeGB},

        [Parameter(ParameterSetName = 'EnableUserProfileDisk', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${DiskPath},

        [Parameter(ParameterSetName = 'Default')]
        [Microsoft.RemoteDesktopServices.Management.RDSessionHostCollectionLoadBalancingInstance[]]
        ${LoadBalancing},

        [Parameter(ParameterSetName = 'Default', ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CustomRdpProperty},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDSessionHost
{
    <#
    .SYNOPSIS
        Set-RDSessionHost [-SessionHost] <string[]> [-NewConnectionAllowed] <RDServerNewConnectionAllowed> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=390820')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]
        ${SessionHost},

        [Parameter(Mandatory = $true, Position = 1)]
        [Microsoft.RemoteDesktopServices.Management.RDServerNewConnectionAllowed]
        ${NewConnectionAllowed},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDVirtualDesktopCollectionConfiguration
{
    <#
    .SYNOPSIS
        Set-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> [-CollectionDescription <string>] [-ClientDeviceRedirectionOptions <RDClientDeviceRedirectionOptions>] [-RedirectAllMonitors <bool>] [-RedirectClientPrinter <bool>] [-SaveDelayMinutes <int>] [-UserGroups <string[]>] [-AutoAssignPersonalVirtualDesktopToUser <bool>] [-GrantAdministrativePrivilege <bool>] [-CustomRdpProperty <string>] [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> -DisableUserProfileDisks [-ConnectionBroker <string>] [<CommonParameters>]

Set-RDVirtualDesktopCollectionConfiguration [-CollectionName] <string> -EnableUserProfileDisks -MaxUserProfileDiskSizeGB <int> -DiskPath <string> [-IncludeFolderPath <string[]>] [-ExcludeFolderPath <string[]>] [-IncludeFilePath <string[]>] [-ExcludeFilePath <string[]>] [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'General', HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254112')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionDescription},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [Microsoft.RemoteDesktopServices.Management.RDClientDeviceRedirectionOptions]
        ${ClientDeviceRedirectionOptions},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${RedirectAllMonitors},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [bool]
        ${RedirectClientPrinter},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [int]
        ${SaveDelayMinutes},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${UserGroups},

        [Parameter(ParameterSetName = 'General')]
        [bool]
        ${AutoAssignPersonalVirtualDesktopToUser},

        [Parameter(ParameterSetName = 'General')]
        [bool]
        ${GrantAdministrativePrivilege},

        [Parameter(ParameterSetName = 'General', ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CustomRdpProperty},

        [Parameter(ParameterSetName = 'DisableUserProfileDisks', Mandatory = $true)]
        [switch]
        ${DisableUserProfileDisks},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', Mandatory = $true)]
        [switch]
        ${EnableUserProfileDisks},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${IncludeFolderPath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${ExcludeFolderPath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${IncludeFilePath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${ExcludeFilePath},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 9999)]
        [int]
        ${MaxUserProfileDiskSizeGB},

        [Parameter(ParameterSetName = 'EnableUserProfileDisks', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${DiskPath},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDVirtualDesktopConcurrency
{
    <#
    .SYNOPSIS
        Set-RDVirtualDesktopConcurrency [-ConcurrencyFactor] <int> [[-HostServer] <string[]>] [-ConnectionBroker <string>] [-BatchSize <int>] [<CommonParameters>]

Set-RDVirtualDesktopConcurrency [-Allocation] <hashtable> [-ConnectionBroker <string>] [-BatchSize <int>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254104')]
    param (
        [Parameter(ParameterSetName = 'Default', Mandatory = $true, Position = 0)]
        [ValidateRange(1, 100)]
        [int]
        ${ConcurrencyFactor},

        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [string[]]
        ${HostServer},

        [Parameter(ParameterSetName = 'Allocation', Mandatory = $true, Position = 0)]
        [hashtable]
        ${Allocation},

        [string]
        ${ConnectionBroker},

        [ValidateRange(1, 100)]
        [int]
        ${BatchSize}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDVirtualDesktopIdleCount
{
    <#
    .SYNOPSIS
        Set-RDVirtualDesktopIdleCount [-IdleCount] <int> [[-HostServer] <string[]>] [-ConnectionBroker <string>] [-BatchSize <int>] [<CommonParameters>]

Set-RDVirtualDesktopIdleCount [-Allocation] <hashtable> [-ConnectionBroker <string>] [-BatchSize <int>] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254109')]
    param (
        [Parameter(ParameterSetName = 'Default', Mandatory = $true, Position = 0)]
        [int]
        ${IdleCount},

        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [string[]]
        ${HostServer},

        [Parameter(ParameterSetName = 'Allocation', Mandatory = $true, Position = 0)]
        [hashtable]
        ${Allocation},

        [string]
        ${ConnectionBroker},

        [ValidateRange(1, 100)]
        [int]
        ${BatchSize}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDVirtualDesktopTemplateExportPath
{
    <#
    .SYNOPSIS
        Set-RDVirtualDesktopTemplateExportPath [[-ConnectionBroker] <string>] [-Path] <string> [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254060')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${Path}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Set-RDWorkspace
{
    <#
    .SYNOPSIS
        Set-RDWorkspace [-Name] <string> [-ConnectionBroker <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254118')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        ${Name},

        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Stop-RDVirtualDesktopCollectionJob
{
    <#
    .SYNOPSIS
        Stop-RDVirtualDesktopCollectionJob [-CollectionName] <string> [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254098')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Test-RDOUAccess
{
    <#
    .SYNOPSIS
        Test-RDOUAccess [[-Domain] <string>] [-OU] <string> [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkId=254061')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${Domain},

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        ${OU},

        [Parameter(Position = 2)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Test-RDVirtualDesktopADMachineAccountReuse
{
    <#
    .SYNOPSIS
        Test-RDVirtualDesktopADMachineAccountReuse [[-ConnectionBroker] <string>] [<CommonParameters>]
    #>

    [CmdletBinding(HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254108')]
    param (
        [Parameter(Position = 0)]
        [string]
        ${ConnectionBroker}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}

function Update-RDVirtualDesktopCollection
{
    <#
    .SYNOPSIS
        Update-RDVirtualDesktopCollection [-CollectionName] <string> -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Update-RDVirtualDesktopCollection [-CollectionName] <string> -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> -StartTime <datetime> -ForceLogoffTime <datetime> [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Update-RDVirtualDesktopCollection [-CollectionName] <string> -VirtualDesktopTemplateName <string> -VirtualDesktopTemplateHostServer <string> -ForceLogoffTime <datetime> [-DisableVirtualDesktopRollback] [-VirtualDesktopPasswordAge <int>] [-ConnectionBroker <string>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Now', SupportsShouldProcess = $true, ConfirmImpact = 'Medium', HelpUri = 'http://go.microsoft.com/fwlink/?LinkId=254094')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${CollectionName},

        [Parameter(Mandatory = $true)]
        [string]
        ${VirtualDesktopTemplateName},

        [Parameter(Mandatory = $true)]
        [string]
        ${VirtualDesktopTemplateHostServer},

        [switch]
        ${DisableVirtualDesktopRollback},

        [ValidateRange(31, 365)]
        [int]
        ${VirtualDesktopPasswordAge},

        [string]
        ${ConnectionBroker},

        [switch]
        ${Force},

        [Parameter(ParameterSetName = 'OnUserLogoff', Mandatory = $true)]
        [datetime]
        ${StartTime},

        [Parameter(ParameterSetName = 'OnSchedule', Mandatory = $true)]
        [Parameter(ParameterSetName = 'OnUserLogoff', Mandatory = $true)]
        [datetime]
        ${ForceLogoffTime}
    )
    end
    {
        throw '{0}: StubNotImplemented' -f $MyInvocation.MyCommand
    }
}
