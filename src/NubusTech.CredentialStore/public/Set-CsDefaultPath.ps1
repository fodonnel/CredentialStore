<#
.SYNOPSIS
    Set the default CredentialStore Path
.DESCRIPTION
    The Set-CsDefaultPath cmdlet gets default CredentialStore path.
.PARAMETER FilePath
    Specifies the path to the CredentialStore file.
.LINK
    https://github.com/
#>
function Set-CsDefaultPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("File")]
        [string] $FilePath
    )

    $Script:DefaultCredentialStore = $FilePath
}