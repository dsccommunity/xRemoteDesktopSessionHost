Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (-not (Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw 'The minimum OS requirement was not met.'
}
Import-Module RemoteDesktop -Global
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

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

    Write-Verbose -Message (
        $script:localizedData.VerboseGetCertificate -f $Role, $ConnectionBroker
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
        Role             = $Role
        ConnectionBroker = $ConnectionBroker
        ImportPath       = $ImportPath
        Force            = $true
        ErrorAction      = 'Stop'
    }

    if ($Credential -ne [pscredential]::Empty)
    {
        $rdCertificateSplat.Add('Password', $Credential.Password)
    }

    try
    {
        Write-Verbose -Message (
            $script:localizedData.VerboseSetCertificate -f $Role, $ImportPath
        )

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
        FilePath    = $ImportPath
        ErrorAction = 'Stop'
    }

    if ($Credential -ne [pscredential]::Empty)
    {
        $getPfxDataSplat.Add('Password', $Credential.Password)
    }

    $currentCertificate = Get-TargetResource @PSBoundParameters
    Write-Verbose -Message (
        $script:localizedData.VerboseCurrentCertificate -f $Role, $currentCertificate.Thumbprint
    )

    try
    {
        $pfxCertificate = (Get-PfxData @getPfxDataSplat).EndEntityCertificates
        Write-Verbose -Message (
            $script:localizedData.VerbosePfxCertificate -f $Role, $pfxCertificate.Thumbprint
        )

        return ($currentCertificate.Thumbprint -eq $pfxCertificate.Thumbprint)
    }
    catch
    {
        Write-Warning -Message (
            $script:localizedData.WarningPfxDataImportFailed -f $ImportPath, $_
        )

        return $false
    }
}

Export-ModuleMember -Function *-TargetResource
