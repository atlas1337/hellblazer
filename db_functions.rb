#!/usr/bin/env ruby

def check_tos(event, user_id)
  db = SQLite3::Database.new 'db/master.db'
  user = db.execute('SELECT tos_sent FROM terms_of_service WHERE user_id=?', user_id)
  if user.empty?
    db.execute('INSERT OR IGNORE INTO terms_of_service '\
               '(user_id, tos_sent, accepted) '\
               'VALUES (?, ?, ?)', user_id, 'false', 'false')
  end
  tos_sent = db.execute('SELECT tos_sent FROM terms_of_service WHERE user_id=?', user_id)
  tos_accepted = db.execute('SELECT accepted FROM terms_of_service WHERE user_id=?', user_id)
  if tos_sent[0][0] == 'false'
    event.user.pm(Hellblazer.conf['terms_of_service1'])
    sleep 1.25
    event.user.pm(Hellblazer.conf['terms_of_service2'])
    sleep 1.25
    event.user.pm(Hellblazer.conf['terms_of_service3'])
    sleep 1.25
    event.user.pm(Hellblazer.conf['terms_of_service4'])
    sleep 1.25
    db.execute('UPDATE terms_of_service SET tos_sent = ? WHERE user_id = ?', 'true', user_id)
    event.user.pm('Please type !agree if you agree to these terms, otherwise stop using this bot.')
    return false
  elsif tos_sent[0][0] == 'true' && tos_accepted[0][0] == 'false'
    event.user.pm(Hellblazer.conf['Please accept the terms of service you were sent with !agree'])
    return 'sent'
  elsif tos_sent[0][0] == 'true' && tos_accepted[0][0] == 'true'
    return true
  end
  db.close if db
end

def check_tos_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'terms_of_service')
  if table[0][0] == 0
    db.execute <<-SQL
      create table if not exists terms_of_service (
        user_id int,
        tos_sent text,
        accepted text,
        accepted_date date,
        UNIQUE(user_id)
      );
    SQL

    query = [
      'ALTER TABLE poll ADD COLUMN user_id int, UNIQUE(user_id)',
      'ALTER TABLE poll ADD COLUMN tos_sent text',
      'ALTER TABLE poll ADD COLUMN accepted text',
      'ALTER TABLE poll ADD COLUMN accepted_date date'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
end

def check_api_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'api')
  if table[0][0] == 0
    db.execute <<-SQL
      create table if not exists api (
        server_id int,
        api text,
        api_key text
      );
    SQL

    query = [
      'ALTER TABLE poll ADD COLUMN server_id int',
      'ALTER TABLE poll ADD COLUMN api text',
      'ALTER TABLE poll ADD COLUMN api_key text'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
end

def check_prefix_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'bot_prefix')
  if table[0][0] == 0
    db.execute <<-SQL
      create table if not exists bot_prefix (
        server_id int,
        prefix text,
        UNIQUE(server_id)
      );
    SQL

    query = [
      'ALTER TABLE poll ADD COLUMN server_id int, UNIQUE(server_id)',
      'ALTER TABLE poll ADD COLUMN prefix text'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
end

def add_default_prefix(joinedServer)
  print joinedServer
  db = SQLite3::Database.new 'db/master.db'
  server = db.execute("SELECT server_id FROM bot_prefix WHERE server_id = ?", joinedServer)
  print server
  if server.empty?
    print 'empty'
    db.execute('INSERT OR IGNORE INTO bot_prefix '\
               '(server_id, prefix) '\
               'VALUES (?, ?)', joinedServer, '!')
  end
end

=begin

  # Create currency table
  db.execute <<-SQL
    create table if not exists currency (
      userid int,
      amount int,
      UNIQUE(userid)
    );
  SQL


  query = [
    'ALTER TABLE currency ADD COLUMN userid int, UNIQUE(userid)',
    'ALTER TABLE currency ADD COLUMN amount int'
  ]
  query.each do |q|
    begin
      db.execute(q)
    rescue SQLite3::Exception
      next
    end
  end

  # Set up levels table
  db.execute <<-SQL
      create table if not exists levels (
        userid int,
        level int,
        xp int,
        UNIQUE(userid)
      );
  SQL

  query = [
    'ALTER TABLE levels ADD COLUMN userid int, UNIQUE(userid)',
    'ALTER TABLE levels ADD COLUMN level int',
    'ALTER TABLE levels ADD COLUMN xp int'
  ]
  query.each do |q|
    begin
      db.execute(q)
    rescue SQLite3::Exception
      next
    end
  end
=end
#end
