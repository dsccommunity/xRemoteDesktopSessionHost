<#
    .DESCRIPTION
        This example shows how to ensure that the Remote Desktop Licensing is setup in the correct mode.
#>

Configuration Example
{

    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    Node localhost {

        xRDLicenseConfiguration MyLicenseServer {
            ConnectionBroker = 'connectionbroker.server.fqdn'
            LicenseMode = 'PerUser'
            LicenseServer = 'license.server.fqdn'
        }
    }
}
