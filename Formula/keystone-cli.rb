require_relative "../Manifests/keystone-cli"

class KeystoneCli < Formula
  include KeystoneCliManifest

  desc "Command-line interface for Keystone"
  homepage "https://github.com/#{REPO}"
  version VERSION
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'osx-arm64'}}"
      sha256 SHA256["osx-arm64"]
    end
    on_intel do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'osx-x64'}}"
      sha256 SHA256["osx-x64"]
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'linux-arm64'}}"
      sha256 SHA256["linux-arm64"]
    end
    on_intel do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'linux-x64'}}"
      sha256 SHA256["linux-x64"]
    end
  end

  def install
    libexec.install "keystone-cli"
    libexec.install "appsettings.json"

    bin.write_exec_script libexec/"keystone-cli"

    man1.install "keystone-cli.1"
    pkgshare.install "LICENSE"
  end

  test do
    system bin/"keystone-cli", "info"
  end
end
