# Verify Signed Artifacts

The signed workflow artifact contains verification material for both the npm tarball and the Google Drive zip.

For the signed Google Drive distribution set, download these files together:

```text
codenote-hello-<version>.zip
codenote-hello-<version>.zip.bundle
codenote-hello-<version>.zip.sha256
VERIFY.md
```

Verify the Google Drive zip checksum first:

```sh
shasum -a 256 -c codenote-hello-<version>.zip.sha256
```

Then verify the Google Drive zip keyless cosign signature:

```sh
cosign verify-blob \
  --bundle codenote-hello-<version>.zip.bundle \
  --certificate-identity "https://github.com/codenote-net/cli-distribution-recipes/.github/workflows/sign-hello-cli-artifacts.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  codenote-hello-<version>.zip
```

Install the CLI only if both checks succeed.

If you need to verify the npm tarball directly, use the tarball files from the same workflow artifact:

```sh
shasum -a 256 -c codenote-net-hello-cli-<version>.tgz.sha256

cosign verify-blob \
  --bundle codenote-net-hello-cli-<version>.tgz.bundle \
  --certificate-identity "https://github.com/codenote-net/cli-distribution-recipes/.github/workflows/sign-hello-cli-artifacts.yml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  codenote-net-hello-cli-<version>.tgz
```

If the artifact is modified after signing, `cosign verify-blob` must fail.
