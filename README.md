# blankmeta Homebrew tap

## Codex Switch

Choose a ChatGPT account for Codex, see usage limits, and optionally connect over VLESS.

```sh
brew install blankmeta/tap/codex-switch
codex-switch
```

The first run guides you through connection setup and ChatGPT sign-in. Dependencies install automatically. Supports Apple Silicon and Intel Macs.

[Project and instructions](https://github.com/blankmeta/codex-switch)

The formula bundles pinned Codex CLI and codex-auth versions in its own installation directory, without replacing globally installed commands. Python, Node, and Xray are Homebrew dependencies. All source archives and resources have SHA-256 checksums.

Update with `brew update && brew upgrade blankmeta/tap/codex-switch`.
