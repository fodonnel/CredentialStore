function Set-CsKeyVaultEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [System.Management.Automation.Credential()]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $false, Position = 2)]
        [string] $Description,

        [Parameter(Mandatory = $true, Position = 3)]
        [string] $VaultName
    )

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