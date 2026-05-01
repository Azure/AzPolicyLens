<#
===============================================================
AUTHOR: Tao Yang
DATE: 13/01/2026
NAME: github-set-variables.ps1
VERSION: 1.0.0
COMMENT: Set GitHub Action variables from configuration files.
===============================================================
#>
[CmdletBinding()]
param (
  [parameter(Mandatory = $true)]
  [ValidateScript({ Test-Path $_ -PathType 'leaf' })]
  [string]$configFilePath
)

# Import required module for YAML parsing
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
  Write-Verbose "Installing powershell-yaml module..."
  Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}
Import-Module powershell-yaml

# Import AzPolicyTest module for YAML parsing
if (-not (Get-Module -ListAvailable -Name AzPolicyTest)) {
  Write-Verbose "Installing AzPolicyTest module..."
  Install-Module -Name AzPolicyTest -RequiredVersion 3.0.0 -Force -Scope CurrentUser
}
Import-Module AzPolicyTest

# Read and parse YAML file
Write-Output "Reading configuration from: $configFilePath"
$yamlContent = Get-Content -Path $configFilePath -Raw
$config = ConvertFrom-Yaml -Yaml $yamlContent

# Check if variables exist in the configuration
if (-not $config.variables) {
  Write-Error "No 'variables' section found in the configuration file."
  exit 1
}

foreach ($item in $config.variables) {
  $name = $item.name
  $value = $item.Value

  # Set GitHub Action output variable
  Write-Output "Setting variable: '$name' with value: '$value'"
  Write-Output ('{0}={1}' -f $name, $value) | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
}
