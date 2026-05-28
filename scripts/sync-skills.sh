#!/bin/bash
# Sync skills from platform-agnostic directory to platform-specific directories
# Skills are organized under skills/<category>/ but flattened at the target.
# Usage: ./scripts/sync-skills.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${PROJECT_ROOT}/skills"

# Target directories for different AI CLI platforms
TARGETS=(
  "${PROJECT_ROOT}/.gemini/skills"
)

echo "🔄 Syncing skills from ${SOURCE_DIR}..."

for target in "${TARGETS[@]}"; do
  if [ -d "$(dirname "$target")" ]; then
    mkdir -p "$target"
    # Flatten: copy contents from all subdirectories in skills/
    for category_dir in "${SOURCE_DIR}"/*/; do
      if [ -d "$category_dir" ] && [ -n "$(ls -A "$category_dir" 2>/dev/null)" ]; then
        cp -r "${category_dir}"* "${target}/"
      fi
    done
    echo "✅ Synced to ${target}"
  else
    echo "⏭️  Skipped ${target} (parent directory does not exist)"
  fi
done

echo "🎉 Skills sync complete."
