# tools/check-load.ps1
#
# Headless load check in two phases:
#
#   Phase 1 — dev-link: Factorio loads the mod via the development junction
#     in the isolated dev profile (fast iteration loop). This is what most
#     code edits should be checked against.
#   Phase 2 — build path: tools/build.ps1 packs the mod into a release zip,
#     the zip replaces the junction in the dev mods dir, and Factorio is
#     re-launched against the zip. Catches packaging issues that the
#     junction hides (missing entries in build.ps1's $includes, paths that
#     work for an in-place file tree but not inside a zip).
#
# Both phases must succeed for an exit code of 0. The dev junction is
# restored after Phase 2 so the next dev launch keeps working without an
# explicit re-link.
#
# Pass -SkipBuild to run only Phase 1 (fast loop). Default behaviour runs
# both phases automatically.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\tools\check-load.ps1
#   powershell -ExecutionPolicy Bypass -File .\tools\check-load.ps1 -SkipBuild

[CmdletBinding()]
param(
  [string]$FactorioRoot = "",
  [string]$ModsPath = "",
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

$profileName = "check-{0}" -f ([guid]::NewGuid().ToString("N"))
Initialize-DevProfile -ProfileName $profileName | Out-Null

if (-not $ModsPath) {
  $ModsPath = Get-DefaultModsPath
}

if (-not (Test-Path -LiteralPath $ModsPath)) {
  New-Item -ItemType Directory -Path $ModsPath -Force | Out-Null
}

& (Join-Path $PSScriptRoot "link-mod.ps1") -ModsPath $ModsPath

$factorioRoot = Get-FactorioRoot -RequestedPath $FactorioRoot
$factorioExe = Get-FactorioExePath -FactorioRoot $factorioRoot
$configPath = Get-DefaultDevConfigPath -ProfileName $profileName

# === Phase 1: dev-link load ===
Write-Host "[check-load] Phase 1: dev-link load" -ForegroundColor Cyan
# Use Start-Process -PassThru so we can read ExitCode reliably under
# Set-StrictMode -Version Latest, where touching an unset $LASTEXITCODE throws.
$proc = Start-Process `
  -FilePath $factorioExe `
  -ArgumentList @("--config", $configPath, "--mod-directory", $ModsPath, "--dump-data", "--disable-audio") `
  -NoNewWindow `
  -Wait `
  -PassThru
if ($proc.ExitCode -ne 0) {
  Write-Host "[check-load] Phase 1 FAILED with exit $($proc.ExitCode)" -ForegroundColor Red
  exit $proc.ExitCode
}
Write-Host "[check-load] Phase 1 OK" -ForegroundColor Green

if ($SkipBuild) {
  Write-Host "[check-load] -SkipBuild set; skipping Phase 2." -ForegroundColor Yellow
  exit 0
}

# === Phase 2: build + zip load ===
Write-Host ""
Write-Host "[check-load] Phase 2: build + zip load" -ForegroundColor Cyan

# Pack the mod. build.ps1 throws on failure, which $ErrorActionPreference =
# "Stop" propagates as a script termination — exactly what we want.
& (Join-Path $PSScriptRoot "build.ps1")

$repoRoot = Get-RepoRoot
$info     = Get-ModInfo
$zipName  = "{0}_{1}.zip" -f $info.name, $info.version
$zipPath  = Join-Path $repoRoot ("dist\{0}" -f $zipName)
if (-not (Test-Path -LiteralPath $zipPath)) {
  throw "Built zip not found at $zipPath after build.ps1."
}

# Swap the dev junction for the freshly built zip in the dev mods dir.
# Reusing the same dev profile means mod-list.json already enables hmfea,
# so Factorio loads the zip the same way the live mod portal would.
$junctionName = "{0}_{1}" -f $info.name, $info.version
$junctionPath = Join-Path $ModsPath $junctionName
if (Test-Path -LiteralPath $junctionPath) {
  Remove-Item -LiteralPath $junctionPath -Force -Recurse
}
$installedZipPath = Join-Path $ModsPath $zipName
Copy-Item -LiteralPath $zipPath -Destination $installedZipPath -Force

try {
  $buildProc = Start-Process `
    -FilePath $factorioExe `
    -ArgumentList @("--config", $configPath, "--mod-directory", $ModsPath, "--dump-data", "--disable-audio") `
    -NoNewWindow `
    -Wait `
    -PassThru
  if ($buildProc.ExitCode -ne 0) {
    Write-Host "[check-load] Phase 2 FAILED with exit $($buildProc.ExitCode)" -ForegroundColor Red
    exit $buildProc.ExitCode
  }
  Write-Host "[check-load] Phase 2 OK" -ForegroundColor Green
}
finally {
  # Clean up the zip and restore the dev junction so the next dev launch
  # works without an explicit re-link. Best-effort — failures here don't
  # mask the actual Phase 2 result.
  if (Test-Path -LiteralPath $installedZipPath) {
    Remove-Item -LiteralPath $installedZipPath -Force -ErrorAction SilentlyContinue
  }
  & (Join-Path $PSScriptRoot "link-mod.ps1") -ModsPath $ModsPath -Force | Out-Null
}

exit 0
