. "$PSScriptRoot\..\src\NubusTech.CredentialStore\public\Initialize-CsStore.ps1"
. "$PSScriptRoot\..\src\NubusTech.CredentialStore\public\Get-CsSecret.ps1"
. "$PSScriptRoot\..\src\NubusTech.CredentialStore\public\Get-CsEntry.ps1"

Describe Get-CsSecret {
    $filePath = $(New-TemporaryFile).FullName
    Remove-Item $filePath
    Initialize-CsStore $filePath

    $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
    $content.Credentials += @{
        Name     = "User1"
        Username = "user1"
        Password = $("pass1" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)
    }
    $content.Credentials += @{
        Name     = "User2"
        Username = "user2"
        Password = $("pass2" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)
    }
    $content | ConvertTo-Json | Out-File -FilePath $filePath

    Context "Get a single secret" {
        $result = Get-CsSecret -Name User1 -FilePath $filePath
        $decrypted = (New-Object PSCredential 'N/A', $result).GetNetworkCredential().Password

        It "should get a single secret" {
            $decrypted | Should Be "pass1"
        }
    }

    Context "Get a single raw secret" {
        $result = Get-CsSecret -Name User1 -Raw -FilePath $filePath

        It "should get a single secret" {
            $result | Should Be "pass1"
        }
    }

    Context "Entry does not exist" {
        It "should throw a exception" {
            { Get-CsSecret -Name unknown -FilePath $filePath} | Should Throw "Cannot find any entry with entry name 'unknown'."
        }
    }

    Context "CredentialStore file does not exist" {
        It "should throw a validation exception" {
            { Get-CsSecret -Name User1 -FilePath unknown.json } | Should Throw "The path 'unknown.json' does not exist."
        }
    }

    Remove-Item $filePath
}