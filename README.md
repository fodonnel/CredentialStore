# CredentialStore
![Build Status](https://ci.appveyor.com/api/projects/status/github/fodonnel/CredentialStore?branch=master&svg=true)

CredentialStore saves powershell credentials securely to file. 

A key feature of the CredentialStore is that Credentials are saved against a name which is separate from the credential username. This allow the user to store credential against a name that describes the credential's propose. For instance a credential to access virtual machine manager might have a username like domain\svc_vmm_prod. In the credentialStore you might prefer to save this credential with a simple name like VMM. 

## Encryption
Passwords are encrypted using windows built in Data Protection API (DAPI). This mean the passwords are encrypted to the user and machine. If the file is copied to another machine it cannot be decrypted, even by the user who created it.

## Default CredentialStore
FilePath is optional for all the CredentialStore cmdlets. If FilePath is not provided the entry will be store in $($env:UserProfile)\CredentialStore.json store. 
You can override this default for the powershell session using the Set-CsDefaultStore cmdlet.

## Examples

### Saving an entry
```
$credential = Get-Credential "domain\username"
Set-CsEntry -Name ProxyServiceAccount -Credential $credential -FilePath myCsStore.json -Description "The service account to use for the internal proxy"
```
FilePath and Description are optional parameters in the above command

### Retrieving an entry
You can retrieve the full entry with
```
Get-CsEntry -Name ProxyServiceAccount -FilePath myCsStore.json
```
However is mosts cases you will only want to get the Credential back, you can do with
```
Get-CsCredential -Name ProxyServiceAccount -FilePath myCsStore.json
```

## Using CredentialStore with script Parameters
A common use case for CredentialStore is setting a default parameter for a powershell function.
```
function Invoke-Test() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [PSCredential] $Credential = (Get-CsCredential AppServiceAccount)
    )

    Write-Host "Hello $($Credential.Username)"
}
```

## Syncing the CredentialStore
In most cases when setting up a new machine or service it is impractical to manually enter all the credentials that are needed. An approach we have taken in these case is to store the credentials in a secure internal or online service like Azure KeyVault.

We then run a once off setup task to import of the credentials into a CredentialStore.

### Example of import the credentials from Azure KeyVault
```
# Properties needed to connect to Azure
$azureSubscriptionId = "xxxx-xxxxx-xxxxx-xxxxx"
$azureKeyVaultName = 'MyAzureKeyVault'
$azureCredential = Get-Credential

# Create a local Credential Store
$localCredentialStore = "myCredentialStore.json"
Initialize-CsStore -FilePath $localCredentialStore

# Get the entries from the KeyVault
Import-Module AzureRM.KeyVault
Add-AzureRmAccount -Credential $azureCredential -SubscriptionId $azureSubscriptionId

# Save the entries to your local credential store
# Note - you can store information sure the entry name, the username and description as tags in Azure KeyVault
$vaultEntries = Get-AzureKeyVaultSecret -VaultName $azureKeyVaultName
foreach ($entry in $vaultEntries) {
    $name = $entry.Tags["Name"]
    $username = $entry.Tags["Username"]
    $description = $entry.Tags["Description"]

    $secret = Get-AzureKeyVaultSecret -VaultName $azureKeyVaultName -Name $entry.Name
    $cred = New-Object PSCredential($username, $secret.SecretValue)

    Set-CsEntry -FilePath $localCredentialStore -Name $name -Credential $cred -Description $description
}
```
