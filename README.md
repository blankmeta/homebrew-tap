# blankmeta Homebrew tap

## Codex Switch

Run isolated ChatGPT account profiles for Codex, remember a profile per project, and see usage limits. VLESS is optional.

```sh
brew install blankmeta/tap/codex-switch
codex-switch
```

The first run guides you through connection setup and ChatGPT sign-in. Dependencies install automatically. Supports Apple Silicon and Intel Macs.

[Project and instructions](https://github.com/blankmeta/codex-switch)

The formula bundles pinned Codex CLI and codex-auth versions in its own installation directory, without replacing globally installed commands. Python, Node, and Xray are Homebrew dependencies. All source archives and resources have SHA-256 checksums.

Update with `brew update && brew upgrade blankmeta/tap/codex-switch`.
