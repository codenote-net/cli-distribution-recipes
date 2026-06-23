# @codenote-net/hello-cli

Minimal sample CLI used as the base artifact for distribution recipes in this repository.

It prints a fixed greeting so package, signing, and distribution workflows can be compared without changing the application behavior.

## Usage

```sh
codenote-hello
```

Output:

```text
Ohayou gozaimasu, Konnichiwa, Konbanwa!
```

## Local Run

Run the executable directly with Node:

```sh
cd packages/hello-cli
node bin/codenote-hello.js
```

Or link the package locally:

```sh
cd packages/hello-cli
npm link
codenote-hello
```
