require_relative "../Manifests/ci-tools"

class CiTools < Formula
  include CiToolsManifest

  desc "CI/CD tools for GitHub Actions workflows"
  homepage "https://github.com/#{REPO}"
  version VERSION
  license "MIT"

  depends_on "curl"
  depends_on "jq"

  on_macos do
    on_arm do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{format(ASSET_TEMPLATE, version: VERSION, platform: "osx-arm64")}"
      sha256 SHA256["osx-arm64"]
    end
    on_intel do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{format(ASSET_TEMPLATE, version: VERSION, platform: "osx-x64")}"
      sha256 SHA256["osx-x64"]
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{format(ASSET_TEMPLATE, version: VERSION, platform: "linux-arm64")}"
      sha256 SHA256["linux-arm64"]
    end
    on_intel do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{format(ASSET_TEMPLATE, version: VERSION, platform: "linux-x64")}"
      sha256 SHA256["linux-x64"]
    end
  end

  def install
    bin.install "validate-action-pins"
    man1.install "validate-action-pins.1"
    pkgshare.install "LICENSE"
  end

  test do
    system bin/"validate-action-pins", "--version"
  end
end
