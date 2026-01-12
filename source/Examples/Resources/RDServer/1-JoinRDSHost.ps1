<#
    .DESCRIPTION
        This example shows how to join a RDSH host to a deployment.
#>

configuration Example
{
    Import-DscResource -ModuleName 'RemoteDesktopServicesDsc'

    node localhost {

        RDServer RemoteDesktopSessionHost {
            ConnectionBroker = 'connectionbroker.server.fqdn'
            Server           = 'sessionhost.server.fqdn'
            Role             = 'RDS-RD-Server'
        }
    }
}
