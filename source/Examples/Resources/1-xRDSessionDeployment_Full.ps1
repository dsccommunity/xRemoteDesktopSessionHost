﻿<#PSScriptInfo
.VERSION 1.0.0
.GUID 627c0685-8348-4514-bbf7-f7716b814a53
.AUTHOR DSC Community
.COMPANYNAME DSC Community
.COPYRIGHT DSC Community contributors. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/dsccommunity/xRemoteDesktopSessionHost/blob/master/LICENSE
.PROJECTURI https://github.com/dsccommunity/xRemoteDesktopSessionHost
.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
First version.
.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core
#>
#requires -Module xRemoteDesktopSessionHost

configuration xRDSessionDeployment_Full
{
    import-dscresource -modulename xRemoteDesktopSessionHost

    node localhost
    {
        xRDSessionDeployment TheBigDeployment
        {
            ConnectionBroker = 'RDBC1.contoso.com'
            WebAccessServer = 'RDWA1.contoso.com'
            SessionHost = 'RDSH1.contoso.com', 'RDSH2.contoso.com'
        }
    }
}
