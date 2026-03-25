#!/usr/bin/env zsh
set -uo pipefail

# =============================================================================
# sync-upstreams.sh — Fetch latest from all upstream skill repos
#
# Each upstream is cloned/pulled into sources/<name>/ as a full mirror.
# Git remotes named "upstream-<name>" are used for tracking.
#
# Usage:
#   ./sync-upstreams.sh           # full sync
#   ./sync-upstreams.sh --status  # show status only
# =============================================================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCES_DIR="${REPO_DIR}/sources"
CONFIG="${REPO_DIR}/upstreams.json"

STATUS_ONLY=false
[[ "${1:-}" == "--status" ]] && STATUS_ONLY=true

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

mkdir -p "$SOURCES_DIR"

SUCCESS=0
FAILED=0
TOTAL=0

# Parse upstreams.json with python
ENTRIES=$(python3 -c "
import json
with open('$CONFIG') as f:
    for s in json.load(f)['sources']:
        print(f\"{s['name']}|{s['upstream']}|{s['branch']}\")
")

echo "${CYAN}═══════════════════════════════════════════════════${NC}"
echo "${CYAN}  Skills Upstream Sync${NC}"
echo "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

while IFS='|' read -r name upstream branch; do
  ((TOTAL++))
  target="${SOURCES_DIR}/${name}"

  if $STATUS_ONLY; then
    if [[ -d "$target/.git" ]]; then
      cd "$target"
      local_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "?")
      echo "  ${GREEN}OK${NC}  ${name} @ ${local_hash} (${branch})"
    else
      echo "  ${RED}MISSING${NC}  ${name}"
    fi
    continue
  fi

  echo -n "  ${name} (${branch})... "

  if [[ ! -d "$target/.git" ]]; then
    # First time: clone
    if git clone --quiet --single-branch --branch "$branch" "$upstream" "$target" 2>/dev/null; then
      echo "${GREEN}cloned${NC}"
      ((SUCCESS++))
    else
      echo "${RED}clone failed${NC}"
      ((FAILED++))
    fi
  else
    # Existing: fetch + merge
    cd "$target"

    # Stash if dirty
    STASHED=0
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      git stash push -m "auto-stash" --quiet 2>/dev/null
      STASHED=1
    fi

    if git fetch origin "$branch" --quiet 2>/dev/null; then
      if git merge "origin/${branch}" -X theirs --no-edit --quiet 2>/dev/null; then
        echo "${GREEN}updated${NC}"
        ((SUCCESS++))
      else
        git merge --abort 2>/dev/null || true
        echo "${YELLOW}fetch ok, merge skipped${NC}"
        ((SUCCESS++))
      fi
    else
      echo "${RED}fetch failed${NC}"
      ((FAILED++))
    fi

    if [[ "$STASHED" -eq 1 ]]; then
      git stash pop --quiet 2>/dev/null || true
    fi
  fi
done <<< "$ENTRIES"

echo ""
echo "${CYAN}═══════════════════════════════════════════════════${NC}"
if $STATUS_ONLY; then
  echo "  ${TOTAL} sources checked"
else
  echo "  ${GREEN}${SUCCESS} synced${NC}  ${RED}${FAILED} failed${NC}  (${TOTAL} total)"
fi
echo "${CYAN}═══════════════════════════════════════════════════${NC}"
