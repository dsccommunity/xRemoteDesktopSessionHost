function Test-xRemoteDesktopSessionHostOsRequirement
{
    return (Get-xRemoteDesktopSessionHostOsVersion) -ge ([Version]::new(6, 2, 9200, 0))
}
