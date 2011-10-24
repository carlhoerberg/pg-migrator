PG Migrator
===========

A simple migration, which runs pure Postgres SQL files. 

Drop ```<timestamp>_desc.sql``` files in ```db/migrations``` (and corresponding ```<timestamp>_desc_down.sql``` files if you want to be able to downgrade). 

Gemfile:

    require 'pg-migrator/tasks'
    # Make sure to have a DATABASE_URL environment variable
    ENV['DATABASE_URL'] = "postgres://user:passwd@host/db"
    # or if using sockets and default user
    ENV['DATABASE_URL'] = "postgres:db"

Then as usually:

    rake db:reset # drops the "public" schema in your database (not the database it self or any other schemas)
    rake db:migrate:up # runs all migrations in order
    rake db:migrate:down # runs the down migration for the latest applied migration

License
=======

Copyright (C) 2011 by Carl Hörberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
