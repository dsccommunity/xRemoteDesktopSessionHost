Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw "The minimum OS requirement was not met."
}
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
        [ValidateLength(1,256)]
        [string] $CollectionName,

        [Parameter(Mandatory = $true)]
        [string] $SessionHost,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string] $Ensure = 'Present',

        [Parameter()]
        [string] $CollectionDescription,

        [Parameter()]
        [string] $ConnectionBroker,

        [Parameter()]
        [ValidateSet('Yes', 'NotUntilReboot', 'No')]
        [string] $NewConnectionAllowed = 'Yes'
    )

    $returnvalues = @{
        "Ensure" = "Absent"
        "CollectionName" = $Null
        "CollectionDescription" = $Null
        "SessionHost" = $Null
        "ConnectionBroker" = $Null
        "NewConnectionAllowed" = $Null
    }

    Write-Verbose "Getting information about RDSH collection."
    $TargetCollection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    
    if ($TargetCollection) 
    {
        $returnvalues["Ensure"] = "Present"
        $returnvalues["CollectionName"] = $CollectionName
        $returnvalues["CollectionDescription"] = $CollectionDescription
        $returnvalues["ConnectionBroker"] = $ConnectionBroker

        $TargetSessionhost = Get-RDSessionHost -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker | Where-Object -property Sessionhost -eq $SessionHost

        if ($TargetSessionhost) 
        {
            $returnvalues["SessionHost"] = $SessionHost
            $returnvalues["NewConnectionAllowed"] = $TargetSessionhost.NewConnectionAllowed
        }
    }
    
    $returnvalues
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
        [ValidateLength(1,256)]
        [string] $CollectionName,

        [Parameter(Mandatory = $true)]
        [string] $SessionHost,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string] $Ensure = 'Present',

        [Parameter()]
        [string] $CollectionDescription,

        [Parameter()]
        [string] $ConnectionBroker,

        [Parameter()]
        [ValidateSet('Yes', 'NotUntilReboot', 'No')]
        [string] $NewConnectionAllowed = 'Yes'
    )

    $Targetresource = Get-TargetResource @PSBoundParameters

    if ($Targetresource['Ensure'] -eq 'Present') 
    {
        if ($Ensure -eq 'Present') 
        {
            if ($Null -eq $Targetresource['Sessionhost']) 
            {
                Write-Verbose "Sessionhost was not found in Collection. Adding it."
                Add-RDSessionHost -Connectionbroker $ConnectionBroker -Sessionhost $SessionHost -CollectionName $CollectionName -ErrorAction 'Stop'
            }
            if (($Null -ne $Targetresource['NewConnectionAllowed']) -and ($Targetresource['NewConnectionAllowed'] -ne $NewConnectionAllowed)) 
            {
                Write-Verbose "Setting right Value for NewConnectionAllowed."                
                Set-RDSessionHost -Connectionbroker $ConnectionBroker -Sessionhost $SessionHost -NewConnectionAllowed $NewConnectionAllowed -ErrorAction 'Stop'
            }      
        }
        elseif ($Ensure -eq 'Absent')
        {
            if ($Targetresource['SessionHost'] -eq $SessionHost) 
            {
                Write-Verbose "Removing Sessionhost from Collection. "
                Remove-RDSessionHost -Connectionbroker $ConnectionBroker -Sessionhost $SessionHost -ErrorAction 'Stop'
            }
        }
    }
    else
    {
        
        if ($Ensure -eq 'Present') 
        {
            Write-Verbose "Creating a new RDSH collection."

            $NewRDSessionCollection = @{} + $PSBoundParameters
            $NewRDSessionCollection.Remove('Ensure')
            $NewRDSessionCollection.Remove('NewConnectionAllowed')
            
            New-RDSessionCollection @NewRDSessionCollection -ErrorAction 'Stop'

            Set-RDSessionHost -Connectionbroker $ConnectionBroker -Sessionhost $SessionHost -NewConnectionAllowed $NewConnectionAllowed -ErrorAction 'Stop'
        }
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
        [ValidateLength(1,256)]
        [string] $CollectionName,

        [Parameter(Mandatory = $true)]
        [string] $SessionHost,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string] $Ensure = 'Present',

        [Parameter()]
        [string] $CollectionDescription,

        [Parameter()]
        [string] $ConnectionBroker,

        [Parameter()]
        [ValidateSet('Yes', 'NotUntilReboot', 'No')]
        [string] $NewConnectionAllowed = 'Yes'
    )

    $Targetresource = Get-TargetResource @PSBoundParameters
    $IsInDesiredState = $true

    Write-Verbose "Checking for existence of RDSH collection."
    if ($Targetresource['Ensure'] -ne $Ensure)
    {
        Write-Verbose "SessionCollection not found."
        $IsInDesiredState = $false
    }

    if ($Targetresource['Sessionhost'] -ne $SessionHost)
    {
        Write-Verbose "Sessionhost was not found in SessionCollection."
        $IsInDesiredState = $false
    }

    if ($Targetresource['NewConnectionAllowed'] -ne $NewConnectionAllowed)
    {
        Write-Verbose "NewConnectionAllowed is not set correct."
        $IsInDesiredState = $false
    }

    $IsInDesiredState
}

Export-ModuleMember -Function *-TargetResource
