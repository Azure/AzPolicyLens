<#
===========================================================================================================================
AUTHOR: Tao Yang
DATE: 04/06/2025
NAME: ado-policy-doc-parse-config-file.ps1
VERSION: 1.0.0
COMMENT: parse the policy documentation configuration file and output wiki information to Azure DevOps pipeline variables.
===========================================================================================================================
#>
[CmdletBinding()]
param (
  [parameter(Mandatory = $true)]
  [ValidateScript({ Test-Path $_ -PathType 'leaf' })]
  [string]$configFilePath,

  [parameter(Mandatory = $true)]
  [ValidateScript({ Test-Path $_ -PathType 'leaf' })]
  [string]$configSchemaFilePath,

  [parameter(Mandatory = $true)]
  [string]$environment
)

#region main
#Schema validation
try {
  $configContent = Get-Content $configFilePath -Raw
  $schemaContent = Get-Content $configSchemaFilePath -Raw
  $validSchema = Test-Json -Json $configContent -Schema $schemaContent
} catch {
  Throw $_.Exception.Message
  Exit 1
}
if ($validSchema -eq $true) {
  Write-Output "Configuration file schema validation passed."
} else {
  Write-Error "Configuration file schema validation failed. Please check the error messages above."
  Exit 1
}

$wikis = [Ordered]@{}
$config = Get-Content $configFilePath | ConvertFrom-Json -AsHashtable -Depth 10
$environmentConfig = $config.environment[$environment]
foreach ($key in $environmentConfig.wiki.keys) {
  $wikiConfig = @{
    matrixWikiAlias     = $key
    matrixPageStyle     = $environmentConfig.wiki[$key].pageStyle
    matrixTitle         = $environmentConfig.wiki[$key].title
    matrixGitRepository = $environmentConfig.wiki[$key].gitRepository
    matrixGitBranch     = $environmentConfig.wiki[$key].gitBranch
    matrixGitUserName   = $environmentConfig.wiki[$key].gitUserName
    matrixGitUserEmail  = $environmentConfig.wiki[$key].gitUserEmail
    matrixGitRepoPath   = $environmentConfig.wiki[$key].gitRepoPath
  }
  if ($environmentConfig.wiki[$key].ContainsKey('childManagementGroupId')) {
    $wikiConfig.matrixChildManagementGroupId = $environmentConfig.wiki[$key].childManagementGroupId
  } else {
    $wikiConfig.matrixChildManagementGroupId = ''
  }
  if ($environmentConfig.wiki[$key].ContainsKey('subscriptionIds')) {
    $wikiConfig.matrixSubscriptionIds = $environmentConfig.wiki[$key].subscriptionIds -join ','
  } else {
    $wikiConfig.matrixSubscriptionIds = ''
  }
  $wikis[$key] = $wikiConfig
}

$wikiCount = $wikis.keys.count

#Create pipeline output variables
Write-Output ('##vso[task.setVariable variable={0};isOutput=true]{1}' -f 'WikiCount', $wikiCount)
#Output Hashtable to ADO Pipeline as a Variable.
Write-Output ('##vso[task.setVariable variable={0};isOutput=true]{1}' -f 'Wiki', ($wikis | ConvertTo-Json -Compress))
#endregion
