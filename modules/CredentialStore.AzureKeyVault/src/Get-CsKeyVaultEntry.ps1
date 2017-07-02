<#
.SYNOPSIS
    Get CredentialStore Entries in an Azure Key Vault
.DESCRIPTION
    The Get-CsKeyVaultEntry cmdlet gets entries from an Azure KeyVault.
    A user must already be authenticated with Azure to run this command.
.PARAMETER VaultName
    Specifies the name of the keyvault
.PARAMETER Name
    Specifies the name of entry. Wildcards are supported.
.Example
    Get-CsKeyVaultEntry -VaultName myVault -Name LocalServer -Credential $cred
    This command gets the entry named LocalServer from the the myVault Key Vault.
.LINK
    https://github.com/fodonnel/CredentialStore
#>
function Get-CsKeyVaultEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $VaultName,

        [Parameter(Mandatory = $false, Position = 1)]
        [string[]] $Name = '*'
    )

    $allEntries = Get-AzureKeyVaultSecret -VaultName $VaultName
    $entries = @(foreach ($entry in $allEntries) {
            if ( $Name | Where-Object { $entry.Name -like $_ }) {
                $entry
            }
        })

    foreach ($entry in $entries) {
        $secret = Get-AzureKeyVaultSecret -VaultName $VaultName -Name $entry.Name
        $username = $secret.Attributes.Tags["Username"]
        $description = $secret.Attributes.Tags["Description"]

        [PsCustomObject]@{
            Name        = $secret.Name
            Description = $description
            Credential  = New-Object PSCredential($username, $secret.SecretValue)
        }
    }
}