# Repository File Structure

This document describes the file and folder structure of the `policy.documentation` repository.

## Structure Overview

| Folder | Description |
| :----- | :---------- |
|[.azuredevops](#azuredevops) | Contains Azure DevOps pipeline and templates for the automated generation of Azure Policy documentation. |
|[.github](#github) | Contains GitHub Actions workflow and reusable actions for the automated generation of Azure Policy documentation. |
| [.vscode](#vscode) | Visual Studio Code workspace settings and recommended extensions for working with the repository. |
| [configurations](#configurations) |  Configuration files used by the pipelines. |
| docs | Documentation |
| [ps_modules](#ps_modules) | PowerShell modules used by the pipelines. |
| [scripts](#scripts) | PowerShell scripts used by the pipelines. |
| [security-controls](#security-controls) | Sample custom security controls that are defined by the organization and used by the custom Azure Policy. They are included in the Policy Wiki documentation. |
| [.gitignore](./../.gitignore) | Specifies files and folders to be ignored by Git. |
| [markdownlint.json](./../.markdownlint.json) | Configuration file for markdownlint VS Code extension. |
| [settings.yml](./../settings.yml) | Settings file used by the pipelines. This file contains various variables used by both Azure DevOps and GitHub Actions pipelines. |

## Folders

### .azuredevops

- [pipelines/azure-pipelines-policy-documentation.yml](../.azuredevops/pipelines/azure-pipelines-policy-documentation.yml): The YAML file for the automated Policy Documentation Azure DevOps pipeline.
- [templates/template-stage-initiation.yml](../.azuredevops/templates/template-stage-initiation.yml): The template for the initiation stage of the pipeline.
- [templates/template-stage-policy-doc-environment-discovery.yml](../.azuredevops/templates/template-stage-policy-doc-environment-discovery.yml): The template for the environment discovery stage of the pipeline.
- [templates/template-stage-policy-doc-generate-wiki.yml](../.azuredevops/templates/template-stage-policy-doc-generate-wiki.yml): The template for the wiki generation stage of the pipeline.
- [pull_request_template.md](../pull_request_template.md): The Azure DevOps pull request template for contributions to the repository.

### .github

- [workflows/policy-documentation.yml](../.github/workflows/policy-documentation.yml): The YAML file for the automated Policy Documentation GitHub Actions workflow.
- [actions/templates/initiation/action.yml](../.github/actions/templates/initiation/action.yml): The reusable action for the initiation job of the workflow.
- [actions/templates/policyDocDiscovery/action.yml](../.github/actions/templates/policyDocDiscovery/action.yml): The reusable action for the environment discovery jobs of the workflow.
- [actions/templates/policyDocParseConfig/action.yml](../.github/actions/templates/policyDocParseConfig/action.yml): The reusable action for parsing the configuration file. It is used in the Parse Config jobs of the workflow.
- [actions/templates/policyDocGenerateWiki/action.yml](../.github/actions/templates/policyDocGenerateWiki/action.yml): The reusable action for the wiki generation jobs of the workflow.
- [PULL_REQUEST_TEMPLATE.md](../PULL_REQUEST_TEMPLATE.md): The GitHub pull request template for contributions to the repository.

### .vscode

- [extensions.json](../.vscode/extensions.json): The recommended extensions for working with this repository in Visual Studio Code.
- [PSScriptAnalyzerSettings.psd1](../.vscode/PSScriptAnalyzerSettings.psd1): The PowerShell Script Analyzer settings for this repository.
- [settings.json](../.vscode/settings.json): The recommended settings for working with this repository in Visual Studio Code.

### configurations

- [additional-policy-metadata-config.jsonc](../configurations/additional-policy-metadata-config.jsonc): The configuration file for additional policy metadata to be included in the Policy Documentation wiki.
- [ado-config.jsonc](../configurations/ado-config.jsonc): The configuration file for the Azure DevOps Policy Documentation pipeline.
- [github-config.jsonc](../configurations/github-config.jsonc): The configuration file for the GitHub Actions Policy Documentation workflow.

### ps_modules

- [AzPolicyLens](../ps_modules/AzPolicyLens): The AzPolicyLens module provides cmdlets to generate Azure Policy documentation wikis.
- [AzPolicyLens.Discovery](../ps_modules/AzPolicyLens.Discovery): The child module for AzPolicyLens. This module provides cmdlets to perform environment discovery for Azure Policy documentation wiki.
- [AzPolicyLens.Wiki](../ps_modules/AzPolicyLens.Wiki): The child module for AzPolicyLens. This module provides cmdlets to generate wiki pages for Azure Policy documentation wiki.

### scripts

- [ado-policy-doc-parse-config-file.ps1](../scripts/ado-policy-doc-parse-config-file.ps1): This script parses the policy documentation configuration file and output wiki information to Azure DevOps pipeline variables. It is used in the Azure DevOps pipeline.
- [environment-discovery.ps1](../scripts/environment-discovery.ps1): This script performs environment discovery for Azure Policy documentation wiki using the AzPolicyLens.Discovery module. It is used in both Azure DevOps and GitHub Actions pipelines.
- [generate-wiki-pages.ps1](../scripts/generate-wiki-pages.ps1): This script generates wiki pages for Azure Policy documentation wiki using the AzPolicyLens.Wiki module. It is used in both Azure DevOps and GitHub Actions pipelines.
- [github-policy-doc-parse-config-file.ps1](../scripts/github-policy-doc-parse-config-file.ps1): This script parses the policy documentation configuration file and output wiki information to GitHub Action variables. It is used in the GitHub Actions workflow.
- [github-set-variables.ps1](../scripts/github-set-variables.ps1): This script sets GitHub Action variables from the Azure Policy documentation settings configuration file. It is used in the GitHub Actions workflow.
- [helper/helper-functions.ps1](../scripts/helper/helper-functions.ps1): This script contains helper functions used by other scripts in this folder.

### security-controls

- [contoso-bank-azure-control](../security-controls/contoso-bank-azure-control/): This folder contains 60 sample custom security controls for a fictional organization called Contoso Bank. This is for demo purposes only. These controls are generated by ChatGPT. Each control is defined in a separate JSON file.
- [iso27001-2022](../security-controls/iso27001-2022/): This folder contains security controls for the `ISO/IEC 27001:2022` standard. The reason for including `ISO/IEC 27001:2022` as custom security controls is because the built-in security controls provided by Azure Policy are incomplete for `ISO/IEC 27001:2022`.
- [security-control.schema.json](../security-controls/security-control.schema.json): The JSON schema for custom security control definition files.
