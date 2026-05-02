using module ./AzPolicyLens.Wiki.Azure.Helper.psm1
using module ./AzPolicyLens.Wiki.Encryption.Helper.psm1
using module ./AzPolicyLens.Wiki.Generic.Helper.psm1
using module ./AzPolicyLens.Wiki.Markdown.Helper.psm1
using module ./AzPolicyLens.Wiki.Platform.Helper.psm1
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1

#region function to generate the top level summary Markdown file
Function newMainSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $false, HelpMessage = 'Optional. The subset of subscription Ids (GUID) to generate the documentation for.')]
    [ValidateScript({ $_ -match '(?im)^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' })]
    [string[]]$SubscriptionIds,

    [parameter(Mandatory = $false, HelpMessage = 'The Id of a child management group to generate the documentation for.')]
    [string]$childManagementGroupId,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The unique assigned policy initiative categories.')]
    [System.Collections.Specialized.OrderedDictionary]
    $uniqueAssignedPolicyInitiativeCategories,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  $AssignmentSummaryFileMapping = getWikiPageFileName -summaryPageType 'assignment' -wikiFileMapping $wikiFileMapping
  $DefinitionSummaryFileMapping = getWikiPageFileName -summaryPageType 'definition' -wikiFileMapping $wikiFileMapping
  $InitiativeSummaryFileMapping = getWikiPageFileName -summaryPageType 'initiative' -wikiFileMapping $wikiFileMapping
  $ExemptionSummaryFileMapping = getWikiPageFileName -summaryPageType 'exemption' -wikiFileMapping $wikiFileMapping
  $SecurityControlSummaryFileMapping = getWikiPageFileName -summaryPageType 'security_control' -wikiFileMapping $wikiFileMapping
  $PolicyCategoryFileMapping = getWikiPageFileName -summaryPageType 'policy_category' -wikiFileMapping $wikiFileMapping
  $AnalysisSummaryFileMapping = getWikiPageFileName -summaryPageType 'analysis' -wikiFileMapping $wikiFileMapping
  $SubscriptionSummaryFileMapping = getWikiPageFileName -summaryPageType 'subscription' -wikiFileMapping $wikiFileMapping
  $SecurityControlsSummaryFileMapping = getWikiPageFileName -summaryPageType 'security_control' -wikiFileMapping $wikiFileMapping
  $MainFileMapping = getWikiPageFileName -summaryPageType 'main' -wikiFileMapping $wikiFileMapping
  $filePaths = @()
  $topLevelManagementGroupName = $EnvironmentDiscoveryData.topLevelManagementGroupName
  #main summary page

  #$MainFileName = encodeAdoWikiPageTitle -stringToEncode $($Title.toupper())
  if ($PageStyle -ieq 'detailed') {
    Write-Verbose "[$(getCurrentUTCString)]: Generating the detailed summary page." -Verbose
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Generating the basic summary page." -Verbose
  }
  Write-Verbose "[$(getCurrentUTCString)]: Main page file name: '$($MainFileMapping.FileName)'." -verbose
  $mainFilePath = $MainFileMapping.FilePath
  Write-Verbose "[$(getCurrentUTCString)]: Generating the main summary Markdown file '$mainFilePath'." -Verbose

  $assignmentFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $AssignmentSummaryFileMapping.FileParentDirectory $AssignmentSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $initiativeFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $InitiativeSummaryFileMapping.FileParentDirectory $InitiativeSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $definitionFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $DefinitionSummaryFileMapping.FileParentDirectory $DefinitionSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $exemptionFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $ExemptionSummaryFileMapping.FileParentDirectory $ExemptionSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $subscriptionFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $SubscriptionSummaryFileMapping.FileParentDirectory $SubscriptionSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $analysisFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $AnalysisSummaryFileMapping.FileParentDirectory $AnalysisSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $securityControlsFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $SecurityControlsSummaryFileMapping.FileParentDirectory $SecurityControlsSummaryFileMapping.FileBaseName) -UseUnixPath $true
  $policyCategoriesFileRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $PolicyCategoryFileMapping.FileParentDirectory $PolicyCategoryFileMapping.FileBaseName) -UseUnixPath $true
  $mgHierarchy = $EnvironmentDiscoveryData.managementGroups
  $topLevelMg = $mgHierarchy | Where-Object { $_.name -ieq $topLevelManagementGroupName }
  $topLevelManagementGroupDisplayName = $topLevelMg.displayName

  #management group summary table
  if ($EnvironmentDiscoveryData.subscriptions.Count -gt 0) {
    $mgSummaryTableSubscriptionValue = "[$($EnvironmentDiscoveryData.subscriptions.Count)]($subscriptionFileRelativePath)"
  } else {
    $mgSummaryTableSubscriptionValue = $EnvironmentDiscoveryData.subscriptions.Count
  }
  $mgSummaryTableData = [ordered]@{
    TopManagementGroup    = "[$($topLevelMg.displayName.toupper())](#$($topLevelMg.name.tolower()))"
    ManagementGroupsCount = "[$($mgHierarchy.Count)](#management-groups)"
    SubscriptionsCount    = $mgSummaryTableSubscriptionValue
  }
  $mgSummaryTable = newMarkdownTable -data $mgSummaryTableData -Orientation 'Horizontal' -formatTableHeader $true -Alignment 'Center'

  #policy resource summary table
  #assignment
  if ($EnvironmentDiscoveryData.assignments.Count -gt 0) {
    $policyAssignmentCountValue = "[$($EnvironmentDiscoveryData.assignments.Count)]($assignmentFileRelativePath)"
  } else {
    $policyAssignmentCountValue = $EnvironmentDiscoveryData.assignments.Count
  }

  #initiative
  if ($EnvironmentDiscoveryData.initiatives.Count -gt 0) {
    $assignedInitiativeCount = ($EnvironmentDiscoveryData.initiatives | Where-Object { $_.isInUse -ieq 'true' }).count
    $policyInitiativeCountValue = "[$assignedInitiativeCount]($initiativeFileRelativePath)"
  } else {
    $policyInitiativeCountValue = $assignedInitiativeCount
  }

  #definition
  if ($EnvironmentDiscoveryData.definitions.Count -gt 0) {
    $assignedDefinitionCount = ($EnvironmentDiscoveryData.definitions | Where-Object { $_.isInUse -ieq 'true' }).count
    $policyDefinitionCountValue = "[$assignedDefinitionCount]($definitionFileRelativePath)"
  } else {
    $policyDefinitionCountValue = $assignedDefinitionCount
  }

  #exemptions
  if ($EnvironmentDiscoveryData.exemptions.Count -gt 0) {
    $policyExemptionCountValue += "[$($EnvironmentDiscoveryData.exemptions.Count)]($exemptionFileRelativePath)"
  } else {
    $policyExemptionCountValue += $EnvironmentDiscoveryData.exemptions.Count
  }

  # Build category table data
  $categoryTableData = @()
  foreach ($category in $uniqueAssignedPolicyInitiativeCategories.Keys) {
    $categoryTableData += [ordered]@{
      Category    = $category
      Initiatives = $uniqueAssignedPolicyInitiativeCategories[$category].policyInitiativeCount
    }
  }
  if ($categoryTableData.Count -gt 0) {
    $categoryMarkdownTable = $(newMarkdownTableFromArray -Data $categoryTableData -FormatTableHeader $true -Alignment 'Left' -ColumnAlignment @{ 'Initiatives' = 'Center' })
  } else {
    $categoryMarkdownTable = ":exclamation: No Categories defined in any assigned policy initiatives."
  }


  $resourceSummaryTableRows = @()
  $resourceSummaryTableRows += [ordered]@{
    ResourceType = 'Policy Assignments'
    Count        = $policyAssignmentCountValue
    Description  = $PageStyle -ieq 'detailed' ? "Assignments that are scoped within the management group hierarchy." : "Assignments applicable to the selected subscriptions."
  }
  $resourceSummaryTableRows += [ordered]@{
    ResourceType = 'Assigned Policy Initiatives'
    Count        = $policyInitiativeCountValue
    Description  = "Assigned initiatives."
  }
  $resourceSummaryTableRows += [ordered]@{
    ResourceType = 'Assigned Policy Definitions'
    Count        = $policyDefinitionCountValue
    Description  = "Definitions that are directly assigned or member of assigned policy initiatives."
  }
  $resourceSummaryTableRows += [ordered]@{
    ResourceType = 'Policy Exemptions'
    Count        = $policyExemptionCountValue
    Description  = $PageStyle -ieq 'detailed' ? "Exemptions from assignment scopes under the management group hierarchy." : "Exemptions applicable to the selected subscriptions."
  }

  $policyResourceMarkdownTable = $(newMarkdownTableFromArray -Data $resourceSummaryTableRows -FormatTableHeader $true -Alignment 'Left')

  Write-Verbose "[$(getCurrentUTCString)]: Found top-level management group '$($topLevelMg.name)' with Id '$($topLevelMg.id)' in the hierarchy." -verbose

  If ($PageStyle -ieq 'detailed') {
    Write-Verbose "[$(getCurrentUTCString)]: Generating the management group hierarchy Mermaid diagram." -Verbose
    $mgHierarchyMermaidDiagram = $(buildMgHierarchyMermaidDiagram -EnvironmentDetails $EnvironmentDiscoveryData -IncludeSubscriptions $true -WikiFileMapping $WikiFileMapping -DiagramVersion 'mainPage')

    Write-Verbose "[$(getCurrentUTCString)]: Generating the Management Group summary Markdown section." -Verbose
    $mgSummaryParams = @{
      managementGroups                     = $EnvironmentDiscoveryData.managementGroups
      assignments                          = $EnvironmentDiscoveryData.assignments
      topManagementGroupId                 = $($topLevelMg.id)
      wikiFileMapping                      = $wikiFileMapping
      assignmentCompliance                 = $EnvironmentDiscoveryData.assignmentCompliance
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    }
    $mgSummaryMarkdown = $(buildManagementGroupSummaryMarkdown @mgSummaryParams)
  }

  #subscriptions compliance summary
  Write-Verbose "[$(getCurrentUTCString)]: Generating the Overall compliance summary section for all subscriptions." -Verbose
  $subscriptionComplianceSummaryHeader = "Overall policy compliance summary"
  if ($EnvironmentDiscoveryData.subscriptionComplianceSummary.count -gt 0) {
    $totalSubCompliantCount = ($EnvironmentDiscoveryData.subscriptionComplianceSummary | Measure-Object -Property 'compliantCount' -Sum).Sum
    $totalSubNonCompliantCount = ($EnvironmentDiscoveryData.subscriptionComplianceSummary | Measure-Object -Property 'nonCompliantCount' -Sum).Sum
    $totalSubConflictCount = ($EnvironmentDiscoveryData.subscriptionComplianceSummary | Measure-Object -Property 'conflictCount' -Sum).Sum
    $totalSubExemptCount = ($EnvironmentDiscoveryData.subscriptionComplianceSummary | Measure-Object -Property 'exemptCount' -Sum).Sum
    if ($PageStyle -ieq 'detailed') {
      if ($childManagementGroupId) {
        $childManagementGroupDisplayName = ($mgHierarchy | Where-Object { $_.name -ieq $childManagementGroupId }).displayName
        $subComplianceSummaryDescription = ":memo: This section provides an overview of the overall policy compliance status for all **$mgSummaryTableSubscriptionValue** subscriptions under the child management group **$($childManagementGroupDisplayName.toupper())**."
      } else {
        $subComplianceSummaryDescription = ":memo: This section provides an overview of the overall policy compliance status for all **$mgSummaryTableSubscriptionValue** subscriptions under the management group **$($topLevelMg.displayName.toupper())**."
      }
    } else {
      $subComplianceSummaryDescription = ":memo: This section provides an overview of the overall policy compliance status for the **$mgSummaryTableSubscriptionValue** subscriptions that are hosting the application."
    }
    $complianceSummaryParams = @{
      header                               = $subscriptionComplianceSummaryHeader
      headerLevel                          = 3
      headerCaseStyle                      = 'TitleCase'
      description                          = $subComplianceSummaryDescription
      diagramTitle                         = "Resources Compliance State"
      compliantCount                       = $totalSubCompliantCount
      nonCompliantCount                    = $totalSubNonCompliantCount
      conflictCount                        = $totalSubConflictCount
      exemptCount                          = $totalSubExemptCount
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      WikiStyle                            = $WikiStyle
    }
    $subscriptionComplianceSummaryMarkdown = buildComplianceSummaryMarkdown @complianceSummaryParams
  } else {
    $subscriptionComplianceSummaryMarkdown = $(newMarkdownHeader -title $subscriptionComplianceSummaryHeader -level 3 -caseStyle 'TitleCase')
    $subscriptionComplianceSummaryMarkdown += "`n`n"
    $subscriptionComplianceSummaryMarkdown += ":exclamation: Compliance Summary Not Available`n`n"
  }
  #Build the summary Markdown content
  $mainPageContent = ""
  $mainPageContent += $(newMarkdownHeader -title "$title summary" -level 1 -caseStyle 'UpperCase')
  $mainPageContent += "`n`n"
  $mainPageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $mainPageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $mainPageContent += "The **``$Title``** Wiki provides detailed information of the Azure Policy related resources for the Azure Management Group **$topLevelManagementGroupDisplayName**(``$($topLevelManagementGroupName.ToUpper())``)."
    $mainPageContent += "`n`n"
    $mainPageContent += "This wiki provides detailed information about the policy ``assignments``, ``initiatives``, ``definitions``, ``exemptions``, and all the Azure ``subscriptions`` under the management group ``$topLevelManagementGroupDisplayName``."
    $mainPageContent += "`n`n"
    $mainPageContent += 'The intended audience for this wiki includes `Azure administrators`, `cloud and security architects`, and anyone involved in managing Azure policies for the entire organization.'
    if ($SubscriptionIds.count -gt 0) {
      $mainPageContent += "`n`n"
      $mainPageContent += ":memo: This  wiki is limited to a subset of subscriptions under the management group hierarchy. The subscriptions in-scope of this wiki are listed in the [Subscription Summary]($subscriptionFileRelativePath) page."
    } elseif ($childManagementGroupId) {
      $mainPageContent += "`n`n"
      $mainPageContent += ":memo: This wiki is limited to the child management group **$($childManagementGroupDisplayName.ToUpper())**. The subscriptions in-scope of this wiki are listed in the [Subscription Summary]($subscriptionFileRelativePath) page."
    }
  } else {
    $mainPageContent += "The **``$Title``** Wiki provides an detailed information of the policy ``assignments``, ``initiatives``, ``definitions``, and ``exemptions`` that impact the following [Azure subscriptions]($subscriptionFileRelativePath) that are hosting the application:"
    $mainPageContent += "`n`n"
    $sortedSubscriptions = $EnvironmentDiscoveryData.subscriptions | sort-object -Property name
    foreach ($sub in $sortedSubscriptions) {
      $subFileNameMapping = getWikiPageFileName -resourceId $sub.id -wikiFileMapping $WikiFileMapping
      $subRelativePath = getRelativePath -FromPath $MainFileMapping.FileParentDirectory -ToPath $(Join-path $subFileNameMapping.FileParentDirectory $subFileNameMapping.FileBaseName) -UseUnixPath $true
      $mainPageContent += "`n- [$($sub.name)]($subRelativePath)"
      $mainPageContent += "`n"
    }
    $mainPageContent += "`n"
    $mainPageContent += 'The intended audience for this wiki are the `application owners`, `application and security architects`, `developers` and `support staff` for a particular application that consumes resources in the subscriptions listed above.'
    $mainPageContent += "`n`n"
    $mainPageContent += "The application team can use this wiki to understand the restriction and requirements for deploying resources to the application landing zones."
  }

  $mainPageContent += "`n`n"
  $mainPageContent += $(newMarkdownHeader -title "overview" -level 2 -caseStyle 'UpperCase')
  $mainPageContent += "`n`n"
  $mainPageContent += $subscriptionComplianceSummaryMarkdown
  $mainPageContent += $(newMarkdownHeader -title "active policy resources" -level 3 -caseStyle 'TitleCase')
  $mainPageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $mainPageContent += ":bookmark: The following Azure Policy resources are active under the management group hierarchy:"
  } else {
    $mainPageContent += ":bookmark: The following Azure Policy resources are active for the in-scope subscriptions:"
  }
  $mainPageContent += "`n`n"
  $mainPageContent += $policyResourceMarkdownTable
  $mainPageContent += "`n`n"
  $mainPageContent += $(newMarkdownHeader -title "policy categories" -level 3 -caseStyle 'TitleCase')
  $mainPageContent += "`n`n"
  if ($categoryTableData.Count -gt 0) {
    $mainPageContent += ":bookmark: **$($categoryTableData.Count)** unique categories have been identified from the `category` metadata property of the assigned policy initiatives:"
    $mainPageContent += "`n`n"
    $mainPageContent += '<details>'
    $mainPageContent += "`n`n"
    $mainPageContent += '<summary>Click to expand Category Details</summary>'
    $mainPageContent += "`n`n"
    $mainPageContent += $categoryMarkdownTable
    $mainPageContent += "`n`n"
    $mainPageContent += '</details>'
  } else {
    $mainPageContent += ":exclamation: No categories defined in the `category` metadata property of any assigned policy initiatives."
  }
  $mainPageContent += "`n`n"

  If ($PageStyle -ieq 'detailed') {
    $mainPageContent += $(newMarkdownHeader -title "analysis and recommendation" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += ":bulb: The [ANALYSIS]($analysisFileRelativePath) page provides an analysis of the current policy coverage for all the resources under the management group hierarchy and recommendations for improvement."
    $mainPageContent += "`n`n"
    $mainPageContent += $(newMarkdownHeader -title "security controls" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += ":bulb: The [SECURITY CONTROLS]($securityControlsFileRelativePath) page provides complete lists of all the built-in security controls (Azure Policy Metadata) and external custom security controls from the security frameworks that the organization has adopted."
    $mainPageContent += "`n`n"
    $mainPageContent += $(newMarkdownHeader -title "policy categories" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += ":bulb: The [POLICY CATEGORIES]($policyCategoriesFileRelativePath) page provides complete lists of all the policy categories from assigned Policy Initiatives, as well as the compliance summary and security control mapping for each category."
    $mainPageContent += "`n`n"
    $mainPageContent += $(newMarkdownHeader -title "hierarchy overview" -level 2 -caseStyle 'UpperCase')
    $mainPageContent += "`n`n"
    $mainPageContent += $(newMarkdownHeader -title "management group summary" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += $mgSummaryTable
    $mainPageContent += "`n`n"
    $mainPageContent += $(newMarkdownHeader -title "management group hierarchy diagram" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += buildQuotedAlert -type 'note' -contentStyle 'normal' -WikiStyle $WikiStyle -messages "This diagram illustrates the hierarchy of management groups and subscriptions under the management group **``$topLevelManagementGroupDisplayName``**."
    $mainPageContent += "`n`n"
    $mainPageContent += "<details>"
    $mainPageContent += "`n`n"
    $mainPageContent += "<summary>Click to expand Management Group Hierarchy Diagram</summary>"
    $mainPageContent += "`n`n"
    $mainPageContent += $mgHierarchyMermaidDiagram
    $mainPageContent += "`n`n"
    $mainPageContent += "</details>"
    $mainPageContent += "`n`n"
    $mainPageContent += $(newMarkdownHeader -title "management groups" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += "The following management groups are part of the hierarchy under the top-level management group **``$topLevelManagementGroupDisplayName``**:"
    $mainPageContent += "`n`n"
    $mainPageContent += $mgSummaryMarkdown
    $mainPageContent += "`n`n"
  } else {
    $mainPageContent += $(newMarkdownHeader -title "analysis" -level 3 -caseStyle 'TitleCase')
    $mainPageContent += "`n`n"
    $mainPageContent += ":bulb: The [ANALYSIS]($analysisFileRelativePath) page provides an analysis of the current policy coverage for all the subscriptions that are part of the application."
  }
  $mainPageContent += "`n`n"

  if ($WikiStyle -ieq 'ado') {
    $mainPageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $MainFileMapping.FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving main summary Markdown file '$mainFilePath'"
  Set-Content -Value $mainPageContent -Path $mainFilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Main Summary Markdown file created in '$mainFilePath'."
  $filePaths += $mainFilePath

  #Create the .order file for the main summary page
  if ($WikiStyle -eq 'ado') {
    #firstly the main page
    $orderFileContent = "$($MainFileMapping.FileBaseName)"
    #then the assignment page
    if ($EnvironmentDiscoveryData.assignments.count -gt 0) {
      $orderFileContent += "`n$($AssignmentSummaryFileMapping.FileBaseName)"
    }
    #then initiative page
    if ($EnvironmentDiscoveryData.initiatives.count -gt 0) {
      $orderFileContent += "`n$($InitiativeSummaryFileMapping.FileBaseName)"
    }
    #then definition page
    if ($EnvironmentDiscoveryData.definitions.count -gt 0) {
      $orderFileContent += "`n$($DefinitionSummaryFileMapping.FileBaseName)"
    }
    #then exemption page
    if ($EnvironmentDiscoveryData.exemptions.count -gt 0) {
      $orderFileContent += "`n$($ExemptionSummaryFileMapping.FileBaseName)"
    }
    #then security control page
    if ($EnvironmentDiscoveryData.policyMetadata.count -gt 0) {
      $orderFileContent += "`n$($SecurityControlSummaryFileMapping.FileBaseName)"
    }
    #then analysis page
    $orderFileContent += "`n$($AnalysisSummaryFileMapping.FileBaseName)"
    #then policy category page
    if ($uniqueAssignedPolicyInitiativeCategories.count -gt 0) {
      $orderFileContent += "`n$($PolicyCategoryFileMapping.FileBaseName)"
    }
    #lastly subscription page
    if ($EnvironmentDiscoveryData.subscriptions.count -gt 0) {
      $orderFileContent += "`n$($SubscriptionSummaryFileMapping.FileBaseName)"
    }
    $filePaths += newAdoWikiOrderFile -FileDirectory $MainFileMapping.FileParentDirectory -content $orderFileContent
  }

  $filePaths
}
#endregion

#region function to generate the assignment summary Markdown file
function newAssignmentSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]

  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  $AssignmentFileNameMapping = getWikiPageFileName -summaryPageType 'assignment' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FileParentDirectory = $AssignmentFileNameMapping.FileParentDirectory
  $FilePath = $AssignmentFileNameMapping.FilePath
  $filePaths = @()

  Write-Verbose "[$(getCurrentUTCString)]: Generating the policy assignment summary Markdown file '$FilePath'." -verbose
  $assignmentPageContent = ""
  $assignmentPageContent += $(newMarkdownHeader -title "$Title Assignments" -level 1 -caseStyle 'UpperCase')
  $assignmentPageContent += "`n`n"
  $assignmentPageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $assignmentPageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $assignmentPageContent += "This page lists all the policy assignments under each management group and subscription in the Management Group hierarchy."
  } else {
    $assignmentPageContent += "This page lists all the policy assignments that are applicable to the following subscriptions:"
    $assignmentPageContent += "`n`n"
    $EnvironmentDiscoveryData.subscriptions | ForEach-Object {
      $assignmentPageContent += "- $($_.name)`n"
    }
  }
  $assignmentPageContent += "`n`n"
  $assignmentPageContent += $(newMarkdownHeader -title "Policy Assignment List" -level 2 -caseStyle 'UpperCase')
  $assignmentPageContent += "`n`n"

  foreach ($mg in $EnvironmentDiscoveryData.managementGroups) {
    $policyAssignmentMarkdownParams = @{
      managementGroup                      = $mg
      assignments                          = $EnvironmentDiscoveryData.assignments
      wikiFileMapping                      = $WikiFileMapping
      resourceTypeFolderPath               = $FileParentDirectory
      includeMgWithoutAssignments          = $false
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      assignmentCompliance                 = $EnvironmentDiscoveryData.assignmentCompliance
    }
    $mgAssignmentTableMarkdown = buildPolicyAssignmentMarkdownTableForMg @policyAssignmentMarkdownParams
    If ($mgAssignmentTableMarkdown) {
      $assignmentPageContent += "$(newMarkdownHeader -title "management group: $($mg.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $assignmentPageContent += $mgAssignmentTableMarkdown
      $assignmentPageContent += "`n"
    }
  }

  foreach ($sub in $EnvironmentDiscoveryData.subscriptions) {
    $subAssignmentMarkdownParams = @{
      subscription                         = $sub
      assignments                          = $EnvironmentDiscoveryData.assignments
      wikiFileMapping                      = $WikiFileMapping
      resourceTypeFolderPath               = $FileParentDirectory
      includeSubWithoutAssignments         = $false
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      assignmentCompliance                 = $EnvironmentDiscoveryData.assignmentCompliance
    }
    $subAssignmentTableMarkdown = buildPolicyAssignmentMarkdownTableForSub @subAssignmentMarkdownParams
    If ($subAssignmentTableMarkdown) {
      $assignmentPageContent += "$(newMarkdownHeader -title "subscription: $($sub.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $assignmentPageContent += $subAssignmentTableMarkdown
    }
  }

  if ($WikiStyle -ieq 'ado') {
    $assignmentPageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving assignment summary Markdown file '$FilePath'"
  Set-Content -Value $assignmentPageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Assignment Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the assignment summary page
  if ($WikiStyle -eq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $WikiFileMapping.AdoResourceDirectories.assignment
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$($AssignmentFileNameMapping.FileBaseName)"
  }
  $filePaths
}
#endregion

#region function to generate the initiative summary Markdown file
function newInitiativeSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  $InitiativeSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'initiative' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $InitiativeSummaryFileNameMapping.FilePath
  $FileParentDirectory = $InitiativeSummaryFileNameMapping.FileParentDirectory
  $filePaths = @()

  $builtInInitiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.properties.policyType -ieq 'builtin' }
  #policy initiative summary page
  Write-Verbose "[$(getCurrentUTCString)]: Generating the policy initiative summary Markdown file '$FilePath'." -verbose
  $initiativePageContent = ""
  $initiativePageContent += $(newMarkdownHeader -title "$Title Initiatives" -level 1 -caseStyle 'UpperCase')
  $initiativePageContent += "`n`n"
  $initiativePageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $initiativePageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $initiativePageContent += "This page lists all the policy initiatives under each management group and subscription in the Management Group hierarchy."
  } else {
    $initiativePageContent += "This page lists all the policy initiatives that are applicable to the following subscriptions:"
    $initiativePageContent += "`n`n"
    $EnvironmentDiscoveryData.subscriptions | ForEach-Object {
      $initiativePageContent += "- $($_.name)`n"
    }
  }
  $initiativePageContent += "`n`n"
  $initiativePageContent += $(newMarkdownHeader -title "Policy Initiatives List" -level 2 -caseStyle 'UpperCase')
  $initiativePageContent += "`n`n"

  foreach ($mg in $EnvironmentDiscoveryData.managementGroups) {
    $mgInitiativeTableMarkdown = buildPolicyDefinitionInitiativeMarkdownTableForScope -resourceId $mg.id -resourceName $mg.name -policyResources $EnvironmentDiscoveryData.initiatives -WikiFileMapping $WikiFileMapping -resourceTypeFolderPath $InitiativeSummaryFileNameMapping.FileParentDirectory -includeTargetWithoutPolicyResources $false

    If ($mgInitiativeTableMarkdown) {
      $initiativePageContent += "$(newMarkdownHeader -title "management group: $($mg.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $initiativePageContent += $mgInitiativeTableMarkdown
    }
  }

  foreach ($sub in $EnvironmentDiscoveryData.subscriptions) {
    $subInitiativeTableMarkdown = buildPolicyDefinitionInitiativeMarkdownTableForScope -resourceId $sub.id -resourceName $sub.name -policyResources $EnvironmentDiscoveryData.initiatives -WikiFileMapping $WikiFileMapping -resourceTypeFolderPath $InitiativeSummaryFileNameMapping.FileParentDirectory -includeTargetWithoutPolicyResources $false
    If ($subInitiativeTableMarkdown) {
      $initiativePageContent += "$(newMarkdownHeader -title "subscription: $($sub.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $initiativePageContent += $subInitiativeTableMarkdown
    }
  }

  #Built-in initiatives section
  $initiativePageContent += "`n`n"
  $initiativePageContent += $(newMarkdownHeader -title "Built-in Policy Initiatives" -level 3 -caseStyle 'UpperCase')
  $initiativePageContent += "`n`n"
  if ($builtInInitiatives.Count -gt 0) {
    $initiativePageContent += "**$($builtInInitiatives.Count)** built-in policy initiatives are currently being assigned."
    $initiativePageContent += "`n`n"
    $initiativePageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $builtInInitiatives -WikiFileMapping $WikiFileMapping -policyResourceType 'initiative'
    $initiativePageContent += "`n`n"
  } else {
    $initiativePageContent += ":bookmark: No built-in Policy Initiatives found."
    $initiativePageContent += "`n`n"
  }

  if ($WikiStyle -ieq 'ado') {
    $initiativePageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving initiative summary Markdown file '$FilePath'"
  Set-Content -Value $initiativePageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Initiative Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the initiative summary page
  if ($WikiStyle -eq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $WikiFileMapping.AdoResourceDirectories.initiative
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$($InitiativeSummaryFileNameMapping.FileBaseName)"
  }
  $filePaths
}
#endregion

#region function to generate the definition summary Markdown file
function newDefinitionSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  $DefinitionSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'definition' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $DefinitionSummaryFileNameMapping.FilePath
  $FileParentDirectory = $DefinitionSummaryFileNameMapping.FileParentDirectory
  $filePaths = @()

  $builtInDefinitions = $EnvironmentDiscoveryData.definitions | Where-Object { $_.properties.policyType -ieq 'builtin' }
  $unassignedBuiltInDefinitions = @()
  #List unassigned built-in definitions (referenced in unassigned custom initiatives) in detailed page as well since they are also part of the environment.
  if ($PageStyle -ieq 'detailed') {
    $existingBuiltInDefinitionIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($d in $builtInDefinitions) {
      if ($d.id) { [void]$existingBuiltInDefinitionIds.Add($d.id) }
    }
    foreach ($item in $EnvironmentDiscoveryData.builtInDefinitionInUnAssignedCustomInitiative) {
      if ($item.id -and -not $existingBuiltInDefinitionIds.Contains($item.id)) {
        $unassignedBuiltInDefinitions += $item
        [void]$existingBuiltInDefinitionIds.Add($item.id)
      }
    }
  }

  #policy definition summary page
  Write-Verbose "[$(getCurrentUTCString)]: Generating the policy definition summary Markdown file in '$FilePath'." -verbose
  $definitionPageContent = ""
  $definitionPageContent += $(newMarkdownHeader -title "$Title Definitions" -level 1 -caseStyle 'UpperCase')
  $definitionPageContent += "`n`n"
  $definitionPageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $definitionPageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $definitionPageContent += "This page lists all the policy definitions under each management group and subscription in the Management Group hierarchy."
  } else {
    $definitionPageContent += "This page lists all the policy definitions that are applicable to the following subscriptions:"
    $definitionPageContent += "`n`n"
    $EnvironmentDiscoveryData.subscriptions | ForEach-Object {
      $definitionPageContent += "- $($_.name)`n"
    }
  }
  $definitionPageContent += "`n`n"
  $definitionPageContent += $(newMarkdownHeader -title "Policy Definitions List" -level 2 -caseStyle 'UpperCase')
  $definitionPageContent += "`n`n"

  foreach ($mg in $EnvironmentDiscoveryData.managementGroups) {
    $mgDefinitionTableMarkdown = buildPolicyDefinitionInitiativeMarkdownTableForScope -resourceId $mg.id -resourceName $mg.name -policyResources $EnvironmentDiscoveryData.definitions -WikiFileMapping $WikiFileMapping -resourceTypeFolderPath $DefinitionSummaryFileNameMapping.FileParentDirectory -includeTargetWithoutPolicyResources $false

    If ($mgDefinitionTableMarkdown) {
      $definitionPageContent += "$(newMarkdownHeader -title "management group: $($mg.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $definitionPageContent += $mgDefinitionTableMarkdown
      $definitionPageContent += "`n"
    }
  }

  foreach ($sub in $EnvironmentDiscoveryData.subscriptions) {
    $subDefinitionTableMarkdown = buildPolicyDefinitionInitiativeMarkdownTableForScope -resourceId $sub.id -resourceName $sub.name -policyResources $EnvironmentDiscoveryData.definitions -WikiFileMapping $WikiFileMapping -resourceTypeFolderPath $DefinitionSummaryFileNameMapping.FileParentDirectory -includeTargetWithoutPolicyResources $false
    If ($subDefinitionTableMarkdown) {
      $definitionPageContent += "$(newMarkdownHeader -title "subscription: $($sub.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $definitionPageContent += $subDefinitionTableMarkdown
      $definitionPageContent += "`n"
    }
  }

  #Built-in definition section
  $definitionPageContent += "`n`n"
  $definitionPageContent += $(newMarkdownHeader -title "Assigned Built-in Policy Definitions" -level 3 -caseStyle 'UpperCase')
  $definitionPageContent += "`n`n"
  if ($builtInDefinitions.Count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Found $($builtInDefinitions.Count) built-in policy definitions." -Verbose
    $definitionPageContent += ":bookmark: **$($builtInDefinitions.Count)** built-in policy definitions are currently being assigned."
    $definitionPageContent += "`n`n"
    $definitionPageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $builtInDefinitions -WikiFileMapping $WikiFileMapping -policyResourceType 'definition'
    $definitionPageContent += "`n`n"
  } else {
    $definitionPageContent += ":bookmark: No built-in policy definitions found."
    $definitionPageContent += "`n`n"
  }

  if ($PageStyle -ieq 'detailed') {
    $definitionPageContent += $(newMarkdownHeader -title "Unassigned Built-in Policy Definitions" -level 3 -caseStyle 'UpperCase')
    $definitionPageContent += "`n`n"
    if ($unassignedBuiltInDefinitions.Count -gt 0) {
      Write-Verbose "[$(getCurrentUTCString)]: Found $($unassignedBuiltInDefinitions.Count) unassigned built-in policy definitions." -Verbose
      $definitionPageContent += ":bookmark: **$($unassignedBuiltInDefinitions.Count)** built-in policy definitions are referenced in unassigned custom initiatives."
      $definitionPageContent += "`n`n"
      $definitionPageContent += buildPolicyDefinitionInitiativeMarkdownTable -policyResources $unassignedBuiltInDefinitions -WikiFileMapping $WikiFileMapping -policyResourceType 'definition'
      $definitionPageContent += "`n`n"
    } else {
      $definitionPageContent += ":bookmark: No built-in policy definitions found in unassigned custom initiatives that are not already assigned."
      $definitionPageContent += "`n`n"
    }
  }
  if ($WikiStyle -ieq 'ado') {
    $definitionPageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }
  Write-Verbose "[$(getCurrentUTCString)]: Saving definition summary Markdown file '$FilePath'"
  Set-Content -Value $definitionPageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Definition Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the definition summary page
  if ($WikiStyle -eq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $WikiFileMapping.AdoResourceDirectories.definition
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$($DefinitionSummaryFileNameMapping.FileBaseName)"
  }

  $filePaths
}
#endregion

#region function to generate the exemption summary Markdown file
function newExemptionSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
    [ValidateRange(7, 90)]
    [int]$ExpiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  $ExemptionFileNameMapping = getWikiPageFileName -summaryPageType 'exemption' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $ExemptionFileNameMapping.FilePath
  $FileParentDirectory = $ExemptionFileNameMapping.FileParentDirectory
  $filePaths = @()

  #policy exemption summary page
  Write-Verbose "[$(getCurrentUTCString)]: Generating the policy exemption summary Markdown file in '$FilePath'." -verbose
  $exemptionPageContent = ""
  $exemptionPageContent += $(newMarkdownHeader -title "$Title Exemptions" -level 1 -caseStyle 'UpperCase')
  $exemptionPageContent += "`n`n"
  $exemptionPageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $exemptionPageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $exemptionPageContent += "This page lists all the policy exemptions under each management group and subscription in the Management Group hierarchy."
  } else {
    $exemptionPageContent += "This page lists all the policy exemptions that are applicable to the following subscriptions:"
    $exemptionPageContent += "`n`n"
    $EnvironmentDiscoveryData.subscriptions | ForEach-Object {
      $exemptionPageContent += "- $($_.name)`n"
    }
  }
  $exemptionPageContent += "`n`n"
  $exemptionPageContent += $(newMarkdownHeader -title "Policy Exemptions List" -level 2 -caseStyle 'UpperCase')
  $exemptionPageContent += "`n`n"

  foreach ($mg in $EnvironmentDiscoveryData.managementGroups) {
    $mgExemptionTableMarkdown = buildPolicyExemptionMarkdownTableForMg -managementGroup $mg -exemptions $EnvironmentDiscoveryData.exemptions -assignments $EnvironmentDiscoveryData.assignments -wikiFileMapping $WikiFileMapping -resourceTypeFolderPath $ExemptionFileNameMapping.FileParentDirectory -includeMgWithoutExemptions $false -expiresOnWarningDays $expiresOnWarningDays
    If ($mgExemptionTableMarkdown) {
      $exemptionPageContent += "$(newMarkdownHeader -title "management group: $($mg.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $exemptionPageContent += $mgExemptionTableMarkdown
      $exemptionPageContent += "`n"
    }
  }

  foreach ($sub in $EnvironmentDiscoveryData.subscriptions) {
    $subExemptionTableMarkdown = buildPolicyExemptionMarkdownTableForSub -subscription $sub -exemptions $EnvironmentDiscoveryData.exemptions -assignments $EnvironmentDiscoveryData.assignments -wikiFileMapping $WikiFileMapping -resourceTypeFolderPath $ExemptionFileNameMapping.FileParentDirectory -includeSubWithoutExemptions $false -expiresOnWarningDays $expiresOnWarningDays
    If ($subExemptionTableMarkdown) {
      $exemptionPageContent += "$(newMarkdownHeader -title "subscription: $($sub.name)" -level 3 -caseStyle 'UpperCase')`n`n"
      $exemptionPageContent += $subExemptionTableMarkdown
    }
  }

  if ($WikiStyle -ieq 'ado') {
    $exemptionPageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving exemption summary Markdown file '$FilePath'"
  Set-Content -Value $exemptionPageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Exemption Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the assignment summary page
  if ($WikiStyle -eq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $WikiFileMapping.AdoResourceDirectories.exemption
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$($ExemptionFileNameMapping.FileBaseName)"
  }
  $filePaths
}
#endregion

#region function to generate the subscription summary Markdown file
function newSubscriptionSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]

  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  $SubscriptionSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'subscription' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $SubscriptionSummaryFileNameMapping.FilePath
  $FileParentDirectory = $SubscriptionSummaryFileNameMapping.FileParentDirectory
  $filePaths = @()

  $subscriptionTableData = @()
  $FileBaseNames = @()
  Foreach ($sub in $($EnvironmentDiscoveryData.subscriptions | sort-object parentMgName, name)) {
    Write-Verbose "  - [$(getCurrentUTCString)]: Processing subscription '$($sub.name)' with Id '$($sub.id)'."
    $subPageFileNameMapping = getWikiPageFileName -ResourceId $sub.id -wikiFileMapping $wikiFileMapping
    $FileBaseNames += $subPageFileNameMapping.FileName
    #Write-Verbose "    - [$(getCurrentUTCString)]: Subscription page file name: '$($subPageFileNameMapping.FileName)'."
    #Write-Verbose "    - [$(getCurrentUTCString)]: Subscription file folder path: '$($subPageFileNameMapping.FileParentDirectory)'."
    $subPagesRelativePath = getRelativePath -FromPath $SubscriptionSummaryFileNameMapping.FileParentDirectory -ToPath $(Join-Path $subPageFileNameMapping.FileParentDirectory $subPageFileNameMapping.FileBaseName) -UseUnixPath $true
    #Write-Verbose "    - [$(getCurrentUTCString)]: Subscription relative path: '$subPagesRelativePath'."
    $subLink = $subPagesRelativePath

    #Write-Verbose "    - [$(getCurrentUTCString)]: Subscription link on the main summary page: '$subLink'."
    $subscriptionComplianceSummary = $EnvironmentDiscoveryData.subscriptionComplianceSummary | Where-Object { $_.subscriptionId -ieq $sub.subscriptionId }
    if ($subscriptionComplianceSummary) {
      $totalCount = $subscriptionComplianceSummary.compliantCount + $subscriptionComplianceSummary.nonCompliantCount + $subscriptionComplianceSummary.conflictCount + $subscriptionComplianceSummary.exemptCount
      $CompliantCount = $subscriptionComplianceSummary.compliantCount + $subscriptionComplianceSummary.exemptCount
      $complianceRateString = "{0}% ({1} out of {2})" -f $subscriptionComplianceSummary.compliancePercentage, $CompliantCount, $totalCount
      $complianceRateParams = @{
        rate                       = $subscriptionComplianceSummary.compliancePercentage
        InputString                = $complianceRateString
        WarningPercentageThreshold = $ComplianceWarningPercentageThreshold
        WikiStyle                  = $WikiStyle
        Format                     = 'Markdown'
      }
      $complianceRate = FormatComplianceRate @complianceRateParams
    } else {
      $complianceRate = 'N/A'
    }
    $subscriptionTableData += [ordered]@{
      name                  = "[{0}]({1})" -f $sub.Name, $subLink
      subscriptionId        = $sub.subscriptionId
      parentManagementGroup = $sub.parentMgName
      state                 = $sub.state
      complianceRate        = $complianceRate
    }
  }
  $subscriptionMarkdownTable = $(newMarkdownTableFromArray -Data $subscriptionTableData -FormatTableHeader $true -KeyFormatting @{ 'subscriptionId' = 'code' })

  If ($PageStyle -ieq 'detailed') {
    Write-Verbose "[$(getCurrentUTCString)]: Generating the management group hierarchy Mermaid diagram in Mermaid." -Verbose
    $mgHierarchyMermaidDiagram = $(buildMgHierarchyMermaidDiagram -EnvironmentDetails $EnvironmentDiscoveryData -IncludeSubscriptions $true -WikiFileMapping $WikiFileMapping -DiagramVersion 'subscriptionPage')
  }
  #subscription summary page
  Write-Verbose "[$(getCurrentUTCString)]: Generating the subscription summary Markdown file in '$FilePath'." -verbose
  $pageContent = ""
  $pageContent += $(newMarkdownHeader -title "$($Title) Subscriptions" -level 1 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  If ($PageStyle -ieq 'detailed') {
    $pageContent += "This page lists all the subscriptions under each management group and subscription in the Management Group hierarchy."
    $pageContent += "`n`n"
    $pageContent += $(newMarkdownHeader -title "management group hierarchy diagram" -level 2 -caseStyle 'UpperCase')
    $pageContent += "`n`n"
    $pageContent += "<details>"
    $pageContent += "`n`n"
    $pageContent += "<summary>Click to expand Management Group Hierarchy Diagram</summary>"
    $pageContent += "`n`n"
    $pageContent += $mgHierarchyMermaidDiagram
    $pageContent += "`n`n"
    $pageContent += "</details>"
    $pageContent += "`n`n"
  } else {
    $pageContent += "This page lists all the subscriptions that are in scope for the **$Title** wiki."
    $pageContent += "`n`n"
  }
  $pageContent += $(newMarkdownHeader -title "Subscriptions List" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += $subscriptionMarkdownTable
  $pageContent += "`n`n"
  $pageContent += $(buildComplianceRatingMarkdown -WikiStyle $WikiStyle -ComplianceWarningPercentageThreshold $ComplianceWarningPercentageThreshold)
  if ($WikiStyle -ieq 'ado') {
    $pageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving subscription summary Markdown file '$FilePath'"
  Set-Content -Value $pageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Subscription Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the subscription summary page
  if ($WikiStyle -ieq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $WikiFileMapping.AdoResourceDirectories.subscription
    $FileNames = $FileBaseNames | Sort-Object
    $orderFileContent = $SubscriptionSummaryFileNameMapping.FileBaseName
    $orderFileContent += "`n"
    $orderFileContent += $FileNames -join "`n"
    Write-Verbose "[$(getCurrentUTCString)]: Creating ADO wiki order file for subscriptions pages in '$orderFileDirectory' directory." -Verbose
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$orderFileContent"
  }

  $filePaths
}
#endregion

#region function to generate the security control summary Markdown file.
function newSecurityControlSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig = @(),

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )

  $SecurityControlSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'security_control' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $SecurityControlSummaryFileNameMapping.FilePath
  $FileParentDirectory = $SecurityControlSummaryFileNameMapping.FileParentDirectory
  $filePaths = @()

  $FileBaseNames = @()

  #security control summary page
  Write-Verbose "[$(getCurrentUTCString)]: Generating the security control summary Markdown file in '$FilePath'." -verbose
  $pageContent = ""
  $pageContent += $(newMarkdownHeader -title "$($Title) Security Controls" -level 1 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  If ($PageStyle -ieq 'detailed') {
    $pageContent += "This page lists the security controls that can be used in all the policy initiatives under each management group and subscription in the Management Group hierarchy."
    $pageContent += "`n`n"
  } else {
    $pageContent += "This page lists security controls that are used in all the policy initiatives that are applicable to the subscriptions that are in scope for the **$Title** wiki."
    $pageContent += "`n`n"
  }
  $notes = @()
  $notes += "Policy definitions in an initiative definition can be grouped and categorized into controls and compliance domains."
  $notes += "The Policy Metadata are the definitions that describe these domains."
  $notes += "Each policy definition that are part of an initiative can be mapped to one or more policy definition group which can contain the security control mapping."
  $pageContent += buildQuotedAlert -type 'note' -contentStyle 'list' -WikiStyle $WikiStyle -messages $notes

  #for detailed page, list out all the built-in. security controls from a selected security control framework
  if ($EnvironmentDiscoveryData.additionalBuiltInPolicyMetadataConfig.count -gt 0) {
    $pageContent += $(newMarkdownHeader -title "Built-In Security Frameworks" -level 2 -caseStyle 'UpperCase')
    $pageContent += "`n`n"
    $pageContent += ":bookmark: The following security frameworks are in use in the current environment."
    $pageContent += "`n`n"
    foreach ($config in $EnvironmentDiscoveryData.additionalBuiltInPolicyMetadataConfig) {
      $secFrameworkPolicyMetadataTableData = @()
      $secFrameworkTitle = $config.framework
      $secFrameworkPolicyMetadata = $EnvironmentDiscoveryData.policyMetadata | Where-Object { $_.name -imatch $config.policyMetadataNameRegex }
      if ($secFrameworkPolicyMetadata.count -gt 0) {
        $pageContent += $(newMarkdownHeader -title $secFrameworkTitle -level 3 -caseStyle 'UpperCase')
        $pageContent += "`n`n"
        foreach ($metadata in $secFrameworkPolicyMetadata) {
          $securityControlPageFileNameMapping = getWikiPageFileName -ResourceId $metadata.id -wikiFileMapping $wikiFileMapping
          $FileBaseNames += $securityControlPageFileNameMapping.FileName
          #Write-Verbose "    - [$(getCurrentUTCString)]: Security Control page file name: '$($securityControlPageFileNameMapping.FileName)'."
          #Write-Verbose "    - [$(getCurrentUTCString)]: Security Control file folder path: '$($securityControlPageFileNameMapping.FileParentDirectory)'."
          $securityControlPagesRelativePath = getRelativePath -FromPath $SecurityControlSummaryFileNameMapping.FileParentDirectory -ToPath $(Join-Path $securityControlPageFileNameMapping.FileParentDirectory $securityControlPageFileNameMapping.FileBaseName) -UseUnixPath $true
          #Write-Verbose "    - [$(getCurrentUTCString)]: Security Control relative path: '$securityControlPagesRelativePath'."
          $securityControlPageLink = $securityControlPagesRelativePath

          #Write-Verbose "    - [$(getCurrentUTCString)]: Security Control link on the main summary page: '$securityControlPageLink'."
          if ($metadata.properties.metadataId) {
            $name = $metadata.properties.metadataId
          } else {
            $name = $metadata.Name
          }
          $secFrameworkPolicyMetadataTableData += [ordered]@{
            name     = "[{0}]({1})" -f $name, $securityControlPageLink
            category = $metadata.properties.category
            title    = $metadata.properties.title
            inUse    = $metadata.isInUse.toupper()
          }
        }
        $pageContent += ":bookmark: **$($secFrameworkPolicyMetadataTableData.count)** controls have been discovered from Azure's Policy Metadata resources. These controls are natively available in Azure. `n`n"
        $pageContent += '<details>'
        $pageContent += "`n`n"
        $pageContent += '<summary>Click to expand</summary>'
        $pageContent += "`n`n"
        $pageContent += $(newMarkdownTableFromArray -Data $secFrameworkPolicyMetadataTableData -FormatTableHeader $true -KeyFormatting @{ 'inUse' = 'code' })
        $pageContent += "`n`n"
        $pageContent += '</details>'
        $pageContent += "`n`n"
      }
    }
  }

  #custom security control definitions
  if ($CustomSecurityControlFileConfig.count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Processing custom security control files." -verbose
    $customSecurityControlTableData = @()
    #get the custom policy definition group from initiatives that are in use
    $customDefinitionGroups = getCustomPolicyDefinitionGroups -initiatives $EnvironmentDiscoveryData.initiatives

    Foreach ($file in $CustomSecurityControlFileConfig) {
      $controlID = $file.controlId
      $framework = $file.framework

      $isInUse = $customDefinitionGroups.contains($controlID)
      $customSecurityControlFileNameMapping = getWikiPageFileName -CustomSecurityControlId $controlID -SecurityControlFramework $framework -wikiFileMapping $WikiFileMapping

      $customSecurityControlPagesRelativePath = getRelativePath -FromPath $SecurityControlSummaryFileNameMapping.FileParentDirectory -ToPath $(Join-Path $customSecurityControlFileNameMapping.FileParentDirectory $customSecurityControlFileNameMapping.FileBaseName) -UseUnixPath $true
      #Write-Verbose "    - [$(getCurrentUTCString)]: Custom Security Control relative path: '$customSecurityControlPagesRelativePath'."
      $customSecurityControlPageLink = $customSecurityControlPagesRelativePath
      $customSecurityControlTableData += [ordered]@{
        ControlId = "[{0}]({1})" -f $controlID, $customSecurityControlPageLink
        Name      = $file.name
        Framework = $framework
        Category  = $file.category
        inUse     = $isInUse.tostring().toupper()
      }
    }
  }
  if ($customSecurityControlTableData.count -gt 0) {
    Write-Verbose "[$(getCurrentUTCString)]: Found $($customSecurityControlTableData.count) custom security controls for processing." -verbose
    $pageContent += $(newMarkdownHeader -title "Custom Security Controls" -level 2 -caseStyle 'UpperCase')
    $pageContent += "`n`n"
    $notes = @()
    if ($PageStyle -ieq 'detailed') {
      $notes += "This section lists all the custom security controls that the organization uses when mapping security controls for member policies in policy initiatives."
    } else {
      $notes += "This section lists all the custom security controls that are currently in use in the policy initiatives that are in scope for the **$Title** wiki."
    }
    $notes += "They are not native in Azure and have been included in this wiki for reference."
    $pageContent += buildQuotedAlert -type 'note' -contentStyle 'list' -WikiStyle $WikiStyle -messages $notes
    #group custom security controls by framework
    $frameworkNames = $customSecurityControlTableData.framework.toupper() | Get-Unique
    foreach ($framework in $frameworkNames) {
      Write-Verbose "[$(getCurrentUTCString)]: Processing custom security controls for framework '$framework'." -verbose
      $filteredCustomSecurityControlTableData = @()
      $frameworkTableData = $customSecurityControlTableData | Where-Object { $_.Framework -ieq $framework }
      foreach ($item in $frameworkTableData) {
        $filteredCustomSecurityControlTableData += [ordered]@{
          ControlId = $item.ControlId
          Name      = $item.Name
          Category  = $item.Category
          inUse     = $item.inUse
        }
      }

      $pageContent += "`n`n"
      $pageContent += $(newMarkdownHeader -title $framework -level 3 -caseStyle 'UpperCase')
      $pageContent += "`n`n"
      $pageContent += ":bookmark: **$($filteredCustomSecurityControlTableData.count)** controls are defined in the framework **$framework**.`n`n"
      $pageContent += '<details>'
      $pageContent += "`n`n"
      $pageContent += '<summary>Click to expand</summary>'
      $pageContent += "`n`n"
      $pageContent += $(newMarkdownTableFromArray -Data $filteredCustomSecurityControlTableData -FormatTableHeader $true -KeyFormatting @{ 'inUse' = 'code' })
      $pageContent += "`n`n"
      $pageContent += '</details>'
      $pageContent += "`n`n"
    }
  }

  if ($WikiStyle -ieq 'ado') {
    $pageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving security control summary Markdown file '$FilePath'"
  Set-Content -Value $pageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Security Control Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the Security Control summary page
  if ($WikiStyle -ieq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $(encodeAdoWikiPageTitle -StringToEncode $WikiFileMapping.AdoResourceDirectories.security_control)
    $FileNames = $FileBaseNames | Sort-Object
    $orderFileContent = $SecurityControlSummaryFileNameMapping.FileBaseName
    $orderFileContent += "`n"
    $orderFileContent += $FileNames -join "`n"
    Write-Verbose "[$(getCurrentUTCString)]: Creating ADO wiki order file for security control pages in '$orderFileDirectory' directory." -Verbose
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$orderFileContent"
  }

  $filePaths
}
#endregion

#region function to generate the analysis summary Markdown file
function newAnalysisSummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]

  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )
  $AnalysisSummaryFileNameMapping = getWikiPageFileName -summaryPageType 'analysis' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $AnalysisSummaryFileNameMapping.FilePath
  $FileParentDirectory = $AnalysisSummaryFileNameMapping.FileParentDirectory
  $filePaths = @()

  if ($PageStyle -ieq 'detailed') {
    Write-Verbose "[$(getCurrentUTCString)]: Generating the detailed Analysis page." -Verbose
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: Generating the basic Analysis page." -Verbose
  }

  #control id compliance coverage Markdown
  Write-Verbose "[$(getCurrentUTCString)]: Generating the control ID compliance coverage section." -Verbose
  $controlIdComplianceCoverageParams = @{
    EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
    ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    WikiStyle                            = $WikiStyle
    TitleName                            = "Policy Control Coverage"
    FromPath                             = $FileParentDirectory
    WikiFileMapping                      = $WikiFileMapping
  }
  if ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
    $controlIdComplianceCoverageParams.add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
  }
  $controlIdComplianceCoverageMarkdown = buildPolicyDefinitionGroupComplianceCoverageMarkdown @controlIdComplianceCoverageParams

  #Build the summary Markdown content
  Write-Verbose "[$(getCurrentUTCString)]: Generating the analysis summary Markdown file in '$FilePath'." -verbose
  $pageContent = ""
  $pageContent += $(newMarkdownHeader -title "$title analysis" -level 1 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  if ($PageStyle -ieq 'detailed') {
    $TopLevelManagementGroupName = $EnvironmentDiscoveryData.topLevelManagementGroupName
    $pageContent += "This page contains analysis and recommendations for the Azure policy resources that are deployed to the Azure Management Group ``$($topLevelManagementGroupName.ToUpper())``."
    $pageContent += "`n`n"
  } else {
    $pageContent += "This page contains analysis and recommendations for the Azure policy resources that are applicable to the following subscriptions:"
    $pageContent += "`n`n"
    $EnvironmentDiscoveryData.subscriptions | ForEach-Object {
      $pageContent += "- $($_.name)`n"
    }
    $pageContent += "`n`n"
  }

  $pageContent += "`n`n"
  $pageContent += $(newMarkdownHeader -title "Policy Control Coverage" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += ":memo: This section provides an overview of the policy control coverage for the environment."
  $pageContent += "`n`n"
  $notes = @()
  $notes += 'The `Initiative Categories` column indicates the Azure services that the policies in the security control are targeting.'
  $notes += 'This information is fetched from the `category` field in the policy initiative metadata.'
  $notes += 'If the data is not accurate, make sure the `category` field in the policy initiative metadata is correctly populated.'
  $pageContent += buildQuotedAlert -type 'note' -WikiStyle $WikiStyle -contentStyle 'list' -messages $notes
  $pageContent += "The following unique control IDs have mapped to assigned policies:"
  $pageContent += "`n`n"
  $pageContent += $controlIdComplianceCoverageMarkdown

  if ($PageStyle -ieq 'detailed') {
    $buildRecommendationParams = @{
      WikiFileMapping          = $WikiFileMapping
      EnvironmentDiscoveryData = $EnvironmentDiscoveryData
      FileParentDirectory      = $FileParentDirectory
    }
    if ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
      $buildRecommendationParams.add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
    }
    $pageContent += buildRecommendationMarkdown @buildRecommendationParams
  }

  if ($WikiStyle -ieq 'ado') {
    $pageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }
  #recommendations are only available for the detailed page
  Write-Verbose "[$(getCurrentUTCString)]: Saving analysis summary Markdown file '$FilePath'"
  Set-Content -Value $pageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Analysis Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  $filePaths
}
#endregion

#region function generate the policy category summary Markdown file
function newPolicyCategorySummaryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The unique assigned policy initiative categories.')]
    [System.Collections.Specialized.OrderedDictionary]
    $uniqueAssignedPolicyInitiativeCategories,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )

  $PolicyCategorySummaryFileNameMapping = getWikiPageFileName -summaryPageType 'policy_category' -wikiFileMapping $WikiFileMapping
  $WikiStyle = $WikiFileMapping.WikiStyle

  $FilePath = $PolicyCategorySummaryFileNameMapping.FilePath
  $FileParentDirectory = $PolicyCategorySummaryFileNameMapping.FileParentDirectory
  $filePaths = @()

  $FileBaseNames = @()

  #policy category summary page
  Write-Verbose "[$(getCurrentUTCString)]: Generating the policy category summary Markdown file in '$FilePath'." -verbose
  $pageContent = ""
  $pageContent += $(newMarkdownHeader -title "$($Title) Policy Categories" -level 1 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $pageContent += $(newMarkdownHeader -title "introduction" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  If ($PageStyle -ieq 'detailed') {
    $pageContent += "This page lists the categories that have been defined in all **assigned** policy initiatives."
  } else {
    $pageContent += "This page lists the categories that have been defined in all **assigned** policy initiatives that are applicable to the subscriptions that are in scope for the **$Title** wiki."
  }
  $pageContent += "`n`n"
  $pageContent += "The `category` is defined via the `category` property in the policy initiative metadata."
  $pageContent += "`n`n"
  $notes = @()
  $notes += "The `Category` metadata is often used to identify the Azure services that the policy is applying to."
  $notes += "A complete is commonly used metadata for Policy Definitions and Initiatives can be found in the Azure Policy documentation [Common metadata properties](https://learn.microsoft.com/azure/governance/policy/concepts/definition-structure-basics#common-metadata-properties)."
  $notes += "It is recommended that all policy definitions and initiatives have the `category` property defined in the metadata field."
  $pageContent += buildQuotedAlert -type 'note' -contentStyle 'list' -WikiStyle $WikiStyle -messages $notes

  $pageContent += $(newMarkdownHeader -title "Policy Category List" -level 2 -caseStyle 'UpperCase')
  $pageContent += "`n`n"
  $policyCategoryTableData = @()
  foreach ($category in $uniqueAssignedPolicyInitiativeCategories.Keys) {
    Write-Verbose "  - Processing policy category '$category'." -verbose
    $policyCategoryPageFileNameMapping = getWikiPageFileName -PolicyCategory $category -wikiFileMapping $wikiFileMapping
    Write-Verbose "    - Policy Category page file name: '$($policyCategoryPageFileNameMapping.FileName)'."
    $policyCategoryPagesRelativePath = getRelativePath -FromPath $PolicyCategorySummaryFileNameMapping.FileParentDirectory -ToPath $(Join-Path $policyCategoryPageFileNameMapping.FileParentDirectory $policyCategoryPageFileNameMapping.FileBaseName) -UseUnixPath $true
    Write-Verbose "    - [$(getCurrentUTCString)]: Policy Category relative path: '$policyCategoryPagesRelativePath'."
    $policyCategoryPageLink = $policyCategoryPagesRelativePath
    #calculate compliance rate
    $compliantCount = $uniqueAssignedPolicyInitiativeCategories[$category].compliantCount
    $nonCompliantCount = $uniqueAssignedPolicyInitiativeCategories[$category].nonCompliantCount
    $conflictCount = $uniqueAssignedPolicyInitiativeCategories[$category].conflictCount
    $exemptCount = $uniqueAssignedPolicyInitiativeCategories[$category].exemptCount

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
    $policyCategoryTableData += [ordered]@{
      name                 = "[{0}]({1})" -f $category, $policyCategoryPageLink
      Initiatives          = $uniqueAssignedPolicyInitiativeCategories[$category].policyInitiativeCount
      MappedControls       = $uniqueAssignedPolicyInitiativeCategories[$category].policyDefinitionGroups.count
      CompliancePercentage = $compliancePercentage
      ComplianceRate       = $complianceRate
    }
  }
  if ($policyCategoryTableData.count -gt 0) {
    #sort by compliance percentage ascending (lowest on top)
    $policyCategoryTableData = $policyCategoryTableData | Sort-Object { [int]$_.CompliancePercentage }
    $pageContent += ":bookmark: **$($policyCategoryTableData.count)** unique policy categories have been discovered from assigned policy initiatives.`n`n"
    $pageContent += $(newMarkdownTableFromArray -Data $policyCategoryTableData -Properties @('name', 'Initiatives', 'MappedControls', 'ComplianceRate') -FormatTableHeader $true -ColumnAlignment @{ 'Initiatives' = 'Center'; 'MappedControls' = 'Center' })
  } else {
    $pageContent += ":exclamation: No policy categories have been discovered from assigned policy initiatives.`n`n"
  }
  $pageContent += "`n`n"
  if ($WikiStyle -ieq 'ado') {
    $pageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
  }

  Write-Verbose "[$(getCurrentUTCString)]: Saving policy category summary Markdown file '$FilePath'"
  Set-Content -Value $pageContent -Path $FilePath -Force -Encoding 'utf8'
  Write-Verbose "[$(getCurrentUTCString)]: Policy Category Summary Markdown file created in '$FilePath'."
  $filePaths += $FilePath

  #Create the .order file for the Security Control summary page
  if ($WikiStyle -ieq 'ado') {
    $orderFileDirectory = Join-Path $WikiFileMapping.BaseOutputPath $(encodeAdoWikiPageTitle -StringToEncode $WikiFileMapping.AdoResourceDirectories.policy_category)
    $FileNames = $FileBaseNames | Sort-Object
    $orderFileContent = $PolicyCategorySummaryFileNameMapping.FileBaseName
    $orderFileContent += "`n"
    $orderFileContent += $FileNames -join "`n"
    Write-Verbose "[$(getCurrentUTCString)]: Creating ADO wiki order file for policy category pages in '$orderFileDirectory' directory." -Verbose
    $filePaths += newAdoWikiOrderFile -FileDirectory $orderFileDirectory -content "$orderFileContent"
  }

  $filePaths
}
#endregion

#region function to generate a Markdown file for each subscription
function newSubscriptionPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $false, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle = 'detailed',

    [parameter(Mandatory = $true, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
    [ValidateRange(7, 90)]
    [int]$ExemptionExpiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData
  )

  $subscriptions = $EnvironmentDiscoveryData.subscriptions
  Write-verbose "[$(getCurrentUTCString)]: Found $($subscriptions.Count) subscriptions in the management group hierarchy."
  $WikiStyle = $WikiFileMapping.WikiStyle
  $filePaths = @()
  $i = 0
  foreach ($sub in $subscriptions) {
    $i++
    $subPageFileNameMapping = getWikiPageFileName -ResourceId $sub.id -wikiFileMapping $wikiFileMapping
    $markdownFilePath = $subPageFileNameMapping.FilePath
    $FileParentDirectory = $subPageFileNameMapping.FileParentDirectory
    #Build the Markdown content
    $subscriptionComplianceSummary = $EnvironmentDiscoveryData.subscriptionComplianceSummary | Where-Object { $_.subscriptionId -ieq $sub.subscriptionId }
    $buildMarkdownParams = @{
      subscription                         = $sub
      managementGroups                     = $EnvironmentDiscoveryData.managementGroups
      assignments                          = $EnvironmentDiscoveryData.assignments
      exemptions                           = $EnvironmentDiscoveryData.exemptions
      exemptionExpiresOnWarningDays        = $ExemptionExpiresOnWarningDays
      TopLevelManagementGroupName          = $EnvironmentDiscoveryData.topLevelManagementGroupName
      wikiFileMapping                      = $wikiFileMapping
      PageStyle                            = $PageStyle
      complianceSummary                    = $subscriptionComplianceSummary
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    }
    $subAssignmentCompliance = $EnvironmentDiscoveryData.assignmentCompliance | Where-Object { $_.subscriptionId -ieq $sub.subscriptionId }
    if ($subAssignmentCompliance.count -gt 0) {
      $buildMarkdownParams.Add('assignmentCompliance', $subAssignmentCompliance)
    }
    $PageContent = ""
    $pageContent += $(newMarkdownHeader -title "Subscription: $($sub.name)" -level 1 -caseStyle 'Original')
    $pageContent += "`n`n"
    $pageContent += $(buildSubscriptionSummaryMarkdown @buildMarkdownParams)
    $pageContent += "`n`n"
    if ($WikiStyle -ieq 'ado') {
      $pageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $FileParentDirectory -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }
    $filePaths += $markdownFilePath
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'" -Verbose
    #create the directory if not exists
    $markdownFileDirectory = $subPageFileNameMapping.FileParentDirectory
    if (-not (Test-Path -Path $markdownFileDirectory)) {
      New-Item -ItemType Directory -Path $markdownFileDirectory -Force | Out-Null
    }
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }
  Write-Verbose "[$(getCurrentUTCString)]: Markdown files created for $($subscriptions.Count) subscriptions in '$OutputPath'."
  $filePaths
}
#endregion

#region function to generate a Markdown file for each policy assignment
function newPolicyAssignmentPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  #get policy assignments
  $assignments = $EnvironmentDiscoveryData.assignments
  $topLevelManagementGroupName = $EnvironmentDiscoveryData.topLevelManagementGroupName.toupper()
  Write-Verbose "[$(getCurrentUTCString)]: Found $($assignments.Count) policy assignments that are assigned in the management group hierarchy."
  $initiativeResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policysetdefinitions\/'
  $definitionResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policydefinitions\/'

  $filePaths = @()
  $i = 0
  foreach ($item in $assignments) {
    $i++
    $AssignmentFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
    Write-Verbose "[$(getCurrentUTCString)]: [$i/$($assignments.count)] Processing policy assignment '$($item.name)'" -verbose
    $fileName = $AssignmentFileNameMapping.FileName
    $OutputPath = $AssignmentFileNameMapping.FileParentDirectory
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'"
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }
    $markdownFilePath = $AssignmentFileNameMapping.FilePath
    $definitionId = $item.properties.policyDefinitionId
    Write-Verbose "  - [$(getCurrentUTCString)]: Policy assignment Id: '$($item.id)'"
    Write-Verbose "  - [$(getCurrentUTCString)]: Assigned Definition Id: '$definitionId'"
    $policyEnforcement = $($item.properties.enforcementMode -ieq 'DoNotEnforce') ? 'Disabled' : 'Enabled'
    #filter out any 'hidden-' metadata
    $metadata = ConvertToOrderedHashtable -InputObject $($item.properties.metadata)
    if ($PageStyle -ieq 'basic') {
      $hiddenMetadataNames = $metadata.Keys | Where-Object { $_ -match '^hidden[-_]' }
      foreach ($hiddenMetadataName in $hiddenMetadataNames) {
        $metadata.Remove($hiddenMetadataName)
      }
    }
    $assignmentOverviewTableData = [ordered]@{
      displayName       = "**$($item.properties.displayName)**"
      name              = $item.name
      id                = $item.id
      description       = $($item.properties.description ? $($item.properties.description) : $null)
      policyEnforcement = $policyEnforcement
      scope             = $item.properties.scope
    }

    #Compliance summary
    $complianceSummary = $EnvironmentDiscoveryData.assignmentCompliance | Where-Object { $_.policyAssignmentId -ieq $item.id }
    $totalCompliantCount = 0
    $totalNonCompliantCount = 0
    $totalConflictCount = 0
    $totalExemptCount = 0
    foreach ($cs in $complianceSummary) {
      $totalCompliantCount += $cs.compliantCount
      $totalNonCompliantCount += $cs.nonCompliantCount
      $totalExemptCount += $cs.exemptCount
      $totalConflictCount += $cs.conflictCount
    }
    if ($PageStyle -ieq 'detailed') {
      $complianceSummaryDescription = ":memo: This section provides the overall policy compliance overview for the policy assignment ``$($item.name)`` for the ``$($topLevelManagementGroupName)`` Management Group."
    } else {
      $complianceSummaryDescription = ":memo: This section provides the policy compliance overview for the policy assignment ``$($item.name)`` for the subscriptions that are hosting the application."
    }
    $complianceSummaryParams = @{
      header                               = "assignment compliance summary"
      description                          = $complianceSummaryDescription
      diagramTitle                         = "Resources Compliance State"
      compliantCount                       = $totalCompliantCount
      nonCompliantCount                    = $totalNonCompliantCount
      conflictCount                        = $totalConflictCount
      exemptCount                          = $totalExemptCount
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      wikiStyle                            = $wikiStyle
    }
    $complianceSummaryMarkdown = buildComplianceSummaryMarkdown @complianceSummaryParams

    if ($definitionId -match $initiativeResourceIdRegex) {
      #an initiative is assigned
      Write-Verbose "  - [$(getCurrentUTCString)]: Assigned definition '$definitionId' is a policy initiative."
      $definition = $EnvironmentDiscoveryData.initiatives | where-object { $_.id -ieq $definitionId }
      Write-Verbose "  - [$(getCurrentUTCString)]: Display name for the assigned initiative '$($definition.properties.displayName)'"
      $overViewTableKeyPrefix = 'assignedInitiative'
      $definitionType = 'initiative'
      $markdownDefinitionDetailsTitle = 'assigned initiative'
    } elseif ($definitionId -match $definitionResourceIdRegex) {
      #a policy is assigned
      Write-Verbose "  - [$(getCurrentUTCString)]: Assigned definition '$definitionId' is a policy definition."
      $definition = $EnvironmentDiscoveryData.definitions | where-object { $_.id -ieq $definitionId }
      Write-Verbose "  - [$(getCurrentUTCString)]: Display name for the assigned definition '$($definition.properties.displayName)'"
      $definitionType = 'definition'
      $overViewTableKeyPrefix = 'assignedPolicy'
      $markdownDefinitionDetailsTitle = 'assigned definition'
    } else {
      Write-Error "Unable to detect the assigned policy type from the resource Id '$definitionId'."
      continue
    }
    $DefinitionFileNameMapping = getWikiPageFileName -ResourceId $definition.id -wikiFileMapping $WikiFileMapping
    $definitionPageFileBaseName = $DefinitionFileNameMapping.FileBaseName
    $definitionFolderPath = $DefinitionFileNameMapping.FileParentDirectory
    $definitionLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $definitionFolderPath $definitionPageFileBaseName) -UseUnixPath $true

    $assignmentOverviewTableData.add("$overViewTableKeyPrefix", "[$($definition.properties.DisplayName)]($definitionLink)")
    Write-Verbose "  - [$(getCurrentUTCString)]: Found assigned $($definitionType) '$($Definition.name)'"
    $assignmentOverviewTableData.add('definitionType', $(ConvertToTitleCase -InputString $definitionType))
    if ($item.properties.notScopes.count -gt 0) {
      $assignmentOverviewTableData.add('excludedScopes', $item.properties.notScopes)
    }
    Write-Verbose "  - [$(getCurrentUTCString)]: Generate Markdown table for the assignment details."
    $assignmentDetailsMarkdownTable = newMarkdownTable -data $assignmentOverviewTableData -Orientation 'vertical' -KeyFormatting @{ 'id' = 'code'; 'scope' = 'code'; "$overViewTableKeyPrefix`Id" = 'code' }
    Write-Verbose "  - [$(getCurrentUTCString)]: Generate Markdown table for the assignment metadata."
    $assignmentMetadataMarkdownTable = newHtmlTable -data $metadata -formatTableHeader $false -WikiStyle $WikiFileMapping.WikiStyle
    Write-Verbose "  - [$(getCurrentUTCString)]: Generate Markdown section for the role assignments for the policy assignment."
    $roleAssignmentsMarkdown = buildPolicyAssignmentRoleAssignmentMarkdown -assignment $item -roleAssignments $EnvironmentDiscoveryData.roleAssignments -roleDefinitions $EnvironmentDiscoveryData.roleDefinitions
    $hasParameters = $null -ne $item.properties.parameters -and @($item.properties.parameters.PSObject.Properties).Count -gt 0
    if ($hasParameters) {
      Write-Verbose "  - [$(getCurrentUTCString)]: Generate Markdown table for the assignment parameters."
      $parametersMarkdownTable = buildAssignmentParametersMarkdownTable -parameters $item.properties.parameters
    }
    #get related exemptions
    $relatedExemptions = $EnvironmentDiscoveryData.exemptions | Where-Object { $_.policyAssignmentId -ieq $item.id }

    Write-Verbose "  - [$(getCurrentUTCString)]: Generating Markdown file '$fileName' for the policy assignment '$($item.name)' in the output path '$OutputPath'."
    $PageContent = ""
    $PageContent += $(newMarkdownHeader -title "Assignment: $($item.properties.displayName)" -level 1 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "assignment overview" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "assignment details" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    $PageContent += $assignmentDetailsMarkdownTable
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "assignment metadata" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    $PageContent += "<details>"
    $PageContent += "`n`n"
    $PageContent += "<summary>Click to expand</summary>"
    $PageContent += "`n`n"
    $PageContent += $assignmentMetadataMarkdownTable
    $PageContent += "`n`n"
    $PageContent += "</details>"
    $PageContent += "`n`n"
    $PageContent += $complianceSummaryMarkdown
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "related resources" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "exemptions" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    if ($relatedExemptions) {
      $relatedExemptionsTableData = @()
      foreach ($exemption in $relatedExemptions) {
        $exemptionFileNameMapping = getWikiPageFileName -ResourceId $exemption.id -wikiFileMapping $wikiFileMapping
        $exemptionPageFileBaseName = $exemptionFileNameMapping.FileBaseName
        $exemptionFolderPath = $exemptionFileNameMapping.FileParentDirectory
        $exemptionLink = getRelativePath -FromPath $OutputPath -ToPath $(Join-Path $exemptionFolderPath $exemptionPageFileBaseName) -UseUnixPath $true

        $relatedExemptionsTableData += [ordered]@{
          Name        = "[$($exemption.name)]($exemptionLink)"
          DisplayName = $exemption.displayName
          Description = $exemption.description
        }
      }
      $PageContent += ":bookmark: The following policy exemptions are created for the assignment:"
      $PageContent += "`n`n"
      $PageContent += $(newMarkdownTableFromArray -data $relatedExemptionsTableData)
      $PageContent += "`n`n"
    } else {
      $PageContent += ":bookmark: This policy assignment does not have any exemptions.`n`n"
    }
    $PageContent += $(newMarkdownHeader -title "role assignments" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    $PageContent += $roleAssignmentsMarkdown
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "assignment parameters" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    if ($hasParameters) {
      $notes = @()
      $notes += "The following table lists the parameters defined in the Assignment and their values."
      $notes += "If a parameter is not defined, it will be set to the default value defined in the $definitionType."
      $PageContent += buildQuotedAlert -type 'note' -contentStyle 'list' -WikiStyle $WikiStyle -messages $notes
      $PageContent += $parametersMarkdownTable
      $PageContent += "`n`n"
    } else {
      $PageContent += ":exclamation: **No parameters are defined in this policy assignment!**"
      $PageContent += "`n`n"
    }
    $PageContent += $(newMarkdownHeader -title "$markdownDefinitionDetailsTitle" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $PageContent += ":bookmark: $(ConvertToTitleCase -InputString $definitionType): [$($definition.properties.displayName)]($definitionLink)"
    $PageContent += "`n`n"

    $PageContent += $(newMarkdownHeader -title "assignment parameter mapping" -level 3 -caseStyle 'TitleCase')
    $PageContent += "`n`n"
    if ($hasParameters) {
      $PageContent += ":bookmark: The mapping between parameters defined in the Assignment and the assigned $definitionType are as follows:`n`n"
      $PageContent += $(buildPolicyAssignmentParameterMappingMarkdown -definitionParameters $definition.properties.parameters -assignmentParameters $item.properties.parameters)
    } else {
      $PageContent += ":exclamation: **No parameters are defined in this policy assignment!**"
      $PageContent += "`n`n"
    }
    $PageContent += "`n`n"
    $PageContent += $(newMarkdownHeader -title "non-compliance messages" -level 2 -caseStyle 'UpperCase')
    $PageContent += "`n`n"
    $nonCompliantMessageParams = @{
      nonComplianceMessages = $item.properties.nonComplianceMessages
      allDefinitions        = $EnvironmentDiscoveryData.definitions
      definition            = $definition
      wikiFileMapping       = $WikiFileMapping
      assignmentOutputPath  = $OutputPath
    }
    $PageContent += $(buildPolicyAssignmentNonComplianceMessageMarkdown @nonCompliantMessageParams)

    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }

    $filePaths += $markdownFilePath
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8BOM'
  }
  #Write-Verbose "[$(getCurrentUTCString)]: Markdown files created for $($assignments.Count) policy assignments in '$OutputPath'."
  $filePaths
}
#endregion

#region function to generate a Markdown file for each custom policy initiative
function newPolicyInitiativePage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  #get policy initiatives
  #$initiatives = $EnvironmentDiscoveryData.initiatives | Where-Object { $_.properties.policyType -eq 'Custom' }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($EnvironmentDiscoveryData.initiatives.Count) policy initiatives that are assigned in the management group hierarchy."
  $filePaths = @()
  #assigned initiatives
  Foreach ($item in $EnvironmentDiscoveryData.initiatives) {
    Write-Verbose "  - [$(getCurrentUTCString)]: Processing policy initiative '$($item.properties.displayName)'" -verbose
    $InitiativeFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
    $OutputPath = $InitiativeFileNameMapping.FileParentDirectory
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'"
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }
    $markdownFilePath = $InitiativeFileNameMapping.FilePath
    if ($PageStyle -ieq 'detailed') {
      #combine builtInDefinitionInUnAssignedCustomInitiative and definitions to a single array
      $defs = if ($EnvironmentDiscoveryData.definitions) { $EnvironmentDiscoveryData.definitions } else { @() }
      $builtInDefs = if ($EnvironmentDiscoveryData.builtInDefinitionInUnAssignedCustomInitiative) { $EnvironmentDiscoveryData.builtInDefinitionInUnAssignedCustomInitiative } else { @() }
      $allDefinitions = @($defs) + @($builtInDefs)
    } else {
      #for basic page, only include the definitions that are directly assigned
      $allDefinitions = @($EnvironmentDiscoveryData.definitions)
    }
    $buildInitiativePageParams = @{
      WikiFileMapping = $WikiFileMapping
      OutputPath      = $OutputPath
      initiative      = $item
      policyMetadata  = $EnvironmentDiscoveryData.policyMetadata
      definitions     = $allDefinitions
      assignments     = $EnvironmentDiscoveryData.assignments
      PageStyle       = $PageStyle
      WikiStyle       = $WikiStyle
    }
    if ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
      $buildInitiativePageParams.add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
    }
    $PageContent = buildPolicyInitiativeDetailedPageContent @buildInitiativePageParams
    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }

    $filePaths += $markdownFilePath
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }
  #Write-Verbose "[$(getCurrentUTCString)]: Markdown files created for $($initiatives.Count) custom policy initiatives in '$OutputPath'."

  $filePaths
}
#endregion

#region function to generate a Markdown file for each custom policy definition
function newPolicyDefinitionPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  #get assigned policy definitions
  #$definitions = $EnvironmentDiscoveryData.definitions | Where-Object { $_.properties.policyType -eq 'Custom' }
  $definitions = @($EnvironmentDiscoveryData.definitions)
  if ($PageStyle -ieq 'detailed') {
    $existingDefinitionIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($d in $definitions) {
      if ($d.id) { [void]$existingDefinitionIds.Add($d.id) }
    }
    foreach ($item in $EnvironmentDiscoveryData.builtInDefinitionInUnAssignedCustomInitiative) {
      if ($item.id -and -not $existingDefinitionIds.Contains($item.id)) {
        $definitions += $item
        [void]$existingDefinitionIds.Add($item.id)
      }
    }
  }
  Write-Verbose "[$(getCurrentUTCString)]: Found $($definitions.Count) policy definitions that are directly or indirectly assigned or included in unassigned custom initiatives in the management group hierarchy." -verbose
  $filePaths = @()
  Foreach ($item in $definitions) {
    #Write-Verbose "  - [$(getCurrentUTCString)]: Processing policy definition '$($item.properties.displayName)'" -verbose
    $DefinitionFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
    $OutputPath = $DefinitionFileNameMapping.FileParentDirectory
    $definitionPageContentParams = @{
      definition      = $item
      PageStyle       = $PageStyle
      WikiStyle       = $WikiFileMapping.WikiStyle
      initiatives     = $EnvironmentDiscoveryData.initiatives
      assignments     = $EnvironmentDiscoveryData.assignments
      WikiFileMapping = $WikiFileMapping
      FromPath        = $OutputPath
    }
    $PageContent = buildPolicyDefinitionDetailedPageContent @definitionPageContentParams

    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }

    #Create the output directory if not exists
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'"
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }
    $markdownFilePath = $DefinitionFileNameMapping.FilePath
    $filePaths += $markdownFilePath
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }

  #Write-Verbose "[$(getCurrentUTCString)]: Markdown files created for $($EnvironmentDiscoveryData.definitions.Count) custom policy definitions in '$OutputPath'."
  $filePaths
}
#endregion

#region function to generate a Markdown file for each policy exemption
function newPolicyExemptionPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The warning days for the expiration of the policy exemption.')]
    [ValidateRange(7, 90)]
    [int]$ExpiresOnWarningDays,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  #get policy exemptions
  $exemptions = $EnvironmentDiscoveryData.exemptions
  Write-Verbose "[$(getCurrentUTCString)]: Found $($exemptions.Count) policy exemptions for the policy assignments." -verbose
  $filePaths = @()
  Foreach ($item in $exemptions) {
    $ExemptionFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
    $fileName = $ExemptionFileNameMapping.FileName
    $OutputPath = $ExemptionFileNameMapping.FileParentDirectory
    $PageContent = buildPolicyExemptionDetailedPageContent -exemption $item -PageStyle $PageStyle -expiresOnWarningDays $expiresOnWarningDays -assignments $EnvironmentDiscoveryData.assignments -WikiFileMapping $WikiFileMapping -FromPath $OutputPath
    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }

    #Create the output directory if not exists
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'"
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }
    $markdownFilePath = Join-Path -Path $OutputPath -ChildPath $fileName
    $filePaths += $markdownFilePath
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }
  $filePaths
}
#endregion

#region function to generate a Markdown file for each policy metadata (built-in security controls)
function newPolicyMetadataPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping
  )

  $WikiStyle = $WikiFileMapping.WikiStyle
  #get security control
  $policyMetadata = $EnvironmentDiscoveryData.policyMetadata
  Write-Verbose "[$(getCurrentUTCString)]: Found $($policyMetadata.Count) built-in security controls." -verbose
  $filePaths = [System.Collections.Generic.List[string]]::new()
  Foreach ($item in $policyMetadata) {
    #Write-Verbose "  - [$(getCurrentUTCString)]: Processing built-in security control '$($item.id)'." -verbose
    $PolicyMetadataFileNameMapping = getWikiPageFileName -ResourceId $item.id -wikiFileMapping $WikiFileMapping
    $fileName = $PolicyMetadataFileNameMapping.FileName
    $OutputPath = $PolicyMetadataFileNameMapping.FileParentDirectory
    $policyMetadataDetailsParams = @{
      metadata                             = $item
      outputPath                           = $OutputPath
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      WikiFileMapping                      = $WikiFileMapping
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
    }
    $PageContent = buildPolicyMetadataDetailedPageContent @policyMetadataDetailsParams
    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }

    #Create the output directory if not exists
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'"
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }

    $markdownFilePath = Join-Path -Path $OutputPath -ChildPath $fileName
    $filePaths.Add($markdownFilePath)
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }
  $filePaths
}
#endregion

#region function to generate a Markdown file for each custom security control
function newCustomSecurityControlPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $WikiStyle = $WikiFileMapping.WikiStyle

  #get the custom policy definition group from initiatives that are in use
  $customDefinitionGroups = getCustomPolicyDefinitionGroups -initiatives $EnvironmentDiscoveryData.initiatives -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  Write-Verbose "[$(getCurrentUTCString)]: Found $($CustomSecurityControlFileConfig.Count) custom security controls." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $filePaths = @()
  Foreach ($file in $CustomSecurityControlFileConfig) {
    $json = Get-Content -Path $file.filePath -Raw | ConvertFrom-Json -Depth 10
    $controlID = $file.controlId
    $framework = $file.framework

    $isInUse = $customDefinitionGroups.contains($controlID)
    #for basic page, only create when it's in use
    if ($PageStyle -eq 'basic' -and -not $isInUse) {
      Write-Verbose "[$(getCurrentUTCString)]: Skipping Markdown file creation for custom security control '$controlID' for the basic page style because it is not in use."
      continue
    }
    $fileNameMapping = getWikiPageFileName -CustomSecurityControlId $controlID -SecurityControlFramework $framework -wikiFileMapping $WikiFileMapping -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $fileName = $fileNameMapping.FileName
    $OutputPath = $fileNameMapping.FileParentDirectory
    $customSecurityControlPageParams = @{
      control                              = $json
      isInUse                              = $isInUse
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      WikiFileMapping                      = $WikiFileMapping
      outputPath                           = $OutputPath
    }
    $PageContent = buildCustomSecurityControlDetailedPageMarkdown @customSecurityControlPageParams -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }

    #Create the output directory if not exists
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }

    $markdownFilePath = Join-Path -Path $OutputPath -ChildPath $fileName
    $filePaths += $markdownFilePath
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }
  $filePaths
}
#endregion

#region function to generate a Markdown file for each policy category
function newPolicyCategoryPage {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([array])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The unique assigned policy initiative categories.')]
    [System.Collections.Specialized.OrderedDictionary]
    $uniqueAssignedPolicyInitiativeCategories,

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]
    $EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The warning percentage threshold for policy compliance summary.')]
    [ValidateRange(1, 99)]
    [int]$ComplianceWarningPercentageThreshold,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig
  )

  $WikiStyle = $WikiFileMapping.WikiStyle

  foreach ($categoryKey in $uniqueAssignedPolicyInitiativeCategories.Keys) {
    $category = $uniqueAssignedPolicyInitiativeCategories[$categoryKey]
    Write-Verbose "[$(getCurrentUTCString)]: Generating Markdown page for policy category '$categoryKey'."
    $PolicyCategoryFileNameMapping = getWikiPageFileName -PolicyCategory $categoryKey -wikiFileMapping $WikiFileMapping
    $fileName = $PolicyCategoryFileNameMapping.FileName
    $OutputPath = $PolicyCategoryFileNameMapping.FileParentDirectory
    $policyCategoryPageParams = @{
      categoryName                         = $categoryKey
      categoryDetails                      = $category
      EnvironmentDiscoveryData             = $EnvironmentDiscoveryData
      WikiFileMapping                      = $WikiFileMapping
      ComplianceWarningPercentageThreshold = $ComplianceWarningPercentageThreshold
      outputPath                           = $OutputPath
    }
    if ($PSBoundParameters.ContainsKey('CustomSecurityControlFileConfig')) {
      $policyCategoryPageParams.add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
    }
    $PageContent = buildPolicyCategoryDetailedPageMarkdown @policyCategoryPageParams

    if ($WikiStyle -ieq 'ado') {
      $PageContent += buildAdoFooter -WikiFileMapping $WikiFileMapping -CurrentPageParentDirectory $OutputPath -TimeStamp $EnvironmentDiscoveryData.TimeStamp
    }

    #Create the output directory if not exists
    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
      Write-Verbose "[$(getCurrentUTCString)]: Creating output directory '$OutputPath'" -Verbose
      New-Item -Path $OutputPath -ItemType Directory | Out-Null
    }
    $markdownFilePath = Join-Path -Path $OutputPath -ChildPath $fileName
    #save the Markdown content to file, create the file if not exists and overwrite it if already exists
    #Write-Verbose "  - Saving Markdown file '$markdownFilePath'" -Verbose
    Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  }
}
#endregion
#region function to generate the sidebar file for GitHub wiki
Function newGitHubWikiSidebar {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The wiki title.')]
    [string]$Title,

    [parameter(Mandatory = $false, HelpMessage = 'The configurations for the custom security control definition files. It contains the file path, control ID, and framework for each file.')]
    [array]$CustomSecurityControlFileConfig = @(),

    [parameter(Mandatory = $true, HelpMessage = 'Required. The environment discovery data.')]
    [system.object]$EnvironmentDiscoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle
  )

  $GitHubSidebarFileNameMapping = getWikiPageFileName -summaryPageType 'github_sidebar' -wikiFileMapping $WikiFileMapping
  Write-Verbose "[$(getCurrentUTCString)]: Generating the GitHub Sidebar page." -Verbose

  Write-Verbose "[$(getCurrentUTCString)]: GitHub Sidebar file name: '$($GitHubSidebarFileNameMapping.FileName)'." -verbose
  $sidebarParams = @{
    EnvironmentDiscoveryData = $EnvironmentDiscoveryData
    Title                    = $Title
    WikiFileMapping          = $WikiFileMapping
    PageStyle                = $PageStyle
  }
  if ($CustomSecurityControlFileConfig.count -gt 0) {
    $sidebarParams.add('CustomSecurityControlFileConfig', $CustomSecurityControlFileConfig)
  }
  $pageContent = buildGitHubWikiSideBarPageContent @sidebarParams

  Write-Verbose "[$(getCurrentUTCString)]: Markdown Content:"
  Write-Verbose $PageContent

  $markdownFilePath = $GitHubSidebarFileNameMapping.FilePath
  #save the Markdown content to file, create the file if not exists and overwrite it if already exists
  #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
  Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  $markdownFilePath
}
#endregion

#region function to generate the footer file for GitHub wiki
Function newGitHubWikiFooter {
  [CmdletBinding(SupportsShouldProcess)]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, HelpMessage = 'The wiki file name mappings.')]
    [hashtable]$WikiFileMapping,

    [parameter(Mandatory = $true, HelpMessage = 'The time stamp.')]
    [ValidateNotNullOrEmpty()]
    [string]$TimeStamp
  )
  $GitHubFooterFileNameMapping = getWikiPageFileName -summaryPageType 'github_footer' -wikiFileMapping $WikiFileMapping
  $PageContent = buildFooterContent -CurrentPageParentDirectory $GitHubFooterFileNameMapping.FileParentDirectory -WikiFileMapping $WikiFileMapping -TimeStamp $TimeStamp

  $markdownFilePath = $GitHubFooterFileNameMapping.FilePath
  #save the Markdown content to file, create the file if not exists and overwrite it if already exists
  #Write-Verbose "[$(getCurrentUTCString)]: Saving Markdown file '$markdownFilePath'"
  Set-Content -Value $PageContent -Path $markdownFilePath -Force -Encoding 'utf8'
  $markdownFilePath
}
#endregion
