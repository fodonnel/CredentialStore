. "$PSScriptRoot\..\src\Set-CsKeyVaultEntry.ps1"

Describe Set-CsKeyVaultEntry {
    Mock -CommandName Set-AzureKeyVaultSecret 

    Context "Adding a new Credential without description" {
        $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
        Set-CsKeyVaultEntry -VaultName vault1 -Name name1 -Credential $cred

        It "should add the entry to the vault" {
            Assert-MockCalled Set-AzureKeyVaultSecret -ParameterFilter {
                $decoded = (New-Object PSCredential("ueser", $SecretValue)).GetNetworkCredential().Password

                $VaultName -eq 'vault1' -And
                $Name -eq 'name1' -And
                $decoded -eq 'pass' -And
                $ContentType -eq "CredentialStore" -And
                $Tag['Username'] -eq 'user'
            }
        }
    }

    Context "Adding a new Credential with description" {
        $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
        Set-CsKeyVaultEntry -VaultName vault1 -Name name1 -Credential $cred -Description desc

        It "should add the entry to the vault" {
            Assert-MockCalled Set-AzureKeyVaultSecret -ParameterFilter {
                $decoded = (New-Object PSCredential("ueser", $SecretValue)).GetNetworkCredential().Password

                $VaultName -eq 'vault1' -And
                $Name -eq 'name1' -And
                $decoded -eq 'pass' -And
                $ContentType -eq "CredentialStore" -And
                $Tag['Username'] -eq 'user' -And
                $Tag['Description'] -eq 'desc'
            }
        }
    }
}