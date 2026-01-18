class KeystoneCli < Formula
  desc "Command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.1.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.6/keystone-cli_0.1.6_osx-arm64.tar.gz"
      sha256 "d6bc80150c56c9ba9e6984a771af865db0eb8553c4c48c2cb134d60762ad6b4a"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.6/keystone-cli_0.1.6_osx-x64.tar.gz"
      sha256 "d0c078c3f3790352c7da00223b6b1d7abca57d45bf5495915ba4e04d75412de4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.6/keystone-cli_0.1.6_linux-arm64.tar.gz"
      sha256 "7c3dc5738569a14a2cc9e801d873dad8757952a462bd1bf553dd9ec48f7bbd41"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.6/keystone-cli_0.1.6_linux-x64.tar.gz"
      sha256 "c5f04d3aa2d62db7441c2b67468b8fe26a0f9cc33717b6580e3db5b972e41d64"
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
