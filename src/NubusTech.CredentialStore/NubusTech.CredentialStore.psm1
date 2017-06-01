$publicFiles = @(Get-ChildItem $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue)
$privateFiles = @(Get-ChildItem $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue)

foreach ($import in @($publicFiles + $privateFiles)) {
    . $import.fullname
}

Set-CsDefaultPath -FilePath "$($env:userprofile)\CredentialStore.json"
if (-Not $(Test-Path $(Get-CsDefaultPath))) {
    Initialize-CsStore -FilePath $(Get-CsDefaultPath)
}

Export-ModuleMember -Function $($publicFiles | Select -ExpandProperty BaseName) -Alias *