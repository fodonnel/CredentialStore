<#
.SYNOPSIS
    Exports a CredentialStore to Azure KeyVault
.DESCRIPTION
    Exports a CredentialStore to Azure KeyVault
.PARAMETER VaultName
    The name of the Azure KeyVault
.PARAMETER FilePath
    Specifies the path to the CredentialStore file
.LINK
    https://github.com/fodonnel/CredentialStore
#>
function Export-CsKeyVaultStore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $VaultName,

        [Parameter(Mandatory = $false, Position = 1)]
        [Alias("File")]
        [string] $FilePath
    )

    Get-CsEntry -FilePath $FilePath | Set-CsKeyVaultEntry -VaultName $VaultName
}