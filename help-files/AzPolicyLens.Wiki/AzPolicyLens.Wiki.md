---
document type: module
Help Version: 2.0.0
HelpInfoUri:
Locale: en-AU
Module Guid: d8e25613-aa1b-46db-b893-d1aae3064b9a
Module Name: AzPolicyLens.Wiki
ms.date: 08/18/2025
PlatyPS schema version: 2024-05-01
title: AzPolicyLens.Wiki Module
---

# AzPolicyLens.Wiki Module

## Description

Generate Azure Policy documentation in Markdown format. This module is designed to work with the Az.ResourceGraph and Az.Accounts modules generate comprehensive documentation for them.

## AzPolicyLens.Wiki

### [Import-AzplEnvironmentDiscovery](Import-AzplEnvironmentDiscovery.md)

Import existing environment details previously exported using the `Invoke-AzplEnvironmentDiscovery` function from the `AzPolicyLens.Discovery` module.

### [New-AzplDocumentation](New-AzplBasicDocumentation.md)

Generate either basic or detailed documentation for the entire environment or a subset of subscriptions.

The detailed documentation is intended to be used by the support engineers of the Azure cloud platform.

The basic documentation is intended to be used by the customer of the Azure cloud platform.
