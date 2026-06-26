#!/usr/bin/env sh
set -eu

if [ "$#" -lt 2 ]; then
  printf 'Usage: %s <artifact> <verify-command> [args...]\n' "$0" >&2
  exit 1
fi

ARTIFACT=$1
shift
TAMPERED_ARTIFACT="$ARTIFACT.tampered"

cleanup() {
  rm -f "$TAMPERED_ARTIFACT"
}
trap cleanup EXIT INT TERM

cp "$ARTIFACT" "$TAMPERED_ARTIFACT"
printf '\ntampered\n' >> "$TAMPERED_ARTIFACT"

if "$@" "$TAMPERED_ARTIFACT" >/dev/null 2>&1; then
  printf 'Tampered artifact unexpectedly passed verification: %s\n' "$ARTIFACT" >&2
  exit 1
fi

printf 'tamper failure ok: %s\n' "$ARTIFACT"
