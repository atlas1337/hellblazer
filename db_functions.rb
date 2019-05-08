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

def check_poll_table(server_id)
  db = SQLite3::Database.new "db/master.db"
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'poll')
  if table[0][0] == 0
    db.execute <<-SQL
      create table if not exists polls (
        id int,
		server_id int,
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
	    server_id int,
        userid int,
        voted int,
        UNIQUE(userid)
      );
    SQL

    query = [
      'ALTER TABLE polls ADD COLUMN id int, UNIQUE(id)',
	  'ALTER TABLE polls ADD COLUMN server_id int',
      'ALTER TABLE polls ADD COLUMN channel_id int',
      'ALTER TABLE polls ADD COLUMN user_id int',
      'ALTER TABLE polls ADD COLUMN started integer',
      'ALTER TABLE polls ADD COLUMN option text',
      'ALTER TABLE polls ADD COLUMN votes integer',
      'ALTER TABLE polls ADD COLUMN poll_time integer',
      'ALTER TABLE polls ADD COLUMN elapsed_time integer',
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

def check_bandnames_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'bandnames')
  if table[0][0] == 0
    # Create bandnames table
    db.execute <<-SQL
      create table if not exists bandnames (
        name text,
        genre text,
        added_by int,
        server_id int,
        server_name text
      );
    SQL

    query = [
      'ALTER TABLE bandnames ADD COLUMN name text',
      'ALTER TABLE bandnames ADD COLUMN genre text',
      'ALTER TABLE bandnames ADD COLUMN added_by int',
      'ALTER TABLE bandnames ADD COLUMN server_id int',
      'ALTER TABLE bandnames ADD COLUMN server_name text'
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

def check_quotes_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'quotes')
  if table[0][0] == 0
    # Create quotes table
    db.execute <<-SQL
      create table if not exists quotes (
        quote text,
        added_by int,
        server_id int,
        server_name text
      );
    SQL

    query = [
      'ALTER TABLE quotes ADD COLUMN quote text',
      'ALTER TABLE quotes ADD COLUMN added_by int',
      'ALTER TABLE quotes ADD COLUMN server_id int',
      'ALTER TABLE quotes ADD COLUMN server_name text'
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

def check_emojicode_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'emojicode')
  if table[0][0] == 0
    # Create emojicode table
    db.execute <<-SQL
      create table if not exists emojicode (
        server_id int,
        emojicode_text text
      );
    SQL

    query = [
      'ALTER TABLE emojicode ADD COLUMN server_id int',
      'ALTER TABLE emojicode ADD COLUMN emojicode_text text'
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

def check_reminders_table
  db = SQLite3::Database.new "db/master.db"
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'reminders')
  if table[0][0] == 0
    # Create emojicode table
    db.execute <<-SQL
      create table if not exists reminders (
        id INTEGER PRIMARY KEY,
        reminder text,
        user int,
        remind_time text
      );
    SQL

    query = [
      'ALTER TABLE reminders ADD COLUMN reminder text',
      'ALTER TABLE reminders ADD COLUMN user int',
      'ALTER TABLE reminders ADD COLUMN remind_time text'
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
