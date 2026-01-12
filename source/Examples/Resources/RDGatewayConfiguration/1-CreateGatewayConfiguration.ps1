<#
    .DESCRIPTION
        This example shows how to ensure that the Remote Desktop Gateway is setup.
#>

configuration Example
{
    Import-DscResource -ModuleName 'RemoteDesktopServicesDsc'

    node localhost {

        RDGatewayConfiguration MyGateway {
            ConnectionBroker     = 'connectionbroker.server.fqdn'
            GatewayServer        = 'gateway.server.fqdn'
            GatewayMode          = 'Automatic'
            ExternalFqdn         = 'gateway.external.fqdn'
            LogonMethod          = 'AllowUserToSelectDuringConnection'
            UseCachedCredentials = $false
            BypassLocal          = $false
        }
    }
}
