
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "parallax/version"

Gem::Specification.new do |spec|
  spec.name          = "parallax"
  spec.version       = Parallax::VERSION
  spec.authors       = ["Francesco Ballardin"]
  spec.email         = ["francesco.ballardin@develonproject.com"]

  spec.summary       = %q{Enhances Ruby inter-process communication, to boost your parallel code execution.}
  spec.description   = %q{Enhances Ruby inter-process communication, to boost your parallel code execution.}
  spec.homepage      = "https://github.com/Pluvie/ruby-parallax"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rainbow"
end
