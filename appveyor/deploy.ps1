Write-Host 'Running AppVeyor deploy script' -ForegroundColor Yellow
if ($env:APPVEYOR_REPO_BRANCH -notmatch 'master') {
    Write-Host "Finished testing of branch: $env:APPVEYOR_REPO_BRANCH - Exiting"
    exit;
}

$modulePath = "$PSScriptRoot\..\modules"
$env:psmodulepath = $env:psmodulepath + ';' + $ModulePath

Write-Host 'Updating the manifests'
$filePath = "$modulePath\CredentialStore\CredentialStore.psd1"
(Get-Content $filePath -Raw) -replace "0.0.0.1", "$env:APPVEYOR_BUILD_VERSION" | Out-File -LiteralPath $filePath

$filePath = "$modulePath\CredentialStore.AzureKeyVault\CredentialStore.AzureKeyVault.psd1"
(Get-Content $filePath -Raw) -replace "0.0.0.1", "$env:APPVEYOR_BUILD_VERSION" | Out-File -LiteralPath $filePath

Write-Host 'Publishing module to Powershell Gallery'
Publish-Module -Name CredentialStore -NuGetApiKey $env:psgallery_api_key
Publish-Module -Name CredentialStore.AzureKeyVault -NuGetApiKey $env:psgallery_api_key