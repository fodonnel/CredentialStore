. "$PSScriptRoot\..\src\CredentialStore\public\Initialize-CsStore.ps1"

Describe Initialize-CsStore {
    $filePath = $(New-TemporaryFile).FullName
    Remove-Item $filePath

    Context "Create a new CredentialStore file" {
        Initialize-CsStore -FilePath $filePath

        It "should create a new CredentialStore file" {
            $filePath | Should Exist
        }

        It "should contain an empty credentials collection" {
            $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
            $content.credentials.Length | Should Be 0
        }

        Remove-Item $filePath
    }

    Context "File already exists exist" {
        New-Item $filePath -Type file

        It "should throw an exception" {
            { Initialize-CsStore -FilePath $filePath } | Should Throw "File already exists, cannot overwrite"
        }

        Remove-Item $filePath
    }

    Context "New CredentialStore should set file meta data" {
        Initialize-CsStore -FilePath $filePath
        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json

        It "should set the username" {
            $content.UserName | Should Not BeNullOrEmpty
        }

        It "should set the computer name" {
            $content.ComputerName | Should Not BeNullOrEmpty
        }
        
        It "should set the created date" {
            $content.CreatedDate | Should Not BeNullOrEmpty
        }

        Remove-Item $filePath
    }
}