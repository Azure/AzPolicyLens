<#
===============================================================================================
AUTHOR: Tao Yang
DATE: 11/09/2025
NAME: AzPolicyLens.Wiki.Utility.Helper.psm1
VERSION: 2.0.0
COMMENT: this nested module contains the utility helper functions for AzPolicyLens.Wiki module
===============================================================================================
#>

#function to get the current UTC time
function getCurrentUTCString {
  "$([DateTime]::UtcNow.ToString('u')) UTC"
}

#function to clean JSON string by removing null properties
function RemoveNullPropertiesFromJson {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$JsonString,

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveEmptyArrays,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveEmptyStrings,

    [Parameter(Mandatory = $false)]
    [int]$Depth = 99
  )

  process {
    try {
      # Convert JSON string to PSCustomObject
      $jsonObject = $JsonString | ConvertFrom-Json

      # Remove null properties
      $cleanedObject = RemoveNullProperties -InputObject $jsonObject -Recurse:$Recurse -RemoveEmptyArrays:$RemoveEmptyArrays -RemoveEmptyStrings:$RemoveEmptyStrings

      # Convert back to JSON
      $cleanedJson = $cleanedObject | ConvertTo-Json -Depth $Depth

      return $cleanedJson
    } catch {
      Write-Error "[$(getCurrentUTCString)]: Failed to process JSON: $_"
      return $JsonString
    }
  }
}


#function to remove null properties from a JSON object
function RemoveNullProperties {
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [PSCustomObject]$InputObject,

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveEmptyArrays,

    [Parameter(Mandatory = $false)]
    [switch]$RemoveEmptyStrings
  )

  process {
    $result = [PSCustomObject]@{}

    foreach ($property in $InputObject.PSObject.Properties) {
      $propertyName = $property.Name
      $propertyValue = $property.Value

      # Skip null values
      if ($null -eq $propertyValue) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing null property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        continue
      }

      # Skip empty strings if requested
      if ($RemoveEmptyStrings -and $propertyValue -is [string] -and [string]::IsNullOrWhiteSpace($propertyValue)) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing empty string property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        continue
      }

      # Skip empty arrays if requested
      if ($RemoveEmptyArrays -and $propertyValue -is [array] -and $propertyValue.Count -eq 0) {
        Write-Verbose "[$(getCurrentUTCString)]: Removing empty array property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        continue
      }

      # Handle nested objects recursively if requested
      if ($Recurse -and $propertyValue -is [PSCustomObject]) {
        $cleanedValue = RemoveNullProperties -InputObject $propertyValue -Recurse:$Recurse -RemoveEmptyArrays:$RemoveEmptyArrays -RemoveEmptyStrings:$RemoveEmptyStrings

        # Only add the property if the cleaned object has properties
        if ($cleanedValue.PSObject.Properties.Count -gt 0) {
          Write-Verbose "[$(getCurrentUTCString)]: Adding cleaned object property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
          Add-Member -InputObject $result -MemberType NoteProperty -Name $propertyName -Value $cleanedValue -Force
        }
      }
      # Handle hashtables (like OrderedDictionary) recursively if requested
      elseif ($Recurse -and $propertyValue -is [System.Collections.IDictionary]) {
        $cleanedHashtable = [ordered]@{}

        foreach ($key in $propertyValue.Keys) {
          $value = $propertyValue[$key]
          if ($null -ne $value) {
            if ($value -is [PSCustomObject]) {
              $cleanedValue = RemoveNullProperties -InputObject $value -Recurse:$Recurse -RemoveEmptyArrays:$RemoveEmptyArrays -RemoveEmptyStrings:$RemoveEmptyStrings
              if ($cleanedValue.PSObject.Properties.Count -gt 0) {
                $cleanedHashtable[$key] = $cleanedValue
              }
            } else {
              $cleanedHashtable[$key] = $value
            }
          }
        }

        if ($cleanedHashtable.Count -gt 0) {
          Write-Verbose "[$(getCurrentUTCString)]: Adding cleaned hashtable property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
          Add-Member -InputObject $result -MemberType NoteProperty -Name $propertyName -Value $cleanedHashtable -Force
        }
      }
      # Handle arrays containing objects recursively if requested
      elseif ($Recurse -and $propertyValue -is [array]) {
        $cleanedArray = @()

        foreach ($item in $propertyValue) {
          if ($item -is [PSCustomObject]) {
            $cleanedItem = RemoveNullProperties -InputObject $item -Recurse:$Recurse -RemoveEmptyArrays:$RemoveEmptyArrays -RemoveEmptyStrings:$RemoveEmptyStrings
            if ($cleanedItem.PSObject.Properties.Count -gt 0) {
              $cleanedArray += $cleanedItem
            }
          } elseif ($null -ne $item) {
            $cleanedArray += $item
          }
        }

        # Only add the array if it's not empty or if we're not removing empty arrays
        if ($cleanedArray.Count -gt 0 -or -not $RemoveEmptyArrays) {
          Write-Verbose "[$(getCurrentUTCString)]: Adding cleaned array property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
          Add-Member -InputObject $result -MemberType NoteProperty -Name $propertyName -Value $cleanedArray -Force
        }
      } else {
        # Add the property as-is
        Write-Verbose "[$(getCurrentUTCString)]: Adding property '$propertyName'" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
        Add-Member -InputObject $result -MemberType NoteProperty -Name $propertyName -Value $propertyValue -Force
      }
    }

    return $result
  }
}
