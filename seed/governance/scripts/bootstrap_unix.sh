#!/usr/bin/env bash
set -euo pipefail

# SWAIF / Maestro Bootstrap (prepare an EXISTING project folder)
#
# - You already created the project folder (optionally already cloned an empty repo into it).
# - This script copies Maestro base seed + your chosen preset into that folder.
# - Optionally unzips a project bundle into the folder.
# - No git init / remote / push.

PROJECT_DIR=""
PRESET_REL=""
BUNDLE_ZIP=""
FORCE="0"

usage() {
  cat <<'USAGE'
Usage:
  bootstrap.sh --preset <preset_rel> [--project <dir>] [--bundle <zip>] [--force]

Examples:
  # Run inside the project folder:
  ../innovai-maestro-main/bootstrap.sh --preset speckit_project_setups/copilot_proj

  # Run from anywhere:
  ./bootstrap.sh --project ../swaif-hunter --preset speckit_project_setups/codex_proj

  # Apply bundle:
  ./bootstrap.sh --project ../swaif-hunter --preset presets/my_mvp --bundle ./project_bundle.zip
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="${2:-}"; shift 2;;
    --preset)  PRESET_REL="${2:-}"; shift 2;;
    --bundle)  BUNDLE_ZIP="${2:-}"; shift 2;;
    --force)   FORCE="1"; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: unknown argument: $1"; usage; exit 1;;
  esac
done

if [[ -z "$PRESET_REL" ]]; then
  echo "ERROR: --preset is required."
  usage
  exit 1
fi

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="$(pwd)"
fi

MAESTRO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_SEED_DIR="$MAESTRO_DIR/seed/governance"
PRESET_DIR="$BASE_SEED_DIR/$PRESET_REL"

need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing dependency: $1"; exit 1; }; }
has_cmd() { command -v "$1" >/dev/null 2>&1; }

copy_tree() {
  local src="$1"
  local dst="$2"
  [[ -d "$src" ]] || return 0
  mkdir -p "$dst"
  if has_cmd rsync; then
    rsync -a "$src"/ "$dst"/
  else
    cp -a "$src"/. "$dst"/
  fi
}

echo "==> Maestro: $MAESTRO_DIR"
echo "==> Target:  $PROJECT_DIR"
echo "==> Preset:  $PRESET_DIR"

if [[ ! -d "$BASE_SEED_DIR" ]]; then
  echo "ERROR: base seed not found: $BASE_SEED_DIR"
  exit 1
fi
if [[ ! -d "$PRESET_DIR" ]]; then
  echo "ERROR: preset not found: $PRESET_DIR"
  echo "Tip: --preset must be relative to seed/governance/"
  exit 1
fi
if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: project dir not found: $PROJECT_DIR"
  exit 1
fi

if [[ "$FORCE" != "1" ]] && [[ -n "$(ls -A "$PROJECT_DIR" 2>/dev/null || true)" ]]; then
  echo "==> Note: target directory is not empty. Files may be overwritten (expected)."
fi

cd "$PROJECT_DIR"

echo "==> Applying base seed (governance)"
copy_tree "$BASE_SEED_DIR/.github"  ".github"
copy_tree "$BASE_SEED_DIR/.specify" ".specify"
copy_tree "$BASE_SEED_DIR/docs"     "docs"
copy_tree "$BASE_SEED_DIR/specs"    "specs"

for f in "AGENTS.md" "CODEOWNERS" ".editorconfig" ".gitignore" "CONTRIBUTING.md"; do
  [[ -f "$BASE_SEED_DIR/$f" ]] && cp -f "$BASE_SEED_DIR/$f" "./$f"
done

mkdir -p docs/sources docs/codex specs

echo "==> Applying preset (overrides base where needed)"
copy_tree "$PRESET_DIR" "."

echo "==> Bundle"
if [[ -n "$BUNDLE_ZIP" ]]; then
  need_cmd unzip
  [[ -f "$BUNDLE_ZIP" ]] || { echo "ERROR: bundle zip not found: $BUNDLE_ZIP"; exit 1; }
  unzip -o "$BUNDLE_ZIP" >/dev/null
else
  if [[ -f "./project_bundle.zip" ]]; then
    need_cmd unzip
    unzip -o "./project_bundle.zip" >/dev/null
  else
    echo "==> No bundle provided/detected. Skipping."
  fi
fi

echo ""
echo "✅ Bootstrap completed."
echo "Key checks:"
echo "  - .specify/memory/constitution.md"
echo "  - .github/ (copilot/codex instructions per preset)"
echo "  - docs/ and specs/"
