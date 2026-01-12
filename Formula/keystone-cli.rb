class KeystoneCli < Formula
  desc "Command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.1.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.5/keystone-cli_0.1.5_osx-arm64.tar.gz"
      sha256 "fc311c1d5c306aaa78cce379669b9404c8f0707e7553770da4ef33e643b6003b"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.5/keystone-cli_0.1.5_osx-x64.tar.gz"
      sha256 "43a4a9636ce41e4dc0320ee6ee236d9ee0f6e1ac1d901e476719099e34888af9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.5/keystone-cli_0.1.5_linux-arm64.tar.gz"
      sha256 "f9401acaedd6f76897576034c301e43010bda33a47d2c7acc4a01ba61ba9fc46"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.5/keystone-cli_0.1.5_linux-x64.tar.gz"
      sha256 "caa7ad5b69928fc3e35580fd7dbdef55c2ca892beb33856a2b6ed1a1b786eb05"
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
