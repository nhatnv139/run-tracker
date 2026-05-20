#!/usr/bin/env bash
# Sync GitHub labels defined in .github/labels.yml into the current repository.
#
# Requires:
#   - gh (GitHub CLI) authenticated
#   - yq v4+ (https://github.com/mikefarah/yq)
#
# Usage:
#   bash .github/scripts/sync-labels.sh              # add / update
#   PRUNE=1 bash .github/scripts/sync-labels.sh      # additionally delete labels not in labels.yml

set -euo pipefail

LABELS_FILE="$(git rev-parse --show-toplevel)/.github/labels.yml"

if [[ ! -f "$LABELS_FILE" ]]; then
  echo "labels.yml not found at $LABELS_FILE" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing dependency: gh CLI (https://cli.github.com/)" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "Missing dependency: yq v4+ (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Syncing labels into $REPO from $LABELS_FILE"

count=$(yq '. | length' "$LABELS_FILE")
declare -A desired

for i in $(seq 0 $((count - 1))); do
  name=$(yq ".[$i].name" "$LABELS_FILE")
  color=$(yq ".[$i].color" "$LABELS_FILE")
  description=$(yq ".[$i].description // \"\"" "$LABELS_FILE")

  desired["$name"]=1

  if gh label list --limit 200 --json name -q '.[].name' | grep -Fxq "$name"; then
    echo "  update: $name"
    gh label edit "$name" --color "$color" --description "$description" >/dev/null
  else
    echo "  create: $name"
    gh label create "$name" --color "$color" --description "$description" >/dev/null
  fi
done

if [[ "${PRUNE:-0}" == "1" ]]; then
  echo "Pruning labels not present in labels.yml ..."
  while IFS= read -r existing; do
    if [[ -z "${desired[$existing]:-}" ]]; then
      echo "  delete: $existing"
      gh label delete "$existing" --yes >/dev/null
    fi
  done < <(gh label list --limit 200 --json name -q '.[].name')
fi

echo "Done."
