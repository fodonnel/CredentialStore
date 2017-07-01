<#
.SYNOPSIS
    Test if a Credential store name is valid
.DESCRIPTION
    Test if a Credential store name is valid.
    The name must be a string 1-127 characters in length containing only 0-9, a-z, A-Z, and -.
    This restriction is in place to ensure the entry can be synced with an Azure key vault.
    See: https://docs.microsoft.com/en-us/rest/api/keyvault/about-keys--secrets-and-certificates
.PARAMETER Name
    Specifies the CredentialStore entry name of entry to be added or updated.
.LINK
    https://github.com/fodonnel/CredentialStore
#>
function Test-CsEntryName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name
    )

    return ($Name.Length -le 127 -and $Name -match '^[A-Za-z0-9-]+$')
}