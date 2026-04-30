# Managing Pipeline and Workflow Variable File

The pipeline configuration file [settings.yml](../../settings.yml) is a YAML file that defines the variables for the policy documentation pipelines.

These variables must be configured in the file before running the pipelines.

## Variables

| Name | Description | Default Value |
| :--- | :---------- | :------------ |
| `policyDocAdditionalBuiltInPolicyMetadataConfigFilePath` | The file path to the additional built-in policy metadata configuration file. | `configurations/additional-policy-metadata-config.jsonc` |
| `policyDocCustomSecurityControlPath` | The folder path containing custom security control catalog files. | `security-controls` |
| `policyDocGitHubDomainName` | The GitHub domain name (e.g., `github.com` or GitHub Enterprise domain). | `github.com` |
| `policyDocExemptionExpiresOnWarningDays` | The number of days before policy exemption expiration to trigger a warning. | `30` |
| `policyDocComplianceWarningPercentageThreshold` | The compliance percentage threshold below which a warning is displayed. | `80` |
| `policyDocDiscoveryFileName` | The file name for the environment discovery artifact (ZIP file). | `environment-discovery.zip` |
