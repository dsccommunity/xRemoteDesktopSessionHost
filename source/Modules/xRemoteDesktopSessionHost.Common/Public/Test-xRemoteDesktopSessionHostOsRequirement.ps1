function Test-xRemoteDesktopSessionHostOsRequirement
{
    return (Get-xRemoteDesktopSessionHostOsVersion) -ge (New-Object 'Version' 6, 2, 9200, 0)
}
