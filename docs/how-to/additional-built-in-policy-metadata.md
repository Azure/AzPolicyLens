# Define Additional Built-In Policy Metadata

## Why Defining Additional Built-In Policy Metadata

By default, when generating the policy wiki, only the built-in metadata that are defined in the policy initiatives are included in the discovery artifact.

For example, if your organization is using a particular security framework (i.e. ISO 27001:2013), and you have mapped totally 10 controls from that framework to the built-in policies, only those 10 controls will be included in the discovery artifact.

You will definitely want to have the complete catalog for all the controls from the ISO 27001:2013 framework included and documented in the wiki. This gives your security teams and cloud engineering teams a more comprehensive reference for the security controls - What has been implemented and what is missing.

To build the complete catalog for this security framework (i.e. ISO 27001:2013) in the `Security Controls` page, you need to specify the additional built-in policy metadata configurations when generating the policy wiki.

By doing this, your security teams and cloud engineering teams can easily reference the complete set of security controls from the desired security frameworks in the generated policy wiki, making it easier to access and understand the security requirements.

## How to Define Additional Built-In Policy Metadata

The `additional built-in policy metadata configuration` is defined as an array of hashtables, where each hashtable contains the following properties:

```powershell
@{
    framework = '<name of the security framework>'
    policyMetadataNameRegex = '<regular expression to match the policy metadata names>'
}
```

For example, to include all the built-in policy metadata that belong to the `ISO 27001:2013` framework, you can define the additional built-in policy metadata configuration as follows:

```powershell
@{
    framework = 'ISO 27001:2013'
    policyMetadataNameRegex = '^ISO27001-2013_A' # name starts with 'ISO27001-2013_A'
  }
```

to map the `Microsoft Cloud Security Benchmark V3.0` built-in policy metadata, you can define the additional built-in policy metadata configuration as follows:

```powershell
@{
    framework = 'Microsoft Cloud Security Benchmark V3.0'
    policyMetadataNameRegex = '^Azure_Security_Benchmark_v3\.0' # name starts with 'Azure_Security_Benchmark_v3.0'
  }
```

By specifying the name of the framework and regular expression to match the security controls (build-in policy metadata names), the policy wiki generation process will include all the matched built-in policy metadata in the discovery artifact, allowing you to build a complete catalog for the specified security frameworks in the `Security Controls` page of the generated policy wiki.

To build the regular expression for matching the built-in policy metadata names, you will firstly find all the built-in policy metadata names for the desired security framework. You can do this by following these steps:

1. Export all the built-in policy metadata to a CSV file using the PowerShell cmdlet `Get-AzPolicyMetadata` as shown below:

```powershell
get-azpolicyMetadata | Export-Csv .\policy_metadata.csv
```

2. Open the exported CSV file as a spreadsheet, locate the rows of interest by the name column,

3. Build the regular expression based on the common patterns of the names of the built-in policy metadata. a good online Regular Expression tester such as [regex101](https://regex101.com/) can be helpful for building and testing the regular expressions.

4. Test the regular expression using PowerShell `-match` operator to ensure it matches the desired built-in policy metadata names. Make sure the regular expression works as expected. For example, to test the regular expression for matching the `ISO 27001:2013` built-in policy metadata names, you can run the following command:

```powershell
Get-AzPolicyMetadata | Where-Object { $_.Name -match '^ISO27001-2013_A' }
```
