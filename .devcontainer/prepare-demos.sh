#!/usr/bin/env bash
# Puts both Copilot CLI demos back at their starting point and pre-builds them.
#
#   Demo 1 (unit tests): this folder, branch demo/tests. The unit tests for
#     decode_get_pdr_resp() have been removed so that Copilot can write them.
#   Demo 3 (security): ~/demo3, a second working copy (git worktree) of main
#     with an uncommitted change that weakens the length check in
#     decode_get_pdr_resp(). /security-review reviews uncommitted changes.
#
# Run it again at any time to reset the demos. It discards changes made
# during a rehearsal in both folders.
set -euo pipefail

REPO="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
DEMO3="${DEMO3_DIR:-$HOME/demo3}"
cd "$REPO"

git fetch --quiet --tags origin

# Make gh commands such as `gh pr create` target this fork, not upstream OpenBMC.
git config remote.origin.gh-resolved base

# Demo 1
git checkout --quiet -B demo/tests demo-tests-start
git reset --quiet --hard demo-tests-start
git clean -fdq

# Demo 3
if ! git worktree list --porcelain | grep -qx "worktree $DEMO3"; then
  rm -rf "$DEMO3"
  git worktree prune
  git worktree add --quiet -B demo3 "$DEMO3" origin/main
fi
git -C "$DEMO3" checkout --quiet -B demo3 origin/main
git -C "$DEMO3" reset --quiet --hard origin/main
git -C "$DEMO3" clean -fdq
git -C "$DEMO3" restore --source=demo-security-start --worktree -- src/dsp/platform.c

# Pre-build both, so Copilot's test runs only recompile the files it changes.
for dir in "$REPO" "$DEMO3"; do
  if [ ! -d "$dir/build" ]; then
    (cd "$dir" && meson setup build >/dev/null)
  fi
  meson compile -C "$dir/build" >/dev/null
done

echo "Demos ready."
echo "  Demo 1: cd $REPO   (branch demo/tests)"
echo "  Demo 3: cd $DEMO3  (uncommitted change in src/dsp/platform.c)"
