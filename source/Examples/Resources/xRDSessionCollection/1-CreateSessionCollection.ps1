<#
    .DESCRIPTION
        This example shows how to ensure a session collection is created.
#>

Configuration Example
{
    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    Node localhost {

        xRDSessionCollection 'MyCollection' {
            CollectionName = 'ExampleApplications'
            SessionHost = 'sessionhost.server.fqdn'
            ConnectionBroker = 'connectionbroker.server.fqdn'
            CollectionDescription = 'A collection to deploy example applications'
        }
    }
}
