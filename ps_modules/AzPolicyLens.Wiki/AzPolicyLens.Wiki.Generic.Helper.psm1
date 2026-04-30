<#
==================================================================================================================
AUTHOR: Tao Yang
DATE: 11/09/2025
NAME: AzPolicyLens.Wiki.Generic.Helper.psm1
VERSION: 2.0.0
COMMENT: this nested module contains the generic powershell objects helper functions for AzPolicyLens.Wiki module
==================================================================================================================
#>
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1
#function to convert string to 'Title Case'
function ConvertToTitleCase {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$InputString
  )
  begin {
    # Split the string by spaces, hyphens, underscores and capitalize each word
    $pattern = '([\s\-_]+)'
    $parts = $InputString -split $pattern, -1, "RegexMatch"
    $result = ""
  }

  process {
    for ($i = 0; $i -lt $parts.Length; $i++) {
      $part = $parts[$i]

      # If even index, it's a word; otherwise it's a delimiter
      if ($i % 2 -eq 0) {
        if (-not [string]::IsNullOrEmpty($part)) {
          $result += (Get-Culture).TextInfo.ToTitleCase($part.ToLower())
        }
      } else {
        # This is a delimiter, keep it as is
        $result += $part
      }
    }
  }
  end {
    $result
  }
}

#function to split a camel case string into multiple words
function SplitPascalCamelCaseString {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [AllowEmptyString()]
    [string]$InputString
  )
  process {
    if ([string]::IsNullOrWhiteSpace($InputString)) {
      return $InputString
    }
    $match = [regex]::Matches($InputString, '([A-Z][a-z]*)|(^[a-z]+|[A-Z][a-z]*)')
    $result = $match -join ' '
    return $result.Trim()
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
    $InputObject.PSObject.Properties | Sort-object Name | ForEach-Object {
      $ordered[$_.Name] = $_.Value
    }

    return $ordered
  }
}

#function to build relative path for 2 directories (handles non-existent paths)
function getRelativePath {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [string]$FromPath,

    [Parameter(Mandatory = $true)]
    [string]$ToPath,

    [Parameter(Mandatory = $false)]
    [bool]$UseUnixPath = $true
  )

  # Handle non-existent paths by using System.IO.Path methods
  try {
    # Get absolute paths without requiring them to exist
    $fromAbsolute = [System.IO.Path]::GetFullPath($FromPath)
    $toAbsolute = [System.IO.Path]::GetFullPath($ToPath)

    # Ensure from path ends with directory separator if it's a directory
    if (-not [System.IO.Path]::HasExtension($fromAbsolute) -and -not $fromAbsolute.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
      $fromAbsolute += [System.IO.Path]::DirectorySeparatorChar
    }

    # Calculate relative path
    $relativePath = [System.IO.Path]::GetRelativePath($fromAbsolute, $toAbsolute)

    # Convert to Unix-style paths if requested or on non-Windows platforms
    if ($UseUnixPath -or $IsLinux -or $IsMacOS) {
      $relativePath = $relativePath -replace '\\', '/'
    }

    Write-Verbose "[$(getCurrentUTCString)]: Relative path from '$FromPath' to '$ToPath' is '$relativePath'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    return $relativePath
  } catch {
    Write-Error "[$(getCurrentUTCString)]: Failed to calculate relative path: $_"
    return $null
  }
}
