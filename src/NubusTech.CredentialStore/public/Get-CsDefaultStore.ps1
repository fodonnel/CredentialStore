<#
.SYNOPSIS
    Gets the path to the default CredentialStore
.DESCRIPTION
    The Get-CsDefaultStore cmdlet gets the path to the default CredentialStore
.LINK
    https://github.com/
#>
function Get-CsDefaultStore {
    return $Script:DefaultCredentialStore
}