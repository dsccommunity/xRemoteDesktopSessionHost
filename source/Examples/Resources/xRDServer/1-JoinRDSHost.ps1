<#
    .DESCRIPTION
        This example shows how to join a RDSH host to a deployment.
#>

Configuration Example
{

    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    Node localhost {

        xRDServer RemoteDesktopSessionHost {
            ConnectionBroker = 'connectionbroker.server.fqdn'
            Server = 'sessionhost.server.fqdn'
            Role = 'RDS-RD-Server'
        }
    }
}
