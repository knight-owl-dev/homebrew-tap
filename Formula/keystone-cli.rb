class KeystoneCli < Formula
  desc "Command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.1.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.7/keystone-cli_0.1.7_osx-arm64.tar.gz"
      sha256 "43acab61c80bbfec349d9eba71561c8b08d24f95c404521473b0f27bd017baae"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.7/keystone-cli_0.1.7_osx-x64.tar.gz"
      sha256 "76b0fb471cb454d5328ac2163354ffb8f502ab0efa417998f11027bf1a43d952"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.7/keystone-cli_0.1.7_linux-arm64.tar.gz"
      sha256 "f960d4f3fd563a3bf70afaa4e87fc5c70a1644b8712b02a7696f6dc5c5cf6c3d"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.7/keystone-cli_0.1.7_linux-x64.tar.gz"
      sha256 "171611d4ec84ad61704e37c1ebbd2f8503906cea7b3bc72f5cd5f3df3f703188"
    end
  end

  def install
    # Keep the binary and config together in libexec, expose via wrapper in bin/
    libexec.install "keystone-cli"
    libexec.install "appsettings.json"

    bin.write_exec_script libexec/"keystone-cli"

    man1.install "keystone-cli.1"
    pkgshare.install "LICENSE"
  end

  test do
    system "#{bin}/keystone-cli", "info"
  end
end
