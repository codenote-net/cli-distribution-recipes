#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s <dist-dir>\n' "$0" >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
DIST_DIR=$1

"$REPO_ROOT/recipes/_shared/build-hello-google-drive-zip.sh" "$DIST_DIR" >/dev/null
cp "$REPO_ROOT/recipes/google-drive-with-cosign/VERIFY.md" "$DIST_DIR/VERIFY.md"
rm "$DIST_DIR/INSTALL.md"

printf '%s\n' "$DIST_DIR"
