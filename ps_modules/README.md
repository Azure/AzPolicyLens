# AzPolicyLens PowerShell Modules

This directory contains the PowerShell modules used by the AzPolicyLens solution. The modules are used to discover the Azure Policy implementation and generate documentation for the policies and their compliance status.

## AzPolicyLens.Discovery

[AzPolicyLens.Discovery](./AzPolicyLens.Discovery) is the module responsible for discovering the Azure Policy implementation in your environment. It collects information about policies, initiatives, and their compliance status.

It is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/AzPolicyLens.Discovery) and can be installed using the following command:

```powershell
Install-Module -Name AzPolicyLens.Discovery -RequiredVersion <version>
```

## AzPolicyLens.Wiki

[AzPolicyLens.Wiki](./AzPolicyLens.Wiki) is the module responsible for generating wiki pages for the Azure Policy documentation.

It is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/AzPolicyLens.Wiki) and can be installed using the following command:

```powershell
Install-Module -Name AzPolicyLens.Wiki -RequiredVersion <version>
```

## AzPolicyLens

[AzPolicyLens](./AzPolicyLens) is the wrapper module that contains both `AzPolicyLens.Discovery` and `AzPolicyLens.Wiki` modules. It is used to install the required modules and their dependencies.

It is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/AzPolicyLens) and can be installed using the following command:

```powershell
Install-Module -Name AzPolicyLens -RequiredVersion <version>
```
