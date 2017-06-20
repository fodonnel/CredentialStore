. "$PSScriptRoot\..\src\CredentialStore\public\Initialize-CsStore.ps1"
. "$PSScriptRoot\..\src\CredentialStore\public\Get-CsEntry.ps1"
. "$PSScriptRoot\..\src\CredentialStore\public\Set-CsEntry.ps1"

Describe Get-CsEntry {
    $filePath = $(New-TemporaryFile).FullName
    Remove-Item $filePath
    Initialize-CsStore $filePath

    @("User1", "User2", "Other", "Last") | ForEach-Object {
        $cred = New-Object PSCredential($_, $($_| ConvertTo-SecureString -AsPlainText -Force))
        Set-CsEntry -FilePath $filePath -Name $_ -Credential $cred
    }

    Context "Get all the Entries" {
        $result = Get-CsEntry -FilePath $filePath

        It "should get all the entries" {
            $result | Should Not Be $null
            $result.Length | Should Be 4

            $result[0].Name | Should Be "User1"
            $result[1].Name | Should Be "User2"
            $result[2].Name | Should Be "Other"
            $result[3].Name | Should Be "Last"
        }
    }

    Context "Getting entries by Name" {
        It "should be able to get an entry by its exact name" {
            $result = Get-CsEntry -FilePath $filePath -Name User1
            $result.Name | Should Be "User1"
        }

        It "should be able to get an entries by regex pattern" {
            $result = Get-CsEntry -FilePath $filePath -Name User*
            $result.Length | Should Be 2
            $result[0].Name | Should Be "User1"
            $result[1].Name | Should Be "User2"
        }

        It "should be able to get an entries by any regex pattern in name array" {
            $result = Get-CsEntry -FilePath $filePath -Name User*,*st
            $result.Length | Should Be 3
            $result[0].Name | Should Be "User1"
            $result[1].Name | Should Be "User2"
            $result[2].Name | Should Be "Last"
        }
    }

    Context "CredentialStore file does not exist" {
        It "should throw a validation exception" {
            { Get-CsEntry -Name User1 -FilePath unknown.json } | Should Throw "The path 'unknown.json' does not exist."
        }
    }

    Context "CredentialStore is for a different user" {
        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
        $content.UserName = "other"
        $content | ConvertTo-Json |Out-File -FilePath $filePath

        It "should throw a exception" {
            { Get-CsEntry -Name User1 -FilePath $filePath } | Should Throw "Cannot access CredentialStore, it is encrypted for"
        }
    }

    Context "CredentialStore is for a different computer" {
        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
        $content.ComputerName = "other"
        $content | ConvertTo-Json | Out-File -FilePath $filePath

        It "should throw a exception" {
            { Get-CsEntry -Name User1 -FilePath $filePath } | Should Throw "Cannot access CredentialStore, it is encrypted for"
        }
    }

    Remove-Item $filePath
}