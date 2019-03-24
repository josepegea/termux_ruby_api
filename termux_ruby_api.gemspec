
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "termux_ruby_api/version"

Gem::Specification.new do |spec|
  spec.name          = "termux_ruby_api"
  spec.version       = TermuxRubyApi::VERSION
  spec.authors       = ["Josep Egea"]
  spec.email         = ["jes@josepegea.com"]

  spec.summary       = %q{A Ruby interface for the Termux API in Android}
  spec.description   = %q{Control your Android device from Ruby thanks to Termux, Termux API and these Ruby bindings}
  spec.homepage      = "https://github.com/josepegea/termux_ruby_api"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 5.2.2"
  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
