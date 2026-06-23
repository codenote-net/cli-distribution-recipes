#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
PACKAGE_DIR="$REPO_ROOT/packages/hello-cli"
DIST_DIR="$SCRIPT_DIR/dist"
PACKAGE_TARBALL="codenote-net-hello-cli-0.1.0.tgz"
ZIP_NAME="codenote-hello-0.1.0.zip"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

npm pack "$PACKAGE_DIR" --pack-destination "$DIST_DIR"
cp "$SCRIPT_DIR/INSTALL.md" "$DIST_DIR/INSTALL.md"

(
  cd "$DIST_DIR"
  zip -q "$ZIP_NAME" "$PACKAGE_TARBALL" INSTALL.md
)

printf '%s\n' "$DIST_DIR/$ZIP_NAME"
