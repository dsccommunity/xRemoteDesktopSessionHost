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
        [System.String] $Role,

        [Parameter(Mandatory = $true)]
        [System.String] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String] $ImportPath,

        [Parameter(Mandatory = $true)]
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "global:DSCMachineStatus")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String] $Role,

        [Parameter(Mandatory = $true)]
        [System.String] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String] $ImportPath,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    try
    {
        Set-RDCertificate -Role $Role -ConnectionBroker $ConnectionBroker -ImportPath $ImportPath -Password $Credential.Password -Force
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
        [System.String] $Role,

        [Parameter(Mandatory = $true)]
        [System.String] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [System.String] $ImportPath,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $pfxCertificate = (Get-PfxData -FilePath $ImportPath -Password ($Credential).Password).EndEntityCertificates
    $currentCertificate = Get-TargetResource @PSBoundParameters

    $currentCertificate.Thumbprint -eq $pfxCertificate.Thumbprint
}

Export-ModuleMember -Function *-TargetResource
