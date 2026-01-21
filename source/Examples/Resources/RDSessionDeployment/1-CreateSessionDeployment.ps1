<#
    .DESCRIPTION
        This example shows how to ensure a session deployment is created.
#>

configuration Example
{
    Import-DscResource -ModuleName 'RemoteDesktopServicesDsc'

    node localhost {

        RDSessionDeployment RDSDeployment {
            SessionHost      = 'rdsessionhost.server.fqdn'
            ConnectionBroker = 'connectionbroker.server.fqdn'
            WebAccessServer  = 'webaccess.server.fqdn'
        }
    }
}
