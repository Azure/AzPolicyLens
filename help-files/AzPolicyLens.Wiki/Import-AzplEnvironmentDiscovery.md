---
document type: cmdlet
external help file: AzPolicyLens.Wiki-help.xml
HelpUri: ''
Locale: en-AU
Module Name: AzPolicyLens.Wiki
ms.date: 01/21/2026
PlatyPS schema version: 2024-05-01
title: Import-AzplEnvironmentDiscovery
---

# Import-AzplEnvironmentDiscovery

## SYNOPSIS

Import existing environment details previously exported using the `Invoke-AzplEnvironmentDiscovery` function from the `AzPolicyLens.Discovery` module.

## SYNTAX

### EncryptionViaKeyText

```
Import-AzplEnvironmentDiscovery -FilePath <string> -EncryptionKey <string> -EncryptionIV <string> [<CommonParameters>]
```

### EncryptionViaKeyFile

```
Import-AzplEnvironmentDiscovery -FilePath <string> -EncryptionKeyFilePath <string> [<CommonParameters>]
```

### NoEncryption

```
Import-AzplEnvironmentDiscovery -FilePath <string> [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Import existing environment details previously exported using the `Invoke-AzplEnvironmentDiscovery` function from the `AzPolicyLens.Discovery` module.

## EXAMPLES

### Example 1

PS C:\> Import-AzplEnvironmentDiscovery -FilePath 'C:\Temp\output.zip'

Import environment details from the unencrypted discovery data from file `C:\Temp\output.zip`.

### Example 2

PS C:\> Import-AzplEnvironmentDiscovery -FilePath 'C:\Temp\output.zip' -EncryptionKeyFilePath 'C:\Temp\AzplEncryptionKey.json'

Import environment details from the encrypted discovery data from file `C:\Temp\output.zip` using the encryption key stored in `C:\Temp\AzplEncryptionKey.json`.

### Example 3

PS C:\> Import-AzplEnvironmentDiscovery -FilePath 'C:\Temp\output.zip' -EncryptionKey 'your-encryption-key' -EncryptionIV 'your-encryption-iv'

Import environment details from the encrypted discovery data from file `C:\Temp\output.zip` using the content of the AES encryption key and Initialization Vector.

## PARAMETERS

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

AES Encryption key file path. Use the same key to decrypt the file if it is encrypted.

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

### -FilePath

File path for the Environment Data to import

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

### System.Collections.Specialized.OrderedDictionary

Imported environment discovery data.

## NOTES

## RELATED LINKS

- [AzPolicyLens Wiki Page](https://github.com/taoyangcloud/AzPolicyLens/wiki)
