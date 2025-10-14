<#
    .DESCRIPTION
        This example shows how to ensure a session deployment is created.
#>

configuration Example
{
    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    node localhost {

        xRDSessionDeployment RDSDeployment {
            SessionHost      = 'rdsessionhost.server.fqdn'
            ConnectionBroker = 'connectionbroker.server.fqdn'
            WebAccessServer  = 'webaccess.server.fqdn'
        }
    }
}
