require_relative '../pg-migrator'
require 'uri'

namespace :db do
  task :setup do
    next unless ENV['DATABASE_URL']
    uri = URI.parse ENV['DATABASE_URL']
    if uri.opaque
      @migrator = PG::Migrator.new(:dbname => uri.opaque)
    else
      @migrator = PG::Migrator.new(uri.host, uri.port, nil, nil, uri.path.sub(/\//, ''), uri.user, uri.password)
    end
  end

  desc 'Drops the "public" schema and runs all the migrations'
  task :reset => :setup do
    @migrator.reset 
  end

  desc 'Migrate up'
  task :migrate => 'migrate:up'

  namespace :migrate do
    desc 'Migrate up'
    task :up => :setup do
      @migrator.migrate_up
    end

    desc 'Migrate down the latest applied migration'
    task :down => :setup do
      @migrator.migrate_down
    end
  end
end

