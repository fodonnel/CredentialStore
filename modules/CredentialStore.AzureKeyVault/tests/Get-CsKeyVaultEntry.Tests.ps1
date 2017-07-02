. "$PSScriptRoot\..\..\CredentialStore\src\Test-CsEntryName.ps1"
. "$PSScriptRoot\..\src\Get-CsKeyVaultEntry.ps1"

Describe Get-CsKeyVaultEntry {
    Mock -CommandName Get-AzureKeyVaultSecret
    Mock -CommandName Get-AzureKeyVaultSecret -ParameterFilter {
        $VaultName -eq 'vault1'
    } -MockWith {
        if ($Name) {
            return @{
                Name        = $name
                Attributes  = @{ Tags = @{ Username = "user$name"; Description = "desc$name" }}
                SecretValue = $("pass$name" | ConvertTo-SecureString -AsPlainText -Force)
            }
        }
        else {
            return @{Name = 'name1'}, @{Name = 'name2'}, @{Name = 'name3'}, @{Name = 'other'}
        }
    }

    Context "Get an from azure entry by name" {
        It "should be able to the get entry by exact name" {
            $result = Get-CsKeyVaultEntry -VaultName vault1 -Name name1
            $result.Name | Should Be 'name1'
            $result.Description | Should Be 'descname1'
            $result.Credential.Username | Should Be 'username1'
            $result.Credential.GetNetworkCredential().Password | Should Be 'passname1'
        }

        It "should be able to the get entry by wildcard" {
            $result = Get-CsKeyVaultEntry -VaultName vault1 -Name name*
            $result.Length | Should Be 3
            $result[0].Name | Should Be 'name1'
            $result[1].Name | Should Be 'name2'
            $result[2].Name | Should Be 'name3'
        }

        It "should be able to the get entry by array" {
            $result = Get-CsKeyVaultEntry -VaultName vault1 -Name name1, name2
            $result.Length | Should Be 2
            $result[0].Name | Should Be 'name1'
            $result[1].Name | Should Be 'name2'
        }
    }
}