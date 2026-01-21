# Localized resources for DSC_RDCertificateConfiguration

ConvertFrom-StringData @'
    ErrorSettingCertificate = Failed to apply certificate from path '{0}' to role '{1}' on connection broker '{2}'. Error: '{3}'
    VerboseCurrentCertificate = Thumbprint of currently configured certificate for role '{0}': '{1}'
    VerboseGetCertificate = Get current certificate for role '{0}' from connection broker '{1}'
    VerbosePfxCertificate = Thumbprint of certificate for role '{0}' in .pfx file: '{1}'
    VerboseSetCertificate = Importing certificate for role '{0}' from file '{1}'
    WarningPfxDataImportFailed = Failed to import certificate from pfx file '{0}'. Error message: '{1}'
'@
