# Verify the Signed Google Drive Artifact

Download these files from the same signed distribution set:

```text
codenote-hello-<version>.zip
codenote-hello-<version>.zip.bundle
codenote-hello-<version>.zip.sha256
VERIFY.md
```

Verify the SHA-256 checksum first:

```sh
shasum -a 256 -c codenote-hello-<version>.zip.sha256
```

Then verify the keyless cosign signature:

```sh
cosign verify-blob \
  --bundle codenote-hello-<version>.zip.bundle \
  --certificate-identity "https://github.com/codenote-net/cli-distribution-recipes/.github/workflows/sign-hello-cli-artifacts.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  codenote-hello-<version>.zip
```

Install the CLI only if both checks succeed.

If the artifact is modified after signing, `cosign verify-blob` must fail.
