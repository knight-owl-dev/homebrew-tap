# Manifest Template

<!-- Ruby templates are in separate files because `brew style` runs rubocop-md
     on all markdown in the tap. When a single .md file contains multiple Ruby
     code blocks with different top-level definitions, rubocop flags
     Style/OneClassPerFile — and the tap's .rubocop.yml is ignored by brew. -->

Template for `Manifests/<formula-name>.rb`:

```ruby
# typed: strict
# frozen_string_literal: true

# AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
# Update with: scripts/update-formula.sh <formula-name> <version>

module ExampleManifest
  VERSION = "<version>"
  REPO = "<org>/<repo>"
  TAG_PREFIX = "v"
  ASSET_TEMPLATE = "<name>_%<version>s_%<platform>s.tar.gz"

  SHA256 = {
    "osx-arm64"   => "<sha256>",
    "osx-x64"     => "<sha256>",
    "linux-arm64" => "<sha256>",
    "linux-x64"   => "<sha256>",
  }.freeze
end
```
