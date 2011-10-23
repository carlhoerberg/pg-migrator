# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pg-migrator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Carl Hörberg"]
  gem.email         = ["carl.hoerberg@gmail.com"]
  gem.description   = %q{Simple PG Migrator}
  gem.summary       = %q{Drop raw sql files in db/migrations and add require 'pg-migrator/tasks' in your Rakefile}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "pg-migrator"
  gem.require_paths = ["lib"]
  gem.version       = PG::Migrator::VERSION

  gem.add_dependency 'pg'
  gem.add_development_dependency 'minitest'

end
