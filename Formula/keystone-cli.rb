class KeystoneCli < Formula
  desc "Command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.1.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.8/keystone-cli_0.1.8_osx-arm64.tar.gz"
      sha256 "259d8a36c328e8175e2f791c98ddbdff580974848733814932e963ddc9e4d388"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.8/keystone-cli_0.1.8_osx-x64.tar.gz"
      sha256 "67cbef21d1ac43fcf2131f7604173ec6e1fcdc840643772f3c77607f57e4ce6f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.8/keystone-cli_0.1.8_linux-arm64.tar.gz"
      sha256 "5dd4f8b2d3851729a74dfb31742d4148b1b913d37b0e1d4a84a1849b17a5fe59"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.8/keystone-cli_0.1.8_linux-x64.tar.gz"
      sha256 "6579354dc119525eacce1a8ad8a7da150476ff58f541487f492f1e3e494e0a6e"
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
