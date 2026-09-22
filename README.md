# blankmeta Homebrew tap

## Codex Lobby

Your Codex and Claude accounts, limits, and sessions in one terminal menu. Choose an account with the arrow keys and press Enter.

```sh
brew install blankmeta/tap/codex-lobby
cxl
```

Choose **Add account → ChatGPT or Claude**, then sign in in your browser. Missing tools install automatically. VLESS is optional. Supports Apple Silicon and Intel Macs.

[Project and instructions](https://github.com/blankmeta/codex-lobby)

The formula bundles pinned Codex CLI and codex-auth versions in its own installation directory, without replacing globally installed commands. Python, Node, and Xray are Homebrew dependencies. All source archives and resources have SHA-256 checksums.

Update with `brew update && brew upgrade blankmeta/tap/codex-lobby`.

Run `cxl` to choose a Codex or Claude account. Previous Codex Switch installations migrate through Homebrew; existing account data stays in place.
