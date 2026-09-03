# GameAutoMods

GameAutoMods is the public collection and version index for 104madlife's game automation, camera, movement, and gameplay-capture Mod projects.

Each Mod remains an independent Git repository with its own history, toolchain, validation evidence, and release lifecycle. This repository pins one known collection state through Git submodules.

## Included projects

| Game | Project | Purpose |
| --- | --- | --- |
| Cyberpunk 2077 | [AutoDirector2077](https://github.com/104madlife/AutoDirector2077) | Automated direction, navigation, weapon, and capture experiments |
| Cyberpunk 2077 | [GetCam2077](https://github.com/104madlife/GetCam2077) | Camera provider and camera-state capture tooling |
| Elden Ring | [AutoEldenRing](https://github.com/104madlife/AutoEldenRing) | Gameplay automation, travel, combat, and equipment experiments |
| Grand Theft Auto V | [GTAVAutoDriver](https://github.com/104madlife/GTAVAutoDriver) | AutoDriver and BattleMode automation |
| Red Dead Redemption 2 | [RDR2AutoDriver](https://github.com/104madlife/RDR2AutoDriver) | Native AutoDriver automation |
| The Witcher 3 | [Witcher3AutoDriver](https://github.com/104madlife/Witcher3AutoDriver) | WitcherScript movement, camera, horse, and teleport automation |

`AutoGhostTsushima` is intentionally excluded from this public repository and is ignored locally.

## Clone the complete collection

```powershell
git clone --recurse-submodules https://github.com/104madlife/GameAutoMods.git
```

For an existing non-recursive clone:

```powershell
git submodule update --init --recursive
```

Submodules are pinned commits. Pulling this repository reproduces the recorded collection state; it does not automatically move every Mod to the newest branch tip.

After a recursive clone, each submodule normally has a detached `HEAD` at its pinned commit. This is the expected read-only collection state. Before developing a Mod, enter that submodule and switch to its `main` branch:

```powershell
cd .\Witcher3AutoDriver
git switch main
```

## Daily workflow

Work and commit inside the individual Mod first:

```powershell
cd .\Witcher3AutoDriver
git switch main
git add <files>
git commit -m "Describe the Mod change"
git push
```

Then return to GameAutoMods and record the new submodule commit:

```powershell
cd ..
git add Witcher3AutoDriver
git commit -m "Update Witcher3AutoDriver"
git push
```

Never commit a submodule pointer whose corresponding child commit has not been pushed to its public remote.

## Collection scripts

```powershell
# Show branch, HEAD, pin, remote, and dirty status for every Mod.
.\scripts\status-all.ps1

# Initialize missing submodules and fetch remote updates without moving pins.
.\scripts\fetch-all.ps1

# Verify clean state, branch, URL, pin, and published remote commit.
.\scripts\verify-all.ps1 -CheckRemote

# Preview which submodules differ from origin/main.
.\scripts\update-pins.ps1

# Explicitly fast-forward clean submodules to origin/main.
.\scripts\update-pins.ps1 -Apply
```

The scripts read [mods.json](mods.json) as the collection manifest. They do not build, deploy, or launch games; each child repository owns those procedures.
