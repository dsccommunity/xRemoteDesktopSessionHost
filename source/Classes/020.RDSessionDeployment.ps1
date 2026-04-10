<#
    .SYNOPSIS
        The `RDSessionDeployment` DSC resource is used to configure the Remote Desktop Session Deployment.

    .DESCRIPTION
        This resource is used to configure the Remote Desktop Session Deployment.

        ## Requirements

        - Target machine must be running Windows Server 2012 or later.

        ## Known issues

        All issues are not listed here, see [all open issues](https://github.com/dsccommunity/RemoteDesktopServicesDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+RDSessionDeployment).

    .PARAMETER ConnectionBroker
        Specifies the FQDN of a server to host the RD Connection Broker role service.

    .PARAMETER SessionHost
        Specifies the FQDNs of the servers to host the RD Session Host role service.

    .PARAMETER WebAccessServer
        Specifies the FQDN of a server to host the RD Web Access role service.

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>

[DscResource()]
class RDSessionDeployment : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $ConnectionBroker

    [DscProperty(Mandatory)]
    [System.String[]]
    $SessionHost

    [DscProperty()]
    [System.String[]]
    $WebAccessServer

    [DscProperty(NotConfigurable)]
    [RDSReason[]]
    $Reasons

    RDSessionDeployment () : base ($PSScriptRoot)
    {
        $this.ExcludeDscProperties = @()
    }

    [RDSessionDeployment] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    hidden [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $deployed = Get-RDServer -ConnectionBroker $properties.ConnectionBroker -ErrorAction SilentlyContinue

        return @{
            SessionHost      = [System.String[]] ($deployed.Where({ $_.Roles -contains 'RDS-RD-SERVER' })).Server
            WebAccessServer  = [System.String[]] ($deployed.Where({ $_.Roles -contains 'RDS-WEB-ACCESS' })).Server
        }
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        if ($properties.ContainsKey('ConnectionBroker'))
        {
            $parameters = @{
                ConnectionBroker = $properties.ConnectionBroker
                SessionHost      = $this.SessionHost
                WebAccessServer  = $this.WebAccessServer | Select-Object -First 1
            }

            New-RDSessionDeployment @parameters
            Set-DscMachineRebootRequired
            return
        }

        if ($properties.ContainsKey('SessionHost'))
        {
            $currentValues = $this.PropertiesNotInDesiredState.Where({ $_.Property -eq 'SessionHost' }).ActualValue
            foreach ($server in ($properties.SessionHost.Where({ $_ -notin $currentValues })))
            {
                $this.AddRole($server, 'RDS-RD-SERVER')
            }

            foreach ($server in ($currentValues.Where({ $_ -notin $properties.SessionHost })))
            {
                $this.RemoveRole($server, 'RDS-RD-SERVER')
            }
        }

        if ($properties.ContainsKey('WebAccessServer'))
        {
            $currentValues = $this.PropertiesNotInDesiredState.Where({ $_.Property -eq 'WebAccessServer' }).ActualValue
            foreach ($server in ($properties.WebAccessServer.Where({ $_ -notin $currentValues })))
            {
                $this.AddRole($server, 'RDS-WEB-ACCESS')
            }

            foreach ($server in ($currentValues.Where({ $_ -notin $properties.WebAccessServer })))
            {
                $this.RemoveRole($server, 'RDS-WEB-ACCESS')
            }
        }
    }

    hidden [void] AddRole([System.String] $server, [System.String] $role)
    {
        Write-Verbose ($this.localizedData.RDSessionDeployment_AddingToDeployment -f $server, $role)
        $null = Add-RDServer -Server $server -Role $role -ConnectionBroker $this.ConnectionBroker
    }

    hidden [void] RemoveRole([System.String] $server, [System.String] $role)
    {
        Write-Verbose ($this.localizedData.RDSessionDeployment_RemovingFromDeployment -f $server, $role)
        $null = Remove-RDServer -Server $server -Role $role -ConnectionBroker $this.ConnectionBroker -Force
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        if (-not (Test-RemoteDesktopServicesDscOsRequirement))
        {
            New-InvalidOperationException -Message $this.localizedData.RDSessionDeployment_OSRequirementNotMet
        }

        # Module Import in verbose mode outputs lots of data, so redirecting to null.
        Import-RemoteDesktopModule 4>&1 > $null
    }
}
