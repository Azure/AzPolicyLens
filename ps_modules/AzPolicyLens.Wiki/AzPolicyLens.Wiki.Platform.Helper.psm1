<#
============================================================================================================================
AUTHOR: Tao Yang
DATE: 11/09/2025
NAME: AzPolicyLens.Wiki.Platform.Helper.psm1
VERSION: 2.0.0
COMMENT: this nested module contains the Azure DevOps and GitHub Wiki related helper functions for AzPolicyLens.Wiki module
============================================================================================================================
#>
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1
#function to create a .order file for ADO wiki
Function newAdoWikiOrderFile {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "The directory of the .order file.")]
    [string]$FileDirectory,

    [Parameter(Mandatory = $true, HelpMessage = "The content.")]
    [string]$content
  )

  #Create the directory if it does not exist
  if (-not (Test-Path -Path $FileDirectory -PathType Container)) {
    New-Item -Path $FileDirectory -ItemType Directory | Out-Null
  }
  #Create the .order file
  $filePath = Join-Path -Path $FileDirectory -ChildPath '.order'
  if (Test-Path -Path $filePath) {
    Write-Verbose "[$(getCurrentUTCString)]: The .order file already exists at '$filePath'. checking if $($content) already exists." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $existingContent = Get-Content -Path $filePath -ErrorAction SilentlyContinue
    if ($existingContent -contains $content) {
      Write-Verbose "[$(getCurrentUTCString)]: The content '$content' already exists in the .order file at '$filePath'. No changes made." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    } else {
      Write-Verbose "[$(getCurrentUTCString)]: The content '$content' does not exist in the .order file at '$filePath'. Appending it." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      Add-Content -Path $filePath -Value $content
    }
  } else {
    Write-Verbose "[$(getCurrentUTCString)]: The .order file does not exist at '$filePath'. Creating a new one." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $content | Out-File -FilePath $filePath -Encoding UTF8 -Force
    Write-Verbose "[$(getCurrentUTCString)]: Created ADO wiki order file at '$filePath'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    return $filePath
  }
}

#function to extract the parent management group, subscription, resource group from the resource Id
function getResourceParent {
  param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceId
  )

  $parent = @{
    ManagementGroup = $null
    Subscription    = $null
    ResourceGroup   = $null
  }
  $mgRegex = '(?im)^\/providers\/microsoft\.management\/managementgroups\/([a-zA-Z0-9][a-zA-Z0-9\-_.()]*[a-zA-Z0-9\-_()])\/\S+'
  $subRegex = '(?im)^\/subscriptions\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})'
  $rgRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\/resourcegroups\/([a-zA-Z0-9][a-zA-Z0-9\-_.()]*[a-zA-Z0-9\-_()])\/\S+'
  # Extract the parent information from the resource ID
  if ($ResourceId -match $mgRegex) {
    $parent.ManagementGroup = $matches[1]
  }
  if ($ResourceId -match $subRegex) {
    $parent.Subscription = $matches[1]
  }
  if ($ResourceId -match $rgRegex) {
    $parent.ResourceGroup = $matches[1]
  }
  $parent
}

#function to escape special characters in page titles (file and folder names) for ADO wiki
function encodeAdoWikiPageTitle {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "The file name to escape.")]
    [string]$StringToEncode
  )
  # Escape special characters for ADO wiki
  #documentation: https://learn.microsoft.com/en-us/azure/devops/project/wiki/wiki-file-structure?view=azure-devops#special-characters-in-wiki-page-titles
  $encodingMapping = @()
  $encodingMapping += @{ character = ':'; encodedString = '%3A' }
  $encodingMapping += @{ character = '<'; encodedString = '%3C' }
  $encodingMapping += @{ character = '>'; encodedString = '%3E' }
  $encodingMapping += @{ character = '*'; encodedString = '%2A' }
  $encodingMapping += @{ character = '?'; encodedString = '%3F' }
  $encodingMapping += @{ character = '|'; encodedString = '%7C' }
  $encodingMapping += @{ character = '-'; encodedString = '%2D' }
  $encodingMapping += @{ character = '"'; encodedString = '%22' }
  $encodingMapping += @{ character = ' '; encodedString = '-' }

  foreach ($mapping in $encodingMapping) {
    $StringToEncode = $StringToEncode -replace [regex]::Escape($mapping.character), $mapping.encodedString
  }
  # Remove any leading or trailing spaces
  $StringToEncode = $StringToEncode.Trim()
  $StringToEncode
}

#function to escape special characters in page titles (file and folder names) for GitHub wiki
function encodeGithubWikiPageTitle {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, HelpMessage = "The file name to escape.")]
    [string]$StringToEncode
  )
  # Escape special characters for GitHub wiki
  $encodingMapping = @()
  $encodingMapping += @{ character = '-'; encodedString = '_' }
  $encodingMapping += @{ character = '.'; encodedString = '_' }
  $encodingMapping += @{ character = ':'; encodedString = '_' }
  $encodingMapping += @{ character = ' '; encodedString = '-' }

  foreach ($mapping in $encodingMapping) {
    $StringToEncode = $StringToEncode -replace [regex]::Escape($mapping.character), $mapping.encodedString
  }
  # Remove any leading or trailing spaces
  $StringToEncode = $StringToEncode.Trim()
  $StringToEncode
}
#function to generate wiki page name
function newGithubWikiPageBaseName {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$resourceName,

    [Parameter(Mandatory = $false)]
    [object]$parent,

    [Parameter(Mandatory = $true)]
    [string]$resourceType
  )
  Switch ($resourceType) {
    'definition' { $BaseName = 'def_' }
    'initiative' { $BaseName = 'init_' }
    'assignment' { $BaseName = 'assign_' }
    'exemption' { $BaseName = 'exemp_' }
    'subscription' { $BaseName = 'sub_' }
    'security_control' { $BaseName = 'sc_' }
    'custom_security_control' { $BaseName = 'csc_' }
    'policy_category' { $BaseName = 'polcat_' }
    default { $BaseName = '' }
  }
  $BaseName = "$BaseName{0}" -f $resourceName
  if ($resourceType -ine 'subscription' -and $resourceType -ine 'security_control' -and $resourceType -ine 'policy_category') {
    if ($parent.managementGroup.length -gt 0) {
      $BaseName = "$BaseName`_{0}" -f $parent.managementGroup
    }
    if ($parent.subscription.length -gt 0) {
      $BaseName = "$BaseName`_{0}" -f $parent.subscription
    }
    if ($parent.resourceGroup.length -gt 0) {
      $BaseName = "$BaseName`_{0}" -f $parent.resourceGroup
    }
  }

  $sanitizedBaseName = encodeGithubWikiPageTitle -stringToEncode $BaseName
  $sanitizedBaseName = $sanitizedBaseName.tolower()
  $sanitizedBaseName
}

#function to build the directory path for the specific policy resource for ADO wiki
function getPolicyResourceAdoDirectoryPath {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'ResourceId')]
    [string]$ResourceId,

    [Parameter(Mandatory = $true, ParameterSetName = 'ResourceType')]
    [ValidateSet('assignments', 'initiatives', 'definitions', 'exemptions', 'security-controls', 'policy-categories')]
    [string]$ResourceType,

    [Parameter(Mandatory = $false)]
    [bool]$getResourceTypeRoot = $false,

    [Parameter(Mandatory = $false)]
    [string]$BasePath = (Get-Location).Path,

    [parameter(Mandatory = $false, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle = 'detailed'
  )

  $assignmentResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policyassignments\/'
  $initiativeResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policysetdefinitions\/'
  $definitionResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policydefinitions\/'
  $exemptionResourceIdRegex = '(?im)\/providers\/microsoft\.authorization\/policyexemptions\/'
  $policyMetadataResourceIdRegex = '(?im)\/providers\/microsoft\.policyinsights\/policymetadata\/'
  $managementGroupResourceIdRegex = '(?im)^\/providers\/microsoft\.management\/managementgroups\/'
  $subscriptionResourceIdRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
  $resourceGroupResourceIdRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\/resourcegroups'
  #determine the resource type based on the resource ID
  if ($PSCmdlet.ParameterSetName -ieq 'ResourceId') {
    if ($ResourceId -match $assignmentResourceIdRegex) {
      $ResourceType = 'assignments'
    } elseif ($ResourceId -match $initiativeResourceIdRegex) {
      $ResourceType = 'initiatives'
    } elseif ($ResourceId -match $definitionResourceIdRegex) {
      $ResourceType = 'definitions'
    } elseif ($ResourceId -match $exemptionResourceIdRegex) {
      $ResourceType = 'exemptions'
    } elseif ($ResourceId -match $policyMetadataResourceIdRegex) {
      $ResourceType = 'security-controls'
    } else {
      Write-Error "[$(getCurrentUTCString)]: Unable to determine the policy resource type from the resource ID: '$ResourceId'."
      return $null
    }
  } else {
    switch ($ResourceType.ToLower()) {
      'assignments' { $ResourceType = 'assignments' }
      'initiatives' { $ResourceType = 'initiatives' }
      'definitions' { $ResourceType = 'definitions' }
      'exemptions' { $ResourceType = 'exemptions' }
      'security-controls' { $ResourceType = 'security-controls' }
      'policy-categories' { $ResourceType = 'policy-categories' }
      default {
        Write-Error "[$(getCurrentUTCString)]: Invalid resource type specified: '$ResourceType'. Valid types are 'assignments', 'initiatives', 'definitions', 'exemptions', 'security-controls', 'policy-categories'."
        return $null
      }
    }
  }

  Write-Verbose "[$(getCurrentUTCString)]: Resource type is '$ResourceType'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  if (!$getResourceTypeRoot) {
    #determine the parent resource based on the resource ID
    $parentResourceId = $ResourceId -replace '\/providers\/microsoft\.authorization\/policy(assignments|setdefinitions|definitions|exemptions)\/\S+', ''
    if ($parentResourceId.length -gt 0) {
      $parentResourceName = $parentResourceId.split('/')[-1]
      Write-Verbose "[$(getCurrentUTCString)]: Parent resource ID is '$parentResourceId'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      Write-Verbose "[$(getCurrentUTCString)]: Parent resource Name is '$parentResourceName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    }
    # Get parent resource type
    if ($parentResourceId -match $managementGroupResourceIdRegex) {
      $parentResourceType = 'managementGroups'
    } elseif ($parentResourceId -match $subscriptionResourceIdRegex) {
      $parentResourceType = 'subscriptions'
    } elseif ($parentResourceId -match $resourceGroupResourceIdRegex) {
      $parentResourceType = 'resourceGroups'
      $subscriptionId = $parentResourceId -replace '^\/subscriptions\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\/resourcegroups\/\S+', '$1'
    } elseif ($parentResourceId.length -eq 0) {
      $parentResourceType = 'builtIn'
    } else {
      Write-Error "[$(getCurrentUTCString)]: Unable to determine the parent resource type from the resource ID: '$parentResourceId'."
      return $null
    }
    Write-Verbose "[$(getCurrentUTCString)]: Parent resource type is '$parentResourceType'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    # Construct child resource directory path
    if ($parentResourceType -ine 'resourcegroups') {
      $childResourceDirectoryPath = Join-Path -Path $BasePath -ChildPath $ResourceType.ToUpper() -AdditionalChildPath $parentResourceType, $parentResourceName
    } else {
      $childResourceDirectoryPath = Join-Path -Path $BasePath -ChildPath $ResourceType.ToUpper() -AdditionalChildPath 'subscriptions', $subscriptionId, $parentResourceName
    }

    Write-Verbose "[$(getCurrentUTCString)]: Child resource directory path is '$childResourceDirectoryPath'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  } else {
    # If we want the root directory for the resource type
    #for basic page style, the security control Markdown pages are stored under the analysis directory
    if ($PageStyle -ieq 'basic' -and $ResourceType -ieq 'security-controls') {
      $childResourceDirectoryPath = Join-Path -Path $BasePath -ChildPath 'ANALYSIS'
    } else {
      $childResourceDirectoryPath = Join-Path -Path $BasePath -ChildPath $ResourceType.ToUpper()
    }
    Write-Verbose "[$(getCurrentUTCString)]: Child resource directory path is '$childResourceDirectoryPath'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  }

  $childResourceDirectoryPath
}

#function to build the directory path for the specific resource container (mg, rg, sub) resource for Azure DevOps wiki
function getResourceContainerAdoDirectoryPath {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceId,

    [Parameter(Mandatory = $false)]
    [string]$BasePath = (Get-Location).Path
  )
  $managementGroupResourceIdRegex = '(?im)^\/providers\/microsoft\.management\/managementgroups\/'
  $subscriptionResourceIdRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
  $resourceGroupResourceIdRegex = '(?im)^\/subscriptions\/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\/resourcegroups'

  # Get parent resource type
  if ($ResourceId -match $managementGroupResourceIdRegex) {
    $resourceType = 'MANAGEMENTGROUPS'
  } elseif ($ResourceId -match $subscriptionResourceIdRegex) {
    $resourceType = 'SUBSCRIPTIONS'
  } elseif ($ResourceId -match $resourceGroupResourceIdRegex) {
    $resourceType = 'RESOURCEGROUPS'
    $subscriptionId = $resourceId -replace '^\/subscriptions\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\/resourcegroups\/\S+', '$1'
  } else {
    Write-Error "[$(getCurrentUTCString)]: Unable to determine the resource type from the resource ID: '$resourceId'."
    return $null
  }
  Write-Verbose "[$(getCurrentUTCString)]: Resource type is '$resourceType'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  # Construct child resource directory path
  if ($resourceType -ine 'RESOURCEGROUPS') {
    $childResourceDirectoryPath = Join-Path -Path $BasePath -ChildPath $ResourceType
  } else {
    $childResourceDirectoryPath = Join-Path -Path $BasePath -ChildPath 'SUBSCRIPTIONS' -AdditionalChildPath $subscriptionId, 'RESOURCEGROUPS'
  }

  Write-Verbose "[$(getCurrentUTCString)]: Child resource directory path is '$childResourceDirectoryPath'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $childResourceDirectoryPath
}

#function to store mapping of wiki pages file name, resource name, resource type, etc.
#This is used to create a lookup table for the wiki pages.
function newWikiPageMapping {
  [OutputType([Hashtable])]
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [object]$discoveryData,

    [parameter(Mandatory = $true, HelpMessage = 'The output base directory.')]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$BaseOutputPath,

    [parameter(Mandatory = $false, HelpMessage = 'The title of the wiki.')]
    [ValidateNotNullOrEmpty()]
    [string]$Title = 'POLICY-DOCUMENTATION',

    [parameter(Mandatory = $true, HelpMessage = 'The wiki style. Supported values are "ado" and "github".')]
    [ValidateSet('ado', 'github')]
    [string]$WikiStyle,

    [parameter(Mandatory = $false, HelpMessage = 'The page style (detailed for engineers or basic for customers).')]
    [ValidateSet('detailed', 'basic')]
    [string]$PageStyle = 'detailed'
  )

  $wikiFileMapping = @()
  $adoResourceDirectories = @{
    definition       = 'DEFINITIONS'
    initiative       = 'INITIATIVES'
    assignment       = 'ASSIGNMENTS'
    exemption        = 'EXEMPTIONS'
    subscription     = 'SUBSCRIPTIONS'
    analysis         = 'ANALYSIS'
    policy_category  = 'POLICY CATEGORIES'
    security_control = $PageStyle -ieq 'detailed' ? 'SECURITY CONTROLS' : 'ANALYSIS'
  }
  $config = @{
    BaseOutputPath         = $BaseOutputPath
    WikiStyle              = $WikiStyle
    AdoResourceDirectories = $adoResourceDirectories
  }
  #Process definitions
  $unassignedDefinitions = $discoveryData.unassignedCustomDefinitions
  $builtInDefinitionInUnAssignedCustomInitiative = $discoveryData.builtInDefinitionInUnAssignedCustomInitiative
  #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($discoveryData.definitions.count) policy definitions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  foreach ($item in $discoveryData.definitions) {
    $parent = getResourceParent -ResourceId $item.Id
    if ($WikiStyle -eq 'ado') {
      $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
      $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath
    } else {
      $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'definition'
      $FileDirectory = $BaseOutputPath
    }
    $FileName = '{0}.md' -f $FileBaseName
    #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping = @{
      FileBaseName        = $FileBaseName
      FileName            = $FileName
      FileParentDirectory = $FileDirectory
      FilePath            = Join-Path $FileDirectory $FileName
      ResourceName        = $item.name
      ResourceId          = $item.id
      ResourceType        = 'definition'
      PageType            = 'individual'
      Parent              = $parent
    }
    $wikiFileMapping += $mapping
  }
  if ($unassignedDefinitions.count -gt 0) {
    #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($unassignedDefinitions.count) unassigned custom policy definitions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    foreach ($item in $unassignedDefinitions) {
      $parent = getResourceParent -ResourceId $item.Id
      if ($WikiStyle -eq 'ado') {
        $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
        $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -PageStyle $PageStyle
      } else {
        $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'definition'
        $FileDirectory = $BaseOutputPath
      }
      $FileName = '{0}.md' -f $FileBaseName
      #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $mapping = @{
        FileBaseName        = $FileBaseName
        FileName            = $FileName
        FileParentDirectory = $FileDirectory
        FilePath            = Join-Path $FileDirectory $FileName
        ResourceName        = $item.name
        ResourceId          = $item.id
        ResourceType        = 'definition'
        PageType            = 'individual'
        Parent              = $parent
      }
      $wikiFileMapping += $mapping
    }
  }
  if ($builtInDefinitionInUnAssignedCustomInitiative.count -gt 0) {
    #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($builtInDefinitionInUnAssignedCustomInitiative.count) builtIn definition in unassigned custom initiatives." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    foreach ($item in $builtInDefinitionInUnAssignedCustomInitiative) {
      $parent = getResourceParent -ResourceId $item.Id
      if ($WikiStyle -eq 'ado') {
        $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
        $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -PageStyle $PageStyle
      } else {
        $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'definition'
        $FileDirectory = $BaseOutputPath
      }
      $FileName = '{0}.md' -f $FileBaseName
      #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $mapping = @{
        FileBaseName        = $FileBaseName
        FileName            = $FileName
        FileParentDirectory = $FileDirectory
        FilePath            = Join-Path $FileDirectory $FileName
        ResourceName        = $item.name
        ResourceId          = $item.id
        ResourceType        = 'definition'
        PageType            = 'individual'
        Parent              = $parent
      }
      $wikiFileMapping += $mapping
    }
  }
  #Process initiatives

  $unassignedInitiatives = $discoveryData.unassignedCustomInitiatives
  #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($discoveryData.initiatives.count) policy initiatives." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  foreach ($item in $discoveryData.initiatives) {
    $parent = getResourceParent -ResourceId $item.Id
    if ($WikiStyle -eq 'ado') {
      $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
      $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -PageStyle $PageStyle
    } else {
      $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'initiative'
      $FileDirectory = $BaseOutputPath
    }
    $FileName = '{0}.md' -f $FileBaseName
    #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping = @{
      FileBaseName        = $FileBaseName
      FileName            = $FileName
      FileParentDirectory = $FileDirectory
      FilePath            = Join-Path $FileDirectory $FileName
      ResourceName        = $item.name
      ResourceId          = $item.id
      ResourceType        = 'initiative'
      PageType            = 'individual'
      Parent              = $parent
    }
    $wikiFileMapping += $mapping
  }



  if ($unassignedInitiatives.count -gt 0) {
    #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($unassignedInitiatives.count) unassigned custom policy initiatives." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    foreach ($item in $unassignedInitiatives) {
      $parent = getResourceParent -ResourceId $item.Id
      if ($WikiStyle -eq 'ado') {
        $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
        $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -PageStyle $PageStyle
      } else {
        $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'initiative'
        $FileDirectory = $BaseOutputPath
      }
      $FileName = '{0}.md' -f $FileBaseName
      #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $mapping = @{
        FileBaseName        = $FileBaseName
        FileName            = $FileName
        FileParentDirectory = $FileDirectory
        FilePath            = Join-Path $FileDirectory $FileName
        ResourceName        = $item.name
        ResourceId          = $item.id
        ResourceType        = 'initiative'
        PageType            = 'individual'
        Parent              = $parent
      }
      $wikiFileMapping += $mapping
    }
  }
  #Process assignments
  #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($discoveryData.assignments.count) policy assignments." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  foreach ($item in $discoveryData.assignments) {
    $parent = getResourceParent -ResourceId $item.Id
    if ($WikiStyle -eq 'ado') {
      $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
      $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -PageStyle $PageStyle
    } else {
      $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'assignment'
      $FileDirectory = $BaseOutputPath
    }
    $FileName = '{0}.md' -f $FileBaseName
    #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping = @{
      FileBaseName        = $FileBaseName
      FileName            = $FileName
      FileParentDirectory = $FileDirectory
      FilePath            = Join-Path $FileDirectory $FileName
      ResourceName        = $item.name
      ResourceId          = $item.id
      ResourceType        = 'assignment'
      PageType            = 'individual'
      Parent              = $parent
    }
    $wikiFileMapping += $mapping
  }

  #Process exemptions
  #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($discoveryData.exemptions.Count) policy exemptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  foreach ($item in $discoveryData.exemptions) {
    $parent = getResourceParent -ResourceId $item.Id
    if ($WikiStyle -eq 'ado') {
      $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
      $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -PageStyle $PageStyle
    } else {
      $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'exemption'
      $FileDirectory = $BaseOutputPath
    }
    $FileName = '{0}.md' -f $FileBaseName
    #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping = @{
      FileBaseName        = $FileBaseName
      FileName            = $FileName
      FileParentDirectory = $FileDirectory
      FilePath            = Join-Path $FileDirectory $FileName
      ResourceName        = $item.name
      ResourceId          = $item.id
      ResourceType        = 'exemption'
      PageType            = 'individual'
      Parent              = $parent
    }
    $wikiFileMapping += $mapping
  }

  #process policy metadata
  #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($discoveryData.policyMetadata.Count) policy metadata." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  foreach ($item in $discoveryData.policyMetadata) {
    $parent = getResourceParent -ResourceId $item.Id
    if ($WikiStyle -eq 'ado') {
      $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $item.name
      $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath -getResourceTypeRoot $true -PageStyle $PageStyle
    } else {
      $FileBaseName = newGithubWikiPageBaseName -resourceName $item.name -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'security_control'
      $FileDirectory = $BaseOutputPath
    }
    $FileName = '{0}.md' -f $FileBaseName
    #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping = @{
      FileBaseName        = $FileBaseName
      FileName            = $FileName
      FileParentDirectory = $FileDirectory
      FilePath            = Join-Path $FileDirectory $FileName
      ResourceName        = $item.name
      ResourceId          = $item.id
      ResourceType        = 'security_control'
      PageType            = 'individual'
      Parent              = $parent
    }
    $wikiFileMapping += $mapping
  }

  #process custom security controls
  Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page directory for custom security control pages." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  if ($WikiStyle -eq 'ado') {
    $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceType 'security-controls' -BasePath $BaseOutputPath -getResourceTypeRoot $true -PageStyle $PageStyle
  } else {
    $FileDirectory = $BaseOutputPath
  }
  #$FileName = '{0}.md' -f $FileBaseName
  #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = ''
    FileName            = ''
    FileParentDirectory = $FileDirectory
    FilePath            = ''
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'custom_security_control'
    PageType            = 'individual'
    Parent              = ''
  }
  $wikiFileMapping += $mapping

  #process policy categories
  Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page directory for policy category pages." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  if ($WikiStyle -eq 'ado') {
    $FileDirectory = getPolicyResourceAdoDirectoryPath -ResourceType 'policy-categories' -BasePath $BaseOutputPath -getResourceTypeRoot $true -PageStyle $PageStyle
  } else {
    $FileDirectory = $BaseOutputPath
  }
  #$FileName = '{0}.md' -f $FileBaseName
  #Write-Verbose "  - [$($item.id)]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = ''
    FileName            = ''
    FileParentDirectory = $FileDirectory
    FilePath            = ''
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'policy_category'
    PageType            = 'individual'
    Parent              = ''
  }
  $wikiFileMapping += $mapping

  #Process subscriptions
  #Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for $($discoveryData.subscriptions.Count) Azure subscriptions." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  foreach ($item in $discoveryData.subscriptions) {
    $parent = getResourceParent -ResourceId $item.Id
    if ($WikiStyle -eq 'ado') {
      $FileBaseName = encodeAdoWikiPageTitle -stringToEncode "$($item.name)_$($item.subscriptionId)"
      $FileDirectory = getResourceContainerAdoDirectoryPath -ResourceId $item.id -BasePath $BaseOutputPath
    } else {
      $FileBaseName = newGithubWikiPageBaseName -resourceName $item.subscriptionId -parent $(getResourceParent -ResourceId $item.Id) -resourceType 'subscription'
      $FileDirectory = $BaseOutputPath
    }

    $FileName = '{0}.md' -f $FileBaseName
    #Write-Verbose "  - '[$($item.id)]': '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping = @{
      FileBaseName        = $FileBaseName
      FileName            = $FileName
      FileParentDirectory = $FileDirectory
      FilePath            = Join-Path $FileDirectory $FileName
      ResourceName        = $item.name
      ResourceId          = $item.id
      ResourceType        = 'subscription'
      PageType            = 'individual'
      Parent              = $parent
    }
    $wikiFileMapping += $mapping
  }

  #Process summary pages
  Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for policy summary pages." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

  #definition summary page
  $FileBaseName = $adoResourceDirectories.definition
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Definition summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'definition'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #initiative summary page
  $FileBaseName = $adoResourceDirectories.initiative
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Initiative summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'initiative'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #assignment summary page
  $FileBaseName = $adoResourceDirectories.assignment
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Assignment summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'assignment'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #exemption summary page
  $FileBaseName = $adoResourceDirectories.exemption
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Exemption summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'exemption'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #subscription summary page
  $FileBaseName = $adoResourceDirectories.subscription
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Subscription summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'subscription'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #analysis summary page
  $FileBaseName = $adoResourceDirectories.analysis
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Analysis summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'analysis'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #Security Control summary page
  if ($WikiStyle -ieq 'ado') {
    $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $adoResourceDirectories.security_control
  } else {
    $FileBaseName = encodeGithubWikiPageTitle -stringToEncode $adoResourceDirectories.security_control
  }
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Security Control summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'security_control'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  #Policy Category summary page
  if ($WikiStyle -ieq 'ado') {
    $FileBaseName = encodeAdoWikiPageTitle -stringToEncode $adoResourceDirectories.policy_category
  } else {
    $FileBaseName = encodeGithubWikiPageTitle -stringToEncode $adoResourceDirectories.policy_category
  }
  $FileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Policy Category summary page]: '$FileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $FileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $FileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'policy_category'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping
  #main page
  if ($WikiStyle -eq 'ado') {
    #The file name must match the title of the wiki page
    $renderedTitle = $Title -replace ' ', '-'
  } else {
    $renderedTitle = 'Home'
  }

  $FileBaseName = $renderedTitle.toupper()
  $MainFileName = '{0}.md' -f $FileBaseName

  Write-Verbose "  - [Main page]: '$MainFileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $FileBaseName
    FileName            = $MainFileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $MainFileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'main'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for GitHub sidebar page." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $GitHubSidebarFileBaseName = '_Sidebar'
  $GitHubSidebarFileName = '{0}.md' -f $GitHubSidebarFileBaseName
  Write-Verbose "  - [GitHub Sidebar page]: '$GitHubSidebarFileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $GitHubSidebarFileBaseName
    FileName            = $GitHubSidebarFileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $GitHubSidebarFileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'github_sidebar'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  Write-Verbose "[$(getCurrentUTCString)]: Generate wiki page names for GitHub footer page." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $GitHubFooterFileBaseName = '_Footer'
  $GitHubFooterFileName = '{0}.md' -f $GitHubFooterFileBaseName
  Write-Verbose "  - [GitHub Footer page]: '$GitHubFooterFileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
  $mapping = @{
    FileBaseName        = $GitHubFooterFileBaseName
    FileName            = $GitHubFooterFileName
    FileParentDirectory = $BaseOutputPath
    FilePath            = Join-Path $BaseOutputPath $GitHubFooterFileName
    ResourceName        = ''
    ResourceId          = ''
    ResourceType        = 'github_footer'
    PageType            = 'summary'
    Parent              = $null
  }
  $wikiFileMapping += $mapping

  $config.Add('FileMapping', $wikiFileMapping)
  $config
}

#Function to retrieve file name from the generated page file name mapping
function getWikiPageFileName {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'individual_azure_resource')]
    [string]$ResourceId,

    [Parameter(Mandatory = $true, ParameterSetName = 'custom_security_control')]
    [string]$CustomSecurityControlId,

    [Parameter(Mandatory = $true, ParameterSetName = 'custom_security_control')]
    [string]$SecurityControlFramework,

    [Parameter(Mandatory = $true, ParameterSetName = 'policy_category')]
    [string]$PolicyCategory,

    [Parameter(Mandatory = $true, ParameterSetName = 'summary')]
    [ValidateSet('definition', 'initiative', 'assignment', 'security_control', 'exemption', 'subscription', 'policy_category', 'analysis', 'main', 'github_sidebar', 'github_footer')]
    [string]$summaryPageType,

    [Parameter(Mandatory = $true)]
    [hashtable]$wikiFileMapping
  )
  # Build hashtable indexes on first use for O(1) lookups
  if (-not $wikiFileMapping._resourceIdIndex) {
    $wikiFileMapping._resourceIdIndex = @{}
    $wikiFileMapping._summaryIndex = @{}
    foreach ($m in $wikiFileMapping.FileMapping) {
      if ($m.ResourceId) {
        $wikiFileMapping._resourceIdIndex[$m.ResourceId.ToLower()] = $m
      }
      if ($m.PageType -eq 'summary') {
        $wikiFileMapping._summaryIndex[$m.ResourceType] = $m
      }
    }
  }
  if ($PSCmdlet.ParameterSetName -eq 'summary') {
    $mapping = $wikiFileMapping._summaryIndex[$summaryPageType]
    if (!$mapping) {
      Write-Error "No wiki page file name mapping found for $summaryPageType summary page."
    }
  } elseif ($PSCmdlet.ParameterSetName -eq 'individual_azure_resource') {
    $mapping = $wikiFileMapping._resourceIdIndex[$ResourceId.ToLower()]
    if (!$mapping) {
      Write-Error "No wiki page file name mapping found for resource '$ResourceId'."
    }
  } elseif ($PSCmdlet.ParameterSetName -eq 'policy_category') {
    $mapping = $wikiFileMapping.FileMapping | Where-Object { $_.ResourceType -ieq 'policy_category' -and $_.PageType -ieq 'individual' }
    $WikiStyle = $wikiFileMapping.WikiStyle
    if ($WikiStyle -ieq 'ado') {
      $fileBaseName = encodeAdoWikiPageTitle -stringToEncode $PolicyCategory
    } else {
      $fileBaseName = newGithubWikiPageBaseName -resourceName $PolicyCategory -parent '' -resourceType 'policy_category'
    }
    $fileName = "{0}.md" -f $fileBaseName
    Write-Verbose "[$(getCurrentUTCString)]: Generated file name for policy category '$PolicyCategory' is '$fileName'." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $mapping.FileBaseName = $fileBaseName
    $mapping.FileName = $fileName
    $mapping.FilePath = join-path $mapping.FileParentDirectory $fileName
    $mapping.ResourceName = $PolicyCategory
    $mapping.ResourceId = $PolicyCategory
  } else {
    $mapping = $wikiFileMapping.FileMapping | Where-Object { $_.ResourceType -ieq 'custom_security_control' }
    $WikiStyle = $wikiFileMapping.WikiStyle
    $secControlFullName = "$($CustomSecurityControlId)_$($SecurityControlFramework)"
    if ($WikiStyle -ieq 'ado') {
      $fileBaseName = encodeAdoWikiPageTitle -stringToEncode $secControlFullName
    } else {
      $fileBaseName = newGithubWikiPageBaseName -resourceName $secControlFullName -parent '' -resourceType 'custom_security_control'
    }
    $fileName = "{0}.md" -f $fileBaseName
    $mapping.FileBaseName = $fileBaseName
    $mapping.FileName = $fileName
    $mapping.FilePath = join-path $mapping.FileParentDirectory $fileName
    $mapping.ResourceName = $CustomSecurityControlId
    $mapping.ResourceId = $secControlFullName
  }
  $mapping
}
