<#
=====================================================================================================
AUTHOR: Tao Yang
DATE: 11/09/2025
NAME: AzPolicyLens.Wiki.Azure.Helper.psm1
VERSION: 2.0.0
COMMENT: this nested module contains the Azure related helper functions for AzPolicyLens.Wiki module
=====================================================================================================
#>
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1
using module ./AzPolicyLens.Wiki.Generic.Helper.psm1
#function to build initiative and definition json definitions from the ARG search results
function buildPolicyDefinitionJson {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Collections.Specialized.IOrderedDictionary]
    $PolicyDefinition
  )
  Write-Verbose "[$(getCurrentUTCString)]: Building JSON for policy definition '$($PolicyDefinition.name)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $json = $PolicyDefinition | ConvertTo-Json -Depth 99
  #tidy up
  $json = RemoveNullPropertiesFromJson -JsonString $json -Recurse -RemoveEmptyArrays -RemoveEmptyStrings
  $json
}

#function to detect the policy effect (borrowed from AzPolicyTest module)
function getPolicyEffect {
  param(
    [object] $policyObject
  )
  $parameterRegex = "^\[parameters\(\'(\S+)\'\)\]$"
  $effect = $policyObject.properties.policyRule.then.effect
  #check if the effect is a parameterised value
  if ($effect -imatch $parameterRegex) {
    $effectParameterName = $matches[1]
    $policyEffectAllowedValues = $policyObject.properties.parameters.$effectParameterName.allowedValues
    $policyEffectDefaultValue = $policyObject.properties.parameters.$effectParameterName.defaultValue
    $effects = @()
    if ($policyEffectAllowedValues) {
      $effects += $policyEffectAllowedValues
    } else {
      $effects += $policyEffectDefaultValue
    }
    $result = @{
      effects            = $effects
      defaultEffectValue = $policyEffectDefaultValue
      isHardCoded        = $false
    }
  } else {
    $result = @{
      effects            = @($effect)
      defaultEffectValue = $null
      isHardCoded        = $true
    }
  }
  $result
}

#function to get the policy definition group details from initiatives
function getPolicyDefinitionGroupsFromInitiatives {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object[]]
    $initiatives
  )

  $policyDefinitionGroups = [System.Collections.Generic.List[object]]::new()
  $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
  foreach ($initiative in $initiatives) {
    if ($initiative.properties.policyDefinitionGroups) {
      foreach ($pdg in $initiative.properties.policyDefinitionGroups) {
        $key = "$($pdg.name)|$($pdg.additionalMetadataId)"
        if ($seen.Add($key)) {
          $policyDefinitionGroups.Add($pdg)
        }
      }
    }
  }
  $policyDefinitionGroups | sort-object -property 'name'
}

#function to get unused policy definition group from an initiative
function getUnusedPolicyDefinitionGroupsFromInitiative {
  [CmdletBinding()]
  [OutputType([Array])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $initiative
  )
  $unusedPolicyDefinitionGroupNames = @()
  $allPolicyDefinitionGroupNames = ($initiative.properties.policyDefinitionGroups).name
  $usedPolicyDefinitionGroupNames = $initiative.properties.policyDefinitions.groupNames | Get-Unique
  foreach ($n in $allPolicyDefinitionGroupNames) {
    if (-not $usedPolicyDefinitionGroupNames.Contains($n)) {
      $unusedPolicyDefinitionGroupNames += $n
    }
  }
  , $unusedPolicyDefinitionGroupNames
}

#function to get mapped policies for a policy definition group
function getMappedPoliciesForPolicyDefinitionGroup {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$policyDefinitionGroupName,

    [parameter(Mandatory = $true, ParameterSetName = 'ByPolicyMetadataId')]
    [string]$policyMetadataId,

    [parameter(Mandatory = $true)]
    [System.Array]
    $initiatives
  )
  $builtInDefinitionResourceIdRegex = '(?im)^\/providers\/microsoft\.authorization\/policydefinitions\/'
  $mapping = @{
    definedInitiatives = [System.Collections.Generic.List[object]]::new()
    mappedPolicies     = [System.Collections.Generic.List[object]]::new()
  }
  foreach ($initiative in $initiatives) {
    Write-Verbose "Processing initiative '$($initiative.id)'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    if ($PSCmdlet.ParameterSetName -eq 'ByName' -and $initiative.properties.policyDefinitionGroups) {
      Write-Verbose "  - searching for policy definition group with name '$policyDefinitionGroupName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $pdg = $initiative.properties.policyDefinitionGroups | Where-Object { $_.name -ieq $policyDefinitionGroupName }
    } elseif ($PSCmdlet.ParameterSetName -eq 'ByPolicyMetadataId' -and $initiative.properties.policyDefinitionGroups) {
      Write-Verbose "  - searching for policy definition group with additionalMetadataIdId '$policyMetadataId'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $pdg = $initiative.properties.policyDefinitionGroups | Where-Object { $_.additionalMetadataId -ieq $policyMetadataId }
    }
    if ($pdg) {
      #Go through the member definitions
      [void]$mapping.definedInitiatives.Add(@{
          policyDefinitionGroupName = $pdg.name
          policySetDefinitionId     = $initiative.id
          policySetName             = $initiative.name
          policySetDisplayName      = $initiative.properties.displayName
          policySetMetadata         = $initiative.properties.metadata
          type                      = $initiative.properties.policyType
          isInUse                   = $initiative.isInUse
        })
      foreach ($definitionConfig in $initiative.properties.policyDefinitions) {
        if ($definitionConfig.groupNames -icontains $pdg.name) {
          #found a mapped policy
          Write-Verbose "  - Found mapped policy '$($definitionConfig.policyDefinitionReferenceId)' in initiative '$($initiative.id)'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
          if ($definitionConfig.policyDefinitionId -match $builtInDefinitionResourceIdRegex) {
            $policyDefinitionType = 'BuiltIn'
          } else {
            $policyDefinitionType = 'Custom'
          }
          [void]$mapping.mappedPolicies.Add(@{
              policyDefinitionGroupName   = $pdg.name
              policySetName               = $initiative.Name
              policySetDisplayName        = $initiative.properties.displayName
              policySetDefinitionId       = $initiative.Id
              policySetIsInUse            = $initiative.isInUse
              policySetType               = $initiative.properties.policyType
              policyDefinitionReferenceId = $definitionConfig.policyDefinitionReferenceId
              policyDefinitionId          = $definitionConfig.policyDefinitionId
              policyDefinitionType        = $policyDefinitionType
            })
        }
      }
    }
  }
  $mapping
}


#Function to get subscription ancestor Management Groups
function getSubscriptionMgAncestors {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object[]]
    $managementGroups,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Object]
    $TopLevelManagementGroup,

    [parameter(Mandatory = $true)]
    [object]
    $subscription
  )

  #get all the ancestor management groups for the subscription that's under the top level management group
  $ancestorManagementGroupNames = @()
  $ancestorManagementGroupNames += $subscription.managementGroupAncestorsChain.name
  $ancestorManagementGroups = @()
  foreach ($mg in $managementGroups) {
    if ($ancestorManagementGroupNames -contains $mg.name -and $mg.tier -ge $TopLevelManagementGroup.tier) {
      $ancestorManagementGroups += $mg
    }
  }
  $ancestorManagementGroups = $ancestorManagementGroups | Sort-Object 'tier' -Descending
  $ancestorManagementGroups
}

#function to get the managed identity principal IDs for assignments
function getPolicyAssignmentManagedIdentityPrincipalIds {
  [CmdletBinding()]
  [OutputType([object[]])]
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
  $assignmentIdentities
}

#function to get role assignment details for a given policy assignment
function getRoleAssignmentDetailsForPolicyAssignment {
  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $assignment,

    [parameter(Mandatory = $true)]
    [AllowNull()]
    [System.Object[]]
    $roleAssignments,

    [parameter(Mandatory = $true)]
    [AllowNull()]
    [System.Object[]]
    $roleDefinitions
  )
  $roleAssignmentDetails = @()
  if ($roleAssignments) {
    # get the managed identity principal IDs for the policy assignment
    $managedIdentityPrincipalIds = getPolicyAssignmentManagedIdentityPrincipalIds -assignments $assignment
    $principalIds = @()

    $assignmentRoleAssignments = @()
    if ($managedIdentityPrincipalIds.systemAssignedPrincipalId) {
      $principalIds += $managedIdentityPrincipalIds.systemAssignedPrincipalId
    }
    if ($managedIdentityPrincipalIds.userAssignedIdentities) {
      foreach ($usmi in $managedIdentityPrincipalIds.userAssignedIdentities) {
        $principalIds += $usmi.principalId
      }
    }
    if (-not $principalIds) {
      Write-Verbose "[$(getCurrentUTCString)]: No managed identity principal IDs found for policy assignment '$($assignment.name)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      return $roleAssignmentDetails
    }
    Write-Verbose "[$(getCurrentUTCString)]: Found $($principalIds.Count) managed identity principal IDs for policy assignment '$($assignment.name)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    # Get role assignments for the managed identity principal IDs
    foreach ($principalId in $principalIds) {
      #find the type of the identity based on the principal ID
      if ($principalId -ieq $managedIdentityPrincipalIds.systemAssignedPrincipalId) {
        $identityType = 'SystemAssigned'
      } else {
        $identityType = 'UserAssigned'
      }
      $assignmentRoleAssignments += $roleAssignments | Where-Object { $_.principalId -ieq $principalId }
      Write-verbose "[$(getCurrentUTCString)]: Found $($assignmentRoleAssignments.Count) role assignments for principal ID '$principalId'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      foreach ($roleAssignment in $assignmentRoleAssignments) {
        #Get the definition
        $roleDefinition = $roleDefinitions | Where-Object { $_.id -ieq $roleAssignment.roleDefinitionId }
        if (-not $roleDefinition) {
          Write-Warning "[$(getCurrentUTCString)]: No role definition found for role assignment '$($roleAssignment.id)'."
        } else {

          $roleAssignmentDetails += @{
            roleAssignmentId          = $roleAssignment.id
            roleDefinitionId          = $roleDefinition.id
            roleDefinitionDisplayName = $roleDefinition.roleName
            roleDefinitionName        = $roleDefinition.name
            roleDefinitionType        = $roleDefinition.type
            principalId               = $roleAssignment.principalId
            identityType              = $identityType
            managedIdentityType       = $assignment.identity.type
            roleAssignmentScope       = $roleAssignment.scope
            assignmentName            = $assignment.name
            assignmentId              = $assignment.id
          }
        }
      }
    }
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No role assignments from the discovery data."  -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  $roleAssignmentDetails
}

#function to calculate the compliance percentage
function getCompliancePercentage {
  param (
    [Parameter(Mandatory = $true)]
    [int]$CompliantCount,

    [Parameter(Mandatory = $true)]
    [int]$NonCompliantCount,

    [Parameter(Mandatory = $true)]
    [int]$ExemptCount,

    [Parameter(Mandatory = $true)]
    [int]$ConflictCount,

    [Parameter(Mandatory = $false, HelpMessage = "Number of fractional digits used to round the compliance percentage.")]
    [ValidateRange(0, 2)]
    [int]$NumberOfFractionalDigits = 0
  )
  $TotalCount = $CompliantCount + $NonCompliantCount + $ExemptCount + $ConflictCount
  $totalCompliantCount = $CompliantCount + $ExemptCount
  if ($TotalCount -eq 0) {
    $compliancePercentage = 100
  } else {
    $compliancePercentage = [math]::round(($totalCompliantCount / $TotalCount) * 100, $NumberOfFractionalDigits)
  }
  $compliancePercentage
}

#function to determine the security framework for a given built-in policy metadata
function getSecFrameworkForPolicyMetadata {
  param (
    [Parameter(Mandatory = $true)]
    [System.Array]$mappings,
    [Parameter(Mandatory = $true)]
    [string]$policyMetadataId
  )
  $policyMetadataName = $policyMetadataId.Split('/')[-1]
  #Write-Verbose "[$(getCurrentUTCString)]: Looking up security framework for policy metadata name '$policyMetadataName'." -Verbose
  $framework = "Uncategorized" #default value if no match found
  foreach ($mapping in $mappings) {
    $regex = $mapping.policyMetadataNameRegex
    if ($policyMetadataName -imatch $regex) {
      $framework = $mapping.framework
      break
    }
  }
  #Write-Verbose "  - Mapped policy metadata name '$policyMetadataName' to security framework '$framework'." -Verbose
  $framework
}

#function to get unique policy categories from assigned initiatives
function getUniqueCategoriesFromAssignedInitiatives {
  [CmdletBinding()]
  [OutputType([System.Collections.Specialized.OrderedDictionary])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData
  )

  $assignedInitiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.isInUse -eq $true }
  $allCategories = @{}
  foreach ($initiative in $assignedInitiatives) {
    #initial values for compliance counts
    $compliantCount = 0
    $nonCompliantCount = 0
    $exemptCount = 0
    $conflictCount = 0
    #get assignments for the initiative
    $initiativeAssignments = $EnvironmentDiscoveryData.assignments | Where-Object { $_.properties.policyDefinitionId -ieq $initiative.id }
    #calculate compliance counts
    foreach ($assignment in $initiativeAssignments) {
      $assignmentComplianceData = $EnvironmentDiscoveryData.assignmentCompliance | Where-Object { $_.policyAssignmentId -ieq $assignment.id }
      foreach ($complianceRecord in $assignmentComplianceData) {
        $compliantCount = $compliantCount + $complianceRecord.compliantCount
        $nonCompliantCount = $nonCompliantCount + $complianceRecord.nonCompliantCount
        $exemptCount = $exemptCount + $complianceRecord.exemptCount
        $conflictCount = $conflictCount + $complianceRecord.conflictCount
      }
    }

    if ($initiative.properties.metadata -and $initiative.properties.metadata.category) {
      $category = $initiative.properties.metadata.category
      $pdgs = @()
      if ($initiative.properties.policyDefinitionGroups.count -gt 0) {
        foreach ($item in $initiative.properties.policyDefinitionGroups) {
          if ($item.additionalMetadataId.length -gt 0) {
            $pdgs += $item.additionalMetadataId
          } else {
            $pdgs += $item.name
          }
        }
      }
      if ($allCategories.ContainsKey($category)) {
        $allCategories[$category].policyInitiativeCount++
        $allCategories[$category].resourceIds += $initiative.id
        $allCategories[$category].policyDefinitionGroups += $pdgs
        $allCategories[$category].compliantCount += $compliantCount
        $allCategories[$category].nonCompliantCount += $nonCompliantCount
        $allCategories[$category].exemptCount += $exemptCount
        $allCategories[$category].conflictCount += $conflictCount
      } else {
        $allCategories[$category] = @{
          policyInitiativeCount  = 1
          resourceIds            = @($initiative.id)
          policyDefinitionGroups = $pdgs
          compliantCount         = $compliantCount
          nonCompliantCount      = $nonCompliantCount
          exemptCount            = $exemptCount
          conflictCount          = $conflictCount
        }
      }
    } else {
      if ($allCategories.ContainsKey('Uncategorized')) {
        $pdgs = @()
        if ($initiative.properties.policyDefinitionGroups.count -gt 0) {
          foreach ($item in $initiative.properties.policyDefinitionGroups) {
            if ($item.additionalMetadataId.length -gt 0) {
              $pdgs += $item.additionalMetadataId
            } else {
              $pdgs += $item.name
            }
          }
        }
        $allCategories['Uncategorized'].policyInitiativeCount++
        $allCategories['Uncategorized'].resourceIds += $initiative.id
        $allCategories['Uncategorized'].policyDefinitionGroups += $pdgs
        $allCategories['Uncategorized'].compliantCount += $compliantCount
        $allCategories['Uncategorized'].nonCompliantCount += $nonCompliantCount
        $allCategories['Uncategorized'].exemptCount += $exemptCount
        $allCategories['Uncategorized'].conflictCount += $conflictCount
      } else {
        $allCategories['Uncategorized'] = @{
          policyInitiativeCount  = 1
          resourceIds            = @($initiative.id)
          policyDefinitionGroups = $pdgs
          compliantCount         = $compliantCount
          nonCompliantCount      = $nonCompliantCount
          exemptCount            = $exemptCount
          conflictCount          = $conflictCount
        }
      }
    }
  }
  #deduplicate policy definition groups in each category
  foreach ($key in $allCategories.Keys) {
    $allCategories[$key].policyDefinitionGroups = $allCategories[$key].policyDefinitionGroups | Get-Unique
  }
  # Convert to ordered hashtable sorted by key, with Uncategorized last
  $orderedCategories = [ordered]@{}
  $allCategories.GetEnumerator() | Where-Object { $_.Key -ne 'Uncategorized' } | Sort-Object -Property Key | ForEach-Object {
    $orderedCategories[$_.Key] = $_.Value
  }
  # Add Uncategorized at the end if it exists
  if ($allCategories.ContainsKey('Uncategorized')) {
    $orderedCategories['Uncategorized'] = $allCategories['Uncategorized']
  }

  $orderedCategories
}
