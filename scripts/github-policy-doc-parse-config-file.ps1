<#
===================================================================================================================
AUTHOR: Tao Yang
DATE: 20/08/2025
NAME: github-policy-doc-parse-config-file.ps1
VERSION: 1.0.0
COMMENT: parse the policy documentation configuration file and output wiki information to GitHub Action variables.
===================================================================================================================
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

#region functions
function getGitHubRepoInfo {
  param (
    [string]$gitRepoUrl
  )

  # Supports both HTTPS (https://github.com/owner/repo[.git]) and SSH (git@github.com:owner/repo[.git]) formats
  if ($gitRepoUrl -match '^git@[^:]+:(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$') {
    $owner = $Matches['owner']
    $repo = $Matches['repo']
  } elseif ($gitRepoUrl -match '^(https?|ssh)://[^/]+/(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?/?$') {
    $owner = $Matches['owner']
    $repo = $Matches['repo']
  } else {
    Throw "Unsupported git repository URL format: $gitRepoUrl"
  }
  return @{
    owner = $owner
    repo  = $repo
  }
}

#Convert GitHub repository URL between HTTPS and SSH formats
function convertGitHubRepoUrl {
  param (
    [string]$gitRepoUrl,

    [ValidateSet('https', 'ssh')]
    [string]$targetFormat
  )

  if ($targetFormat -eq 'https') {
    # Already in HTTPS format, return as-is
    if ($gitRepoUrl -match '^(https?)://[^/]+/(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?/?$') {
      return $gitRepoUrl
    }
    if ($gitRepoUrl -match '^git@[^:]+:(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$') {
      $owner = $Matches['owner']
      $repo = $Matches['repo']
      return "https://github.com/$owner/$repo.git"
    }
  } elseif ($targetFormat -eq 'ssh') {
    # Already in SSH format, return as-is
    if ($gitRepoUrl -match '^git@[^:]+:(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?$') {
      return $gitRepoUrl
    }
    if ($gitRepoUrl -match '^(https?|ssh)://[^/]+/(?<owner>[^/]+)/(?<repo>[^/]+?)(\.git)?/?$') {
      $owner = $Matches['owner']
      $repo = $Matches['repo']
      return "git@github.com:$owner/$repo.git"
    }
  }
  Throw "Unsupported git repository URL format: $gitRepoUrl"
}

#endregion

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

$wikis = @()
$config = Get-Content $configFilePath | ConvertFrom-Json -AsHashtable -Depth 10
$environmentConfig = $config.environment[$environment]
foreach ($key in $environmentConfig.wiki.keys) {
  #$repoInfo = getGitHubRepoInfo -gitRepoUrl $environmentConfig.wiki[$key].gitRepository
  $repoHttpsUrl = convertGitHubRepoUrl -gitRepoUrl $environmentConfig.wiki[$key].gitRepository -targetFormat 'https'
  $repoSshUrl = convertGitHubRepoUrl -gitRepoUrl $environmentConfig.wiki[$key].gitRepository -targetFormat 'ssh'
  $wikiConfig = @{
    wikiAlias        = $key
    pageStyle        = $environmentConfig.wiki[$key].pageStyle
    title            = $environmentConfig.wiki[$key].title
    gitRepository    = $repoHttpsUrl
    gitSshRepository = $repoSshUrl
    gitBranch        = $environmentConfig.wiki[$key].gitBranch
    gitUserName      = $environmentConfig.wiki[$key].gitUserName
    gitUserEmail     = $environmentConfig.wiki[$key].gitUserEmail
    #gitRepoOwner     = $repoInfo.owner
    #gitRepoName      = $repoInfo.repo
  }
  if ($environmentConfig.wiki[$key].ContainsKey('childManagementGroupId')) {
    $wikiConfig.childManagementGroupId = $environmentConfig.wiki[$key].childManagementGroupId
  } else {
    $wikiConfig.childManagementGroupId = ''
  }
  if ($environmentConfig.wiki[$key].ContainsKey('subscriptionIds')) {
    $wikiConfig.subscriptionIds = $environmentConfig.wiki[$key].subscriptionIds -join ','
  } else {
    $wikiConfig.subscriptionIds = ''
  }
  if ($environmentConfig.wiki[$key].ContainsKey('deployKeySecretName')) {
    $wikiConfig.deployKeySecretName = $environmentConfig.wiki[$key].deployKeySecretName
  } else {
    $wikiConfig.deployKeySecretName = ''
  }
  $wikis += $wikiConfig
}

$wikiCount = $wikis.count
# Ensure wikis is always output as a JSON array
if ($wikiCount -eq 0) {
  $wikis_json = '[]'
} elseif ($wikiCount -eq 1) {
  $wikis_json = '[' + ($wikis | ConvertTo-Json -depth 5 -Compress) + ']'
} else {
  $wikis_json = $wikis | ConvertTo-Json -depth 5 -Compress
}

#Create pipeline output variables
$wikiCountOutput = '{0}={1}' -f 'wikiCount', $wikiCount
$wikisOutput = '{0}={1}' -f 'wikis', $wikis_json
#$wikiCountOutput | Out-File -FilePath $env:GITHUB_OUTPUT -Append
echo $wikiCountOutput >> $env:GITHUB_OUTPUT
Write-Verbose $wikiCountOutput -Verbose
#$wikisOutput | Out-File -FilePath $env:GITHUB_OUTPUT -Append
echo $wikisOutput >> $env:GITHUB_OUTPUT
Write-Verbose $wikisOutput -Verbose
#endregion
