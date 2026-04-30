# Managing Pipeline Configuration File

## Overview

Both Azure DevOps pipeline and GitHub Action workflow for Azure Policy documentation generation use several configuration files to store the pipeline/workflow variables. This article provides guidance on how to manage these configuration files.

## Pipeline Configuration Files

The configuration files are stored in the [configurations](../../configurations) folder in the root directory of the repository. Below are the descriptions of each configuration file.

### `additional-policy-metadata-config.jsonc`

This file defines the additional built-in policy metadata that you want to include in the environment discovery artifact and the generated wiki. By default, AzPolicyLens only collects the built-in policy metadata that are being referenced by the policy definitions in initiatives. By defining the additional built-in policy metadata in this configuration file, you can include more built-in policy metadata that are currently not used but belong to the same security framework as the ones being referenced in the initiatives, which allows you to build a more complete catalog for the desired security frameworks in the generated policy wiki.

Refer to the [Define Additional Built-In Policy Metadata](additional-built-in-policy-metadata.md) guide for more details on how to define the additional built-in policy metadata configurations.

The content of this jsonc file is an array of objects, where each object has the following properties:

```jsonc
{
  "framework": "<name of the security framework>",
  "policyMetadataNameRegex": "<regular expression to match the policy metadata names>"
}
```

Both Azure DevOps pipeline and GitHub Action workflow will read this configuration file to get the additional built-in policy metadata configurations when generating the environment discovery artifact.

### `ado-config.jsonc`

This file defines the configurations for the Azure DevOps pipeline that generates wikis to Azure DevOps repositories that host the code wikis.

Below is the sample content of this configuration file:

```jsonc
{
  "environment": {
    "dev": {
      "description": "Development environment for policy documentation",
      "wiki": {
        "engineering": {
          "title": "CONTOSO DEV POLICY",
          "gitRepository": "https://dev.azure.com/contoso/Policy.Documentation/_git/eng-dev-doc",
          "gitBranch": "main",
          "pageStyle": "detailed",
          "gitRepoPath": "docs/policy-documentation",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com"
        },
        "app1": {
          "title": "APP 1 DEV POLICY",
          "gitRepository": "https://dev.azure.com/contoso/Policy.Documentation/_git/customer-dev-doc",
          "gitBranch": "main",
          "pageStyle": "basic",
          "gitRepoPath": "docs/policy-documentation-app1",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "subscriptionIds": [
            "636c9e85-dfd2-4eda-b65d-436aed59345b"
          ]
        },
        "platform": {
          "title": "PLATFORM DEV POLICY",
          "gitRepository": "https://dev.azure.com/contoso/Policy.Documentation/_git/platform-dev-doc",
          "gitBranch": "main",
          "pageStyle": "detailed",
          "gitRepoPath": "docs/policy-documentation-platform",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "childManagementGroupId": "CONTOSO-DEV-Platform"
        }
      }
    },
    "prod": {
      "description": "Production environment for policy documentation",
      "wiki": {
        "engineering": {
          "title": "CONTOSO PROD POLICY",
          "gitRepository": "https://dev.azure.com/contoso/Policy.Documentation/_git/eng-prod-doc",
          "gitBranch": "main",
          "pageStyle": "detailed",
          "gitRepoPath": "docs/policy-documentation",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com"
        },
        "app1": {
          "title": "APP 1 PROD POLICY",
          "gitRepository": "https://dev.azure.com/contoso/Policy.Documentation/_git/customer-prod-doc",
          "gitBranch": "main",
          "pageStyle": "basic",
          "gitRepoPath": "docs/policy-documentation-app1",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "subscriptionIds": [
            "61b84c68-1e41-419a-a339-53cedc4dcb8e",
            "3dafb756-e2a1-4bc0-a67a-ac6aba34de72"
          ]
        },
        "platform": {
          "title": "PLATFORM PROD POLICY",
          "gitRepository": "https://dev.azure.com/contoso/Policy.Documentation/_git/platform-prod-doc",
          "gitBranch": "main",
          "pageStyle": "detailed",
          "gitRepoPath": "docs/policy-documentation-platform",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "childManagementGroupId": "CONTOSO-Platform"
        }
      }
    }
  }
}

```

The top level property `environment` defines the environments that you have for hosting the policy wikis. This maps to the environment specific data discovery and wiki generation stages of the Azure Pipeline. You can have multiple environments such as `dev`, `prod`, `pre-prod` etc. under the `environment` property. the environment specific pipeline stages will get the configuration for the corresponding environment from this configuration file.

Under each environment, each property under `wiki` represents a wiki instance. for each instance, you will need to specify the following properties:

- `title`: the title of the generated wiki, which will be displayed in the wiki home page and also used as the name of the wiki in Azure DevOps when publishing the generated wiki to Azure DevOps. You can change it to whatever title you want for the generated wiki.
- `gitRepository`: the git repository URL of the Azure DevOps repository that hosts the wiki. Note only `https` URL is supported, `ssh` URL is not supported because the pipeline does not use ssh key for authentication.
- `gitBranch`: the git branch that you want to publish the generated wiki to. This must be aligned with how the code wiki is configured in your Azure DevOps project.
- `pageStyle`: the page style for the generated wiki, which can be either `detailed` or `basic`. Generally speaking, the `detailed` page style is designed for the cloud platform team, cloud architect and security operations teams on the enterprise level. Whereas the 'basic' page style is normally limited to a subset of subscriptions and is designed for application teams.
- `gitRepoPath`: the path within the git repository where the wiki content is stored. This must be aligned with how the code wiki is configured in your Azure DevOps project.
- `gitUserName`: the git username to use when committing changes to the git repository. Note: This is not the username for authentication, but just the name that will be displayed in the commit history for the commits made by the pipeline. The Azure DevOps pipeline does not use any ADO users for pushing changes to the git repository. details can be found in the [Azure DevOps Wiki Setup Guide](ado-wiki-setup.md).
- `gitUserEmail`: the git email address to use when committing changes to the git repository.
- `subscriptionIds`: optional. An array of subscription IDs that the wiki is associated with. This is typically used for 'basic' page style wikis. This setting cannot be used together with `childManagementGroupId`.
- `childManagementGroupId`: optional. The child management group ID that the wiki is associated with. This is used when you want to generate wiki content for policies that are assigned at the management group level and you want to scope down the wiki content to only include the policies that are assigned at a specific child management group. This is can be used in both 'detailed' and 'basic' page style wikis. This setting cannot be used together with `subscriptionIds`.

### `github-config.jsonc`

This file defines the configurations for the GitHub action workflow that generates wikis to GitHub repositories that host the code wikis.

Below is the sample content of this configuration file:

```jsonc
{
  "environment": {
    "dev": {
      "description": "Development environment for policy documentation",
      "wiki": {
        "engineering": {
          "title": "CONTOSO DEV POLICY",
          "gitRepository": "https://github.com/contoso/azure.policy.doc.eng.dev.wiki.git",
          "gitBranch": "master",
          "pageStyle": "detailed",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com"
        },
        "app1": {
          "title": "APP 1 DEV POLICY",
          "gitRepository": "https://github.com/contoso/azure.policy.doc.app.dev.wiki.git",
          "gitBranch": "master",
          "pageStyle": "basic",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "subscriptionIds": [
            "46aa6fb9-01f8-4acc-b67c-ee355f6b6fa0"
          ]
        },
        "platform": {
          "title": "PLATFORM DEV POLICY",
          "gitRepository": "https://github.com/contoso/azure.policy.doc.platform.dev.wiki.git",
          "gitBranch": "master",
          "pageStyle": "detailed",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "childManagementGroupId": "CONTOSO-DEV-Platform"
        }
      }
    },
    "prod": {
      "description": "Production environment for policy documentation",
      "wiki": {
        "engineering": {
          "title": "CONTOSO PROD POLICY",
          "gitRepository": "https://github.com/contoso/azure.policy.doc.eng.prod.wiki.git",
          "gitBranch": "master",
          "pageStyle": "detailed",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
        },
        "app1": {
          "title": "APP 1 PROD POLICY",
          "gitRepository": "https://github.com/contoso/azure.policy.doc.app.prod.wiki.git",
          "gitBranch": "master",
          "pageStyle": "basic",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "subscriptionIds": [
            "681512a3-2969-4449-b1b0-5b8dcad20059",
            "61e03022-b49e-440e-a906-2d0224755165"
          ]
        },
        "platform": {
          "title": "PLATFORM PROD POLICY",
          "gitRepository": "https://github.com/contoso/azure.policy.doc.platform.prod.wiki.git",
          "gitBranch": "master",
          "pageStyle": "detailed",
          "gitUserName": "AzPolicyLens Pipeline",
          "gitUserEmail": "policyDoc@contoso.com",
          "childManagementGroupId": "CONTOSO-Platform"
        }
      }
    }
  }
}
```

The top level property `environment` defines the environments that you have for hosting the policy wikis. This maps to the environment specific data discovery and wiki generation stages of the GitHub Actions workflow. You can have multiple environments such as `dev`, `prod`, `pre-prod` etc. under the `environment` property. the environment specific workflow stages will get the configuration for the corresponding environment from this configuration file.

Under each environment, each property under `wiki` represents a wiki instance. for each instance, you will need to specify the following properties:

- `title`: the title of the generated wiki, which will be displayed in the wiki home page and also used as the name of the wiki in Azure DevOps when publishing the generated wiki to Azure DevOps. You can change it to whatever title you want for the generated wiki.
- `gitRepository`: the git repository URL of the Azure DevOps repository that hosts the wiki. Note only `https` URL is supported, `ssh` URL is not supported because the pipeline does not use ssh key for authentication.
- `gitBranch`: the git branch that you want to publish the generated wiki to. Note: for GitHub wiki, the branch is typically `master`.
- `pageStyle`: the page style for the generated wiki, which can be either `detailed` or `basic`. Generally speaking, the `detailed` page style is designed for the cloud platform team, cloud architect and security operations teams on the enterprise level. Whereas the 'basic' page style is normally limited to a subset of subscriptions and is designed for application teams.
- `gitUserName`: the git username to use when committing changes to the git repository. Note: This is not the username for authentication, but just the name that will be displayed in the commit history for the commits made by the workflow. The GitHub Actions workflow uses a pre-defined fine grained personal access token (PAT) for pushing changes to the git repository. details can be found in the [GitHub Wiki Setup Guide](github-wiki-setup.md).
- `gitUserEmail`: the git email address to use when committing changes to the git repository.
- `subscriptionIds`: optional. An array of subscription IDs that the wiki is associated with. This is typically used for 'basic' page style wikis. This setting cannot be used together with `childManagementGroupId`.
- `childManagementGroupId`: optional. The child management group ID that the wiki is associated with. This is used when you want to generate wiki content for policies that are assigned at the management group level and you want to scope down the wiki content to only include the policies that are assigned at a specific child management group. This is can be used in both 'detailed' and 'basic' page style wikis. This setting cannot be used together with `subscriptionIds`.
