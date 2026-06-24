# npmjs Public Registry Recipe

This recipe publishes `@codenote-net/hello-cli` to the public npmjs.com registry from GitHub Actions using npm Trusted Publishing.

Trusted Publishing uses GitHub Actions OIDC instead of a long-lived `NPM_TOKEN`. For a public repository and public package, npm also generates provenance automatically when the package is published through Trusted Publishing.

## Published Result

After the package is published, users can run:

```sh
npx @codenote-net/hello-cli
```

Expected output:

```text
Ohayou gozaimasu, Konnichiwa, Konbanwa!
```

## Prerequisites

- The package name `@codenote-net/hello-cli` exists on npmjs.com or is available for first publish.
- `packages/hello-cli/package.json` has `publishConfig.access: public`.
- The GitHub workflow file exists at `.github/workflows/publish-hello-cli.yml`.
- The GitHub repository is public so npm can attach provenance.
- The release workflow runs on a GitHub-hosted runner.
- Node.js 22.14 or newer and npm 11.15.0 or newer are used in the publish job.

## One-Time npm Setup

On npmjs.com, open the package settings for `@codenote-net/hello-cli`.

If this is the first publish and the package settings page does not exist yet, use your npm organization's current first-package setup flow without adding an npm publish token to GitHub repository or organization secrets. Future publishes for this recipe should go through Trusted Publishing only.

Configure Trusted Publishing:

```text
Provider: GitHub Actions
Organization or user: codenote-net
Repository: cli-distribution-recipes
Workflow filename: publish-hello-cli.yml
Environment name: release
Allowed actions: npm publish, npm stage publish
```

Then open Settings -> Publishing access and select:

```text
Require two-factor authentication and disallow tokens
```

This keeps long-lived npm publish tokens out of the repository and organization secrets. There should be no `NPM_TOKEN` secret for this publish path.

## One-Time GitHub Setup

Create a GitHub Deployment Environment named:

```text
release
```

Configure it with required reviewers so a human approves the publish job before it receives the environment.

Recommended baseline:

- Required reviewers: at least one maintainer
- Deployment branches and tags: restrict to the release process used by the repository
- Environment name: exactly `release`

The environment name must match both the workflow and the npm Trusted Publisher configuration.

## Publish Workflow

The workflow lives at:

```text
.github/workflows/publish-hello-cli.yml
```

It uses:

- `release: published` for normal release publishing
- `workflow_dispatch` for manual testing or staged publishing
- `permissions: id-token: write, contents: read`
- GitHub-hosted `ubuntu-latest`
- protected environment `release`
- Node.js 24 with npm 11.15.0 or newer
- pinned `actions/checkout` and `actions/setup-node` commit SHAs
- `package-manager-cache: false`
- `npm ci`
- CLI output verification before publishing

Normal release publish:

```sh
gh release create v0.1.0 --title "v0.1.0" --notes "Publish @codenote-net/hello-cli 0.1.0"
```

After the workflow reaches the `release` environment gate, approve the deployment in GitHub Actions.

## Staged Publishing Gate

For an additional human approval step before the package becomes live, run the workflow manually with:

```text
publish_mode: stage
```

The workflow runs:

```sh
npm stage publish
```

After the package is staged, inspect it from an authenticated maintainer machine:

```sh
npm stage list @codenote-net/hello-cli
npm stage view <stage-id>
npm stage download <stage-id>
```

Approve it with MFA:

```sh
npm stage approve <stage-id>
```

You can also review and approve staged packages from the npmjs.com Staged Packages tab. Approval requires proof of presence with 2FA. Staged publishing works well for this single-package recipe, but per-package approval does not batch cleanly in larger monorepos.

## Hardened Variant: PR-Merge Based Release

For a stronger multi-boundary release design:

1. Create a version bump PR.
2. Review and merge the PR.
3. Trigger the publish job only from the reviewed PR pathway.
4. Protect the `release` Environment with required reviewers.
5. Restrict deployment branches to GitHub's merge refs, such as `refs/pull/*/merge`, when that release model is used.
6. Publish directly with `npm publish`, or stage with `npm stage publish` and approve with MFA.

This design forces a publish to cross several independent boundaries: repository write access, reviewed source changes, environment approval, OIDC Trusted Publishing, and optional npm staged-publish approval.

## Verify

After publishing, verify the package metadata:

```sh
npm view @codenote-net/hello-cli version
npm view @codenote-net/hello-cli dist
```

Verify install paths:

```sh
npx @codenote-net/hello-cli
npm install -g @codenote-net/hello-cli
codenote-hello
```

Expected output:

```text
Ohayou gozaimasu, Konnichiwa, Konbanwa!
```

On npmjs.com, confirm that the package page shows provenance linked to:

```text
codenote-net/cli-distribution-recipes
.github/workflows/publish-hello-cli.yml
```

## Security Best Practices

- Prefer OIDC Trusted Publishing over stored npm tokens.
- Keep zero standing npm publish tokens for this package after Trusted Publishing is configured.
- Use `Require two-factor authentication and disallow tokens` for npm publishing access.
- Grant only `id-token: write` and `contents: read` to the release workflow.
- Pin third-party GitHub Actions to commit SHAs.
- Disable dependency caching in release jobs.
- Use protected GitHub Environments with required reviewers.
- Store operator credentials in a password manager that requires MFA before extraction.
- Use fine-grained, least-privilege GitHub PATs when local automation needs GitHub API access.

## Known Limitations

- The package is not available from npmjs.com until the npm-side Trusted Publisher, GitHub `release` Environment, and first release publish are completed.
- Provenance proves origin, not build-time integrity. A contaminated build can still receive a valid provenance statement.
- Provenance is generated only for public repositories and public packages.
- If publishing moves into a reusable workflow, npm Trusted Publishing must reference the caller workflow file.
- Trusted Publisher configurations created after May 20, 2026 must explicitly select at least one allowed action.
- Each package supports only one Trusted Publisher configuration.
- Self-hosted runners are not supported for npm Trusted Publishing.
- `npm stage approve` is a per-package approval flow and does not batch cleanly for monorepos.

## References

- npm Docs: Trusted publishing for npm packages: https://docs.npmjs.com/trusted-publishers/
- npm Docs: Generating provenance statements: https://docs.npmjs.com/generating-provenance-statements/
- npm Docs: Staged publishing for npm packages: https://docs.npmjs.com/staged-publishing/
