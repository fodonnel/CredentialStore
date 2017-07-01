<#
.SYNOPSIS
    Imports a Credential from Azure KeyVault to a local CredentialStore file
.DESCRIPTION
    Import a Credential from Azure KeyVault to a local CredentialStore file
.PARAMETER VaultName
    The name of the Azure KeyVault
.PARAMETER FilePath
    Specifies the path to the CredentialStore file
.LINK
    https://github.com/fodonnel/CredentialStore
#>
function Import-CsKeyVaultStore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $VaultName,

        [Parameter(Mandatory = $false, Position = 1)]
        [Alias("File")]
        [string] $FilePath
    )

    $entries = Get-CsKeyVaultEntry -VaultName $VaultName 
    Initialize-CsStore -FilePath $FilePath
    $entries | Set-CsEntry -FilePath $FilePath
}