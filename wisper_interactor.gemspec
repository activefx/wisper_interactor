# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisper_interactor/version'

Gem::Specification.new do |spec|
  spec.name          = "wisper_interactor"
  spec.version       = WisperInteractor::VERSION
  spec.authors       = ["Matt Solt"]
  spec.email         = ["mattsolt@gmail.com"]

  spec.summary       = %q{Extend Interactor (https://github.com/collectiveidea/interactor) with PubSub capabilities using Wisper (https://github.com/krisleech/wisper).}
  spec.description   = %q{Extend Interactor (https://github.com/collectiveidea/interactor) with PubSub capabilities using Wisper (https://github.com/krisleech/wisper).}
  spec.homepage      = "https://github.com/activefx/wisper_interactor"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "wisper-rspec"

  spec.add_dependency "wisper", "~> 1.0", "< 2"
  spec.add_dependency "interactor", "~> 3.0", "< 4"
end
