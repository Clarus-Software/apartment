# frozen_string_literal: true

version = File.read(File.expand_path("APARTMENT_VERSION", __dir__)).strip

Gem::Specification.new do |s|
  s.name = 'clarus-apartment'
  s.version = version

  s.authors       = ['Ryan Brunner', 'Brad Robertson', 'Rui Baltazar']
  s.summary       = 'A Ruby gem for managing database multitenancy. Apartment Gem drop in replacement'
  s.description   = 'Apartment allows Rack applications to deal with database multitenancy through ActiveRecord'
  s.email         = ['team@clarussoftware.co.uk']
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      # NOTE: ignore all test related
      f.match(%r{^(test|spec|features|documentation)/})
    end
  end
  s.executables   = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.homepage = 'https://github.com/Clarus-Software/apartment'
  s.licenses = ['MIT']

  s.add_dependency 'activerecord', '>= 5.0.0', '< 7.2'
  s.add_dependency 'parallel', '< 2.0'
  s.add_dependency 'public_suffix', '>= 2.0.5', '< 5.0'
  s.add_dependency 'rack', '>= 1.3.6', '< 3.1'
end
