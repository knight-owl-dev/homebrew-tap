class KeystoneCli < Formula
  desc "A command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.0/keystone-cli_0.1.0_osx-arm64.tar.gz"
      sha256 "f0b2578e929fd1ad4845b4c2ac266eb29b91100551accf81fe27d49ec1b81758"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.0/keystone-cli_0.1.0_osx-x64.tar.gz"
      sha256 "58c7ade83f31e4321ddce0028b21c431484c4fe63b4b3ca8011575c9b51454cf"
    end
  end

  def install
    # Keep the binary and appsettings together, then expose the command via a wrapper in bin/.
    libexec.install "keystone-cli"
    libexec.install "appsettings.json"

    bin.write_exec_script libexec/"keystone-cli"

    man1.install "keystone-cli.1"
  end

  test do
    system "#{bin}/keystone-cli", "info"
  end
end
