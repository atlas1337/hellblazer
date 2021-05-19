def check_poll_table(server_id)
  db = SQLite3::Database.new 'db/master.db'
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
