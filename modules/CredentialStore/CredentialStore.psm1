. $PSScriptRoot\src\Initialize-CsStore.ps1
. $PSScriptRoot\src\Get-CsEntry.ps1
. $PSScriptRoot\src\Set-CsEntry.ps1
. $PSScriptRoot\src\Get-CsCredential.ps1
. $PSScriptRoot\src\Get-CsPassword.ps1
. $PSScriptRoot\src\Get-CsDefaultStore.ps1
. $PSScriptRoot\src\Set-CsDefaultStore.ps1

$majorVersion = $PSVersionTable.PSVersion.Major
if ($majorVersion -ge 5) {
    Register-ArgumentCompleter -CommandName Get-CsCredential, Get-CsPassword, Get-CsEntry -ParameterName Name -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $params = @{}
        if ($fakeBoundParameter["FilePath"]) {
            $params = @{'FilePath' = $fakeBoundParameter["FilePath"]}
        }
        Get-CsEntry @params | Where-Object Name -like "$wordToComplete*" |
        ForEach-Object {
            $toolTip = "Username: $($_.Credential.Username)"
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $toolTip)
        }

    }
}

$defaultPath = "$($env:userprofile)\CredentialStore.json"
Set-CsDefaultStore -FilePath $defaultPath

if (-Not $(Test-Path $defaultPath)) {
    Initialize-CsStore -FilePath $defaultPath
}