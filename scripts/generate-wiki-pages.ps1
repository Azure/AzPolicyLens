using module ../ps_modules/AzPolicyLens.Wiki/AzPolicyLens.Wiki.psd1
<#
=================================================================================================================
AUTHOR: Tao Yang
DATE: 14/01/2026
NAME: generate-wiki-pages.ps1
VERSION: 2.0.0
COMMENT: Generate ADO or GitHub Wiki pages for Azure Policy documentation based on environment discovery results.
=================================================================================================================
#>
[CmdletBinding()]
[OutputType([hashtable])]
param (
  [parameter(Mandatory = $true, HelpMessage = 'Json discovery data file path')]
  [ValidateScript({ Test-Path $_ -PathType 'leaf' })]
  [string]$DiscoveryFilePath,

  [parameter(Mandatory = $true, HelpMessage = 'Base Output Path')]
  [ValidateScript({ Test-Path $_ -PathType 'Container' })]
  [string]$BaseOutputPath,

  [parameter(Mandatory = $true, HelpMessage = 'Wiki alias')]
  [ValidateNotNullOrEmpty()]
  [string]$wikiAlias,

  [parameter(Mandatory = $true, HelpMessage = 'Page Style')]
  [ValidateSet("detailed", "basic")]
  [string]$pageStyle,

  [parameter(Mandatory = $true, HelpMessage = 'Git Platform')]
  [ValidateSet("ado", "github")]
  [string]$gitPlatform,

  [parameter(Mandatory = $true, HelpMessage = 'Git branch to push the wiki pages to.')]
  [ValidateNotNullOrEmpty()]
  [string]$gitBranch,

  [parameter(Mandatory = $false, HelpMessage = 'Path within the git repository where the wiki pages will be stored. Only Required for Azure DevOps Wiki.')]
  [ValidateNotNullOrEmpty()]
  [string]$gitRepoPath = "docs",

  [parameter(Mandatory = $false, HelpMessage = 'Git commit message.')]
  [string]$gitCommitMessage = '',

  [parameter(Mandatory = $false, HelpMessage = 'Subscription ID to filter the discovery data.')]
  [string]$SubscriptionIds,

  [parameter(Mandatory = $false, HelpMessage = 'Child management group ID to filter the discovery data.')]
  [string]$childManagementGroupId,

  [parameter(Mandatory = $true, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
  [ValidateRange(7, 90)]
  [int]$ExemptionExpiresOnWarningDays,

  [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
  [ValidateRange(1, 99)]
  [int]$ComplianceWarningPercentageThreshold,

  [parameter(Mandatory = $false, HelpMessage = 'The directory contains custom security control definitions.')]
  [ValidateScript({ Test-Path $_ -PathType 'Container' })]
  [string]$CustomSecurityControlPath,

  [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
  [ValidateNotNullOrEmpty()]
  [string]$Title
)

#region main
if ($gitPlatform -eq 'ado') {
  Write-Verbose "Git platform is set to 'ado'." -Verbose
  $gitToken = $env:SYSTEM_ACCESSTOKEN
  $tokenType = "bearer"
} else {
  Write-Verbose "Git platform is set to 'github'." -Verbose
  $githubToken = $env:githubToken
  $githubUserID = $env:githubUserID
  $tokenType = "basic"
  $gitTokenBytes = [System.Text.Encoding]::Unicode.GetBytes("$githubUserID`:$githubToken")
  $gitToken = [Convert]::ToBase64String($gitTokenBytes)
}

$EncryptionKey = $env:EncryptionKey
$EncryptionIV = $env:EncryptionIV
$gitRepository = $env:gitRepository
$gitUserName = $env:gitUserName
$gitUserEmail = $env:gitUserEmail
Write-Output "Starting the wiki page generation script."
Write-Output "The following parameters were provided:"
Write-Output "  - DiscoveryFilePath: $DiscoveryFilePath"
Write-Output "  - BaseOutputPath: $BaseOutputPath"
Write-Output "  - wikiAlias: $wikiAlias"
Write-Output "  - gitRepository: $gitRepository"
Write-Output "  - gitBranch: $gitBranch"
if ($gitPlatform -eq 'ado') {
  Write-Output "  - gitRepoPath: $gitRepoPath"
}
Write-Output "  - GitHub User ID: $githubUserID"
if ($SubscriptionIds) {
  Write-Output "  - SubscriptionIds: $SubscriptionIds"
} else {
  Write-Output "  - SubscriptionIds: None"
}
if ($childManagementGroupId) {
  Write-Output "  - childManagementGroupId: $childManagementGroupId"
} else {
  Write-Output "  - childManagementGroupId not specified."
}
Write-Output "  - Title: $Title"
Write-Output "  - EncryptionKey: $($EncryptionKey -replace '.', '*')"
Write-Output "  - EncryptionIV: $($EncryptionIV -replace '.', '*')"
if ($gitCommitMessage) {
  Write-Output "  - gitCommitMessage: $gitCommitMessage"
} else {
  $strNow = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $gitCommitMessage = "Update wiki pages with latest Azure Policy documentation - '$strNow'"
  Write-Output "  - gitCommitMessage: $gitCommitMessage"
}
#Construct the path where the wiki pages will be created.
$OutputPath = Join-Path -Path $BaseOutputPath -ChildPath $wikiAlias

#Ensure the output path exists.
if (-not (Test-Path -Path $OutputPath -PathType 'Container')) {
  Write-Verbose "Creating output path '$OutputPath'." -Verbose
  New-Item -Path $OutputPath -ItemType Directory | Out-Null
} else {
  Write-Verbose "The output path '$OutputPath' already exists." -Verbose
}


#clone the git repository if provided
$gitRepoRootPath = Join-Path -Path $OutputPath -ChildPath 'repo'
if (-not (Test-Path -Path $gitRepoRootPath -PathType 'Container')) {
  if ($gitPlatform -ieq 'ado') {
    Write-Output "Cloning the Git repo using http.extraheader for authentication with $tokenType token."
    git -c http.extraheader="AUTHORIZATION: $tokenType $gitToken" clone $gitRepository $gitRepoRootPath --branch $gitBranch --single-branch
  } else {
    Write-Output "Cloning the Git repo using embedded credentials in URL for authentication."
    $authenticatedRepoUrl = $gitRepository -replace 'https://', "https://$githubUserID`:$githubToken@"
    git clone $authenticatedRepoUrl $gitRepoRootPath --branch $gitBranch --single-branch
  }
  if ($gitPlatform -ieq 'ado') {
    #make sure the child path $gitRepoPath exists
    $gitRepoFullPath = Join-Path -Path $gitRepoRootPath -ChildPath $gitRepoPath
    if (-not (Test-Path -Path $gitRepoFullPath -PathType 'Container')) {
      Write-Verbose "Creating the documentation sub directory '$gitRepoFullPath'." -Verbose
      New-Item -Path $gitRepoFullPath -ItemType Directory -Force | Out-Null
    } else {
      Write-Verbose "The the documentation sub directory '$gitRepoFullPath' already exists." -Verbose
    }
  } else {
    #Github wiki does not support sub directories. It has to use a flat structure where all files are stored in the root of the wiki repository.
    $gitRepoFullPath = $gitRepoRootPath
  }
} else {
  Throw "The documentation sub directory '$gitRepoPath' already exists."
  exit 1
}
#get the discovery data
$param = @{
  Title                                = $Title
  DiscoveryDataImportFilePath          = $DiscoveryFilePath
  BaseOutputPath                       = $gitRepoFullPath
  PageStyle                            = $pageStyle
  EncryptionKey                        = $EncryptionKey
  EncryptionIV                         = $EncryptionIV
  ExemptionExpiresOnWarningDays        = $ExemptionExpiresOnWarningDays
  ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
  WikiStyle                            = $gitPlatform
}
Write-Verbose "The discovery data file path is '$($DiscoveryFilePath)'." -Verbose
Write-Verbose "The output path is '$($OutputPath)'." -Verbose
Write-Verbose "The wiki title is '$($Title)'." -Verbose

if ($SubscriptionIds.length -gt 0) {
  $arrSubscriptionIds = $SubscriptionIds.split(',')
  $param.add('SubscriptionIds', $arrSubscriptionIds)
  Write-Output "Creating $pageStyle style wiki pages for subscriptions '$SubscriptionIds'."
} elseif ($childManagementGroupId.length -gt 0) {
  $param.add('childManagementGroupId', $childManagementGroupId)
  Write-Output "Creating $pageStyle style wiki pages for child management group '$childManagementGroupId'."
} else {
  Write-Verbose "No SubscriptionIds or childManagementGroupId provided. The wiki pages will be generated based on the entire discovery data without filtering." -Verbose
  Write-Output "Creating $pageStyle style wiki pages for all subscriptions."
}

if ($CustomSecurityControlPath.length -gt 0) {
  $param.add('CustomSecurityControlPath', $CustomSecurityControlPath)
  Write-Verbose "Custom security control path provided: '$CustomSecurityControlPath'." -Verbose
}
Write-Verbose "Generating wiki pages with the following parameters:" -Verbose
foreach ($key in $param.Keys) {
  if ($key -in @('EncryptionKey', 'EncryptionIV')) {
    Write-Verbose "  - $key`: $($param[$key] -replace '.', '*')" -Verbose
  } else {
    Write-Verbose "  - $key`: $($param[$key])" -Verbose
  }
}
New-AzplDocumentation @param

#Push the changes to the git repository
Write-Verbose "Preparing to push changes to the git repository." -Verbose
#set the current location to the git repository root path
Write-Output "Setting current location to git repository root path '$gitRepoRootPath'."
Set-Location -Path $gitRepoRootPath
Write-Output "Files and folders contained in the '$gitRepoRootPath':"
Get-ChildItem $gitRepoRootPath -force | format-table Mode, LastWriteTIme, Length, Name
$gitStatus = git status --porcelain
if ($gitStatus) {
  Write-Verbose "Changes detected in the git repository. Preparing to commit and push." -Verbose
  Write-Verbose "Configure git user name using command 'git config user.name `"$gitUserName`"" -Verbose
  git config user.name "$gitUserName"

  Write-Verbose "Configure git user email using command 'git config user.email `"$gitUserEmail`"" -Verbose
  git config user.email "$gitUserEmail"

  Write-Verbose "Configure git rebase" -Verbose
  git config pull.rebase false

  Write-Verbose "Adding changes to git staging area." -Verbose
  git add .
  git commit -m "$gitCommitMessage"
  if ($gitPlatform -eq 'ado') {
    Write-Output "Pushing changes to the $gitBranch branch of the repository '$gitRepository' using http.extraheader for authentication with $tokenType token."
    git -c http.extraheader="AUTHORIZATION: bearer $gitToken" push origin $gitBranch --porcelain
  } else {
    Write-Output "Pushing changes to the $gitBranch branch of the repository '$gitRepository' using embedded credentials in URL for authentication."
    git push origin $gitBranch --porcelain
  }

  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push to the $gitBranch branch of the repository '$gitRepository'."
    exit 1
  }
} else {
  Write-Verbose "No changes detected in the git repository. No commit or push needed." -Verbose
}

#endregion
