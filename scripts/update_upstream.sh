#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Init submodules..."
git submodule update --init --recursive

echo "📡 Pulling latest in each submodule (ff-only)..."
git submodule foreach --recursive '
  set -e
  echo ""
  echo "==> $name"
  git fetch origin --prune --progress
  # pull current branch if attached; otherwise pull default branch
  b="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$b" = "HEAD" ]; then
    b="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD | sed "s|^origin/||")"
    [ -z "$b" ] && b="master"
    git checkout -B "$b" "origin/$b" || true
  fi
  git pull --ff-only --progress origin "$b" || true
'

if [[ -z "$(git status --porcelain)" ]]; then
  echo "✅ No submodule pointer changes."
  exit 0
fi

echo "📝 Committing updated submodule pointers..."
git add .gitmodules upstream
git commit -m "Bump upstream submodules" || true
git push || true
echo "✅ Done."