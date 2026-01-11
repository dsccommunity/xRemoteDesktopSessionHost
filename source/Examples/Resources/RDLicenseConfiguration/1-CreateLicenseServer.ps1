<#
    .DESCRIPTION
        This example shows how to ensure that the Remote Desktop Licensing is setup in the correct mode.
#>

configuration Example
{

    Import-DscResource -ModuleName 'RemoteDesktopServicesDsc'

    node localhost {

        xRDLicenseConfiguration MyLicenseServer {
            ConnectionBroker = 'connectionbroker.server.fqdn'
            LicenseMode      = 'PerUser'
            LicenseServer    = 'license.server.fqdn'
        }
    }
}
