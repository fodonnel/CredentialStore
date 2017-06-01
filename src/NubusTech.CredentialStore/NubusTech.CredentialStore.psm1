. $PSScriptRoot\public\Initialize-CsStore.ps1
. $PSScriptRoot\public\Get-CsEntry.ps1
. $PSScriptRoot\public\Set-CsEntry.ps1
. $PSScriptRoot\public\Get-CsCredential.ps1
. $PSScriptRoot\public\Get-CsSecret.ps1
. $PSScriptRoot\public\Get-CsDefaultPath.ps1
. $PSScriptRoot\public\Set-CsDefaultPath.ps1

$defaultPath = "$($env:userprofile)\CredentialStore.json"
Set-CsDefaultPath -FilePath $defaultPath
if (-Not $(Test-Path $defaultPath)) {
    Initialize-CsStore -FilePath $defaultPath
}