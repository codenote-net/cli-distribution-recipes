#!/usr/bin/env sh
set -eu

if [ "$#" -lt 1 ]; then
  printf 'Usage: %s <dist-dir> [--sidecar-doc <path>] [--omit-install-sidecar]\n' "$0" >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
PACKAGE_DIR="$REPO_ROOT/packages/hello-cli"
DIST_DIR=$1
SIDE_CAR_DOC=
OMIT_INSTALL_SIDE_CAR=0
shift

while [ "$#" -gt 0 ]; do
  case "$1" in
    --sidecar-doc)
      if [ "$#" -lt 2 ]; then
        printf '%s requires a path argument.\n' "$1" >&2
        exit 1
      fi
      SIDE_CAR_DOC=$2
      shift 2
      ;;
    --omit-install-sidecar)
      OMIT_INSTALL_SIDE_CAR=1
      shift
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

PACKAGE_VERSION=$(node -p "require(process.argv[1]).version" "$PACKAGE_DIR/package.json")
ZIP_NAME="codenote-hello-$PACKAGE_VERSION.zip"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

PACK_OUTPUT=$(npm pack "$PACKAGE_DIR" --pack-destination "$DIST_DIR" --json)
PACKAGE_TARBALL=$(printf '%s' "$PACK_OUTPUT" | node -e 'let input = ""; process.stdin.on("data", chunk => input += chunk); process.stdin.on("end", () => console.log(JSON.parse(input)[0].filename));')

test -f "$DIST_DIR/$PACKAGE_TARBALL"
cp "$REPO_ROOT/recipes/google-drive/INSTALL.md" "$DIST_DIR/INSTALL.md"

(
  cd "$DIST_DIR"
  zip -q "$ZIP_NAME" "$PACKAGE_TARBALL" INSTALL.md
)

if [ "$OMIT_INSTALL_SIDE_CAR" -eq 1 ]; then
  rm "$DIST_DIR/INSTALL.md"
fi

if [ -n "$SIDE_CAR_DOC" ]; then
  cp "$SIDE_CAR_DOC" "$DIST_DIR/$(basename "$SIDE_CAR_DOC")"
fi

printf '%s\n' "$DIST_DIR/$ZIP_NAME"
