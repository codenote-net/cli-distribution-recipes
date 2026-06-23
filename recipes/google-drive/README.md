# Google Drive Distribution Recipe

This recipe packages `@codenote-net/hello-cli` as a self-contained zip and distributes it through a Google Drive share link.

Use this pattern when the CLI must be delivered as a shared file instead of through a public or private npm registry.

## Artifact

The distributable archive is:

```text
codenote-hello-<version>.zip
├── codenote-net-hello-cli-<version>.tgz
└── INSTALL.md
```

The zip is self-contained. A recipient can install the CLI by extracting the archive and following `INSTALL.md`.

## Build

Requirements:

- Node.js 22 or newer
- npm
- zip

From the repository root, run:

```sh
ZIP_PATH=$(recipes/google-drive/build-distribution-zip.sh)
printf '%s\n' "$ZIP_PATH"
```

The script:

1. Runs `npm pack packages/hello-cli`
2. Copies `recipes/google-drive/INSTALL.md` into the distribution directory
3. Creates `recipes/google-drive/dist/codenote-hello-<version>.zip`

To inspect the zip contents:

```sh
unzip -l "$ZIP_PATH"
```

Expected files:

```text
codenote-net-hello-cli-<version>.tgz
INSTALL.md
```

## Upload to Google Drive

1. Open Google Drive in a browser.
2. Upload the zip path printed by `recipes/google-drive/build-distribution-zip.sh`.
3. Open the file sharing dialog.

## Share

For this public demo recipe, set access to:

```text
Anyone with the link
```

Copy the share link. It will look like:

```text
https://drive.google.com/file/d/FILE_ID/view?usp=sharing
```

For production use, do not use public link sharing unless that is the intended access model. Restrict access to specific Google accounts by email, then send the link only to those recipients.

## Download

### Browser

Open the Google Drive share link in a browser and download the zip file.

### Terminal

Install `gdown` if it is not already available:

```sh
python3 -m pip install --user gdown
```

Download by file ID:

```sh
FILE_ID="replace-with-google-drive-file-id"
gdown "https://drive.google.com/uc?id=${FILE_ID}" -O codenote-hello.zip
```

For the email-restricted production variant, the terminal download must run under an authenticated Google account that has access to the file. Anonymous terminal downloads only work for files shared as `Anyone with the link`.

## Install and Verify

Extract the downloaded zip:

```sh
unzip codenote-hello.zip -d codenote-hello
cd codenote-hello
```

Follow the bundled instructions:

```sh
cat INSTALL.md
npm install -g ./*.tgz
codenote-hello
```

Expected output:

```text
Ohayou gozaimasu, Konnichiwa, Konbanwa!
```

## Limitations

- No integrity or authenticity guarantee is provided by this recipe. Add checksums, signatures, or notarization separately if required.
- No version discovery or auto-update mechanism is provided. Recipients must be told which file and version to download.
- `Anyone with the link` makes the file effectively public to anyone who obtains the URL.
- Email-restricted sharing requires an authenticated, authorized Google account and cannot be fetched anonymously.
- Manual upload does not scale. This recipe documents the distribution pattern, not a production upload pipeline.
