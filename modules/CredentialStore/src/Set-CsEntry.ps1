<#
.SYNOPSIS
    Set CredentialStore Entries
.DESCRIPTION
    The Set-CsEntry cmdlet adds or updates CredentialStore entries in a CredentialStore file.
.PARAMETER FilePath
    Specifies the path to the CredentialStore file.
.PARAMETER Name
    Specifies the CredentialStore entry name of entry to be added or updated.
.PARAMETER Description
    A description of the CredentialStore entry.
.PARAMETER Credential
    Specifies the PSCredential of the CredentialStore entry.
.Example
    Set-CsEntry -FilePath CredentialStore.json -Name LocalServer -Credential $cred
    This command sets the CredentialStore entry named LocalServer in the CredentialStore.json file.
.LINK
    https://github.com/fodonnel/CredentialStore
#>
function Set-CsEntry {
    [CmdletBinding(SupportsShouldProcess = $false)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string] $Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
        [System.Management.Automation.Credential()]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)]
        [string] $Description,

        [ValidateScript( {
                if (Test-Path $_) { $true }
                else { throw [System.Management.Automation.ValidationMetadataException] "The path '${_}' does not exist." }
            })]
        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 3)]
        [Alias("File")]
        [string] $FilePath = (Get-CsDefaultStore)
    )

    begin {
        $store = Get-Content -Raw -Path $FilePath | ConvertFrom-Json
        if ($store.Username -ne $(whoami) -or $store.ComputerName -ne $(hostname)) {
            throw "Cannot access CredentialStore, it is encrypted for user $($store.UserName) on Computer $($store.ComputerName)"
        }
    }

    process {
        $entry = $store.credentials | Where-Object {$_.name -eq $Name}

        if (-not $entry) {
            $store.credentials += @{
                name        = $Name
                description = $Description
                username    = $Credential.username
                password    = $($Credential.password | ConvertFrom-SecureString)
            }
        }
        else {
            $entry.description = $description
            $entry.username = $Credential.username
            $entry.password = $($Credential.password | ConvertFrom-SecureString)
        }
    }

    end {
        $store | ConvertTo-Json | Out-File -FilePath $FilePath -Force
    }
}