Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}
Import-Module RemoteDesktop
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_xRDCertificateConfiguration'

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
        [ValidateSet('RDRedirector', 'RDPublishing', 'RDWebAccess', 'RDGateway')]
        [System.String]
        $Role,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ImportPath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Get-RDCertificate -Role $Role -ConnectionBroker $ConnectionBroker
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
        [ValidateSet('RDRedirector', 'RDPublishing', 'RDWebAccess', 'RDGateway')]
        [System.String]
        $Role,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ImportPath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $rdCertificateSplat = @{
        Role = $Role
        ConnectionBroker = $ConnectionBroker
        ImportPath = $ImportPath
        Force = $true
    }

    if ($Credential -ne [pscredential]::Empty)
    {
        $rdCertificateSplat.Add('Password', $Credential.Password)
    }

    try
    {
        Set-RDCertificate @rdCertificateSplat
    }
    catch
    {
        Write-Error -Message (
            $script:localizedData.ErrorSettingCertificate -f $ImportPath, $Role, $ConnectionBroker, $_
        )
    }
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
        [ValidateSet('RDRedirector', 'RDPublishing', 'RDWebAccess', 'RDGateway')]
        [System.String]
        $Role,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ImportPath,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $getPfxDataSplat = @{
        FilePath = $ImportPath
    }

    if ($Credential -ne [pscredential]::Empty)
    {
        $getPfxDataSplat.Add('Password', $Credential.Password)
    }

    $pfxCertificate = (Get-PfxData @getPfxDataSplat).EndEntityCertificates
    $currentCertificate = Get-TargetResource @PSBoundParameters

    $currentCertificate.Thumbprint -eq $pfxCertificate.Thumbprint
}

Export-ModuleMember -Function *-TargetResource
