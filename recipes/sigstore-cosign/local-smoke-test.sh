#!/usr/bin/env sh
set -eu

COSIGN_VERSION="${COSIGN_VERSION:-3.0.6}"
COSIGN_TOOL="aqua:sigstore/cosign@$COSIGN_VERSION"
COSIGN_PASSWORD="${COSIGN_PASSWORD:-local-smoke-test}"
NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-/private/tmp/codex-npm-cache}"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
PACKAGE_DIR="$REPO_ROOT/packages/hello-cli"
GOOGLE_DRIVE_RECIPE_DIR="$REPO_ROOT/recipes/google-drive"
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/codenote-cosign-smoke.XXXXXX")

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT INT TERM

run_cosign() {
  mise x "$COSIGN_TOOL" -- cosign "$@"
}

printf 'Using work directory: %s\n' "$WORK_DIR"
printf 'Using cosign: %s\n' "$COSIGN_TOOL"

if ! command -v mise >/dev/null 2>&1; then
  printf 'mise is required for this smoke test.\n' >&2
  exit 1
fi

NPM_CONFIG_CACHE="$NPM_CONFIG_CACHE" npm pack "$PACKAGE_DIR" --pack-destination "$WORK_DIR" >/dev/null

ZIP_PATH=$(NPM_CONFIG_CACHE="$NPM_CONFIG_CACHE" "$GOOGLE_DRIVE_RECIPE_DIR/build-distribution-zip.sh")
cp "$ZIP_PATH" "$WORK_DIR/"

cd "$WORK_DIR"

artifact_count=$(find . -maxdepth 1 \( -name '*.tgz' -o -name '*.zip' \) -type f | wc -l | tr -d ' ')
if [ "$artifact_count" -ne 2 ]; then
  printf 'Expected exactly two artifacts in %s: one .tgz and one .zip.\n' "$WORK_DIR" >&2
  find . -maxdepth 1 -type f -print >&2
  exit 1
fi

COSIGN_PASSWORD="$COSIGN_PASSWORD" run_cosign generate-key-pair >/dev/null

for artifact in ./*.tgz ./*.zip; do
  if [ ! -f "$artifact" ]; then
    printf 'Missing expected artifact pattern: %s\n' "$artifact" >&2
    exit 1
  fi

  artifact=${artifact#./}

  shasum -a 256 "$artifact" > "$artifact.sha256"

  COSIGN_PASSWORD="$COSIGN_PASSWORD" run_cosign sign-blob \
    --yes \
    --key cosign.key \
    --bundle "$artifact.bundle" \
    "$artifact" >/dev/null

  run_cosign verify-blob \
    --key cosign.pub \
    --bundle "$artifact.bundle" \
    "$artifact" >/dev/null

  cp "$artifact" "$artifact.tampered"
  printf '\ntampered\n' >> "$artifact.tampered"

  if run_cosign verify-blob \
    --key cosign.pub \
    --bundle "$artifact.bundle" \
    "$artifact.tampered" >/dev/null 2>&1; then
    printf 'Tampered artifact unexpectedly passed verification: %s\n' "$artifact" >&2
    exit 1
  fi

  shasum -a 256 -c "$artifact.sha256" >/dev/null
  printf 'ok: %s bundle, checksum, and tamper failure\n' "$artifact"
done
