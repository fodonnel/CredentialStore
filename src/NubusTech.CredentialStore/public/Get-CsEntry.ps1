<#
.SYNOPSIS
    Get CredentialStore Entries
.DESCRIPTION
    The Get-CsEntry cmdlet gets objects that represent the CredentialStore entries for a file.
.PARAMETER FilePath
    Specifies the path to the CredentialStore file.
.PARAMETER Name
    Specifies the CredentialStore entries names of entries to be retrieved. Wildcards are permitted. By default,
    this cmdlet gets all of the entries in the CredentialStore file.
.Example
    Get-CsEntry -FilePath CredentialStore.json
    This command gets all CredentialStore entries in the CredentialStore.json file.
.Example
    Get-CsEntry -FilePath CredentialStore.json -Name "LocalServer"
    This command retrieves CredentialStore entry with the name LocalServer.
.Example
    Get-CsEntry -FilePath CredentialStore.json -Name "vmm*"
    This command retrieves CredentialStore entries with names that begin with vmm.
.LINK
    https://github.com/
#>
function Get-CsEntry {
    [CmdletBinding()]
    param(
        [ValidateScript( {
                if (Test-Path $_) { $true }
                else { throw [System.Management.Automation.ValidationMetadataException] "The path '${_}' does not exist." }
            })]
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias("File")]
        [string] $FilePath = (Get-CsDefaultPath),

        [Parameter(Mandatory = $false)]
        [string[]] $Name = "*"
    )

    $store = Get-Content -Raw -Path $FilePath | ConvertFrom-Json
    if ($store.Username -ne $(whoami) -or $store.ComputerName -ne $(hostname)) {
        throw "Cannot access CredentialStore, it is encrypted for user $($store.UserName) on Computer $($store.ComputerName)"
    }

    $entries = @(foreach ($entry in $store.credentials) {
            if ( $Name | Where-Object { $entry.Name -like $_ }) {
                $entry
            }
        })

    foreach ($entry in $entries) {
        $password = ($entry.password | ConvertTo-SecureString)
        $cred = New-Object PSCredential($entry.username, $password)

        [PsCustomObject]@{
            Name        = $entry.Name
            Description = $entry.Description
            Credential  = $cred
        }
    }
}