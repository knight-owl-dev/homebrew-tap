class KeystoneCli < Formula
  desc "Command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.2.0/keystone-cli_0.2.0_osx-arm64.tar.gz"
      sha256 "153418d9a2874253e30055b7ceb1d09f7b2b9c66666ea21d204bdd9f28136ea8"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.2.0/keystone-cli_0.2.0_osx-x64.tar.gz"
      sha256 "39a586af391df07c804b32a889ce54a6f8d4df9a13b890e76ba959a278d3203b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.2.0/keystone-cli_0.2.0_linux-arm64.tar.gz"
      sha256 "16ecedac8b3767664e6787bdc6dc3828f9e7f1a4a319a5caec5763a97d948c62"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.2.0/keystone-cli_0.2.0_linux-x64.tar.gz"
      sha256 "2dac50ad132f42503dff3ed98b79a5fabb13839a5be098e97f56604b3fc744ce"
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
