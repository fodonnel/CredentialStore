. "$PSScriptRoot\..\..\CredentialStore\src\Test-CsEntryName.ps1"
. "$PSScriptRoot\..\src\Get-CsKeyVaultEntry.ps1"

Describe Get-CsKeyVaultEntry {
    Mock -CommandName Get-AzureKeyVaultSecret

    Context "Get an from azure entry by name" {
        Mock -CommandName Get-AzureKeyVaultSecret -ParameterFilter {
            $VaultName -eq 'vault1'
        } -MockWith {
            @{
                Name        = 'name1'
                Attributes  = @{ Tags = @{ Username = 'user1'; Description = "desc1" }}
            }
        }

        Mock -CommandName Get-AzureKeyVaultSecret -ParameterFilter {
            $VaultName -eq 'vault1' -And $Name -eq 'name1'
        } -MockWith {
            @{
                Name        = 'name1'
                SecretValue = $("pass" | ConvertTo-SecureString -AsPlainText -Force)
                Attributes  = @{ Tags = @{ Username = 'user1'; Description = "desc1" }}
            }
        }

        $result = Get-CsKeyVaultEntry -VaultName vault1 -Name name1

        It "should be able to the get entry" {
            $result.Name | Should Be 'name1'
            $result.Description | Should Be 'desc1'
            $result.Credential.Username | Should Be 'user1'
            $result.Credential.GetNetworkCredential().Password | Should Be 'pass'
        }
    }
}