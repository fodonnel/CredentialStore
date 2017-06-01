<#
.SYNOPSIS
    Get CredentialStore Path
.DESCRIPTION
    The Get-CsDefaultPath cmdlet gets default CredentialStore path.
.LINK
    https://github.com/
#>
function Get-CsDefaultPath {
    return $Script:DefaultCredentialStore
}