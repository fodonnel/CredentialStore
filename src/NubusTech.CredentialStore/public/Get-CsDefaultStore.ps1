<#
.SYNOPSIS
    Gets the path to the default CredentialStore
.DESCRIPTION
    The Get-CsDefaultStore cmdlet gets the path to the default CredentialStore
.LINK
    https://github.com/nubustech/NubusTech.CredentialStore
#>
function Get-CsDefaultStore {
    return $Script:DefaultCredentialStore
}