#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
DIST_DIR="$SCRIPT_DIR/dist"

"$REPO_ROOT/recipes/_shared/build-hello-google-drive-zip.sh" "$DIST_DIR"
