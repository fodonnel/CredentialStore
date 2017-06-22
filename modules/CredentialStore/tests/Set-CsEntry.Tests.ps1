. "$PSScriptRoot\..\src\Initialize-CsStore.ps1"
. "$PSScriptRoot\..\src\Set-CsEntry.ps1"

Describe Set-CsEntry {
    $filePath = $(New-TemporaryFile).FullName
    Remove-Item $filePath

    Context "Adding a new Credential without description" {
        Initialize-CsStore $filePath

        $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
        Set-CsEntry -Name NewCred -Credential $cred -FilePath $filePath

        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json

        It "should add the new credential" {
            $content.Credentials.Length | Should Be 1
            $content.Credentials[0].Name | Should Be "NewCred"
        }

        It "should save the username" {
            $content.Credentials[0].UserName | Should Be "user"
        }

        It "should encrypt and save the password" {
            $content.Credentials[0].Password | Should Not Be NullOrEmpty
            $content.Credentials[0].Password | Should Not Be "pass"
        }

        It "should have empty description" {
            $content.Credentials[0].Description | Should BeNullOrEmpty
        }

        Remove-Item $filePath
    }

    Context "Adding a new Credential with description" {
        Initialize-CsStore $filePath

        $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
        Set-CsEntry -Name NewCred -Description Test -Credential $cred -FilePath $filePath

        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json

        It "should set the description" {
            $content.Credentials[0].Description | Should Be 'Test'
        }

        Remove-Item $filePath
    }


    Context "Updating an existing entry without description" {
        Initialize-CsStore $filePath

        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
        $content.Credentials += @{
            Name        = "Existing"
            Description = "oldDesc"
            Username    = "olduser"
            Password    = "encOldPass"
        }
        $content | ConvertTo-Json |Out-File -FilePath $filePath

        $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
        Set-CsEntry -Name Existing -Credential $cred -FilePath $filePath

        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json

        It "should not add a the new credential" {
            $content.Credentials.Length | Should Be 1
            $content.Credentials[0].Name | Should Be "Existing"
        }

        It "should update the username" {
            $content.Credentials[0].UserName | Should Be "user"
        }

        It "should encrypt and update the password" {
            $content.Credentials[0].Password | Should Not Be NullOrEmpty
            $content.Credentials[0].Password | Should Not Be "encOldPass"
            $content.Credentials[0].Password | Should Not Be "pass"
        }

        It "should have empty description" {
            $content.Credentials[0].Description | Should BeNullOrEmpty
        }

        Remove-Item $filePath
    }

    Context "Pipeline support" {
        Initialize-CsStore $filePath

        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
        $content.Credentials += @{
            Name        = "Existing"
            Description = "oldDesc"
            Username    = "olduser"
            Password    = "encOldPass"
        }
        $content | ConvertTo-Json | Out-File -FilePath $filePath

        $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
        $entries = @(
            [PSCustomObject] @{Name = "Name1"; Credential = $cred}
            [PSCustomObject] @{Name = "Name2"; Credential = $cred}
            [PSCustomObject] @{Name = "Existing"; Credential = $cred}
        )

        $entries | Set-CsEntry -FilePath $filePath
        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json

        It "should update the existing credential" {
            $content.Credentials[0].UserName | Should Be "user"
            $content.Credentials[0].Password | Should Not Be "encOldPass"
        }

        It "should add the new credential" {
            $content.Credentials.Length | Should Be 3
            $content.Credentials[1].Name | Should Be "Name1"
            $content.Credentials[2].Name | Should Be "Name2"
        }

        Remove-Item $filePath
    }

    Context "CredentialStore file does not exist" {
        It "should throw a validation exception" {
            $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force))
            { Set-CsEntry -Name User1 -Credential $cred -FilePath unknown.json } | Should Throw "The path 'unknown.json' does not exist."
        }
    }

    Context "CredentialStore is for a different user" {
        Initialize-CsStore $filePath
        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
        $content.UserName = "other"
        $content | ConvertTo-Json | Out-File -FilePath $filePath

        It "should throw a exception" {
            $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force)) 
            {  Set-CsEntry -Name User1 -Credential $cred -FilePath $filePath } | Should Throw "Cannot access CredentialStore, it is encrypted for"
        }

        Remove-Item $filePath
    }

    Context "CredentialStore is for a different computer" {
        Initialize-CsStore $filePath
        $content = Get-Content -Raw -Path $filePath | ConvertFrom-Json
        $content.ComputerName = "other"
        $content | ConvertTo-Json | Out-File -FilePath $filePath

        It "should throw a exception" {
            $cred = New-Object PSCredential("user", $("pass" | ConvertTo-SecureString -AsPlainText -Force)) 
            {  Set-CsEntry -Name User1 -Credential $cred -FilePath $filePath } | Should Throw "Cannot access CredentialStore, it is encrypted for"
        }

        Remove-Item $filePath
    }

}