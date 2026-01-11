<#
    .DESCRIPTION
        This example shows how to ensure a session collection is created.
#>

configuration Example
{
    Import-DscResource -ModuleName 'RemoteDesktopServicesDsc'

    node localhost {

        xRDSessionCollection 'MyCollection' {
            CollectionName        = 'ExampleApplications'
            SessionHost           = 'sessionhost.server.fqdn'
            ConnectionBroker      = 'connectionbroker.server.fqdn'
            CollectionDescription = 'A collection to deploy example applications'
        }
    }
}
