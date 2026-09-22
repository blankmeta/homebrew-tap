# blankmeta Homebrew tap

## RunLobby

Your Codex and Claude accounts, limits, and sessions in one terminal menu. Choose an account with the arrow keys and press Enter.

```sh
brew install blankmeta/tap/runlobby
rlb
```

Choose **Add account → ChatGPT or Claude**, then sign in in your browser. Missing tools install automatically. VLESS is optional. Supports Apple Silicon and Intel Macs.

[Project and instructions](https://github.com/blankmeta/runlobby)

Homebrew installs a verified standalone build with its Python runtime included. A private codex-auth helper and Node runtime keep existing accounts visible even if older tools are installed globally. The formula does not upgrade global Node, Python or Xray packages. RunLobby prepares other missing native tools when you choose a provider. Apple Silicon and Intel archives have separate SHA-256 checksums.

The launcher uses macOS system certificates for Python HTTPS requests and preserves an explicit `SSL_CERT_FILE` setting.

Update with `brew update && brew upgrade blankmeta/tap/runlobby`.

Run `rlb` to choose a Codex or Claude account. Previous Codex Switch installations migrate through Homebrew; existing account data stays in place.
