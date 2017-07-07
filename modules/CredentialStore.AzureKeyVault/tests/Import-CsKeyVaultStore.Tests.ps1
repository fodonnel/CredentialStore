[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param()

. "$PSScriptRoot\..\..\CredentialStore\src\Test-CsEntryName.ps1"
. "$PSScriptRoot\..\..\CredentialStore\src\Initialize-CsStore.ps1"
. "$PSScriptRoot\..\..\CredentialStore\src\Set-CsEntry.ps1"
. "$PSScriptRoot\..\src\Get-CsKeyVaultEntry.ps1"
. "$PSScriptRoot\..\src\Import-CsKeyVaultStore.ps1"

Describe Import-CsKeyVaultStore {
    $filePath = $(New-TemporaryFile).FullName

    Mock Initialize-CsStore
    Mock Set-CsEntry
    Mock Get-CsKeyVaultEntry -MockWith {
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

    Context "Import a CredentialStore from Vault to File" {
        Import-CsKeyVaultStore -VaultName vault1 -FilePath $filePath

        It "Should Initialise a local CredentialStore" {
            Assert-MockCalled Initialize-CsStore -ParameterFilter { 
                $FilePath -eq $filePath
            }
        }

        It "Should add the entries from the vault" {
            Assert-MockCalled Set-CsEntry -Exactly 2
            Assert-MockCalled Set-CsEntry -ParameterFilter {
                $Name -eq 'name1'
            }

            Assert-MockCalled Set-CsEntry -ParameterFilter {
                $Name -eq 'name2'
            }
        }
    }

    Remove-Item $filePath 
}
