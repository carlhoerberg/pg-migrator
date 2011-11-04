require 'minitest/autorun'
require './lib/pg-migrator'

describe PG::Migrator do
  before do
    @pg = PGconn.connect :dbname => 'pg-migrator'
    @pg.exec 'SET client_min_messages = warning'
    logger = Logger.new STDERR
    logger.level = Logger::FATAL
    @migrator = PG::Migrator.new({:dbname => 'pg-migrator'}, '/tmp', logger)
  end

  it 'can be initialized with a pgconn' do
    PG::Migrator.new(@pg)
  end

  describe 'reset' do
    it 'drops tables' do
      @pg.exec 'create table bar (id int)'
      @migrator.reset
      tables = @pg.exec "select tablename from pg_tables where schemaname = 'public'"
      refute_includes tables.values.flatten, 'bar'
    end

    it 'drops tables from all schemas in search_path' do
      @pg.exec "
        drop schema if exists foo cascade;
        create schema foo
          create table bar (id int);
        drop schema if exists foobar cascade;
        create schema foobar
          create table bar (id int);
        create table public.bar (id int);
      "
      pg = PGconn.connect :dbname => 'pg-migrator'
      pg.exec 'SET search_path TO foo, public'
      migrator = PG::Migrator.new(pg)
      migrator.reset
      migrator.close
      tables = @pg.exec "select schemaname, tablename from pg_tables where tablename = 'bar'"
      assert_equal [['foobar', 'bar']], tables.values
      @pg.exec 'drop schema if exists foobar cascade'
    end
  end

  describe 'migrate' do
    before do
      @migrator.reset
      up = "create table foo (id int)" 
      down = "drop table foo" 
      File.open('/tmp/201109102230_init.sql', 'w') {|f| f.write up }
      File.open('/tmp/201109102230_init_down.sql', 'w') {|f| f.write down }
    end

    after do
      File.delete '/tmp/201109102230_init.sql'
      File.delete '/tmp/201109102230_init_down.sql'
    end

    describe 'up' do
      it 'adds migration table' do
        @migrator.migrate_up
        tables = @pg.exec "select tablename from pg_tables where schemaname = 'public'"
        assert_includes tables.values.flatten, 'migration'
      end

      it 'execute sql files' do
        @migrator.migrate_up
        tables = @pg.exec "select tablename from pg_tables where schemaname = 'public'"
        assert_includes tables.values.flatten, 'foo'
      end

      it 'adds records to the migration table' do
        @migrator.migrate_up
        migrations = @pg.exec "select * from migration"
        assert_equal 1, migrations.count
        assert_equal 201109102230, migrations.first['id'].to_i
        assert_equal 'init', migrations.first['name']
      end
    end

    describe 'down' do 

      it 'executes sql-down files' do
        @migrator.migrate_up
        @migrator.migrate_down
        tables = @pg.exec "select tablename from pg_tables where schemaname = 'public'"
        refute_includes tables.values.flatten, 'foo'
      end

      it 'removes records from the migration table' do
        @migrator.migrate_up
        @migrator.migrate_down
        migrations = @pg.exec "select * from migration"
        assert_equal 0, migrations.count
      end
    end

    after do
      @pg.finish
      @migrator.close
    end
  end
end
