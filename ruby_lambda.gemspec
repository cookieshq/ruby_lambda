
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby_lambda/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_lambda"
  spec.version       = RubyLambda::VERSION
  spec.authors       = ["cookieshq", "denissellu"]
  spec.email         = ["denis@cookieshq.co.uk"]

  spec.summary       = %q{RubyLambda is a toolset for developing and deploying serverless Ruby app in AWS Lambda.}
  spec.description   = %q{Command line tool to locally run, test and deploy your Ruby app to AWS Lambda.}
  spec.homepage      = "https://cookieshq.co.uk"
  spec.license       = "MIT"
  spec.metadata      = {
    'source_code_uri'   => 'https://github.com/cookieshq/ruby_lambda',
    'documentation_uri' => 'https://github.com/cookieshq/ruby_lambda'
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'bin'
  spec.executables   = %w[ruby-lambda]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'awesome_print', '~> 1.8.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
end
