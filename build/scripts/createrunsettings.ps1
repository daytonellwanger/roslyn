[CmdletBinding(PositionalBinding=$false)]
param (
    [switch]$release = $false)

Set-StrictMode -version 2.0
$ErrorActionPreference = "Stop"

try {
    . (Join-Path $PSScriptRoot "build-utils.ps1")
    Push-Location $RepoRoot
    
    Write-Host "Repo Dir $RepoRoot"
    Write-Host "Binaries Dir $binariesDir"
    
    $buildConfiguration = if ($release) { "Release" } else { "Debug" }
    $configDir = Join-Path (Join-Path $binariesDir "VSSetup") $buildConfiguration
    
    $optProfToolDir = Get-PackageDir "Roslyn.OptProf.RunSettings.Generator"
    $optProfToolExe = Join-Path $optProfToolDir "tools\roslyn.optprof.runsettings.generator.exe"
    $configFile = Join-Path $RepoRoot "build\config\optprof.json"
    $outputFolder = Join-Path $configDir "Insertion\RunSettings"
    $optProfArgs = "--configFile $configFile --outputFolder $outputFolder --testsUrl Tests/DevDiv/VS/ded1ed1f2c40eef6bb3e0649b1dde997ae2269d2/e6d1aee0-3736-45da-954d-07c7d9d31aba "
    
    # https://github.com/dotnet/roslyn/issues/31486
    $dest = Join-Path $RepoRoot ".vsts-ci.yml"
    try {
        Copy-Item (Join-Path $RepoRoot "azure-pipelines-official.yml") $dest
        Exec-Console $optProfToolExe $optProfArgs
    }
    finally {
        Remove-Item $dest
    }
        
    exit 0
}
catch {
    Write-Host $_
    Write-Host $_.Exception
    Write-Host $_.ScriptStackTrace
    exit 1
}
finally {
    Pop-Location
}
