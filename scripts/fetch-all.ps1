[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$collectionRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -Raw -LiteralPath (Join-Path $collectionRoot "mods.json") | ConvertFrom-Json

git -C $collectionRoot submodule sync --recursive
if ($LASTEXITCODE -ne 0) { throw "Submodule URL synchronization failed." }
git -C $collectionRoot submodule update --init --recursive
if ($LASTEXITCODE -ne 0) { throw "Submodule initialization failed." }

foreach ($project in $manifest.projects) {
    $path = Join-Path $collectionRoot $project.path
    Write-Output "Fetching $($project.name) ..."
    git -C $path fetch origin --prune
    if ($LASTEXITCODE -ne 0) { throw "Fetch failed for $($project.name)." }
}

Write-Output "Fetch complete. No submodule branch or collection pin was moved."
