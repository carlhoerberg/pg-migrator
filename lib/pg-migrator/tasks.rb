require_relative '../pg-migrator'
require 'uri'

namespace :db do
  task :setup do
    next if @migrator
    next if ENV['DATABASE_URL'].nil?
    uri = URI.parse ENV['DATABASE_URL']
    conn_hash = 
      if uri.opaque
        { :dbname => uri.opaque }
      else
        { :host => uri.host,
          :port => uri.port || 5432,
          :dbname => uri.path[1..-1],
          :user => uri.user,
          :password => uri.password
        }
      end
    @migrator = PG::Migrator.new conn_hash
  end

  desc 'Drops all schemas currently in the search_path and then applies all the migrations'
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

