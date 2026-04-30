class BuiltInSecurityControlConfig {
  [ValidateNotNullOrEmpty()][string]$framework
  [ValidateNotNullOrEmpty()][string]$policyMetadataNameRegex


  # common constructor
  PropertyValueTestConfig([string]$framework, [string]$policyMetadataNameRegex) {
    $this.framework = $framework
    $this.policyMetadataNameRegex = $policyMetadataNameRegex
  }

  # Default constructor
  BuiltInSecurityControlConfig() { $this.Init(@{}) }
  # Convenience constructor from hashtable
  BuiltInSecurityControlConfig([hashtable]$Properties) { $this.Init($Properties) }
  # Shared initializer method
  [void] Init([hashtable]$Properties) {
    foreach ($Property in $Properties.Keys) {
      $this.$Property = $Properties.$Property
    }
  }
}
