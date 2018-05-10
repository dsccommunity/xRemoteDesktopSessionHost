Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}
Import-Module RemoteDesktop

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource 
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [Parameter()]
        [string[]] 
        $LicenseServers,
        
        [Parameter()]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        [string] 
        $LicenseMode
    )

    $result = $null

    Write-Verbose "Getting RD License server configuration from broker '$ConnectionBroker'..."    
    
    $config = Get-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker -ea SilentlyContinue

    if ($config)   # Microsoft.RemoteDesktopServices.Management.LicensingSetting 
    {
    Write-Verbose "configuration retrieved successfully:"
    }

    $result = 
    @{
        "ConnectionBroker" = $ConnectionBroker
        "LicenseServers"   = $config.LicenseServer          
        "LicenseMode"      = $config.Mode.ToString()  # Microsoft.RemoteDesktopServices.Management.LicensingMode  .ToString()
    }

    Write-Verbose ">> RD License mode:     $($result.LicenseMode)"
    Write-Verbose ">> RD License servers:  $($result.LicenseServers -join '; ')"

    else 
    {
        Write-Verbose "Failed to retrieve RD License configuration from broker '$ConnectionBroker'."
    }

    $result
}


######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource 
{
    [CmdletBinding()]
    param
    (    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [Parameter()]
        [string[]] 
        $LicenseServers,
        
        [Parameter()]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        [string] 
        $LicenseMode
    )
    
    Write-Verbose "Starting RD License server configuration..."
    Write-Verbose ">> RD Connection Broker:  $($ConnectionBroker.ToLower())"

    if ($LicenseServers) 
    {
        Write-Verbose ">> RD License servers:    $($LicenseServers -join '; ')"

        Write-Verbose "calling Set-RDLicenseConfiguration cmdlet..."
        Set-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker -LicenseServer $LicenseServers -Mode $LicenseMode -Force
    }
    else 
    {
        Write-Verbose "calling Set-RDLicenseConfiguration cmdlet..."
        Set-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker -Mode $LicenseMode -Force
    }

    Write-Verbose "Set-RDLicenseConfiguration done."
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource 
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ConnectionBroker,
        
        [Parameter()]
        [string[]] 
        $LicenseServers,
        
        [Parameter()]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]
        [string] $LicenseMode
    )

    $config = Get-TargetResource @PSBoundParameters
    
    if ($config) 
    {
        Write-Verbose "verifying RD Licensing mode..."

        $result = ($config.LicenseMode -eq $LicenseMode)
    }
    else 
    {
        Write-Verbose "Failed to retrieve RD License server configuration from broker '$ConnectionBroker'."
        $result = $false
    }

    Write-Verbose "Test-TargetResource returning:  $result"
    return $result
}


Export-ModuleMember -Function *-TargetResource
