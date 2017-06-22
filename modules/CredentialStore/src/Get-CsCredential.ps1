<#
.SYNOPSIS
    Get a CredentialStore Entry Credential
.DESCRIPTION
    The Get-CsCredential cmdlet gets the credential for a CredentialStore entry by name.
.PARAMETER FilePath
    Specifies the path to the CredentialStore file.
.PARAMETER Name
    Specifies the CredentialStore entry name of of the be retrieved. Wildcards are not permitted.
    This cmdlet throws an error if no entry with that name exists.
.Example
    Get-CsCredential -FilePath CredentialStore.json -Name LocalServer
    This command gets the credential of the CredentialStore entry named LocalServer in the CredentialStore.json file.
.LINK
    https://github.com/fodonnel/CredentialStore
#>
function Get-CsCredential {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name,

        [ValidateScript({
            if (Test-Path $_) { $true }
            else { throw [System.Management.Automation.ValidationMetadataException] "The path '${_}' does not exist." }
        })] 
        [Parameter(Mandatory = $false, Position = 1)]
        [Alias("File")]
        [string] $FilePath = (Get-CsDefaultStore)
    )

    $entry = Get-CsEntry -Name $Name -FilePath $FilePath
    if ($entry) {
        return $entry.Credential
    }

    throw "Get-CsCredential : Cannot find any entry with entry name '$Name'."
}