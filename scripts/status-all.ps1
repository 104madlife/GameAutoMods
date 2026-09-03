[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$collectionRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -Raw -LiteralPath (Join-Path $collectionRoot "mods.json") | ConvertFrom-Json
$rows = [System.Collections.Generic.List[object]]::new()

foreach ($project in $manifest.projects) {
    $path = Join-Path $collectionRoot $project.path
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        $rows.Add([pscustomobject]@{
            Project = $project.name
            Branch = "<missing>"
            Head = ""
            Pin = ""
            Dirty = ""
            Remote = $project.url
        })
        continue
    }

    $indexLine = [string](git -C $collectionRoot ls-files -s -- $project.path)
    $pin = if ($indexLine -match '^160000\s+([0-9a-f]{40})') { $Matches[1].Substring(0, 8) } else { "<not-pinned>" }
    $status = [string](git -C $path status --porcelain --untracked-files=all)
    $branch = [string](git -C $path branch --show-current)
    if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "<detached>" }
    $rows.Add([pscustomobject]@{
        Project = $project.name
        Branch = $branch
        Head = ([string](git -C $path rev-parse HEAD)).Substring(0, 8)
        Pin = $pin
        Dirty = -not [string]::IsNullOrWhiteSpace($status)
        Remote = [string](git -C $path remote get-url origin)
    })
}

$rows | Format-Table -AutoSize
