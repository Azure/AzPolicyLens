# Frequently Asked Questions (FAQ)

This section provides answers to some of the most common questions regarding the AzPolicyLens Auto Documentation Pipelines and wikis.

## AzPolicyLens PowerShell Module

### Can I manually generate policy documentation without using the pipelines?

<details>
<summary>Click to expand the answer</summary>
You can manually generate policy documentation using the AzPolicyLens PowerShell module. The process is documented in the [How to Manually Generate Policy Wiki](how-to/manually-generate-policy-wiki.md) guide.

</details>

### How to get help for the AzPolicyLens PowerShell module cmdlets?

<details>

<summary>Click to expand the answer</summary>

All the cmdlets in the AzPolicyLens PowerShell modules are fully documented. The module help files are embedded within the modules.

To get a list of all cmdlets in the AzPolicyLens modules, you can run the following command:

```PowerShell
#AzPolicyLens.Discovery module
Get-Command -Module AzPolicyLens.Discovery

#AzPolicyLens.Wiki module
Get-Command -Module AzPolicyLens.Wiki
```

To get detailed help for a specific cmdlet, you can use the `Get-Help` cmdlet. For example, to get help for the `Invoke-AzplEnvironmentDiscovery` cmdlet, you can run:

```PowerShell
Get-Help Invoke-AzplEnvironmentDiscovery -Full
```

</details>

### Why are AzPolicyLens separated into two child modules?

<details>

<summary>Click to expand the answer</summary>

To support the scenario where the environment discovery and policy wiki generation are performed separately by separate teams or processes, the AzPolicyLens PowerShell module is divided into two child modules:

- `AzPolicyLens.Discovery`: This module contains cmdlets related to environment discovery
- `AzPolicyLens.Wiki`: This module contains cmdlets related to policy documentation wiki generation

To consume the environment discovery data created by the `AzPolicyLens.Discovery` module, the `AzPolicyLens.Wiki` module must use have the following information:
- Same encryption key file used to encrypt the environment discovery artifact.

</details>

## Security Considerations

### How is sensitive information handled in the pipelines?

<details>

<summary>Click to expand the answer</summary>

The AzPolicyLens Auto Documentation Pipelines are designed with security best practices in mind. The discovery artifact only contains information required for generating policy documentation and does not include any sensitive information such as passwords, secrets, or personal data.

The following information are collected in the environment discovery artifact:

- Full payload of Azure Policy Assignments, Definitions, Initiatives, and Exemptions
- Azure Management Group hierarchy
  - name, id
  - parent management group id and name
- Azure Subscriptions under the management groups
  - name, subscription id, tenant id
  - parent management group
  - management group ancestor chain
  - state and quota id (type of subscription)
- Azure Role Assignments created for the Policy Assignments
  - id
  - principal id and type
  - scope
  - role definition id
- Azure Role Definitions referenced by the Role Assignments
  - id, name, description, type
  - assignable scopes
  - is service role
- Built-in policy metadata associated with the policies and configured to be included in the discovery
- Policy Assignment Compliance
  - policy assignment name, id and assigned scope
  - subscription id
  - compliance state and percentage
  - count for resources in different compliance states
- Subscription Compliance Summary under the management group
  - subscription id
  - compliance stage and percentage
  - count for resources in different compliance states
- Compliance summary by policy definition group under the management group
  - policy definition group name
  - policy definition reference id
  - policy definition id
  - policy assignment id
  - subscription id
  - policy metadata Id for built-in policy metadata
  - count for resources in different compliance states

The content of the discovery artifact can be manually examined using the AzPolicyLens PowerShell module cmdlet `Import-AzplEnvironmentDiscovery`.

None of above listed information are considered sensitive information. The identity used for environment discovery only requires the reader role at the management group level to collect the required information. It does not require any data plane access to any resources.

The environment discovery data does not contain information for any Azure resources, resource groups.

To further enhance security, the pipelines are designed to encrypt the environment discovery artifact using AES (symmetric) encryption before storing the artifacts in pipeline artifact storage. The encryption keys are managed securely ensuring even when the artifact storage is compromised, the environment discovery data remains protected because it is encrypted at rest.

</details>

### How is the environment discovery data collected?

<details>

<summary>Click to expand the answer</summary>
Under the hood, the environment discovery data is collected purely using Azure Resource Graph (ARG) queries. No direct calls to Azure Resource Manager (ARM) REST APIs are made to collect the data. This design choice ensures that the environment discovery process is efficient and scalable, as ARG is optimized for querying large sets of Azure resources across multiple subscriptions and management groups. It also minimizes the permissions required for the identity used for environment discovery, as ARG queries can be performed with reader role at the management group level. No special permissions to any Azure resource providers are required.

</details>

### Why does the environment discovery artifact need to be encrypted?

<details>

<summary>Click to expand the answer</summary>

When using the Cloud-hosted pipeline platforms such as Azure DevOps or GitHub Actions, the pipeline artifacts are stored in the cloud managed by the owner of the platform (Microsoft in this case). Although the pipeline artifact storage is generally secure, since the customer does not have direct control over the storage, to further enhance security, the environment discovery artifact is encrypted using a customer managed key before being stored in the pipeline artifact storage.

</details>

### How is the encryption key for the environment discovery artifact managed?

<details>

<summary>Click to expand the answer</summary>

For both Azure DevOps and GitHub Actions pipelines, the encryption keys used to encrypt the environment discovery artifacts are kept as secrets in the pipeline platform's secret management system (Azure Devops variable groups or GitHub Actions Secrets). With Azure DevOps, to further enhance security, you can also configure the variable group to use Azure Key Vault to manage the secrets.

The encryption keys can be disposed or updated by updating the secret in the pipeline platform's secret management system. After the encryption key is updated, the next environment discovery run will use the new encryption key to encrypt the artifact. Note that after the encryption key is updated, any previously generated environment discovery artifacts cannot be decrypted using the new key. If you need to access the data in previously generated artifacts, you must use the old encryption key to decrypt them.

</details>

### Why are the environment discovery artifacts encrypted using AES (symmetric) and not RSA (asymmetric)?

<details>

<summary>Click to expand the answer</summary>

Although asymmetric encryption (e.g., RSA) provides advantages in key management and distribution, decrypting large files using asymmetric encryption can be computationally intensive and slow. Symmetric encryption algorithms like AES are generally faster and more efficient for encrypting and decrypting large files, making them more suitable for scenarios where performance is a concern. Thus, to optimize performance while ensuring data security, AES (symmetric) encryption is used for encrypting the environment discovery artifacts.

</details>

## Azure Policy

### The compliance rating for a specific security control is not matching my expectation, why is that?

<details>

<summary>Click to expand the answer</summary>

The security controls are mapped to each policy definition in the policy initiatives. To do so, firstly define the security controls in the `policyDefinitionGroups` section of the Policy Initiative JSON file. for example:

```json
"policyDefinitionGroups": [
  {
    "name": "ISO27001-2013_A.8.2.1",
    "additionalMetadataId": "/providers/Microsoft.PolicyInsights/policyMetadata/ISO27001-2013_A.8.2.1"
  },
  {
    "name": "CB-AZ-037"
  }
]
```

In the above example, the first policy definition group has `additionalMetadataId` property defined, which maps the policy definition group to a built-in policy metadata resource. The second policy definition group does not have the `additionalMetadataId` property defined, which means it is a custom security control (internal to the organization).

Once the security controls are defined in the `policyDefinitionGroups` section, you can then map the policy definition to the security controls by defining the `groupNames` property in each policy definition in the initiative. You can multiple policy definition group to a policy within the initiative. For example:

```json
"policyDefinitions": [
  {
    "policyDefinitionReferenceId": "TAG-001",
    "policyDefinitionId": "/providers/Microsoft.Management/managementGroups/MyMG/providers/Microsoft.Authorization/policyDefinitions/pol-sub-should-have-required-tag",
    "parameters": {
      "effect": {
        "value": "[parameters('TAG-001_Effect')]"
      },
      "tagName": {
        "value": "SolutionID"
      }
    },
    "groupNames": [
      "ISO27001-2013_A.8.2.1",
      "CB-AZ-037"
    ]
  }
]
```

Lastly, if custom security controls are in use, make sure they are defined in the custom security control JSON files and included in the wiki generation process.

For built-in controls, the AzPolicyLens module uses the `additionalMetadataId` property to aggregate the compliance data for the security control from all policy definitions mapped to the control.

For custom controls, the AzPolicyLens module uses the `name` property of the policy definition group to aggregate the compliance data for the security control from all policy definitions mapped to the control. It is important to ensure that the `name` property of the custom security control matches exactly with the name used in the custom security control JSON files.

</details>

### How to ensure the Initiative Categories column from the Analysis page Policy Control Coverage tables are populated correctly?

<details>

<summary>Click to expand the answer</summary>

Under the `POLICY CONTROL COVERAGE` section of the Analysis page, the `Initiative Categories` column in the tables is populated based on the `category` property defined in the built-in policy metadata resources.

![Initiative Categories Column](../images/faq-initiative-category.png)

To ensure the `Initiative Categories` column is populated correctly, make sure `category` metadata is correctly defined for each policy initiative. `Category` is one of the commonly used metadata properties for Azure Policy. It is recommended that all the commonly used metadata properties listed from [Microsoft's documentation](https://learn.microsoft.com/azure/governance/policy/concepts/definition-structure-basics#common-metadata-properties) are defined in your custom policy definitions and initiatives.

</details>

### How does the wiki know which policy definitions and initiatives are deprecated?

<details>

<summary>Click to expand the answer</summary>

The AzPolicyLens module determines whether a policy definition or initiative is deprecated based on the `deprecated` metadata property defined in the policy definition or initiative JSON file. If the `deprecated` property is set to `true`, the policy definition or initiative is considered deprecated.

`deprecated` is one of the commonly used metadata properties for Azure Policy. It is recommended that all the commonly used metadata properties listed from [Microsoft's documentation](https://learn.microsoft.com/azure/governance/policy/concepts/definition-structure-basics#common-metadata-properties) are defined in your custom policy definitions and initiatives.

</details>

### What can I do if the built-in policy metadata is incorrect, missing or inconsistent for a given framework?

<details>

<summary>Click to expand the answer</summary>

You may find the built-in policy metadata for a specific framework provided by Microsoft is incorrect, incomplete, or inconsistent. In such cases, you can create custom policy definitions and initiatives with the correct metadata and use them instead of the built-in ones. This allows you to maintain accurate and consistent policy documentation for your organization.

For example, you may define the `ISO/IEC 27001:2022` as a custom security control framework by defining each control in the framework as json files in the custom security control folder. You can then create map to the controls to policy definitions in Policy Initiative's JSON configuration.
</details>

### What can I do if the built-in policy initiative that I use does not have the security control mapping for the framework I need?

<details>

<summary>Click to expand the answer</summary>

You can consider replacing the built-in initiative with a custom policy initiative. You can define the security control mapping as per your requirements.

</details>

### How do I define custom security controls for my organization's specific framework?

<details>

<summary>Click to expand the answer</summary>

You can define each custom security control in a JSON file. Please refer to the [Create Custom Security Control Catalog](how-to/custom-security-control-catalog.md) guide for detailed instructions on how to create custom security control definitions and import them when generating the policy wiki.

</details>

## Azure DevOps Wikis

### Can I use a single Azure DevOps project to host multiple policy documentation wikis for different environments and different teams?

<details>

<summary>Click to expand the answer</summary>

Yes, you can use a single Azure DevOps project to host multiple policy documentation wikis for different environments and different teams. Each wiki can be created in a separate Git repository within the same Azure DevOps project. You can configure the Wiki access for different teams by assigning appropriate permissions to the Git repositories hosting the wikis.

Azure DevOps users can only access the wikis they have been granted permissions to, ensuring that sensitive policy documentation is only accessible to authorized users.

</details>

### What type of Azure DevOps license is required to access the policy documentation wikis?

<details>

<summary>Click to expand the answer</summary>

Since the Policy Documentation are published as code wiki in the Azure DevOps project, each user accessing the wiki must have the `Basic` license in the Azure DevOps organization where the wiki is hosted. The free `Stakeholder` license does not provide access to code wikis.

</details>

## GitHub Wikis

### Some sections of the GitHub wiki are not rendering the font color correctly, why is that?

<details>

<summary>Click to expand the answer</summary>

Looks like the font color is not rendered when you use the back button on the browser to navigate back to a wiki page. This is a known issue with GitHub wikis. To work around this issue, you can refresh the wiki page after navigating back to it using the back button. This should correctly render the font colors.

</details>

## Other Questions

### Why are the hidden tags and metadata not included in the basic wiki page style?

<details>

<summary>Click to expand the answer</summary>

It is a common practice for the cloud platform teams to use hidden tags to store information about the resources that are not intended to be visible to end users (application teams in this case) from the Azure portal. Including the hidden tags ain the basic wiki page style may lead to unintended exposure of information that are supposed to be hidden from end users.

Although Azure Policy resources do not support tags, they do support metadata which serves the same purpose. Some customers may have adopted this practice and implemented similar patterns for policy resources by using `hidden-` or `hidden_` prefixes for metadata names to indicate that the metadata should be hidden from end users. To respect this common practice, the basic wiki page style excludes hidden tags and metadata to prevent unintended exposure these information to the application teams.

</details>

### How often should I run the environment discovery to keep the policy documentation up-to-date?

<details>

<summary>Click to expand the answer</summary>

The frequency of running the environment discovery depends on how the policy wikis are consumed and how quickly users expect changes to be made to the wiki.

We recommend you configure the pipeline to run several times a day. The first run can be scheduled before the start of the business hours (i.e. 7:00 AM local time) to ensure the wiki is up-to-date at the start of the business day. Subsequent runs can be scheduled to run several hours apart until the end of the business day.

If you don't expect people to access the wiki outside of business hours, you can avoid scheduling runs during non-business hours to reduce unnecessary pipeline runs.

If your organization operates across multiple time zones, you may want to schedule additional runs to ensure the wiki is updated during the business hours of different regions.

</details>

### What browsers are tested for viewing the policy documentation wikis?

<details>

<summary>Click to expand the answer</summary>

The policy documentation wikis are tested and verified to work correctly on the latest versions of the following browsers:

- Google Chrome
- Chromium-based browsers (e.g., Microsoft Edge, Brave, etc.)
- Apple Safari

Although not explicitly tested, the wikis should also work correctly any other modern browsers that support standard Markdown rendering.

</details>

### Where can I find more information about AzPolicyLens?

<details>

<summary>Click to expand the answer</summary>

You can find more information about AzPolicyLens on the [AzPolicyLens website](https://tbd).

If you have further questions, you can reach out to the AzPolicyLens support team at [Email address](mailto:support@tbd).

</details>
