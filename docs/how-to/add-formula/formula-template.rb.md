# Formula Template

<!-- Ruby templates are in separate files because `brew style` runs rubocop-md
     on all markdown in the tap. When a single .md file contains multiple Ruby
     code blocks with different top-level definitions, rubocop flags
     Style/OneClassPerFile — and the tap's .rubocop.yml is ignored by brew. -->

Template for `Formula/<formula-name>.rb`:

```ruby
require_relative "../Manifests/example"

class Example < Formula
  include ExampleManifest

  desc "<description>"
  homepage "https://github.com/#{REPO}"
  version VERSION
  license "<license>"

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
    # Customize based on archive contents
    bin.install "<binary-name>"
    # Optional: man pages, config files, etc.
  end

  test do
    system bin/"<binary-name>", "--version"
  end
end
```
