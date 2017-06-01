. "$PSScriptRoot\..\src\NubusTech.CredentialStore\public\Get-CsCredential.ps1"
. "$PSScriptRoot\..\src\NubusTech.CredentialStore\public\Get-CsEntry.ps1"
. "$PSScriptRoot\..\src\NubusTech.CredentialStore\public\Initialize-CsStore.ps1"

Describe Get-CsCredential {
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

    Context "Get a single Credential" {
        $result = Get-CsCredential -Name User1 -FilePath $filePath

        It "should get a single user" {
            $result | Should Not Be $null
            $result.Username | Should Be "user1"
        }
    }

    Context "Credential does not exist" {
        It "should throw a exception" {
            { Get-CsCredential -Name unknown -FilePath $filePath} | Should Throw "Cannot find any entry with entry name 'unknown'."
        }
    }

    Context "CredentialStore file does not exist" {
        It "should throw a validation exception" {
            { Get-CsCredential -Name User1 -FilePath unknown.json } | Should Throw "The path 'unknown.json' does not exist."
        }
    }

    Remove-Item $filePath
}