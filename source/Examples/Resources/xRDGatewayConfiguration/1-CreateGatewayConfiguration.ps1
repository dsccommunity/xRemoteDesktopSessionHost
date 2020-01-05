<#
    .DESCRIPTION
        This example shows how to ensure that the Remote Desktop Gateway is setup.
#>

Configuration Example
{
    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    Node localhost {

        xRDGatewayConfiguration MyGateway {
            ConnectionBroker = 'connectionbroker.server.fqdn'
            GatewayServer = 'gateway.server.fqdn'
            GatewayMode = 'Automatic'
            ExternalFqdn = 'gateway.external.fqdn'
            LogonMethod = 'AllowUserToSelectDuringConnection'
            UseCachedCredentials = $false
            BypassLocal = $false
        }
    }
}
