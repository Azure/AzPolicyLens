---
document type: cmdlet
external help file: AzPolicyLens.Discovery-help.xml
HelpUri: ''
Locale: en-AU
Module Name: AzPolicyLens.Discovery
ms.date: 02/09/2026
PlatyPS schema version: 2024-05-01
title: Invoke-AzplEnvironmentDiscovery
---

# Invoke-AzplEnvironmentDiscovery

## SYNOPSIS

Perform Azure environment discovery and collect required data for the Policy Documentation.

## SYNTAX

### EncryptionViaKeyText

```
Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName <string>
 -Token <string> -AdditionalBuiltInPolicyMetadataConfig <BuiltInSecurityControlConfig[]>
 -EncryptionKey <string> -EncryptionIV <string> [-OutputFileDirectory <string>]
 [-OutputFileBaseName <string>] [<CommonParameters>]
```

### EncryptionViaKeyFile

```
Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName <string>
 -Token <string> -AdditionalBuiltInPolicyMetadataConfig <BuiltInSecurityControlConfig[]>
 -EncryptionKeyFilePath <string> [-OutputFileDirectory <string>] [-OutputFileBaseName <string>]
 [<CommonParameters>]
```

### NoEncryption

```
Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName <string>
 -Token <string> -AdditionalBuiltInPolicyMetadataConfig <BuiltInSecurityControlConfig[]>
 [-OutputFileDirectory <string>] [-OutputFileBaseName <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Perform Azure environment discovery and collect required data for the Policy Documentation.
It get all relevant policy resources and management group hierarchy based on a management group scope.

## EXAMPLES

### Example 1 - Perform environment discovery and output file in plain text (no encryption). The file name is based on the Top-level Management Group name since it is not specified.

PS C:\> $token = ConvertFrom-SecureString (Get-AzAccessToken -ResourceUrl 'https://management.azure.com/').token -AsPlainText
PS C:\> Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName 'MyManagementGroup' -OutputFilePath 'C:\Temp\output.json' -Token $token

### Example 2 - Perform environment discovery and store the data in an output file encrypted.

PS C:\> $token = ConvertFrom-SecureString (Get-AzAccessToken -ResourceUrl 'https://management.azure.com/').token -AsPlainText
PS C:\> Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName 'MyManagementGroup' -OutputFileDirectory 'C:\Temp\' -OutputFileBaseName 'output' -EncryptionKeyFilePath 'C:\temp\EncryptionKey.json' -Token $token

### Example 3 - Perform environment discovery output  encrypted file using the AES encryption key and AES encryption Initialization Vector.

PS C:\> $token = ConvertFrom-SecureString (Get-AzAccessToken -ResourceUrl 'https://management.azure.com/').token -AsPlainText
PS C:\> Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName 'MyManagementGroup' -OutputFileDirectory 'C:\Temp' -OutputFileBaseName 'output' -compressOutputFile $true -EncryptionKey 'w7naanmxtd23OMRjIhC+5YXJL40xa5lVJ/5zdrD8q3Y=' -EncryptionIV 'jaX7ALmAWVid64K45tjUQQ==' -Token $token

### Example 4 - Perform environment discovery with additional built-in policy metadata defined and encrypted using the AES encryption key file.

PS C:\> $additionalBuiltInPolicyMetadataConfig = @()
PS C:\> $additionalBuiltInPolicyMetadataConfig += @{
  framework = 'ISO 27001:2013'
  policyMetadataNameRegex = '^ISO27001-2013_A'
}
PS C:\> $additionalBuiltInPolicyMetadataConfig += @{
  framework = 'Microsoft Cloud Security Benchmark V3.0'
  policyMetadataNameRegex = '^Azure_Security_Benchmark_v3\.0'
}
PS C:\> $token = ConvertFrom-SecureString (Get-AzAccessToken -ResourceUrl 'https://management.azure.com/').token -AsPlainText
PS C:\> Invoke-AzplEnvironmentDiscovery -TopLevelManagementGroupName 'MyManagementGroup' -OutputFileDirectory 'C:\Temp\' -OutputFileBaseName 'output' -EncryptionKeyFilePath 'C:\temp\EncryptionKey.json' -Token $token -AdditionalBuiltInPolicyMetadataConfig $additionalBuiltInPolicyMetadataConfig

Perform environment discovery and store the data in an output file 'C:\Temp\output.zip', with additional built-in policy metadata defined in the $additionalBuiltInPolicyMetadataConfig and encrypted using the AES encryption key file 'C:\temp\EncryptionKey.json'.

## PARAMETERS

### -AdditionalBuiltInPolicyMetadataConfig

Additional builtin Policy Metadata from security control frameworks to include.

```yaml
Type: AzPolicyLens.Discovery.Models.BuiltInSecurityControlConfig[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EncryptionViaKeyFile
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: EncryptionViaKeyText
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NoEncryption
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
- Name: EncryptionViaKeyText
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
- Name: EncryptionViaKeyText
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

AES Encryption key file path. If specified, the output file will be encrypted using this key.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EncryptionViaKeyFile
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OutputFileBaseName

Export file base name (without file extension)

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

### -OutputFileDirectory

Export file directory

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EncryptionViaKeyFile
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: EncryptionViaKeyText
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NoEncryption
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```


### -Token

The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EncryptionViaKeyFile
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: EncryptionViaKeyText
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NoEncryption
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TopLevelManagementGroupName

The Top-level Management Group name.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EncryptionViaKeyFile
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: EncryptionViaKeyText
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: NoEncryption
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### String

The Output file path.

## NOTES

## RELATED LINKS

- [AzPolicyLens Wiki Page](https://github.com/taoyangcloud/AzPolicyLens/wiki)
