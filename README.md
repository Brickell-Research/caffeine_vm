# cvm - Caffeine Version Manager

A dead-simple version manager for the [Caffeine](https://github.com/Brickell-Research/caffeine_lang) programming language.

[![CI](https://github.com/Brickell-Research/caffeine_vm/actions/workflows/ci.yml/badge.svg)](https://github.com/Brickell-Research/caffeine_vm/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Install

```bash
brew install brickell-research/caffeine/cvm
```

## Quick Start

```bash
cvm install latest      # Install the latest version
cvm use 4.6.0           # Switch to a specific version
caffeine --help         # Use it
```

## Commands

| Command                   | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `cvm install <version>`   | Install a version (use `latest` for the most recent) |
| `cvm use <version>`       | Switch the active version                            |
| `cvm list`                | List installed versions                              |
| `cvm list-remote`         | List versions available to install                   |
| `cvm uninstall <version>` | Remove an installed version                          |
| `cvm current`             | Show the active version                              |
| `cvm which`               | Show the path to the active binary                   |
| `cvm help`                | Show help                                            |

## .caffeine-version

Running `cvm install` with no arguments reads the version from a `.caffeine-version` file in the current directory:

```bash
echo "4.6.0" > .caffeine-version
cvm install
```

## How It Works

`cvm` downloads pre-built binaries from [GitHub Releases](https://github.com/Brickell-Research/caffeine_lang/releases) into `~/.cvm/versions/<version>/`. A symlink at `~/.cvm/current` points to the active version. Your PATH includes `~/.cvm/current`, so `caffeine` always resolves to the right binary. No shims, no shell functions, no magic.

## License

[MIT](LICENSE)
