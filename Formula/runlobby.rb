class Runlobby < Formula
  desc "Codex and Claude accounts, limits and sessions in one terminal menu"
  homepage "https://github.com/blankmeta/runlobby"
  license "MIT"
  version_scheme 1

  depends_on :macos

  on_arm do
    url "https://github.com/blankmeta/runlobby/releases/download/v1.4.1/runlobby-1.4.1-darwin-arm64.tar.gz"
    sha256 "27b4ed33a6b6267e9ac3ab0ab7ac48bfed35b5dc24aa96856f1b319650cf0122"
  end

  on_intel do
    url "https://github.com/blankmeta/runlobby/releases/download/v1.4.1/runlobby-1.4.1-darwin-x64.tar.gz"
    sha256 "378b4e25811e94952397fb90cefb3e629d10f4b75b92d8440335a1f519b82de0"
  end

  def install
    # Keep the embedded runtime beside its launchers; no global runtime upgrades.
    libexec.install Dir["*"]
    %w[runlobby rlb codex-lobby cxl codex-switch codex-vpn codex-proxy].each do |name|
      bin.install_symlink libexec/name
    end
  end

  def caveats
    <<~EOS
      Open your accounts, limits and settings:
        rlb

      For Russian prompts:
        RUNLOBBY_LANG=ru rlb

      Choose with the arrow keys and press Enter to launch.
      Press Right on an account for its actions and project preference.
      Add ChatGPT or Claude accounts from the menu. Missing tools install automatically.
      Optional VLESS: Settings -> Connection.

      Existing codex-vpn VLESS settings are detected.
      No shell configuration is required. Proxy use is optional.
    EOS
  end

  test do
    ENV["RUNLOBBY_HOME"] = (testpath/"settings").to_s
    ENV["CODEX_HOME"] = (testpath/"codex").to_s
    ENV["RUNLOBBY_LANG"] = "en"
    (testpath/"codex").mkpath
    assert_match version.to_s, shell_output("#{bin}/codex-switch --version")
    assert_match version.to_s, shell_output("#{bin}/runlobby --version")
    assert_match version.to_s, shell_output("#{bin}/rlb --version")
    assert_match version.to_s, shell_output("#{bin}/codex-lobby --version")
    assert_match version.to_s, shell_output("#{bin}/cxl --version")
    assert_match version.to_s, shell_output("#{bin}/codex-vpn --version")
    assert_match "Ready", pipe_output("#{bin}/codex-switch setup", "1\n", 0)
    assert_equal false, JSON.parse((testpath/"settings/settings.json").read)["proxy_enabled"]
    assert_match "No accounts yet", shell_output("#{bin}/codex-switch accounts")
    status = JSON.parse(shell_output("#{bin}/codex-switch status --json"))
    assert_equal 1, status["schema_version"]
    assert_equal [], status["profiles"]
    assert_nil status["project"]["profile"]
    assert_match "RunLobby: no accounts", shell_output("#{bin}/codex-switch status --line")
    assert_match "Normal connection", shell_output("#{bin}/codex-switch doctor")
    assert_match "RunLobby", shell_output("#{bin}/codex-proxy --help")
  end
end
