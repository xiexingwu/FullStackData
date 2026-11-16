#!/bin/sh
# Build the site and publish it to the `release` branch, which Porkbun serves.
set -eu
cd "$(dirname "$0")"

# Only release committed work, so each release maps to a main commit.
if [ -n "$(git status --porcelain)" ]; then
  echo "main has uncommitted changes; commit or stash them first" >&2
  exit 1
fi

# Set up the release worktree if it isn't there yet, and bring it up to date.
[ -d public ] || git worktree add public release
git -C public pull --ff-only

# Build into an empty folder, then mirror it into public/.
# --delete removes pages that no longer exist; .git is left alone.
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
./zine release -o "$out"
rsync -a --delete --exclude .git "$out/" public/

git -C public add -A
if git -C public diff --cached --quiet; then
  echo "Nothing changed since the last release."
  exit 0
fi
git -C public status --short

printf "Push this release? [y/N] "
read -r ans
if [ "$ans" != y ]; then
  echo "Not pushed. The changes are staged in public/."
  exit 1
fi
git -C public commit -m "Release $(git rev-parse --short HEAD): $(git log -1 --format=%s)"
git -C public push
