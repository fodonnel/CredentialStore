<#
.SYNOPSIS
    Get CredentialStore Entry Secret
.DESCRIPTION
    The Get-CsSecret cmdlet gets the credential password for a CredentialStore entry by name.
.PARAMETER FilePath
    Specifies the path to the CredentialStore file.
.PARAMETER Name
    Specifies the CredentialStore entry name of of the be retrieved. Wildcards are not permitted.
    This cmdlet throws an error if no entry with that name exists.
.PARAMETER Raw
    Return the secret as a standard unsecure string.
.Example
    Get-CsSecret -FilePath CredentialStore.json -Name LocalServer
    This command gets the password of the CredentialStore entry named LocalServer in the CredentialStore.json file.
.LINK
    https://github.com/
#>
function Get-CsSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name,

        [Parameter(Position = 1)]
        [switch] $Raw,

        [ValidateScript({
            if (Test-Path $_) { $true }
            else { throw [System.Management.Automation.ValidationMetadataException] "The path '${_}' does not exist." }
        })] 
        [Parameter(Mandatory = $false, Position = 2)]
        [Alias("File")]
        [string] $FilePath = (Get-CsDefaultPath)
    )

    $entry = Get-CsEntry -Name $Name -FilePath $FilePath
    if ($entry) {
        if ($Raw) {
            return $entry.Credential.GetNetworkCredential().Password
        }
        else {
            return $entry.Credential.Password
        }
    }

    throw "Get-CsSecret : Cannot find any entry with entry name '$Name'."
}