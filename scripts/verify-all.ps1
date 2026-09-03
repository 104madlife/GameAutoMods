[CmdletBinding()]
param(
    [switch]$CheckRemote
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$collectionRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -Raw -LiteralPath (Join-Path $collectionRoot "mods.json") | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($project in $manifest.projects) {
    $path = Join-Path $collectionRoot $project.path
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        $errors.Add("$($project.name): missing working tree")
        continue
    }

    $head = [string](git -C $path rev-parse HEAD)
    $branch = [string](git -C $path branch --show-current)
    $status = [string](git -C $path status --porcelain --untracked-files=all)
    $remote = [string](git -C $path remote get-url origin)
    $indexLine = [string](git -C $collectionRoot ls-files -s -- $project.path)
    $pin = if ($indexLine -match '^160000\s+([0-9a-f]{40})') { $Matches[1] } else { "" }

    # A recursive clone checks out a submodule at its pinned commit, which is
    # normally a detached HEAD. Accept that reproducible state as well as the
    # configured development branch.
    if (-not [string]::IsNullOrWhiteSpace($branch) -and $branch -ne $project.defaultBranch) {
        $errors.Add("$($project.name): branch=$branch expected=$($project.defaultBranch) or detached at the pin")
    }
    if (-not [string]::IsNullOrWhiteSpace($status)) { $errors.Add("$($project.name): dirty working tree") }
    if ($remote.TrimEnd('/') -ne ([string]$project.url).TrimEnd('/')) { $errors.Add("$($project.name): origin URL mismatch") }
    if ($pin -ne $head) { $errors.Add("$($project.name): collection pin does not match working-tree HEAD") }

    if ($CheckRemote) {
        $remoteLine = [string](git -C $path ls-remote origin "refs/heads/$($project.defaultBranch)")
        $remoteHead = ($remoteLine -split "`t")[0]
        if ($remoteHead -ne $head) { $errors.Add("$($project.name): HEAD is not published at origin/$($project.defaultBranch)") }
    }
}

if ($errors.Count -gt 0) {
    throw "Collection verification failed:`n$($errors -join "`n")"
}

Write-Output "Collection verification passed for $($manifest.projects.Count) public Mod repositories."
