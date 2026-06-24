#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
PACKAGE_DIR="$REPO_ROOT/packages/hello-cli"
DIST_DIR="$SCRIPT_DIR/dist"
PACKAGE_VERSION=$(node -p "require(process.argv[1]).version" "$PACKAGE_DIR/package.json")
ZIP_NAME="codenote-hello-$PACKAGE_VERSION.zip"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

PACK_OUTPUT=$(npm pack "$PACKAGE_DIR" --pack-destination "$DIST_DIR" --json)
PACKAGE_TARBALL=$(printf '%s' "$PACK_OUTPUT" | node -e 'let input = ""; process.stdin.on("data", chunk => input += chunk); process.stdin.on("end", () => console.log(JSON.parse(input)[0].filename));')

test -f "$DIST_DIR/$PACKAGE_TARBALL"
cp "$SCRIPT_DIR/INSTALL.md" "$DIST_DIR/INSTALL.md"

(
  cd "$DIST_DIR"
  zip -q "$ZIP_NAME" "$PACKAGE_TARBALL" INSTALL.md
)

printf '%s\n' "$DIST_DIR/$ZIP_NAME"
