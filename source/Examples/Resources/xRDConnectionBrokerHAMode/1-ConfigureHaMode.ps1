<#
    .DESCRIPTION
        This example shows how to configure HA mode on a connection broker.
#>

configuration Example
{
    Import-DscResource -ModuleName 'xRemoteDesktopSessionHost'

    node localhost {

        xRDConnectionBrokerHAMode MyGateway {
            ConnectionBroker         = 'RDCB1'
            DatabaseConnectionString = 'DRIVER=SQL Server Native Client 11.0;SERVER=RDDB1;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=RDS'
            ClientAccessName         = 'rdsfarm.contoso.com'
        }
    }
}
