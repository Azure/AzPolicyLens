using module ./AzPolicyLens.Discovery.helper.psm1
using module ./AzPolicyLens.Discovery.type.psm1
#function to create AES encryption key and IV for encrypting the environment discovery file
Function New-AzplEncryptionKey {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([System.Object])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The directory path for the encryption key.')]
    [ValidateScript({ Test-Path -path $_ -PathType 'Container' })]
    [string]$OutputDir,

    [parameter(Mandatory = $false, HelpMessage = 'The file name for the encryption key.')]
    [ValidateNotNullOrEmpty()]
    [string]$FileName = 'AzplEncryptionKey.json'
  )
  #Create Key File
  $KeyFilePath = Join-Path -Path $OutputDir -ChildPath $FileName
  if ($PSCmdlet.ShouldProcess($KeyFilePath)) {
    $key = newAesKey -KeySize 256 -OutputFilePath $KeyFilePath
  }
  $key
}

#function to get all relevant policy resources and management group hierarchy based on a management group scope
Function Invoke-AzplEnvironmentDiscovery {
  [CmdletBinding()]
  [OutputType([String])]
  param (
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'The Top-level Management Group name.')]
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'The Top-level Management Group name.')]
    [parameter(Mandatory = $true, ParameterSetName = 'NoEncryption', HelpMessage = 'The Top-level Management Group name.')]
    [ValidateNotNullOrEmpty()]
    [string]$TopLevelManagementGroupName,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [parameter(Mandatory = $true, ParameterSetName = 'NoEncryption', HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'Additional builtin Policy Metadata from security control frameworks to include.')]
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'Additional builtin Policy Metadata from security control frameworks to include.')]
    [parameter(Mandatory = $true, ParameterSetName = 'NoEncryption', HelpMessage = 'Additional builtin Policy Metadata from security control frameworks to include.')]
    [BuiltInSecurityControlConfig[]]$AdditionalBuiltInPolicyMetadataConfig,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'Export file directory')]
    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'Export file directory')]
    [parameter(Mandatory = $true, ParameterSetName = 'NoEncryption', HelpMessage = 'Export file directory')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Container' })]
    [string]$OutputFileDirectory,

    [parameter(Mandatory = $false, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'Export file base name (without file extension)')]
    [parameter(Mandatory = $false, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'Export file base name (without file extension)')]
    [parameter(Mandatory = $false, ParameterSetName = 'NoEncryption', HelpMessage = 'Export file base name (without file extension)')]
    [ValidateNotNullOrEmpty()]
    [string]$OutputFileBaseName = $TopLevelManagementGroupName,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyFile', HelpMessage = 'AES Encryption key file path. If specified, the output file will be encrypted using this key.')]
    [ValidateScript({ Test-Path -Path $_ -PathType 'Leaf' })]
    [string]$EncryptionKeyFilePath,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'AES Encryption Key Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionKey,

    [parameter(Mandatory = $true, ParameterSetName = 'EncryptionViaKeyText', HelpMessage = 'AES Encryption Initialization Vector (IV) Content.')]
    [ValidateNotNullOrEmpty()]
    [string]$EncryptionIV
  )
  #Define file names
  $hierarchyFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'managementGroupHierarchy.json'
  $policyAssignmentFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'policyAssignments.json'
  $policyInitiativeFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'policyInitiatives.json'
  $policyDefinitionFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'policyDefinitions.json'
  $policyExemptionFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'policyExemptions.json'
  $policyMetadataFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'policyMetadata.json'
  $complianceDataFilePath = Join-Path -Path $OutputFileDirectory -ChildPath 'complianceData.json'

  #Get policy resources
  $utcNow = (Get-Date).ToUniversalTime()
  $allPolicyResourcesParams = @{
    ManagementGroupName = $TopLevelManagementGroupName
    Token               = $Token
  }
  if ($PSBoundParameters.ContainsKey('AdditionalBuiltInPolicyMetadataConfig')) {
    $allPolicyResourcesParams.add('additionalBuiltInPolicyMetadataConfig', $AdditionalBuiltInPolicyMetadataConfig)
  }
  Write-Verbose "[$(getCurrentUTCString)]: Retrieving all relevant policy resources under the management group '$TopLevelManagementGroupName'." -verbose
  $PolicyResources = getAllPolicyResources @allPolicyResourcesParams
  Write-Verbose "[$(getCurrentUTCString)]: Found $($PolicyResources.assignments.Count) policy assignments in the management group hierarchy." -verbose
  Write-Verbose "[$(getCurrentUTCString)]: Found $($PolicyResources.initiatives.Count) policy initiatives in the management group hierarchy." -verbose
  Write-Verbose "[$(getCurrentUTCString)]: Found $($PolicyResources.definitions.Count) policy definitions in the management group hierarchy." -verbose
  Write-Verbose "[$(getCurrentUTCString)]: Found $($PolicyResources.exemptions.Count) policy exemptions in the management group hierarchy." -verbose
  Write-Verbose "[$(getCurrentUTCString)]: Found $($PolicyResources.policyMetadata.Count) built-in in-used policy metadata in the management group hierarchy." -verbose
  Write-Verbose "[$(getCurrentUTCString)]: Found $($PolicyResources.builtInDefinitionInUnAssignedCustomInitiative.Count) built-in policy definitions used in unassigned custom policy initiatives in the management group hierarchy." -verbose
  #get all managed identities for the policy assignments
  Write-Verbose "[$(getCurrentUTCString)]: Retrieving managed identities used in the policy assignments."
  $assignmentManagedIdentities = getPolicyAssignmentManagedIdentityPrincipalIds -assignments $PolicyResources.assignments

  #get all principal Ids for all the policy initiatives
  $assignmentManagedIdentityPrincipalIds = @()
  foreach ($item in $assignmentManagedIdentities) {
    #add system assigned managed identity principal Id
    if ($item.systemAssignedPrincipalId) {
      $assignmentManagedIdentityPrincipalIds += $item.systemAssignedPrincipalId
    }
    #add user assigned managed identity principal Id
    if ($item.userAssignedIdentities) {
      foreach ($userAssignedIdentity in $item.userAssignedIdentities) {
        if ($userAssignedIdentity.principalId) {
          $assignmentManagedIdentityPrincipalIds += $userAssignedIdentity.principalId
        }
      }
    }
  }

  $assignmentManagedIdentityPrincipalIds = $assignmentManagedIdentityPrincipalIds | Sort-Object -Unique
  if ($assignmentManagedIdentityPrincipalIds.Count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Found $($assignmentManagedIdentityPrincipalIds.Count) unique managed identity principal Ids used in the policy assignments." -Verbose

    #Get role assignments for the managed identities
    $roleAssignments = getRoleAssignments -principalIds $assignmentManagedIdentityPrincipalIds -token $Token
    if ($roleAssignments.Count -gt 0) {
      Write-Verbose "[$(getCurrentUTCString)]: Found $($roleAssignments.Count) role assignments for the managed identities used in the policy assignments." -Verbose

      #get Role definitions used in the role assignments
      $roleDefinitionIds = $roleAssignments.roleDefinitionId | Sort-Object -Unique
      Write-Verbose "[$(getCurrentUTCString)]: Found $($roleDefinitionIds.Count) unique role definition IDs used in the role assignments. Getting details of these Role Definitions.."
      $roleDefinitions = getRoleDefinitions -resourceIds $roleDefinitionIds -token $Token
      if ($roleDefinitions.Count -eq 0) {
        Write-Warning "[$(getCurrentUTCString)]: No role definitions found for the role assignments. Make sure you have required permission to perform this Azure resource graph search on the tenant scope."
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: Found $($roleDefinitions.Count) role definitions used in the role assignments." -Verbose
      }
    } else {
      Write-Warning "[$(getCurrentUTCString)]: No role assignments found for the managed identities used in the policy assignments. Make sure you have required permission to perform this Azure resource graph search on the tenant scope."
    }
  } else {
    Write-Warning "[$(getCurrentUTCString)]: No managed identities found in the policy assignments."
  }


  #Get management group hierarchy
  $managementGroups = getManagementGroupHierarchy -ManagementGroupName $TopLevelManagementGroupName -token $Token
  if ($managementGroups.Count -eq 0) {
    Write-Warning "[$(getCurrentUTCString)]: No management group hierarchy found for '$TopLevelManagementGroupName'"
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Found $($managementGroups.Count) management groups in the hierarchy."
  }
  #Get subscriptions under the top-level management group
  $subscriptions = getSubscriptionsUnderManagementGroup -ManagementGroupName $TopLevelManagementGroupName -token $Token
  if ($subscriptions.Count -eq 0) {
    Write-Warning "[$(getCurrentUTCString)]: No subscriptions found for '$TopLevelManagementGroupName'"
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Found $($subscriptions.Count) subscriptions in the hierarchy."
  }

  #Create ordered hashtables for output
  $hierarchyDetails = [ordered]@{
    timeStamp                   = $utcNow.tostring('yyyy-MM-ddTHH:mmZ')
    topLevelManagementGroupName = $TopLevelManagementGroupName
    managementGroups            = $managementGroups
    subscriptions               = $subscriptions
  }
  $policyAssignmentDetails = [ordered]@{
    assignments     = $PolicyResources.assignments
    roleAssignments = $roleAssignments
    roleDefinitions = $roleDefinitions
  }
  $policyInitiativeDetails = [ordered]@{
    initiatives = $PolicyResources.initiatives
  }
  $policyDefinitionDetails = [ordered]@{
    definitions                                   = $PolicyResources.definitions
    builtInDefinitionInUnAssignedCustomInitiative = $PolicyResources.builtInDefinitionInUnAssignedCustomInitiative
  }
  $policyExemptionDetails = [ordered]@{
    exemptions = $PolicyResources.exemptions
  }
  $policyMetadataDetails = [ordered]@{
    policyMetadata                        = $PolicyResources.policyMetadata
    additionalBuiltInPolicyMetadataConfig = $AdditionalBuiltInPolicyMetadataConfig
  }
  $complianceDataDetails = [ordered]@{
    assignmentCompliance                     = $PolicyResources.assignmentCompliance
    subscriptionComplianceSummary            = $PolicyResources.subscriptionComplianceSummary
    complianceSummaryByPolicyDefinitionGroup = $PolicyResources.complianceSummaryByPolicyDefinitionGroup
  }

  #Encrypt files if required
  if ($($PsCmdlet.ParameterSetName) -eq 'EncryptionViaKeyFile') {
    Write-Verbose "[$(getCurrentUTCString)]: Encrypting the environment details using the encryption key file '$EncryptionKeyFilePath'." -Verbose
    $hierarchyOutput = encryptStuff -InputText ($hierarchyDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
    $assignmentOutput = encryptStuff -InputText ($policyAssignmentDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
    $initiativeOutput = encryptStuff -InputText ($policyInitiativeDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
    $definitionOutput = encryptStuff -InputText ($policyDefinitionDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
    $exemptionOutput = encryptStuff -InputText ($policyExemptionDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
    $metadataOutput = encryptStuff -InputText ($policyMetadataDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
    $complianceOutput = encryptStuff -InputText ($complianceDataDetails | ConvertTo-Json -depth 100) -KeyFilePath $EncryptionKeyFilePath
  } elseif ($($PsCmdlet.ParameterSetName) -eq 'EncryptionViaKeyText') {
    Write-Verbose "[$(getCurrentUTCString)]: Encrypting the environment details using the encryption key and IV." -Verbose
    $hierarchyOutput = encryptStuff -InputText ($hierarchyDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
    $assignmentOutput = encryptStuff -InputText ($policyAssignmentDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
    $initiativeOutput = encryptStuff -InputText ($policyInitiativeDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
    $definitionOutput = encryptStuff -InputText ($policyDefinitionDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
    $exemptionOutput = encryptStuff -InputText ($policyExemptionDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
    $metadataOutput = encryptStuff -InputText ($policyMetadataDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
    $complianceOutput = encryptStuff -InputText ($complianceDataDetails | ConvertTo-Json -depth 100) -AESKey $EncryptionKey -AESIV $EncryptionIV
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Exporting the environment details as plain text." -Verbose
    $hierarchyOutput = $hierarchyDetails | ConvertTo-Json -depth 100
    $assignmentOutput = $policyAssignmentDetails | ConvertTo-Json -depth 100
    $initiativeOutput = $policyInitiativeDetails | ConvertTo-Json -depth 100
    $definitionOutput = $policyDefinitionDetails | ConvertTo-Json -depth 100
    $exemptionOutput = $policyExemptionDetails | ConvertTo-Json -depth 100
    $metadataOutput = $policyMetadataDetails | ConvertTo-Json -depth 100
    $complianceOutput = $complianceDataDetails | ConvertTo-Json -depth 100
  }
  #Create output files
  $hierarchyOutput | Out-File $hierarchyFilePath
  $assignmentOutput | Out-File $policyAssignmentFilePath
  $initiativeOutput | Out-File $policyInitiativeFilePath
  $definitionOutput | Out-File $policyDefinitionFilePath
  $exemptionOutput | Out-File $policyExemptionFilePath
  $metadataOutput | Out-File $policyMetadataFilePath
  $complianceOutput | Out-File $complianceDataFilePath

  #Zip the output files
  $compressedFilePath = Join-Path $OutputFileDirectory -ChildPath ($OutputFileBaseName + '.zip')
  $includedFiles = @(
    $hierarchyFilePath
    $policyAssignmentFilePath
    $policyInitiativeFilePath
    $policyDefinitionFilePath
    $policyExemptionFilePath
    $policyMetadataFilePath
    $complianceDataFilePath
  )
  Write-Verbose "[$(getCurrentUTCString)]: Compressing the output files to  '$compressedFilePath'." -Verbose
  Compress-Archive -Path $includedFiles -DestinationPath $compressedFilePath -Force
  #Delete the uncompressed file
  Foreach ($file in $includedFiles) {
    Remove-Item -Path $file -Force
  }

  $compressedFilePath
}
