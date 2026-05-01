<#
===============================================================================================================
AUTHOR: Tao Yang
DATE: 11/09/2025
NAME: AzPolicyLens.Wiki.Markdown.Helper.psm1
VERSION: 2.0.0
COMMENT: this nested module contains the json, Markdown and HTML helper functions for AzPolicyLens.Wiki module
===============================================================================================================
#>
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1
using module ./AzPolicyLens.Wiki.Generic.Helper.psm1
using module ./AzPolicyLens.Wiki.Azure.Helper.psm1
using module ./AzPolicyLens.Wiki.Platform.Helper.psm1
# 01. function to clean up existing wiki files
function removeExistingWikiFiles {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$WikiDirectory,
    [Parameter(Mandatory = $false)]
    [string]$assignmentDirName = 'assignments',
    [Parameter(Mandatory = $false)]
    [string]$definitionDirName = 'definitions',
    [Parameter(Mandatory = $false)]
    [string]$exemptionDirName = 'exemptions',
    [Parameter(Mandatory = $false)]
    [string]$initiativeDirName = 'initiatives',
    [Parameter(Mandatory = $false)]
    [string]$subscriptionDirName = 'subscriptions',
    [Parameter(Mandatory = $false)]
    [string]$securityControlDirName = 'security-controls',
    [Parameter(Mandatory = $false)]
    [string]$analysisDirName = 'analysis'
  )

  process {
    if (Test-Path -Path $WikiDirectory -PathType Container) {
      $rootLevelMarkdownFiles = Get-ChildItem -Path "$WikiDirectory\*" -File -Include "*.md", ".order" -Force
      $assignmentDirectory1 = Join-Path -Path $WikiDirectory -ChildPath $assignmentDirName.tolower()
      $assignmentDirectory2 = Join-Path -Path $WikiDirectory -ChildPath $assignmentDirName.toupper()
      $definitionDirectory1 = Join-Path -Path $WikiDirectory -ChildPath $definitionDirName.tolower()
      $definitionDirectory2 = Join-Path -Path $WikiDirectory -ChildPath $definitionDirName.toupper()
      $exemptionDirectory1 = Join-Path -Path $WikiDirectory -ChildPath $exemptionDirName.tolower()
      $exemptionDirectory2 = Join-Path -Path $WikiDirectory -ChildPath $exemptionDirName.toupper()
      $initiativeDirectory1 = Join-Path -Path $WikiDirectory -ChildPath $initiativeDirName.tolower()
      $initiativeDirectory2 = Join-Path -Path $WikiDirectory -ChildPath $initiativeDirName.toupper()
      $subscriptionDirectory1 = Join-Path -Path $WikiDirectory -ChildPath $subscriptionDirName.tolower()
      $subscriptionDirectory2 = Join-Path -Path $WikiDirectory -ChildPath $subscriptionDirName.toupper()
      $securityControlDirectory1 = join-path $WikiDirectory -ChildPath $securityControlDirName.tolower()
      $securityControlDirectory2 = join-path $WikiDirectory -ChildPath $securityControlDirName.toupper()
      $analysisDirectory1 = join-path $wikiDirectory -ChildPath $analysisDirName.tolower()
      $analysisDirectory2 = join-path $wikiDirectory -ChildPath $analysisDirName.toupper()

      if ($rootLevelMarkdownFiles.Count -gt 0) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing top level wiki files from '$WikiDirectory'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        foreach ($f in $rootLevelMarkdownFiles) {
          #Write-Verbose "  - '$($f.Name)'"  -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
          Remove-Item -path $f.FullName -Force
        }

      } else {
        Write-Verbose "No existing top level wiki files found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }
      #Remove assignments dir
      if (test-path $assignmentDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing assignments directory '$assignmentDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $assignmentDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing assignments directory '$assignmentDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $assignmentDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing assignments directory '$assignmentDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $assignmentDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing assignments directory '$assignmentDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      #Remove definitions dir
      if (test-path $definitionDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing definitions directory '$definitionDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $definitionDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing definitions directory '$definitionDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $definitionDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing definitions directory '$definitionDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $definitionDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing definitions directory '$definitionDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      #Remove exemptions dir
      if (test-path $exemptionDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing exemptions directory '$exemptionDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $exemptionDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing exemptions directory '$exemptionDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $exemptionDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing exemptions directory '$exemptionDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $exemptionDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing exemptions directory '$exemptionDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      #Remove initiatives dir
      if (test-path $initiativeDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing initiatives directory '$initiativeDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $initiativeDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing initiatives directory '$initiativeDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $initiativeDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing initiatives directory '$initiativeDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $initiativeDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing initiatives directory '$initiativeDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      #Remove subscriptions dir
      if (test-path $subscriptionDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing subscriptions directory '$subscriptionDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $subscriptionDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing subscriptions directory '$subscriptionDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $subscriptionDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing subscriptions directory '$subscriptionDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $subscriptionDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing subscriptions directory '$subscriptionDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      #Remove security control dir
      if (test-path $securityControlDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing security control directory '$securityControlDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $securityControlDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing security control directory '$securityControlDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $securityControlDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing security control directory '$securityControlDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $securityControlDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing security control directory '$securityControlDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      #Remove analysis dir
      if (test-path $analysisDirectory1) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing analysis directory '$analysisDirectory1'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $analysisDirectory1 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing analysis directory '$analysisDirectory1' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }

      if (test-path $analysisDirectory2) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing existing analysis directory '$analysisDirectory2'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Remove-Item -Path $analysisDirectory2 -Recurse -Force
      } else {
        Write-Verbose "[$(getCurrentUTCString)]: No existing analysis directory '$analysisDirectory2' found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      }
    } else {
      Write-Error "[$(getCurrentUTCString)]: Wiki directory '$WikiDirectory' does not exist."
      exit 1
    }
  }
}

# 02. function to format exemption expiresOn date for Markdown table rows
# color code:
# - green for future dates that's more than x number of days away
# - orange for future dates that's less than x number of days away
# - red for past dates
function FormatExemptionExpiresOn {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [string]$InputString,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle,

    [Parameter(Mandatory = $true)]
    [int]$warningDays
  )
  $green = '#008000'
  $orange = '#FFA500'
  $red = '#FF0000'
  $dateTimeFormat = 'yyyy-MM-dd HH:mm:ss'
  if ($WikiStyle -ieq 'ado') {
    if ([string]::IsNullOrEmpty($InputString)) {
      # never expires, return "Never" with green color
      $spanOpenBracket = "<span style=`"color:{0}`">" -f $green
      $return = "{0}Never</span>" -f $spanOpenBracket
    } else {
      try {
        $date = $(Get-Date $InputString).ToUniversalTime()
        $currentDate = [DateTime]::UtcNow
        $daysDifference = ($date - $currentDate).Days
        if ($daysDifference -gt $warningDays) {
          # More than $warningDays days away, green
          $spanOpenBracket = "<span style=`"color:{0}`">" -f $green
        } elseif ($daysDifference -ge 0) {
          # Less than $warningDays days away, orange
          $spanOpenBracket = "<span style=`"color:{0}`">" -f $orange
        } else {
          # Past date, red
          $spanOpenBracket = "<span style=`"color:{0}`">" -f $red
        }
        $return = "{0}{1:$dateTimeFormat}</span>" -f $spanOpenBracket, $date
      } catch {
        Write-Warning "[$(getCurrentUTCString)]: Invalid date format '$InputString'. Returning as is."
        $return = $InputString
      }
    }
  } else {
    if ([string]::IsNullOrEmpty($InputString)) {
      $return = '$${\color{green}Never}$$'
    } else {
      try {
        $date = $(Get-Date $InputString).ToUniversalTime()
        $currentDate = [DateTime]::UtcNow
        $daysDifference = ($date - $currentDate).Days
        $strExpiryDate = $date.ToString($dateTimeFormat).replace(" ", " \space ")
        if ($daysDifference -gt $warningDays) {
          # More than $warningDays days away, green
          $colorCodedDate = "`$\color{$green}{\textsf " + $strExpiryDate + '}$'
        } elseif ($daysDifference -ge 0) {
          # Less than $warningDays days away, orange
          $colorCodedDate = "`$\color{$orange}{\textsf " + $strExpiryDate + '}$'
        } else {
          # Past date, red
          $colorCodedDate = "`$\color{$red}{\textsf " + $strExpiryDate + '}$'
        }
        $return = $colorCodedDate
      } catch {
        Write-Warning "[$(getCurrentUTCString)]: Invalid date format '$InputString'. Returning as is."
        $return = $InputString
      }
    }
  }
  $return
}

# 03. function to format compliance rate for Markdown table rows
#color code:
# - green for 100%
# - orange for between warning threshold and 100%
# - red for below warning threshold
function FormatComplianceRate {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(0, 100)]
    [double]$rate,

    [Parameter(Mandatory = $true)]
    [AllowEmptyString()]
    [string]$InputString,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle,

    [parameter(Mandatory = $true, HelpMessage = 'Format".')]
    [ValidateSet('Markdown', 'html')]
    [string]$Format,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 99)]
    [int]$WarningPercentageThreshold
  )
  $green = '#008000'
  $orange = '#FFA500'
  $red = '#FF0000'
  if ($WikiStyle -ieq 'ado') {
    try {
      if ($rate -eq 100) {
        # 100%
        $spanOpenBracket = "<span style=`"color:{0}`">" -f $green
      } elseif ($rate -ge $WarningPercentageThreshold -and $rate -lt 100) {
        # between warning threshold and 100%
        $spanOpenBracket = "<span style=`"color:{0}`">" -f $orange
      } else {
        # below warning threshold
        $spanOpenBracket = "<span style=`"color:{0}`">" -f $red
      }
      $return = "{0}{1}</span>" -f $spanOpenBracket, $InputString
    } catch {
      Write-Warning "[$(getCurrentUTCString)]: Invalid rate '$rate'. Returning as is."
      $return = $InputString
    }
  } else {
    try {

      $strRate = $InputString.replace(" ", " \space ")
      if ($format -ieq 'html') {
        $strRate = $strRate.replace("%", "\% ")
      } else {
        $strRate = $strRate.replace("%", "\\% ")
      }

      if ($rate -eq 100) {
        # 100%
        $colorCodedRate = "`$\color{$green}{\textsf " + $strRate + '}$'
      } elseif ($rate -ge $WarningPercentageThreshold -and $rate -lt 100) {
        # between warning threshold and 100%
        $colorCodedRate = "`$\color{$orange}{\textsf " + $strRate + '}$'
      } else {
        # below warning threshold
        $colorCodedRate = "`$\color{$red}{\textsf " + $strRate + '}$'
      }
      $return = $colorCodedRate
    } catch {
      Write-Warning "[$(getCurrentUTCString)]: Invalid rate '$rate'. Returning as is."
      $return = $InputString
    }
  }
  $return
}

# 04.function to calculate compliance rating for a policy definition group
function getComplianceRatingSummaryForPolicyDefinitionGroup {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, ParameterSetName = 'overallByMetadataId')]
    [ValidateNotNullOrEmpty()]
    [string]
    $policyMetadataId,

    [parameter(Mandatory = $true, ParameterSetName = 'overallByName')]
    [parameter(Mandatory = $true, ParameterSetName = 'byInitiativeMemberDefinition')]
    [ValidateNotNullOrEmpty()]
    [string]
    $policyDefinitionGroupName,

    [parameter(Mandatory = $true, ParameterSetName = 'byInitiativeMemberDefinition')]
    [ValidateNotNullOrEmpty()]
    [string]
    $policyInitiativeId,

    [parameter(Mandatory = $true, ParameterSetName = 'byInitiativeMemberDefinition')]
    [ValidateNotNullOrEmpty()]
    [string]
    $policyDefinitionReferenceId,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style.')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )

  # Build compliance lookup indexes lazily on first use (O(n) once, then O(1) per lookup)
  if (-not $EnvironmentDiscoveryData._complianceIndexesBuilt) {
    $EnvironmentDiscoveryData._assignmentIdsByDefId = @{}
    $assignmentToInitiativeId = @{}
    foreach ($a in $EnvironmentDiscoveryData.assignments) {
      $aKey = $a.properties.policyDefinitionId.ToLower()
      if (-not $EnvironmentDiscoveryData._assignmentIdsByDefId[$aKey]) {
        $EnvironmentDiscoveryData._assignmentIdsByDefId[$aKey] = [System.Collections.Generic.List[string]]::new()
      }
      $EnvironmentDiscoveryData._assignmentIdsByDefId[$aKey].Add($a.id)
      $assignmentToInitiativeId[$a.id.ToLower()] = $a.properties.policyDefinitionId
    }
    # Map (initiativeId|groupName) -> additionalMetadataId so we can resolve a record's
    # policyMetadataId at index-build time even if discovery didn't populate it.
    $initiativeGroupMetadataId = @{}
    foreach ($init in $EnvironmentDiscoveryData.initiatives) {
      if ($init.properties.policyDefinitionGroups) {
        foreach ($pdg in $init.properties.policyDefinitionGroups) {
          if ($pdg.additionalMetadataId) {
            $gKey = "$($init.id)|$($pdg.name)".ToLower()
            $initiativeGroupMetadataId[$gKey] = $pdg.additionalMetadataId
          }
        }
      }
    }
    $EnvironmentDiscoveryData._complianceByMetadataId = @{}
    $EnvironmentDiscoveryData._complianceByGroupName = @{}
    $EnvironmentDiscoveryData._complianceByGroupRef = @{}
    foreach ($c in $EnvironmentDiscoveryData.complianceSummaryByPolicyDefinitionGroup) {
      $resolvedMetadataId = $c.policyMetadataId
      if (-not $resolvedMetadataId -and $c.policyAssignmentId -and $c.policyDefinitionGroupName) {
        $initiativeId = $assignmentToInitiativeId[$c.policyAssignmentId.ToLower()]
        if ($initiativeId) {
          $gKey = "$initiativeId|$($c.policyDefinitionGroupName)".ToLower()
          $resolvedMetadataId = $initiativeGroupMetadataId[$gKey]
        }
      }
      if ($resolvedMetadataId) {
        $metaKey = $resolvedMetadataId.ToLower()
        if (-not $EnvironmentDiscoveryData._complianceByMetadataId[$metaKey]) {
          $EnvironmentDiscoveryData._complianceByMetadataId[$metaKey] = [System.Collections.Generic.List[object]]::new()
        }
        $EnvironmentDiscoveryData._complianceByMetadataId[$metaKey].Add($c)
      }
      $groupKey = $c.policyDefinitionGroupName.ToLower()
      if (-not $EnvironmentDiscoveryData._complianceByGroupName[$groupKey]) {
        $EnvironmentDiscoveryData._complianceByGroupName[$groupKey] = [System.Collections.Generic.List[object]]::new()
      }
      $EnvironmentDiscoveryData._complianceByGroupName[$groupKey].Add($c)
      $grpRefKey = "$($c.policyDefinitionGroupName)|$($c.policyDefinitionReferenceId)".ToLower()
      if (-not $EnvironmentDiscoveryData._complianceByGroupRef[$grpRefKey]) {
        $EnvironmentDiscoveryData._complianceByGroupRef[$grpRefKey] = [System.Collections.Generic.List[object]]::new()
      }
      $EnvironmentDiscoveryData._complianceByGroupRef[$grpRefKey].Add($c)
    }
    $EnvironmentDiscoveryData._complianceIndexesBuilt = $true
  }

  if ($PSCmdlet.ParameterSetName -eq 'byInitiativeMemberDefinition') {
    # Use indexed lookups instead of linear scans
    $assignmentIdList = $EnvironmentDiscoveryData._assignmentIdsByDefId[$policyInitiativeId.ToLower()]
    if ($assignmentIdList -and $assignmentIdList.Count -gt 0) {
      $assignmentIdSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
      foreach ($aid in $assignmentIdList) { [void]$assignmentIdSet.Add($aid) }
      $grpRefKey = "$policyDefinitionGroupName|$policyDefinitionReferenceId".ToLower()
      $candidates = $EnvironmentDiscoveryData._complianceByGroupRef[$grpRefKey]
      if ($candidates) {
        $complianceData = $candidates | Where-Object { $assignmentIdSet.Contains($_.policyAssignmentId) }
      } else {
        $complianceData = @()
      }
    } else {
      $complianceData = @()
    }
  } elseif ($PSCmdlet.ParameterSetName -eq 'overallByName') {
    $complianceData = $EnvironmentDiscoveryData._complianceByGroupName[$policyDefinitionGroupName.ToLower()]
  } else {
    $complianceData = $EnvironmentDiscoveryData._complianceByMetadataId[$policyMetadataId.ToLower()]
  }
  $compliantCount = 0
  $nonCompliantCount = 0
  $exemptCount = 0
  $conflictCount = 0
  #aggregate all policies with the same policy definition group name
  foreach ($c in $complianceData) {
    $compliantCount = $compliantCount + $c.compliantCount
    $nonCompliantCount = $nonCompliantCount + $c.nonCompliantCount
    $exemptCount = $exemptCount + $c.exemptCount
    $conflictCount = $conflictCount + $c.conflictCount
  }

  $compliancePercentage = getCompliancePercentage -CompliantCount $compliantCount -NonCompliantCount $nonCompliantCount -ExemptCount $exemptCount -ConflictCount $conflictCount -NumberOfFractionalDigits 0
  $totalCompliantCount = $compliantCount + $exemptCount
  $totalCount = $compliantCount + $nonCompliantCount + $exemptCount + $conflictCount
  $complianceRateString = "{0}% ({1} out of {2})" -f $compliancePercentage, $totalCompliantCount, $totalCount

  $complianceRateParams = @{
    rate                       = $compliancePercentage
    InputString                = $complianceRateString
    WarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    WikiStyle                  = $WikiStyle
    Format                     = 'Markdown'
  }
  $complianceRateSummary = FormatComplianceRate @complianceRateParams
  $complianceRate = @{
    compliant            = $compliantCount
    nonCompliant         = $nonCompliantCount
    conflict             = $conflictCount
    exempt               = $exemptCount
    total                = $totalCount
    compliancePercentage = $compliancePercentage
    summary              = $complianceRateSummary
  }
  $complianceRate
}

# 05.function to determine if a exemption is applicable to a subscription
function isExemptionApplicableToSubscription {
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = 'The exemption to check.')]
    [PSCustomObject]$exemption,

    [Parameter(Mandatory = $true, HelpMessage = 'The subscription ID to check against.')]
    [string]$subscriptionId,

    [Parameter(Mandatory = $true, HelpMessage = 'The subscription ancestor management groups.')]
    [string[]]$ancestorManagementGroupNames
  )
  $mgIdRegex = '(?im)^\/providers\/microsoft\.management\/managementgroups\/'
  $bIsApplicable = $false
  if ($exemption.id -match $mgIdRegex) {
    # If the exemption is at a management group level, check if any ancestor matches
    $mgName = $exemption.id -replace '(?im)^\/providers\/microsoft\.management\/managementgroups\/([a-zA-Z0-9][a-zA-Z0-9\-_.()]*[a-zA-Z0-9\-_()])\/\S+', '$1'
    if ($ancestorManagementGroupNames -icontains $mgName) {
      $bIsApplicable = $true
    }
  } elseif ($exemption.id -imatch "(?im)^/subscriptions/$($subscriptionId.ToLower())") {
    $bIsApplicable = $true
  }
  $bIsApplicable
}

# 06. function filter discovery data for a subset of Subscriptions
function filterDiscoveryData {
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = 'The Discovered environment details.')]
    [hashtable]$environmentDetails,

    [Parameter(Mandatory = $true, ParameterSetName = 'FilterBySubscription', HelpMessage = 'The list of subscriptions to include in the filtered data.')]
    [string[]]$subscriptionIds,

    [Parameter(Mandatory = $true, ParameterSetName = 'FilterByManagementGroup', HelpMessage = 'The Id of a child management group to filter the data for.')]
    [ValidateNotNullOrEmpty()]
    [string]$childManagementGroupId
  )
  $filteredAssignments = @()
  $filteredInitiatives = @()
  $filteredDefinitions = @()
  $filteredExemptions = @()
  $filteredRoleAssignments = @()
  $filteredRoleDefinitions = @()
  $filteredPolicyMetadata = @()
  $filteredSubscriptionComplianceSummary = @()
  $filteredAssignmentCompliance = @()
  $filteredComplianceSummaryByPolicyDefinitionGroup = @()
  $filteredInitiativeIds = @()
  $filteredDefinitionIds = @()
  $filteredRoleDefinitionIds = @()
  $filteredPolicyMetadataIds = @()
  $ancestorMGNames = @()

  $subscriptionResourceIdRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
  $initiativeResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policysetdefinitions\/'
  $definitionResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policydefinitions\/'
  # Filter subscriptions based on provided IDs
  if ($PScmdlet.ParameterSetName -eq 'FilterBySubscription') {
    $filteredSubscriptions = $environmentDetails.subscriptions | Where-Object { $subscriptionIds -contains $_.subscriptionId }
    $filteredSubscriptionResourceIds = $filteredSubscriptions | ForEach-Object { $_.id.tolower() }
    Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredSubscriptions.Count) subscriptions matching the provided IDs." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    # get management group ancestors for each subscription
    foreach ($sub in $filteredSubscriptions) {
      $ancestorMGNames += $sub.managementGroupAncestorsChain.name
    }
    $ancestorMGNames = $ancestorMGNames | Sort-Object -Unique
    if ($filteredSubscriptions.Count -eq 0) {
      Write-Warning "No subscriptions found matching the provided IDs."
      return $null
    }
    #filter management groups to include only those that are ancestors of the filtered subscriptions
    $filteredManagementGroups = $environmentDetails.managementGroups | Where-Object { $ancestorMGNames -contains $_.name }

    Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredManagementGroups.Count) management groups matching the ancestor names of the filtered subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  } else {
    #filter management groups to include only the specified child management group and its descendants
    $childManagementGroup = $environmentDetails.managementGroups | Where-Object { $_.name -ieq $childManagementGroupId }
    $filteredManagementGroups = $environmentDetails.managementGroups | where-object { $_.name -ieq $childManagementGroupId -or $_.ancestors -icontains $childManagementGroupId -or $childManagementGroup.ancestors -icontains $_.name }
    if ($filteredManagementGroups.Count -eq 0) {
      Write-Warning "No management groups found matching the specified child management group ID or its descendants."
      return $null
    }
    Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredManagementGroups.Count) management groups matching the specified child management group and its descendants." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $filteredSubscriptions = $environmentDetails.subscriptions | Where-Object { $_.managementGroupAncestorsChain.name -icontains $childManagementGroupId }
  }
  $filteredManagementGroupIds = $filteredManagementGroups | ForEach-Object { $_.id.tolower() }

  #filter policy assignments to include only those that are assigned to the filtered subscriptions or filtered management groups

  foreach ($policyAssignment in $environmentDetails.assignments) {
    $scope = $policyAssignment.properties.scope.tolower()
    #mg level assignment
    if ($filteredManagementGroupIds -contains $scope) {
      $filteredAssignments += $policyAssignment
    } elseif ($policyAssignment.properties.scope -match $subscriptionResourceIdRegex) {
      #subscription level assignment
      foreach ($id in $filteredSubscriptionResourceIds) {
        if ($scope -imatch "^$id") {
          $filteredAssignments += $policyAssignment
        }
      }
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredAssignments.Count) policy assignments applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  #Get the role assignments for the filtered assignments
  $principalIds = @()
  foreach ($policyAssignment in $filteredAssignments) {
    $managedIdentityPrincipalIds = getPolicyAssignmentManagedIdentityPrincipalIds -assignments $policyAssignment
    if ($managedIdentityPrincipalIds.systemAssignedPrincipalId) {
      $principalIds += $managedIdentityPrincipalIds.systemAssignedPrincipalId
    }
    if ($managedIdentityPrincipalIds.userAssignedIdentities) {
      foreach ($usmi in $managedIdentityPrincipalIds.userAssignedIdentities) {
        $principalIds += $usmi.principalId
      }
    }
  }
  #dedup the principal Ids
  $principalIds = $principalIds | Sort-Object -Unique
  #get role assignments
  foreach ($principalId in $principalIds) {
    $roleAssignments = $environmentDetails.roleAssignments | Where-Object { $_.principalId -eq $principalId }
    if ($roleAssignments) {
      $filteredRoleAssignments += $roleAssignments
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredRoleAssignments.Count) role assignments for the policy assignments applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  #get role definitions
  foreach ($ra in $filteredRoleAssignments) {
    $filteredRoleDefinitionIds += $ra.roleDefinitionId.tolower()
  }
  #dedup the role definition Ids
  $filteredRoleDefinitionIds = $filteredRoleDefinitionIds | Sort-Object -Unique
  foreach ($roleDefinitionId in $filteredRoleDefinitionIds) {
    $roleDefinition = $environmentDetails.roleDefinitions | Where-Object { $_.id.tolower() -eq $roleDefinitionId }
    if ($roleDefinition) {
      $filteredRoleDefinitions += $roleDefinition
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredRoleDefinitions.Count) role definitions for the role assignments applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  #Get filtered policy initiatives and definitions
  foreach ($policyAssignment in $filteredAssignments) {
    if ($policyAssignment.properties.policyDefinitionId -match $initiativeResourceIdRegex) {
      # Initiative assignment
      $filteredInitiativeIds += $policyAssignment.properties.policyDefinitionId.tolower()
    } elseif ($policyAssignment.properties.policyDefinitionId -match $definitionResourceIdRegex) {
      # Definition assignment
      $filteredDefinitionIds += $policyAssignment.properties.policyDefinitionId.tolower()
    }
  }
  #dedup the initiative resource Ids
  $filteredInitiativeIds = $filteredInitiativeIds | Sort-Object -Unique

  #get the initiatives from the IDs
  foreach ($initiativeId in $filteredInitiativeIds) {
    $initiative = $environmentDetails.initiatives | Where-Object { $_.id.tolower() -eq $initiativeId }
    if ($initiative) {
      $filteredInitiatives += $initiative
      foreach ($policyDefinitionGroup in $initiative.properties.policyDefinitionGroups) {
        if ($policyDefinitionGroup.additionalMetadataId) {
          $filteredPolicyMetadataIds += $policyDefinitionGroup.additionalMetadataId.tolower()
        }
      }
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredInitiatives.Count) policy initiatives applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  #dedup policy metadata Ids
  $filteredPolicyMetadataIds = $filteredPolicyMetadataIds | Sort-Object -Unique
  #get policy metadata from the IDs
  foreach ($policyMetadataId in $filteredPolicyMetadataIds) {
    $policyMetadata = $environmentDetails.policyMetadata | Where-Object { $_.id.tolower() -eq $policyMetadataId }
    if ($policyMetadata) {
      $filteredPolicyMetadata += $policyMetadata
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredPolicyMetadata.Count) security control applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  #get policy metadata from the IDs

  #get definitions from initiatives
  foreach ($initiative in $filteredInitiatives) {
    foreach ($definition in $initiative.properties.policyDefinitions) {
      $filteredDefinitionIds += $definition.policyDefinitionId.tolower()
    }
  }
  #dedup the definition resource Ids
  $filteredDefinitionIds = $filteredDefinitionIds | Sort-Object -Unique
  #get the definitions from the IDs
  foreach ($definitionId in $filteredDefinitionIds) {
    $definition = $environmentDetails.definitions | Where-Object { $_.id.tolower() -eq $definitionId }
    if ($definition) {
      $filteredDefinitions += $definition
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredDefinitions.Count) policy definitions applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  # get the exemptions applicable to the subscriptions
  foreach ($sub in $filteredSubscriptions) {
    $ancestorMGNames = $sub.managementGroupAncestorsChain.name
    foreach ($exemption in $environmentDetails.exemptions) {
      if (isExemptionApplicableToSubscription -exemption $exemption -subscriptionId $sub.subscriptionId -ancestorManagementGroupNames $ancestorMGNames) {
        $filteredExemptions += $exemption
      }
    }
  }
  if ($filteredExemptions.Count -ge 2) {
    #dedup the exemptions
    $filteredExemptions = $filteredExemptions | Sort-Object -Property id
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($filteredExemptions.Count) policy exemptions applicable to the subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  #get subscription compliance summary
  foreach ($sub in $filteredSubscriptions) {
    $subComplianceSummary = $environmentDetails.subscriptionComplianceSummary | Where-Object { $_.subscriptionId -eq $sub.subscriptionId }
    if ($subComplianceSummary) {
      $filteredSubscriptionComplianceSummary += $subComplianceSummary
    }
  }

  #get assignment compliance data
  foreach ($sub in $filteredSubscriptions) {
    $subAssignmentCompliance = $environmentDetails.assignmentCompliance | Where-Object { $_.subscriptionId -eq $sub.subscriptionId }
    if ($subAssignmentCompliance) {
      $filteredAssignmentCompliance += $subAssignmentCompliance
    }
  }

  #get compliance summary by policy definition group
  foreach ($sub in $filteredSubscriptions) {
    $subComplianceSummaryByPolicyDefinitionGroup = $environmentDetails.complianceSummaryByPolicyDefinitionGroup | Where-Object { $_.subscriptionId -eq $sub.subscriptionId }
    if ($subComplianceSummaryByPolicyDefinitionGroup) {
      $filteredComplianceSummaryByPolicyDefinitionGroup += $subComplianceSummaryByPolicyDefinitionGroup
    }
  }

  # Create a new hashtable with filtered subscriptions
  $filteredData = @{
    timeStamp                                     = $environmentDetails.timeStamp
    subscriptions                                 = $filteredSubscriptions
    managementGroups                              = $filteredManagementGroups
    topLevelManagementGroupName                   = $EnvironmentDetails.topLevelManagementGroupName
    assignments                                   = $filteredAssignments
    initiatives                                   = $filteredInitiatives
    definitions                                   = $filteredDefinitions
    exemptions                                    = $filteredExemptions
    subscriptionComplianceSummary                 = $filteredSubscriptionComplianceSummary
    roleAssignments                               = $filteredRoleAssignments
    roleDefinitions                               = $filteredRoleDefinitions
    policyMetadata                                = $filteredPolicyMetadata
    builtInDefinitionInUnAssignedCustomInitiative = $environmentDetails.builtInDefinitionInUnAssignedCustomInitiative
    additionalBuiltInPolicyMetadataConfig         = $EnvironmentDetails.additionalBuiltInPolicyMetadataConfig
    assignmentCompliance                          = $filteredAssignmentCompliance
    complianceSummaryByPolicyDefinitionGroup      = $filteredComplianceSummaryByPolicyDefinitionGroup
  }

  return $filteredData
}

# 07. function to build policy compliance summary Markdown
function buildComplianceSummaryMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $false, HelpMessage = 'Markdown header.')]
    [ValidateNotNullOrEmpty()]
    [string]$header,

    [parameter(Mandatory = $false, HelpMessage = 'Markdown header level.')]
    [ValidateRange(1, 3)]
    [int]$headerLevel = 2,

    [parameter(Mandatory = $false, HelpMessage = 'Markdown header case style.')]
    [ValidateSet('UpperCase', 'TitleCase', 'LowerCase', 'Original')]
    [string]$headerCaseStyle = 'UpperCase',

    [parameter(Mandatory = $true, HelpMessage = 'description text under the header.')]
    [ValidateNotNullOrEmpty()]
    [string]$description,

    [parameter(Mandatory = $true, HelpMessage = 'Diagram title.')]
    [ValidateNotNullOrEmpty()]
    [string]$diagramTitle,

    [parameter(Mandatory = $true, HelpMessage = 'The count for the compliant resources (either compliant or exempted).')]
    [int]$compliantCount,

    [parameter(Mandatory = $true, HelpMessage = 'The count for the non-compliant resources.')]
    [int]$nonCompliantCount,

    [parameter(Mandatory = $true, HelpMessage = 'The count for the conflict resources.')]
    [int]$conflictCount,

    [parameter(Mandatory = $true, HelpMessage = 'The count for the exempted resources.')]
    [int]$exemptCount,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style.')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )

  $totalCount = $compliantCount + $nonCompliantCount + $conflictCount + $exemptCount
  $totalCompliantCount = $compliantCount + $exemptCount
  $compliancePercentageParams = @{
    CompliantCount           = $compliantCount
    NonCompliantCount        = $nonCompliantCount
    ExemptCount              = $exemptCount
    ConflictCount            = $conflictCount
    NumberOfFractionalDigits = 0
  }
  $compliancePercentage = getCompliancePercentage @compliancePercentageParams
  $complianceRateString = "{0}% ({1} out of {2})" -f $compliancePercentage, $totalCompliantCount, $totalCount
  $complianceRateParams = @{
    rate                       = $compliancePercentage
    InputString                = $complianceRateString
    WarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    WikiStyle                  = $WikiStyle
    Format                     = 'Markdown'
  }
  $complianceRate = FormatComplianceRate @complianceRateParams
  $complianceSummaryData = [ordered]@{
    compliant        = $compliantCount
    nonCompliant     = $nonCompliantCount
    conflict         = $conflictCount
    exempt           = $exemptCount
    complianceRating = $complianceRate
  }
  $Markdown = ""
  if ($PSBoundParameters.ContainsKey('header')) {
    $Markdown += $(newMarkdownHeader -title $header -level $headerLevel -caseStyle $headerCaseStyle)
    $Markdown += "`n`n"
  }
  $Markdown += $description
  $Markdown += "`n`n"
  $Markdown += "$(buildComplianceRatingMermaidDiagram -title $diagramTitle -compliantCount $totalCompliantCount -totalCount $totalCount -WikiStyle $WikiStyle)"
  $Markdown += "`n`n"
  $Markdown += $(newMarkdownTable -data $complianceSummaryData -Orientation Horizontal -Alignment 'Center')
  $Markdown += "`n`n"
  $Markdown += $(buildComplianceRatingMarkdown -WikiStyle $WikiStyle -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold)
  $Markdown
}

# 08. function to build mermaid diagram for management group hierarchy
function buildMgHierarchyMermaidDiagram {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The Discovered environment details.')]
    [hashtable]$EnvironmentDetails,

    [parameter(Mandatory = $false, HelpMessage = 'If the diagram should include subscriptions.')]
    [boolean]$IncludeSubscriptions = $true,

    [parameter(Mandatory = $false, HelpMessage = 'Diagram version, either for the main page or the subscription page.')]
    [ValidateSet('mainPage', 'subscriptionPage')]
    [string]$DiagramVersion = 'mainPage',

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  #If total subscription count in scope is greater than this number, they will be represented as a single node with the count, instead of individual nodes, in the diagram to avoid overwhelming the diagram with too many nodes and connections.
  $maxSubscriptionCountForInclusion = 30
  # Get management group hierarchy
  $WikiStyle = $WikiFileMapping.WikiStyle
  $mgHierarchy = $EnvironmentDetails.managementGroups
  if ($mgHierarchy.Count -eq 0) {
    Write-Warning "No management group hierarchy found for '$TopLevelManagementGroupName'"
    return $null
  }

  $topLevelMg = $mgHierarchy | Where-Object { $_.name -ieq $EnvironmentDetails.topLevelManagementGroupName }
  if (-not $topLevelMg) {
    Write-Warning "Top level management group '$TopLevelManagementGroupName' not found in the hierarchy."
    return $null
  }

  Write-Verbose "[$(getCurrentUTCString)]: Found $($mgHierarchy.Count) management groups in the hierarchy." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  # mermaid identifier
  if ($WikiStyle -eq 'ado') {
    $mermaidIdentifier = ':::mermaid'
    $mermaidClosingIdentifier = ':::'
  } else {
    $mermaidIdentifier = '```mermaid'
    $mermaidClosingIdentifier = '```'
  }
  # Start building Mermaid diagram
  $diagram = $mermaidIdentifier
  $diagram += "`n"
  $diagram += "flowchart LR`n"
  $diagram += "linkStyle default interpolate stepAfter`n"
  $diagram += "classDef subscription fill:#d9f7be,stroke:#389e0d`n"
  $diagram += "classDef managementGroup fill:#bae7ff,stroke:#1890ff"


  # Add management group nodes
  foreach ($mg in $mgHierarchy) {
    $mgId = "mg_$($mg.name.toupper() -replace '-', '_')"
    $diagram += "`n    $mgId[`"$($mg.DisplayName)`"]"
    $diagram += "`n    class $mgId managementGroup"
  }

  # Add connections between management groups
  foreach ($mg in $mgHierarchy) {
    if ($mg.parentName -and $mg.name -ine $topLevelMg.name) {
      $childId = "mg_$($mg.name.toupper() -replace '-', '_')"
      $parentId = "mg_$($mg.parentName.toupper() -replace '-', '_')"
      $diagram += "`n    $parentId --> $childId"
    }
  }

  # Add subscriptions if requested
  if ($IncludeSubscriptions) {
    Write-Verbose "[$(getCurrentUTCString)]: Including subscriptions in the diagram" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    # Get subscriptions under each management group
    $subs = $EnvironmentDetails.subscriptions
    if ($subs.Count -gt 0) {
      Write-Verbose "[$(getCurrentUTCString)]: Found $($subs.Count) subscriptions in scope" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      if ($subs.Count -gt $maxSubscriptionCountForInclusion) {
        # If subscription count exceeds the threshold, group by parent management group and represent as count nodes
        $subsByParentMg = $subs | Group-Object -Property parentMgName
        foreach ($group in $subsByParentMg) {
          $parentMgName = $group.Name
          $subCount = $group.Count
          $mgId = "mg_$($parentMgName.toupper() -replace '-', '_')"
          $subNodeId = "sub_$($parentMgName.toupper() -replace '-', '_')"
          $diagram += "`n    $subNodeId[`"$subCount Subscriptions`"]"
          $diagram += "`n    class $subNodeId subscription"
          $diagram += "`n    $mgId --> $subNodeId"
        }
      } else {
        foreach ($sub in $subs) {
          $subId = "sub_$($sub.subscriptionId -replace '-', '_')"
          $mgId = "mg_$($sub.parentMgName.toupper() -replace '-', '_')"
          $diagram += "`n    $subId[`"$($sub.name)`"]"
          $diagram += "`n    class $subId subscription"
          $diagram += "`n    $mgId --> $subId"
        }
      }
    }
  }

  # Close the diagram
  $diagram += "`n"
  $diagram += $mermaidClosingIdentifier

  Write-Verbose "[$(getCurrentUTCString)]: Management group hierarchy diagram generated." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $diagram
}

# 09.function to build mermaid pie chart diagram for compliance status
function buildComplianceRatingMermaidDiagram {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'Diagram title.')]
    [ValidateNotNullOrEmpty()]
    [string]$title,

    [parameter(Mandatory = $true, HelpMessage = 'The count for the compliant resources (either compliant or exempted).')]
    [int]$compliantCount,

    [parameter(Mandatory = $true, HelpMessage = 'The count for the total resources.')]
    [int]$totalCount,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style.')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  $nonCompliantCount = $totalCount - $compliantCount

  # mermaid identifier
  if ($WikiStyle -eq 'ado') {
    $mermaidIdentifier = ':::mermaid'
    $mermaidClosingIdentifier = ':::'
  } else {
    $mermaidIdentifier = '```mermaid'
    $mermaidClosingIdentifier = '```'
  }
  $green = '#428000'
  $red = '#FF0000'
  # Mermaid pie maps pie1/pie2 to slices in declaration order. Always declare
  # Compliant first with pie1=green and Non-Compliant second with pie2=red so
  # the colors are deterministic regardless of slice values.
  if ($compliantCount -eq 0 -and $nonCompliantCount -eq 0) {
    #both zero - mimic the Azure portal UI (all green)
    $compliantCount = 1
  }
  $themeVars = "'pie1': '$green', 'pie2': '$red'"
  $slices = "`"Compliant`": $compliantCount`n`"Non-Compliant`": $nonCompliantCount"

  # Start building Mermaid diagram. The init directive must come before the
  # `pie` keyword so the theme variables apply.
  $diagram = $mermaidIdentifier
  $diagram += "`n"
  $diagram += "pie title $title`n"
  $diagram += "%%{init: {'theme': 'base', 'themeVariables': { $themeVars, 'pieTitleTextSize': '20px', 'pieStrokeWidth': '1px', 'pieOuterStrokeWidth': '1px', 'pieLegendTextSize': '14px'}}}%%"
  $diagram += "`n"
  $diagram += $slices
  $diagram += "`n"

  # Close the diagram
  $diagram += "`n"
  $diagram += $mermaidClosingIdentifier

  Write-Verbose "[$(getCurrentUTCString)]: Compliance rating pie chart $title generated."  -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $diagram
}

# 10.function to build policyDefinitionGroup compliance coverage Markdown
function buildPolicyDefinitionGroupComplianceCoverageMarkdown {
  [CmdletBinding()]
  [OutputType([String])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style.')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle,

    [parameter(Mandatory = $true, HelpMessage = 'Title for the compliance coverage section.')]
    [ValidateNotNullOrEmpty()]
    [string]$TitleName,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'The from path for building the link to the security control page.')]
    [string]$FromPath
  )
  $arrPolicyDefinitionGroupNamesComplianceSummary = @()
  # Markdown anchor for the title
  $titleAnchor = $TitleName.tolower() -replace '[^a-z0-9]+', '-'
  #Get all unique policy definition group names
  $assignedInitiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.isInUse -ieq 'true' }
  $policyDefinitionGroupNames = getPolicyDefinitionGroupsFromInitiatives -initiatives $assignedInitiatives
  $allFrameworks = @()
  $processedPolicyMetadataIds = @()
  foreach ($item in $policyDefinitionGroupNames) {
    #firstly get the display name and category from the policy definition group config
    $name = $item.name
    $title = $item.displayName ? $item.displayName : 'UNKNOWN'
    $category = $item.category ? $item.category : 'UNKNOWN'
    $policyMetadata = $null
    if ($item.additionalMetadataId.length -gt 0) {
      $policyMetadata = $EnvironmentDiscoveryData.policyMetadata | Where-Object { $_.id -ieq $item.additionalMetadataId } | select-object -first 1
      if ($policyMetadata) {
        $PolicyMetadataFileNameMapping = getWikiPageFileName -ResourceId $policyMetadata.id -wikiFileMapping $wikiFileMapping
        $PolicyMetadataPageFileBaseName = $PolicyMetadataFileNameMapping.FileBaseName
        $PolicyMetadataFolderPath = $PolicyMetadataFileNameMapping.FileParentDirectory
        $securityControlLink = getRelativePath -FromPath $FromPath -ToPath $(Join-Path $PolicyMetadataFolderPath $PolicyMetadataPageFileBaseName) -UseUnixPath $true
        $title = "[$($policyMetadata.properties.title)]($securityControlLink)"
        $category = $policyMetadata.properties.category
        #Write-Verbose "Looking up security framework for policy metadata '$($policyMetadata.id)'." -Verbose
        #$framework = getSecFrameworkForPolicyMetadata -mappings $EnvironmentDiscoveryData.additionalBuiltInPolicyMetadataConfig -policyMetadataId $item.additionalMetadataId
        $framework = $policyMetadata.framework
        #Write-Verbose "Security framework for policy metadata '$($policyMetadata.id)' is '$framework'." -Verbose
        if ($allFrameworks -notcontains $framework) {
          #Write-Verbose "Adding framework '$framework' to the list of all frameworks." -Verbose
          $allFrameworks += $framework.toupper()
        }
        if ($policyMetadata.properties.metadataId) {
          $name = $policyMetadata.properties.metadataId
        }
      }
    } elseif (($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig'))) {
      #no policy metadata id specified, checking custom security control files if custom control are available
      $customControl = $CustomSecurityControlFileConfig | Where-Object { $_.controlId -ieq $item.name } | select-object -first 1
      if ($customControl) {
        $customSecurityControlFileNameMapping = getWikiPageFileName -CustomSecurityControlId $customControl.controlId -SecurityControlFramework $customControl.framework -wikiFileMapping $WikiFileMapping
        $customSecurityControlPagesRelativePath = getRelativePath -FromPath $FromPath -ToPath $(Join-Path $customSecurityControlFileNameMapping.FileParentDirectory $customSecurityControlFileNameMapping.FileBaseName) -UseUnixPath $true
        $title = "[$($customControl.name)]($customSecurityControlPagesRelativePath)"
        $category = $customControl.category
        $framework = $customControl.framework
        #Write-Verbose "Security framework for custom control '$($customControl.controlId)' is '$framework'." -Verbose
        if ($allFrameworks -notcontains $framework) {
          #Write-Verbose "Adding framework '$framework' to the list of all frameworks." -Verbose
          $allFrameworks += $framework.toupper()
        }
        $name = $customControl.controlId
      }
    }
    #Get mapped policy count
    if ($policyMetadata) {
      if ($processedPolicyMetadataIds -contains $policyMetadata.id.tolower()) {
        Write-Verbose "[$(getCurrentUTCString)]: Skipping policy definition group '$($item.name)' as its policy metadata '$($policyMetadata.id)' has already been processed." -Verbose
        continue
      }
      #Write-Verbose "Looking up mapped policies for policy metadata data '$($policyMetadata.id)'." -Verbose
      $mappedDefinitions = getMappedPoliciesForPolicyDefinitionGroup -policyMetadataId $policyMetadata.id -initiatives $assignedInitiatives
      $processedPolicyMetadataIds += $policyMetadata.id.tolower()
    } else {
      #Write-Verbose "Looking up mapped policies for policy definition group '$($item.name)'." -Verbose
      $mappedDefinitions = getMappedPoliciesForPolicyDefinitionGroup -policyDefinitionGroupName $item.name -initiatives $assignedInitiatives
    }
    $policyCount = $mappedDefinitions.mappedPolicies.count
    Write-Verbose "  - Found $policyCount mapped policy from initiatives." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    #Get the unique category from policy initiative's metadata. This metadata field is normally used to indicate the Azure service that the initiative is targeting.
    $uniqueCategory = $mappedDefinitions.definedInitiatives.policySetMetadata | Where-Object { $null -ne $_.category } | Select-Object -ExpandProperty category -Unique | Sort-Object
    $uniqueCategoryList = '<ul>'
    if ($uniqueCategory.Count -eq 0) {
      $uniqueCategoryList += '<li>``N/A``</li>'
    } else {
      foreach ($uc in $uniqueCategory) {
        $uniqueCategoryList += "<li>``$uc``</li>"
      }
    }
    $uniqueCategoryList += '</ul>'
    #remove the $uniqueCategory and $uc variable in case the next policy definition group does not have any mapped policies
    Remove-Variable -Name uniqueCategory -ErrorAction SilentlyContinue
    Remove-Variable -Name uc -ErrorAction SilentlyContinue
    #skip if the policy definition group is defined but not mapped to any policies
    if ($policyCount -gt 0) {
      #aggregate all policies with the same policy definition group name
      $complianceRateParams = @{
        EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
        ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
        WikiStyle                            = $WikiStyle
      }
      if ($item.additionalMetadataId.length -gt 0) {
        $complianceRateParams.policyMetadataId = $item.additionalMetadataId
      } else {
        $complianceRateParams.policyDefinitionGroupName = $item.name
      }
      $complianceRate = getComplianceRatingSummaryForPolicyDefinitionGroup @complianceRateParams
      $arrPolicyDefinitionGroupNamesComplianceSummary += [ordered]@{
        Name                    = $name
        Title                   = $title
        Framework               = $framework
        SecurityControlCategory = $category
        PolicyCount             = $policyCount
        ComplianceRating        = $complianceRate.summary
        CompliancePercentage    = $complianceRate.compliancePercentage
        InitiativeCategories    = $uniqueCategoryList
      }
    } else {
      Write-Verbose "[$(getCurrentUTCString)]: Skipping policy definition group '$($item.name)' as it has no mapped policies." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
  }
  #generate a Markdown table for each security framework
  $Markdown = ""
  foreach ($framework in $($allFrameworks | sort-Object)) {
    $frameworkComplianceSummaryParams = @{
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      Framework                            = $framework
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      WikiStyle                            = $WikiStyle
    }
    if ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
      $frameworkComplianceSummaryParams.CustomSecurityControlFileConfig = $CustomSecurityControlFileConfig
    }
    $frameworkComplianceSummary = getComplianceRatingSummaryForFramework @frameworkComplianceSummaryParams
    $Markdown += $(newMarkdownHeader -title "$framework - Compliance Summary" -level 3 -caseStyle 'Original')
    $Markdown += "`n`n"
    $Markdown += "<details>"
    $Markdown += "`n`n"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += $frameworkComplianceSummary
    $Markdown += "`n`n"
    $filteredArr = $arrPolicyDefinitionGroupNamesComplianceSummary | Where-Object { $_.Framework.toupper() -ieq $framework.toupper() } | Sort-Object { [int]$_.CompliancePercentage }, { $_.Name }
    Write-Verbose "[$(getCurrentUTCString)]: Building compliance summary for framework '$framework' with $($filteredArr.Count) items." -Verbose
    $Markdown += newMarkdownTableFromArray -Data $filteredArr -keyFormatting @{'Name' = 'code'; 'Category' = 'code' } -Alignment 'Left' -Properties @('Name', 'Title', 'SecurityControlCategory', 'PolicyCount', 'ComplianceRating', 'InitiativeCategories')
    $Markdown += "`n`n"
    $Markdown += "[:arrow_up: Back to Top](#$titleAnchor)"
    $Markdown += "`n`n"
    $Markdown += "</details>"
    $Markdown += "`n`n"
  }
  #$Markdown += newMarkdownTableFromArray -Data $arrPolicyDefinitionGroupNamesComplianceSummary -keyFormatting @{'Name' = 'code'; 'Category' = 'code' } -Alignment 'Left'
  #$Markdown += "`n`n"
  $Markdown += ":bulb: **Compliance Rating:**`n`n"
  if ($wikiStyle -ieq 'ado') {
    $Markdown += "- <span style=`"color:#008000`">Green</span>: 100%`n"
    $Markdown += "- <span style=`"color:#FFA500`">Orange</span>: Above $ComplianceWarningPercentageThreshold%`n"
    $Markdown += "- <span style=`"color:#FF0000`">Red</span>: Below $ComplianceWarningPercentageThreshold%`n`n"
  } else {
    $Markdown += "- `$\color{green}{\textsf{Green}}`$: 100%`n"
    $Markdown += "- `$\color{orange}{\textsf{Orange}}`$: Above $ComplianceWarningPercentageThreshold%`n"
    $Markdown += "- `$\color{red}{\textsf{Red}}`$: Below $ComplianceWarningPercentageThreshold%`n`n"
  }
  $Markdown
}

# 11. function to build parameters Markdown table for policy assignment
function buildAssignmentParametersMarkdownTable {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [object]
    $Parameters
  )
  $htParameters = ConvertToOrderedHashtable -InputObject $Parameters
  $arrParameters = @()
  foreach ($param in $htParameters.Keys) {
    $parameterValue = $Parameters.$param.value
    if (!$parameterValue) {
      $parameterValue = 'null'
    }
    $arrParameters += [ordered]@{
      Name  = $param
      Value = $parameterValue
    }
  }
  if ($arrParameters.count -gt 0) {
    $markdownTable = newMarkdownTableFromArray -Data $arrParameters -keyFormatting @{'Value' = 'code' }
  } else {
    $markdownTable = "**No parameters are explicitly defined in the Policy Assignment.**"
  }

  $markdownTable
}

# 12. function to build parameters Markdown snippets for policy definitions and initiatives
function buildPolicyDefinitionParametersMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Collections.Specialized.IOrderedDictionary]
    $Definition,

    [parameter(Mandatory = $false, HelpMessage = "Specify the Casing style of the title.")]
    [ValidateSet('UpperCase', 'TitleCase', 'LowerCase', 'Original')]
    [string]$CaseStyle = 'Original',

    [parameter(Mandatory = $true, HelpMessage = "Specify the level.")]
    [ValidateSet(2, 3, 4, 5, 6)]
    [int]$Level
  )
  if ($null -eq $Definition.properties.parameters) {
    Write-Verbose "[$(getCurrentUTCString)]: No parameters found for definition '$($Definition.id)'. Skipping parameter Markdown generation." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    return ":exclamation: **No parameters are defined!**"
  }
  $Parameters = ConvertToOrderedHashtable -InputObject $Definition.properties.parameters
  $Markdown = ""

  foreach ($param in $Parameters.Keys) {
    $title = newMarkdownHeader -title $param -caseStyle $CaseStyle -level $Level
    Write-Verbose "[$(getCurrentUTCString)]: Building Markdown for parameter '$param'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $Markdown += "$title`n"
    $Markdown += "`n"
    if ($Parameters[$param].metadata.displayName) {
      $Markdown += "- **Display Name:** ``$($Parameters[$param].metadata.displayName)```n"
    }
    if ($Parameters[$param].metadata.description) {
      $Markdown += "- **Description:** ``$($Parameters[$param].metadata.description)```n"
    }
    if ($Parameters[$param].metadata.strongType) {
      $Markdown += "- **Strong Type:** ``$($Parameters[$param].metadata.strongType)```n"
    }
    if ($Parameters[$param].metadata.assignPermissions) {
      $Markdown += "- **Assigned Permissions:** ``$($Parameters[$param].metadata.assignPermissions)```n"
    }
    if ($Parameters[$param].type) {
      $Markdown += "- **Type:** ``$($Parameters[$param].type)```n"
    }
    if ($Parameters[$param].allowedValues) {
      # wrap code block `` for each allowed Value
      $allowedValues = $Parameters[$param].allowedValues | ForEach-Object { '`{0}`' -f $_ }
      $strAllowedValues = $allowedValues -join ', '
      $Markdown += "- **Allowed Values:** $strAllowedValues`n"
    }
    if ($Parameters[$param].defaultValue) {
      $Markdown += "- **Default Value:** ``$($Parameters[$param].defaultValue)```n"
    }
    $Markdown += "`n"
  }
  return $Markdown
}

# 13. Function to build policy assignment parameter mapping Markdown
function buildPolicyAssignmentParameterMappingMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $definitionParameters,

    [parameter(Mandatory = $true)]
    [System.Object]
    $assignmentParameters
  )
  $htAssignmentParameters = ConvertToOrderedHashtable -InputObject $assignmentParameters
  $htDefinitionParameters = ConvertToOrderedHashtable -InputObject $definitionParameters
  $definitionParameterNames = $htDefinitionParameters.Keys | Sort-Object
  $Markdown = @"
| Parameter ID | Parameter Name | Parameter Value | Reference Type |
| ------------ | -------------- | --------------- | -------------- |`n
"@
  Foreach ($param in $definitionParameterNames) {
    if ($htAssignmentParameters.Keys.contains($param)) {
      $value = $htAssignmentParameters.$param.value
      $referenceType = 'User defined parameter'
    } else {
      $value = $definitionParameters.$param.defaultValue
      $referenceType = 'Default value'
    }
    Write-Verbose "[$(getCurrentUTCString)]: Parameter '$param' maps to value '$value'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $Markdown += "| $param | $($definitionParameters.$param.metadata.displayName) | ``$value`` | $referenceType |`n"
  }
  $Markdown
}

# 14. Function to build policy assignment role assignment Markdown
function buildPolicyAssignmentRoleAssignmentMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
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
  # Get role assignment details
  Write-Verbose "[$(getCurrentUTCString)]: Building role assignment Markdown for Policy assignment '$($assignment.id)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $roleAssignmentDetails = getRoleAssignmentDetailsForPolicyAssignment -assignment $assignment -roleAssignments $roleAssignments -roleDefinitions $roleDefinitions
  if ($roleAssignmentDetails.Count -eq 0) {
    Write-Verbose "[$(getCurrentUTCString)]: No role assignments found for Policy assignment '$($assignment.id)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $Markdown = ":bookmark: This assignment does not have any role assignments.`n"
  } else {
    $Markdown = @"
:bookmark: The Policy Assignment has the following role assignments:

| Identity Principal Id | Identity Type | Role Display Name | Role Name | Role Type | Role Assignment Scope |
| --------------------- | ------------- | ----------------- | --------- | --------- | --------------------- |`n
"@
    foreach ($ra in $roleAssignmentDetails) {
      $principalId = $ra.principalId
      $identityType = SplitPascalCamelCaseString -InputString $ra.identityType
      $roleDisplayName = $ra.roleDefinitionDisplayName
      $roleName = $ra.roleDefinitionName
      $scope = $ra.roleAssignmentScope
      $roleType = SplitPascalCamelCaseString -InputString $ra.roleDefinitionType
      # Build the Markdown row
      $Markdown += "| $principalId | $identityType | ``$roleDisplayName`` | $roleName | ``$roleType`` | ``$scope`` |`n"
    }
    $Markdown += "`n"
  }
  $Markdown
}

# 15. Function to build policy assignment non-compliance message Markdown
function buildPolicyAssignmentNonComplianceMessageMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [AllowNull()]
    [System.Object]
    $nonComplianceMessages,

    [parameter(Mandatory = $true)]
    [array]
    $allDefinitions,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true)]
    [string]
    $assignmentOutputPath,

    [parameter(Mandatory = $true)]
    [System.Object]
    $definition
  )
  $WikiStyle = $WikiFileMapping.WikiStyle
  if ($null -eq $nonComplianceMessages -or $nonComplianceMessages.Count -eq 0) {
    Write-Verbose "[$(getCurrentUTCString)]: No non-compliance messages found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    return ":exclamation: This assignment does not have any non-compliance messages defined.`n"
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Found $($nonComplianceMessages.Count) non-compliance messages." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $defaultMessage = $nonComplianceMessages | where-object { $null -eq $_.policyDefinitionReferenceId }
    $customMessages = $nonComplianceMessages | where-object { $_.policyDefinitionReferenceId } | sort-object 'policyDefinitionReferenceId'
    if ($definition.type -ieq 'microsoft.authorization/policysetdefinitions') {
      $notes = @()
      $notes += "The **Default** non-compliance message is used when the policy assignment does not have any custom non-compliance messages defined a member policy of an assigned initiative."
      $notes += "The custom non-compliance messages are used when the policy assignment has custom messages defined for specific policy definitions within the initiative."
      $Markdown += buildQuotedAlert -type 'note' -WikiStyle $WikiStyle -contentStyle 'list' -messages $notes
      $Markdown += "| Reference ID | Policy Definition | Non-compliance message |`n"
      $Markdown += "| ------------ | ----------------- | ---------------------- |`n"
      $Markdown += "| **Default** | N/A | ````$($defaultMessage.message)```` |`n"
      foreach ($cm in $customMessages) {
        # If custom message exists, the assigned definition must be a policy initiative
        $referencedDefinitionId = ($definition.properties.policyDefinitions | where-object { $_.policyDefinitionReferenceId -ieq $cm.policyDefinitionReferenceId }).policyDefinitionId
        Write-Verbose "Referenced Definition id for $($cm.policyDefinitionReferenceId) is $referencedDefinitionId"  -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        $referencedDefinition = $allDefinitions | where-object { $_.id -ieq $referencedDefinitionId }
        if ($null -eq $referencedDefinition) {
          Write-Error "[$(getCurrentUTCString)]: Unable to find referenced definition for policy definition reference ID '$($cm.policyDefinitionReferenceId)' with resource id '$referencedDefinitionId' from discovered environment data."
          continue
        }
        $referenceDefinitionDisplayName = $referencedDefinition.properties.displayName
        $DefinitionFileNameMapping = getWikiPageFileName -ResourceId $referencedDefinitionId -wikiFileMapping $wikiFileMapping
        $definitionPageFileBaseName = $DefinitionFileNameMapping.FileBaseName
        $definitionFolderPath = $DefinitionFileNameMapping.FileParentDirectory
        $definitionLink = getRelativePath -FromPath $assignmentOutputPath -ToPath $(Join-Path $definitionFolderPath $definitionPageFileBaseName) -UseUnixPath $true

        $Markdown += "| {0} | [{1}]({2}) | ````{3}```` |`n" -f $cm.policyDefinitionReferenceId, $referenceDefinitionDisplayName, $definitionLink, $cm.message
      }

    } else {
      $Markdown = @"
The non-compliance message for assigned policy definition is defined as below:

````$($defaultMessage.message)````
"@
    }
  }
  return $Markdown
}

# 16. Function to build management group summary page Markdown section
function buildManagementGroupSummaryMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object[]]
    $managementGroups,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $false, HelpMessage = 'Assignment Compliance data for the detailed pages')]
    [array]
    $assignmentCompliance = @(),

    [parameter(Mandatory = $true)]
    [string]
    $topManagementGroupId

  )

  $MainFileMapping = getWikiPageFileName -summaryPageType 'main' -wikiFileMapping $wikiFileMapping
  #make sure the management groups are sorted by tier
  $managementGroups = $managementGroups | Sort-Object { $_.tier }
  $mgTable = @()
  $Markdown = ''
  foreach ($managementGroup in $managementGroups) {
    $mgAssignments = $assignments | Where-Object { $_.properties.scope -ieq $managementGroup.id }
    if ($managementGroup.id -ine $topManagementGroupId ) {
      if ($ManagementGroup.parentName) {
        $ParentName = $managementGroup.parentName
      }
    }
    if ($mgAssignments.count -gt 0) {
      $mgAssignmentCount = "[**{0}**](#{1})" -f $mgAssignments.count, $ManagementGroup.name.tolower()
    } else {
      $mgAssignmentCount = $mgAssignments.count
    }
    $mgTable += [ordered]@{
      Name            = $ManagementGroup.name
      DisplayName     = $ManagementGroup.displayName
      ParentName      = $ParentName
      AssignmentCount = $mgAssignmentCount
    }
  }
  $Markdown += newMarkdownTableFromArray -Data $mgTable -FormatTableHeader $true -Alignment 'Center'
  $Markdown += "`n`n"
  foreach ($managementGroup in $managementGroups) {
    Write-Verbose "[$(getCurrentUTCString)]: Building Markdown for management group '$($ManagementGroup.name)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mgAssignments = $assignments | Where-Object { $_.properties.scope -ieq $managementGroup.id }
    $mgAssignmentCount = $mgAssignments.count
    if ($mgAssignmentCount -gt 0) {
      $policyAssignmentTableParams = @{
        assignments                          = $assignments
        managementGroup                      = $managementGroup
        includeMgWithoutAssignments          = $true
        wikiFileMapping                      = $wikiFileMapping
        resourceTypeFolderPath               = $MainFileMapping.FileParentDirectory
        assignmentCompliance                 = $assignmentCompliance
        ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      }
      $Markdown += newMarkdownHeader -title $ManagementGroup.displayName -caseStyle 'UpperCase' -level 4
      $Markdown += "`n`n"
      $Markdown += buildPolicyAssignmentMarkdownTableForMg @policyAssignmentTableParams
      $Markdown += "`n"
    }
  }
  $Markdown
}

# 17. Function to build management group management group ancestor chain Markdown table
function buildSubscriptionMgAncestorChainMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object[]]
    $ancestorManagementGroups,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Object[]]
    $TopLevelManagementGroup,

    [parameter(Mandatory = $true)]
    [object]
    $subscription,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  # mermaid identifier
  if ($WikiStyle -eq 'ado') {
    $mermaidIdentifier = ':::mermaid'
    $mermaidClosingIdentifier = ':::'
  } else {
    $mermaidIdentifier = '```mermaid'
    $mermaidClosingIdentifier = '```'
  }
  # Start building Mermaid diagram
  $diagram += '<details>'
  $diagram += "`n`n"
  $diagram += '<summary>Click to expand</summary>'
  $diagram += "`n`n"
  $diagram += $mermaidIdentifier
  $diagram += "`n"
  $diagram += "flowchart TD`n"
  $diagram += 'linkStyle default interpolate stepAfter'
  $diagram += "`n"
  $diagram += 'classDef subscription fill:#d9f7be,stroke:#389e0d'
  $diagram += "`n"
  $diagram += 'classDef managementGroup fill:#bae7ff,stroke:#1890ff'
  # Add management group nodes
  foreach ($mg in $ancestorManagementGroups) {
    $mgAssignmentCount = ($assignments | Where-Object { $_.properties.scope -ieq $mg.id }).count
    $mgId = "mg_$($mg.name -replace '-', '_')"
    $diagram += "`n    $mgId[`"$($mg.displayName)`nPolicy Assignments: $mgAssignmentCount`"]"
    if ($WikiStyle -eq 'ado') {
      if ($mgAssignmentCount -gt 0) {
        $diagram += "`n    click $mgId `"./#$($mg.name.tolower())`""
      }
    }

    $diagram += "`n    class $mgId managementGroup"
  }
  # Add connections between management groups
  foreach ($mg in $ancestorManagementGroups) {
    if ($mg.parentName -and $mg.name -ine $TopLevelManagementGroup.name) {
      $childId = "mg_$($mg.name -replace '-', '_')"
      $parentId = "mg_$($mg.parentName -replace '-', '_')"
      $diagram += "`n    $parentId --> $childId"
    }
  }
  # Add subscription
  $subResourceId = $subscription.id
  $subAssignmentCount = ($assignments | Where-Object { $_.properties.scope -imatch $('{0}*' -f $subResourceId) }).count
  $subId = "sub_$($subscription.subscriptionId -replace '-', '_')"
  $mgId = "mg_$($subscription.parentMgName -replace '-', '_')"
  $diagram += "`n    $subId[`"$($subscription.name)`nPolicy Assignments: $subAssignmentCount`"]"
  $diagram += "`n    class $subId subscription"
  if ($WikiStyle -eq 'ado') {
    if ($subAssignmentCount -gt 0) {
      $diagram += "`n    click $subId `"./#subscription-scoped-policy-assignments`""
    }
  }
  $diagram += "`n    $mgId --> $subId"

  # Close the diagram
  $diagram += "`n"
  $diagram += $mermaidClosingIdentifier
  $diagram += "`n`n"
  $diagram += "</details>`n`n"
  $diagram
}
# 18. Function to build subscription summary Markdown section
function buildSubscriptionSummaryMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [Object]
    $subscription,

    [parameter(Mandatory = $true)]
    [System.Object[]]
    $managementGroups,

    [parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TopLevelManagementGroupName,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [array]
    $exemptions,

    [parameter(Mandatory = $false)]
    [AllowEmptyCollection()]
    [array]
    $assignmentCompliance,

    [parameter(Mandatory = $false)]
    [object]
    $complianceSummary,

    [parameter(Mandatory = $true)]
    [int]
    $exemptionExpiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  #no hidden tags to be shown if page style is basic
  if ($subscription.tags) {
    $tags = ConvertToOrderedHashtable -InputObject $subscription.tags
    if ($PageStyle -ieq 'basic') {
      $hiddenTagNames = $tags.Keys | Where-Object { $_ -match '^hidden-' }
      foreach ($hiddenTagName in $hiddenTagNames) {
        $tags.Remove($hiddenTagName)
      }
    }
  } else {
    $tags = [ordered]@{}
  }

  $WikiStyle = $WikiFileMapping.WikiStyle
  $topLevelManagementGroup = $managementGroups | Where-Object { $_.name -ieq $TopLevelManagementGroupName }
  $SubFileNameMapping = getWikiPageFileName -ResourceId $subscription.id -wikiFileMapping $wikiFileMapping
  $Markdown = ''
  #get all the ancestor management groups for the subscription that's under the top level management group
  $ancestorManagementGroups = getSubscriptionMgAncestors -managementGroups $managementGroups -TopLevelManagementGroup $TopLevelManagementGroup -subscription $subscription
  Write-Verbose "[$(getCurrentUTCString)]: Building Markdown for subscription '$($subscription.name)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $subData = [ordered]@{
    name                  = "<b>$($subscription.name)</b>"
    subscriptionId        = $subscription.subscriptionId
    parentManagementGroup = $subscription.parentMgName.toupper()
    quotaId               = $subscription.quotaId
    state                 = $subscription.state
  }
  $Markdown += $(newMarkdownHeader -title "subscription overview" -level 2 -caseStyle 'UpperCase')
  $Markdown += "`n`n"
  $Markdown += $(newHtmlTable -data $subData -KeyFormatting @{'subscriptionId' = 'code' } -WikiStyle $WikiFileMapping.WikiStyle)
  $Markdown += "`n`n"
  $Markdown += $(newMarkdownHeader -title "subscription tags" -level 2 -caseStyle 'UpperCase')
  $Markdown += "`n`n"
  if ($subscription.tags.count -eq 0) {
    $Markdown += ":bookmark: No tags are defined for this subscription.`n`n"
  } else {
    $Markdown += "<details>"
    $Markdown += "`n`n"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += $(newHtmlTable -data $tags -FormatTableHeader $false -FormatAllKeysAsCode -WikiStyle $WikiStyle)
    $Markdown += "`n`n"
    $Markdown += "</details>"
    $Markdown += "`n`n"
  }

  if ($complianceSummary) {
    $complianceSummaryParams = @{
      header                               = "policy compliance summary"
      description                          = ":memo: This section provides an overview of the policy compliance status for the subscription ``$($subscription.name)``."
      diagramTitle                         = "Resources Compliance State"
      compliantCount                       = $complianceSummary.compliantCount
      nonCompliantCount                    = $complianceSummary.nonCompliantCount
      conflictCount                        = $complianceSummary.conflictCount
      exemptCount                          = $complianceSummary.exemptCount
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      wikiStyle                            = $wikiStyle
    }
    $Markdown += buildComplianceSummaryMarkdown @complianceSummaryParams
  } else {
    $Markdown += $(newMarkdownHeader -title "policy compliance summary" -level 2 -caseStyle 'UpperCase')
    $Markdown += "`n`n"
    $Markdown += ":exclamation: Compliance Summary Not Available`n`n"
  }

  $Markdown += $(newMarkdownHeader -title "management group hierarchy" -level 2 -caseStyle 'UpperCase')
  $Markdown += "`n`n"
  $notes = @()
  $notes += "This diagram illustrates the location of the subscription in the Management Group hierarchy."
  $notes += "Any Azure Policy assignments created on the parent management groups and the subscription itself are applicable to the subscription."
  $Markdown += buildQuotedAlert -type 'note' -contentStyle 'list' -WikiStyle $WikiStyle -messages $notes
  $Markdown += $(buildSubscriptionMgAncestorChainMarkdown -ancestorManagementGroups $ancestorManagementGroups -subscription $subscription -TopLevelManagementGroup $topLevelManagementGroup -assignments $assignments -WikiStyle $WikiFileMapping.WikiStyle)
  $Markdown += "`n`n"
  $Markdown += $(newMarkdownHeader -title "policy assignments" -level 2 -caseStyle 'UpperCase')
  $Markdown += "`n`n"
  $Markdown += 'The following Policy Assignments are effective for the subscription:'
  $Markdown += "`n`n"
  $Markdown += "$(newMarkdownHeader -title "management group scoped policy assignments" -level 3 -caseStyle 'UpperCase')`n`n"

  # Create a table for each mg that has policy assignments
  foreach ($mg in $ancestorManagementGroups) {
    $mgAssignments = $assignments | Where-Object { $_.properties.scope -ieq $mg.id } | sort-Object name
    if ($mgAssignments.count -gt 0) {
      $Markdown += "$(newMarkdownHeader -title "$($mg.displayName)" -level 3 -caseStyle 'UpperCase')`n`n"
      $mgAssignmentsParams = @{
        managementGroup                         = $mg
        assignments                             = $assignments
        resourceTypeFolderPath                  = $SubFileNameMapping.FileParentDirectory
        includeMgWithoutAssignments             = $true
        subscriptionToCheckForAssignmentNoScope = $subscription
        wikiFileMapping                         = $wikiFileMapping
        ComplianceWarningPercentageThreshold    = $ComplianceWarningPercentageThreshold
      }
      if ($assignmentCompliance.count -gt 0) {
        $mgAssignmentsParams.add('assignmentCompliance', $assignmentCompliance)
      }
      $Markdown += buildPolicyAssignmentMarkdownTableForMg @mgAssignmentsParams
      $Markdown += "`n"
    }
  }

  $Markdown += "$(newMarkdownHeader -title "subscription scoped policy assignments" -level 3 -caseStyle 'UpperCase')`n`n"
  $subAssignmentsParams = @{
    subscription                         = $subscription
    assignments                          = $assignments
    resourceTypeFolderPath               = $SubFileNameMapping.FileParentDirectory
    includeSubWithoutAssignments         = $true
    wikiFileMapping                      = $wikiFileMapping
    ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    includeNoScope                       = $true
  }
  if ($assignmentCompliance.count -gt 0) {
    $subAssignmentsParams.add('assignmentCompliance', $assignmentCompliance)
  }
  $Markdown += buildPolicyAssignmentMarkdownTableForSub @subAssignmentsParams
  $Markdown += "`n`n"
  $Markdown += $(newMarkdownHeader -title "policy exemptions" -level 2 -caseStyle 'UpperCase')
  $Markdown += "`n`n"

  foreach ($mg in $ancestorManagementGroups) {
    $mgExemptionsParams = @{
      managementGroup            = $mg
      exemptions                 = $exemptions
      assignments                = $assignments
      resourceTypeFolderPath     = $SubFileNameMapping.FileParentDirectory
      expiresOnWarningDays       = $exemptionExpiresOnWarningDays
      includeMgWithoutExemptions = $false
      wikiFileMapping            = $wikiFileMapping
    }
    $mgExemptionMarkdown = buildPolicyExemptionMarkdownTableForMg @mgExemptionsParams
  }

  $subExemptionsParams = @{
    subscription                = $subscription
    exemptions                  = $exemptions
    assignments                 = $assignments
    resourceTypeFolderPath      = $SubFileNameMapping.FileParentDirectory
    expiresOnWarningDays        = $exemptionExpiresOnWarningDays
    includeSubWithoutExemptions = $false
    wikiFileMapping             = $wikiFileMapping
  }
  $subExemptionMarkdown = buildPolicyExemptionMarkdownTableForSub @subExemptionsParams

  if ($mgExemptionMarkdown -or $subExemptionMarkdown) {
    $Markdown += 'The following Policy Exemptions are effective for the subscription:'
    $Markdown += "`n`n"
    if ($mgExemptionMarkdown) {
      $Markdown += "$(newMarkdownHeader -title "management group scoped policy exemptions" -level 3 -caseStyle 'UpperCase')`n`n"
      $Markdown += $mgExemptionMarkdown
    }
    if ($subExemptionMarkdown) {
      $Markdown += "$(newMarkdownHeader -title "subscription scoped policy exemptions" -level 3 -caseStyle 'UpperCase')`n`n"
      $Markdown += $subExemptionMarkdown
    }
  } else {
    $Markdown += ':bookmark: No Policy Exemptions are effective for the subscription.'
    $Markdown += "`n`n"
  }
  $Markdown
}

# 19. Function to build policy assignment table for a given management group
function buildPolicyAssignmentMarkdownTableForMg {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [Object]
    $managementGroup,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    # This parameter is used to check if the subscription is in the exclusion scopes of the assignment
    [parameter(Mandatory = $false)]
    [Object]
    $subscriptionToCheckForAssignmentNoScope,

    [parameter(Mandatory = $true)]
    [string]
    $resourceTypeFolderPath,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $false)]
    [bool]
    $includeMgWithoutAssignments = $true,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $false, HelpMessage = 'Assignment Compliance data for the detailed pages')]
    [array]
    $assignmentCompliance = @()
  )

  $WikiStyle = $WikiFileMapping.WikiStyle

  if ($subscriptionToCheckForAssignmentNoScope) {
    #Get All ancestor management groups for the subscription
    $ancestorManagementGroupIds = @()
    foreach ($mg in $subscription.managementGroupAncestorsChain.name) {
      $ancestorManagementGroupIds += '/providers/microsoft.management/managementgroups/{0}' -f $($mg.tolower())
    }
  }

  $mgAssignments = $assignments | Where-Object { $_.properties.scope -ieq $managementGroup.id } | Sort-Object name
  $assignmentTableData = @()
  if ($mgAssignments.count -ge 1) {
    $markdownHeaderLine1 = '| Name | Display Name | Description |'
    $markdownHeaderLine2 = '| :--- | :----------- | :---------- |'
    if ($assignmentCompliance.count -gt 0) {
      $markdownHeaderLine1 += ' Compliance % |'
      $markdownHeaderLine2 += ' :----------: |'
    }
    if ($subscriptionToCheckForAssignmentNoScope) {
      $markdownHeaderLine1 += ' Applicable Exclusion Scopes |'
      $markdownHeaderLine2 += ' :-------------------------- |'
    }
    $Markdown = ''
    $Markdown += ":bookmark: **$($mgAssignments.count)** Policy Assignments are created on the scope of the management group ``$($managementGroup.name)``:`n`n"
    $Markdown += "`n`n"
    if ($subscriptionToCheckForAssignmentNoScope) {
      $Markdown += buildQuotedAlert -type 'note' -WikiStyle $WikiStyle -contentStyle normal -messages "If the ``applicable Exclusion Scopes`` column contains any scopes, then either the entire subscription or some resources groups or resources within the subscription are excluded from the Policy Assignment."
    }
    $Markdown += "`n`n"
    $Markdown += "<details>"
    $Markdown += "`n`n"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += $markdownHeaderLine1
    $Markdown += "`n"
    $Markdown += $markdownHeaderLine2
    $Markdown += "`n"
    foreach ($assignment in $mgAssignments) {
      $assignmentComplianceForAssignment = $assignmentCompliance | Where-Object { $_.policyAssignmentId -ieq $assignment.id }
      $totalCompliantCount = 0
      $totalNonCompliantCount = 0
      $totalConflictCount = 0
      $totalExemptCount = 0
      foreach ($item in $assignmentComplianceForAssignment) {
        $totalCompliantCount = $totalCompliantCount + $item.compliantCount
        $totalNonCompliantCount = $totalNonCompliantCount + $item.nonCompliantCount
        $totalConflictCount = $totalConflictCount + $item.conflictCount
        $totalExemptCount = $totalExemptCount + $item.exemptCount
      }
      $totalCount = $totalCompliantCount + $totalNonCompliantCount + $totalConflictCount + $totalExemptCount
      $compliancePercentageParams = @{
        CompliantCount           = $totalCompliantCount
        NonCompliantCount        = $totalNonCompliantCount
        ExemptCount              = $totalExemptCount
        ConflictCount            = $totalConflictCount
        NumberOfFractionalDigits = 0
      }
      $compliancePercentage = getCompliancePercentage @compliancePercentageParams
      $complianceRateString = "{0}% ({1} out of {2})" -f $compliancePercentage, $($totalCompliantCount + $totalExemptCount), $totalCount
      $complianceRateParams = @{
        rate                       = $compliancePercentage
        InputString                = $complianceRateString
        WarningPercentageThreshold = $ComplianceWarningPercentageThreshold
        WikiStyle                  = $WikiStyle
        Format                     = 'Markdown'
      }
      $complianceRate = FormatComplianceRate @complianceRateParams

      if ($subscriptionToCheckForAssignmentNoScope) {
        #Check if the assignment has any notScopes that apply to the subscription
        $arrEffectiveNotScopes = @()
        #check if subscription is in the exclusion scopes of the assignment
        foreach ($ns in $assignment.properties.notScopes) {
          #check management group first
          if ($($ns.tolower()) -in $ancestorManagementGroupIds) {
            $arrEffectiveNotScopes += $ns
          }
          #then check subscription
          if ($ns -imatch $('{0}*' -f $subscriptionToCheckForAssignmentNoScope.id)) {
            $arrEffectiveNotScopes += $ns
          }
        }
        if ($arrEffectiveNotScopes.Count -gt 0) {
          $effectiveNotScopes = ""
          foreach ($scope in $arrEffectiveNotScopes) {
            $effectiveNotScopes = $effectiveNotScopes + "<li>``$scope``</li>"
          }
        } else {
          $effectiveNotScopes = '``null``'
        }
      }
      $assignmentPageFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $assignmentPageFileNameMapping.FileBaseName
      $assignmentFolderPath = $assignmentPageFileNameMapping.FileParentDirectory
      $assignmentLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true
      $assignmentTableRow = [PSCustomObject]@{
        Name        = "[$($assignment.name)]($assignmentLink)"
        DisplayName = $(FormatMarkdownTableString -InputString $assignment.properties.displayName)
        Description = $($assignment.properties.description ? $(FormatMarkdownTableString -InputString $assignment.properties.description) : '``null``')
      }
      if ($assignmentCompliance.count -gt 0) {
        Add-Member -InputObject $assignmentTableRow -MemberType NoteProperty -Name 'complianceRate' -Value $complianceRate
        #add the compliance percentage as a hidden column for sorting purpose
        Add-Member -InputObject $assignmentTableRow -MemberType NoteProperty -Name 'compliancePercentage' -Value $compliancePercentage
      }
      if ($subscriptionToCheckForAssignmentNoScope) {
        Add-Member -InputObject $assignmentTableRow -MemberType NoteProperty -Name 'effectiveNotScopes' -Value $effectiveNotScopes
      }
      $assignmentTableData += $assignmentTableRow
    }
    #Sort the table rows based on the compliance percentage
    $sortedAssignmentTableData = $assignmentTableData | Sort-Object -Property 'compliancePercentage', 'name'
    foreach ($assignmentTableRow in $sortedAssignmentTableData) {
      $tableRow = "| $($assignmentTableRow.name) | $($assignmentTableRow.displayName) | $($assignmentTableRow.description) |"
      if ($assignmentTableRow.complianceRate) {
        $tableRow += " $($assignmentTableRow.complianceRate) |"
      }
      if ($subscriptionToCheckForAssignmentNoScope) {
        $tableRow += " $($assignmentTableRow.effectiveNotScopes) |"
      }
      $Markdown += $tableRow
      $Markdown += "`n"
    }
    $Markdown += "`n"
    if ($assignmentCompliance.count -gt 0) {
      $Markdown += "`n"
      $Markdown += $(buildComplianceRatingMarkdown -WikiStyle $WikiStyle -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold)
    }
    $Markdown += "`n`n"
    $Markdown += "</details>"
    $Markdown += "`n`n"
  } else {
    if ($includeMgWithoutAssignments) {
      $Markdown += buildQuotedAlert -type 'note' -contentStyle normal -WikiStyle $WikiStyle -messages "There are no active Policy Assignments created on the scope of the Management Group ``$($managementGroup.name)``."
    } else {
      $Markdown = $null
    }
  }
  $Markdown
}

# 20. Function to build policy assignment table for a given subscription
function buildPolicyAssignmentMarkdownTableForSub {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [Object]
    $subscription,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $false)]
    [boolean]
    $includeNoScope = $false,

    [parameter(Mandatory = $true)]
    [string]
    $resourceTypeFolderPath,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $false)]
    [bool]
    $includeSubWithoutAssignments = $false,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $false, HelpMessage = 'Assignment Compliance data for the detailed pages')]
    [array]
    $assignmentCompliance = @()
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  $subAssignments = $assignments | Where-Object { $_.properties.scope -imatch $('{0}*' -f $subscription.id) }
  $assignmentTableData = @()
  if ($subAssignments.count -ge 1) {
    $markdownHeaderLine1 = '| Name | Display Name | Description |'
    $markdownHeaderLine2 = '| :--- | :----------- | :---------- |'
    if ($assignmentCompliance.count -gt 0) {
      $markdownHeaderLine1 += ' Compliance % |'
      $markdownHeaderLine2 += ' :----------: |'
    }
    if ($includeNoScope) {
      $markdownHeaderLine1 += ' Exclusion Scopes |'
      $markdownHeaderLine2 += ' :--------------- |'
    }
    $Markdown = ''
    $Markdown += ":bookmark: **$($subAssignments.count)** Policy Assignments are created on the scope of the subscription ``$($subscription.name)`` or resource groups in the subscription:`n`n"
    $Markdown += "<details>"
    $Markdown += "`n`n"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += $markdownHeaderLine1
    $Markdown += "`n"
    $Markdown += $markdownHeaderLine2
    $Markdown += "`n"
    foreach ($assignment in $subAssignments) {
      $assignmentComplianceForAssignment = $assignmentCompliance | Where-Object { $_.policyAssignmentId -ieq $assignment.id }
      $totalCompliantCount = 0
      $totalNonCompliantCount = 0
      $totalConflictCount = 0
      $totalExemptCount = 0
      foreach ($item in $assignmentComplianceForAssignment) {
        $totalCompliantCount = $totalCompliantCount + $item.compliantCount
        $totalNonCompliantCount = $totalNonCompliantCount + $item.nonCompliantCount
        $totalConflictCount = $totalConflictCount + $item.conflictCount
        $totalExemptCount = $totalExemptCount + $item.exemptCount
      }
      $totalCount = $totalCompliantCount + $totalNonCompliantCount + $totalConflictCount + $totalExemptCount
      $compliancePercentageParams = @{
        CompliantCount           = $totalCompliantCount
        NonCompliantCount        = $totalNonCompliantCount
        ExemptCount              = $totalExemptCount
        ConflictCount            = $totalConflictCount
        NumberOfFractionalDigits = 0
      }
      $compliancePercentage = getCompliancePercentage @compliancePercentageParams
      $complianceRateString = "{0}% ({1} out of {2})" -f $compliancePercentage, $($totalCompliantCount + $totalExemptCount), $totalCount
      $complianceRateParams = @{
        rate                       = $compliancePercentage
        InputString                = $complianceRateString
        WarningPercentageThreshold = $ComplianceWarningPercentageThreshold
        WikiStyle                  = $WikiStyle
        Format                     = 'Markdown'
      }
      $complianceRate = FormatComplianceRate @complianceRateParams

      if ($includeNoScope) {
        $arrNotScopes = @()
        foreach ($ns in $assignment.properties.notScopes) {
          $arrNotScopes += $ns
        }
        if ($arrNotScopes.Count -gt 0) {
          $notScopes = ""
          foreach ($scope in $arrNotScopes) {
            $notScopes = $effectiveNotScopes + "<br> - ``$scope``"
          }
        } else {
          $notScopes = '``null``'
        }
      }

      $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $AssignmentFileNameMapping.FileBaseName
      $assignmentFolderPath = $AssignmentFileNameMapping.FileParentDirectory

      $assignmentLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true
      $assignmentTableRow = [PSCustomObject]@{
        Name        = "[$($assignment.name)]($assignmentLink)"
        DisplayName = $(FormatMarkdownTableString -InputString $assignment.properties.displayName)
        Description = $($assignment.properties.description ? $(FormatMarkdownTableString -InputString $assignment.properties.description) : '``null``')
      }
      if ($assignmentCompliance.count -gt 0) {
        Add-Member -InputObject $assignmentTableRow -MemberType NoteProperty -Name 'complianceRate' -Value $complianceRate
        #add the compliance percentage as a hidden column for sorting purpose
        Add-Member -InputObject $assignmentTableRow -MemberType NoteProperty -Name 'compliancePercentage' -Value $compliancePercentage
      }
      if ($includeNoScope) {
        Add-Member -InputObject $assignmentTableRow -MemberType NoteProperty -Name 'notScopes' -Value $notScopes
      }
      $assignmentTableData += $assignmentTableRow
    }
    #Sort the table rows based on the compliance percentage
    $sortedAssignmentTableData = $assignmentTableData | Sort-Object -Property 'compliancePercentage', 'name'
    foreach ($assignmentTableRow in $sortedAssignmentTableData) {
      $tableRow = "| $($assignmentTableRow.name) | $($assignmentTableRow.displayName) | $($assignmentTableRow.description) |"
      if ($assignmentCompliance.count -gt 0) {
        $tableRow += " $($assignmentTableRow.complianceRate) |"
      }
      if ($includeNoScope) {
        $tableRow += " $($assignmentTableRow.notScopes) |"
      }
      $Markdown += $tableRow
    }
    $Markdown += "`n"
    if ($assignmentCompliance.count -gt 0) {
      $Markdown += "`n"
      $Markdown += $(buildComplianceRatingMarkdown -WikiStyle $WikiStyle -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold)
    }
    $Markdown += "`n"
    $Markdown += "</details>"
    $Markdown += "`n`n"
  } else {
    if ($includeSubWithoutAssignments) {
      $Markdown += ":bookmark: There are no active Policy Assignments created on the scope of the subscription ``$($subscription.name)`` or resource groups in the subscription.`n`n"
    } else {
      $Markdown = $null
    }
  }
  $Markdown
}

# 21. Function to build policy exemption table for a given management group
function buildPolicyExemptionMarkdownTableForMg {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [Object]
    $managementGroup,

    [parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [array]
    $exemptions,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $true)]
    [int]
    $expiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true)]
    [string]
    $resourceTypeFolderPath,

    [parameter(Mandatory = $false)]
    [bool]
    $includeMgWithoutExemptions = $false
  )
  $wikiStyle = $WikiFileMapping.WikiStyle
  $mgMatchRegex = '(?im)^\/providers\/microsoft\.management\/managementgroups\/{0}\/' -f $($managementGroup.name.tolower())
  $mgExemptions = $exemptions | Where-Object { $_.id -match $mgMatchRegex } | sort-Object name

  if ($mgExemptions.count -ge 1) {
    $Markdown += "$(newMarkdownHeader -title "$($managementGroup.name)" -level 3 -caseStyle 'UpperCase')`n`n"
    $Markdown = ''
    $Markdown += ":bookmark: **$($mgExemptions.count)** Policy Exemptions are created on the scope of the management group ``$($managementGroup.name)``:`n`n"
    $Markdown += "<details>"
    $Markdown += "`n`n"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += "| Name | Display Name | Description | Policy Assignment | Category | Expires On (UTC) | Definition Reference Ids |`n"
    $Markdown += "| ---- | ------------ | ----------- | ----------------- | -------- | ---------------- | ------------------------ |`n"

    foreach ($exemption in $mgExemptions) {
      $assignment = $assignments | Where-Object { $_.id -ieq $exemption.policyAssignmentId }
      $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $wikiFileMapping
      $exemptionFileNameMapping = getWikiPageFileName -ResourceId $exemption.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $AssignmentFileNameMapping.FileBaseName
      $assignmentFolderPath = $AssignmentFileNameMapping.FileParentDirectory
      $assignmentLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true

      $exemptionPageFileBaseName = $exemptionFileNameMapping.FileBaseName
      $exemptionFolderPath = $exemptionFileNameMapping.FileParentDirectory
      $exemptionLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $exemptionFolderPath $exemptionPageFileBaseName) -UseUnixPath $true

      if ($exemption.policyDefinitionReferenceIds.Count -gt 0) {
        $policyDefinitionReferenceIds = ""
        foreach ($id in $exemption.policyDefinitionReferenceIds) {
          $policyDefinitionReferenceIds += $policyDefinitionReferenceIds + "<li>``$id``</li>"
        }
      } else {
        $policyDefinitionReferenceIds = '``null``'
      }
      $exemptionDisplayName = FormatMarkdownTableString -InputString $exemption.displayName
      if ($exemption.expiresOn -is [datetime]) {
        #format to correct string format
        $strExemptionExpiresOn = $exemption.expiresOn.ToString('yyyy-MM-ddTHH:mm:ssZ')
      } else {
        $strExemptionExpiresOn = $exemption.expiresOn
      }
      $exemptionExpiresOn = FormatExemptionExpiresOn -InputString $strExemptionExpiresOn -warningDays $expiresOnWarningDays -WikiStyle $wikiStyle
      $Markdown += "| [$($exemption.name)]($exemptionLink) | $exemptionDisplayName | $($exemption.description ? $(FormatMarkdownTableString -InputString $exemption.description) : '``null``') | [$($assignment.name)]($assignmentLink) | $($exemption.exemptionCategory) | $exemptionExpiresOn | $policyDefinitionReferenceIds |`n"
    }
    $Markdown += "`n`n"
    $Markdown += buildExemptionExpiresOnMarkdown -expiresOnWarningDays $expiresOnWarningDays -WikiStyle $wikiStyle
    $Markdown += "</details>"
    $Markdown += "`n`n"
  } else {
    if ($includeMgWithoutExemptions) {
      $Markdown += buildQuotedAlert -type note -contentStyle normal -WikiStyle $WikiStyle -message "There are no Policy Exemptions created on the scope of the Management Group ``$($managementGroup.name)``."
    } else {
      $Markdown = $null
    }
  }
  $Markdown
}

# 22. Function to build policy exemption table for a given subscription
function buildPolicyExemptionMarkdownTableForSub {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [Object]
    $subscription,

    [parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [array]
    $exemptions,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $true)]
    [int]
    $expiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true)]
    [string]
    $resourceTypeFolderPath,

    [parameter(Mandatory = $false)]
    [bool]
    $includeSubWithoutExemptions = $false
  )
  $wikiStyle = $WikiFileMapping.WikiStyle
  $subExemptions = $exemptions | Where-Object { $_.id -imatch $('{0}*' -f $subscription.id) }
  if ($subExemptions.count -ge 1) {
    $Markdown += ":bookmark: **$($subExemptions.count)** Policy Exemptions are created on the scope of the subscription ``$($subscription.name)`` or resource groups in the subscription:`n`n"
    $Markdown += "<details>"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += "| Name | Display Name | Description | Policy Assignment | Category | Expires On (UTC) | Definition Reference Ids |`n"
    $Markdown += "| ---- | ------------ | ----------- | ----------------- | -------- | ---------------- | ------------------------ |`n"

    foreach ($exemption in $subExemptions) {
      $assignment = $assignments | Where-Object { $_.id -ieq $exemption.policyAssignmentId }
      $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $wikiFileMapping
      $exemptionFileNameMapping = getWikiPageFileName -ResourceId $exemption.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $AssignmentFileNameMapping.FileBaseName
      $assignmentFolderPath = $AssignmentFileNameMapping.FileParentDirectory
      $assignmentLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true

      $exemptionPageFileBaseName = $exemptionFileNameMapping.FileBaseName
      $exemptionFolderPath = $exemptionFileNameMapping.FileParentDirectory
      $exemptionLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $exemptionFolderPath $exemptionPageFileBaseName) -UseUnixPath $true

      if ($exemption.policyDefinitionReferenceIds.Count -gt 0) {
        $policyDefinitionReferenceIds = ""
        foreach ($id in $exemption.policyDefinitionReferenceIds) {
          $policyDefinitionReferenceIds += $policyDefinitionReferenceIds + "<li>``$id``</li>"
        }
      } else {
        $policyDefinitionReferenceIds = '``null``'
      }
      $exemptionDisplayName = FormatMarkdownTableString -InputString $exemption.displayName
      if ($exemption.expiresOn -is [datetime]) {
        #format to correct string format
        $strExemptionExpiresOn = $exemption.expiresOn.ToString('yyyy-MM-ddTHH:mm:ssZ')
      } else {
        $strExemptionExpiresOn = $exemption.expiresOn
      }
      $exemptionExpiresOn = FormatExemptionExpiresOn -InputString $strExemptionExpiresOn -warningDays $expiresOnWarningDays -WikiStyle $wikiStyle
      $Markdown += "| [$($exemption.name)]($exemptionLink) | $exemptionDisplayName | $($exemption.description ? $(FormatMarkdownTableString -InputString $exemption.description) : '``null``') | [$($assignment.name)]($assignmentLink) | $($exemption.exemptionCategory) | $exemptionExpiresOn | $policyDefinitionReferenceIds |`n"
    }
    $Markdown += "`n`n"
    $Markdown += buildExemptionExpiresOnMarkdown -expiresOnWarningDays $expiresOnWarningDays -WikiStyle $wikiStyle
    $Markdown += "</details>"
    $Markdown += "`n`n"
  } else {
    if ($includeSubWithoutExemptions) {
      $Markdown += ":bookmark: There are no Policy Exemptions created on the scope of the subscription ``$($subscription.name)`` or resource groups in the subscription.`n`n"
    } else {
      $Markdown = $null
    }
  }
  $Markdown
}

# 23. Function to build policy initiative or definition table for a given management group or subscription
function buildPolicyDefinitionInitiativeMarkdownTableForScope {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [string]
    $resourceId,

    [parameter(Mandatory = $true)]
    [string]
    $resourceName,

    [parameter(Mandatory = $true)]
    [array]
    $policyResources,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true)]
    [string]
    $resourceTypeFolderPath,

    [parameter(Mandatory = $false)]
    [bool]
    $includeTargetWithoutPolicyResources = $true
  )
  $initiativeResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policysetdefinitions\/'
  $definitionResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policydefinitions\/'
  $managementGroupResourceIdRegex = '(?im)^\/providers\/microsoft\.management\/managementgroups\/'
  $subscriptionResourceIdRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
  #determine the resource type based on the resource ID
  if ($policyResources[0].id -match $initiativeResourceIdRegex) {
    $policyResourceType = 'Initiatives'
  } elseif ($policyResources[0].id -match $definitionResourceIdRegex) {
    $policyResourceType = 'Definitions'
  } else {
    Write-Error "[$(getCurrentUTCString)]: Unable to determine the policy resource type from the resource ID: '$($policyResources[0].id)'."
    return $null
  }
  #determine the resource parent type based on the resource ID
  if ($ResourceId -match $managementGroupResourceIdRegex) {
    $resourceType = 'Management Groups'
  } elseif ($ResourceId -match $subscriptionResourceIdRegex) {
    $resourceType = 'Subscriptions'
  } else {
    Write-Error "[$(getCurrentUTCString)]: Unable to determine the resource type from the resource ID: '$resourceId'."
    return $null
  }
  $inScopeResources = $policyResources | Where-Object { $_.id -imatch $('{0}*' -f $resourceId) } | sort-Object name
  $Markdown = ''
  if ($inScopeResources.count -ge 1) {
    $Markdown += ":bookmark: **$($inScopeResources.count)** Policy $policyResourceType are created on the the $resourceType ``$resourceName``:`n`n"
    $Markdown += "<details>"
    $Markdown += "`n`n"
    $Markdown += "<summary>Click to expand</summary>"
    $Markdown += "`n`n"
    $Markdown += "| Name | Display Name | Assigned |`n"
    $Markdown += "| ---- | ------------ | :------: |`n"
    foreach ($item in $inScopeResources) {
      $DefinitionFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
      $policyResourcePageFileBaseName = $DefinitionFileNameMapping.FileBaseName
      $policyResourceFolderPath = $DefinitionFileNameMapping.FileParentDirectory
      $policyResourceLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $policyResourceFolderPath $policyResourcePageFileBaseName) -UseUnixPath $true
      $Markdown += "| [$($item.name)]($policyResourceLink) | $(FormatMarkdownTableString -InputString $item.properties.displayName) | ``$($item.isInUse.toupper())`` |`n"
    }
    $Markdown += "`n"
    $Markdown += "</details>"
    $Markdown += "`n`n"
  } else {
    if ($includeTargetWithoutPolicyResources) {
      $Markdown += buildQuotedAlert -type note -contentStyle normal -WikiStyle $WikiStyle -messages "There is no Policy $policyResourceType created on the $resourceType ``$resourceName``."
    } else {
      $Markdown = $null
    }
  }
  $Markdown
}

# 24. Function to build policy initiative or definition table for all definitions or initiatives passed into the function
function buildPolicyDefinitionInitiativeMarkdownTable {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [array]
    $policyResources,

    [parameter(Mandatory = $true)]
    [validateSet('initiative', 'definition')]
    [string]
    $policyResourceType,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )

  $builtInitiativeResourceIdRegex = '(?im)^\/providers\/microsoft\.authorization\/policysetdefinitions\/'
  $builtInDefinitionResourceIdRegex = '(?im)^\/providers\/microsoft\.authorization\/policydefinitions\/'
  $SummaryPageFileNameMapping = getWikiPageFileName -summaryPageType $policyResourceType -wikiFileMapping $WikiFileMapping
  $resourceTypeFolderPath = $SummaryPageFileNameMapping.FileParentDirectory
  switch ($policyResourceType) {
    'initiative' {
      $builtInResourceIdRegex = $builtInitiativeResourceIdRegex
    }
    'definition' {
      $builtInResourceIdRegex = $builtInDefinitionResourceIdRegex
    }
  }

  $Markdown = ''
  $Markdown += "<details>"
  $Markdown += "`n`n"
  $Markdown += "<summary>Click to expand</summary>"
  $Markdown += "`n`n"
  $Markdown += "| Name | Display Name | Description |`n"
  $Markdown += "| ---- | ------------ | ----------- |`n"
  foreach ($item in $policyResources) {
    #determine if the definition or initiative is built-in or custom
    if ($item.id -match $builtInResourceIdRegex) {
      Write-Verbose "[$(getCurrentUTCString)]: Found built-in Policy $policyResourceType`: $($item.name)." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    } else {
      Write-Verbose "[$(getCurrentUTCString)]: Found custom Policy $policyResourceType`: $($item.name)." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
    $PolicyResourceFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
    $policyResourcePageFileBaseName = $PolicyResourceFileNameMapping.FileBaseName
    $policyResourceFolderPath = $PolicyResourceFileNameMapping.FileParentDirectory
    $policyResourceLink = getRelativePath -FromPath $resourceTypeFolderPath -ToPath $(Join-Path $policyResourceFolderPath $policyResourcePageFileBaseName) -UseUnixPath $true
    $Markdown += "| [$($item.name)]($policyResourceLink) | $(FormatMarkdownTableString -InputString $item.properties.displayName) | $($item.properties.description ? $(FormatMarkdownTableString -InputString $item.properties.description) : '``null``') |`n"
  }
  $Markdown += "`n"
  $Markdown += "</details>"
  $Markdown += "`n`n"
  $Markdown
}

# 24a. Function to format Pester syntax test result (from Test-AzPolicyDefinition / Test-AzPolicyInitiativeDefinition) into markdown
function buildPolicySyntaxTestResultMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = 'Pester run result object containing a Tests collection.')]
    [System.Object]$TestResult
  )
  $markdown = ''
  if (-not $TestResult -or -not $TestResult.Tests -or $TestResult.Tests.Count -eq 0) {
    $markdown += ":bookmark: No syntax tests were executed.`n`n"
    return $markdown
  }

  # Overall summary
  $totalCount = $TestResult.Tests.Count
  $passedCount = @($TestResult.Tests | Where-Object { $_.Result -ieq 'Passed' }).Count
  $failedCount = @($TestResult.Tests | Where-Object { $_.Result -ieq 'Failed' }).Count
  $skippedCount = @($TestResult.Tests | Where-Object { $_.Result -ieq 'Skipped' }).Count
  if ($failedCount -gt 0) {
    $overallStatus = ':x: Failed'
  } elseif ($passedCount -eq $totalCount) {
    $overallStatus = ':white_check_mark: Passed'
  } else {
    $overallStatus = ':warning: Partial'
  }
  $summaryTable = [ordered]@{
    Status  = $overallStatus
    Total   = $totalCount
    Passed  = $passedCount
    Failed  = $failedCount
    Skipped = $skippedCount
  }
  $markdown += $(newMarkdownTable -data $summaryTable -Orientation 'vertical')
  $markdown += "`n`n"

  # Group tests by their immediate context (Block.Name). Preserve original order.
  $grouped = $TestResult.Tests | Group-Object -Property { $_.Block.Name }
  foreach ($group in $grouped) {
    $contextName = if ([string]::IsNullOrWhiteSpace($group.Name)) { 'Tests' } else { $group.Name }
    $markdown += $(newMarkdownHeader -title $contextName -level 3 -caseStyle 'TitleCase')
    $markdown += "`n`n"

    $tableData = @()
    foreach ($test in $group.Group) {
      switch ($test.Result) {
        'Passed' { $resultText = ':white_check_mark: Passed' }
        'Failed' { $resultText = ':x: Failed' }
        'Skipped' { $resultText = ':warning: Skipped' }
        default { $resultText = $test.Result }
      }
      $testTitle = if ($test.ExpandedName) { $test.ExpandedName } else { $test.Name }
      $tableData += [ordered]@{
        Test   = $testTitle
        Result = $resultText
      }
    }
    $markdown += $(newMarkdownTableFromArray -data $tableData -FormatTableHeader $false)
    $markdown += "`n`n"
  }
  $markdown
}

# 25. Function to build detailed page content for a policy definition
function buildPolicyDefinitionDetailedPageContent {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $definition,

    [parameter(Mandatory = $true)]
    [System.array]
    $initiatives,

    [parameter(Mandatory = $true)]
    [System.array]
    $assignments,

    [parameter(Mandatory = $true)]
    [string]
    $FromPath,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  $markdownCodeBlock = '```'
  #filter out any 'hidden-' metadata
  $metadata = ConvertToOrderedHashtable -InputObject $($definition.properties.metadata)
  if ($PageStyle -ieq 'basic') {
    $hiddenMetadataNames = $metadata.Keys | Where-Object { $_ -match '^hidden[-_]' }
    foreach ($hiddenMetadataName in $hiddenMetadataNames) {
      $metadata.Remove($hiddenMetadataName)
    }
  }
  #build policy definition json
  $definitionData = [ordered]@{
    name       = $definition.name
    properties = [ordered]@{
      displayName = $definition.properties.displayName
      description = $definition.properties.description
      metadata    = $metadata
      mode        = $definition.properties.mode
      parameters  = $definition.properties.parameters
      policyRule  = [ordered]@{
        if   = $definition.properties.policyRule.if
        then = $definition.properties.policyRule.then
      }
    }
    id         = $definition.id
  }

  $definitionJson = buildPolicyDefinitionJson -PolicyDefinition $definitionData
  $policyEffectConfig = getPolicyEffect -policyObject $definition
  $wrappedEffects = $policyEffectConfig.effects | ForEach-Object { "``$($_)``" }
  $effects = $($wrappedEffects -join ', ')
  $defaultEffect = $policyEffectConfig.defaultEffectValue
  #get the initiatives that the definition is a. member of
  $relatedInitiatives = $initiatives | Where-Object { $_.properties.policyDefinitions.policyDefinitionId -ieq $definition.id }

  #Get the assignments that are directly assigning this policy definition and related initiatives
  $relatedAssignments = @()
  foreach ($a in $($assignments | Where-Object { $_.properties.policyDefinitionId -ieq $definition.id })) {
    $relatedAssignments += $a
  }
  foreach ($i in $relatedInitiatives) {
    $relatedAssignments += $assignments | Where-Object { $_.properties.policyDefinitionId -ieq $i.id }
  }

  $definitionOverviewTableData = [ordered]@{
    DisplayName   = "**$($definition.properties.displayName)**"
    Name          = $definition.name
    Id            = $definition.id
    Type          = $definition.properties.policyType
    Description   = $($definition.properties.description ? $($definition.properties.description) : $null)
    Version       = $definition.properties.version ?? $metadata.version ?? $null
    Effects       = $effects
    DefaultEffect = "``$defaultEffect``"
    InUse         = '``{0}``' -f ($(if ($definition.isInUse) { $definition.isInUse } else { 'false' })).ToString().ToUpper()
  }

  if ($PageStyle -ieq 'detailed') {
    #Use AzPolicyTest to test definition syntax when the page style is detailed, exclude 2 tests for the DINE policies since many built-in policies violate these rules and they are not critical.
    $syntaxTestResult = Test-AzPolicyDefinition -content $definitionJson -PesterVerbosity 'None' -ExcludeTags 'DINETemplateVariables', 'DINETemplateOutputs'
    $coloredSyntaxTestResult = FormatTestResult -result $syntaxTestResult.Result -WikiStyle $WikiStyle
    $definitionOverviewTableData.Add('TestResult', $coloredSyntaxTestResult)
  }
  $parameterMarkdownContent = buildPolicyDefinitionParametersMarkdown -definition $(ConvertToOrderedHashtable -InputObject $definition) -caseStyle 'original' -level 3

  $PageContent = ""
  $PageContent += $(newMarkdownHeader -title "Definition: $($definition.properties.displayName)" -level 1 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "definition overview" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "definition details" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownTable -data $definitionOverviewTableData -Orientation 'vertical')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "definition metadata" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  $PageContent += "<details>"
  $PageContent += "`n`n"
  $PageContent += "<summary>Click to expand</summary>"
  $PageContent += "`n`n"
  $PageContent += $(newHtmlTable -data $metadata -formatTableHeader $false -WikiStyle $WikiStyle)
  $PageContent += "`n`n"
  $PageContent += "</details>"
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "related resources" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "initiatives" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  if ($relatedInitiatives) {
    $relatedInitiativesTableData = @()
    foreach ($initiative in $relatedInitiatives) {
      $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiative.id -wikiFileMapping $wikiFileMapping
      $initiativePageFileBaseName = $initiativeFileNameMapping.FileBaseName
      $initiativeFolderPath = $initiativeFileNameMapping.FileParentDirectory
      $initiativeLink = getRelativePath -FromPath $FromPath -ToPath $(Join-Path $initiativeFolderPath $initiativePageFileBaseName) -UseUnixPath $true

      $relatedInitiativesTableData += [ordered]@{
        Name        = "[$($initiative.name)]($initiativeLink)"
        DisplayName = $initiative.properties.displayName
        Description = $initiative.properties.description
      }
    }
    $PageContent += ":bookmark: This policy definition is part of the following policy initiatives:"
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownTableFromArray -data $relatedInitiativesTableData)
    $PageContent += "`n`n"
  } else {
    $PageContent += ":bookmark: This policy definition is not a member of any policy initiatives.`n`n"
  }
  $PageContent += $(newMarkdownHeader -title "assignments" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  if ($relatedAssignments) {
    $PageContent += ":bookmark: The following policy assignments are assigning this policy definition directly or related initiatives:"
    $PageContent += "`n`n"
    $relatedAssignmentsTableData = @()
    foreach ($assignment in $relatedAssignments) {
      $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $AssignmentFileNameMapping.FileBaseName
      $assignmentFolderPath = $AssignmentFileNameMapping.FileParentDirectory
      $assignmentLink = getRelativePath -FromPath $FromPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true

      $relatedAssignmentsTableData += [ordered]@{
        Name        = "[$($assignment.name)]($assignmentLink)"
        DisplayName = $assignment.properties.displayName
        Description = $assignment.properties.description
      }
    }
    $PageContent += $(newMarkdownTableFromArray -data $relatedAssignmentsTableData)
    $PageContent += "`n`n"
  } else {
    $PageContent += ":bookmark: There are no active policy assignments directly assigning this policy definition.`n`n"
  }
  $PageContent += $(newMarkdownHeader -title "definition parameters" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += "<details>"
  $PageContent += "`n`n"
  $PageContent += "<summary>Click to expand</summary>"
  $PageContent += "`n`n"
  $PageContent += $parameterMarkdownContent
  $PageContent += "`n`n"
  $PageContent += "</details>"
  $PageContent += "`n`n"
  if ($PageStyle -ieq 'detailed' -and $syntaxTestResult) {
    $PageContent += $(newMarkdownHeader -title "definition syntax test result" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $notes = @()
    $notes += "Definition syntax validation is performed using ``AzPolicyTest``, an open-source Pester-based test framework for Azure Policy."
    $notes += "It performs static analysis of the Policy definition against schema requirements and a curated set of best-practice assertions."
    $PageContent += buildQuotedAlert -type tip -messages $notes -contentStyle list -WikiStyle $WikiFileMapping.WikiStyle
    $PageContent += "`n`n"
    $PageContent += "<details>"
    $PageContent += "`n`n"
    $PageContent += "<summary>Click to expand</summary>"
    $PageContent += "`n`n"
    $PageContent += $(buildPolicySyntaxTestResultMarkdown -TestResult $syntaxTestResult)
    $PageContent += "`n`n"
    $PageContent += "</details>"
    $PageContent += "`n`n"
  }
  $PageContent += $(newMarkdownHeader -title "raw policy definition" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += "<details>`n`n"
  $PageContent += "<summary>Click to expand</summary>`n`n"
  $PageContent += $markdownCodeBlock + "json`n"
  $PageContent += $definitionJson
  $PageContent += "`n`n"
  $PageContent += "$markdownCodeBlock`n"
  $PageContent += "`n`n</details>`n`n"

  Write-Verbose $PageContent -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $PageContent
}

# 26. Function to build detailed page content for a policy initiative
function buildPolicyInitiativeDetailedPageContent {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [string]
    $OutputPath,

    [parameter(Mandatory = $true)]
    [System.Object]
    $initiative,

    [parameter(Mandatory = $true)]
    [System.array]
    $assignments,

    [parameter(Mandatory = $true)]
    [Array]
    $policyMetadata,

    [parameter(Mandatory = $true)]
    [Array]
    $definitions,

    [parameter(Mandatory = $false)]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  $markdownCodeBlock = '```'
  #build initiative definition json
  #filter out any 'hidden-' metadata
  $metadata = ConvertToOrderedHashtable -InputObject $($initiative.properties.metadata)
  if ($PageStyle -ieq 'basic') {
    $hiddenMetadataNames = $metadata.Keys | Where-Object { $_ -match '^hidden[-_]' }
    foreach ($hiddenMetadataName in $hiddenMetadataNames) {
      $metadata.Remove($hiddenMetadataName)
    }
  }
  $SecurityControlSummaryFileNameMapping = getWikiPageFileName -summaryPageType security_control -wikiFileMapping $WikiFileMapping
  $SecurityControlSummaryFileBaseName = $SecurityControlSummaryFileNameMapping.FileBaseName
  $SecurityControlSummaryFolderPath = $SecurityControlSummaryFileNameMapping.FileParentDirectory
  $securityControlSummaryLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $SecurityControlSummaryFolderPath $SecurityControlSummaryFileBaseName) -UseUnixPath $true
  #Get the assignments that are directly assigning this policy definition
  $relatedAssignments = $assignments | Where-Object { $_.properties.policyDefinitionId -ieq $initiative.id }

  $definitionData = [ordered]@{
    name       = $initiative.name
    properties = [ordered]@{
      displayName            = $initiative.properties.displayName
      description            = $($initiative.properties.description ? $($initiative.properties.description) : $null)
      metadata               = $metadata
      parameters             = $initiative.properties.parameters
      policyDefinitionGroups = $initiative.properties.policyDefinitionGroups
      policyDefinitions      = $initiative.properties.policyDefinitions | select-Object -Property 'policyDefinitionReferenceId', 'policyDefinitionId', 'parameters', 'groupNames'
    }
    id         = $initiative.id
  }
  $definitionJson = buildPolicyDefinitionJson -PolicyDefinition $definitionData
  $definitionOverviewTableData = [ordered]@{
    displayName = "**$($initiative.properties.displayName)**"
    name        = $initiative.name
    id          = $initiative.id
    type        = $initiative.properties.policyType
    description = $($initiative.properties.description ? $($initiative.properties.description) : $null)
    version     = $initiative.properties.version ?? $metadata.version ?? $null
    InUse       = '``{0}``' -f $initiative.isInUse.ToUpper()
  }
  if ($PageStyle -ieq 'detailed') {
    #Use AzPolicyTest to test definition syntax when the page style is detailed.
    $syntaxTestResult = Test-AzPolicySetDefinition -content $definitionJson -PesterVerbosity 'None'
    $coloredSyntaxTestResult = FormatTestResult -result $syntaxTestResult.Result -WikiStyle $WikiStyle
    $definitionOverviewTableData.Add('TestResult', $coloredSyntaxTestResult)
  }
  $policyDefinitionGroupTableData = @()

  foreach ($policyGroup in $initiative.properties.policyDefinitionGroups) {
    $pm = $null
    $customControl = $null
    #get details from the built-in policy metadata if in use
    if ($policyGroup.additionalMetadataId.length -gt 0) {
      $pm = $policyMetadata | Where-Object { $_.id -ieq $policyGroup.additionalMetadataId }
    } elseif ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
      #look up the policy definition group name in provided custom security control (should match control id)
      $customControl = $CustomSecurityControlFileConfig | Where-Object { $_.ControlId -ieq $policyGroup.name }
    }
    if ($pm) {
      $PolicyMetadataFileNameMapping = getWikiPageFileName -ResourceId $pm.id -wikiFileMapping $wikiFileMapping
      $PolicyMetadataPageFileBaseName = $PolicyMetadataFileNameMapping.FileBaseName
      $PolicyMetadataFolderPath = $PolicyMetadataFileNameMapping.FileParentDirectory
      $securityControlLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $PolicyMetadataFolderPath $PolicyMetadataPageFileBaseName) -UseUnixPath $true

      $policyGroupName = $pm.name
      $source = 'Azure Policy Metadata'
      $policyGroupCategory = $pm.properties.category
      $policyGroupDisplayName = "[$($pm.properties.title)]($securityControlLink)"
    } elseif ($customControl) {
      $customSecControlFileNameMapping = getWikiPageFileName -CustomSecurityControlId $customControl.ControlId -SecurityControlFramework $customControl.Framework -wikiFileMapping $wikiFileMapping
      $customSecControlPageFileBaseName = $customSecControlFileNameMapping.FileBaseName
      $customSecControlFolderPath = $customSecControlFileNameMapping.FileParentDirectory
      $securityControlLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $customSecControlFolderPath $customSecControlPageFileBaseName) -UseUnixPath $true

      $policyGroupName = $customControl.controlId
      $source = 'Custom Security Control'
      $policyGroupCategory = $customControl.category
      $policyGroupDisplayName = "[$($customControl.name)]($securityControlLink)"
    } else {
      $policyGroupName = $policyGroup.name
      $source = 'Policy Initiative'
      $policyGroupCategory = $policyGroup.category ? $policyGroup.category : $null
      $policyGroupDisplayName = $policyGroup.displayName ? $policyGroup.displayName : $null
    }
    $policyDefinitionGroupTableData += [ordered]@{
      Name        = $policyGroupName
      DisplayName = $policyGroupDisplayName
      Category    = $policyGroupCategory
      source      = $source
    }
  }
  $memberPolicyTableData = @()
  foreach ($policy in $initiative.properties.policyDefinitions) {
    $PolicyDefinition = $definitions | Where-Object { $_.id -eq $policy.policyDefinitionId } | Select-object -First 1
    $policyEffectConfig = getPolicyEffect -policyObject $PolicyDefinition
    $effects = $($($policyEffectConfig.effects | ForEach-Object { '`{0}`' -f $_ }) -join ', ')
    $defaultEffect = $policyEffectConfig.defaultEffectValue
    $groupNames = $($($policy.groupNames | ForEach-Object { '`{0}`' -f $_ }) -join ', ')
    $DefinitionFileNameMapping = getWikiPageFileName -ResourceId $PolicyDefinition.id -wikiFileMapping $WikiFileMapping
    $definitionPageFileBaseName = $DefinitionFileNameMapping.FileBaseName
    $definitionFolderPath = $DefinitionFileNameMapping.FileParentDirectory
    $definitionLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $definitionFolderPath $definitionPageFileBaseName) -UseUnixPath $true

    $name = '[{0}]({1})' -f $PolicyDefinition.Name, $definitionLink

    $memberPolicyTableData += [ordered]@{
      ReferenceId   = $policy.policyDefinitionReferenceId
      DisplayName   = $PolicyDefinition.properties.displayName
      Name          = $name
      policyType    = $PolicyDefinition.properties.policyType
      GroupNames    = $groupNames
      Effects       = $effects
      DefaultEffect = $defaultEffect
    }
  }

  $parameterMarkdownContent = buildPolicyDefinitionParametersMarkdown -definition $(ConvertToOrderedHashtable -InputObject $initiative) -caseStyle 'original' -level 3
  $PageContent = ""
  $PageContent += $(newMarkdownHeader -title "Initiative: $($initiative.properties.displayName)" -level 1 -caseStyle 'TItleCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "initiative overview" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "initiative details" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownTable -data $definitionOverviewTableData -Orientation 'vertical')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "initiative metadata" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  $PageContent += "<details>"
  $PageContent += "`n`n"
  $PageContent += "<summary>Click to expand</summary>"
  $PageContent += "`n`n"
  $PageContent += $(newHtmlTable -data $metadata -formatTableHeader $false -WikiStyle $WikiFileMapping.WikiStyle)
  $PageContent += "`n`n"
  $PageContent += "</details>"
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "related resources" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "assignments" -level 3 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  if ($relatedAssignments) {
    $relatedAssignmentsTableData = @()
    foreach ($assignment in $relatedAssignments) {
      $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $AssignmentFileNameMapping.FileBaseName
      $assignmentFolderPath = $AssignmentFileNameMapping.FileParentDirectory
      $assignmentLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true

      $relatedAssignmentsTableData += [ordered]@{
        Name        = "[$($assignment.name)]($assignmentLink)"
        DisplayName = $assignment.properties.displayName
        Description = $assignment.properties.description
      }
    }
    $PageContent += ":bookmark: The following policy assignments are assigning this policy initiative:"
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownTableFromArray -data $relatedAssignmentsTableData)
    $PageContent += "`n`n"
  } else {
    $PageContent += ":bookmark: There are no active Policy Assignments assigning this policy initiative.`n`n"
  }

  $PageContent += $(newMarkdownHeader -title "initiative parameters" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  if ($parameterMarkdownContent.Length -eq 0) {
    $PageContent += ":exclamation: **No parameters defined for this initiative!**`n`n"
  } else {
    $PageContent += "<details>"
    $PageContent += "`n`n"
    $PageContent += "<summary>Click to expand</summary>"
    $PageContent += "`n`n"
    $PageContent += $parameterMarkdownContent
    $PageContent += "`n`n"
    $PageContent += "</details>"
    $PageContent += "`n`n"
  }
  $PageContent += $(newMarkdownHeader -title "policy definition groups" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $notes = @()
  $notes += "Policy definitions in an initiative can be grouped and categorized using `Policy Definition Groups`."
  $notes += "They can be mapped to one or more security controls from your organization's preferred security frameworks."
  if ($pageStyle -ieq 'detailed') {
    $notes += "You can define control IDs of your preferred security framework (i.e. ISO27001-2013) here and map them to each member policy."
    $notes += "In Azure portal, you can only view the details of the mapped security controls if they are predefined in Azure as Policy Metadata resources."
    $notes += "On this page, you can also view details of the security controls that your organization has defined that are not available in Azure (i.e. internal security standards or industrial standards that are not defined in Azure)."
    $notes += "Use the [SECURITY CONTROL]($securityControlSummaryLink) page as a reference when mapping the controls for each member policy in this initiative."
  }
  $PageContent += buildQuotedAlert -type tip -messages $notes -contentStyle list -WikiStyle $WikiFileMapping.WikiStyle
  if ($policyDefinitionGroupTableData.count -gt 0) {
    $PageContent += $(newMarkdownTableFromArray -data $policyDefinitionGroupTableData -KeyFormatting @{'Name' = 'code' })
    $PageContent += "`n`n"
    #notes for policy definition group source column
    $PageContent += ":bulb: **Source:**`n`n"
    $PageContent += '- `Azure Policy Metadata`: The policy definition group is mapped to a security control that is predefined in Azure as Policy Metadata.'
    $PageContent += "`n"
    $PageContent += '- `Custom Security Control`: The policy definition group is mapped to a security control that is defined by your organization and is not available in Azure as Policy Metadata.'
    $PageContent += "`n"
    $PageContent += '- `PolicyInitiative`: Hardcoded in the policy initiative definition.'
  } else {
    $PageContent += ":exclamation: **No policy definition groups defined in this initiative!**`n`n"
  }


  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "included policies" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownTableFromArray -data $memberPolicyTableData -KeyFormatting @{'ReferenceId' = 'code'; 'DefaultEffect' = 'code' })
  $PageContent += "`n`n"
  if ($PageStyle -ieq 'detailed' -and $syntaxTestResult) {
    $PageContent += $(newMarkdownHeader -title "initiative syntax test result" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $notes = @()
    $notes += "Initiative syntax validation is performed using ``AzPolicyTest``, an open-source Pester-based test framework for Azure Policy."
    $notes += "It performs static analysis of the policy initiative against schema requirements and a curated set of best-practice assertions."
    $PageContent += buildQuotedAlert -type tip -messages $notes -contentStyle list -WikiStyle $WikiFileMapping.WikiStyle
    $PageContent += "`n`n"
    $PageContent += "<details>"
    $PageContent += "`n`n"
    $PageContent += "<summary>Click to expand</summary>"
    $PageContent += "`n`n"
    $PageContent += $(buildPolicySyntaxTestResultMarkdown -TestResult $syntaxTestResult)
    $PageContent += "`n`n"
    $PageContent += "</details>"
    $PageContent += "`n`n"
  }
  $PageContent += $(newMarkdownHeader -title "raw initiative definition" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += "<details>"
  $PageContent += "`n`n"
  $PageContent += "<summary>Click to expand</summary>"
  $PageContent += "`n`n"
  $PageContent += $markdownCodeBlock + "json`n"
  $PageContent += $definitionJson
  $PageContent += "`n`n"
  $PageContent += "$markdownCodeBlock`n"
  $PageContent += "`n`n"
  $PageContent += "</details>"
  $PageContent += "`n`n"
  $PageContent
}

# 27. Function to build detailed page content for a policy exemption
function buildPolicyExemptionDetailedPageContent {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $exemption,

    [parameter(Mandatory = $true)]
    [array]
    $assignments,

    [parameter(Mandatory = $true)]
    [string]
    $FromPath,

    [parameter(Mandatory = $true)]
    [int]
    $expiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )
  $wikiStyle = $WikiFileMapping.WikiStyle
  $markdownCodeBlock = '```'
  if ($null -ne $exemption.metadata) {
    #filter out any 'hidden-' metadata
    $metadata = ConvertToOrderedHashtable -InputObject $($exemption.metadata)
    if ($PageStyle -ieq 'basic') {
      $hiddenMetadataNames = $metadata.Keys | Where-Object { $_ -match '^hidden[-_]' }
      foreach ($hiddenMetadataName in $hiddenMetadataNames) {
        $metadata.Remove($hiddenMetadataName)
      }
    }
  }

  if ($exemption.expiresOn -is [datetime]) {
    #format to correct string format
    $strExemptionExpiresOn = $exemption.expiresOn.ToString('yyyy-MM-ddTHH:mm:ssZ')
  } else {
    $strExemptionExpiresOn = $exemption.expiresOn
  }
  $exemptionExpiresOn = FormatExemptionExpiresOn -InputString $strExemptionExpiresOn -warningDays $expiresOnWarningDays -WikiStyle $wikiStyle
  $assignment = $assignments | Where-Object { $_.id -ieq $exemption.policyAssignmentId }
  $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $assignment.id -wikiFileMapping $WikiFileMapping
  $assignmentPageFileBaseName = $AssignmentFileNameMapping.FileBaseName
  $assignmentFolderPath = $AssignmentFileNameMapping.FileParentDirectory
  $assignmentLink = getRelativePath -FromPath $FromPath -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true
  if ($exemption.subscriptionId) {
    $subResourceId = '/subscriptions/{0}' -f $exemption.subscriptionId
    $SubscriptionPageFileNameMapping = getWikiPageFileName -ResourceId $subResourceId -wikiFileMapping $WikiFileMapping
    $subscriptionLink = getRelativePath -FromPath $FromPath -ToPath $(Join-Path $SubscriptionPageFileNameMapping.FileParentDirectory $SubscriptionPageFileNameMapping.FileBaseName) -UseUnixPath $true
  }
  $exemptionOverviewTableData = [ordered]@{
    DisplayName                  = "**$($exemption.displayName)**"
    Name                         = $exemption.name
    Id                           = $exemption.id
    PolicyAssignment             = "[$($assignment.name)]($assignmentLink)"
    Description                  = $($exemption.description ? $($exemption.description) : $null)
    SubscriptionId               = $($exemption.subscriptionId ? "[$($exemption.subscriptionId)]($subscriptionLink)" : $null)
    ResourceGroup                = $($exemption.resourceGroup ? $($exemption.resourceGroup) : $null)
    PolicyDefinitionReferenceIds = $exemption.PolicyDefinitionReferenceIds
    ExemptionCategory            = $exemption.exemptionCategory
    ExpiresOn                    = $exemptionExpiresOn
  }
  if ($exemption.resourceSelectors) {
    $resourceSelectorsJson = $exemption.resourceSelectors | ConvertTo-Json -Depth 10
  }
  $PageContent = ""
  $PageContent += $(newMarkdownHeader -title "Exemption: $($exemption.displayName)" -level 1 -caseStyle 'TitleCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "exemption details" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownTable -data $exemptionOverviewTableData -Orientation 'vertical')
  $PageContent += "`n`n"
  $PageContent += buildExemptionExpiresOnMarkdown -expiresOnWarningDays $expiresOnWarningDays -WikiStyle $wikiStyle
  if ($null -ne $exemption.metadata) {
    $PageContent += $(newMarkdownHeader -title "exemption metadata" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += "<details>"
    $PageContent += "`n`n"
    $PageContent += "<summary>Click to expand</summary>"
    $PageContent += "`n`n"
    $PageContent += $(newHtmlTable -data $metadata -formatTableHeader $false -WikiStyle $WikiStyle)
    $PageContent += "`n`n"
    $PageContent += "</details>"
    $PageContent += "`n`n"
  }

  if ($resourceSelectorsJson) {
    $PageContent += $(newMarkdownHeader -title "resource selectors" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += "<details>"
    $PageContent += "`n`n"
    $PageContent += "<summary>Click to expand</summary>"
    $PageContent += "`n`n"
    $PageContent += $markdownCodeBlock + "json`n"
    $PageContent += $resourceSelectorsJson
    $PageContent += "`n"
    $PageContent += "$markdownCodeBlock`n"
    $PageContent += "`n`n</details>`n`n"
  }
  Write-Verbose $PageContent -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $PageContent
}

# 28. Function to build detailed page content for a policy metadata
function buildPolicyMetadataDetailedPageContent {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $metadata,

    [parameter(Mandatory = $true)]
    [System.Object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true)]
    [String]
    $outputPath
  )
  $WikiStyle = $WikiFileMapping.WikiStyle
  if ($metadata.properties.title) {
    $title = $metadata.properties.title.trim()
  } else {
    $title = $null
  }
  $isInUse = $metadata.isInUse.toupper()
  $framework = $metadata.framework.toupper()
  $overviewTableData = [ordered]@{
    Id                = $metadata.properties.metadataId ? "**$($metadata.properties.metadataId)**" : $null
    Title             = $title
    Responsibility    = $metadata.properties.owner ? $metadata.properties.owner : $null
    Category          = $metadata.properties.category ? $metadata.properties.category : $null
    Framework         = $framework
    InUse             = $isInUse
    additionalContent = $metadata.properties.additionalContentUrl ? "[Read More]($($metadata.properties.additionalContentUrl))" : $null
    resourceId        = $metadata.id ? $metadata.id : $null
    source            = 'Azure'
  }

  $PageContent = ""
  if ($metadata.properties.metadataId) {
    $PageContent += $(newMarkdownHeader -title "Built-In Control: $($metadata.properties.metadataId)" -level 1 -caseStyle 'UpperCase')
  } else {
    $PageContent += $(newMarkdownHeader -title "Built-In Control: $($metadata.name)" -level 1 -caseStyle 'UpperCase')
  }
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "Overview" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownTable -data $overviewTableData -Orientation 'vertical' -KeyFormatting @{'Category' = 'code'; 'resourceId' = 'code'; 'InUse' = 'code' })
  $PageContent += "`n`n"

  if ($metadata.properties.description) {
    $PageContent += $(newMarkdownHeader -title "Description" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $metadata.properties.description
    $PageContent += "`n`n"
  }

  if ($isInUse -ieq 'true') {
    #Build compliance summary Markdown with mermaid pie chart
    $overallComplianceRatingParams = @{
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      policyMetadataId                     = $metadata.id
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      WikiStyle                            = $WikiStyle
    }
    $overallComplianceRating = getComplianceRatingSummaryForPolicyDefinitionGroup @overallComplianceRatingParams

    $overallComplianceSummaryParams = @{
      header                               = "policy compliance summary"
      description                          = ":memo: This section provides an overview of the policy compliance status for the Security Control ``$($metadata.properties.metadataId)``."
      diagramTitle                         = "Resources Compliance State"
      compliantCount                       = $overallComplianceRating.compliant
      nonCompliantCount                    = $overallComplianceRating.nonCompliant
      conflictCount                        = $overallComplianceRating.conflict
      exemptCount                          = $overallComplianceRating.exempt
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      wikiStyle                            = $wikiStyle
    }
    $PageContent += buildComplianceSummaryMarkdown @overallComplianceSummaryParams
  } else {
    $PageContent += $(newMarkdownHeader -title "Policy Compliance Summary" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += ":bookmark: Compliance summary not available because this security control is current not in use.`n`n"
  }
  $PageContent += $(newMarkdownHeader -title "Related Resources" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  if ($isInUse -ieq 'true') {
    Write-Verbose "  - Get the mapped definitions for policy metadata '$($metadata.id)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    #Get the initiatives where they are defined and get mapped member policies
    $mappedDefinitions = getMappedPoliciesForPolicyDefinitionGroup -policyMetadataId $metadata.id -initiatives $EnvironmentDiscoveryData.initiatives
    Write-Verbose "  - Found $($mappedDefinitions.mappedPolicies.Count) mapped policies." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    if ($mappedDefinitions.mappedPolicies.count -gt 0 ) {
      $mappedDefTableData = @()
      foreach ($item in $mappedDefinitions.mappedPolicies) {
        $initiativeId = $item.policySetDefinitionId
        $initiativeName = $item.policySetName
        $initiativeType = $item.policySetType
        $initiativeIsInUse = $item.policySetIsInUse.toupper()
        $definitionId = $item.policyDefinitionId
        $policyDefinitionReferenceId = $item.policyDefinitionReferenceId
        $definitionId = $item.policyDefinitionId
        $definitionName = $definitionId.split('/')[-1]

        $definitionFileNameMapping = getWikiPageFileName -ResourceId $definitionId -wikiFileMapping $WikiFileMapping
        $definitionLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $definitionFileNameMapping.FileParentDirectory $definitionFileNameMapping.FileBaseName) -UseUnixPath $true
        $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $WikiFileMapping
        $initiativeLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $initiativeFileNameMapping.FileParentDirectory $initiativeFileNameMapping.FileBaseName) -UseUnixPath $true

        #if the initiative is assigned, calculate the compliance rating for each policy definition reference id
        if ($initiativeIsInUse -ieq 'true') {
          $complianceRatingParams = @{
            EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
            policyDefinitionGroupName            = $item.policyDefinitionGroupName
            policyInitiativeId                   = $initiativeId
            policyDefinitionReferenceId          = $policyDefinitionReferenceId
            ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
            WikiStyle                            = $WikiStyle
          }
          $complianceDetails = getComplianceRatingSummaryForPolicyDefinitionGroup @complianceRatingParams
          $complianceRating = $complianceDetails.summary
          $compliancePercentage = $complianceDetails.compliancePercentage
        } else {
          $complianceRating = 'N/A'
          $compliancePercentage = 999 #make sure it stays on the bottom of the list
        }

        $mappedDefTableData += [ordered]@{
          Initiative           = "[$initiativeName]($initiativeLink)"
          ReferenceId          = $policyDefinitionReferenceId
          Definition           = "[$definitionName]($definitionLink)"
          InitiativeAssigned   = $initiativeIsInUse
          ComplianceRating     = $complianceRating
          CompliancePercentage = $compliancePercentage
        }
      }
      $sortedMappedDefTableData = $mappedDefTableData | Sort-Object -Property @{Expression = { [int]$_.CompliancePercentage } }, 'Initiative'
      $PageContent += ":bookmark: This policy metadata has been mapped to $($mappedDefTableData.Count) policy definitions in policy initiatives.`n`n"
      $PageContent += '<details>'
      $PageContent += "`n`n"
      $PageContent += '<summary>Click to expand</summary>'
      $PageContent += "`n`n"
      $PageContent += $(newMarkdownTableFromArray -data $sortedMappedDefTableData -KeyFormatting @{'ReferenceId' = 'code'; 'Assigned' = 'code' } -Properties @('Initiative', 'ReferenceId', 'Definition', 'InitiativeAssigned', 'ComplianceRating'))
      $PageContent += '</details>'
      $PageContent += "`n`n"
    } else {
      #Defined in initiatives but not mapped to member policies
      $definedInInitiativesTableData = @()
      foreach ($item in $mappedDefinitions.definedInitiatives) {
        $initiativeId = $item.policySetDefinitionId
        $initiativeName = $item.policySetName
        $isInUse = $item.isInUse.toUpper()

        $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $WikiFileMapping
        $initiativeLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $initiativeFileNameMapping.FileParentDirectory $initiativeFileNameMapping.FileBaseName) -UseUnixPath $true

        $definedInInitiativesTableData += [ordered]@{
          Initiative         = "[$initiativeName]($initiativeLink)"
          Type               = $initiativeType
          InitiativeAssigned = $initiativeIsInUse
        }
      }
      $PageContent += ":warning: This policy metadata is defined in the following **$($definedInInitiativesTableData.Count)** initiatives but it has not been mapped to any member policies.`n`n"
      $PageContent += '<details>'
      $PageContent += "`n`n"
      $PageContent += '<summary>Click to expand</summary>'
      $PageContent += "`n`n"
      $PageContent += $(newMarkdownTableFromArray -data $definedInInitiativesTableData -KeyFormatting @{'ReferenceId' = 'code'; 'Assigned' = 'code' })
      $PageContent += '</details>'
      $PageContent += "`n`n"
    }

  } else {
    $PageContent += ":bookmark: This policy metadata is not used in any policy initiatives.`n`n"
  }


  if ($metadata.properties.requirements) {
    $PageContent += $(newMarkdownHeader -title "Customer Actions" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $metadata.properties.requirements
    $PageContent += "`n`n"
  }

  $PageContent
}

# 29. Function to build page content for the GitHub SIdebar page
function buildGitHubWikiSideBarPageContent {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki title.')]
    [string]$Title,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig = @(),

    [parameter(Mandatory = $false, HelpMessage = 'Optional. The environment discovery data.')]
    [system.object]$EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )
  $GitHubSidebarFileNameMapping = getWikiPageFileName -summaryPageType 'github_sidebar' -wikiFileMapping $WikiFileMapping
  $MainFileNameMapping = getWikiPageFileName -summaryPageType 'main' -wikiFileMapping $WikiFileMapping
  $AssignmentSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'assignment' -wikiFileMapping $WikiFileMapping
  $DefinitionSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'definition' -wikiFileMapping $WikiFileMapping
  $InitiativeSummaryFileMapping = getWikiPageFileName -summaryPageType 'initiative' -wikiFileMapping $WikiFileMapping
  $ExemptionSummaryFileMapping = getWikiPageFileName -summaryPageType 'exemption' -wikiFileMapping $WikiFileMapping
  $AnalysisSummaryFileMapping = getWikiPageFileName -summaryPageType 'analysis' -wikiFileMapping $WikiFileMapping
  $SubscriptionSummaryFileMapping = getWikiPageFileName -summaryPageType 'subscription' -wikiFileMapping $WikiFileMapping
  $SecurityControlSummaryFileMapping = getWikiPageFileName -summaryPageType 'security_control' -wikiFileMapping $WikiFileMapping
  $PolicyCategorySummaryFileMapping = getWikiPageFileName -summaryPageType 'policy_category' -wikiFileMapping $WikiFileMapping

  $titleLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $MainFileNameMapping.FileParentDirectory $MainFileNameMapping.FileBaseName) -UseUnixPath $true
  $titleContent = "[$Title]($titleLink)"
  $PageContent = ""
  $PageContent += $(newMarkdownHeader -title $titleContent -level 1 -caseStyle 'UpperCase')
  $PageContent += "`n`n"

  #Assignments
  if ($EnvironmentDiscoveryData.assignments.Count -gt 0) {
    $assignmentLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $AssignmentSummaryFileNameMapping.FileParentDirectory $AssignmentSummaryFileNameMapping.FileBaseName) -UseUnixPath $true
    $PageContent += $(newMarkdownHeader -title "[ASSIGNMENTS]($assignmentLink)" -level 2 -caseStyle 'Original')
    $PageContent += "`n`n"
  }

  #Initiatives
  if ($EnvironmentDiscoveryData.initiatives.Count -gt 0) {
    $initiativeLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $InitiativeSummaryFileMapping.FileParentDirectory $InitiativeSummaryFileMapping.FileBaseName) -UseUnixPath $true
    $PageContent += $(newMarkdownHeader -title "[INITIATIVES]($initiativeLink)" -level 2 -caseStyle 'Original')
    $PageContent += "`n`n"
  }

  #Definitions
  if ($EnvironmentDiscoveryData.definitions.Count -gt 0) {
    $definitionLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $DefinitionSummaryFileNameMapping.FileParentDirectory $DefinitionSummaryFileNameMapping.FileBaseName) -UseUnixPath $true
    $PageContent += $(newMarkdownHeader -title "[DEFINITIONS]($definitionLink)" -level 2 -caseStyle 'Original')
    $PageContent += "`n`n"
  }

  #Exemptions
  if ($EnvironmentDiscoveryData.exemptions.Count -gt 0) {
    $exemptionLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $ExemptionSummaryFileMapping.FileParentDirectory $ExemptionSummaryFileMapping.FileBaseName) -UseUnixPath $true
    $PageContent += $(newMarkdownHeader -title "[EXEMPTIONS]($exemptionLink)" -level 2 -caseStyle 'Original')
    $PageContent += "`n`n"
  }

  #security control (only for detailed page)
  if ($PageStyle -ieq 'detailed') {
    if ($EnvironmentDiscoveryData.policyMetadata.Count -gt 0 -or $CustomSecurityControlFileConfig.count -gt 0) {
      $securityControlLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $SecurityControlSummaryFileMapping.FileParentDirectory $SecurityControlSummaryFileMapping.FileBaseName) -UseUnixPath $true
      $PageContent += $(newMarkdownHeader -title "[SECURITY CONTROLS]($securityControlLink)" -level 2 -caseStyle 'Original')
      $PageContent += "`n`n"
    }
  }

  #analysis
  $analysisLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $AnalysisSummaryFileMapping.FileParentDirectory $AnalysisSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $PageContent += $(newMarkdownHeader -title "[ANALYSIS]($analysisLink)" -level 2 -caseStyle 'Original')
  $PageContent += "`n`n"

  #policy category
  if ($EnvironmentDiscoveryData.initiatives.Count -gt 0) {
    $policyCategoryLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $PolicyCategorySummaryFileMapping.FileParentDirectory $PolicyCategorySummaryFileMapping.FileBaseName) -UseUnixPath $true
    $PageContent += $(newMarkdownHeader -title "[POLICY CATEGORIES]($policyCategoryLink)" -level 2 -caseStyle 'Original')
    $PageContent += "`n`n"
  }

  #Subscriptions
  if ($EnvironmentDiscoveryData.subscriptions.Count -gt 0) {
    $subscriptionLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $SubscriptionSummaryFileMapping.FileParentDirectory $SubscriptionSummaryFileMapping.FileBaseName) -UseUnixPath $true
    $PageContent += $(newMarkdownHeader -title "[SUBSCRIPTIONS]($subscriptionLink)" -level 2 -caseStyle 'Original')
    $PageContent += "`n"
    $PageContent += '<details>'
    $PageContent += "`n`n"
    $PageContent += '<summary>Click to expand Subscriptions</summary>'

    $PageContent += "`n`n"
    $orderedSubscriptions = $EnvironmentDiscoveryData.subscriptions | Sort-Object name
    foreach ($subscription in $orderedSubscriptions) {
      $SubFileNameMapping = getWikiPageFileName -ResourceId $subscription.id -wikiFileMapping $WikiFileMapping
      $subscriptionLink = getRelativePath -FromPath $GitHubSidebarFileNameMapping.FileParentDirectory -ToPath $(Join-Path $SubFileNameMapping.FileParentDirectory $SubFileNameMapping.FileBaseName) -UseUnixPath $true
      $PageContent += "- [$($subscription.name)]($subscriptionLink)"
      $PageContent += "`n"
    }
    $PageContent += '</details>'
    $PageContent += "`n`n"
  }
  $PageContent
}

# 30. Function to generate the footer content
function buildFooterContent {
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The time stamp.')]
    [ValidateNotNullOrEmpty()]
    [string]$TimeStamp,

    [parameter(Mandatory = $true, HelpMessage = 'Current page parent directory')]
    [string]$CurrentPageParentDirectory
  )

  $MainPageFileNameMapping = getWikiPageFileName -summaryPageType 'main' -wikiFileMapping $WikiFileMapping
  $TimeStamp = $TimeStamp.replace('T', ' ')
  $TimeStamp = $TimeStamp.replace('Z', ' (UTC)')
  $homeLink = getRelativePath -FromPath $CurrentPageParentDirectory -ToPath $(Join-Path $MainPageFileNameMapping.FileParentDirectory $MainPageFileNameMapping.FileBaseName) -UseUnixPath $true
  $pageContent = ":link: [HOME]($homeLink) | Generated by [**AzPolicyLens**](https://aka.ms/AzPolicyLens) | :date: Data collected on: **$TimeStamp**"

  Write-Verbose "[$(getCurrentUTCString)]: Footer Content:" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  Write-Verbose $pageContent -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  $pageContent
}
# 31. Function to build ado footer
function buildAdoFooter {
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The time stamp.')]
    [ValidateNotNullOrEmpty()]
    [string]$TimeStamp,

    [parameter(Mandatory = $true, HelpMessage = 'Current page parent directory')]
    [string]$CurrentPageParentDirectory
  )
  $pageContent = '<!-- Blank -->'
  $pageContent += "`n"
  $pageContent += '---'
  $pageContent += "`n"
  $footerParams = @{
    'WikiFileMapping'            = $WikiFileMapping
    'TimeStamp'                  = $TimeStamp
    'CurrentPageParentDirectory' = $CurrentPageParentDirectory
  }
  $pageContent += buildFooterContent @footerParams
  $pageContent += "`n"
  $pageContent
}
# 32. Function to build Markdown content for the recommendations
function buildRecommendationMarkdown {
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The parent directory for the file that contains the generated Markdown.')]
    [string]$FileParentDirectory,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $false, HelpMessage = 'Optional. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData
  )
  $initiativeCheckPassed = $true
  $definitionCheckPassed = $true
  #deprecated initiatives
  $deprecatedInitiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.isInUse -ieq 'true' -and $_.properties.metadata.deprecated -eq $true }
  #custom initiatives
  $customInitiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.properties.policyType -ieq 'custom' }
  #deprecated definitions
  $deprecatedDefinitions = $EnvironmentDiscoveryData.definitions | Where-Object { $_.isInUse -ieq 'true' -and $_.properties.metadata.deprecated -eq $true }
  #Unassigned custom initiatives
  $unassignedCustomInitiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.isInUse -ieq 'false' -and $_.properties.policyType -ieq 'custom' }
  #Unassigned custom definitions
  $unassignedCustomDefinitions = $EnvironmentDiscoveryData.definitions | Where-Object { $_.isInUse -ieq 'false' -and $_.properties.policyType -ieq 'custom' }
  #directly assigned policy definitions
  $definitionAssignments = $EnvironmentDiscoveryData.assignments | Where-Object { $_.properties.policyDefinitionId -match '(?i)\/providers\/microsoft.authorization\/policydefinitions\/' }

  #get unused policy definition group from custom initiatives
  $unUsedPolicyDefinitionGroupTableData = @()
  foreach ($initiative in $customInitiatives) {
    $unusedPolicyDefinitionGroups = getUnusedPolicyDefinitionGroupsFromInitiative -initiative $initiative
    if ($unusedPolicyDefinitionGroups.count -gt 0) {
      $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiative.id -wikiFileMapping $wikiFileMapping
      $initiativeFileParentDirectory = $initiativeFileNameMapping.FileParentDirectory
      $initiativeFileBaseName = $initiativeFileNameMapping.FileBaseName
      $initiativeLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $initiativeFileParentDirectory $initiativeFileBaseName) -UseUnixPath $true
      foreach ($unusedPolicyDefinitionGroup in $unusedPolicyDefinitionGroups) {
        $unUsedPolicyDefinitionGroupTableData += [ordered]@{
          Initiative            = "[$($initiative.name)]($($initiativeLink))"
          PolicyDefinitionGroup = $unusedPolicyDefinitionGroup
        }
      }
    }
  }
  #Custom initiatives that do not have the category metadata defined
  $customInitiativesWithoutCategory = $customInitiatives | Where-Object { -not $_.properties.metadata.category }

  #Get undefined security controls
  $undefinedSecurityControls = @()
  foreach ($initiative in $customInitiatives) {
    #Get all policy definition groups without metadata ID in the initiative
    $policyDefinitionGroupsWithoutMetadataId = $initiative.properties.policyDefinitionGroups | Where-Object { -not $_.additionalMetadataId }
    foreach ($policyDefinitionGroup in $policyDefinitionGroupsWithoutMetadataId) {
      if ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
        #if external security controls are available, check if the policy definition group is defined
        $existingCustomControl = $CustomSecurityControlFileConfig | Where-Object { $_.ControlID -eq $policyDefinitionGroup.name }
        if (-not $existingCustomControl) {
          $initiativeId = $initiative.id
          $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $wikiFileMapping
          $initiativeFileBaseName = $initiativeFileNameMapping.FileBaseName
          $initiativeFolderPath = $initiativeFileNameMapping.FileParentDirectory
          $initiativeLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $initiativeFolderPath $initiativeFileBaseName) -UseUnixPath $true
          $undefinedSecurityControls += [ordered]@{
            Initiative            = "[$($initiative.name)]($($initiativeLink))"
            PolicyDefinitionGroup = $policyDefinitionGroup.name
          }
        }
      } else {
        $initiativeId = $initiative.id
        $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $wikiFileMapping
        $initiativeFileBaseName = $initiativeFileNameMapping.FileBaseName
        $initiativeFolderPath = $initiativeFileNameMapping.FileParentDirectory
        $initiativeLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $initiativeFolderPath $initiativeFileBaseName) -UseUnixPath $true
        #no external security controls are available, add to undefined list
        $undefinedSecurityControls += [ordered]@{
          Initiative            = "[$($initiative.name)]($($initiativeLink))"
          PolicyDefinitionGroup = $policyDefinitionGroup.name
        }
      }
    }
  }

  #get policy definition group that have different names but same policy metadata Id
  $mismatchPolicyDefinitionGroupNames = @()
  $policyDefinitionGroupsWithPolicyMetadata = @()
  foreach ($initiative in $customInitiatives) {
    foreach ($item in $($initiative.properties.policyDefinitionGroups | Where-Object { $_.additionalMetadataId })) {
      $policyDefinitionGroupsWithPolicyMetadata += [PSCustomObject]@{
        Name                 = $item.name
        additionalMetadataId = $item.additionalMetadataId
        initiativeName       = $initiative.name
        initiativeId         = $initiative.id
      }
    }
  }
  $groupedPolicyDefinitionGroups = $policyDefinitionGroupsWithPolicyMetadata | Group-Object -Property additionalMetadataId | where-object { $_.Count -gt 1 }
  foreach ($group in $groupedPolicyDefinitionGroups) {
    $uniqueGroupNames = $group.Group | Select-Object -ExpandProperty Name -Unique
    if ($uniqueGroupNames.Count -gt 1) {
      $misMatchPolicyDefinitionGroupNames += $group
    }
  }
  $pageContent = ''
  $pageContent += $(newMarkdownHeader -title "Recommendations" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += ":memo: This section provides recommendations for improvement for the current environment."
  $pageContent += "`n`n"
  #assignment recommendations
  $pageContent += $(newMarkdownHeader -title "Policy Assignment Recommendations" -level 3 -caseStyle 'TitleCase')
  $pageContent += "`n`n"

  if ($definitionAssignments.Count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Assignment Recommendations for directly assigned definitions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Directly Assigned Policy Definitions**`n`n"
    $pageContent += ":exclamation: **$($definitionAssignments.Count) policy definitions are directly assigned to management groups or subscriptions.**`n`n"
    $pageContent += "It is recommended to use policy initiatives to group related policy definitions together and assign the policy initiatives."
    $pageContent += "`n`n"
    $pageContent += "To learn more about using policy initiatives, please refer to the [Microsoft Documentation](https://learn.microsoft.com/azure/governance/policy/concepts/initiative-definition-structure).`n`n"
    #build the table
    $arrDefAssignments = @()
    foreach ($item in $definitionAssignments) {
      $assignmentPageFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $wikiFileMapping
      $assignmentPageFileBaseName = $assignmentPageFileNameMapping.FileBaseName
      $assignmentFolderPath = $assignmentPageFileNameMapping.FileParentDirectory
      $assignmentLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $assignmentFolderPath $assignmentPageFileBaseName) -UseUnixPath $true
      $arrDefAssignments += [ordered]@{
        'Name'        = "[$($item.name)]($assignmentLink)"
        'DisplayName' = $item.properties.displayName
        'Description' = $item.properties.description
      }
    }
    $pageContent += "<details>"
    $pageContent += "`n`n"
    $pageContent += "<summary>Click to expand</summary>"
    $pageContent += "`n`n"
    $pageContent += $(newMarkdownTableFromArray -Data $arrDefAssignments -FormatTableHeader $true)
    $pageContent += "`n`n"
    $pageContent += "</details>"
    $pageContent += "`n`n"

  } else {
    Write-Verbose "[$(getCurrentUTCString)]: No Policy Assignments recommendations found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += ":tada: **No Policy Assignments recommendations found.**"
    $pageContent += "`n`n"
  }

  #initiative recommendations
  $pageContent += $(newMarkdownHeader -title "Policy Initiative Recommendations" -level 3 -caseStyle 'TitleCase')
  $pageContent += "`n`n"
  if ($deprecatedInitiatives.Count -gt 0) {
    $initiativeCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Initiative Recommendations for deprecated initiatives." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Assigned Deprecated Policy Initiatives**`n`n"
    $pageContent += ":exclamation: **$($deprecatedInitiatives.Count) deprecated policy initiatives are currently being assigned and may not be supported in the future.**`n`n"
    $pageContent += "The following policy initiatives have been marked as deprecated in the metadata.`n`n"
    $pageContent += "Please review, evaluate and replace them with the up-to-date replacement initiatives. If they are no longer required, please produce a plan to decommission them.`n`n"
    $pageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $deprecatedInitiatives -WikiFileMapping $WikiFileMapping -policyResourceType 'initiative'
    $pageContent += "`n`n"
  }
  if ($unassignedCustomInitiatives.Count -gt 0) {
    $initiativeCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Initiative Recommendations for unassigned custom initiatives." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Unassigned Custom Policy Initiatives**`n`n"
    $pageContent += ":exclamation: **$($unassignedCustomInitiatives.Count) Unassigned custom Policy Initiatives detected.**`n`n"
    $pageContent += "They may have been created for testing in the past or may not be needed anymore. Please review and delete them if they are no longer required."
    $pageContent += "`n`n"
    $pageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $unassignedCustomInitiatives -WikiFileMapping $WikiFileMapping -policyResourceType 'initiative'
    $pageContent += "`n`n"
  }
  if ($unUsedPolicyDefinitionGroupTableData.count -gt 0) {
    $initiativeCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Initiative Recommendations for unused policy definition groups." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Unused Policy Definition Groups**`n`n"
    $pageContent += ":exclamation: **$($unUsedPolicyDefinitionGroupTableData.count) Un-Used Policy Definition Groups detected from custom Policy Initiatives.**`n`n"
    $pageContent += "Please review and delete them from the Policy Initiative definitions if they are no longer required."
    $pageContent += "`n`n"
    $pageContent += "<details>"
    $pageContent += "`n`n"
    $pageContent += "<summary>Click to expand</summary>"
    $pageContent += "`n`n"
    $pageContent += newMarkdownTableFromArray -Data $unUsedPolicyDefinitionGroupTableData -FormatTableHeader $true
    $pageContent += "`n`n"
    $pageContent += "</details>"
    $pageContent += "`n`n"
  }
  if ($undefinedSecurityControls.count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Initiative Recommendations for undefined security controls." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Undefined Security Controls in Custom Policy Initiatives**`n`n"
    $pageContent += ":exclamation: **$($undefinedSecurityControls.count) Undefined Security Controls detected from custom Policy Initiatives.**`n`n"
    $pageContent += "Please review and map them to the appropriate security controls."
    $pageContent += "`n`n"
    $pageContent += "To map it to a built-in security control defined as an Azure Policy Metadata, add the ``additionalMetadataId`` property in the Policy Definition Group.`n`n"
    $pageContent += "To map it to a custom security control which can be viewed in this wiki, please sure a custom security control with the exact same name is imported into the wiki page when the wiki is generated. `n`n"
    $pageContent += "To learn more about the Policy Definition Group in the Policy Initiative definition, please refer to the [Microsoft documentation](https://learn.microsoft.com/azure/governance/policy/concepts/initiative-definition-structure#policy-definition-groups).`n`n"
    $pageContent += "<details>"
    $pageContent += "`n`n"
    $pageContent += "<summary>Click to expand</summary>"
    $pageContent += "`n`n"
    $pageContent += $(newMarkdownTableFromArray -Data $undefinedSecurityControls -FormatTableHeader $true)
    $pageContent += "`n`n"
    $pageContent += "</details>"
    $pageContent += "`n`n"
  }

  if ($mismatchPolicyDefinitionGroupNames.count -gt 0) {
    $initiativeCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Initiative Recommendations for mismatched policy definition group names." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Mismatch Policy Definition Group Names**`n`n"
    $pageContent += ":exclamation: **$($mismatchPolicyDefinitionGroupNames.count) Policy Definition Groups have different names but the same Policy Metadata ID across different custom policy initiatives.**`n`n"
    $pageContent += "Please review and update them to ensure consistency.`n`n"
    $pageContent += "<details>"
    $pageContent += "`n`n"
    $pageContent += "<summary>Click to expand</summary>"
    $pageContent += "`n`n"
    foreach ($groupName in $mismatchPolicyDefinitionGroupNames) {
      $groupTableData = @()
      $policyMetadataId = $groupName.Name
      $policyMetadata = $EnvironmentDiscoveryData.policyMetadata | Where-Object { $_.id -eq $policyMetadataId }
      $PolicyMetadataFileNameMapping = getWikiPageFileName -ResourceId $policyMetadataId -wikiFileMapping $WikiFileMapping
      $PolicyMetadataFileBaseName = $PolicyMetadataFileNameMapping.FileBaseName
      $PolicyMetadataFolderPath = $PolicyMetadataFileNameMapping.FileParentDirectory
      $PolicyMetadataLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $PolicyMetadataFolderPath $PolicyMetadataFileBaseName) -UseUnixPath $true
      $pageContent += " - [$($policyMetadata.Name)]($PolicyMetadataLink)`n`n"
      foreach ($item in $($groupName.Group | Sort-Object -Property Name)) {
        $initiativeId = $item.initiativeId
        $initiativeName = $item.initiativeName
        $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $WikiFileMapping
        $initiativeFileBaseName = $initiativeFileNameMapping.FileBaseName
        $initiativeFolderPath = $initiativeFileNameMapping.FileParentDirectory
        $initiativeLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $initiativeFolderPath $initiativeFileBaseName) -UseUnixPath $true
        $groupTableData += [ordered]@{
          PolicyDefinitionGroup = $item.Name
          Initiative            = "[$($initiativeName)]($($initiativeLink))"
        }
      }
      $pageContent += $(newMarkdownTableFromArray -Data $groupTableData -FormatTableHeader $true)
      $pageContent += "`n`n"
    }
    $pageContent += "`n`n"
    $pageContent += "</details>"
    $pageContent += "`n`n"
  }

  if ($customInitiativesWithoutCategory.count -gt 0) {
    $initiativeCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Initiative Recommendations for initiatives without category defined in metadata." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Custom Policy Initiatives without Category Metadata**`n`n"
    $pageContent += ":exclamation: **$($customInitiativesWithoutCategory.count) Custom Policy Initiatives do not have the ``category`` metadata defined.**`n`n"
    $pageContent += "The ``category`` is a common metadata field used to classify policy initiatives. This wiki uses this field in various places.`n`n"
    $pageContent += "Please review and update them to ensure they have the appropriate category defined in the metadata."
    $pageContent += "`n`n"
    $customInitiativesWithoutCategoryTableData = @()
    foreach ($initiative in $customInitiativesWithoutCategory) {
      $initiativeId = $initiative.id
      $initiativeName = $initiative.name
      $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $WikiFileMapping
      $initiativeFileBaseName = $initiativeFileNameMapping.FileBaseName
      $initiativeFolderPath = $initiativeFileNameMapping.FileParentDirectory
      $initiativeLink = getRelativePath -FromPath $FileParentDirectory -ToPath $(Join-Path $initiativeFolderPath $initiativeFileBaseName) -UseUnixPath $true
      $customInitiativesWithoutCategoryTableData += [ordered]@{
        Initiative  = "[$($initiativeName)]($($initiativeLink))"
        displayName = $initiative.properties.displayName
      }
    }
    $pageContent += "<details>"
    $pageContent += "`n`n"
    $pageContent += "<summary>Click to expand</summary>"
    $pageContent += "`n`n"
    $pageContent += $(newMarkdownTableFromArray -Data $customInitiativesWithoutCategoryTableData -FormatTableHeader $true)
    $pageContent += "`n`n"
    $pageContent += "</details>"
    $pageContent += "`n`n"
  }

  if ($initiativeCheckPassed -eq $true) {
    Write-Verbose "[$(getCurrentUTCString)]: No Policy Initiative recommendations found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "`n`n"
    $pageContent += ":tada: **No Policy Initiative recommendations found.**"
  }
  $pageContent += "`n`n"

  #definition recommendations
  $pageContent += $(newMarkdownHeader -title "Policy Definition Recommendations" -level 3 -caseStyle 'TitleCase')
  $pageContent += "`n`n"

  if ($deprecatedDefinitions.Count -gt 0) {
    $definitionCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Definition Recommendations for deprecated definitions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Assigned Deprecated Policy Definitions**`n`n"
    $pageContent += ":exclamation: **$($deprecatedDefinitions.Count) deprecated policy definitions are currently being assigned and may not be supported in the future.**`n`n"
    $pageContent += "The following policy definitions have been marked as deprecated in the metadata.`n`n"
    $pageContent += "Please review, evaluate and replace them with the up-to-date replacement policy definitions. If they are no longer required, please produce a plan to decommission them.`n`n"
    $pageContent += "Please review and update your policies accordingly."
    $pageContent += "`n`n"
    $pageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $deprecatedDefinitions -WikiFileMapping $WikiFileMapping -policyResourceType 'definition'
    $pageContent += "`n`n"
  }

  if ($unassignedCustomDefinitions.Count -gt 0) {
    $definitionCheckPassed = $false
    Write-Verbose "[$(getCurrentUTCString)]: Generating Policy Definition Recommendations for unassigned custom definitions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "**Unassigned Custom Policy Definitions**`n`n"
    $pageContent += ":exclamation: **$($unassignedCustomDefinitions.Count) Unassigned custom Policy Definitions detected.**`n`n"
    $pageContent += "They may have been created for testing in the past or may not be needed anymore. Please review and delete them if they are no longer required."
    $pageContent += "`n`n"
    $pageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $unassignedCustomDefinitions -WikiFileMapping $WikiFileMapping -policyResourceType 'definition'
    $pageContent += "`n`n"
  }

  if ($definitionCheckPassed -eq $true) {
    Write-Verbose "[$(getCurrentUTCString)]: No Policy Definition recommendations found." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $pageContent += "`n`n"
    $pageContent += ":tada: **No Policy Definition recommendations found.**"
  }

  $pageContent += "`n`n"
  $pageContent
}

# 33. Function to get the list of files for the custom security controls from the specified path
function getCustomSecurityControlFileConfig {
  [OutputType([array])]
  param (
    [string]$filePath,

    [string]$schemaFilePath
  )
  $arrSecurityControlFiles = @()

  #get all json files from the file path
  $files = Get-ChildItem -Path $filePath -Recurse -File -Include *.json -Exclude *.schema.json
  $schema = Get-Content -Path $schemaFilePath -raw
  Foreach ($f in $files) {
    #Validate the file content against specified JSON schema
    $content = get-content -path $f.FullName -raw
    $json = ConvertFrom-Json -InputObject $content -Depth 10
    if (Test-Json -Json $content -Schema $schema) {
      $arrSecurityControlFiles += @{
        filePath  = $f.FullName
        controlId = $json.ControlID
        name      = $json.name
        category  = $json.category
        framework = $json.framework
      }
    } else {
      Write-Warning "[$(getCurrentUTCString)]: The file '$($f.FullName)' is not a valid custom security control file and will be skipped."
    }
  }
  , $arrSecurityControlFiles
}

# 34. Function to get policy definition group without additional policy metadata id from list of initiatives
function getCustomPolicyDefinitionGroups {
  [OutputType([array])]
  param (
    [array]$initiatives
  )

  $customDefinitionGroupNames = @()
  foreach ($initiative in $initiatives) {
    $customDefinitionGroups = $($initiative.properties.policyDefinitionGroups | Where-Object { $_.additionalMetadataId.length -eq 0 })
    foreach ($cdg in $customDefinitionGroups) {
      $customDefinitionGroupNames += $cdg.name.toupper()
    }
  }
  #dedup
  $customDefinitionGroupNames = $customDefinitionGroupNames | Select-Object -Unique
  $customDefinitionGroupNames
}

# 35. Function to build detailed page content for the custom security controls
function buildCustomSecurityControlDetailedPageMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [System.Object]
    $control,

    [parameter(Mandatory = $true)]
    [bool]
    $isInUse,

    [parameter(Mandatory = $true)]
    [System.Object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true)]
    [String]
    $outputPath
  )
  $WikiStyle = $WikiFileMapping.WikiStyle
  $overviewTableData = [ordered]@{
    Id        = "**$($control.ControlID)**"
    Name      = $control.name
    Category  = $control.category
    Publisher = $control.publisher
    Framework = $control.framework
    InUse     = $isInUse.tostring().toupper()
    source    = 'Custom'
  }

  $PageContent = ""
  $PageContent += $(newMarkdownHeader -title "Custom Control: $($control.ControlID)" -level 1 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownHeader -title "Overview" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $(newMarkdownTable -data $overviewTableData -Orientation 'vertical' -KeyFormatting @{'Category' = 'code'; 'InUse' = 'code' })
  $PageContent += "`n`n"

  if ($control.AdditionalInfo.psobject.properties.Name.count -gt 0) {
    $PageContent += $(newMarkdownHeader -title "Additional Information" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownTable -data $(ConvertToOrderedHashtable -inputObject $control.AdditionalInfo) -Orientation 'vertical')
    $PageContent += "`n`n"
  }

  $PageContent += $(newMarkdownHeader -title "Description" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  $PageContent += $control.description
  $PageContent += "`n`n"

  if ($isInUse -ieq 'true') {
    #Build compliance summary Markdown with mermaid pie chart
    $overallComplianceRatingParams = @{
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      policyDefinitionGroupName            = $control.controlID
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      WikiStyle                            = $WikiStyle
    }
    $overallComplianceRating = getComplianceRatingSummaryForPolicyDefinitionGroup @overallComplianceRatingParams

    $overallComplianceSummaryParams = @{
      header                               = "policy compliance summary"
      description                          = ":memo: This section provides an overview of the policy compliance status for the Security Control ``$($control.ControlID)``."
      diagramTitle                         = "Resources Compliance State"
      compliantCount                       = $overallComplianceRating.compliant
      nonCompliantCount                    = $overallComplianceRating.nonCompliant
      conflictCount                        = $overallComplianceRating.conflict
      exemptCount                          = $overallComplianceRating.exempt
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      wikiStyle                            = $wikiStyle
    }
    $PageContent += buildComplianceSummaryMarkdown @overallComplianceSummaryParams
  } else {
    $PageContent += $(newMarkdownHeader -title "Policy Compliance Summary" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += ":bookmark: Compliance summary not available because this security control is current not in use.`n`n"
  }

  $PageContent += $(newMarkdownHeader -title "Related Resources" -level 2 -caseStyle 'UpperCase')
  $PageContent += "`n`n"
  if ($isInUse -ieq 'true') {
    Write-Verbose "  - Get the mapped definitions for custom security control '$($control.ControlID)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    #Get the initiatives where they are defined and get mapped member policies
    $mappedDefinitions = getMappedPoliciesForPolicyDefinitionGroup -policyDefinitionGroupName $control.ControlID -initiatives $EnvironmentDiscoveryData.initiatives
    Write-Verbose "  - Found $($mappedDefinitions.mappedPolicies.Count) mapped policies." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    if ($mappedDefinitions.mappedPolicies.count -gt 0 ) {
      $mappedDefTableData = @()
      foreach ($item in $mappedDefinitions.mappedPolicies) {
        $initiativeId = $item.policySetDefinitionId
        $initiativeName = $item.policySetName
        $initiativeType = $item.policySetType
        $initiativeIsInUse = $item.policySetIsInUse.toupper()
        $definitionId = $item.policyDefinitionId
        $policyDefinitionReferenceId = $item.policyDefinitionReferenceId
        $definitionId = $item.policyDefinitionId
        $definitionName = $definitionId.split('/')[-1]
        $definitionFileNameMapping = getWikiPageFileName -ResourceId $definitionId -wikiFileMapping $WikiFileMapping
        $definitionLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $definitionFileNameMapping.FileParentDirectory $definitionFileNameMapping.FileBaseName) -UseUnixPath $true

        $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $WikiFileMapping
        $initiativeLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $initiativeFileNameMapping.FileParentDirectory $initiativeFileNameMapping.FileBaseName) -UseUnixPath $true

        #if the initiative is assigned, calculate the compliance rating for each policy definition reference id
        if ($initiativeIsInUse -ieq 'true') {
          $complianceRatingParams = @{
            EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
            policyDefinitionGroupName            = $item.policyDefinitionGroupName
            policyInitiativeId                   = $initiativeId
            policyDefinitionReferenceId          = $policyDefinitionReferenceId
            ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
            WikiStyle                            = $WikiStyle
          }
          $complianceDetails = getComplianceRatingSummaryForPolicyDefinitionGroup @complianceRatingParams
          $complianceRating = $complianceDetails.summary
          $compliancePercentage = $complianceDetails.compliancePercentage
        } else {
          $complianceRating = 'N/A'
          $compliancePercentage = 999 #make sure it stays on the bottom of the list
        }

        $mappedDefTableData += [ordered]@{
          Initiative           = "[$initiativeName]($initiativeLink)"
          ReferenceId          = $policyDefinitionReferenceId
          Definition           = "[$definitionName]($definitionLink)"
          InitiativeAssigned   = $initiativeIsInUse
          ComplianceRating     = $complianceRating
          CompliancePercentage = $compliancePercentage
        }
      }
      #Sort the table data by compliance percentage, initiative name
      $sortedMappedDefTableData = $mappedDefTableData | Sort-Object -Property @{Expression = { [int]$_.CompliancePercentage } }, 'Initiative'
      $PageContent += ":bookmark: This policy metadata has been mapped to $($mappedDefTableData.Count) policy definitions in policy initiatives.`n`n"
      $PageContent += '<details>'
      $PageContent += "`n`n"
      $PageContent += '<summary>Click to expand</summary>'
      $PageContent += "`n`n"
      $PageContent += $(newMarkdownTableFromArray -data $sortedMappedDefTableData -KeyFormatting @{'ReferenceId' = 'code'; 'Assigned' = 'code' } -Properties @('Initiative', 'ReferenceId', 'Definition', 'InitiativeAssigned', 'ComplianceRating'))
      $PageContent += '</details>'
      $PageContent += "`n`n"
    } else {
      #Defined in initiatives but not mapped to member policies
      $definedInInitiativesTableData = @()
      foreach ($item in $mappedDefinitions.definedInitiatives) {
        $initiativeId = $item.policySetDefinitionId
        $initiativeName = $item.policySetName
        $isInUse = $item.isInUse.toUpper()

        $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiativeId -wikiFileMapping $WikiFileMapping
        $initiativeLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $initiativeFileNameMapping.FileParentDirectory $initiativeFileNameMapping.FileBaseName) -UseUnixPath $true

        $definedInInitiativesTableData += [ordered]@{
          Initiative         = "[$initiativeName]($initiativeLink)"
          Type               = $initiativeType
          InitiativeAssigned = $initiativeIsInUse
        }
      }
      $PageContent += ":warning: This policy metadata is defined in the following **$($definedInInitiativesTableData.Count)** initiatives but it has not been mapped to any member policies.`n`n"
      $PageContent += '<details>'
      $PageContent += "`n`n"
      $PageContent += '<summary>Click to expand</summary>'
      $PageContent += "`n`n"
      $PageContent += $(newMarkdownTableFromArray -data $definedInInitiativesTableData -KeyFormatting @{'ReferenceId' = 'code'; 'Assigned' = 'code' })
      $PageContent += '</details>'
      $PageContent += "`n`n"
    }
  } else {
    $PageContent += ":bookmark: This custom security control is not used in any policy initiatives.`n`n"
  }
  $PageContent
}

# 36. Function to build Markdown content for the exemption expires on note
function buildExemptionExpiresOnMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [int]$expiresOnWarningDays,

    [parameter(Mandatory = $true)]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  $PageContent = ":bulb: **Expires On:**`n`n"
  if ($WikiStyle -ieq 'ado') {
    $PageContent += "- <span style=`"color:#008000`">Green</span>: Expires in more than $expiresOnWarningDays days.`n"
    $PageContent += "- <span style=`"color:#FFA500`">Orange</span>: Expires in less than $expiresOnWarningDays days.`n"
    $PageContent += "- <span style=`"color:#FF0000`">Red</span>: Already expired.`n`n"
  } else {
    $PageContent += "- `$\color{green}{\textsf{Green}}`$: Expires in more than $expiresOnWarningDays days.`n"
    $PageContent += "- `$\color{orange}{\textsf{Orange}}`$: Expires in less than $expiresOnWarningDays days.`n"
    $PageContent += '- $\color{red}{\textsf{Red}}$: Already expired.'
    $PageContent += "`n`n"
  }
  $PageContent
}

# 37. Function to build Markdown content for the compliance rating note
function buildComplianceRatingMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true)]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  $PageContent = ":bulb: **Compliance Rating:**`n`n"
  if ($wikiStyle -ieq 'ado') {
    $PageContent += "- <span style=`"color:#008000`">Green</span>: = 100%`n"
    $PageContent += "- <span style=`"color:#FFA500`">Orange</span>: >= $ComplianceWarningPercentageThreshold%`n"
    $PageContent += "- <span style=`"color:#FF0000`">Red</span>: < $ComplianceWarningPercentageThreshold%`n`n"
  } else {
    $PageContent += "- `$\color{green}{\textsf{Green}}`$: = 100%`n"
    $PageContent += "- `$\color{orange}{\textsf{Orange}}`$: >= $ComplianceWarningPercentageThreshold%`n"
    $PageContent += "- `$\color{red}{\textsf{Red}}`$: < $ComplianceWarningPercentageThreshold%`n`n"
  }
  $PageContent
}

# 38. Function to build quoted rendered alerts https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts
function buildQuotedAlert {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "The message content.")]
    [string[]]$messages,

    [Parameter(Mandatory = $true, HelpMessage = "The alert type. Supported values are 'note', 'tip', 'important', 'warning', and 'caution'.")]
    [ValidateSet('note', 'tip', 'important', 'warning', 'caution')]
    [string]$type,

    [Parameter(Mandatory = $false, HelpMessage = "The content style.")]
    [ValidateSet('normal', 'list')]
    [string]$contentStyle = 'normal',

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  #complete list of supported emojis for github and ADO: https://gist.github.com/rxaviers/7360908
  switch ($type) {
    'note' { $adoEmoji = ':memo: **Note**' }
    'tip' { $adoEmoji = ':bulb: **Tip**' }
    'important' { $adoEmoji = ':grey_exclamation: **Important**' }
    'warning' { $adoEmoji = ':warning: **Warning**' }
    'caution' { $adoEmoji = ':exclamation: **Caution**' }
  }
  $Markdown = "<blockquote>`n`n"
  if ($WikiStyle -ieq 'github') {
    $Markdown += "[!$($type.toupper())]`n`n"
  } else {
    $Markdown += "$adoEmoji`n`n"
  }
  foreach ($message in $messages) {
    if ($contentStyle -ieq 'normal') {
      $Markdown += $message
      $Markdown += "`n"
    } else {
      $Markdown += "- $message`n"
    }
  }
  $Markdown += "`n</blockquote>`n`n"
  $Markdown
}

# 39. Function to convert ASCII Hyphen minus to Unicode Hyphen. This is used to convert the file name for GitHub wiki
function ConvertAsciiHyphenToUnicode {

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$InputString
  )

  process {
    # Convert input string to UTF-8 byte array
    $inputBytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)

    # Define byte constants
    $asciiHyphenByte = 0x2D                    # ASCII hyphen-minus (-)
    $unicodeHyphenBytes = @(0xE2, 0x80, 0x90) # UTF-8 for Unicode hyphen (‐) U+2010

    # Create dynamic byte array for output
    $outputBytes = New-Object System.Collections.Generic.List[System.Byte]

    # Process each byte in the input
    for ($i = 0; $i -lt $inputBytes.Length; $i++) {
      $currentByte = $inputBytes[$i]

      if ($currentByte -eq $asciiHyphenByte) {
        # Replace ASCII hyphen with Unicode hyphen bytes
        foreach ($b in $unicodeHyphenBytes) {
          $outputBytes.Add($b)
        }
      } else {
        # Keep original byte unchanged
        $outputBytes.Add($currentByte)
      }
    }

    # Convert result bytes back to string
    $resultString = [System.Text.Encoding]::UTF8.GetString($outputBytes.ToArray())

    $resultString
  }
}

# 40. Function to format string for Markdown table rows
function FormatMarkdownTableString {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [AllowEmptyString()]
    [string]$InputString,

    [Parameter(Mandatory = $false)]
    [switch]$FormatAsCode
  )

  process {
    # Escape pipe characters for Markdown table
    $escapedString = $InputString -replace '\|', '\|'
    #replace newlines with spaces
    $escapedString = $escapedString -replace '\r?\n', ' '
    # Format as code if requested
    if ($FormatAsCode) {
      return "``$escapedString``"
    } else {
      return $escapedString
    }
  }
}

# 41. Function for Markdown header
function newMarkdownHeader {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = "Specify the title of the Markdown file.")]
    [string]$title,

    [parameter(Mandatory = $false, HelpMessage = "Specify the Casing style of the title.")]
    [ValidateSet('UpperCase', 'TitleCase', 'LowerCase', 'Original')]
    [string]$CaseStyle = 'Original',

    [parameter(Mandatory = $true, HelpMessage = "Specify the level.")]
    [ValidateSet(1, 2, 3, 4, 5, 6)]
    [int]$Level
  )

  switch ($CaseStyle) {
    'UpperCase' { $formattedTitle = $title.ToUpper() }
    'TitleCase' { $formattedTitle = ConvertToTitleCase -InputString $title }
    'LowerCase' { $formattedTitle = $title.ToLower() }
    'Original' { $formattedTitle = $title }
  }
  Write-verbose "Formatted title: $formattedTitle" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $headerCharacter = '#'
  $header = "{0} {1}" -f ($headerCharacter * $Level), $formattedTitle
  Write-Verbose "Markdown header: '$header'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $header
}

# 42. Function to generate a HTML table
function newHtmlTable {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Hashtable containing the data to display in the table")]
    [System.Collections.Specialized.IOrderedDictionary]$Data,

    [Parameter(Mandatory = $false, HelpMessage = "Format table header by splitting camel or pascal case strings and convert to title case")]
    [Boolean]$FormatTableHeader = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Keys to format specifically (e.g. 'id' as code)")]
    [hashtable]$KeyFormatting = @{ 'id' = 'code' },

    [Parameter(Mandatory = $false, HelpMessage = "value color mapping (e.g. 'Enabled' as green, 'Disabled' as red)")]
    [hashtable]$valueColorMapping = @{ 'Enabled' = '#008000'; 'Disabled' = '#FF0000' },

    [Parameter(Mandatory = $false, HelpMessage = "Format All keys as code")]
    [switch]$FormatAllKeysAsCode,

    [parameter(Mandatory = $false, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle = 'ado'
  )

  $htmlTable = "<table>`n"
  foreach ($key in $Data.Keys) {
    $value = $Data[$key]
    if ($value -is [array] -and $value.Count -gt 0) {
      #convert to a HTML list
      $value = newHTMLList -Items $value -ListType Unordered -FormatAsCode
    }
    #value color mapping
    if ($value) {
      if ($valueColorMapping.ContainsKey($value)) {
        $colorCode = $valueColorMapping[$value]
        if ($WikiStyle -ieq 'ado') {
          $tdAttrWithColor = " style=`"color:$colorCode`""
        } else {
          $tdAttrWithColor = "`$\color{$colorCode}{\textsf "
        }
      } else {
        $tdAttrWithColor = ""
      }
    }
    # Apply special formatting if defined for this key
    if ($KeyFormatting.ContainsKey($key)) {
      $format = $KeyFormatting[$key]
      if ($format -eq 'code') {
        $value = "<code>$value</code>"
      }
    }
    # Apply special formatting if defined for this key
    if ($FormatAllKeysAsCode) {
      $value = "<code>$value</code>"
    }
    #Add link if the value is a URL
    if ($Data[$key] -is [string] -and $Data[$key] -imatch '^https?://') {
      $value = "<a href=`"$($Data[$key])`">$value</a>"
    }
    if ($FormatTableHeader) {
      $th = $(ConvertToTitleCase -InputString $(SplitPascalCamelCaseString -InputString $key))
    } else {
      $th = $key
    }

    if ($WikiStyle -ieq 'ado') {
      $tdOpenBracket = "<td$tdAttrWithColor>"
      $tdValue = $tdOpenBracket + $value + "</td>`n"
    } else {
      $tdOpenBracket = "<td>$tdAttrWithColor"
      if ($colorCode) {
        $tdValue = $tdOpenBracket + $value + "}`$" + "</td>`n"
      } else {
        $tdValue = $tdOpenBracket + $value + "</td>`n"
      }
    }

    $htmlTable += "  <tr>`n"
    $htmlTable += "    <th>$th</th>`n"
    $htmlTable += "    $tdValue"
    $htmlTable += "  </tr>`n"
    $colorCode = $null
  }

  # Close the table
  $htmlTable += "</table>"
  return $htmlTable
}

# 43. Function to generate a Markdown table
function newMarkdownTable {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Hashtable containing the data to display in the table")]
    [System.Collections.Specialized.IOrderedDictionary]$Data,

    [Parameter(Mandatory = $false, HelpMessage = "Table orientation: Vertical (key-value pairs in rows) or Horizontal (keys as column headers)")]
    [ValidateSet('Vertical', 'Horizontal')]
    [string]$Orientation = 'Vertical',

    [Parameter(Mandatory = $false, HelpMessage = "Format table header by splitting camel or pascal case strings and convert to title case")]
    [Boolean]$FormatTableHeader = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Keys to format specifically (e.g. 'id' as code)")]
    [hashtable]$KeyFormatting = @{ 'id' = 'code' },

    [Parameter(Mandatory = $false, HelpMessage = "Alignment for columns: Left, Center, or Right")]
    [ValidateSet('Left', 'Center', 'Right')]
    [string]$Alignment = 'Left'
  )

  $markdownTable = ""

  # Format based on requested orientation
  if ($Orientation -eq 'Vertical') {
    # Vertical table - two columns: Property and Value
    $markdownTable += "| Property | Value | `n"

    # Add alignment row
    switch ($Alignment) {
      'Left' { $markdownTable += "| :--------- | :------ |`n" }
      'Center' { $markdownTable += "| :--------: | :-----: |`n" }
      'Right' { $markdownTable += "| --------- : | ------: |`n" }
    }

    # Add data rows
    foreach ($key in $Data.Keys) {
      $value = $Data[$key]

      #remove line breaks and trim the value
      $value = $value -replace '\r?\n', ' '
      $value = $value.tostring().Trim()

      # Apply special formatting if defined for this key
      if ($KeyFormatting.ContainsKey($key)) {
        $format = $KeyFormatting[$key]
        if ($format -eq 'code') {
          $value = '`{0}`' -f $value
        }
      }

      # Escape pipe characters in values
      if ($FormatTableHeader) {
        $escapedKey = $(ConvertToTitleCase -InputString $(SplitPascalCamelCaseString -InputString $key)) -replace '\|', '\|'
      } else {
        $escapedKey = $key -replace '\|', '\|'
      }
      $escapedValue = $value -replace '\|', '\|'
      $markdownTable += "| $escapedKey | $escapedValue | `n"
    }
  } else {
    # Horizontal table - keys as column headers, one row of values
    # Header row
    $markdownTable += "| "
    $HeaderLine = ''
    foreach ($key in $Data.Keys) {
      if ($FormatTableHeader) {
        $escapedKey = $(ConvertToTitleCase -InputString $(SplitPascalCamelCaseString -InputString $key)) -replace '\|', '\|'
      } else {
        $escapedKey = $key -replace '\|', '\|'
      }
      $HeaderLine += " $escapedKey | "
    }
    $HeaderLine = $HeaderLine.trim()
    $markdownTable += $HeaderLine
    $markdownTable += "`n"

    # Alignment row
    $markdownTable += "| "
    $AlignmentLine = ''
    foreach ($key in $Data.Keys) {
      switch ($Alignment) {
        'Left' { $AlignmentLine += ":----- | " }
        'Center' { $AlignmentLine += ":----: | " }
        'Right' { $AlignmentLine += "----- : | " }
      }
    }
    $AlignmentLine = $AlignmentLine.trim()
    $markdownTable += $AlignmentLine
    $markdownTable += "`n"

    # Data row
    $markdownTable += "| "
    foreach ($key in $Data.Keys) {
      $value = $Data[$key]

      # Apply special formatting if defined for this key
      if ($KeyFormatting.ContainsKey($key)) {
        $format = $KeyFormatting[$key]
        if ($format -eq 'code') {
          $value = '`{0}`' -f $value
        }
      }

      # Escape pipe characters in values
      $escapedValue = $value -replace '\|', '\|'
      $markdownTable += ' {0} |' -f $escapedValue
    }
    $markdownTable += "`n"
  }

  return $markdownTable
}

# 44. Function to generate a Markdown table from an array of objects
function newMarkdownTableFromArray {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Array of objects to display in the table")]
    [System.Collections.Specialized.IOrderedDictionary[]]$Data,

    [Parameter(Mandatory = $false, HelpMessage = "Properties to include in the table")]
    [string[]]$Properties,

    [Parameter(Mandatory = $false, HelpMessage = "Format table header by splitting camel or pascal case strings and convert to title case")]
    [Boolean]$FormatTableHeader = $true,

    [Parameter(Mandatory = $false, HelpMessage = "Keys to format specifically (e.g. 'id' as code)")]
    [hashtable]$KeyFormatting = @{ 'id' = 'code' },

    [Parameter(Mandatory = $false, HelpMessage = "Default alignment for columns: Left, Center, or Right")]
    [ValidateSet('Left', 'Center', 'Right')]
    [string]$Alignment = 'Left',

    [Parameter(Mandatory = $false, HelpMessage = "Column-specific alignment (e.g. @{'Name' = 'Left'; 'Count' = 'Center'})")]
    [hashtable]$ColumnAlignment = @{}
  )

  if ($Data.Count -eq 0) {
    return ""
  }

  # Determine properties to use
  if (-not $Properties) {
    # Get all properties from the first object
    $Properties = $Data[0].keys
  }

  $markdownTable = ""

  # Header row
  $headerRow = ""
  $headerRow += "| "
  foreach ($prop in $Properties) {
    if ($FormatTableHeader) {
      $escapedProp = $(ConvertToTitleCase -InputString $(SplitPascalCamelCaseString -InputString $prop)) -replace '\|', '\|'
    } else {
      $escapedProp = $prop -replace '\|', '\|'
    }
    $headerRow += " $escapedProp | "
  }
  $headerRow = $headerRow.trim()
  $markdownTable += $headerRow
  $markdownTable += "`n"

  # Alignment row
  $alignmentRow = ""
  $alignmentRow += "| "
  foreach ($prop in $Properties) {
    # Check if column-specific alignment is defined, otherwise use default
    $colAlignment = if ($ColumnAlignment.ContainsKey($prop)) { $ColumnAlignment[$prop] } else { $Alignment }
    switch ($colAlignment) {
      'Left' { $alignmentRow += ":----- | " }
      'Center' { $alignmentRow += ":----: | " }
      'Right' { $alignmentRow += "----- : | " }
    }
  }
  $alignmentRow = $alignmentRow.trim()
  $markdownTable += $alignmentRow
  $markdownTable += "`n"

  # Data rows
  foreach ($item in $Data) {
    $dataRow = ""
    $dataRow += "| "
    foreach ($prop in $Properties) {
      $value = $item.$prop
      #remove line breaks and trim the value
      $value = $value -replace '\r?\n', ' '
      $value = $value.Trim()
      # Apply special formatting if defined for this property
      if ($KeyFormatting.ContainsKey($prop)) {
        $format = $KeyFormatting[$prop]
        if ($format -eq 'code') {
          $value = '`{0}`' -f $value
        }
      }

      # Handle null or empty values
      if ([string]::IsNullOrEmpty($value)) {
        $escapedValue = ""
      } else {
        # Escape pipe characters in values
        $escapedValue = FormatMarkdownTableString -InputString $value
      }

      $dataRow += " $escapedValue | "
      $dataRow = $dataRow.trim()
    }
    $markdownTable += $dataRow
    $markdownTable += "`n"
  }

  return $markdownTable
}

# 45. Function to build HTML list for an array of strings
Function newHTMLList {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [string[]]$Items,

    [Parameter(Mandatory = $false, HelpMessage = "List type: Ordered (numbered) or Unordered (bulleted)")]
    [ValidateSet('Ordered', 'Unordered')]
    [string]$ListType = 'Unordered',

    [Parameter(Mandatory = $false, HelpMessage = "HTML attributes for the list")]
    [hashtable]$ListAttributes = @{},

    [Parameter(Mandatory = $false, HelpMessage = "Format items as code")]
    [switch]$FormatAsCode,

    [Parameter(Mandatory = $false, HelpMessage = "Enable HTML encoding for special characters")]
    [switch]$EncodeHtml
  )

  # Determine list tag based on type
  $listTag = if ($ListType -ieq 'Ordered') { 'ol' } else { 'ul' }

  # Build list attributes
  $listAttr = ""
  if ($ListAttributes.Count -gt 0) {
    foreach ($key in $ListAttributes.Keys) {
      $listAttr += " $key=`"$($ListAttributes[$key])`""
    }
  }

  # Start the list
  $htmlList = "<$listTag$listAttr>`n"

  # Add list items
  foreach ($item in $Items) {
    $listItem = $item

    # Encode HTML if requested
    if ($EncodeHtml) {
      $listItem = [System.Web.HttpUtility]::HtmlEncode($listItem)
    }

    # Format as code if requested
    if ($FormatAsCode) {
      $listItem = "<code>$listItem</code>"
    }

    $htmlList += "  <li>$listItem</li>`n"
  }

  # Close the list
  $htmlList += "</$listTag>"

  return $htmlList
}

# 46. Function to build detailed page content for the custom security controls
function buildPolicyCategoryDetailedPageMarkdown {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true)]
    [string]
    $categoryName,

    [parameter(Mandatory = $true)]
    [System.Object]
    $categoryDetails,

    [parameter(Mandatory = $true)]
    [System.Object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true)]
    [String]$outputPath
  )
  $WikiStyle = $WikiFileMapping.WikiStyle

  #calculate compliance rate
  $compliantCount = $categoryDetails.compliantCount
  $nonCompliantCount = $categoryDetails.nonCompliantCount
  $conflictCount = $categoryDetails.conflictCount
  $exemptCount = $categoryDetails.exemptCount

  $overviewTableData = [ordered]@{
    Name           = "**$($categoryName)**"
    Initiatives    = $categoryDetails.policyInitiativeCount
    MappedControls = $categoryDetails.policyDefinitionGroups.count
  }
  $initiativeTableData = @()
  $mappedSecurityControlTableData = @()

  #assigned initiatives
  foreach ($resourceId in $categoryDetails.resourceIds) {
    $initiative = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.id -ieq $resourceId }
    if ($initiative) {
      $displayName = $initiative.properties.displayName
      $name = $initiative.name
      $description = $initiative.properties.description

      $initiativeFileNameMapping = getWikiPageFileName -ResourceId $initiative.id -wikiFileMapping $WikiFileMapping
      $initiativeLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $initiativeFileNameMapping.FileParentDirectory $initiativeFileNameMapping.FileBaseName) -UseUnixPath $true

      $initiativeTableData += [ordered]@{
        Name        = "[$name]($initiativeLink)"
        DisplayName = $displayName
        Description = $description

      }
    }
  }
  #security controls mapped to this category
  foreach ($group in $categoryDetails.policyDefinitionGroups) {
    #determine if it's a built-in policy metadata resource id or just the name (for the custom control)
    if ($group -match '(?im)^\/providers\/microsoft\.policyInsights\/policymetadata\/') {
      $securityControl = $EnvironmentDiscoveryData.policyMetadata | Where-Object { $_.id -ieq $group }
      $securityControlFileNameMapping = getWikiPageFileName -ResourceId $securityControl.id -WikiFileMapping $WikiFileMapping
      $securityControlPageLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $securityControlFileNameMapping.FileParentDirectory $securityControlFileNameMapping.FileBaseName) -UseUnixPath $true
      $securityControlName = "[$($securityControl.name)]($securityControlPageLink)"
      $securityControlCategory = $securityControl.properties.category
    } else {
      if ($CustomSecurityControlFileConfig.count -gt 0) {
        $control = $CustomSecurityControlFileConfig | Where-Object { $_.controlId -ieq $group }
        if ($null -ne $control) {
          $securityControl = $control.controlId
          $framework = $control.framework
          $securityControlCategory = $control.category
          $securityControlFileNameMapping = getWikiPageFileName -CustomSecurityControlId $securityControl -SecurityControlFramework $framework -wikiFileMapping $WikiFileMapping
          $securityControlPageLink = getRelativePath -FromPath $outputPath -ToPath $(Join-Path $securityControlFileNameMapping.FileParentDirectory $securityControlFileNameMapping.FileBaseName) -UseUnixPath $true
          $securityControlName = "[$($securityControl)]($securityControlPageLink)"
        } else {
          $securityControlName = $group
          $securityControlCategory = 'N/A'
        }

      } else {
        $securityControlName = $group
        $securityControlCategory = 'N/A'
      }
    }
    $mappedSecurityControlTableData += [ordered]@{
      ControlId = $securityControlName
      Category  = $securityControlCategory
    }

    $PageContent = ""
    $PageContent += $(newMarkdownHeader -title "Policy Category: $categoryName" -level 1 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "Overview" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownTable -data $overviewTableData -Orientation 'Horizontal' -Alignment 'Center')
    $PageContent += "`n`n"

    $overallComplianceSummaryParams = @{
      header                               = "policy compliance summary"
      description                          = ":memo: This section provides an overview of the policy compliance status for the Policy Category ``$categoryName``."
      diagramTitle                         = "Resources Compliance State"
      compliantCount                       = $compliantCount
      nonCompliantCount                    = $nonCompliantCount
      conflictCount                        = $conflictCount
      exemptCount                          = $exemptCount
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      WikiStyle                            = $WikiStyle
    }
    $PageContent += buildComplianceSummaryMarkdown @overallComplianceSummaryParams

    $PageContent += $(newMarkdownHeader -title "Related Resources" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"

    $PageContent += $(newMarkdownHeader -title "Initiatives" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    $PageContent += ":bookmark: This policy category has been defined in $($categoryDetails.policyInitiativeCount) assigned policy initiatives.`n`n"
    $PageContent += '<details>'
    $PageContent += "`n`n"
    $PageContent += '<summary>Click to expand</summary>'
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownTableFromArray -data $initiativeTableData)
    $PageContent += '</details>'
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "Security Controls" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    $PageContent += ":bookmark: $($categoryDetails.policyDefinitionGroups.count) security controls have been mapped to this policy category.`n`n"
    if ($mappedSecurityControlTableData.Count -gt 0) {
      $PageContent += '<details>'
      $PageContent += "`n`n"
      $PageContent += '<summary>Click to expand</summary>'
      $PageContent += "`n`n"
      $PageContent += $(newMarkdownTableFromArray -data $mappedSecurityControlTableData)
      $PageContent += '</details>'
      $PageContent += "`n`n"
    } else {
      $PageContent += ":warning: No security controls have been mapped to this policy category.`n`n"
    }
  }
  $PageContent
}


# 47.function to calculate compliance rating for a security framework and build the Markdown content for the compliance rating summary section
function getComplianceRatingSummaryForFramework {
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The security framework to calculate the compliance rating summary for.')]
    [ValidateNotNullOrEmpty()]
    [string]
    $framework,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style.')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )

  # Get the policy definition groups that are mapped to the specified framework from built-in policy metadata and custom security control config
  $compliantCount = 0
  $nonCompliantCount = 0
  $exemptCount = 0
  $conflictCount = 0
  if ($EnvironmentDiscoveryData.policyMetadata) {
    Write-Verbose "Collecting compliance summary for framework '$framework' for built-in policy metadata." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $policyMetadata = $EnvironmentDiscoveryData.policyMetadata | Where-Object { $_.framework -ieq $framework -and $_.isInUse -eq $true }
    foreach ($pm in $policyMetadata) {
      Write-Verbose "  - Processing policy metadata '$($pm.name)' (ID: $($pm.id))." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $complianceSummary = $EnvironmentDiscoveryData.complianceSummaryByPolicyDefinitionGroup | where-object { $_.policyMetadataId -ieq $pm.id }
      foreach ($cs in $complianceSummary) {
        $compliantCount = $compliantCount + $cs.compliantCount
        $nonCompliantCount = $nonCompliantCount + $cs.nonCompliantCount
        $exemptCount = $exemptCount + $cs.exemptCount
        $conflictCount = $conflictCount + $cs.conflictCount
      }
    }
  }
  if ($CustomSecurityControlFileConfig.count -gt 0) {
    Write-Verbose "Collecting compliance summary for framework '$framework' for custom security control files." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $customControl = $CustomSecurityControlFileConfig | Where-Object { $_.framework -ieq $framework }
    foreach ($control in $customControl) {
      Write-Verbose "  - Processing custom security control '$($control.controlId)'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $complianceSummary = $EnvironmentDiscoveryData.complianceSummaryByPolicyDefinitionGroup | where-object { $_.policyDefinitionGroupName -ieq $control.controlId -and $_.policyMetadataId -eq $null }
      foreach ($cs in $complianceSummary) {
        $compliantCount = $compliantCount + $cs.compliantCount
        $nonCompliantCount = $nonCompliantCount + $cs.nonCompliantCount
        $exemptCount = $exemptCount + $cs.exemptCount
        $conflictCount = $conflictCount + $cs.conflictCount
      }
    }
  }

  $complianceSummaryParams = @{
    description                          = ":memo: This section provides an overview of the policy compliance status for the security framework ``$framework``."
    diagramTitle                         = "Resource Compliance State"
    compliantCount                       = $compliantCount
    nonCompliantCount                    = $nonCompliantCount
    conflictCount                        = $conflictCount
    exemptCount                          = $exemptCount
    ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    wikiStyle                            = $wikiStyle
  }
  $Markdown = buildComplianceSummaryMarkdown @complianceSummaryParams
  $Markdown
}

#48 function to format the test result based on the result (Passed, Failed)
function FormatTestResult {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Passed', 'Failed')]
    [string]$result,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle
  )
  $green = '#008000'
  $red = '#FF0000'
  if ($WikiStyle -ieq 'ado') {
    try {
      if ($result -ieq 'Passed') {
        $spanOpenBracket = "<span style=`"color:{0}`">" -f $green
      } else {
        $spanOpenBracket = "<span style=`"color:{0}`">" -f $red
      }
      $return = "{0}{1}</span>" -f $spanOpenBracket, $result
    } catch {
      Write-Warning "[$(getCurrentUTCString)]: Invalid result '$result'. Returning as is."
      $return = $result
    }
  } else {
    try {
      if ($result -ieq 'Passed') {
        $colorCodedRate = "`$\color{$green}{\textsf " + $result + '}$'
      } else {
        $colorCodedRate = "`$\color{$red}{\textsf " + $result + '}$'
      }
      $return = $colorCodedRate
    } catch {
      Write-Warning "[$(getCurrentUTCString)]: Invalid result '$result'. Returning as is."
      $return = $result
    }
  }
  $return
}
