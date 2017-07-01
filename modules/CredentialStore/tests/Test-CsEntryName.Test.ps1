. "$PSScriptRoot\..\src\Test-CsEntryName.ps1"

Describe Test-CsEntryName {
    Context "Name validity" {
        It "should allow a name of less that 127 characters" {
            Test-CsEntryName -Name test | Should Be $true
        }

        It "should allow a name of exactly 127 characters" {
            Test-CsEntryName -Name ("test".PadLeft(127, 'x')) | Should Be $true
        }

        It "should reject a name greater 127 characters" {
            Test-CsEntryName -Name ("test".PadLeft(128, 'x')) | Should Be $false
        }

        It "should allow lowercase letters" {
            Test-CsEntryName -Name test | Should Be $true
        }

        It "should allow uppercase letters" {
            Test-CsEntryName -Name TEST | Should Be $true
        }

        It "should allow numbers" {
            Test-CsEntryName -Name 1234 | Should Be $true
        }

        It "should allow dashes" {
            Test-CsEntryName -Name --- | Should Be $true
        }

        It "should reject special characters" {
            Test-CsEntryName -Name "*" | Should Be $false
        }
    }
}