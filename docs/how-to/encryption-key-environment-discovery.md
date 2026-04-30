# Create Encryption Key for Environment Discovery Artifact

## Why Create an Encryption Key?
Although the environment discovery data does not contain sensitive information, it is recommended to encrypt the artifact for added security. Using an encryption key ensures the discovery data is encrypted at rest using your own key. The cloud provider for Azure DevOps or GitHub (Microsoft) will not have access to your environment discovery data after it is stored in the artifact storage.


## How to Create an Encryption Key

After cloned this repository,  navigate to the root directory of the repository in PowerShell.

You can create an encryption key using the AzPolicyLens PowerShell module with the following command:

```powershell
  function Get-GitRoot {
    $gitRootDir = Invoke-expression 'git rev-parse --show-toplevel 2>&1' -ErrorAction SilentlyContinue
    if (Test-Path $gitRootDir) {
      Convert-Path $gitRootDir
    }
  }

  $gitRoot = Get-GitRoot
  $discoveryModulePath = Join-Path $gitRoot 'ps_modules/AzPolicyLens.Discovery'

  Import-module $discoveryModulePath

  New-AzplEncryptionKey -OutputDir 'C:\Temp' -FileName 'MyEncryptionKey.json'
```


Once the key is created, you can open the generated JSON file to view the key details, which includes the `KeyID`, `Key`, and `IV` values. You will need to provide the `Key` and `IV` values as parameters when running the environment discovery command to encrypt the discovery artifact.

```json
{
  "Key": "the encryption key value ",
  "IV": "the initialization vector value"
}
```
