<#
    .DESCRIPTION
        This example shows how to ensure a session deployment is created.
#>

Configuration Example
{
    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    Node localhost {

        xRDSessionDeployment RDSDeployment {
            SessionHost = 'rdsessionhost.server.fqdn'
            ConnectionBroker = 'connectionbroker.server.fqdn'
            WebAccessServer =  'webaccess.server.fqdn'
        }
    }
}
