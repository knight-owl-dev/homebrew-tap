class KeystoneCli < Formula
  desc "Command-line interface for Keystone"
  homepage "https://github.com/Knight-Owl-Dev/keystone-cli"
  version "0.1.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.9/keystone-cli_0.1.9_osx-arm64.tar.gz"
      sha256 "5acb67f220135c72bd6347ae19e0dbf40c078c3821d2c0b638914e255d9210b7"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.9/keystone-cli_0.1.9_osx-x64.tar.gz"
      sha256 "4a9fc64d5e8a530b652656f0977749f67f2b0d5b0e84406f494694c4919bcd95"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.9/keystone-cli_0.1.9_linux-arm64.tar.gz"
      sha256 "a455bb4c1ade1f0e384c689fc22105ebeeb01448faa78b1fd3bf9400acec3b29"
    else
      url "https://github.com/Knight-Owl-Dev/keystone-cli/releases/download/v0.1.9/keystone-cli_0.1.9_linux-x64.tar.gz"
      sha256 "275f8d6c336da51e3e765d05343c8de7fcecfd8ceaae2f6a6fca4628d83376ab"
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
