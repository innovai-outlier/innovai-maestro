<#
SWAIF / Maestro Bootstrap (prepare an EXISTING project folder)

- You already created the project folder (optionally already cloned an empty repo into it).
- Copies Maestro base seed + your chosen preset into that folder.
- Optionally unzips a project bundle into the folder.
- No git init / remote / push.

Example:
  # run inside project folder:
  ..\innovai-maestro-main\bootstrap.ps1 -Preset "speckit_project_setups\copilot_proj"

  # run from anywhere:
  .\bootstrap.ps1 -ProjectPath "..\swaif-hunter" -Preset "speckit_project_setups\codex_proj"
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Preset,

  [Parameter(Mandatory = $false)]
  [string]$ProjectPath = (Get-Location).Path,

  [Parameter(Mandatory = $false)]
  [string]$BundleZip = "",

  [switch]$Force
)

$MaestroDir  = $PSScriptRoot
$BaseSeedDir = Join-Path $MaestroDir "seed\governance"
$PresetDir   = Join-Path $BaseSeedDir $Preset

function Ensure-Dir([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Copy-Tree([string]$Src, [string]$Dst) {
  if (-not (Test-Path -LiteralPath $Src)) { return }
  Ensure-Dir $Dst
  Get-ChildItem -LiteralPath $Src -Force | ForEach-Object {
    $target = Join-Path $Dst $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
  }
}

Write-Host "==> Maestro: $MaestroDir"
Write-Host "==> Target:  $ProjectPath"
Write-Host "==> Preset:  $PresetDir"

if (-not (Test-Path -LiteralPath $BaseSeedDir)) { throw "Base seed not found: $BaseSeedDir" }
if (-not (Test-Path -LiteralPath $PresetDir))   { throw "Preset not found: $PresetDir`nTip: -Preset must be relative to seed\governance" }
if (-not (Test-Path -LiteralPath $ProjectPath)) { throw "ProjectPath not found: $ProjectPath" }

if (-not $Force) {
  $items = Get-ChildItem -LiteralPath $ProjectPath -Force -ErrorAction SilentlyContinue
  if ($items -and $items.Count -gt 0) {
    Write-Host "==> Note: target directory is not empty. Files may be overwritten (expected)."
  }
}

Set-Location -LiteralPath $ProjectPath

Write-Host "==> Applying base seed (governance)"
Copy-Tree (Join-Path $BaseSeedDir ".github")  (Join-Path $ProjectPath ".github")
Copy-Tree (Join-Path $BaseSeedDir ".specify") (Join-Path $ProjectPath ".specify")
Copy-Tree (Join-Path $BaseSeedDir "docs")     (Join-Path $ProjectPath "docs")
Copy-Tree (Join-Path $BaseSeedDir "specs")    (Join-Path $ProjectPath "specs")

$singleFiles = @("AGENTS.md","CODEOWNERS",".editorconfig",".gitignore","CONTRIBUTING.md")
foreach ($f in $singleFiles) {
  $src = Join-Path $BaseSeedDir $f
  if (Test-Path -LiteralPath $src) {
    Copy-Item -LiteralPath $src -Destination (Join-Path $ProjectPath $f) -Force
  }
}

Ensure-Dir (Join-Path $ProjectPath "docs\sources")
Ensure-Dir (Join-Path $ProjectPath "docs\codex")
Ensure-Dir (Join-Path $ProjectPath "specs")

Write-Host "==> Applying preset (overrides base where needed)"
Copy-Tree $PresetDir $ProjectPath

Write-Host "==> Bundle"
$autoBundle = Join-Path $ProjectPath "project_bundle.zip"
if ([string]::IsNullOrWhiteSpace($BundleZip) -and (Test-Path -LiteralPath $autoBundle)) {
  $BundleZip = $autoBundle
  Write-Host "==> Auto-detected bundle: $BundleZip"
}

if (-not [string]::IsNullOrWhiteSpace($BundleZip)) {
  if (-not (Test-Path -LiteralPath $BundleZip)) { throw "Bundle zip not found: $BundleZip" }
  Expand-Archive -LiteralPath $BundleZip -DestinationPath $ProjectPath -Force
} else {
  Write-Host "==> No bundle provided/detected. Skipping."
}

Write-Host ""
Write-Host "✅ Bootstrap completed."
Write-Host "Key checks:"
Write-Host "  - .specify\memory\constitution.md"
Write-Host "  - .github\ (copilot/codex instructions per preset)"
Write-Host "  - docs\ and specs\"
