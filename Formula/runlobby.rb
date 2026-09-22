class Runlobby < Formula
  desc "Codex and Claude accounts, limits and sessions in one terminal menu"
  homepage "https://github.com/blankmeta/runlobby"
  license "MIT"
  version_scheme 1

  depends_on :macos

  if Hardware::CPU.arm?
    url "https://github.com/blankmeta/runlobby/releases/download/v1.5.1/runlobby-1.5.1-darwin-arm64.tar.gz"
    sha256 "8476a1ceef3630d6789f7cd8d8c4c27a63d8fde6639eccdd7181ba5526addcd7"
  else
    url "https://github.com/blankmeta/runlobby/releases/download/v1.5.1/runlobby-1.5.1-darwin-x64.tar.gz"
    sha256 "6aeeccd5f94ab545d85d384e22f6f83de93693a3e121f40108fdf9044544a536"
  end

  on_arm do
    resource "codex-auth" do
      url "https://registry.npmjs.org/@loongphy/codex-auth-darwin-arm64/-/codex-auth-darwin-arm64-0.3.0.tgz"
      sha256 "d19cdcbfe7e7bdb5929205bfa19a01fa5753ed14565fd58db3ceae4375e83e96"
    end
    resource "node-runtime" do
      url "https://nodejs.org/dist/v24.13.0/node-v24.13.0-darwin-arm64.tar.gz"
      sha256 "d595961e563fcae057d4a0fb992f175a54d97fcc4a14dc2d474d92ddeea3b9f8"
    end
  end

  on_intel do
    resource "codex-auth" do
      url "https://registry.npmjs.org/@loongphy/codex-auth-darwin-x64/-/codex-auth-darwin-x64-0.3.0.tgz"
      sha256 "d2455c9729428256d84a80ad0ceeaa33af507cc9850e3e0835da420ab67f1e6c"
    end
    resource "node-runtime" do
      url "https://nodejs.org/dist/v24.13.0/node-v24.13.0-darwin-x64.tar.gz"
      sha256 "6f03c1b48ddbe1b129a6f8038be08e0899f05f17185b4d3e4350180ab669a7f3"
    end
  end

  def install
    # Keep the embedded runtime beside its launchers; no global runtime upgrades.
    libexec.install Dir["*"]
    resource("codex-auth").stage do
      (libexec/"auth").install "bin"
      (pkgshare/"licenses").install "LICENSE" => "codex-auth-LICENSE"
    end
    resource("node-runtime").stage do
      (libexec/"node/bin").install "bin/node"
      (pkgshare/"licenses").install "LICENSE" => "node-LICENSE"
    end
    %w[runlobby rlb codex-lobby cxl codex-switch codex-vpn codex-proxy].each do |name|
      (bin/name).write <<~SH
        #!/bin/sh
        export PATH="#{libexec}/auth/bin:#{libexec}/node/bin:$PATH"
        export CODEX_AUTH_NODE_EXECUTABLE="#{libexec}/node/bin/node"
        if [ -z "${SSL_CERT_FILE:-}" ] && [ -r /etc/ssl/cert.pem ]; then
          export SSL_CERT_FILE=/etc/ssl/cert.pem
        fi
        exec "#{libexec}/#{name}" "$@"
      SH
      (bin/name).chmod 0755
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
      Live session statistics appear beside the agent. F8 hides the panel.
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
    # Old global tools must not hide the original account registry or trigger upgrades.
    (testpath/"old-tools").mkpath
    %w[codex-auth node].each do |name|
      (testpath/"old-tools"/name).write "#!/bin/sh\nexit 42\n"
      (testpath/"old-tools"/name).chmod 0755
    end
    ENV.prepend_path "PATH", testpath/"old-tools"
    assert_match version.to_s, shell_output("#{bin}/codex-switch --version")
    assert_match version.to_s, shell_output("#{bin}/runlobby --version")
    assert_match version.to_s, shell_output("#{bin}/rlb --version")
    assert_match version.to_s, shell_output("#{bin}/codex-lobby --version")
    assert_match version.to_s, shell_output("#{bin}/cxl --version")
    assert_match version.to_s, shell_output("#{bin}/codex-vpn --version")
    assert_match "Ready", pipe_output("#{bin}/codex-switch setup", "1\n", 0)
    assert_equal false, JSON.parse((testpath/"settings/settings.json").read)["proxy_enabled"]
    assert_match "off", shell_output("#{bin}/rlb monitor off")
    assert_equal false, JSON.parse((testpath/"settings/settings.json").read)["monitor_enabled"]
    assert_match "on", shell_output("#{bin}/rlb monitor on")
    assert_match "on", shell_output("#{bin}/rlb monitor status")
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
