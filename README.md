# cli-distribution-recipes

Practical, security-conscious recipes for distributing a command-line tool through different channels — public registries, private registries, out-of-band file delivery, and managed device (MDM) deployment.

Each recipe distributes the same minimal sample CLI, [`@codenote-net/hello-cli`](packages/hello-cli/), so that the channels can be compared head to head without the application itself getting in the way. Every recipe focuses on the parts that actually differ between channels: authentication, integrity and signing, provenance and audit, and the scale the channel fits.

## Sample CLI

All recipes publish or deliver [`@codenote-net/hello-cli`](packages/hello-cli/), a fixed-output greeting CLI. It prints:

```text
Ohayou gozaimasu, Konnichiwa, Konbanwa!
```

Because the artifact never changes, any difference you see between recipes comes from the distribution channel, not the code.

## Recipe Comparison Matrix

| Recipe / Channel | Category | Authentication | Integrity & signing | Provenance & audit | Scale fit | Status | Link |
|---|---|---|---|---|---|---|---|
| npmjs public | Public registry | OIDC Trusted Publishing (tokenless) | npm provenance (auto) | Yes — provenance attestation + transparency log | Public distribution | ✅ Done | [recipes/npmjs-public/](recipes/npmjs-public/README.md) |
| Google Drive | Out-of-band | Shared link / per-account share | None yet (add checksum or signature separately) | No | Individual / internal | ✅ Done | [recipes/google-drive/](recipes/google-drive/README.md) |
| Google Drive with cosign | Out-of-band | Shared link / per-account share + GitHub Actions OIDC signing | cosign bundle + SHA-256 | Yes — transparency log-backed keyless signature | Individual / internal | ✅ Done | [recipes/google-drive-with-cosign/](recipes/google-drive-with-cosign/README.md) |
| AWS CodeArtifact | Private registry | Short-lived token / IAM | TBD | Partial — registry access logs | Internal | 📋 Planned | — |
| Azure Artifacts | Private registry | Short-lived token / Entra ID | TBD | Partial — registry access logs | Internal | 📋 Planned | — |
| Google Cloud Artifact Registry | Private registry | Short-lived token / IAM | TBD | Partial — registry access logs | Internal | 📋 Planned | — |
| Sigstore cosign | Signing | OIDC (keyless) | cosign bundle + SHA-256 | Yes — transparency log-backed keyless signature | Public distribution | ✅ Done | [recipes/sigstore-cosign/](recipes/sigstore-cosign/README.md) |
| Code signing: macOS notarization | Signing | Apple Developer ID | OS code signing + notarization | Partial — Apple notarization ticket | Public distribution | 📋 Planned | — |
| Code signing: Windows Authenticode | Signing | Code signing certificate | OS code signing | Partial — timestamping authority | Public distribution | 📋 Planned | — |
| Jamf (macOS MDM) | MDM | MDM enrollment | OS code signing (via packaged artifact) | Yes — MDM deployment records | Internal | 📋 Planned | — |
| Intune (Windows MDM) | MDM | MDM enrollment | OS code signing (via packaged artifact) | Yes — MDM deployment records | Internal | 📋 Planned | — |

## Comparison Axes

Each column in the matrix is a deliberately fixed comparison axis. New recipes are evaluated against the same axes so the matrix stays consistent.

- **Recipe / Channel** — the distribution channel the recipe demonstrates (e.g. npmjs public, Google Drive, AWS CodeArtifact).
- **Category** — the kind of channel:
  - *Public registry* — a registry anyone can install from (e.g. npmjs.com).
  - *Private registry* — an access-controlled registry for internal consumers.
  - *Out-of-band* — file delivery outside any package registry (shared links, object storage).
  - *Signing* — recipes whose primary purpose is integrity/authenticity signing rather than transport.
  - *MDM* — managed deployment to enrolled devices via a mobile device management platform.
- **Authentication** — how a publisher proves it may publish, and how a consumer proves it may install. Prefer tokenless OIDC and short-lived credentials over long-lived stored tokens.
- **Integrity & signing** — what protects the artifact from tampering and proves who produced it: provenance attestations, cosign signatures, checksums, OS code signing, or nothing.
- **Provenance & audit** — whether the channel offers verifiable origin and an audit trail, such as a transparency log, attestations, or access/deployment records.
- **Scale fit** — the audience the channel realistically serves:
  - *Individual* — ad hoc delivery to one or a few people.
  - *Internal* — distribution within an organization.
  - *Public distribution* — open distribution to anyone.

## Status Legend

| Status | Meaning |
|---|---|
| ✅ Done | Recipe is implemented and documented under `recipes/`. |
| 📋 Planned | Recipe is on the roadmap; the matrix row is a placeholder until it lands. |

## Repository Layout

```text
packages/
  hello-cli/        Sample CLI shared by every recipe
recipes/
  npmjs-public/     Public npmjs.com publishing via OIDC Trusted Publishing
  google-drive/     Out-of-band distribution via a Google Drive share link
  google-drive-with-cosign/
                    Google Drive distribution with cosign verification files
  sigstore-cosign/  Keyless cosign signing for built artifacts
```

## Maintenance

The comparison matrix is the source of truth for what this repository covers, and it is maintained by hand.

**Adding a recipe means appending one row to the matrix.** Keep the columns fixed: if a recipe does not fit the existing axes, adjust the axis definitions deliberately rather than adding ad hoc columns. When a planned recipe is implemented, change its **Status** to ✅ Done and point its **Link** at the new `recipes/<name>/README.md`.
