# @codenote-net/hello-cli

Minimal sample CLI used as the base artifact for distribution recipes in this repository.

It prints a fixed greeting so package, signing, and distribution workflows can be compared without changing the application behavior.

## Usage

Run without installing globally:

```sh
npx @codenote-net/hello-cli
```

Or install globally:

```sh
npm install -g @codenote-net/hello-cli
```

Then run:

```sh
codenote-hello
```

Output:

```text
Ohayou gozaimasu, Konnichiwa, Konbanwa!
```

## Repository Development

When working from a clone of `codenote-net/cli-distribution-recipes`, run the executable directly with Node:

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
