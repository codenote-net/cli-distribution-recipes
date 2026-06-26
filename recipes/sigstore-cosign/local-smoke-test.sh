#!/usr/bin/env sh
set -eu

COSIGN_VERSION="${COSIGN_VERSION:-3.0.6}"
COSIGN_TOOL="aqua:sigstore/cosign@$COSIGN_VERSION"
COSIGN_PASSWORD="${COSIGN_PASSWORD:-local-smoke-test}"
NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-${TMPDIR:-/tmp}/codenote-npm-cache}"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
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

if command -v shasum >/dev/null 2>&1; then
  checksum_create() {
    shasum -a 256 "$1" > "$1.sha256"
  }

  checksum_verify() {
    shasum -a 256 -c "$1"
  }
elif command -v sha256sum >/dev/null 2>&1; then
  checksum_create() {
    sha256sum "$1" > "$1.sha256"
  }

  checksum_verify() {
    sha256sum --check "$1"
  }
else
  printf 'shasum or sha256sum is required for this smoke test.\n' >&2
  exit 1
fi

"$REPO_ROOT/recipes/sigstore-cosign/check-certificate-identity.sh" >/dev/null

NPM_CONFIG_CACHE="$NPM_CONFIG_CACHE" "$REPO_ROOT/recipes/sigstore-cosign/build-artifacts.sh" "$WORK_DIR" >/dev/null
cd "$WORK_DIR"

tgz_count=$(find . -maxdepth 1 -name '*.tgz' -type f | wc -l | tr -d ' ')
zip_count=$(find . -maxdepth 1 -name '*.zip' -type f | wc -l | tr -d ' ')
if [ "$tgz_count" -ne 1 ] || [ "$zip_count" -ne 1 ]; then
  printf 'Expected exactly one .tgz and one .zip artifact in %s.\n' "$WORK_DIR" >&2
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

  checksum_create "$artifact"

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

  checksum_verify "$artifact.sha256" >/dev/null
  printf 'ok: %s bundle, checksum, and tamper failure\n' "$artifact"
done
