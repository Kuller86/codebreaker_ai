lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "codebreaker_ai/version"

Gem::Specification.new do |spec|
  spec.name          = "codebreaker_ai"
  spec.version       = CodebreakerAi::VERSION
  spec.authors       = ["Alexander Ivanitsa"]
  spec.email         = ["alexander.ivanitsa@gmail.com"]

  spec.summary       = %q{Codebreaker game}
  spec.description   = %q{Codebreaker game}
  spec.homepage      = "https://github.com/Kuller86/codebreaker_ai"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = "https://github.com/Kuller86/codebreaker_ai"
  spec.metadata["source_code_uri"] = "https://github.com/Kuller86/codebreaker_ai"
  spec.metadata["changelog_uri"] = "https://github.com/Kuller86/codebreaker_ai"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = "codebreaker_ai"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "bundle-audit", "~> 0.1.0"
  spec.add_development_dependency "fasterer", "~> 0.5.1"
  spec.add_development_dependency "rubocop", "~> 0.69.0"
  spec.add_development_dependency "rubocop-performance", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop-rspec", "~> 1.33"
  spec.add_development_dependency "simplecov", "~> 0.16.1"
end
