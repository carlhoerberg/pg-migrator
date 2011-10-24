# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pg-migrator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Carl Hörberg"]
  gem.email         = ["carl.hoerberg@gmail.com"]
  gem.description   = %q{Rake migration tasks which utilities pure SQL files}
  gem.summary       = %q{Drop raw SQL files in db/migrations and add require 'pg-migrator/tasks' to your Rakefile}
  gem.homepage      = "https://github.com/carlhoerberg/pg-migrator"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "pg-migrator"
  gem.require_paths = ["lib"]
  gem.version       = PG::Migrator::VERSION

  gem.add_dependency 'pg'
  gem.add_development_dependency 'minitest'

end
