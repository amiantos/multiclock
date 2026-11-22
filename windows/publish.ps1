# Builds a distributable MultiClock screensaver: publishes a self-contained,
# single-file executable, renames it to .scr, and zips it for release.
#
#   pwsh windows/publish.ps1
#
# Output: windows/dist/MultiClock-<version>-Windows.zip

[CmdletBinding()]
param(
    [string]$Configuration = 'Release',
    [string]$Runtime = 'win-x64'
)

$ErrorActionPreference = 'Stop'

$projectDir = $PSScriptRoot
$project = Join-Path $projectDir 'MultiClock.csproj'
$dist = Join-Path $projectDir 'dist'

# Read the version from the csproj so the zip name can never drift from the build.
[xml]$csproj = Get-Content $project
$version = @($csproj.Project.PropertyGroup.Version | Where-Object { $_ })[0]
if (-not $version) { throw "No <Version> found in $project" }

Write-Host "Publishing MultiClock $version ($Runtime)..."
dotnet publish $project -c $Configuration -r $Runtime --self-contained `
    -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed with exit code $LASTEXITCODE" }

$publishDir = Join-Path $projectDir "bin\$Configuration\net8.0-windows\$Runtime\publish"
$exe = Join-Path $publishDir 'MultiClock.exe'
if (-not (Test-Path $exe)) { throw "Expected published executable at $exe" }

New-Item -ItemType Directory -Force $dist | Out-Null
$scr = Join-Path $dist 'MultiClock.scr'
$zip = Join-Path $dist "MultiClock-$version-Windows.zip"

# A .scr is nothing but a renamed .exe; that rename is the entire packaging step.
Copy-Item $exe $scr -Force
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path $scr -DestinationPath $zip

$mb = [math]::Round((Get-Item $zip).Length / 1MB, 1)
Write-Host ""
Write-Host "Wrote $zip ($mb MB)"
Write-Host "To install: extract it, move MultiClock.scr somewhere permanent, then right-click -> Install."
