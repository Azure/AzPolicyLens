#function detect if the script is running in an Azure DevOps pipeline or GitHub Actions
Function getPipelineType {
  if ($env:ADOORGNAME) {
    "Azure DevOps"
  } elseif ($env:GITHUB_ACTIONS) {
    "GitHub Actions"
  } else {
    "Local"
  }
}
