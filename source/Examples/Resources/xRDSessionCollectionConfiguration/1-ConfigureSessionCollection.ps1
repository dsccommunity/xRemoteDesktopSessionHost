<#
    .DESCRIPTION
        This example shows how to ensure a session collection is configured.
#>

configuration Example
{
    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    node localhost {

        xRDSessionCollectionConfiguration 'ExampleApplications' {
            CollectionName                 = 'ExampleApplications'
            CollectionDescription          = 'A collection to deploy example applications'
            ConnectionBroker               = 'connectionbroker.server.fqdn'
            UserGroup                      = 'DOMAIN\AllowedUsersGroup'
            ActiveSessionLimitMin          = 0
            BrokenConnectionAction         = 'Disconnect'
            AutomaticReconnectionEnabled   = $True
            DisconnectedSessionLimitMin    = 30
            IdleSessionLimitMin            = 1440 # One day
            TemporaryFoldersDeletedOnExit  = $True
            RDEasyPrintDriverEnabled       = 0
            MaxRedirectedMonitors          = 16
            ClientPrinterRedirected        = 0
            ClientDeviceRedirectionOptions = 'AudioVideoPlayBack, AudioRecording, Clipboard'
            ClientPrinterAsDefault         = 0
            AuthenticateUsingNLA           = $True
            EncryptionLevel                = 'High'
            SecurityLayer                  = 'SSL'
            EnableUserProfileDisk          = $True
            DiskPath                       = '\\file.server.fqdn\RDSProfileShare'
            MaxUserProfileDiskSizeGB       = 5
        }
    }
}
