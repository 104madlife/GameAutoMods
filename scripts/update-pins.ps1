[CmdletBinding()]
param(
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$collectionRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -Raw -LiteralPath (Join-Path $collectionRoot "mods.json") | ConvertFrom-Json

foreach ($project in $manifest.projects) {
    $path = Join-Path $collectionRoot $project.path
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Missing submodule working tree: $($project.path)"
    }

    $status = [string](git -C $path status --porcelain --untracked-files=all)
    if (-not [string]::IsNullOrWhiteSpace($status)) {
        throw "Refusing to update dirty submodule: $($project.name)"
    }

    git -C $path fetch origin $project.defaultBranch
    if ($LASTEXITCODE -ne 0) { throw "Fetch failed for $($project.name)." }
    $current = [string](git -C $path rev-parse HEAD)
    $remote = [string](git -C $path rev-parse "origin/$($project.defaultBranch)")

    if ($current -eq $remote) {
        Write-Output "$($project.name): already at origin/$($project.defaultBranch) ($($current.Substring(0, 8)))"
        continue
    }

    if (-not $Apply) {
        Write-Output "$($project.name): would update $($current.Substring(0, 8)) -> $($remote.Substring(0, 8))"
        continue
    }

    git -C $path switch $project.defaultBranch
    if ($LASTEXITCODE -ne 0) { throw "Branch switch failed for $($project.name)." }
    git -C $path merge --ff-only "origin/$($project.defaultBranch)"
    if ($LASTEXITCODE -ne 0) { throw "Fast-forward failed for $($project.name)." }
    Write-Output "$($project.name): updated to $($remote.Substring(0, 8))"
}

if ($Apply) {
    Write-Output "Review the changed submodule pins, then commit them in GameAutoMods."
    git -C $collectionRoot status --short
}
else {
    Write-Output "Preview complete. Re-run with -Apply to fast-forward clean submodules."
}
