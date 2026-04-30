---
document type: cmdlet
external help file: AzPolicyLens.Discovery-help.xml
HelpUri: ''
Locale: en-AU
Module Name: AzPolicyLens.Discovery
ms.date: 02/09/2026
PlatyPS schema version: 2024-05-01
title: New-AzplEncryptionKey
---

# New-AzplEncryptionKey

## SYNOPSIS

Create AES encryption key and Initialization Vector for encrypting the environment discovery file for the Azure Policy Documentation.

## SYNTAX

### __AllParameterSets

```
New-AzplEncryptionKey -OutputDir <string> [-FileName <string>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Create AES encryption key and Initialization Vector for encrypting the environment discovery file for the Azure Policy Documentation.

## EXAMPLES

### Example 1 - Create an encryption key file in the directory 'C:\Temp' with the default file name 'AzplEncryptionKey.json'.

PS C:\> New-AzplEncryptionKey -OutputDir 'C:\Temp'

### Example 2 - Create an encryption key file in the directory 'C:\Temp' with the file name 'MyEncryptionKey.json'.

PS C:\> New-AzplEncryptionKey -OutputDir 'C:\Temp' -FileName 'MyEncryptionKey.json'

## PARAMETERS

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

### -FileName

The file name for the encryption key.

```yaml
Type: System.String
DefaultValue: None
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

### -OutputDir

The directory path for the encryption key.

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

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

The AES Encryption key content.

### AzPolicyLens.Discovery.Models.EncryptionKey

The AES Encryption key object.

## NOTES

## RELATED LINKS

- [AzPolicyLens Wiki Page](https://github.com/taoyangcloud/AzPolicyLens/wiki)
