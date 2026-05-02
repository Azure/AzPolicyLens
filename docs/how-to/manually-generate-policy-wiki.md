# How to Manually Generate Policy Wiki

This document provides instructions on how to manually generate a policy wiki without using the Azure DevOps Pipelines or GitHub Actions.

## Prerequisites

### Azure CLI or Az PowerShell Module

You will need to generate the Azure oAuth token for the wiki generation process. You can use either the Azure CLI or the Az PowerShell module.

### AzPolicyTest PowerShell Module

The AzPolicyTest PowerShell module is required for the wiki generation process. Please ensure you have version 3.1.1 or later installed. You can install it using the following command:

```powershell
Install-Module -Name AzPolicyTest -RequiredVersion 3.1.1 -Force -Scope CurrentUser
```

### Git

You will need Git installed on your machine to clone the wiki repository.

## Instructions

1. **Clone the Wiki Repository**

   First, clone the wiki repository to your local machine using Git.

   ```powershell
   git clone <URL of the wiki repository>
   ```

2. **Generate Encryption Key**

   If you do not already have an encryption key for the environment discovery artifact, and you'd like to encrypt the discovery artifact, you can generate one using the instructions in the [Create Encryption Key for Environment Discovery Artifact](how-to/encryption-key-environment-discovery.md) guide.

3. **Log In to Azure**
   - Using Azure CLI:
     ```powershell
     az login
     ```

   - Using Az PowerShell Module:
     ```powershell
     Connect-AzAccount
     ```

4. **Generate Azure oAuth Token**

   - Using Azure CLI:
     ```powershell
     $token = az account get-access-token --resource="https://management.azure.com/" --query "accessToken" -o tsv
     ```

   - Using Az PowerShell Module:
     ```powershell
     $token = ConvertFrom-SecureString (Get-AzAccessToken -ResourceUrl 'https://management.azure.com/').token -AsPlainText
     ```

5. **Define mandatory variables in PowerShell**

  Define the following mandatory variables for the wiki generation process

    * Specify the top level Management Group Id

    ```powershell
    $mg = "<e.g. ContosoRoot>" # Top level management group name or ID
    ```

    * Specify the title for the generated policy wiki.

    ```powershell
    $policyWikiTitle = "<e.g. Policy Documentation Wiki>" # Title of the generated wiki change as needed
    ```


    * Specify the page style (`detailed` or `basic`) and wiki style (`ado` or `github`) for the generated wiki.

    ```powershell
       $wikiStyle = "<github or ado>"
       $pageStyle = "<detailed or basic>"
    ```

    * Specify the path where you want to save the generated wiki. This can be the local clone of your wiki repository.

    ```powershell
      $WikiRepositoryPath = "<Path to the local clone of the wiki repository>"
    ```

    * Specify the path to the encryption key file you generated earlier. If you want to encrypt the environment discovery artifact, otherwise, leave it empty.

    ```powershell
    $encryptionFilePath = "<Path to the encryption key file>"
    ```

    * Specify the directory path for storing the environment discovery artifact.

    ```powershell
      $discoveryFileDirectory = "<Directory path to save the environment discovery artifact>"
    ```

1. Specify optional variables in PowerShell if required

    * Optional: Specify the file base name for the environment discovery artifact. The final environment discovery artifact will be saved as a zip file with the name format of `<file base name>.zip` in the specified directory. if not specified, the default value is the name of the top level management group name.

    ```powershell
      $discoveryFileBaseName = 'discovery-artifact'
    ```

    * Optional:Specify Number of days before example expiration to show warning in the wiki, you can adjust this value as needed. If not specified, the default value is 30 days.

    ```powershell
     $ExemptionExpiresOnWarningDays = 30 # Number of days before exemption expiration to show warning
    ```

    * Optional:Specify the compliance percentage threshold to show warning in the wiki, you can adjust this value as needed. If not specified, the default value is 80%, which means if the compliance percentage of a resource is below 80%, it will show red, if it's between 80% and 100%, it will show yellow warning, if it's 100%, it will show green.

    ```powershell
     $ComplianceWarningPercentageThreshold = 80 # Compliance percentage threshold to show warning, below this will show red, >= this but below 100% will show yellow, 100% will show green
    ```

    * Optional: Specify the path to the custom security control definitions if you have custom security controls that you want to include in the generated wiki. If not, you can leave it empty or remove the line in the code.

    ```powershell
      $CustomSecurityControlPath = Join-Path $gitRoot 'security-controls' # Path to custom security control definitions, change as needed
    ```

    * Optional but strongly recommended: Define the additional built-in policy metadata configurations to include more built-in policy metadata in the discovery artifact, which allows you to build a more complete catalog for the desired security frameworks in the generated policy wiki. Refer to the [Define Additional Built-In Policy Metadata](additional-built-in-policy-metadata.md) guide for more details on how to define the additional built-in policy metadata configurations.

    ```powershell
      $additionalBuiltInPolicyMetadataConfig = @()
      #define additional built-in policy metadata configurations if needed. i.e.:
      $additionalBuiltInPolicyMetadataConfig += @{
        framework = 'ISO 27001:2013'
        policyMetadataNameRegex = '^ISO27001-2013_A' # name starts with 'ISO27001-2013_A'
      }
      $additionalBuiltInPolicyMetadataConfig += @{
        framework = 'Microsoft Cloud Security Benchmark V3.0'
        policyMetadataNameRegex = '^Azure_Security_Benchmark_v3\.0' # name starts with 'Azure_Security_Benchmark_v3.0'
      }
    ```

2. **Import AzPolicyLens Modules**

  ```powershell
  function Get-GitRoot {
    $gitRootDir = Invoke-expression 'git rev-parse --show-toplevel 2>&1' -ErrorAction SilentlyContinue
    if (Test-Path $gitRootDir) {
      Convert-Path $gitRootDir
    }
  }

  $gitRoot = Get-GitRoot
  $discoveryModulePath = Join-Path $gitRoot 'ps_modules/AzPolicyLens.Discovery'
  $wikiModulePath = Join-Path $gitRoot 'ps_modules/AzPolicyLens.Wiki'

  Import-module $discoveryModulePath
  Import-module $wikiModulePath
  ```

8. **Invoke Environment Discovery**

  ```powershell
    $DiscoveryParams = @{
      TopLevelManagementGroupName = $mg
      Token = $token
      EncryptionKeyFilePath = $encryptionFilePath #Optional
      OutputFileDirectory = $discoveryFileDirectory
      OutputFileBaseName = $discoveryFileBaseName #Optional
      additionalBuiltInPolicyMetadataConfig = $additionalBuiltInPolicyMetadataConfig #Optional
    }
    Invoke-AzplEnvironmentDiscovery @DiscoveryParams
  ```

9. **Examine the environment discovery data (optional)**

  You can examine the generated environment discovery artifact to ensure it contains the expected data.

  ```powershell
    $discoveryFile = Join-Path $discoveryFileDirectory ($discoveryFileBaseName + '.zip')
    $importParams = @{
      FilePath = $discoveryFile
      EncryptionKeyFilePath = $encryptionFilePath #Optional
    }
    $environmentDiscoveryData = Import-AzplEnvironmentDiscovery @importParams -verbose
    $environmentDiscoveryData | Format-List
  ```

10. **Optional: Pull Latest Changes from Wiki Repository**

   If you are generating the wiki and storying it in a git repository, before generating the wiki, ensure you have the latest changes from the remote wiki repository.

  ```powershell
  $CurrentDir = $pwd #capture current directory
  Set-Location $WikiRepositoryPath #navigate to wiki repo
  git pull #pull latest changes
  Set-Location $CurrentDir #return to original directory
  ```

11. **Generate the Policy Wiki**

  ```powershell
  $GenerateWikiParams = @{
    DiscoveryDataImportFilePath = $discoveryFile
    ExemptionExpiresOnWarningDays = $ExemptionExpiresOnWarningDays #Optional, default value is 30 (days)
    ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold #Optional, default value is 80(%)
    Title = $policyWikiTitle
    BaseOutputPath = $GitHubEngDevRepoPath
    WikiStyle = $wikiStyle
    PageStyle = $pageStyle
    CustomSecurityControlPath = $CustomSecurityControlPath #Remove this line if not using custom security controls
    EncryptionKeyFilePath = $encryptionFilePath #Optional, only if the discovery artifact is encrypted
  }

  Set-Location $GenerateWikiParams.BaseOutputPath

  #if the output path is a git repository, pull the latest changes before generating the wiki to avoid potential conflicts, you can remove this step if the output path is not a git repository
  git pull

  Write-Host "Creating Detailed $($GenerateWikiParams.wikiStyle) Wiki " -ForegroundColor "Green"
  New-AzplDocumentation @GenerateWikiParams -verbose
  ```

12. **Optional: Commit and Push Changes to Wiki Repository**

   If you are storing the generated wiki in a git repository, after generating the wiki, navigate to the local clone of your wiki repository, commit the changes, and push them to the remote repository.

  ```powershell
  Set-Location $WikiRepositoryPath
  git add -A
  git commit -m "Updated policy wiki"
  git push --force
  git status
  Set-Location $CurrentDir
  ```
