class Runlobby < Formula
  include Language::Python::Virtualenv
  desc "Codex and Claude accounts, limits and sessions in one terminal menu"
  homepage "https://github.com/blankmeta/runlobby"
  url "https://github.com/blankmeta/runlobby/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "2a0c63ef32a4be26e2288253a435232d5a20e7e9dcc0d44424ac541248044852"

  license "MIT"
  version_scheme 1

  depends_on :macos
  depends_on "node"
  depends_on "python@3.13"
  depends_on "xray"

  on_arm do
    resource "codex-cli" do
      url "https://github.com/openai/codex/releases/download/rust-v0.153.2/codex-package-aarch64-apple-darwin.tar.gz"
      sha256 "287e2dd0a9bbfb58581b0a9150399458b4f094ea42caf02860f1e8cb5a202a0b"
    end

    resource "codex-auth" do
      url "https://registry.npmjs.org/@loongphy/codex-auth-darwin-arm64/-/codex-auth-darwin-arm64-0.3.0.tgz"
      sha256 "d19cdcbfe7e7bdb5929205bfa19a01fa5753ed14565fd58db3ceae4375e83e96"
    end
  end

  on_intel do
    resource "codex-cli" do
      url "https://github.com/openai/codex/releases/download/rust-v0.153.2/codex-package-x86_64-apple-darwin.tar.gz"
      sha256 "6e3876e7f4edff2e3dee545e1d3b2334866791a8dfce7e25789bf6799355a4ea"
    end

    resource "codex-auth" do
      url "https://registry.npmjs.org/@loongphy/codex-auth-darwin-x64/-/codex-auth-darwin-x64-0.3.0.tgz"
      sha256 "d2455c9729428256d84a80ad0ceeaa33af507cc9850e3e0835da420ab67f1e6c"
    end
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  def install
    venv = virtualenv_create(libexec/"venv", Formula["python@3.13"].opt_bin/"python3.13")
    venv.pip_install resource("psutil")
    libexec.install "src"
    resource("codex-cli").stage do
      (libexec/"codex").install Dir["*"]
    end
    resource("codex-auth").stage do
      (libexec/"auth").install "bin"
      (pkgshare/"licenses").install "LICENSE" => "codex-auth-LICENSE"
    end
    bin.mkpath
    { "runlobby" => "codex_switch", "codex-proxy" => "codex_switch.compat" }.each do |name, module_name|
      (bin/name).write <<~SH
        #!/bin/sh
        export PATH="#{libexec}/codex/bin:#{libexec}/auth/bin:#{Formula["node"].opt_bin}:#{Formula["xray"].opt_bin}:$PATH"
        export CODEX_AUTH_NODE_EXECUTABLE="#{Formula["node"].opt_bin}/node"
        export PYTHONPATH="#{libexec}/src"
        exec "#{libexec}/venv/bin/python3.13" -m #{module_name} "$@"
      SH
      (bin/name).chmod 0755
    end
    %w[rlb codex-lobby cxl codex-switch codex-vpn].each { |name| bin.install_symlink "runlobby" => name }
    prefix.install "LICENSE"
    doc.install "README.md", "CHANGELOG.md", "docs"
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
