require 'minitest/autorun'
require './lib/pg-migrator'

describe PG::Migrator do
  before do
    @pg = PGconn.connect :dbname => 'pg-migrator'
    @migrator = PG::Migrator.new({:dbname => 'pg-migrator'}, '/tmp')
  end

  describe 'reset' do
    it 'deletes previous tables' do
      @pg.exec 'create table bar (id int)'
      @migrator.reset
      tables = @pg.exec "select tablename from pg_tables where schemaname = 'public'"
      refute_includes tables.values.flatten, 'bar'
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

      it 'executes sql files in order' do
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
