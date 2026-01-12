<#PSScriptInfo
.VERSION 1.0.0
.GUID 627c0685-8348-4514-bbf7-f7616b814a53
.AUTHOR DSC Community
.COMPANYNAME DSC Community
.COPYRIGHT DSC Community contributors. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/RemoteDesktopServicesDsc/blob/main/LICENSE
.PROJECTURI https://github.com/dsccommunity/RemoteDesktopServicesDsc
.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>
#requires -Module RemoteDesktopServicesDsc

configuration xRDSessionCollection_Full
{
    Import-DscResource -modulename RemoteDesktopServicesDsc

    node localhost
    {
        RDSessionCollection WeLoveDsc
        {
            ConnectionBroker = 'RDCB1.contoso.com'
            CollectionName   = 'WeLoveDsc'
            SessionHost      = 'RDSH1.contoso.com', 'RDSH2.contoso.com'
        }
    }
}
