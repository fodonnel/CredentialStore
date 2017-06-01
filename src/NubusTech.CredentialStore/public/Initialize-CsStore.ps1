<#
.SYNOPSIS
    Creates a new CredentialStore
.DESCRIPTION
    The Initialize-CsStore cmdlet create a new CredentialStore file.
.PARAMETER FilePath
    Specifies the path for the new CredentialStore file.
.Example
    Initialize-CsStore -FilePath CredentialStore.json
    This command will create a new keysore file called CredentialStore.json.
.LINK
    https://github.com/nubustech/NubusTech.CredentialStore
#>
function Initialize-CsStore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("File")]
        [string] $FilePath
    )

    if (Test-Path $FilePath) {
        throw "File already exists, cannot overwrite"
    }

    ConvertTo-Json @{
        UserName = $(whoami)
        ComputerName = $(hostname)
        CreatedDate = (Get-Date).ToString()
        FileFormatVersion = "1.0"
        Credentials = @()
    } | Out-File -FilePath $FilePath
}