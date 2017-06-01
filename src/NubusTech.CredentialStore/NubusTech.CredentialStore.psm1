. $PSScriptRoot\public\Initialize-CsStore.ps1
. $PSScriptRoot\public\Get-CsEntry.ps1
. $PSScriptRoot\public\Set-CsEntry.ps1
. $PSScriptRoot\public\Get-CsCredential.ps1
. $PSScriptRoot\public\Get-CsPassword.ps1
. $PSScriptRoot\public\Get-CsDefaultStore.ps1
. $PSScriptRoot\public\Set-CsDefaultStore.ps1

$defaultPath = "$($env:userprofile)\CredentialStore.json"
Set-CsDefaultStore -FilePath $defaultPath

if (-Not $(Test-Path $defaultPath)) {
    Initialize-CsStore -FilePath $defaultPath
}