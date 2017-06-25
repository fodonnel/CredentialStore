<#
.SYNOPSIS
    Set CredentialStore Entries in an Azure Key Vault
.DESCRIPTION
    The Set-CsKeyVaultEntry cmdlet adds or updates CredentialStore entries in an Azure KeyVault.
    A user must already be authenticated with Azure to run this command.
.PARAMETER VaultName
    Specifies the name of the keyvault
.PARAMETER Name
    Specifies the name of entry to be added or updated.
.PARAMETER Description
    A description of the CredentialStore entry.
.PARAMETER Credential
    Specifies the PSCredential of the CredentialStore entry.
.Example
    Set-CsKeyVaultEntry -VaultName myVault -Name LocalServer -Credential $cred
    This command sets the CredentialStore entry named LocalServer in the myVault Key Vault.
.LINK
    https://github.com/fodonnel/CredentialStore
#>

function Set-CsKeyVaultEntry {
    [CmdletBinding(SupportsShouldProcess = $false)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $VaultName,
        
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
        [string] $Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
        [System.Management.Automation.Credential()]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)]
        [string] $Description
    )

    process {
        $params = @{
            Name        = $Name
            VaultName   = $VaultName
            SecretValue = $Credential.password
            ContentType = "CredentialStore"
            Tag         = @{
                Username    = $Credential.Username
                Description = $Description
            }
        }

        Set-AzureKeyVaultSecret @params
    }
}