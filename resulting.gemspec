require_relative "lib/resulting/version"

Gem::Specification.new do |spec|
  spec.name          = "resulting"
  spec.version       = Resulting::VERSION
  spec.authors       = ["John DeWyze"]
  spec.email         = ["john@dewyze.dev"]

  spec.summary       = "Library for result handling and graceful saving"
  spec.description   = <<~DESCRIPTION
    Resulting is a library for graceful result handling. It provides a result
    class with a few methods that can be used as a mixin. Using these results,
    they can be passed to save and validation services which handle them
    gracefully, returning early when there is a failure, or ensuring success
    for all objects before returning success.
  DESCRIPTION
  spec.homepage = "https://github.com/dewyze/resulting"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dewyze/resulting"
  spec.metadata["changelog_uri"] = "https://github.com/dewyze/resulting/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rspec"
end
