# How to Map Security Controls to Azure Policies

## Overview
Security controls can be mapped to Azure Policies in order to understand how the policies in your environment help meet the requirements of various security frameworks. This mapping can be used to build a policy wiki that organizes Azure Policies by the security controls they help implement, which can be a valuable resource for security and compliance teams.

The mapping is defined in the definition of the Policy Initiatives. To map security controls to Azure Policies, you can follow these steps:

1. Define each security control in the [Policy definition groups](https://learn.microsoft.com/azure/governance/policy/concepts/initiative-definition-structure#policy-definition-groups) section of the initiative definition. Each security control should be defined as a separate group with a unique name.

2. Once all the security controls that you want to map to the member policies are defined inside the `policyDefinitionGroups` section, you can then map one or more security controls to each member policy.


## Mapping Security Controls to Azure Policies

### Defining Built-in Controls (Policy Metadata)

For security controls, you can either use a pre-defined control (built-in policy metadata), or a custom control that you define yourself.

To add a built-in control to a policy, you need to specify the following properties inside the `PolicyDefinitionGroups` section of the initiative definition:

  - `name`: The name of the control, which is used to reference in the member policy definition.
  - `additionalMetadataId`: The ID of the additional built-in policy metadata that represents the control.

for example:

```json
"policyDefinitionGroups": [
  {
    "name": "A.8.1.3",
    "additionalMetadataId": "/providers/Microsoft.PolicyInsights/policyMetadata/ISO27001-2013_A.8.1.3"
  },
  {
    "name": "A.10.1.1",
    "additionalMetadataId": "/providers/Microsoft.PolicyInsights/policyMetadata/ISO27001-2013_A.10.1.1"
  }
]
```

### Defining Custom Controls

If the specific control you want to map is not available as built-in policy metadata, you can define it as a custom control in the initiative definition. To do this, you need to specify the following properties inside the `PolicyDefinitionGroups` section of the initiative definition:

  - `name`: The short name for the group. In Regulatory Compliance, the control. The value of this property is used by groupNames in policyDefinitions.
  - `category`: The hierarchy the group belongs to. In Regulatory Compliance, the compliance domain of the control.
  - `displayName`: The friendly name for the group or control. Used by the portal.
  - `description`: A description of what the group or control covers.

>:memo: Only the `name` property is required for mapping the control to policies. If you wish to have a more user-friendly view in the Azure portal, you can use the other properties to provide more context about the control.

for example:

```json
"policyDefinitionGroups": [
  {
    "name": "Control-1",
    "category": "Identity and Access Management",
    "displayName": "Control 1: Ensure secure access",
    "description": "This control ensures that secure access policies are in place to protect sensitive resources."
  },
  {
    "name": "Control-2"
  }
]
```

>:exclamation: The AzPolicyLens module does not rely on the `category`, `displayName`, or `description` properties of the custom security control to build the wiki page for the specific control. The details of the custom control in the wiki page are based on the json files that you have defined and specified in the `CustomSecurityControlPath` variable when you run the `New-AzplDocumentation` cmdlet. This is because we are trying to model the custom controls in the wiki in the same way as the built-in policy metadata, which provides a lot more details than just the name, category, display name and description. By doing this, we can provide a more comprehensive catalog of security controls in the wiki, and also provide the flexibility for you to define any additional properties for the custom controls in the JSON file as needed.

### Mapping Controls to Policies

To map the defined controls to policies, you need to specify the `groupNames` property in each member policy definition. The value of the `groupNames` property should be an array of control names that you want to map the policy to.

for example:

```json
"policyDefinitions": [
  {
    "policyDefinitionReferenceId": "ADF-001",
    "policyDefinitionId": "/providers/Microsoft.Management/managementGroups/contoso/providers/Microsoft.Authorization/policyDefinitions/pol-audit-adf-private-endpoints",
    "parameters": {
      "effect": {
        "value": "[parameters('ADF-001_Effect')]"
      }
    },
    "groupNames": [
      "A.10.1.1",
      "Control-1"
    ]
  }
]
```

In the above example, the policy definition with reference ID `ADF-001` is mapped to both a built-in control `A.10.1.1` and a custom control `Control-1`. When the wiki is generated, this policy will be listed under both controls, allowing users to see how this policy helps meet the requirements of both the built-in control and the custom control.

## Defining Custom Security Controls for the Policy Wiki

How to define custom security controls and include them in the generated policy wiki is covered in the [Custom Security Control Catalog](custom-security-control-catalog.md) guide.
