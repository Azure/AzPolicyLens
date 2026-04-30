---
document type: cmdlet
external help file: AzPolicyLens.Wiki-help.xml
HelpUri: ''
Locale: en-AU
Module Name: AzPolicyLens.Wiki
ms.date: 04/27/2026
PlatyPS schema version: 2024-05-01
title: New-AzplDocumentation
---

# New-AzplDocumentation

## SYNOPSIS

Generate detailed documentation for the entire environment, a subset of subscriptions, or a child management group sub-tree.

The detailed documentation is intended to be used by the support engineers of the Azure cloud platform.

The basic documentation is intended to be used by the customer of the Azure cloud platform.

## SYNTAX

### ImportNoEncryption (Default)

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string>
 [-ExemptionExpiresOnWarningDays <int>] [-ComplianceWarningPercentageThreshold <int>]
 [-CustomSecurityControlPath <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportNoEncryption_Subscription

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -SubscriptionIds <string[]>
 [-ExemptionExpiresOnWarningDays <int>] [-ComplianceWarningPercentageThreshold <int>]
 [-CustomSecurityControlPath <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportNoEncryption_ManagementGroup

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -childManagementGroupId <string>
 [-ExemptionExpiresOnWarningDays <int>] [-ComplianceWarningPercentageThreshold <int>]
 [-CustomSecurityControlPath <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportEncryptionWithKeyFile

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -EncryptionKeyFilePath <string>
 [-ExemptionExpiresOnWarningDays <int>] [-ComplianceWarningPercentageThreshold <int>]
 [-CustomSecurityControlPath <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportEncryptionWithKeyFile_Subscription

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -EncryptionKeyFilePath <string>
 -SubscriptionIds <string[]> [-ExemptionExpiresOnWarningDays <int>]
 [-ComplianceWarningPercentageThreshold <int>] [-CustomSecurityControlPath <string>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportEncryptionWithKeyFile_ManagementGroup

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -EncryptionKeyFilePath <string>
 -childManagementGroupId <string> [-ExemptionExpiresOnWarningDays <int>]
 [-ComplianceWarningPercentageThreshold <int>] [-CustomSecurityControlPath <string>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportEncryptionWithKeyText

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -EncryptionKey <string>
 -EncryptionIV <string> [-ExemptionExpiresOnWarningDays <int>]
 [-ComplianceWarningPercentageThreshold <int>] [-CustomSecurityControlPath <string>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportEncryptionWithKeyText_Subscription

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -EncryptionKey <string>
 -EncryptionIV <string> -SubscriptionIds <string[]> [-ExemptionExpiresOnWarningDays <int>]
 [-ComplianceWarningPercentageThreshold <int>] [-CustomSecurityControlPath <string>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ImportEncryptionWithKeyText_ManagementGroup

```
New-AzplDocumentation -PageStyle <string> -BaseOutputPath <string> -Title <string>
 -WikiStyle <string> -DiscoveryDataImportFilePath <string> -EncryptionKey <string>
 -EncryptionIV <string> -childManagementGroupId <string> [-ExemptionExpiresOnWarningDays <int>]
 [-ComplianceWarningPercentageThreshold <int>] [-CustomSecurityControlPath <string>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Generate the basic or detailed documentation for the entire environment, a subset of subscriptions, or a sub-tree rooted at a child management group.
The basic documentation does not include the following: hidden tags for subscriptions, any metadata that starts with 'hidden-' or 'hidden_' for policy resources, Management group hierarchy mermaid diagram, management group summary, deprecated policy resources, unassigned policy resources, etc..

## EXAMPLES

### Example 1

PS C:\> New-AzplDocumentation -PageStyle 'detailed' -BaseOutputPath 'C:\AzPolicyLens\Wiki' -Title 'My Azure Policy Detailed Documentation' -WikiStyle 'github' -DiscoveryDataImportFilePath 'C:\AzPolicyLens\Wiki\Discovery.zip'

Generates the detailed GitHub Wiki documentation for the entire environment using the discovery data that was not encrypted.

### Example 2

PS C:\> $subscriptionIds = @('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002')
PS C:\> New-AzplDocumentation -PageStyle 'basic' -SubscriptionIds $subscriptionIds -BaseOutputPath 'C:\AzPolicyLens\Wiki' -Title 'My Azure Policy Basic Documentation' -WikiStyle 'github' -DiscoveryDataImportFilePath 'C:\AzPolicyLens\Wiki\Discovery.zip' -EncryptionKeyFilePath 'C:\AzPolicyLens\Wiki\EncryptionKey.json' -ComplianceWarningPercentageThreshold 90 -ExemptionExpiresOnWarningDays 15

Generates the basic GitHub Wiki documentation for the 2 subscriptions using the encryption key file and non-default thresholds for compliance warning and exemption expiration warning, saving the output files in the specified base output path.

### Example 3

PS C:\> New-AzplDocumentation -PageStyle 'basic' -BaseOutputPath 'C:\AzPolicyLens\Wiki' -Title 'My Azure Policy Basic Documentation' -WikiStyle 'github' -DiscoveryDataImportFilePath 'C:\AzPolicyLens\Wiki\Discovery.zip' -EncryptionKey 'MyEncryptionKey' -EncryptionIV 'MyEncryptionIV'

Generates the basic GitHub Wiki documentation for the entire environment using the existing encrypted discovery data, saving the output files in the specified base output path.
The discovery data is decrypted using the provided AES encryption key and IV.

### Example 4

PS C:\> New-AzplDocumentation -PageStyle 'detailed' -BaseOutputPath 'C:\AzPolicyLens\Wiki' -Title 'Platform MG Documentation' -WikiStyle 'ado' -DiscoveryDataImportFilePath 'C:\AzPolicyLens\Wiki\Discovery.zip' -childManagementGroupId 'mg-platform'

Generates the detailed Azure DevOps Wiki documentation scoped to the child management group `mg-platform` and all of its descendants, using unencrypted discovery data.

## PARAMETERS

### -BaseOutputPath

The output base directory.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -childManagementGroupId

The Id of a child management group to generate the documentation for. The documentation will include the specified management group and all of its descendants.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ImportNoEncryption_ManagementGroup
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyFile_ManagementGroup
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyText_ManagementGroup
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ComplianceWarningPercentageThreshold

The warning percentage threshold for policy compliance summary. Accepted range: 1 - 99.

```yaml
Type: System.Int32
DefaultValue: 80
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -CustomSecurityControlPath

The directory contains custom security control definitions.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -DiscoveryDataImportFilePath

File path for the Environment Data to import. Only `.zip` files produced by `Invoke-AzplEnvironmentDiscovery` are supported.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -EncryptionIV

AES Encryption Initialization Vector (IV) Content.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ImportEncryptionWithKeyText
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyText_Subscription
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyText_ManagementGroup
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -EncryptionKey

AES Encryption Key Content.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ImportEncryptionWithKeyText
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyText_Subscription
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyText_ManagementGroup
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -EncryptionKeyFilePath

AES Encryption key file path. This key is used to decrypt the existing environment discovery file.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ImportEncryptionWithKeyFile
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyFile_Subscription
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyFile_ManagementGroup
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ExemptionExpiresOnWarningDays

The warning days for the expiration of the policy exemption. Accepted range: 7 - 90.

```yaml
Type: System.Int32
DefaultValue: 30
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageStyle

The page style (detailed for engineers or basic for customers).

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues:
- detailed
- basic
HelpMessage: ''
```

### -SubscriptionIds

The subset of subscription Ids (GUID) to generate the documentation for.

```yaml
Type: System.String[]
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ImportNoEncryption_Subscription
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyFile_Subscription
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ImportEncryptionWithKeyText_Subscription
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Title

The title of the wiki.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WikiStyle

The wiki style. Supported values are "ado" and "github".

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues:
- ado
- github
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

File paths for the list of files generated by the cmdlet.

### System.String

Paths of the generated documentation files.

## NOTES

## RELATED LINKS

- [AzPolicyLens Wiki Page](https://github.com/taoyangcloud/AzPolicyLens/wiki)
