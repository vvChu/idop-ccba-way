#!/bin/sh
# Install IDOP git hooks
# Usage: sh tools/hooks/install.sh

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  echo "Error: not inside a git repository"
  exit 1
fi

HOOKS_SRC="$REPO_ROOT/tools/hooks"
HOOKS_DST="$REPO_ROOT/.git/hooks"

echo "Installing IDOP git hooks..."

cp "$HOOKS_SRC/pre-commit" "$HOOKS_DST/pre-commit"
chmod +x "$HOOKS_DST/pre-commit" 2>/dev/null || true

echo "Installed: pre-commit"
echo "Done. Hooks are active."
