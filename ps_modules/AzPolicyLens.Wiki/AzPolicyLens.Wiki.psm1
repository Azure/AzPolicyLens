using module ./AzPolicyLens.Wiki.Azure.Helper.psm1
using module ./AzPolicyLens.Wiki.Encryption.Helper.psm1
using module ./AzPolicyLens.Wiki.Generic.Helper.psm1
using module ./AzPolicyLens.Wiki.Markdown.Helper.psm1
using module ./AzPolicyLens.Wiki.Pages.Helper.psm1
using module ./AzPolicyLens.Wiki.Platform.Helper.psm1
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1

#region function to import previously exported environment details
Function Import-AzplEnvironmentDiscovery {
  [CmdletBinding()]
  [OutputType([System.Collections.Specialized.OrderedDictionary])]
  param (
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'File path for the Environment Data to import')]
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'File path for the Environment Data to import')]
    [parameter(Mandatory = $true, ParameterSetName = 'NoEncryption', HelpMessage = 'File path for the Environment Data to import')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
    [string]$FilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'AES Encryption key file path. Use the same key to decrypt the file if it is encrypted.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKeyFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'AES Encryption Key Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKey,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionIV
  )
  #Discovery Data File names
  $hierarchyFileName = 'managementGroupHierarchy.json'
  $policyAssignmentFileName = 'policyAssignments.json'
  $policyInitiativeFileName = 'policyInitiatives.json'
  $policyDefinitionFileName = 'policyDefinitions.json'
  $policyExemptionFileName = 'policyExemptions.json'
  $policyMetadataFileName = 'policyMetadata.json'
  $complianceDataFileName = 'complianceData.json'

  $objFile = Get-Item $FilePath
  if ($objFile.Extension -ieq '.zip') {
    Write-Verbose "[$(getCurrentUTCString)]: Expanding the ZIP archive '$($objFile.FullName)'."
    Expand-Archive -Path $objFile.FullName -DestinationPath (Split-Path -Path $objFile.FullName -Parent) -Force
    $hierarchyFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $hierarchyFileName)
    $policyAssignmentFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyAssignmentFileName)
    $policyInitiativeFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyInitiativeFileName)
    $policyDefinitionFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyDefinitionFileName)
    $policyExemptionFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyExemptionFileName)
    $policyMetadataFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $policyMetadataFileName)
    $complianceDataFileFullPath = (Join-Path -Path (Split-Path -Path $objFile.FullName -Parent) -ChildPath $complianceDataFileName)
    $removeExtractedFile = $true
  } else {
    Throw "Unsupported file format '$($objFile.Extension)'. Only .zip files are supported for environment details import."
  }

  try {
    if ($($PSCmdlet.ParameterSetName) -eq 'EncryptionViaKeyFile') {
      Write-Verbose "[$(getCurrentUTCString)]: Decrypting the environment details using the encryption key file '$EncryptionKeyFilePath'." -Verbose
      $hierarchyDetails = decryptStuff -InputFilePath $hierarchyFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyAssignmentDetails = decryptStuff -InputFilePath $policyAssignmentFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyInitiativeDetails = decryptStuff -InputFilePath $policyInitiativeFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyDefinitionDetails = decryptStuff -InputFilePath $policyDefinitionFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyExemptionDetails = decryptStuff -InputFilePath $policyExemptionFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $policyMetadataDetails = decryptStuff -InputFilePath $policyMetadataFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100
      $complianceDataDetails = decryptStuff -InputFilePath $complianceDataFileFullPath -KeyFilePath $EncryptionKeyFilePath | ConvertFrom-Json -depth 100

    } elseif ($($PSCmdlet.ParameterSetName) -ieq 'EncryptionViaKeyText') {
      Write-Verbose "[$(getCurrentUTCString)]: Decrypting the environment details using the encryption key and IV text." -Verbose
      $hierarchyDetails = decryptStuff -InputFilePath $hierarchyFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyAssignmentDetails = decryptStuff -InputFilePath $policyAssignmentFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyInitiativeDetails = decryptStuff -InputFilePath $policyInitiativeFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyDefinitionDetails = decryptStuff -InputFilePath $policyDefinitionFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyExemptionDetails = decryptStuff -InputFilePath $policyExemptionFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $policyMetadataDetails = decryptStuff -InputFilePath $policyMetadataFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
      $complianceDataDetails = decryptStuff -InputFilePath $complianceDataFileFullPath -AESKey $EncryptionKey -AESIV $EncryptionIV | ConvertFrom-Json -depth 100
    } else {
      Write-Verbose "[$(getCurrentUTCString)]: Importing the environment details from the file '$FilePath' as plain-text." -Verbose
      $hierarchyDetails = Get-Content $hierarchyFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyAssignmentDetails = Get-Content $policyAssignmentFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyInitiativeDetails = Get-Content $policyInitiativeFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyDefinitionDetails = Get-Content $policyDefinitionFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyExemptionDetails = Get-Content $policyExemptionFileFullPath -Raw | ConvertFrom-Json -depth 100
      $policyMetadataDetails = Get-Content $policyMetadataFileFullPath -Raw | ConvertFrom-Json -depth 100
      $complianceDataDetails = Get-Content $complianceDataFileFullPath -Raw | ConvertFrom-Json -depth 100
    }

    # Extract the data from the output
    $hierarchyData = $hierarchyDetails
    $policyAssignmentData = $policyAssignmentDetails
    $policyInitiativeData = $policyInitiativeDetails
    $policyDefinitionData = $policyDefinitionDetails
    $policyExemptionData = $policyExemptionDetails
    $policyMetadataData = $policyMetadataDetails
    $complianceData = $complianceDataDetails

    Write-Verbose "[$(getCurrentUTCString)]: Environment Discovery Data Import." -verbose
    $AzplEnvironmentDetails = [ordered]@{
      timeStamp                                     = $hierarchyData.timeStamp
      topLevelManagementGroupName                   = $hierarchyData.topLevelManagementGroupName
      managementGroups                              = $hierarchyData.managementGroups
      subscriptions                                 = $hierarchyData.subscriptions
      assignments                                   = $policyAssignmentData.assignments
      initiatives                                   = $policyInitiativeData.initiatives
      definitions                                   = $policyDefinitionData.definitions
      exemptions                                    = $policyExemptionData.exemptions
      policyMetadata                                = $policyMetadataData.policyMetadata
      builtInDefinitionInUnAssignedCustomInitiative = $policyDefinitionData.builtInDefinitionInUnAssignedCustomInitiative
      assignmentCompliance                          = $complianceData.assignmentCompliance
      subscriptionComplianceSummary                 = $complianceData.subscriptionComplianceSummary
      complianceSummaryByPolicyDefinitionGroup      = $complianceData.complianceSummaryByPolicyDefinitionGroup
      additionalBuiltInPolicyMetadataConfig         = $policyMetadataData.additionalBuiltInPolicyMetadataConfig
      roleAssignments                               = $policyAssignmentData.roleAssignments
      roleDefinitions                               = $policyAssignmentData.roleDefinitions
    }


    Write-Verbose "[$(getCurrentUTCString)]: Imported environment details summary:" -Verbose
    Write-Verbose "  - Time Stamp (UTC): $($AzplEnvironmentDetails.timeStamp)" -Verbose
    Write-Verbose "  - Top Level Management Group Name: $($AzplEnvironmentDetails.topLevelManagementGroupName)" -Verbose
    Write-Verbose "  - Management Groups Count: $($AzplEnvironmentDetails.managementGroups.Count)" -Verbose
    Write-Verbose "  - Subscriptions Count: $($AzplEnvironmentDetails.subscriptions.Count)" -Verbose
    Write-Verbose "  - Assignments Count: $($AzplEnvironmentDetails.assignments.Count)" -Verbose
    Write-Verbose "  - Initiatives Count: $($AzplEnvironmentDetails.initiatives.Count)" -Verbose
    Write-Verbose "  - Definitions Count: $($AzplEnvironmentDetails.definitions.Count)" -Verbose
    Write-Verbose "  - Exemptions Count: $($AzplEnvironmentDetails.exemptions.Count)" -Verbose
    Write-Verbose "  - Policy Metadata Count: $($AzplEnvironmentDetails.policyMetadata.Count)" -Verbose
    Write-Verbose "  - Built-in Definition in Unassigned Custom Initiative Count: $($AzplEnvironmentDetails.builtInDefinitionInUnAssignedCustomInitiative.Count)" -Verbose
    Write-Verbose "  - Role Assignments Count: $($AzplEnvironmentDetails.roleAssignments.Count)" -Verbose
    Write-Verbose "  - Role Definitions Count: $($AzplEnvironmentDetails.roleDefinitions.Count)" -Verbose

  } catch {
    $ExceptionDetails = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($ExceptionDetails)
    $ExceptionResponse = $reader.ReadToEnd();
    Write-Error $ExceptionResponse
    Write-Error $_.ErrorDetails
    throw $_.Exception
    $AzplEnvironmentDetails = [ordered]@{}
  }
  if ($removeExtractedFile) {
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($hierarchyFileFullPath)'." -Verbose
    Remove-Item -Path $hierarchyFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyAssignmentFileFullPath)'." -Verbose
    Remove-Item -Path $policyAssignmentFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyInitiativeFileFullPath)'." -Verbose
    Remove-Item -Path $policyInitiativeFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyDefinitionFileFullPath)'." -Verbose
    Remove-Item -Path $policyDefinitionFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyExemptionFileFullPath)'." -Verbose
    Remove-Item -Path $policyExemptionFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($policyMetadataFileFullPath)'." -Verbose
    Remove-Item -Path $policyMetadataFileFullPath -Force
    Write-Verbose "[$(getCurrentUTCString)]: Removing the extracted file '$($complianceDataFileFullPath)'." -Verbose
    Remove-Item -Path $complianceDataFileFullPath -Force
  }

  $AzplEnvironmentDetails
}
#endregion

#region function to generate either basic or detailed documentation for the entire environment or a subset of subscriptions
Function New-AzplDocumentation {
  [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ImportNoEncryption')]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportNoEncryption_Subscription', HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_Subscription', HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_Subscription', HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [ValidateScript({ $_ -match '(?im)^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' })]
    [string[]]$SubscriptionIds,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportNoEncryption_ManagementGroup', HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_ManagementGroup', HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_ManagementGroup', HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [ValidateNotNullOrEmpty()]
    [string]$childManagementGroupId,

    [parameter(Mandatory = $true, HelpMessage = 'The output base directory.')]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$BaseOutputPath,

    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle,

    [parameter(Mandatory = $false, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
    [ValidateRange(7, 90)]
    [int]$ExemptionExpiresOnWarningDays = 30,

    [parameter(Mandatory = $false, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold = 80,

    [parameter(Mandatory = $false, HelpMessage = 'The directory contains custom security control definitions.')]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$CustomSecurityControlPath,

    [parameter(Mandatory = $true, HelpMessage = 'File path for the Environment Data to import')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
    [string]$DiscoveryDataImportFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile', HelpMessage = 'AES Encryption key file path. This key is used to encrypt the new discovery json export file or decrypt the existing environment discovery file.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_Subscription', HelpMessage = 'AES Encryption key file path. This key is used to encrypt the new discovery json export file or decrypt the existing environment discovery file.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyFile_ManagementGroup', HelpMessage = 'AES Encryption key file path. This key is used to encrypt the new discovery json export file or decrypt the existing environment discovery file.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKeyFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText', HelpMessage = 'AES Encryption Key Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_Subscription', HelpMessage = 'AES Encryption Key Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_ManagementGroup', HelpMessage = 'AES Encryption Key Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKey,

    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_Subscription', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [parameter(Mandatory = $true, ParameterSetName = 'ImportEncryptionWithKeyText_ManagementGroup', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionIV
  )

  Write-Verbose "Environment Data will be imported from '$DiscoveryDataImportFilePath'."
  $importParams = @{
    FilePath = $DiscoveryDataImportFilePath
  }
  if ($PSCmdlet.ParameterSetName -ilike 'ImportEncryptionWithKeyFile*') {
    $importParams.Add('EncryptionKeyFilePath', $EncryptionKeyFilePath)
  } elseif ($PSCmdlet.ParameterSetName -ilike 'ImportEncryptionWithKeyText*') {
    $importParams.Add('EncryptionKey', $EncryptionKey)
    $importParams.Add('EncryptionIV', $EncryptionIV)
  }
  $AzplEnvironmentDetails = Import-AzplEnvironmentDiscovery @importParams

  #Make sure all policy resources are retrieved previously in a script scoped variable $AzplEnvironmentDetails
  if (!$AzplEnvironmentDetails) {
    Throw "[$(getCurrentUTCString)]: No environment discovery data found."
    Exit 1
  }
  #create script scoped variables for Policy Definition and initiative syntax validation failures
  $global:failedSyntaxValidationDefinitions = @()
  $global:failedSyntaxValidationInitiatives = @()

  if ($subscriptionIds.count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: subscription Ids are provided. Filtering documentation for the specified subscriptions only." -Verbose
    $EnvironmentDiscoveryData = filterDiscoveryData -SubscriptionIds $subscriptionIds -environmentDetails $AzplEnvironmentDetails
  } elseif ($childManagementGroupId.length -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Child management group ID is provided. Filtering documentation for the specified child management group and its descendants." -Verbose
    $EnvironmentDiscoveryData = filterDiscoveryData -ChildManagementGroupId $childManagementGroupId -environmentDetails $AzplEnvironmentDetails
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No subscription Ids or child management group ID provided. Generating documentation for all subscriptions in the environment." -Verbose
    $EnvironmentDiscoveryData = $AzplEnvironmentDetails
  }


  # generate wiki page file names
  $wikiFileMapping = newWikiPageMapping -discoveryData $EnvironmentDiscoveryData -BaseOutputPath $BaseOutputPath -WikiStyle $WikiStyle -Title $Title -PageStyle $PageStyle -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  #Delete existing wiki content (so there are no orphaned pages for resources no longer exist)
  Write-Verbose "[$(getCurrentUTCString)]: Deleting existing wiki content in '$BaseOutputPath'." -Verbose
  removeExistingWikiFiles -WikiDirectory $BaseOutputPath -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  $detailedPagesCommonParams = @{
    WikiFileMapping          = $wikiFileMapping
    EnvironmentDiscoveryData = $EnvironmentDiscoveryData
    PageStyle                = $PageStyle
    Verbose                  = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #Get unique policy categories from assigned initiatives
  $uniqueAssignedPolicyInitiativeCategories = getUniqueCategoriesFromAssignedInitiatives -EnvironmentDiscoveryData $EnvironmentDiscoveryData

  #Generate Markdown page for custom security controls
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    #Get list of custom security control files
    $CustomSecurityControlFileSchemaFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'AzPolicyLens.Wiki.Custom.Security.Control.schema.json'
    $CustomSecurityControlFileConfig = getCustomSecurityControlFileConfig -FilePath $CustomSecurityControlPath -schemaFilePath $CustomSecurityControlFileSchemaFilePath
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the custom security controls defined in '$CustomSecurityControlPath'." -Verbose
    $customSecurityControlPages = newCustomSecurityControlPage @detailedPagesCommonParams -CustomSecurityControlFileConfig $CustomSecurityControlFileConfig -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold
  }

  #Generate Markdown pages for built-in security controls
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.policyMetadata.count) built-in security controls (policy metadata) that have been discovered." -Verbose
  $policyMetadataPages = newPolicyMetadataPage -WikiFileMapping $wikiFileMapping -EnvironmentDiscoveryData $EnvironmentDiscoveryData -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  #Generate Markdown pages for policy definitions
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.definitions.count) policy definitions that have been discovered." -Verbose
  $definitionPages = newPolicyDefinitionPage @detailedPagesCommonParams

  #Generate Markdown pages for policy initiatives
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.initiatives.count) policy initiatives that have been discovered." -Verbose
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $initiativePages = newPolicyInitiativePage @detailedPagesCommonParams -CustomSecurityControlFileConfig $CustomSecurityControlFileConfig
  } else {
    $initiativePages = newPolicyInitiativePage @detailedPagesCommonParams
  }

  #Generate Markdown pages for policy assignments
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.assignments.count) policy assignments that have been discovered." -Verbose
  $assignmentPages = newPolicyAssignmentPage @detailedPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  if ($EnvironmentDiscoveryData.exemptions.Count -gt 0) {
    #Generate Markdown pages for policy exemptions
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.exemptions.count) policy exemptions that have been discovered." -Verbose
    $exemptionPages = newPolicyExemptionPage @detailedPagesCommonParams -ExpiresOnWarningDays $ExemptionExpiresOnWarningDays
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No policy exemptions found in the environment. Skipping individual exemption page generation."
    $exemptionPages = @()
  }

  #Generate Markdown pages for subscriptions
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($EnvironmentDiscoveryData.subscriptions.count) subscriptions that have been discovered." -Verbose
  $subscriptionPages = newSubscriptionPage @detailedPagesCommonParams -ExemptionExpiresOnWarningDays $ExemptionExpiresOnWarningDays -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  #Generate Markdown pages for policy categories
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Markdown files for the $($uniqueAssignedPolicyInitiativeCategories.count) unique policy categories from assigned initiatives." -Verbose
  $policyCategoryPageParams = @{
    WikiFileMapping                          = $wikiFileMapping
    EnvironmentDiscoveryData                 = $EnvironmentDiscoveryData
    uniqueAssignedPolicyInitiativeCategories = $uniqueAssignedPolicyInitiativeCategories
    ComplianceWarningPercentageThreshold     = $ComplianceWarningPercentageThreshold
    Verbose                                  = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $policyCategoryPageParams.Add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
  }
  $policyCategoryPages = newPolicyCategoryPage @policyCategoryPageParams

  $summaryPagesCommonParams = @{
    wikiFileMapping          = $wikiFileMapping
    EnvironmentDiscoveryData = $EnvironmentDiscoveryData
    Title                    = $Title
    PageStyle                = $PageStyle
    Verbose                  = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  #Generate detailed main summary Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating main $PageStyle summary Markdown file." -Verbose
  if ($SubscriptionIds.count -gt 0) {
    $mainSummaryPage = newMainSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories -SubscriptionIds $SubscriptionIds
  } elseif ($null -ne $childManagementGroupId) {
    $mainSummaryPage = newMainSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories -ChildManagementGroupId $childManagementGroupId
  } else {
    $mainSummaryPage = newMainSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories
  }

  #Generate assignment summary Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Assignment summary Markdown file." -Verbose
  $assignmentSummaryPage = newAssignmentSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  #Generate assignment initiative Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Initiative summary Markdown file." -Verbose
  $initiativeSummaryPage = newInitiativeSummaryPage @summaryPagesCommonParams

  #Generate assignment definition Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Definition summary Markdown file." -Verbose
  $definitionSummaryPage = newDefinitionSummaryPage @summaryPagesCommonParams

  if ($PageStyle -ieq 'detailed') {
    #Generate security control summary Markdown page
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Security Control summary Markdown file." -Verbose
    if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
      $securityControlSummaryPage = newSecurityControlSummaryPage @summaryPagesCommonParams -CustomSecurityControlFileConfig $CustomSecurityControlFileConfig
    } else {
      $securityControlSummaryPage = newSecurityControlSummaryPage @summaryPagesCommonParams
    }
  }

  #Generate policy category summary Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Category summary Markdown file." -Verbose
  $policyCategorySummaryPage = newPolicyCategorySummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -uniqueAssignedPolicyInitiativeCategories $uniqueAssignedPolicyInitiativeCategories

  #Generate subscription Markdown page
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Subscription summary Markdown file." -Verbose
  $subscriptionSummaryPage = newSubscriptionSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold

  #Generate analysis Markdown page
  #This page must be generated after the policy definition and initiative detailed pages because it needs the summary data for definition and initiative syntax validation results.
  Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Analysis summary Markdown file." -Verbose
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlPath')) {
    $analysisSummaryPage = newAnalysisSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold -CustomSecurityControlFileConfig $CustomSecurityControlFileConfig
  } else {
    $analysisSummaryPage = newAnalysisSummaryPage @summaryPagesCommonParams -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold
  }

  if ($EnvironmentDiscoveryData.exemptions.Count -gt 0) {
    #Generate exemption Markdown page
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating Policy Exemption summary Markdown file." -Verbose
    $exemptionSummaryPage = newExemptionSummaryPage @summaryPagesCommonParams -ExpiresOnWarningDays $ExemptionExpiresOnWarningDays
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No policy exemptions found in the environment. Skipping exemption summary page generation."
    $exemptionSummaryPage = @()
  }

  if ($WikiStyle -ieq 'github') {
    #Generate GitHub wiki sidebar
    Write-Verbose "[$(getCurrentUTCString)]: Start Generating GitHub wiki sidebar and footer Markdown files." -Verbose
    $githubSidebarParams = @{
      WikiFileMapping                 = $wikiFileMapping
      Title                           = $Title
      EnvironmentDiscoveryData        = $EnvironmentDiscoveryData
      CustomSecurityControlFileConfig = $customSecurityControlPages
      PageStyle                       = $PageStyle
      Verbose                         = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
    $sidebarFilePath = newGitHubWikiSidebar @githubSidebarParams
    $footerFilePath = newGitHubWikiFooter -WikiFileMapping $wikiFileMapping -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Skipping GitHub wiki sidebar generation as WikiStyle is not 'github'." -Verbose
  }

  #Tidy up - Remove global variables
  Remove-Variable -Name failedSyntaxValidationDefinitions -Scope Global -ErrorAction SilentlyContinue
  Remove-Variable -Name failedSyntaxValidationInitiatives -Scope Global -ErrorAction SilentlyContinue

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for main summary page are generated."
  foreach ($p in $mainSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy assignment summary page are generated."
  foreach ($p in $assignmentSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy initiative summary page are generated."
  foreach ($p in $initiativeSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy definition summary page are generated."
  foreach ($p in $definitionSummaryPage) {
    Write-Output "  - $p"
  }

  if ($PageStyle -ieq 'detailed') {
    Write-Output "[$(getCurrentUTCString)]: The following Markdown files for security control summary page are generated."
    foreach ($p in $securityControlSummaryPage) {
      Write-Output "  - $p"
    }
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy category summary page are generated."
  foreach ($p in $policyCategorySummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy exemption summary page are generated."
  foreach ($p in $exemptionSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy subscription summary page are generated."
  foreach ($p in $subscriptionSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for policy analysis summary page are generated."
  foreach ($p in $analysisSummaryPage) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Subscriptions are generated."
  foreach ($p in $subscriptionPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Assignments are generated."
  foreach ($p in $assignmentPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Initiatives are generated."
  foreach ($p in $initiativePages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Definitions are generated."
  foreach ($p in $definitionPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Exemptions are generated."
  foreach ($p in $exemptionPages) {
    Write-Output "  - $p"
  }

  Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Metadata are generated."
  foreach ($p in $policyMetadataPages) {
    Write-Output "  - $p"
  }

  if ($customSecurityControlPages) {
    Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Custom Security Controls are generated."
    foreach ($p in $customSecurityControlPages) {
      Write-Output "  - $p"
    }
  }

  if ($policyCategoryPages) {
    Write-Output "[$(getCurrentUTCString)]: The following Markdown files for Policy Categories are generated."
    foreach ($p in $policyCategoryPages) {
      Write-Output "  - $p"
    }
  }

  if ($WikiStyle -ieq 'github') {
    Write-Output "[$(getCurrentUTCString)]: The GitHub wiki sidebar and footer files have been successfully generated."
    Write-Output "  - $sidebarFilePath"
    Write-Output "  - $footerFilePath"
  }

  Write-Output "[$(getCurrentUTCString)]: The Policy documentation have been successfully generated for Management Group '$($AzplEnvironmentDetails.topLevelManagementGroupName)'."
}
#endregion
