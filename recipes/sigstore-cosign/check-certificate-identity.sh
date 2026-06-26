#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
WORKFLOW_FILE="$REPO_ROOT/.github/workflows/sign-hello-cli-artifacts.yml"

EXPECTED_IDENTITY=$(awk -F'"' '/CERTIFICATE_IDENTITY:/ { print $2; exit }' "$WORKFLOW_FILE" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$EXPECTED_IDENTITY" ]; then
  printf 'CERTIFICATE_IDENTITY was not found in %s\n' "$WORKFLOW_FILE" >&2
  exit 1
fi

CHECK_FILES="
$REPO_ROOT/recipes/sigstore-cosign/README.md
$REPO_ROOT/recipes/google-drive-with-cosign/README.md
$REPO_ROOT/recipes/google-drive-with-cosign/VERIFY.md
"

for file in $CHECK_FILES; do
  if ! grep -F "$EXPECTED_IDENTITY" "$file" >/dev/null; then
    printf 'Missing certificate identity in %s: %s\n' "$file" "$EXPECTED_IDENTITY" >&2
    exit 1
  fi
done

FOUND_IDENTITIES=$(
  grep -Eho 'https://github\.com/[^" <>`]+/\.github/workflows/[^" <>`]+@refs/(heads|tags)/[^" <>`]+' $CHECK_FILES "$WORKFLOW_FILE" |
    sed 's/[.,;:)]*$//' |
    sort -u
)

if [ -z "$FOUND_IDENTITIES" ]; then
  printf 'No certificate identity URLs were found in the checked files.\n' >&2
  exit 1
fi

if [ "$FOUND_IDENTITIES" != "$EXPECTED_IDENTITY" ]; then
  printf 'Documented certificate identities do not match CERTIFICATE_IDENTITY.\n' >&2
  printf 'Expected:\n%s\n\nFound:\n%s\n' "$EXPECTED_IDENTITY" "$FOUND_IDENTITIES" >&2
  exit 1
fi

printf 'certificate identity ok: %s\n' "$EXPECTED_IDENTITY"
