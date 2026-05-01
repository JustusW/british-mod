# Development workflow

This repository is set up for local Factorio mod development on Windows.

## What is already configured

- The repo includes PowerShell helpers for an isolated local Factorio dev workflow (under `tools/`).
- The helpers auto-detect common Windows Factorio install locations or accept `-FactorioRoot`.
- The default isolated dev profile root is a sibling directory named `<repo-name>-dev-profile`.
- The default isolated dev mods directory is `<dev-profile>\mods`.
- The default isolated dev write-data directory is `<dev-profile>\player-data`.

## Core workflow

1. Create a junction from the repo into the isolated dev mods directory:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\link-mod.ps1
   ```

2. Launch Factorio with the isolated dev mods directory:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\start-factorio.ps1 -LinkFirst
   ```

3. Restart Factorio cleanly after script or prototype changes:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\restart-factorio.ps1 -LinkFirst
   ```

4. Tail the current Factorio log while testing:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\tail-log.ps1
   ```

5. Run a headless load check against the isolated dev profile:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\check-load.ps1
   ```

6. Run a headless runtime smoke test that creates a save and advances it a few ticks:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\check-runtime.ps1
   ```

7. Pack a release zip for the mod portal under `dist/`:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\tools\build.ps1
   ```

Run the validation helpers one at a time. They both rewrite the isolated dev profile and can collide if launched in parallel.

## Notes

- `link-mod.ps1` reads `info.json` and creates a junction named `<mod-name>_<version>` in the mods directory — currently `hmfea_<version>`.
- By default, the helpers use a sibling `british-mod-dev-profile` directory outside the repo so test launches do not load your normal `%APPDATA%\Factorio\mods` collection and the repo does not contain a self-referential mod junction.
- `start-factorio.ps1` also generates a dedicated config file and routes Factorio write-data into the isolated profile, which keeps logs, saves, and lock files out of the shared profile.
- `restart-factorio.ps1` closes any running Factorio process, waits for it to exit, and relaunches through `start-factorio.ps1`.
- Set `BRITISH_MOD_FACTORIO_DEV_ROOT` if you want these helpers to use a different isolated profile root.
- Pass `-ModsPath "$env:APPDATA\Factorio\mods"` explicitly if you want to target the shared mods directory instead.
- `start-factorio.ps1` auto-detects common Factorio install locations and can be pointed at a custom path with `-FactorioRoot`.
- The current branch targets Factorio 2.0 in `info.json`.

## Spec-first feature flow

When implementing a new feature, **first** update [requirements.md](requirements.md) (player-facing intent) and [design.md](design.md) (implementation choices), and only then write the code. The docs lead, the code follows.
