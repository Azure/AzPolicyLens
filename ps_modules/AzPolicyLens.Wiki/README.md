# AzPolicyLens.Wiki Module

## Generate Module Help File

### Generate Markdown Files

```PowerShell
#Import PlatyPS module
Import-Module Microsoft.PowerShell.PlatyPS

#Import AzPolicyLens.Discovery Module
Import-Module ./AzPolicyLens.Wiki.psd1

#Generate Help
$OutputFolder = join-path $pwd 'docs'
$params = @{
    ModuleInfo = Get-Module 'AzPolicyLens.Wiki'
    OutputFolder = $OutputFolder
    HelpVersion = '2.0.0'
    WithModulePage = $true
    Encoding = [System.Text.Encoding]::UTF8
}
New-MarkdownCommandHelp @params
```

Manually update the generated Markdown files and ensure there are no errors flagged by the Markdown linter `markdownlint`.

### Generate XML help files

```powershell
$mdfiles = Measure-PlatyPSMarkdown -Path ./docs/AzPolicyLens.Wiki/*.md
$mdfiles | Where-Object Filetype -match 'CommandHelp' | Import-MarkdownCommandHelp -Path {$_.FilePath} | Export-MamlCommandHelp -OutputFolder $pwd

```

### Update help

```PowerShell
$paths = @()
$paths += join-path $pwd 'docs' 'AzPolicyLens.Wiki' 'New-AzplDocumentation.md'
$paths += join-path $pwd 'docs' 'AzPolicyLens.Wiki' 'Import-AzplEnvironmentDiscovery.md'
foreach ($path in $paths)
{
Update-MarkdownCommandHelp -path $path
}
```


