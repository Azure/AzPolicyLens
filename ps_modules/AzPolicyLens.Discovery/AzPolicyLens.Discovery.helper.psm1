<#
==========================================================================================
AUTHOR: Tao Yang
DATE: 06/06/2024
NAME: AzPolicyLens.Discovery.utilities.psm1
VERSION: 1.0.0
COMMENT: this nested module contains the helper functions for AzPolicyLens.Discovery module
==========================================================================================
#>

#function to get the current UTC time
function getCurrentUTCString {
  "$([DateTime]::UtcNow.ToString('u')) UTC"
}


#function to generate AES key and IV
function newAesKey {
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory = $false)]
    [ValidateSet(128, 192, 256)]
    [int]$KeySize = 256,

    [Parameter(Mandatory = $false)]
    [string]$OutputFilePath
  )

  try {
    Write-Verbose "[$(getCurrentUTCString)]: Generating AES-$KeySize key and IV"

    # Create AES instance
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = $KeySize
    $aes.GenerateKey()
    $aes.GenerateIV()

    # Create key object
    $keyObject = [PSCustomObject]@{
      Key     = [Convert]::ToBase64String($aes.Key)
      IV      = [Convert]::ToBase64String($aes.IV)
      KeySize = $KeySize
      Created = (Get-Date).ToUniversalTime().ToString('o')
    }

    # Save to file if path specified
    if ($OutputFilePath) {
      $keyJson = $keyObject | ConvertTo-Json
      [System.IO.File]::WriteAllText($OutputFilePath, $keyJson, [System.Text.Encoding]::UTF8)
      Write-Verbose "[$(getCurrentUTCString)]: AES key saved to: $OutputFilePath"
    }

    # Dispose of AES instance
    $aes.Dispose()

    return $keyObject
  } catch {
    Write-Error "[$(getCurrentUTCString)]: Failed to generate AES key: $_"
    throw
  }
}

#function to encrypt file or text using AES
function encryptStuff {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyFile')]
    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyDirect')]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$InputFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyFile')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyDirect')]
    [ValidateNotNullOrEmpty()]
    [string]$InputText,

    [Parameter(Mandatory = $false)]
    [string]$OutputFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyFile')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyFile')]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$KeyFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyDirect')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyDirect')]
    [string]$AESKey,

    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyDirect')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyDirect')]
    [string]$AESIV,

    [Parameter(Mandatory = $false)]
    [switch]$UseCompression
  )

  try {
    Write-Verbose "[$(getCurrentUTCString)]: Starting AES encryption"
    $startTime = [datetime]::UtcNow

    # Load key and IV
    if ($PSCmdlet.ParameterSetName -eq 'FileInKeyFile' -or $PSCmdlet.ParameterSetName -eq 'TextInKeyFile') {
      $KeyFullPath = (Resolve-Path -Path $KeyFilePath).path
      Write-Verbose "[$(getCurrentUTCString)]: Loading key from file: $KeyFullPath"
      $keyJson = [System.IO.File]::ReadAllText($KeyFullPath)
      $keyObject = $keyJson | ConvertFrom-Json
      $keyBytes = [Convert]::FromBase64String($keyObject.Key)
      $ivBytes = [Convert]::FromBase64String($keyObject.IV)
    } else {
      $keyBytes = [Convert]::FromBase64String($AESKey)
      $ivBytes = [Convert]::FromBase64String($AESIV)
    }

    # Read input data
    if ($InputFilePath) {
      $inputFileFullPath = (Resolve-Path -Path $InputFilePath).path
      Write-Verbose "[$(getCurrentUTCString)]: Reading input file: $inputFileFullPath"
      $inputBytes = [System.IO.File]::ReadAllBytes($inputFileFullPath)
    } else {
      $inputBytes = [System.Text.Encoding]::UTF8.GetBytes($InputText)
    }

    Write-Verbose "[$(getCurrentUTCString)]: Input size: $($inputBytes.Length) bytes"

    # Compress if requested
    if ($UseCompression) {
      Write-Verbose "[$(getCurrentUTCString)]: Compressing data"
      $memoryStream = New-Object System.IO.MemoryStream
      $gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Compress)
      $gzipStream.Write($inputBytes, 0, $inputBytes.Length)
      $gzipStream.Close()
      $inputBytes = $memoryStream.ToArray()
      $memoryStream.Dispose()
      Write-Verbose "[$(getCurrentUTCString)]: Compressed size: $($inputBytes.Length) bytes"
    }

    # Create AES instance
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $keyBytes
    $aes.IV = $ivBytes
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    # Create encryptor
    $encryptor = $aes.CreateEncryptor()

    # Encrypt data
    Write-Verbose "[$(getCurrentUTCString)]: Encrypting data"
    $encryptedBytes = $encryptor.TransformFinalBlock($inputBytes, 0, $inputBytes.Length)

    # Create output object with metadata
    $outputObject = [PSCustomObject]@{
      Algorithm     = "AES-$($aes.KeySize)"
      Compressed    = $UseCompression.IsPresent
      OriginalSize  = if ($InputFilePath) { (Get-Item $InputFilePath).Length } else { $InputText.Length }
      EncryptedData = [Convert]::ToBase64String($encryptedBytes)
      EncryptedAt   = (Get-Date).ToUniversalTime().ToString('o')
    }
    $outputJson = $outputObject | ConvertTo-Json
    # Cleanup
    $encryptor.Dispose()
    $aes.Dispose()

    $endTime = [datetime]::UtcNow
    $timeTaken = New-TimeSpan -Start $startTime -End $endTime
    Write-Verbose "[$(getCurrentUTCString)]: AES encryption completed in $($timeTaken.TotalSeconds) seconds"

    if ($OutputFilePath) {
      # Save to file
      [System.IO.File]::WriteAllText($OutputFilePath, $outputJson, [System.Text.Encoding]::UTF8)
      Write-Verbose "[$(getCurrentUTCString)]: Encrypted file saved to: $OutputFilePath"
      return $OutputFilePath
    } else {
      # Return JSON string
      return $outputJson
    }
  } catch {
    Write-Error "[$(getCurrentUTCString)]: AES encryption failed: $_"
    throw
  } finally {
    if ($aes) { $aes.Dispose() }
    if ($encryptor) { $encryptor.Dispose() }
  }
}

#function to convert a PSCustomObject to an ordered hashtable
function ConvertToOrderedHashtable {
  [CmdletBinding()]
  [OutputType([System.Collections.Specialized.OrderedDictionary])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [PSCustomObject]$InputObject
  )
  process {
    $ordered = [ordered]@{}

    # Get all properties and add them to the ordered hashtable
    $InputObject.PSObject.Properties | ForEach-Object {
      $ordered[$_.Name] = $_.Value
    }

    return $ordered
  }
}

#function to query Azure resource graph using the rest API
function invokeARGQueryREST {
  [CmdletBinding()]
  [OutputType([system.object[]])]
  param (
    [parameter(Mandatory = $true)]
    [string]$query,

    [parameter(Mandatory = $false)]
    [string[]]$scope,

    [parameter(Mandatory = $true)]
    [ValidateSet('tenant', 'subscription', 'managementGroup')]
    [string]$scopeType,

    [parameter(Mandatory = $false)]
    [ValidateRange(1, 1000)]
    [int]$top = 1000,

    [parameter(Mandatory = $false)]
    [int]$skip = 0,

    [parameter(Mandatory = $true)]
    [string]$token,

    [parameter(Mandatory = $false)]
    [ValidateRange(30, 600)]
    [int]$timeoutSeconds = 300,

    [parameter(Mandatory = $false)]
    [ValidateRange(1, 5)]
    [int]$maxRetries = 3,

    [parameter(Mandatory = $false)]
    [bool]$enablePagination = $true
  )

  # Build the request URI
  $uri = 'https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2024-04-01'

  # Build request headers
  $headers = @{
    'Authorization' = "Bearer $token"
    'Content-Type'  = 'application/json'
  }

  # Initialize collections for all results
  $allResults = @()
  $totalCount = 0
  $skipToken = $null
  $currentSkip = $skip
  $pageNumber = 1

  do {
    # Build request body
    $body = @{
      query   = $query
      options = @{
      }
    }
    #only set the $top and $skip option if pagination is disabled
    if (!$enablePagination) {
      $body.options.'$top' = $top
      $body.options.'$skip' = $currentSkip
    }
    # Add skip token if present (for pagination)
    if ($skipToken) {
      $body.options.'$skipToken' = $skipToken
    }

    # Add subscriptions if provided
    if ($scopeType -ieq 'subscription' -and $scope -and $scope.Count -gt 0) {
      $body.subscriptions = $scope
    } elseif ($scopeType -ieq 'managementGroup' -and $scope -and $scope.Count -gt 0) {
      # If scope is management group, convert to management group names
      $body.managementGroups = $scope
    }

    $jsonBody = $body | ConvertTo-Json -Depth 10
    Write-Verbose "[$(getCurrentUTCString)]: Querying Azure Resource Graph via REST API (Page $pageNumber)"
    Write-Verbose "[$(getCurrentUTCString)]: Query: $query"
    Write-Verbose "[$(getCurrentUTCString)]: Request URI: $uri"
    if ($skipToken) {
      Write-Verbose "[$(getCurrentUTCString)]: Using skip token for pagination"
    }

    $retryCount = 0
    $success = $false
    $pageResult = $null

    do {
      try {
        $skipToken = $null
        $retryCount++
        Write-Verbose "[$(getCurrentUTCString)]: Attempt $retryCount/$maxRetries (Page $pageNumber)"

        $response = Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $jsonBody -TimeoutSec $timeoutSeconds

        if ($response.StatusCode -eq 200) {
          $pageResult = ($response.Content | ConvertFrom-Json -Depth 99)
          $success = $true

          $pageCount = if ($pageResult.data) { $pageResult.data.Count } else { 0 }
          Write-Verbose "[$(getCurrentUTCString)]: Successfully retrieved $pageCount resources from Azure Resource Graph (Page $pageNumber)"

          # Handle truncated results
          if ($pageResult.truncated -eq $true) {
            Write-Warning "[$(getCurrentUTCString)]: Results were truncated on page $pageNumber. Consider refining your query."
          }

          # Add results to collection
          if ($pageResult.data -and $pageResult.data.Count -gt 0) {
            $allResults += $pageResult.data
            $totalCount += $pageResult.data.Count
          }

          # Check for more pages
          $skipToken = $pageResult.'$skipToken'

          if ($skipToken -and $enablePagination) {
            Write-Verbose "[$(getCurrentUTCString)]: Skip token found. More pages available."
            $pageNumber++
            # Reset skip for next page when using skip token
            $currentSkip = 0
          } elseif ($skipToken -and !$enablePagination) {
            Write-Warning "[$(getCurrentUTCString)]: More results available but pagination is disabled. Set -enablePagination to true to retrieve all results."
            break
          }

        } else {
          Write-Warning "[$(getCurrentUTCString)]: Unexpected status code: $($response.StatusCode)"
        }
      } catch {
        $statusCode = $null
        if ($_.Exception.Response) {
          $statusCode = [int]$_.Exception.Response.StatusCode
        }

        Write-Verbose "[$(getCurrentUTCString)]: Error occurred during Azure Resource Graph query (Page $pageNumber)"
        Write-Verbose "[$(getCurrentUTCString)]: HTTP Status Code: $statusCode"
        Write-Verbose "[$(getCurrentUTCString)]: Error: $($_.Exception.Message)"

        # Handle specific error scenarios
        if ($statusCode -eq 429 -or $statusCode -eq 503) {
          # Rate limiting or service unavailable - retry with exponential backoff
          if ($retryCount -lt $maxRetries) {
            $waitSeconds = [math]::Pow(2, $retryCount) + (Get-Random -Minimum 1 -Maximum 5)
            Write-Verbose "[$(getCurrentUTCString)]: Rate limited or service unavailable. Waiting $waitSeconds seconds before retry."
            Start-Sleep -Seconds $waitSeconds
          }
        } elseif ($statusCode -eq 400) {
          # Bad request - don't retry
          Write-Error "[$(getCurrentUTCString)]: Bad request. Please check your query syntax and parameters."
          return $null
        } elseif ($statusCode -eq 401 -or $statusCode -eq 403) {
          # Authentication/authorization error - don't retry
          Write-Error "[$(getCurrentUTCString)]: Authentication or authorization failed. Please check your permissions."
          return $null
        } else {
          # Other errors - retry with standard backoff
          if ($retryCount -lt $maxRetries) {
            $waitSeconds = Get-Random -Minimum 5 -Maximum 15
            Write-Verbose "[$(getCurrentUTCString)]: Retrying in $waitSeconds seconds..."
            Start-Sleep -Seconds $waitSeconds
          }
        }
      }
    } while ($retryCount -lt $maxRetries -and !$success)

    if (!$success) {
      Write-Error "[$(getCurrentUTCString)]: Failed to query Azure Resource Graph on page $pageNumber after $maxRetries attempts."
      # Return partial results if we have any
      if ($allResults.Count -gt 0) {
        Write-Warning "[$(getCurrentUTCString)]: Returning partial results ($($allResults.Count) items) due to failure on page $pageNumber."
        return $allResults
      }
      return $null
    }

  } while ($skipToken -and $enablePagination -and $success)

  Write-Verbose "[$(getCurrentUTCString)]: Completed pagination. Total results: $totalCount across $pageNumber page(s)"

  return $allResults
}

#function to get Policy resources using Azure Resource Graph
function getPolicyResources {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(ParameterSetName = 'byId', Mandatory = $true, HelpMessage = "Specify the resource Id of the Policy resource.")]
    [string[]]$ResourceIds,

    [parameter(ParameterSetName = 'byManagementGroupHierarchy', Mandatory = $true, HelpMessage = "Specify the resource type.")]
    [ValidateSet('assignment', 'definition', 'initiative', 'exemption', 'policyMetadata')]
    [string]$ResourceType,

    [parameter(ParameterSetName = 'byManagementGroupHierarchy', Mandatory = $true, HelpMessage = "Specify the resource Id of management group at the top of the hierarchy.")]
    [string]$ManagementGroupName,

    [parameter(Mandatory = $true, HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token
  )
  $searchParams = @{
    scopeType = 'tenant'
    token     = $Token
  }
  if ($PSCmdlet.ParameterSetName -eq 'byId') {
    #convert multiple resourceIds to string
    $arrResourceId = @()
    foreach ($item in $ResourceIds) {
      $arrResourceId += "'$item'"
    }
    $resourceId = $arrResourceId -join ','
    $resourceId = $resourceId.ToLower()
    $Query = "policyresources | where tolower(id) in ($resourceId)"
  } else {
    switch ($ResourceType) {
      'assignment' { $type = 'microsoft.authorization/policyassignments' }
      'definition' { $type = 'microsoft.authorization/policydefinitions' }
      'initiative' { $type = 'microsoft.authorization/policysetdefinitions' }
      'exemption' { $type = 'microsoft.authorization/policyexemptions' }
    }
    $Query = "policyresources | where type =~ '{0}'" -f $type
    $searchParams.scopeType = 'managementGroup'
    $searchParams.Add('scope', $ManagementGroupName)
  }
  $searchParams.Add('query', $Query)
  $result = invokeARGQueryREST @searchParams
  if ($result) {
    Write-Verbose "[$(getCurrentUTCString)]: Found policy resource in the $($searchParams.scopeType) scope"
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No policy resources found in the $($searchParams.scopeType) scope"
    $result = @()
  }
  return , $result
}

#function to get all assignments, initiatives and definitions that are currently assigned and store them in a variable so that we don't have to keep querying ARG
function getAllPolicyResources {
  [CmdletBinding()]
  [OutputType([Hashtable])]
  param (
    [parameter(Mandatory = $true)][string]$ManagementGroupName,
    [parameter(Mandatory = $true)][string]$Token,
    [parameter(Mandatory = $false)][BuiltInSecurityControlConfig[]]$additionalBuiltInPolicyMetadataConfig
  )
  $initiativeResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policysetdefinitions\/'
  $definitionResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policydefinitions\/'
  $policyMetadataResourceIdRegex = '(?im)^\/providers\/microsoft\.policyinsights\/policyMetadata\/'
  $builtInDefinitionResourceIdRegex = '(?im)^\/providers\/microsoft\.authorization\/policydefinitions\/'
  $initiativeResourceIds = @()
  $definitionResourceIds = @()
  $assignmentResourceIds = @()
  $builtInDefinitionInUnassignedInitiativeResourceIds = @()
  $policyMetadataResourceIds = @()
  Write-Verbose "[$(getCurrentUTCString)]: Getting all policy Assignments under management group '$ManagementGroupName'."
  $assignments = getPolicyResources -ResourceType assignment -ManagementGroupName $ManagementGroupName -Token $Token
  Write-Verbose "[$(getCurrentUTCString)]: Found $($assignments.Count) policy assignments under management group '$ManagementGroupName'."

  #Get all assigned initiatives and definitions
  foreach ($assignment in $assignments) {
    $assignmentResourceIds += "'$($assignment.id.tolower())'"
    $defId = $assignment.properties.policyDefinitionId.tolower()
    Write-Verbose "[$(getCurrentUTCString)]: Policy assignment '$($assignment.name)'is used to assign '$defId'."
    if ($defId -match $initiativeResourceIdRegex) {
      #a policy initiative is assigned
      if ($initiativeResourceIds -notcontains $defId) {
        $initiativeResourceIds += $defId
      }
    } elseif ($defId -match $definitionResourceIdRegex) {
      #a policy definition is assigned
      if ($definitionResourceIds -notcontains $defId) {
        $definitionResourceIds += $defId
      }
    } else {
      Write-Error "[$(getCurrentUTCString)]: Unable to detect the type of the assigned policy definition Id '$defId'."
    }
  }

  #get compliance percentage for each assignment
  $assignmentResourceId = $assignmentResourceIds -join ','
  $assignmentComplianceQuery = @"
PolicyResources
| where type =~ 'Microsoft.PolicyInsights/PolicyStates'
| extend complianceState = tostring(properties.complianceState)
| extend
  resourceId = tostring(properties.resourceId),
  policyAssignmentId = tostring(properties.policyAssignmentId),
  policyAssignmentScope = tostring(properties.policyAssignmentScope),
  policyAssignmentName = tostring(properties.policyAssignmentName),
  policyDefinitionId = tostring(properties.policyDefinitionId),
  policyDefinitionReferenceId = tostring(properties.policyDefinitionReferenceId),
  stateWeight = iff(complianceState == 'NonCompliant', int(300), iff(complianceState == 'Compliant', int(200), iff(complianceState == 'Conflict', int(100), iff(complianceState == 'Exempt', int(50), int(0)))))
| where tolower(policyAssignmentId) in ($assignmentResourceId)
| summarize max(stateWeight) by resourceId, policyAssignmentId, policyAssignmentScope, policyAssignmentName, subscriptionId
| summarize counts = count() by policyAssignmentId, policyAssignmentScope, max_stateWeight, policyAssignmentName, subscriptionId
| summarize overallStateWeight = max(max_stateWeight),
nonCompliantCount = sumif(counts, max_stateWeight == 300),
compliantCount = sumif(counts, max_stateWeight == 200),
conflictCount = sumif(counts, max_stateWeight == 100),
exemptCount = sumif(counts, max_stateWeight == 50) by policyAssignmentId, policyAssignmentScope, policyAssignmentName, subscriptionId
| extend totalResources = todouble(nonCompliantCount + compliantCount + conflictCount + exemptCount)
| extend compliancePercentage = round(iff(totalResources == 0, todouble(100), 100 * todouble(compliantCount + exemptCount) / totalResources), 0)
| project policyAssignmentName, policyAssignmentId, scope = policyAssignmentScope, subscriptionId,
complianceState = iff(overallStateWeight == 300, 'noncompliant', iff(overallStateWeight == 200, 'compliant', iff(overallStateWeight == 100, 'conflict', iff(overallStateWeight == 50, 'exempt', 'notstarted')))),
compliancePercentage,
compliantCount,
nonCompliantCount,
conflictCount,
exemptCount
"@
  $assignmentCompliance = invokeARGQueryREST -ScopeType 'managementGroup' -Scope $ManagementGroupName -Query $assignmentComplianceQuery -token $Token

  #Get all policy initiatives and definitions
  $initiatives = @()
  if ($initiativeResourceIds.count -gt 0) {
    $arrAssignedInitiativeResourceId = @()
    foreach ($item in $initiativeResourceIds) {
      $arrAssignedInitiativeResourceId += "'$item'"
    }
    $assignedInitiativeResourceId = $arrAssignedInitiativeResourceId -join ','
    $assignedInitiativeResourceId = $assignedInitiativeResourceId.ToLower()
    $assignedInitiativeQuery = "policyresources | where id in~ ($assignedInitiativeResourceId) | extend isInUse = 'true'"
    $initiatives += invokeARGQueryREST -ScopeType 'tenant' -Query $assignedInitiativeQuery -token $Token
  }

  #get all the member policy definitions and used built-in policy metadata from all the assigned initiatives
  foreach ($initiative in $initiatives) {
    #get all the built-in policy metadata used by the initiative
    foreach ($policyDefinitionGroup in $initiative.properties.policyDefinitionGroups) {
      if ($policyDefinitionGroup.additionalMetadataId -match $policyMetadataResourceIdRegex) {
        $policyMetadataId = $policyDefinitionGroup.additionalMetadataId.tolower()
        if ($policyMetadataResourceIds -notcontains $policyMetadataId) {
          $policyMetadataResourceIds += $policyMetadataId
        }
      }

    }
    #get all the policy definitions used by the initiative
    foreach ($policy in $initiative.properties.policyDefinitions) {
      $defId = $policy.policyDefinitionId.tolower()
      if ($definitionResourceIds -notcontains $defId) {
        $definitionResourceIds += $defId
      }
    }
  }

  #Find unassigned custom initiatives
  $arrInitiativeResourceIds = @()
  foreach ($item in $initiativeResourceIds) {
    $arrInitiativeResourceIds += "'$item'"
  }
  $strInitiativeResourceId = $arrInitiativeResourceIds -join ','
  $strInitiativeResourceId = $strInitiativeResourceId.ToLower()
  $unassignedCustomInitiativesQuery = "policyresources | where type =~ 'microsoft.authorization/policysetdefinitions'| where properties.policyType =~ 'custom'| where id !in~ ($strInitiativeResourceId) | extend isInUse = 'false'"

  $unassignedCustomInitiatives = invokeARGQueryREST -scopeType 'managementGroup' -scope $ManagementGroupName -query $unassignedCustomInitiativesQuery -token $Token

  #get all the built-in member policy definitions and used built-in policy metadata from all the unassigned initiatives
  foreach ($initiative in $unassignedCustomInitiatives) {
    #get all the built-in policy metadata used by the initiative
    foreach ($policyDefinitionGroup in $initiative.properties.policyDefinitionGroups) {
      if ($policyDefinitionGroup.additionalMetadataId -match $policyMetadataResourceIdRegex) {
        $policyMetadataId = $policyDefinitionGroup.additionalMetadataId.tolower()
        if ($policyMetadataResourceIds -notcontains $policyMetadataId) {
          $policyMetadataResourceIds += $policyMetadataId
        }
      }

    }
    #get all the built-in policy definitions used by the initiative, custom policy definitions should already been captured
    foreach ($policy in $initiative.properties.policyDefinitions) {
      $defId = $policy.policyDefinitionId.tolower()
      if ($builtInDefinitionInUnassignedInitiativeResourceIds -notcontains $defId -and $defId -match $builtInDefinitionResourceIdRegex) {
        $builtInDefinitionInUnassignedInitiativeResourceIds += $defId
      }
    }
  }
  #get policy metadata
  if ($policyMetadataResourceIds.count -gt 0) {
    $arrInUsePolicyMetadataResourceIds = @()
    foreach ($item in $policyMetadataResourceIds) {
      $arrInUsePolicyMetadataResourceIds += "'$item'"
    }
    $inUsePolicyMetadataResourceId = $arrInUsePolicyMetadataResourceIds -join ','
    $inUsePolicyMetadataResourceId = $inUsePolicyMetadataResourceId.ToLower()
    $inUsePolicyMetadataQuery = "policyresources | where tolower(id) in ($inUsePolicyMetadataResourceId) | extend isInUse = 'true', framework = 'tbd'"
    $policyMetadata = invokeARGQueryREST -scopeType tenant -query $inUsePolicyMetadataQuery -token $Token
  } else {
    $policyMetadata = @()
  }
  #additional built-in policy metadata
  if ($additionalBuiltInPolicyMetadataConfig) {
    foreach ($config in $additionalBuiltInPolicyMetadataConfig) {
      $additionalPolicyMetadataQuery = "policyresources | where type =~ 'microsoft.policyinsights/policymetadata' | where name matches regex @'$($config.policyMetadataNameRegex)' | extend IsInUse = 'false', framework = '$($config.framework)'"
      $additionalPolicyMetadata = invokeARGQueryREST -scopeType 'tenant' -query $additionalPolicyMetadataQuery -token $Token

      #Add result to $policyMetadata if it's not already present
      $additionalPolicyMetadataCount = 0
      foreach ($item in $additionalPolicyMetadata) {
        if (-not $($policyMetadata | where-object { $_.id -ieq $item.id })) {
          $policyMetadata += $item
          $additionalPolicyMetadataCount ++
        }
      }
    }
  }
  #try to determine the framework for in-use policy metadata using the regex in additionalBuiltInPolicyMetadataConfig, if not match, set framework to 'tbd'
  foreach ($metadata in $($policyMetadata | where-object { $_.isInUse -eq 'true' })) {
    $matchedFramework = $null
    if ($additionalBuiltInPolicyMetadataConfig) {
      foreach ($config in $additionalBuiltInPolicyMetadataConfig) {
        if ($metadata.name -imatch $config.policyMetadataNameRegex) {
          $matchedFramework = $config.framework
          break
        }
      }
    }
    if ($matchedFramework) {
      $metadata.framework = $matchedFramework
    } else {
      $metadata.framework = 'Unknown'
    }
  }
  #get policy definitions
  if ($definitionResourceIds.count -gt 0) {
    $definitions = @()
    $arrAssignedDefinitionsResourceId = @()
    foreach ($item in $definitionResourceIds) {
      $arrAssignedDefinitionsResourceId += "'$item'"
    }
    $assignedDefinitionResourceId = $arrAssignedDefinitionsResourceId -join ','
    $assignedDefinitionResourceId = $assignedDefinitionResourceId.ToLower()
    $assignedDefinitionsQuery = "policyresources | where id in~ ($assignedDefinitionResourceId) | extend isInUse = 'true'"
    $definitions += invokeARGQueryREST -scopeType 'tenant' -query $assignedDefinitionsQuery -token $Token
  } else {
    $definitions = @()
  }

  if ($builtInDefinitionInUnassignedInitiativeResourceIds.count -gt 0) {
    $builtInDefinitionInUnassignedInitiative = getPolicyResources -ResourceIds $builtInDefinitionInUnassignedInitiativeResourceIds -Token $Token
  } else {
    $builtInDefinitionInUnassignedInitiative = @()
  }
  #Find unassigned custom definitions
  $arrDefinitionResourceIds = @()
  foreach ($item in $definitionResourceIds) {
    $arrDefinitionResourceIds += "'$item'"
  }
  $strDefinitionResourceId = $arrDefinitionResourceIds -join ','
  $strDefinitionResourceId = $strDefinitionResourceId.ToLower()
  $unassignedCustomDefinitionsQuery = "policyresources | where type =~ 'microsoft.authorization/policydefinitions'| where properties.policyType =~ 'custom'| where id !in~ ($strDefinitionResourceId) | extend isInUse = 'false'"

  $unassignedCustomDefinitions = invokeARGQueryREST -scopeType 'managementGroup' -scope $ManagementGroupName -query $unassignedCustomDefinitionsQuery -token $Token

  #find policy exemptions created for the assignments
  $policyExemptions = getPolicyExemptions -policyAssignmentResourceIds $assignments.id -token $Token

  #get compliance percentage for each subscription
  $subscriptionComplianceQuery = @"
PolicyResources
| where type =~ 'Microsoft.PolicyInsights/PolicyStates'
| extend complianceState = tostring(properties.complianceState)
| extend
  resourceId = tostring(properties.resourceId),
  stateWeight = iff(complianceState == 'NonCompliant', int(300), iff(complianceState == 'Compliant', int(200), iff(complianceState == 'Conflict', int(100), iff(complianceState == 'Exempt', int(50), int(0)))))
| summarize max(stateWeight) by resourceId, subscriptionId
| summarize counts = count() by subscriptionId, max_stateWeight
| summarize overallStateWeight = max(max_stateWeight),
nonCompliantCount = sumif(counts, max_stateWeight == 300),
compliantCount = sumif(counts, max_stateWeight == 200),
conflictCount = sumif(counts, max_stateWeight == 100),
exemptCount = sumif(counts, max_stateWeight == 50) by subscriptionId
| extend totalResources = todouble(nonCompliantCount + compliantCount + conflictCount + exemptCount)
| extend compliancePercentage = round(iff(totalResources == 0, todouble(100), 100 * todouble(compliantCount + exemptCount) / totalResources), 0)
| project subscriptionId,
complianceState = iff(overallStateWeight == 300, 'noncompliant', iff(overallStateWeight == 200, 'compliant', iff(overallStateWeight == 100, 'conflict', iff(overallStateWeight == 50, 'exempt', 'notstarted')))),
compliancePercentage, compliantCount, nonCompliantCount, conflictCount, exemptCount
"@
  $subscriptionComplianceSummary = invokeARGQueryREST -scopeType 'managementGroup' -scope $ManagementGroupName -query $subscriptionComplianceQuery -token $Token

  #get compliance summary by initiative policyDefinitionGroupName
  $complianceSummaryByInitiativePolicyDefinitionGroupQuery = @"
PolicyResources
| where type =~ 'Microsoft.PolicyInsights/PolicyStates'
| extend complianceState = tostring(properties.complianceState)
| mv-expand policyDefinitionGroupName = properties.policyDefinitionGroupNames
| extend
  resourceId = tostring(properties.resourceId),
  resourceType = tolower(tostring(properties.resourceType)),
  policyAssignmentId = tostring(properties.policyAssignmentId),
  policyDefinitionId = tostring(properties.policyDefinitionId),
  policyDefinitionReferenceId = tostring(properties.policyDefinitionReferenceId),
  stateWeight = iff(complianceState == 'NonCompliant', int(300), iff(complianceState == 'Compliant', int(200), iff(complianceState == 'Conflict', int(100), iff(complianceState == 'Exempt', int(50), int(0)))))
| where policyAssignmentId in~ ($assignmentResourceId)
| summarize max(stateWeight) by tostring(policyDefinitionGroupName), policyDefinitionReferenceId, policyDefinitionId, policyAssignmentId, subscriptionId
| summarize counts = count() by tostring(policyDefinitionGroupName), policyDefinitionReferenceId, policyDefinitionId, policyAssignmentId, max_stateWeight, subscriptionId
| summarize nonCompliantCount = sumif(counts, max_stateWeight == 300), compliantCount = sumif(counts, max_stateWeight == 200),
conflictCount = sumif(counts, max_stateWeight == 100),
exemptCount = sumif(counts, max_stateWeight == 50) by tostring(policyDefinitionGroupName), policyDefinitionReferenceId, policyDefinitionId, policyAssignmentId, subscriptionId
| extend totalResources = todouble(nonCompliantCount + compliantCount + conflictCount + exemptCount)
| project policyDefinitionGroupName, policyDefinitionReferenceId, policyDefinitionId, policyAssignmentId, subscriptionId, compliantCount, nonCompliantCount, conflictCount, exemptCount
"@

  $complianceSummaryByPolicyDefinitionGroup = invokeARGQueryREST  -scopeType 'managementGroup' -scope $ManagementGroupName -query $complianceSummaryByInitiativePolicyDefinitionGroupQuery -token $Token
  $allInitiatives = $($initiatives; $unassignedCustomInitiatives)
  $allDefinitions = $($definitions; $unassignedCustomDefinitions)
  #look up policy metadata resource id for each item in $complianceSummaryByPolicyDefinitionGroup
  foreach ($item in $complianceSummaryByPolicyDefinitionGroup) {
    if ($item.policyDefinitionGroupName.length -gt 0) {
      $policyMetadataId = getPolicyMetadataResourceId -policyMetadataName $item.policyDefinitionGroupName -policyAssignmentId $item.policyAssignmentId -assignments $assignments -initiatives $allInitiatives
    } else {
      $policyMetadataId = $null
    }

    $item | Add-Member -MemberType NoteProperty -Name policyMetadataId -Value $policyMetadataId
  }
  $policyResources = @{
    assignments                                   = $assignments
    initiatives                                   = $allInitiatives
    definitions                                   = $allDefinitions
    exemptions                                    = $policyExemptions
    policyMetadata                                = $policyMetadata
    #unassignedCustomInitiatives                   = $unassignedCustomInitiatives
    #unassignedCustomDefinitions                   = $unassignedCustomDefinitions
    builtInDefinitionInUnAssignedCustomInitiative = $builtInDefinitionInUnassignedInitiative
    assignmentCompliance                          = $assignmentCompliance
    subscriptionComplianceSummary                 = $subscriptionComplianceSummary
    complianceSummaryByPolicyDefinitionGroup      = $complianceSummaryByPolicyDefinitionGroup
  }
  $policyResources
}

#function to get the managed identity principal IDs for assignments
function getPolicyAssignmentManagedIdentityPrincipalIds {
  [CmdletBinding()]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object[]]
    $assignments
  )

  # Get all managed identity principal IDs from policy assignments
  $assignmentIdentities = @()
  foreach ($assignment in $assignments) {
    if ($assignment.identity) {
      $assignmentIdentity = @{
        assignmentId = $assignment.id
      }
      if ($assignment.identity -and $assignment.identity.type -ieq 'SystemAssigned') {
        $assignmentIdentity.Add('systemAssignedPrincipalId', $assignment.identity.principalId)
      } elseif ($assignment.identity.type -ieq 'UserAssigned') {
        $userAssignedIdentities = ConvertToOrderedHashtable -inputObject $assignment.identity.userAssignedIdentities
        $userAssignedIdentityResourceId = $userAssignedIdentities.Keys
        $usmi = @()
        foreach ($id in $userAssignedIdentityResourceId) {
          $usmi += @{
            resourceId  = $id
            principalId = $userAssignedIdentities[$id].principalId
          }
        }
        $assignmentIdentity.Add('userAssignedIdentities', $usmi)
      }
      $assignmentIdentities += $assignmentIdentity
    }
  }
  , $assignmentIdentities
}

#function to get policy exemptions for a list of policy assignment IDs using Azure Resource Graph
function getPolicyExemptions {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)][string[]]$policyAssignmentResourceIds,

    [parameter(Mandatory = $true, HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token
  )
  $arrAssignmentId = @()
  foreach ($item in $policyAssignmentResourceIds) {
    $arrAssignmentId += "'$item'"
  }
  $strAssignmentId = $arrAssignmentId -join ','
  $strAssignmentId = $strAssignmentId.ToLower()
  $query = @"
policyresources
| where type =~ 'microsoft.authorization/policyexemptions'
| extend policyAssignmentId = properties.policyAssignmentId
| where tolower(policyAssignmentId) in ($strAssignmentId)
| project id, name, displayName = properties.displayName, subscriptionId, resourceGroup, policyAssignmentId, policyDefinitionReferenceIds = properties.policyDefinitionReferenceIds, exemptionCategory = properties.exemptionCategory, description = properties.description, expiresOn = properties.expiresOn, metadata = properties.metadata, definitionVersion = properties.definitionVersion, resourceSelectors = properties.resourceSelectors
"@
  $searchParams = @{
    scopeType = 'tenant'
    query     = $query
    token     = $Token
  }
  $result = invokeARGQueryREST @searchParams
  if ($result) {
    Write-Verbose "[$(getCurrentUTCString)]: Found policy exemptions in the $($searchParams.scopeType) scope"
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No policy exemptions found in the $($searchParams.scopeType) scope"
    $result = @()
  }
  return , $result
}

#function to get role assignments using Azure Resource Graph
function getRoleAssignments {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)][string[]]$principalIds,

    [parameter(Mandatory = $true, HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token
  )
  $arrPrincipalId = @()
  foreach ($item in $principalIds) {
    $arrPrincipalId += "'$item'"
  }
  $strPrincipalId = $arrPrincipalId -join ','
  $strPrincipalId = $strPrincipalId.ToLower()
  $query = @"
authorizationresources
| where type =~ "microsoft.authorization/roleassignments"
| extend principalId = properties.principalId, principalType = properties.principalType, scope = properties.scope, roleDefinitionId = properties.roleDefinitionId
| where tolower(principalId) in ($strPrincipalId)
| project id, principalId, principalType, scope, roleDefinitionId
"@
  $searchParams = @{
    scopeType = 'tenant'
    query     = $query
    token     = $Token
  }
  $result = invokeARGQueryREST @searchParams
  if (!$result) {
    $result = @()
  }
  return , $result
}

#function to get role definitions using Azure Resource Graph
function getRoleDefinitions {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)][string[]]$resourceIds,

    [parameter(Mandatory = $true, HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token
  )
  $arrResourceId = @()
  foreach ($item in $resourceIds) {
    $arrResourceId += "'$item'"
  }
  $strResourceId = $arrResourceId -join ','
  $strResourceId = $strResourceId.ToLower()
  $query = @"
authorizationresources
| where type == "microsoft.authorization/roledefinitions"
| extend roleName = properties.roleName, description = properties.description, assignableScopes = properties.assignableScopes, type = properties.type, isServiceRole = properties.isServiceRole
| where tolower(id) in ($strResourceId)
| project id, name, roleName, description, assignableScopes, type, isServiceRole
"@

  $searchParams = @{
    scopeType = 'tenant'
    query     = $query
    token     = $Token
  }
  $result = invokeARGQueryREST @searchParams
  if (!$result) {
    $result = @()
  }
  return , $result
}

#function to get management group hierarchy
function getManagementGroupHierarchy {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)][string]$ManagementGroupName,

    [parameter(Mandatory = $true, HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token
  )
  $Query = @"
resourcecontainers
| where type =~ 'microsoft.management/managementgroups'
| extend parentId = properties.details.parent.id, parentName = properties.details.parent.name, parentDisplayName = properties.details.parent.displayName, managementGroupAncestors = tostring(properties.details.managementGroupAncestorsChain)
| extend ancestors = extract_all(@'\"name\"\:\"([^"]+)\"}', managementGroupAncestors)
| extend strAncestors = tostring(ancestors)
| where strAncestors contains '"$ManagementGroupName"' or name =~ '$ManagementGroupName'
| extend tier = coalesce(array_length(ancestors), 0)+1
| project id, name, displayName = properties.displayName, parentId, parentName, parentDisplayName, ancestors, tier
| sort by tier asc
"@
  $result = invokeARGQueryREST -scopeType 'tenant' -query $Query -token $Token
  if (!$result) {
    $result = @()
  }
  return , $result
}

#function to get subscriptions under management group
function getSubscriptionsUnderManagementGroup {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)][string]$ManagementGroupName,

    [parameter(Mandatory = $true, HelpMessage = "The Azure OAuth token for accessing 'https://management.azure.com/'. This is required to invoke the Azure Resource Graph query via it's REST API.")]
    [ValidateNotNullOrEmpty()]
    [string]$Token
  )
  $Query = @"
ResourceContainers
| where type =~ 'microsoft.resources/subscriptions'
| extend  mgParent = properties.managementGroupAncestorsChain
| mv-expand with_itemindex=MGHierarchy mgParent
| where MGHierarchy == 0
| project id, subscriptionId, name, tenantId, parentMgName = mgParent.name, tags, managementGroupAncestorsChain = properties.managementGroupAncestorsChain, quotaId = properties.subscriptionPolicies.quotaId, state = properties.state
"@

  $result = invokeARGQueryREST -scopeType 'managementGroup' -scope $ManagementGroupName -query $Query -token $Token
  if (!$result) {
    $result = @()
  }
  return , $result
}

#function to look up policy metadata resource Id by name and policy assignment id
function getPolicyMetadataResourceId {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)][string]$policyMetadataName,
    [parameter(Mandatory = $true)][string]$policyAssignmentId,
    [parameter(Mandatory = $true)][object[]]$assignments,
    [parameter(Mandatory = $true)][object[]]$initiatives
  )

  #Get the policy assignment
  $assignment = $assignments | Where-Object { $_.id -ieq $policyAssignmentId }
  if (-not $assignment) {
    Write-Error "[$(getCurrentUTCString)]: Unable to find policy assignment with Id '$policyAssignmentId'."
    return $null
  }

  #Get the policy definition Id from the assignment
  $policyDefinitionId = $assignment.properties.policyDefinitionId
  if (-not $policyDefinitionId) {
    Write-Error "[$(getCurrentUTCString)]: Unable to find policy definition Id from policy assignment with Id '$policyAssignmentId'."
    return $null
  }
  #Check if the policy definition is an initiative
  if ($policyDefinitionId -notmatch '(?im)\/providers\/microsoft\.authorization\/policysetdefinitions\/') {
    Write-Verbose "[$(getCurrentUTCString)]: The policy definition Id '$policyDefinitionId' from policy assignment with Id '$policyAssignmentId' is not a policy initiative."
    return $null
  }

  #Get the initiative
  $initiative = $initiatives | Where-Object { $_.id -ieq $policyDefinitionId }
  if (-not $initiative) {
    Write-Error "[$(getCurrentUTCString)]: Unable to find policy initiative with Id '$policyDefinitionId'."
    return $null
  }

  #Get policy definition group
  $pdg = $initiative.properties.policyDefinitionGroups | Where-Object { $_.name -ieq $policyMetadataName }
  if (-not $pdg) {
    Write-Error "[$(getCurrentUTCString)]: Unable to find policy definition group with name '$policyMetadataName' in initiative with Id '$policyDefinitionId'."
    return $null
  }

  #check if additionalMetadataId exists
  if (-not $pdg.additionalMetadataId) {
    Write-Verbose "[$(getCurrentUTCString)]: No additionalMetadataId found in policy definition group with name '$policyMetadataName' in initiative with Id '$policyDefinitionId'."
    return $null
  } else {
    return $pdg.additionalMetadataId
  }
}

#function to sign the environment discovery file to ensure integrity and prevent manual modification
function signContent {
  [CmdletBinding()]
  [OutputType([System.Collections.Specialized.OrderedDictionary])]
  param(
    [System.Collections.Specialized.OrderedDictionary]$inputContent
  )
  $inputJson = $inputContent | ConvertTo-Json -Depth 100
  $inputFileBytes = [System.Text.Encoding]::UTF8.GetBytes($inputJson)
  # Load private key
  $codeSignPrivateKey = '<RSAKeyValue><Modulus>u27QW4gRFxuf34cydg+kIyAqpBfzrMfeqZmu6YhK5aacurte+xPEhLD0SUwHgfve+kb2l7+QKp9dGlU+w/obT9b6hw1IBtr5amcO2QRxWbG1IAtq1cgLkyeL9/rWw3nvsTTO4vDnLqmGzaOZl+0ZueU5lfArfb2cpj03B+MUBEHcwwziQfOQN6z21lezM/NVVDvKswTIeJlOipRwBeD85Wf6T5egMibLri9WVsmeDCq0fN3WPBZOtaeO2xh8j1U4HQN/jKbOmp0JdhyLgjtJKLpCRwxzZKz5MR25U3NN41K+w7JXirXEZ8f3E7PywjAC+GawrVqm9qvVOj8Pw1hEzw==</Modulus><Exponent>AQAB</Exponent><P>5FpIZw3UOYh1bzLdtAmj2j/yD6/AgEWY63WkLT2iXcuApysNXpn8O0QD6R9/IP7kT6Sygy1iVtgxtwy6T6Pfbb0Je8XypKH4y5u+5chKWWNEF3zMyJNm/WTuRdFLp8zVAhvZKgDr8U7EXNMA/bRjjzaDXV5sYuIpuBNR632i6rU=</P><Q>0iA8Lbj6j0xc5u2slmFGtUhhHmeIC2kwWy+TvTUM7DXJGlumOs2VWi7A5NDJVErJq3J9tEx1nE/JOR3dmCRYo5FjQpi25ov9AJ03UjMiYU5RdUYbedhOsehA40TFrnijTd7BHSt3uf+UyfXldKwPC2pyR+tJfefFvmwy87iTb/M=</Q><DP>OiENa0Zm7tpg4pS1QT5u+oDqsrmPrFeLLO0+hNG6wluqfWOFPL7AKaoPwMlmyFR6dBe95YypCuhwB2PzDZDusHW9s0dZlDUzK0mTV9UbsBOH4t6/FpQHVJvb1+QGeUm4M5g5OOsRJNVjQSnph6vi6DL9T8hYmPdvnU81vFe4ID0=</DP><DQ>EKjVnJpp4yqewwBdCp8zx/OxH4P92UnBt7kR8ZJfL+sjwp85krfx+3BxgrK7A5/aVWmCZeUZ/galYY3on8Nh87X3NLR+69B1grL0S+QZ+bUH6FBipUptEtXjLyGouqh96hKbJQDpQSnuVgTU6Gcr2i/aV7Fj5kOV/f7+GyyrI9k=</DQ><InverseQ>ZVCSvqYk4Vwz9yeCEVDb887e5qufb8zFrR0SCjsvLKZSz+nxpmA7++CHED+2W6Ko3pFvQd6iucITVJU5Ri/wXe+wbo1DcrJIPl/6rdkAZ3WpYcNgNOX/Rag+f8yKbU+07Op8JWRRWww4ioK71bcxBJeYkuTLxt+mjIDyjWYN09g=</InverseQ><D>Ot3P1J+EdpR3frWwdIHvFBUbL1RSdLaFSRD6bWAf3caZPNByQTrxIpeM8aROS1W2rzYwZnKErc5FaGrTfquDfmzPXDEgqP6HDRL3B9OsYfY9I6ZSVHgyonHuNOD0KIqYbDhgrcfpY69cpiM2rw+JX+gNUPkQP7qYg2GAchqwg7E+FNOyOfXQJUzy4oZz3YfCz4rr/MF++gc7I58OWK9oNtsDDJ0JQQDh+oE3+7GfAo43kCaaUPlSuck4QcjwcSTHtmSEoZQEZBCWXCk4XINtHSBLXggb1WWdMFgRtyWYplwfJUtIgMcaGPHDu2qVYp0hMy1O3Wm3z/8NZWnqq7i2GQ==</D></RSAKeyValue>'
  $rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new()
  $rsa.FromXmlString($codeSignPrivateKey)  # Use FromXmlString for XML format

  $signature = $rsa.SignData($inputFileBytes,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)

  # Cleanup
  $rsa.Dispose()

  # Export signature as Base64
  $signature = [Convert]::ToBase64String($signature)

  # Create output object with signature embedded
  $signedOutput = [ordered]@{
    signature = $signature
    data      = $inputContent
  }
  $signedOutput
}
