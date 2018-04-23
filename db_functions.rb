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

def check_poll_table(server_id)
  db = SQLite3::Database.new "db/#{server_id}.db"
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'poll')
  if table[0][0] == 0
    db.execute <<-SQL
      create table if not exists poll (
        id int,
        channel_id int,
        user_id int,
        started int,
        option text,
        votes int,
        poll_time int,
        elapsed_time int,
        UNIQUE(id)
      );
    SQL

    db.execute <<-SQL
      create table if not exists poll_voters (
        userid int,
        voted int,
        UNIQUE(userid)
      );
    SQL

    query = [
      'ALTER TABLE poll ADD COLUMN id int, UNIQUE(id)',
      'ALTER TABLE poll ADD COLUMN channel_id int',
      'ALTER TABLE poll ADD COLUMN user_id int',
      'ALTER TABLE poll ADD COLUMN started integer',
      'ALTER TABLE poll ADD COLUMN option text',
      'ALTER TABLE poll ADD COLUMN votes integer',
      'ALTER TABLE poll ADD COLUMN poll_time integer',
      'ALTER TABLE poll ADD COLUMN elapsed_time integer',
      'ALTER TABLE poll_voters ADD COLUMN userid int, UNIQUE(userid)',
      'ALTER TABLE poll_voters ADD COLUMN voted integer'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
  db.close if db
  nil
end

def check_bandnames_table(server_id)
  db = SQLite3::Database.new "db/#{server_id}.db"
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'bandnames')
  if table[0][0] == 0
    # Create bandnames table
    db.execute <<-SQL
      create table if not exists bandnames (
        name text,
        genre text,
        addedby int,
        UNIQUE(name)
      );
    SQL

    query = [
      'ALTER TABLE bandnames ADD COLUMN name text, UNIQUE(name)',
      'ALTER TABLE bandnames ADD COLUMN genre text',
      'ALTER TABLE bandnames ADD COLUMN addedby text'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
  db.close if db
  nil
end

def check_quotes_table(server_id)
  db = SQLite3::Database.new "db/#{server_id}.db"
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'quotes')
  if table[0][0] == 0
    # Create quotes table
    db.execute <<-SQL
      create table if not exists quotes (
        quote text,
        added_by int,
        UNIQUE(quote)
      );
    SQL

    query = [
      'ALTER TABLE quotes ADD COLUMN quote text, UNIQUE(quote)',
      'ALTER TABLE quotes ADD COLUMN added_by text'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
  db.close if db
  nil
end

def check_emojicode_table(server_id)
  db = SQLite3::Database.new "db/#{server_id}.db"
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'emojicode')
  if table[0][0] == 0
    # Create emojicode table
    db.execute <<-SQL
      create table if not exists emojicode (
        id int,
        emojicode_text blob,
        UNIQUE(id)
      );
    SQL

    query = [
      'ALTER TABLE emojicode ADD COLUMN id int, UNIQUE(id)',
      'ALTER TABLE emojicode ADD COLUMN emojicode_text blob'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
    db.execute('INSERT OR IGNORE INTO emojicode (id) '\
               'VALUES (?)', 1)
  end
  db.close if db
  nil
end

def dbSetup(server)

  db = SQLite3::Database.new "db/#{server}.db"

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
end
