. "$PSScriptRoot\..\..\CredentialStore\src\Test-CsEntryName.ps1"
. "$PSScriptRoot\..\..\CredentialStore\src\Get-CsEntry.ps1"
. "$PSScriptRoot\..\src\Set-CsKeyVaultEntry.ps1"
. "$PSScriptRoot\..\src\Export-CsKeyVaultStore.ps1"

Describe Export-CsKeyVaultStore {
    $filePath = $(New-TemporaryFile).FullName

    Mock Set-CsKeyVaultEntry
    Mock Get-CsEntry -MockWith {
        @(
            [PSCustomObject]@{
                Name        = 'name1'
                Credential  = New-Object PSCredential("user1", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
                Description = 'desc1'
            },
            [PSCustomObject]@{
                Name        = 'name2'
                Credential  = New-Object PSCredential("user2", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
                Description = 'desc2'
            }
        )
    }

    Context "Export a CredentialStore to a Vault" {
        Export-CsKeyVaultStore -VaultName vault1 -FilePath $filePath

        It "Should add the entries to the vault" {
            Assert-MockCalled Set-CsKeyVaultEntry -Exactly 2
            Assert-MockCalled Set-CsKeyVaultEntry -ParameterFilter {
                $Name -eq 'name1'
            }

            Assert-MockCalled Set-CsKeyVaultEntry -ParameterFilter {
                $Name -eq 'name2'
            }
        }
    }

    Remove-Item $filePath
}
