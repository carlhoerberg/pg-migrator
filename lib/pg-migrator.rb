#encoding: utf-8
require_relative 'pg-migrator/version'
require 'pg'
require 'logger'

module PG
  class Migrator
    def initialize(database_url, migrations_dir = './db/migrations', logger = Logger.new(STDOUT))
      @pg = PGconn.connect database_url
      @pg.exec 'SET client_min_messages = warning'
      @migrations_dir = migrations_dir
      @log = logger
    end

    def reset
      @pg.transaction do |conn|
        conn.exec 'DROP SCHEMA public CASCADE'
        conn.exec 'CREATE SCHEMA public'
      end
      migrate_up
    end

    def migrate_up
      @pg.transaction do |conn|
        conn.exec "CREATE TABLE IF NOT EXISTS migration (
          id bigint PRIMARY KEY,
          name varchar(255),
          applied timestamp DEFAULT current_timestamp)
        "
        applied = conn.exec 'SELECT id, name FROM migration ORDER BY id'
        Dir["#{@migrations_dir}/*.sql"].sort.each do |m|
          next if m.end_with? '_down.sql'
          id = m.sub /.*\/(\d+)_.*/, '\1'
          name = m.sub /.*\/\d+_([^\.]*).sql$/, '\1'
          next if applied.any? { |a| a['id'] == id }
          @log.info "Applying #{File.basename m}"
          conn.exec File.read m
          conn.exec 'INSERT INTO migration (id, name) VALUES ($1, $2)', [id, name]
        end
      end
    end

    def migrate_down
      @pg.transaction do |conn|
        applied = conn.exec 'SELECT id, name FROM migration ORDER BY applied DESC LIMIT 1'
        id = applied.first['id']
        name = applied.first['name']
        down_sql_file = "#{@migrations_dir}/#{id}_#{name}_down.sql"
        unless File.exists? down_sql_file
          @log.error "No down migration found for #{id} #{name} at #{down_sql_file}"
          return
        end
        @log.info "Applying #{File.basename down_sql_file}"
        conn.exec File.read down_sql_file
        conn.exec "DELETE FROM migration WHERE id = $1", [id]
      end
    end

    def close
      @pg.finish
    end
  end
end
