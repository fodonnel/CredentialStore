function Get-CsKeyVaultEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory = $true, Position = 1)]
        [string] $VaultName
    )

    $secret = Get-AzureKeyVaultSecret -VaultName $VaultName -Name $Name
    $username = $secret.Attributes.Tags["Username"]
    $description = $secret.Attributes.Tags["Description"]

    [PsCustomObject]@{
        Name        = $secret.Name
        Description = $description
        Credential  = New-Object PSCredential($username, $secret.SecretValue)
    }
}