# innovai-maestro Makefile
# Purpose:
# - Seed/Update innovai-governance from local seed files
# - Apply governance into any project repo (e.g., Pilot)
# - Initialize Spec Kit scaffolding in project repos (if not present)

SHELL := /usr/bin/env bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

# -------- Config (edit these defaults) --------
WORKDIR        ?= $(HOME)/innovai

GOV_REPO_URL   ?= https://github.com/innovai-outlier/innovai-governance.git
MAESTRO_REPO_URL ?= https://github.com/innovai-outlier/innovai-maestro.git

# Target project (set PROJECT=Pilot or any repo name)
PROJECT        ?= Pilot
PROJECT_REPO_URL ?= https://github.com/<YOUR_ORG_OR_USER>/$(PROJECT).git

# Tag to create in governance when you run gov-tag
GOV_TAG        ?= v0.1.0

# Paths
GOV_DIR        ?= $(WORKDIR)/innovai-governance
PROJECT_DIR    ?= $(WORKDIR)/$(PROJECT)

SEED_GOV_DIR   ?= $(CURDIR)/seed/governance

# Spec Kit CLI invocation (requires uv installed)
SPECIFY_INIT_CMD ?= uvx --from git+https://github.com/github/spec-kit.git specify init . --ai copilot

# Files that must exist in governance + must be copied into project repos
GOV_FILES := \
  .specify/memory/constitution.md \
  .github/copilot-instructions.md \
  docs/spec-workflow.md \
  docs/chatgpt-intake.md \
  docs/interviews/question-bank.v1.json \
  docs/interviews/host-script.v1.md

# Where to consider "code" changes (for future CI gates; kept here for reference)
CODE_DIRS := src app packages

# -------- Helpers --------
.PHONY: help
help:
	@cat <<'EOF'
Targets:

  deps-check               - Verify required tools are installed (git, uvx)
  gov-clone                - Clone innovai-governance into WORKDIR if missing
  project-clone            - Clone PROJECT into WORKDIR if missing (set PROJECT, PROJECT_REPO_URL)
  gov-seed                 - Copy seed/governance/* into innovai-governance working tree (no commit)
  gov-commit               - Commit & push governance changes (after gov-seed)
  gov-tag                  - Tag & push GOV_TAG in governance repo

  project-init-speckit      - Initialize Spec Kit in PROJECT if not already present
  project-apply-governance   - Copy governance files into PROJECT + commit & push
  project-update             - Pull latest governance + project, then apply governance again

Quickstart (first time):
  1) Put your governance pack under: seed/governance/  (same paths as GOV_FILES)
  2) make deps-check
  3) make gov-clone gov-seed gov-commit gov-tag GOV_TAG=v0.1.0
  4) make project-clone PROJECT=Pilot PROJECT_REPO_URL=... 
  5) make project-init-speckit PROJECT=Pilot
  6) make project-apply-governance PROJECT=Pilot

EOF

.PHONY: deps-check
deps-check:
	command -v git >/dev/null || (echo "Missing: git" && exit 1)
	command -v uvx >/dev/null || (echo "Missing: uv (uvx). Install uv: https://docs.astral.sh/uv/" && exit 1)
	echo "OK: deps present (git, uvx)"

.PHONY: gov-clone
gov-clone:
	mkdir -p "$(WORKDIR)"
	if [ ! -d "$(GOV_DIR)/.git" ]; then
	  git clone "$(GOV_REPO_URL)" "$(GOV_DIR)"
	else
	  echo "Governance repo already cloned at: $(GOV_DIR)"
	fi

.PHONY: project-clone
project-clone:
	mkdir -p "$(WORKDIR)"
	if [ ! -d "$(PROJECT_DIR)/.git" ]; then
	  git clone "$(PROJECT_REPO_URL)" "$(PROJECT_DIR)"
	else
	  echo "Project repo already cloned at: $(PROJECT_DIR)"
	fi

.PHONY: gov-seed
gov-seed: gov-clone
	# Validate seed exists
	if [ ! -d "$(SEED_GOV_DIR)" ]; then
	  echo "Missing seed dir: $(SEED_GOV_DIR)"
	  echo "Create it and place governance files there using the same paths as GOV_FILES."
	  exit 1
	fi

	# Validate required files exist in seed
	for f in $(GOV_FILES); do
	  if [ ! -f "$(SEED_GOV_DIR)/$$f" ]; then
	    echo "Missing seed file: $(SEED_GOV_DIR)/$$f"
	    exit 1
	  fi
	done

	cd "$(GOV_DIR)"
	# Copy seed files into governance repo (preserve paths)
	for f in $(GOV_FILES); do
	  mkdir -p "$$(dirname "$$f")"
	  cp -f "$(SEED_GOV_DIR)/$$f" "$$f"
	done
	echo "Seeded governance working tree at $(GOV_DIR)"

.PHONY: gov-commit
gov-commit:
	cd "$(GOV_DIR)"
	git status --porcelain
	if [ -z "$$(git status --porcelain)" ]; then
	  echo "No changes to commit in governance."
	  exit 0
	fi
	git add .
	git commit -m "Update governance pack"
	git push

.PHONY: gov-tag
gov-tag:
	cd "$(GOV_DIR)"
	# Create tag only if not exists locally
	if git rev-parse "$(GOV_TAG)" >/dev/null 2>&1; then
	  echo "Tag already exists locally: $(GOV_TAG)"
	else
	  git tag "$(GOV_TAG)"
	fi
	# Push tag (safe if already exists remotely will fail; you can delete/retag manually if needed)
	git push origin "$(GOV_TAG)" || true
	echo "Tag pushed (or already existed): $(GOV_TAG)"

.PHONY: project-init-speckit
project-init-speckit: project-clone
	cd "$(PROJECT_DIR)"
	if [ -d ".specify" ]; then
	  echo "Spec Kit already initialized in $(PROJECT_DIR)"
	  exit 0
	fi
	$(SPECIFY_INIT_CMD)
	git add .
	git commit -m "Initialize Spec Kit scaffolding"
	git push
	echo "Spec Kit initialized and pushed for $(PROJECT)"

.PHONY: project-apply-governance
project-apply-governance: gov-clone project-clone
	# Ensure governance repo is up to date
	cd "$(GOV_DIR)"
	git pull --rebase || true

	# Validate governance has required files
	for f in $(GOV_FILES); do
	  if [ ! -f "$(GOV_DIR)/$$f" ]; then
	    echo "Missing in governance repo: $(GOV_DIR)/$$f"
	    echo "Run: make gov-seed gov-commit (and optionally gov-tag)"
	    exit 1
	  fi
	done

	cd "$(PROJECT_DIR)"
	# Copy governance files into project (Copilot requires local .github/copilot-instructions.md)
	for f in $(GOV_FILES); do
	  mkdir -p "$$(dirname "$$f")"
	  cp -f "$(GOV_DIR)/$$f" "$$f"
	done

	if [ -z "$$(git status --porcelain)" ]; then
	  echo "No governance changes to apply to $(PROJECT)."
	  exit 0
	fi

	git add .
	git commit -m "Apply InnovAI governance $(GOV_TAG)"
	git push
	echo "Applied governance to $(PROJECT) and pushed."

.PHONY: project-update
project-update: gov-clone project-clone
	cd "$(GOV_DIR)"
	git pull --rebase || true
	cd "$(PROJECT_DIR)"
	git pull --rebase || true
	$(MAKE) project-apply-governance PROJECT="$(PROJECT)" PROJECT_REPO_URL="$(PROJECT_REPO_URL)" GOV_TAG="$(GOV_TAG)"